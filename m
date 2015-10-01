From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: Re: [PATCH] net: usb: asix: Fix crash on skb alloc failure
Date: Thu, 1 Oct 2015 11:51:31 +0100
Message-ID: <560D1033.6020301@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Craske, Mark" <Mark_Craske@mentor.com>
To: "David B. Robins" <linux@davidrobins.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:51349 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbbJAKw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 06:52:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If asix_rx_fixup_internal() fails to allocate rx->ax_skb, it will return
> but not clear rx->size. rx points to driver private data. A later call
> assumes that nonzero size means ax_skb was allocated and passes a null
> ax_skb to skb_put. Changed allocation failure return to clear size first.
>
> Found testing board with AX88772B devices.
>
> Signed-off-by: David B. Robins <linux@xxxxxxxxxxxxxxx>
> ---
>   drivers/net/usb/asix_common.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
> index 75d6f26..079069a 100644
> --- a/drivers/net/usb/asix_common.c
> +++ b/drivers/net/usb/asix_common.c
> @@ -91,8 +91,10 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
>   			}
>   			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net,
>   							       rx->size);
> -			if (!rx->ax_skb)
> +			if (!rx->ax_skb) {
> +				rx->size = 0;
>   				return 0;
> +			}
>   		}
>   
>   		if (rx->size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
> -- 
> 1.9.1
Hi David,

I copied your patch from 
http://www.spinics.net/lists/netdev/msg345724.html and resubscribed to 
netdev@vger.kernel.org so I am unable to directly reply to your original 
post. But I should now see any subsequent reply on the mailing list.

We are preparing to release some fixes in this area of the asix driver 
which fixes your observation. Unfortunately, your simple proposal has a 
flaw because state variables exist outside of the scope of 
asix_rx_fixup_internal() which handles Ethernet frames spanning multiple 
URBs (depends on the variant of the USB ASIX chipset). Therefore, 
subsequent URBs with the remainder of the Ethernet frame need to be 
handled when no netdev socket buffer exists.

We intend to release the patches within the next few days so please 
watch out for them.

Regards,
Dean

-- 
Dean Jenkins
Embedded Software Engineer
Linux Transportation Solutions
Mentor Embedded Software Division
Mentor Graphics (UK) Ltd.
