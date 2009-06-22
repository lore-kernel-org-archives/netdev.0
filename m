From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
 queueing an extra skb.
Date: Mon, 22 Jun 2009 11:25:29 -0700
Message-ID: <20090622182529.GA4990@xw6200.broadcom.net>
References: <200905292346.04815.rusty@rustcorp.com.au>
 <200906181647.51045.rusty@rustcorp.com.au>
 <20090618073422.GA4087@gondor.apana.org.au>
 <200906191307.20360.rusty@rustcorp.com.au>
 <20090619043613.GA15163@gondor.apana.org.au>
 <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com>
 <20090622073417.GA21698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Krishna Kumar2" <krkumar2@in.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4018 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702AbZFVSZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 14:25:45 -0400
In-Reply-To: <20090622073417.GA21698@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 12:34:17AM -0700, Herbert Xu wrote:
> On Mon, Jun 22, 2009 at 11:16:03AM +0530, Krishna Kumar2 wrote:
> >
> > I was curious about "queueing it in the driver" part: why is this bad? Do
> > you
> > anticipate any performance problems, or does it break QoS, or something
> > else I
> > have missed?
> 
> Queueing it in the driver is bad because it is no different than
> queueing it at the upper layer, which is what will happen when
> you return TX_BUSY.
> 
> Because we've ripped out the qdisc requeueing logic (which is
> horribly complex and only existed because of TX_BUSY), it means
> that higher priority packets cannot preempt a packet that is queued
> in this way.

As was said elsewhere, from the driver writer's perspective every packet
that has already been submitted (queued) to the hardware cannot be
preempted.  Slightly extending that logic doesn't seem like that much of
a problem, especially if it saves the troublesome requeuing logic higher up.

Below is a very rough, untested patch that implements what I am
thinking.  The patch only allows one tx packet to be stored, so it
shouldn't impact any QoS strategy that much.  It can even be extended to
eliminate the rest of the NETDEV_TX_BUSY return values, if that is the
direction everyone wants to go.

Do you agree this is a better approach to turning off TSO completely?


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 46a3f86..f061c04 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4223,6 +4223,8 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
 		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
 }
 
+static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
+
 /* Tigon3 never reports partial packet sends.  So we do not
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
@@ -4272,7 +4274,13 @@ static void tg3_tx(struct tg3 *tp)
 	 */
 	smp_mb();
 
-	if (unlikely(netif_queue_stopped(tp->dev) &&
+	if (tp->tx_skb) {
+		struct sk_buff *skb = tp->tx_skb;
+		tp->tx_skb = NULL;
+		tg3_start_xmit_dma_bug(skb, tp->dev);
+	}
+
+	if (!tp->tx_skb && unlikely(netif_queue_stopped(tp->dev) &&
 		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
@@ -5211,8 +5219,10 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 	/* Estimate the number of fragments in the worst case */
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
-		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
-			return NETDEV_TX_BUSY;
+		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3)) {
+			tp->tx_skb = skb;
+			return NETDEV_TX_OK;
+		}
 
 		netif_wake_queue(tp->dev);
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b3347c4..ed1d6ff 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2515,6 +2515,7 @@ struct tg3 {
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
+	struct sk_buff			*tx_skb;
 
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tx_ring_info		*tx_buffers;

