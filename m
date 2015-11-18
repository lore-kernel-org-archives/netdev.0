From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 08/14] bnx2x: remove bnx2x_low_latency_recv() support
Date: Wed, 18 Nov 2015 06:30:57 -0800
Message-ID: <1447857063-618-9-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36522 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbKRObh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:37 -0500
Received: by pacdm15 with SMTP id dm15so46627480pac.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:37 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to native NAPI polling, as this reduces overhead and complexity.

Normal path is faster, since one cmpxchg() is not anymore requested,
and busy polling with the NAPI polling has same performance.

Tested:
lpk50:~# cat /proc/sys/net/core/busy_read
70
lpk50:~# nstat >/dev/null;./netperf -H lpk55 -t TCP_RR;nstat
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpk55.prod.google.com () port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    40095.07
16384  87380
IpInReceives                    401062             0.0
IpInDelivers                    401062             0.0
IpOutRequests                   401079             0.0
TcpActiveOpens                  7                  0.0
TcpPassiveOpens                 3                  0.0
TcpAttemptFails                 3                  0.0
TcpEstabResets                  5                  0.0
TcpInSegs                       401036             0.0
TcpOutSegs                      401052             0.0
TcpOutRsts                      38                 0.0
UdpInDatagrams                  26                 0.0
UdpOutDatagrams                 27                 0.0
Ip6OutNoRoutes                  1                  0.0
TcpExtDelayedACKs               1                  0.0
TcpExtTCPPrequeued              98                 0.0
TcpExtTCPDirectCopyFromPrequeue 98                 0.0
TcpExtTCPHPHits                 4                  0.0
TcpExtTCPHPHitsToUser           98                 0.0
TcpExtTCPPureAcks               5                  0.0
TcpExtTCPHPAcks                 101                0.0
TcpExtTCPAbortOnData            6                  0.0
TcpExtBusyPollRxPackets         400832             0.0
TcpExtTCPOrigDataSent           400983             0.0
IpExtInOctets                   21273867           0.0
IpExtOutOctets                  21261254           0.0
IpExtInNoECTPkts                401064             0.0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 113 -----------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  46 +--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   7 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   3 -
 4 files changed, 2 insertions(+), 167 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index b5e64b02200c..0b214b5d944a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -540,10 +540,6 @@ struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	unsigned long		busy_poll_state;
-#endif
-
 	union host_hc_status_block	status_blk;
 	/* chip independent shortcuts into sb structure */
 	__le16			*sb_index_values;
@@ -617,115 +613,6 @@ struct bnx2x_fastpath {
 #define bnx2x_fp_stats(bp, fp)	(&((bp)->fp_stats[(fp)->index]))
 #define bnx2x_fp_qstats(bp, fp)	(&((bp)->fp_stats[(fp)->index].eth_q_stats))
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-
-enum bnx2x_fp_state {
-	BNX2X_STATE_FP_NAPI	= BIT(0), /* NAPI handler owns the queue */
-
-	BNX2X_STATE_FP_NAPI_REQ_BIT = 1, /* NAPI would like to own the queue */
-	BNX2X_STATE_FP_NAPI_REQ = BIT(1),
-
-	BNX2X_STATE_FP_POLL_BIT = 2,
-	BNX2X_STATE_FP_POLL     = BIT(2), /* busy_poll owns the queue */
-
-	BNX2X_STATE_FP_DISABLE_BIT = 3, /* queue is dismantled */
-};
-
-static inline void bnx2x_fp_busy_poll_init(struct bnx2x_fastpath *fp)
-{
-	WRITE_ONCE(fp->busy_poll_state, 0);
-}
-
-/* called from the device poll routine to get ownership of a FP */
-static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
-{
-	unsigned long prev, old = READ_ONCE(fp->busy_poll_state);
-
-	while (1) {
-		switch (old) {
-		case BNX2X_STATE_FP_POLL:
-			/* make sure bnx2x_fp_lock_poll() wont starve us */
-			set_bit(BNX2X_STATE_FP_NAPI_REQ_BIT,
-				&fp->busy_poll_state);
-			/* fallthrough */
-		case BNX2X_STATE_FP_POLL | BNX2X_STATE_FP_NAPI_REQ:
-			return false;
-		default:
-			break;
-		}
-		prev = cmpxchg(&fp->busy_poll_state, old, BNX2X_STATE_FP_NAPI);
-		if (unlikely(prev != old)) {
-			old = prev;
-			continue;
-		}
-		return true;
-	}
-}
-
-static inline void bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
-{
-	smp_wmb();
-	fp->busy_poll_state = 0;
-}
-
-/* called from bnx2x_low_latency_poll() */
-static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
-{
-	return cmpxchg(&fp->busy_poll_state, 0, BNX2X_STATE_FP_POLL) == 0;
-}
-
-static inline void bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
-{
-	smp_mb__before_atomic();
-	clear_bit(BNX2X_STATE_FP_POLL_BIT, &fp->busy_poll_state);
-}
-
-/* true if a socket is polling */
-static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
-{
-	return READ_ONCE(fp->busy_poll_state) & BNX2X_STATE_FP_POLL;
-}
-
-/* false if fp is currently owned */
-static inline bool bnx2x_fp_ll_disable(struct bnx2x_fastpath *fp)
-{
-	set_bit(BNX2X_STATE_FP_DISABLE_BIT, &fp->busy_poll_state);
-	return !bnx2x_fp_ll_polling(fp);
-
-}
-#else
-static inline void bnx2x_fp_busy_poll_init(struct bnx2x_fastpath *fp)
-{
-}
-
-static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
-{
-	return true;
-}
-
-static inline void bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
-{
-}
-
-static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
-{
-	return false;
-}
-
-static inline void bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
-{
-}
-
-static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
-{
-	return false;
-}
-static inline bool bnx2x_fp_ll_disable(struct bnx2x_fastpath *fp)
-{
-	return true;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 /* Use 2500 as a mini-jumbo MTU for FCoE */
 #define BNX2X_FCOE_MINI_JUMBO_MTU	2500
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f8d7a2f06950..ca208a7eecd5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1096,10 +1096,7 @@ reuse_rx:
 
 		skb_mark_napi_id(skb, &fp->napi);
 
-		if (bnx2x_fp_ll_polling(fp))
-			netif_receive_skb(skb);
-		else
-			napi_gro_receive(&fp->napi, skb);
+		napi_gro_receive(&fp->napi, skb);
 next_rx:
 		rx_buf->data = NULL;
 
@@ -1869,7 +1866,6 @@ static void bnx2x_napi_enable_cnic(struct bnx2x *bp)
 	int i;
 
 	for_each_rx_queue_cnic(bp, i) {
-		bnx2x_fp_busy_poll_init(&bp->fp[i]);
 		napi_enable(&bnx2x_fp(bp, i, napi));
 	}
 }
@@ -1879,7 +1875,6 @@ static void bnx2x_napi_enable(struct bnx2x *bp)
 	int i;
 
 	for_each_eth_queue(bp, i) {
-		bnx2x_fp_busy_poll_init(&bp->fp[i]);
 		napi_enable(&bnx2x_fp(bp, i, napi));
 	}
 }
