From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Wed, 01 Jul 2015 18:19:24 +0200
Message-ID: <1435767564.4110.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5593EB38.5050000@certsign.ro>
	 <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5593F956.4020300@certsign.ro>
	 <1435764834.4110.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAH=tA9HHqQMhs5_qdc63BsT1BW0jvmoEChbsgzvn-LKqbUt1zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolae Rosia <nicolae.rosia@certsign.ro>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>
To: Nicolae Rosia <nicolae.rosia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34431 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603AbbGAQT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 12:19:29 -0400
Received: by wiar9 with SMTP id r9so74719760wia.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 09:19:28 -0700 (PDT)
In-Reply-To: <CAH=tA9HHqQMhs5_qdc63BsT1BW0jvmoEChbsgzvn-LKqbUt1zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-01 at 18:53 +0300, Nicolae Rosia wrote:
> On Wed, Jul 1, 2015 at 6:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> [...]
> > This only matters in terms of few nano seconds per packet, so for 10Gb+
> > NIC anyway. Absolute noise for most NIC.
> >
> I'll give it a try and benchmark.
> I achieved a huge speedup by moving TX into napi [0], but my hardware doesn't
> support multiple TX queues and I can't test that situation.
> 
> > Yes, but main question is : Do you have the hardware to test your
> > changes ?
> Yes, I have a Xilinx ZC706 board with a Zynq7 XC7Z045 processor [1]
> 
> [0] https://patchwork.ozlabs.org/patch/488949/
> [1] http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html

OK, then enabling GRO should be quite easy, given driver already has
most of it.

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index caeb39561567237261ac0d50befebad666cfbeb3..24a93c769caa5430ca61efe002b458fef7281e99 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -815,7 +815,7 @@ static int gem_rx(struct macb *bp, int budget)
 			       skb->data, 32, true);
 #endif
 
-		netif_receive_skb(skb);
+		napi_gro_receive(&bp->napi, skb);
 	}
 
 	gem_rx_refill(bp);
@@ -896,7 +896,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	bp->stats.rx_bytes += skb->len;
 	netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
 		   skb->len, skb->csum);
-	netif_receive_skb(skb);
+	napi_gro_receive(&bp->napi, skb);
 
 	return 0;
 }
