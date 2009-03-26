From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] niu: RX queues should rotate if budget exhausted
Date: Thu, 26 Mar 2009 19:26:20 +0100
Message-ID: <49CBC8CC.1090807@cosmosbay.com>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se> <49CB8DFD.2050504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesper Krogh <jesper@krogh.cc>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60511 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800AbZCZS03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 14:26:29 -0400
In-Reply-To: <49CB8DFD.2050504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I dont have NIU hardware but it seems this driver could suffer from 
starvation of high numbered RX queues under flood. I suspect other
multiqueue drivers might have same problem.

With a standard budget of 64, we can consume all credit when handling
first queue(s), and last queues might discard packets.

Solve this by rotating the starting point, so that we garantee to scan at
least one new queue at each niu_poll_core() invocation, even under stress.

Also, change logic calling niu_sync_rx_discard_stats() to take
into account the device qlen, not bounded by budget (which could be 0)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 50c1112..d62d186 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3726,8 +3726,8 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 	       np->dev->name, rp->rx_channel, (unsigned long long) stat, qlen);
 
 	rcr_done = work_done = 0;
-	qlen = min(qlen, budget);
-	while (work_done < qlen) {
+	budget = min(qlen, budget);
+	while (work_done < budget) {
 		rcr_done += niu_process_rx_pkt(np, rp);
 		work_done++;
 	}
@@ -3759,6 +3759,7 @@ static int niu_poll_core(struct niu *np, struct niu_ldg *lp, int budget)
 	u32 tx_vec = (v0 >> 32);
 	u32 rx_vec = (v0 & 0xffffffff);
 	int i, work_done = 0;
+	unsigned int cur_rx_ring;
 
 	niudbg(INTR, "%s: niu_poll_core() v0[%016llx]\n",
 	       np->dev->name, (unsigned long long) v0);
@@ -3770,17 +3771,24 @@ static int niu_poll_core(struct niu *np, struct niu_ldg *lp, int budget)
 		nw64(LD_IM0(LDN_TXDMA(rp->tx_channel)), 0);
 	}
 
+	cur_rx_ring = np->last_rx_ring;
 	for (i = 0; i < np->num_rx_rings; i++) {
-		struct rx_ring_info *rp = &np->rx_rings[i];
+		struct rx_ring_info *rp;
 
+		if (++cur_rx_ring >= np->num_rx_rings)
+			cur_rx_ring = 0;
+		rp = &np->rx_rings[cur_rx_ring];
 		if (rx_vec & (1 << rp->rx_channel)) {
 			int this_work_done;
 
 			this_work_done = niu_rx_work(np, rp,
 						     budget);
-
-			budget -= this_work_done;
-			work_done += this_work_done;
+			if (this_work_done) {
+				budget -= this_work_done;
+				work_done += this_work_done;
+				if (budget <= 0)
+					np->last_rx_ring = cur_rx_ring;
+			}
 		}
 		nw64(LD_IM0(LDN_RXDMA(rp->rx_channel)), 0);
 	}
@@ -4497,6 +4505,7 @@ static int niu_alloc_channels(struct niu *np)
 	}
 
 	np->num_rx_rings = parent->rxchan_per_port[port];
+	np->last_rx_ring = 0;
 	np->num_tx_rings = parent->txchan_per_port[port];
 
 	np->dev->real_num_tx_queues = np->num_tx_rings;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 8754e44..113fe1d 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3266,6 +3266,7 @@ struct niu {
 	struct tx_ring_info		*tx_rings;
 	int				num_rx_rings;
 	int				num_tx_rings;
+	int				last_rx_ring;
 
 	struct niu_ldg			ldg[NIU_NUM_LDG];
 	int				num_ldg;
