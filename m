From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Thu, 27 Mar 2014 13:53:03 +0100
Message-ID: <20140327125303.GA22117@breakpoint.cc>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
 <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com>
 <525C0993.70503@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39035 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756463AbaC0MxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:53:07 -0400
Content-Disposition: inline
In-Reply-To: <525C0993.70503@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-14 18:11:15 [+0300], Claudiu Manoil wrote:
> >>BUG: soft lockup - CPU#0 stuck for 23s! [iperf:2847]
> >>NIP [c0255b6c] find_next_bit+0xb8/0xc4
> >>LR [c0367ae8] gfar_poll+0xc8/0x1d8
> >It seems there is a race condition, and this patch only makes it happen
> >less often ?
> >
> >return faster means what exactly ?
> >
> 
> Hi Eric,
> Because of the outer while loop, gfar_poll may not return due
> to continuous tx work. The later implementation of gfar_poll
> allows only one iteration of the Tx queues before returning
> control to net_rx_action(), that's what I meant with "returns faster".

We talk here about 23secs of cleanup. RX is limited by NAPI and TX is
limited because it can't be refilled on your UP system.
Does your box recover from this condition without this patch? Mine does
not. But I run -RT and stumbled uppon something different.

What I observe is that the TX queue is not empty but does not make any
progress. That means tx_queue->tx_skbuff[tx_queue->skb_dirtytx] is true
and gfar_clean_tx_ring() cleans up zero packages because it is not yet
complete.

My problem is that when gfar_start_xmit() is preemted after the 
tx_queue->tx_skbuff[tx_queue->skb_curtx] is set but before the DMA is started
then the NAPI-poll never completes because it sees a packet which never
completes because the DMA engine did no start yet and won't.
On non-RT SMP systems this isn't a big problem because on the first iteration
the DMA engine might be idle but on the second the other CPU most likely
started the DMA engine and on the fifth the packet might be gone so you
stop (finally).

What happens on your slow link setup is probably the following:
You enqueue hundrets of packets which need TX cleanup. Since that link
is *that* slow, you spent a bunch of cycles calling gfar_clean_tx_ring()
with zero cleanup and you can't leave the poll routine because there is
TX skb not cleaned up. What amazes me is hat it keeps you CPU busy for
as long as 23secs.
*IF* the link goes down in the middle of a cleanup you should see
similar stall because that TX packet won't leave the device so you never
cleanup. So what happens here? Do you get an error interrupt which
purges that skb or do you wait for ndo_tx_timeout()? One of these two
will save your ass but it ain't pretty.

To fix properly with something that works on -RT and mainline I suggest
to revert this patch and add the following:
- do not set has_tx_work unless gfar_clean_tx_ring() unless atleast one
  skb has been cleaned up.
- take the TX cleanup into NAPI accounting. I am not sure if it is
  realistic that one CPU is filling the queue and the other cleans up
  continuously assuming a GBIT link and small packets. However this should
  put a limit here.

which looks in C like this:

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1799ff0..19192c4 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -132,7 +132,6 @@ static int gfar_poll(struct napi_struct *napi, int budget);
 static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
-static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
 static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 			       int amount_pull, struct napi_struct *napi);
 void gfar_halt(struct net_device *dev);
@@ -2473,7 +2472,7 @@ static void gfar_align_skb(struct sk_buff *skb)
 }
 
 /* Interrupt Handler for Transmit complete */
-static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
+static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 {
 	struct net_device *dev = tx_queue->dev;
 	struct netdev_queue *txq;
@@ -2854,10 +2853,14 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			tx_queue = priv->tx_queue[i];
 			/* run Tx cleanup to completion */
 			if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
-				gfar_clean_tx_ring(tx_queue);
-				has_tx_work = 1;
+				int ret;
+
+				ret = gfar_clean_tx_ring(tx_queue);
+				if (ret)
+					has_tx_work++;
 			}
 		}
+		work_done += has_tx_work;
 
 		for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
 			/* skip queue if not active */
> Thanks,
> Claudiu

Sebastian
