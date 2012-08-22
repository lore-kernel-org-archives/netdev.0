From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: smsc75xx & smsc95xx, setting skb->truesize correctly?
Date: Wed, 22 Aug 2012 08:35:49 +0300
Message-ID: <20120822083549.57260n3jdqfgxtj4@www.81.fi>
References: <20120820175706.12394vktsvm3yvqc@www.81.fi>
 <1345542398.5158.446.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-01.sanoma.fi ([158.127.18.161]:49166 "EHLO
	sd-mail-sa-01.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HVFfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 01:35:52 -0400
In-Reply-To: <1345542398.5158.446.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric Dumazet <eric.dumazet@gmail.com>:

> On Mon, 2012-08-20 at 17:57 +0300, Jussi Kivilinna wrote:
>> Hello,
>>
>> Is setting skb->truesize in smsc75xx and smsc95xx correct?
>> In smsc75xx/smsc95xx_rx_fixup(), input skb containing multiple packets
>> is cloned and truesize for each clone is set to packet-size +
>> sizeof(struct sk_buff), but input skb has minimum allocation size of
>> 9000 bytes (MAX_SINGLE_PACKET_SIZE) and maximum of 18944 bytes
>> (DEFAULT_HS_BURST_CAP_SIZE) (+ NET_IP_ALIGN). Doesn't this cause
>> truesize to be underestimated?
>
> This has been discussed in a "TCP transmit performance regression"
> thread some weeks ago.
>
> More generally, skb_clone() is not a good idea in rx path.

So all skb_clone use in drivers/net/usb/ should be removed/replaced  
with following?

>
> I dont have the hardware so cannot send a formal patch.

Neither do I, was looking for gigabit-usb dongle to buy and ended up  
checking various drivers.

I guess I could do and test this for rndis_host/rndis_wlan and add  
rx-skb recycling to usbnet core for drivers that do copy-break in  
rx_fixup.

-Jussi

>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index b1112e7..3d9566f 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1080,30 +1080,17 @@ static int smsc95xx_rx_fixup(struct usbnet  
> *dev, struct sk_buff *skb)
>  				return 0;
>  			}
>
> -			/* last frame in this batch */
> -			if (skb->len == size) {
> -				if (dev->net->features & NETIF_F_RXCSUM)
> -					smsc95xx_rx_csum_offload(skb);
> -				skb_trim(skb, skb->len - 4); /* remove fcs */
> -				skb->truesize = size + sizeof(struct sk_buff);
> -
> -				return 1;
> -			}
> -
> -			ax_skb = skb_clone(skb, GFP_ATOMIC);
> +			ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
>  			if (unlikely(!ax_skb)) {
>  				netdev_warn(dev->net, "Error allocating skb\n");
>  				return 0;
>  			}
>
> -			ax_skb->len = size;
> -			ax_skb->data = packet;
> -			skb_set_tail_pointer(ax_skb, size);
> +			memcpy(skb_put(ax_skb, size), packet, size);
>
>  			if (dev->net->features & NETIF_F_RXCSUM)
>  				smsc95xx_rx_csum_offload(ax_skb);
> -			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
> -			ax_skb->truesize = size + sizeof(struct sk_buff);
> +			__skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
>
>  			usbnet_skb_return(dev, ax_skb);
>  		}
>
>
>
>
