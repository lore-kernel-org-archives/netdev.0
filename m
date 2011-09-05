From: Jim Wylder <jwylder1@motorola.com>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Mon, 5 Sep 2011 11:29:05 -0500
Message-ID: <CAPopfEXz+HPdwWh_GQ2WzMnHh5DuXTse78NAU=-iN15wv-0C5g@mail.gmail.com>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
	<201109031837.48444.oliver@neukum.org>
	<CAPopfEWi0v9VXeDYcBfEgnWYxg7WcTTj3GBc6USzwcN+aGrKOQ@mail.gmail.com>
	<201109041216.12127.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:42167 "EHLO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab1IEQ3J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 12:29:09 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.176.129.42])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p85GPF4i015540
	for <netdev@vger.kernel.org>; Mon, 5 Sep 2011 12:25:16 -0400 (EDT)
Received: from mail-ww0-f46.google.com (mail-ww0-f46.google.com [74.125.82.46])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p85GPEbr015532
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 5 Sep 2011 12:25:15 -0400 (EDT)
Received: by wwg7 with SMTP id 7so4926612wwg.3
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2011 09:29:06 -0700 (PDT)
In-Reply-To: <201109041216.12127.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calling pm_runtime_get, usb_autopm_get_interface_async
treats a return value of -EINPROGRESS as a success and
increments the usage count.  Since the interface is resuming,
it is safe for usbnet_start_xmit to submit the urb.  If instead,
usbnet_start_xmit treats this as an error the packet will be
dropped.  Additionally, a corresponding tx_complete will not
run to offset the earlier increment of the usage count from the
call to usb_autopm_get_interface_async.

Signed-off-by: James Wylder <james.wylder@motorola.com>
---
 drivers/net/usb/usbnet.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ce395fe..7dcef05 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -81,6 +81,19 @@

 /*--------------------------------------------------------------------=
-----*/

+/* When power management is configured, usb_autopm_get_interface_async=
()
+ * will return -EINPROGRESS to signify that the interface was already
+ * resuming at the time that the function was called.  In our case
+ * (all cases?) this not an error condition.
+ * */
+#ifdef CONFIG_PM
+#define USBNET_PM_INTF_ALREADY_RESUMING(x) (x =3D=3D -EINPROGRESS)
+#else
+#define USBNET_PM_INTF_ALREADY_RESUMING(x) 0
+#endif
+
+/*--------------------------------------------------------------------=
-----*/
+
 // randomly generated ethernet address
 static u8	node_id [ETH_ALEN];

@@ -1042,6 +1055,7 @@ EXPORT_SYMBOL_GPL(usbnet_tx_timeout);

 /*--------------------------------------------------------------------=
-----*/

+
 netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 				     struct net_device *net)
 {
@@ -1105,7 +1119,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *sk=
b,

 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval =3D usb_autopm_get_interface_async(dev->intf);
-	if (retval < 0) {
+	if (retval < 0 && !USBNET_PM_INTF_ALREADY_RESUMING(retval)) {
 		spin_unlock_irqrestore(&dev->txq.lock, flags);
 		goto drop;
 	}
--=20
1.7.6

On Sun, Sep 4, 2011 at 5:16 AM, Oliver Neukum <oliver@neukum.org> wrote=
:
> Am Samstag, 3. September 2011, 19:32:44 schrieb Jim Wylder:
>
> Hi,
>
>> Thanks for the quick feedback. =A0True usbnet_start_xmit() could be
>> running at anytime, but the usb_autopm_get_interface_async() will on=
ly
>> return -EINPROGRESS when rpm_resume detects that
>> dev->power.runtime_status =3D=3D RPM_RESUMING. =A0My understanding i=
s that
>> for an asynchronous request, the promise that the device is resuming
>> would be equivalent to cases where usb_autopm_get_interface_async()
>> returns success.
>
> If CONFIG_PM is set.
>
>> In all other cases, when we are not attempting to resume an already
>> resuming interface, this change should have no impact.
>>
>> Are you recommending that I add an additional check for DEV_ASLEEP,
>
> The check is already there but depending on CONFIG_PM.
>
>> possibly to decide whether to drop the or continue on? =A0Or am I
>> missing your point? =A0I had not done anything similar because my
>> understanding was that knowing that the device is in fact resuming
>> would be sufficient.
>
> At that point it is sufficient. Upon further thought it looks like yo=
ur check
> is correct.
> We just need to make very sure that for the decision to queue or
> to submit EVENT_DEV_ASLEEP is relevant.
> Would you consider defining a macro with a nice name for the
> =3D=3D0 || =3D=3D -EINPROGRESS check, so that any reader knows what
> this is about? This is because I doubt only usbnet is affected.
>
> =A0 =A0 =A0 =A0Regards
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Oliver
>
