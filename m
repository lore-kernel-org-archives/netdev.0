From: Hyong-Youb Kim <hykim@myri.com>
Subject: [PATCH net-next] myri10ge: Add support for ndo_busy_poll
Date: Mon, 19 Aug 2013 02:02:19 -0700
Message-ID: <1376902939-21968-1-git-send-email-hykim@myri.com>
Cc: netdev@vger.kernel.org, Hyong-Youb Kim <hykim@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-43-81-194.west.biz.rr.com ([24.43.81.194]:1157 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750911Ab3HSJDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 05:03:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ndo_busy_poll handler. Use skb_mark_napi_id to mark receive
packets with the napi id. For each slice, use per-slice spinlock and
state variable to ensure that only one handler processes receive
pacekts.

Locking, statistics counters, and the ndo_busy_poll handler follow
those in the ixgbe driver. So, credit goes to that driver's authors.

Signed-off-by: Hyong-Youb Kim <hykim@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  200 +++++++++++++++++++++-
 1 files changed, 198 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 66c0400..3bb14e7 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -74,6 +74,7 @@
 #ifdef CONFIG_MTRR
 #include <asm/mtrr.h>
 #endif
+#include <net/busy_poll.h>
 
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
@@ -194,6 +195,21 @@ struct myri10ge_slice_state {
 	int cpu;
 	__be32 __iomem *dca_tag;
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned int state;
+#define SLICE_STATE_IDLE	0
+#define SLICE_STATE_NAPI	1	/* NAPI owns this slice */
+#define SLICE_STATE_POLL	2	/* poll owns this slice */
+#define SLICE_LOCKED (SLICE_STATE_NAPI | SLICE_STATE_POLL)
+#define SLICE_STATE_NAPI_YIELD	4	/* NAPI yielded this slice */
+#define SLICE_STATE_POLL_YIELD	8	/* poll yielded this slice */
+#define SLICE_USER_PEND (SLICE_STATE_POLL | SLICE_STATE_POLL_YIELD)
+	spinlock_t lock;
+	unsigned long lock_napi_yield;
+	unsigned long lock_poll_yield;
+	unsigned long busy_poll_miss;
+	unsigned long busy_poll_cnt;
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 	char irq_desc[32];
 };
 
@@ -909,6 +925,92 @@ abort:
 	return status;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static inline void myri10ge_ss_init_lock(struct myri10ge_slice_state *ss)
+{
+	spin_lock_init(&ss->lock);
+	ss->state = SLICE_STATE_IDLE;
+}
+
+static inline bool myri10ge_ss_lock_napi(struct myri10ge_slice_state *ss)
+{
+	int rc = true;
+	spin_lock(&ss->lock);
+	if ((ss->state & SLICE_LOCKED)) {
+		WARN_ON((ss->state & SLICE_STATE_NAPI));
+		ss->state |= SLICE_STATE_NAPI_YIELD;
+		rc = false;
+		ss->lock_napi_yield++;
+	} else
+		ss->state = SLICE_STATE_NAPI;
+	spin_unlock(&ss->lock);
+	return rc;
+}
+
+static inline void myri10ge_ss_unlock_napi(struct myri10ge_slice_state *ss)
+{
+	spin_lock(&ss->lock);
+	WARN_ON((ss->state & (SLICE_STATE_POLL | SLICE_STATE_NAPI_YIELD)));
+	ss->state = SLICE_STATE_IDLE;
+	spin_unlock(&ss->lock);
+}
+
+static inline bool myri10ge_ss_lock_poll(struct myri10ge_slice_state *ss)
+{
+	int rc = true;
+	spin_lock_bh(&ss->lock);
+	if ((ss->state & SLICE_LOCKED)) {
+		ss->state |= SLICE_STATE_POLL_YIELD;
+		rc = false;
+		ss->lock_poll_yield++;
+	} else
+		ss->state |= SLICE_STATE_POLL;
+	spin_unlock_bh(&ss->lock);
+	return rc;
+}
+
+static inline void myri10ge_ss_unlock_poll(struct myri10ge_slice_state *ss)
+{
+	spin_lock_bh(&ss->lock);
+	WARN_ON((ss->state & SLICE_STATE_NAPI));
+	ss->state = SLICE_STATE_IDLE;
+	spin_unlock_bh(&ss->lock);
+}
+
+static inline bool myri10ge_ss_busy_polling(struct myri10ge_slice_state *ss)
+{
+	WARN_ON(!(ss->state & SLICE_LOCKED));
+	return (ss->state & SLICE_USER_PEND);
+}
+#else /* CONFIG_NET_RX_BUSY_POLL */
+static inline void myri10ge_ss_init_lock(struct myri10ge_slice_state *ss)
+{
+}
+
+static inline bool myri10ge_ss_lock_napi(struct myri10ge_slice_state *ss)
+{
+	return false;
+}
+
+static inline void myri10ge_ss_unlock_napi(struct myri10ge_slice_state *ss)
+{
+}
+
+static inline bool myri10ge_ss_lock_poll(struct myri10ge_slice_state *ss)
+{
+	return false;
+}
+
+static inline void myri10ge_ss_unlock_poll(struct myri10ge_slice_state *ss)
+{
+}
+
+static inline bool myri10ge_ss_busy_polling(struct myri10ge_slice_state *ss)
+{
+	return false;
+}
+#endif
+
 static int myri10ge_reset(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_cmd cmd;
@@ -1300,6 +1402,8 @@ myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
 	}
 }
 
