From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Sat, 4 Dec 2010 22:18:29 +0800
Message-ID: <20101204141826.GA5830@Desktop-Junchang>
References: <20101203101450.GA9573@Desktop-Junchang>
 <1291373429.2897.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:54817 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133Ab0LDOSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:18:50 -0500
Received: by pva4 with SMTP id 4so1596677pva.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:18:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291373429.2897.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 03, 2010 at 11:50:29AM +0100, Eric Dumazet wrote:
>
>This is because __alloc_skb() is generic :
>
>We dont know if the skb->data is going to be used right after or not at
>all.
>
>For example, NIC drivers call __alloc_skb() to refill their RX ring
>buffer. There is no gain to prefetch data in this case since the data is
>going to be written by the NIC hardware. The reverse would be needed
>actually : ask to local cpu to evict data from its cache, so that device
>can DMA it faster (less bus transactions)

Thanks for your explanation. Now I understand your patch. :)

>
>By the way, adding prefetchw() right before the "return skb;" is
>probably not very useful. 

Did you mean adding prefetchw() right before the "return" instruction 
doesn't gain beneficial effect? 

My understanding is that what prefetch instructions do is to hint cpu 
to hot some cache lines, so this kind of prefetch could also benefit 
following functions.

>You can certainly try to add the prefetchw()
>in pktgen itself, since you know for sure you are going to write the
>data.
>
>I dont understand your 10% speedup because pktgen actually uses
>__netdev_alloc_skb(), so it calls skb_reserve(skb, NET_SKB_PAD) : your
>prefetchw is bringing a cache line that wont be used at all by pktgen.

Thanks for corrections. Please check the following code.
>
>I would say 10% sounds highly suspect to me...
>
I repeated the experiment a number of times (>10). The number of 10% was
careless, but I confirmed there's speedup, which fall into (%3, 8%). I
found it hard to give the exact number of speedup because I had to reboot
the system each time I added the prefetch code.

I noticed the hardware prefetch(Hardware Prefetcher and Adjacent Cache
Line Prefetch) was turn on by default. I doubt my faulty code gain benefit
from hardware prefetch. Without those two options, the performance of 
both pktgens reduced by 5%-8% and I can hardly see beneficial effect from
my previous code. 

I added the prefetchw() in pktgen as follows:

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2953b2a..512f1ae 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2660,6 +2660,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
 	}
+	prefetchw(skb->data);
 
 	skb_reserve(skb, datalen);
 
This time, I can check it without rebooting the system. The performance 
gain is 4%-5%(stable). Does 4% worth submitting it to the kernel?

Thanks.

--Junchang
