From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Fri, 22 May 2009 16:27:20 +0200
Message-ID: <9E304569-5828-403D-B4B0-845D8F0D6B95@it-loops.com>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com> <20090520214734.GA11277@mail.wantstofly.org> <20090521.152439.79009648.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:34510
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756223AbZEVO1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 10:27:23 -0400
In-Reply-To: <20090521.152439.79009648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 22, 2009, at 0:24, David Miller wrote:

> From: Lennert Buytenhek <buytenh@wantstofly.org>
> Date: Wed, 20 May 2009 23:47:34 +0200
>
>> gianfar puts skbuffs that are in the rx ring back onto the recycle
>> list if there was a receive error, but this breaks the following
>> invariant: that all skbuffs on the recycle list have skb->data =
>> skb->head + NET_SKB_PAD (NET_SKB_PAD being 32 for you).
>>
>> In this case, the skb's ->data will be skb->head + RXBUF_ALIGNMENT
>> (where RXBUF_ALIGNMENT is 64) when it is put onto the recycle list.
>> And when gfar_new_skb() picks this skb off the recycle list again,
>> it'll do:
>>
>>        alignamount = RXBUF_ALIGNMENT -
>>                (((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1));
>>
>>        /* We need the data buffer to be aligned properly.  We will  
>> reserve
>>         * as many bytes as needed to align the data properly
>>         */
>>        skb_reserve(skb, alignamount);
>>
>> So now skb->data will be skb->head + 128, and there won't be enough
>> space between skb->head and skb->end to hold a full-sized packet.
>>
>> Something like the patch below would fix it.
>
> Let me know when a final, tested, version of this patch is available
> and please make sure it makes it to netdev@vger.kernel.org

I can confirm that Lennert's patch fixes my panic problems here. After  
applying it, my connection has been rock solid and I no longer get any  
kernel panics.
That said, I think the final descision if this patch should go in like  
it is now has to be made by Andy Fleming since he wrote the initial  
code.

Kind regards,
Michael

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b2c4967..85883c7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1886,7 +1886,7 @@ int gfar_clean_rx_ring(struct net_device *dev,  
int rx_work_limit)
			if (unlikely(!newskb))
				newskb = skb;
			else if (skb)
-				__skb_queue_head(&priv->rx_recycle, skb);
+				dev_kfree_skb_any(skb);
		} else {
			/* Increment the number of packets */
			dev->stats.rx_packets++;