+#define MYRI10GE_HLEN 64 /* Bytes to copy from page to skb linear memory */
+
 static inline int
 myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 {
@@ -1311,6 +1415,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	struct pci_dev *pdev = mgp->pdev;
 	struct net_device *dev = mgp->dev;
 	u8 *va;
+	bool polling;
 
 	if (len <= mgp->small_bytes) {
 		rx = &ss->rx_small;
@@ -1325,7 +1430,15 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
 	prefetch(va);
 
-	skb = napi_get_frags(&ss->napi);
+	/* When busy polling in user context, allocate skb and copy headers to
+	 * skb's linear memory ourselves.  When not busy polling, use the napi
+	 * gro api.
+	 */
+	polling = myri10ge_ss_busy_polling(ss);
+	if (polling)
+		skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
+	else
+		skb = napi_get_frags(&ss->napi);
 	if (unlikely(skb == NULL)) {
 		ss->stats.rx_dropped++;
 		for (i = 0, remainder = len; remainder > 0; i++) {
@@ -1364,8 +1477,29 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	}
 	myri10ge_vlan_rx(mgp->dev, va, skb);
 	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
+	skb_mark_napi_id(skb, &ss->napi);
 
-	napi_gro_frags(&ss->napi);
+	if (polling) {
+		int hlen;
+		
+		/* myri10ge_vlan_rx might have moved the header, so compute
+		 * length and address again.
+		 */
+		hlen = MYRI10GE_HLEN > skb->len ? skb->len : MYRI10GE_HLEN;
+		va = page_address(skb_frag_page(&rx_frags[0])) +
+			rx_frags[0].page_offset;
+		/* Copy header into the skb linear memory */
+		skb_copy_to_linear_data(skb, va, hlen);
+		rx_frags[0].page_offset += hlen;
+		rx_frags[0].size -= hlen;
+		skb->data_len -= hlen;
+		skb->tail += hlen;
+		skb->protocol = eth_type_trans(skb, dev);
+		netif_receive_skb(skb);
+	}
+	else
+		napi_gro_frags(&ss->napi);
+	
 	return 1;
 }
 
@@ -1524,10 +1658,14 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
+	/* Try later if the busy_poll handler is running. */
+	if (!myri10ge_ss_lock_napi(ss))
+		return budget;
 
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
+	myri10ge_ss_unlock_napi(ss);
 	if (work_done < budget) {
 		napi_complete(napi);
 		put_be32(htonl(3), ss->irq_claim);
@@ -1535,6 +1673,34 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static int myri10ge_busy_poll(struct napi_struct *napi)
+{
+	struct myri10ge_slice_state *ss =
+	    container_of(napi, struct myri10ge_slice_state, napi);
+	struct myri10ge_priv *mgp = ss->mgp;
+	int work_done;
+
+	/* Poll only when the link is up */
+	if (mgp->link_state != MXGEFW_LINK_UP)
+		return LL_FLUSH_FAILED;
+
+	if (!myri10ge_ss_lock_poll(ss))
+		return LL_FLUSH_BUSY;
+
+	/* Process a small number of packets */
+	work_done = myri10ge_clean_rx_done(ss, 4);
+	if (work_done)
+		ss->busy_poll_cnt += work_done;
+	else
+		ss->busy_poll_miss++;
+	
+	myri10ge_ss_unlock_poll(ss);
+
+	return work_done;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 static irqreturn_t myri10ge_intr(int irq, void *arg)
 {
 	struct myri10ge_slice_state *ss = arg;
@@ -1742,6 +1908,10 @@ static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
 	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
 	"rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "tx_linearized",
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	"rx_lock_napi_yield", "rx_lock_poll_yield", "rx_busy_poll_miss",
+	"rx_busy_poll_cnt",
+#endif
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -1842,6 +2012,12 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 		data[i++] = (unsigned int)ss->tx.wake_queue;
 		data[i++] = (unsigned int)ss->tx.stop_queue;
 		data[i++] = (unsigned int)ss->tx.linearized;
+#ifdef CONFIG_NET_RX_BUSY_POLL
+		data[i++] = ss->lock_napi_yield;
+		data[i++] = ss->lock_poll_yield;
+		data[i++] = ss->busy_poll_miss;
+		data[i++] = ss->busy_poll_cnt;
+#endif
 	}
 }
 
@@ -2405,6 +2581,9 @@ static int myri10ge_open(struct net_device *dev)
 			goto abort_with_rings;
 		}
 
+		/* Initialize the slice spinlock and state used for polling */
+		myri10ge_ss_init_lock(ss);
+		
 		/* must happen prior to any irq */
 		napi_enable(&(ss)->napi);
 	}
@@ -2481,9 +2660,19 @@ static int myri10ge_close(struct net_device *dev)
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
+	local_bh_disable(); /* myri10ge_ss_lock_napi needs bh disabled */
 	for (i = 0; i < mgp->num_slices; i++) {
 		napi_disable(&mgp->ss[i].napi);
+		/* Lock the slice to prevent the busy_poll handler from
+		 * accessing it.  Later when we bring the NIC up, myri10ge_open
+		 * resets the slice including this lock.
+		 */
+		while (!myri10ge_ss_lock_napi(&mgp->ss[i])) {
+			pr_info("Slice %d locked\n", i);
+			mdelay(1);
+		}
 	}
+	local_bh_enable();
 	netif_carrier_off(dev);
 
 	netif_tx_stop_all_queues(dev);
@@ -3569,8 +3758,11 @@ static void myri10ge_free_slices(struct myri10ge_priv *mgp)
 					  ss->fw_stats, ss->fw_stats_bus);
 			ss->fw_stats = NULL;
 		}
+		napi_hash_del(&ss->napi);
 		netif_napi_del(&ss->napi);
 	}
+	/* Wait till napi structs are no longer used, and then free ss. */
+	synchronize_rcu();
 	kfree(mgp->ss);
 	mgp->ss = NULL;
 }
@@ -3606,6 +3798,7 @@ static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
 		ss->dev = mgp->dev;
 		netif_napi_add(ss->dev, &ss->napi, myri10ge_poll,
 			       myri10ge_napi_weight);
+		napi_hash_add(&ss->napi);
 	}
 	return 0;
 abort:
@@ -3748,6 +3941,9 @@ static const struct net_device_ops myri10ge_netdev_ops = {
 	.ndo_change_mtu		= myri10ge_change_mtu,
 	.ndo_set_rx_mode	= myri10ge_set_multicast_list,
 	.ndo_set_mac_address	= myri10ge_set_mac_address,
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= myri10ge_busy_poll,
+#endif
 };
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
-- 
1.7.1
