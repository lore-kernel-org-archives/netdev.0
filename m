From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] cdc_ncm: do not call usbnet_link_change from cdc_ncm_bind
Date: Mon, 7 Mar 2016 21:15:36 +0100
Message-ID: <87k2le815w.fsf_-_@nemi.mork.no>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	<20160307.141100.1511700720120062677.davem@davemloft.net>
	<CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	<20160307.145406.188091362181073486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andreyknvl@gmail.com, torvalds@linux-foundation.org,
	oneukum@suse.com, dvyukov@google.com, glider@google.com,
	kcc@google.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36722 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbcCGUsv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:48:51 -0500
In-Reply-To: <20160307.145406.188091362181073486.davem@davemloft.net> (David
	Miller's message of "Mon, 07 Mar 2016 14:54:06 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet_link_change will call schedule_work and should be
avoided if bind is failing. Otherwise we will end up with
scheduled work referring to a netdev which has gone away.

Instead of making the call conditional, we can just defer
it to usbnet_probe, using the driver_info flag made for
this purpose.

=46ixes: 8a34b0ae8778 ("usbnet: cdc_ncm: apply usbnet_link_change")
Reported-by: Andrey Konovalov <andreyknvl@gmail.com>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---

David Miller <davem@davemloft.net> writes:
> From: Andrey Konovalov <andreyknvl@gmail.com>
>
>> Could you also add:
>> Reported-by: Andrey Konovalov <andreyknvl@gmail.com>
>> ?
>
> Sorry it's already committed to my tree and I can't redo the commit m=
essage
> once that happens since my tree has static history.

Even with Oliver's generic fix we should still fix the inconsistency
in cdc_ncm, as pointed out by Linus.

This is a slightly different approach than the patch proposed by Linus.
When I started looking at this I couldn't figure out why we were doing
this differently in this driver from all the other usbnet drivers
disabling the link at probe time.  So let's make it consistent.  Then a=
t
least we get consistent bugs :)


Bj=C3=B8rn


 drivers/net/usb/cdc_ncm.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index be927964375b..86ba30ba35e8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -988,8 +988,6 @@ EXPORT_SYMBOL_GPL(cdc_ncm_select_altsetting);
=20
 static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
 {
-	int ret;
-
 	/* MBIM backwards compatible function? */
 	if (cdc_ncm_select_altsetting(intf) !=3D CDC_NCM_COMM_ALTSETTING_NCM)
 		return -ENODEV;
@@ -998,16 +996,7 @@ static int cdc_ncm_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	 * Additionally, generic NCM devices are assumed to accept arbitraril=
y
 	 * placed NDP.
 	 */
-	ret =3D cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0=
);
-
-	/*
-	 * We should get an event when network connection is "connected" or
-	 * "disconnected". Set network connection in "disconnected" state
-	 * (carrier is OFF) during attach, so the IP network stack does not
-	 * start IPv6 negotiation and more.
-	 */
-	usbnet_link_change(dev, 0, 0);
-	return ret;
+	return cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0)=
;
 }
=20
 static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, si=
ze_t remainder, size_t max)
@@ -1590,7 +1579,8 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
=20
 static const struct driver_info cdc_ncm_info =3D {
 	.description =3D "CDC NCM",
-	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
+	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
+			| FLAG_LINK_INTR,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
 	.manage_power =3D usbnet_manage_power,
@@ -1603,7 +1593,7 @@ static const struct driver_info cdc_ncm_info =3D =
{
 static const struct driver_info wwan_info =3D {
 	.description =3D "Mobile Broadband Network Device",
 	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
-			| FLAG_WWAN,
+			| FLAG_LINK_INTR | FLAG_WWAN,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
 	.manage_power =3D usbnet_manage_power,
@@ -1616,7 +1606,7 @@ static const struct driver_info wwan_info =3D {
 static const struct driver_info wwan_noarp_info =3D {
 	.description =3D "Mobile Broadband Network Device (NO ARP)",
 	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
-			| FLAG_WWAN | FLAG_NOARP,
+			| FLAG_LINK_INTR | FLAG_WWAN | FLAG_NOARP,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
 	.manage_power =3D usbnet_manage_power,
--=20
2.1.4