@@ -1890,8 +1885,6 @@ static void bnx2x_napi_disable_cnic(struct bnx2x *bp)
 
 	for_each_rx_queue_cnic(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
-		while (!bnx2x_fp_ll_disable(&bp->fp[i]))
-			usleep_range(1000, 2000);
 	}
 }
 
@@ -1901,8 +1894,6 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 
 	for_each_eth_queue(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
-		while (!bnx2x_fp_ll_disable(&bp->fp[i]))
-			usleep_range(1000, 2000);
 	}
 }
 
@@ -3232,9 +3223,6 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			return 0;
 		}
 #endif
-		if (!bnx2x_fp_lock_napi(fp))
-			return budget;
-
 		for_each_cos_in_tx_queue(fp, cos)
 			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
 				bnx2x_tx_int(bp, fp->txdata_ptr[cos]);
@@ -3243,14 +3231,10 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			work_done += bnx2x_rx_int(fp, budget - work_done);
 
 			/* must not complete if we consumed full budget */
-			if (work_done >= budget) {
-				bnx2x_fp_unlock_napi(fp);
+			if (work_done >= budget)
 				break;
-			}
 		}
 
-		bnx2x_fp_unlock_napi(fp);
-
 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 
@@ -3294,32 +3278,6 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-/* must be called with local_bh_disable()d */
-int bnx2x_low_latency_recv(struct napi_struct *napi)
-{
-	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
-						 napi);
-	struct bnx2x *bp = fp->bp;
-	int found = 0;
-
-	if ((bp->state == BNX2X_STATE_CLOSED) ||
-	    (bp->state == BNX2X_STATE_ERROR) ||
-	    (bp->dev->features & (NETIF_F_LRO | NETIF_F_GRO)))
-		return LL_FLUSH_FAILED;
-
-	if (!bnx2x_fp_lock_poll(fp))
-		return LL_FLUSH_BUSY;
-
-	if (bnx2x_has_rx_work(fp))
-		found = bnx2x_rx_int(fp, 4);
-
-	bnx2x_fp_unlock_poll(fp);
-
-	return found;
-}
-#endif
-
 /* we split the first BD into headers and data BDs
  * to ease the pain of our fellow microcode engineers
  * we use one mapping for both BDs
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index b7d32e8412f1..4cbb03f87b5a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -570,13 +570,6 @@ int bnx2x_enable_msix(struct bnx2x *bp);
 int bnx2x_enable_msi(struct bnx2x *bp);
 
 /**
- * bnx2x_low_latency_recv - LL callback
- *
- * @napi:	napi structure
- */
-int bnx2x_low_latency_recv(struct napi_struct *napi);
-
-/**
  * bnx2x_alloc_mem_bp - allocate memories outsize main driver structure
  *
  * @bp:		driver handle
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c9b036789184..2273576404b4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13004,9 +13004,6 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_fcoe_get_wwn	= bnx2x_fcoe_get_wwn,
 #endif
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= bnx2x_low_latency_recv,
-#endif
 	.ndo_get_phys_port_id	= bnx2x_get_phys_port_id,
 	.ndo_set_vf_link_state	= bnx2x_set_vf_link_state,
 	.ndo_features_check	= bnx2x_features_check,
-- 
2.6.0.rc2.230.g3dd15c0
