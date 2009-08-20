From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Thu, 20 Aug 2009 16:04:40 +0200
Message-ID: <4A8D57F8.1050106@gmail.com>
References: <4A855DE2.2000907@gmail.com>	<20090814163644.0cc8974f.akpm@linux-foundation.org>	<20090814.164123.36875657.davem@davemloft.net>	<20090814165852.7338461e.akpm@linux-foundation.org>	<4A86BAF3.5060609@gmail.com> <m3iqgovrsv.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:51891 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbZHTOAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 10:00:03 -0400
Received: by ewy3 with SMTP id 3so2899812ewy.18
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 07:00:03 -0700 (PDT)
In-Reply-To: <m3iqgovrsv.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the tests that check whether Frame* bits are not set

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---

>> -		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
>> +		else if (!(skb->data[pkt_len] & (FrameVfr | FrameRab)))
>>  			dev->stats.rx_length_errors++;
> 
> This test requires both FrameVfr and FrameRab to be true (zero). Perhaps
> it should be:
> 
>> +		else if ((skb->data[pkt_len] & (FrameVfr | FrameRab)) != FrameVfr | FrameRab)

Ok, Francois Romieu, could you test this?

>>  		else
>>  			dev->stats.rx_errors++;
> 
> rx_errors is incremented only on remaining errors. I think most drivers
> increment rx_errors on all RX errors, and simultaneously rx_*_errors
> when needed.
> 
> 
> Perhaps something like the following should be better?
> 
> 		u8 status = ~skb->data[pkt_len];
> 
> 		if (status == 0)
> 			looks_good...;
> 		else {
> 			if (status & FrameRab)
> 				...
> 			if (status & FrameVfr)
> 				...
> 			etc.
> 			rx_errors++;
> 		}

I don't understand your suggestion - why status == 0? doesn't the patch
below do what you want instead?

Roel

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 8face5d..88534b6 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -663,12 +663,12 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 	} else {
 		if (skb->data[pkt_len] & FrameRdo)
 			dev->stats.rx_fifo_errors++;
-		else if (!(skb->data[pkt_len] | ~FrameCrc))
+		else if (!(skb->data[pkt_len] & FrameCrc))
 			dev->stats.rx_crc_errors++;
-		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
+		else if ((skb->data[pkt_len] & (FrameVfr | FrameRab)) !=
+				FrameVfr | FrameRab)
 			dev->stats.rx_length_errors++;
-		else
-			dev->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		dev_kfree_skb_irq(skb);
 	}
 refill:
