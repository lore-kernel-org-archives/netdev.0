From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] acenic - don't spin in hard_start_xmit when ring fills
Date: Thu, 16 Sep 2004 16:17:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Running performance tests on the acenic, I noticed that the driver
spins when the transmit ring gets full.  This might have been okay when
CPU's were slower, but it isn't the right thing to do. Better to
return TX_BUSY and let network scheduling handle it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-09-16 16:17:09 -07:00
+++ b/drivers/net/acenic.c	2004-09-16 16:17:09 -07:00
@@ -2517,11 +2517,10 @@
 	struct tx_desc *desc;
 	u32 idx, flagsize;
 
-restart:
 	idx = ap->tx_prd;
 
 	if (tx_ring_full(ap, ap->tx_ret_csm, idx))
-		goto overflow;
+		return NETDEV_TX_BUSY;
 
 #if MAX_SKB_FRAGS
 	if (!skb_shinfo(skb)->nr_frags)
@@ -2625,27 +2624,7 @@
 	}
 
 	dev->trans_start = jiffies;
-	return 0;
-
-overflow:
-	/*
-	 * This race condition is unavoidable with lock-free drivers.
-	 * We wake up the queue _before_ tx_prd is advanced, so that we can
-	 * enter hard_start_xmit too early, while tx ring still looks closed.
-	 * This happens ~1-4 times per 100000 packets, so that we can allow
-	 * to loop syncing to other CPU. Probably, we need an additional
-	 * wmb() in ace_tx_intr as well.
-	 *
-	 * Note that this race is relieved by reserving one more entry
-	 * in tx ring than it is necessary (see original non-SG driver).
-	 * However, with SG we need to reserve 2*MAX_SKB_FRAGS+1, which
-	 * is already overkill.
-	 *
-	 * Alternative is to return with 1 not throttling queue. In this
-	 * case loop becomes longer, no more useful effects.
-	 */
-	barrier();
-	goto restart;
+	return NETDEV_TX_OK;
 }
 
 
