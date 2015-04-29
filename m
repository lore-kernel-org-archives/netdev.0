From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next v3 3/4] rocker: Handle IFF_PROTODOWN by doing
 a PHYS-DOWN on the switch port.
Date: Tue, 28 Apr 2015 22:51:07 -0700
Message-ID: <CAE4R7bD=QPViX4Fig7TSS+P3XdBHWG=Ei_LOPcBYi+4qGhhaew@mail.gmail.com>
References: <1430156304-13187-4-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bDF4C_WpueoiRkXDyHk=TfQJG99GB8jEFtOL-yN6Sa2xQ@mail.gmail.com>
	<CACcJQnRi1AOYiu_0t3Acx1=t7W6z6i7DqawvWZUiCcOLV5Rm+w@mail.gmail.com>
	<CAE4R7bAcH7OSYfKWEj+Jn8XTX4CbKzeCpSGvkZQn6UU-EoFMYA@mail.gmail.com>
	<CACcJQnRjQbmK_PqOgga-hT5vBDBGCXTRbuDXfoFDuODZJHQ9tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:32813 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031630AbbD2FvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 01:51:08 -0400
Received: by qgdy78 with SMTP id y78so7349410qgd.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 22:51:07 -0700 (PDT)
In-Reply-To: <CACcJQnRjQbmK_PqOgga-hT5vBDBGCXTRbuDXfoFDuODZJHQ9tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 1:35 PM, Anuradha Karuppiah
<anuradhak@cumulusnetworks.com> wrote:
> On Tue, Apr 28, 2015 at 12:48 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Tue, Apr 28, 2015 at 8:49 AM, Anuradha Karuppiah
>> <anuradhak@cumulusnetworks.com> wrote:
>>> On Mon, Apr 27, 2015 at 10:51 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>>>> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wrote:
>>>>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>>>
>>>>> IFF_PROTODOWN can be set by user space applications like MLAG on detecting
>>>>> errors on a switch port. This patch provides sample switch driver changes
>>>>> for handling IFF_PROTODOWN. Rocker PHYS disables the port in response to
>>>>> protodown.
>>>>>
>>>>> Note: I understand Scott has some rocker changes on hold. I will re-spin
>>>>> this patch once his changes are in.
>>>>>
>>>>> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>>>> ---
>>>>>  drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
>>>>>  1 file changed, 15 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>>>> index a87b177..e3084e3 100644
>>>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>>>> @@ -3838,7 +3838,8 @@ static int rocker_port_open(struct net_device *dev)
>>>>>
>>>>>         napi_enable(&rocker_port->napi_tx);
>>>>>         napi_enable(&rocker_port->napi_rx);
>>>>> -       rocker_port_set_enable(rocker_port, true);
>>>>> +       if (!(dev->flags & IFF_PROTO_DOWN))
>>>>> +               rocker_port_set_enable(rocker_port, true);
>>>>>         netif_start_queue(dev);
>>>>>         return 0;
>>>>>
>>>>> @@ -4238,6 +4239,18 @@ static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
>>>>>         return rocker_port_stp_update(rocker_port, state);
>>>>>  }
>>>>>
>>>>> +static int rocker_port_swdev_port_phy_state_set(struct net_device *dev,
>>>>> +                                               bool enable)
>>>>> +{
>>>>> +       struct rocker_port *rocker_port = netdev_priv(dev);
>>>>> +
>>>>> +       if (enable && (dev->flags & IFF_UP) && !(dev->flags & IFF_PROTO_DOWN))
>>>>> +               rocker_port_set_enable(rocker_port, true);
>>>>> +       else
>>>>> +               rocker_port_set_enable(rocker_port, false);
>>>>
>>>> This isn't working like your expecting.  PHY link is still up on the
>>>> rocker port, so the other end of the wire still sees link UP even when
>>>> IFF_PROTO_DOWN is set locally.
>>>
>>> I wanted to check with you first on the rocker handling; that is the main
>>> reason for posting this an RFC (thanks for the review).
>>>
>>> I used rocker_port_set_enable/PORT_PHYS_ENABLE for setting the phy state
>>> because I assumed that in the case of an offloaded switch driver it would be
>>> the equivalent of doing "sdk port N en=1|0". Is that not the case? If not,
>>> could you please point me in the right direction?
>>
>> To put PHY link down, on PORT_PHYS_ENABLE true, rocker device (qemu)
>> would need to down the link state for the port so other end of wire
>> sees link down.  I think I remember looking into that but didn't
>> implement it.  In qemu monitor, you can manually set the link up/down
>> (set_link <dev> [on|off]).  We'd need to call the same from within the
>> rocker device.
>>
>> So if we want to be able to test this with rocker, we'll need a device
>> and driver change.
>
> Thanks for the details, Scott. We will looking into implementing the necessary
> changes to get it working with rocker.

Hmmm....looks like we can only go so far using rocker.  The patch
below for rocker device will set link up/down when phy is
enabled/disabled, but that only affects the local link status.  The
remote will not see link down/up when the local changes because there
is no physical signalling between two VM instances (local and remote)
(duh!).  I'll add the device patch to my queue just because it's a
good things to have, but at this point I'm not seeing how you can use
rocker to down the remote link.

diff --git a/hw/net/rocker/rocker_fp.c b/hw/net/rocker/rocker_fp.c
index 42354c3..d8d934c 100644
--- a/hw/net/rocker/rocker_fp.c
+++ b/hw/net/rocker/rocker_fp.c
@@ -188,8 +188,19 @@ bool fp_port_enabled(FpPort *port)
     return port->enabled;
 }

+static void fp_port_set_link(FpPort *port, bool up)
+{
+    NetClientState *nc = qemu_get_queue(port->nic);
+
+    if (up == nc->link_down) {
+        nc->link_down = !up;
+        nc->info->link_status_changed(nc);
+    }
+}
+
 void fp_port_enable(FpPort *port)
 {
+    fp_port_set_link(port, true);
     port->enabled = true;
     DPRINTF("port %d enabled\n", port->index);
 }
@@ -197,6 +208,7 @@ void fp_port_enable(FpPort *port)
 void fp_port_disable(FpPort *port)
 {
     port->enabled = false;
+    fp_port_set_link(port, false);
     DPRINTF("port %d disabled\n", port->index);
 }
