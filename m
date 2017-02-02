From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] myri10ge: get rid of custom busy poll code
Date: Thu, 02 Feb 2017 10:50:48 -0800
Message-ID: <1486061448.21871.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33207 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdBBSuz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:50:55 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so2033941pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:50:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Compared to custom busy_poll, the generic NAPI one is simpler and
removes a lot of code. It removes one atomic in the fast path (when
busy poll is not in action) since we do not have to use an extra
spinlock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  197 -------------
 1 file changed, 4 insertions(+), 193 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 3d881176a35392cdac0567f6dbdeb3d6b8835a81..1139d1803e7e483a72e4cc225207e68a5d61924a 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -191,21 +191,6 @@ struct myri10ge_slice_state {
 	int cpu;
 	__be32 __iomem *dca_tag;
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	unsigned int state;
-#define SLICE_STATE_IDLE	0
-#define SLICE_STATE_NAPI	1	/* NAPI owns this slice */
-#define SLICE_STATE_POLL	2	/* poll owns this slice */
-#define SLICE_LOCKED (SLICE_STATE_NAPI | SLICE_STATE_POLL)
-#define SLICE_STATE_NAPI_YIELD	4	/* NAPI yielded this slice */
-#define SLICE_STATE_POLL_YIELD	8	/* poll yielded this slice */
-#define SLICE_USER_PEND (SLICE_STATE_POLL | SLICE_STATE_POLL_YIELD)
-	spinlock_t lock;
-	unsigned long lock_napi_yield;
-	unsigned long lock_poll_yield;
-	unsigned long busy_poll_miss;
-	unsigned long busy_poll_cnt;
-#endif /* CONFIG_NET_RX_BUSY_POLL */
 	char irq_desc[32];
 };
 
@@ -925,92 +910,6 @@ static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 	return status;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline void myri10ge_ss_init_lock(struct myri10ge_slice_state *ss)
-{
-	spin_lock_init(&ss->lock);
-	ss->state = SLICE_STATE_IDLE;
-}
-
-static inline bool myri10ge_ss_lock_napi(struct myri10ge_slice_state *ss)
-{
-	bool rc = true;
-	spin_lock(&ss->lock);
-	if ((ss->state & SLICE_LOCKED)) {
-		WARN_ON((ss->state & SLICE_STATE_NAPI));
-		ss->state |= SLICE_STATE_NAPI_YIELD;
-		rc = false;
-		ss->lock_napi_yield++;
-	} else
-		ss->state = SLICE_STATE_NAPI;
-	spin_unlock(&ss->lock);
-	return rc;
-}
-
-static inline void myri10ge_ss_unlock_napi(struct myri10ge_slice_state *ss)
-{
-	spin_lock(&ss->lock);
-	WARN_ON((ss->state & (SLICE_STATE_POLL | SLICE_STATE_NAPI_YIELD)));
-	ss->state = SLICE_STATE_IDLE;
-	spin_unlock(&ss->lock);
-}
-
-static inline bool myri10ge_ss_lock_poll(struct myri10ge_slice_state *ss)
-{
-	bool rc = true;
-	spin_lock_bh(&ss->lock);
-	if ((ss->state & SLICE_LOCKED)) {
-		ss->state |= SLICE_STATE_POLL_YIELD;
-		rc = false;
-		ss->lock_poll_yield++;
-	} else
-		ss->state |= SLICE_STATE_POLL;
-	spin_unlock_bh(&ss->lock);
-	return rc;
-}
-
-static inline void myri10ge_ss_unlock_poll(struct myri10ge_slice_state *ss)
-{
-	spin_lock_bh(&ss->lock);
-	WARN_ON((ss->state & SLICE_STATE_NAPI));
-	ss->state = SLICE_STATE_IDLE;
-	spin_unlock_bh(&ss->lock);
-}
-
-static inline bool myri10ge_ss_busy_polling(struct myri10ge_slice_state *ss)
-{
-	WARN_ON(!(ss->state & SLICE_LOCKED));
-	return (ss->state & SLICE_USER_PEND);
-}
-#else /* CONFIG_NET_RX_BUSY_POLL */
-static inline void myri10ge_ss_init_lock(struct myri10ge_slice_state *ss)
-{
-}
-
-static inline bool myri10ge_ss_lock_napi(struct myri10ge_slice_state *ss)
-{
-	return false;
-}
-
-static inline void myri10ge_ss_unlock_napi(struct myri10ge_slice_state *ss)
-{
-}
-
-static inline bool myri10ge_ss_lock_poll(struct myri10ge_slice_state *ss)
-{
-	return false;
-}
-
-static inline void myri10ge_ss_unlock_poll(struct myri10ge_slice_state *ss)
-{
-}
-
-static inline bool myri10ge_ss_busy_polling(struct myri10ge_slice_state *ss)
-{
-	return false;
-}
-#endif
-
 static int myri10ge_reset(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_cmd cmd;
@@ -1426,7 +1325,6 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	struct pci_dev *pdev = mgp->pdev;
 	struct net_device *dev = mgp->dev;
 	u8 *va;
-	bool polling;
 
 	if (len <= mgp->small_bytes) {
 		rx = &ss->rx_small;
@@ -1441,15 +1339,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
 	prefetch(va);
 
-	/* When busy polling in user context, allocate skb and copy headers to
-	 * skb's linear memory ourselves.  When not busy polling, use the napi
-	 * gro api.
-	 */
-	polling = myri10ge_ss_busy_polling(ss);
-	if (polling)
-		skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
-	else
-		skb = napi_get_frags(&ss->napi);
+	skb = napi_get_frags(&ss->napi);
 	if (unlikely(skb == NULL)) {
 		ss->stats.rx_dropped++;
 		for (i = 0, remainder = len; remainder > 0; i++) {
@@ -1489,27 +1379,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	myri10ge_vlan_rx(mgp->dev, va, skb);
 	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
 
-	if (polling) {
-		int hlen;
-
-		/* myri10ge_vlan_rx might have moved the header, so compute
-		 * length and address again.
-		 */
-		hlen = MYRI10GE_HLEN > skb->len ? skb->len : MYRI10GE_HLEN;
-		va = page_address(skb_frag_page(&rx_frags[0])) +
-			rx_frags[0].page_offset;
-		/* Copy header into the skb linear memory */
-		skb_copy_to_linear_data(skb, va, hlen);
-		rx_frags[0].page_offset += hlen;
-		rx_frags[0].size -= hlen;
-		skb->data_len -= hlen;
-		skb->tail += hlen;
-		skb->protocol = eth_type_trans(skb, dev);
-		skb_mark_napi_id(skb, &ss->napi);
-		netif_receive_skb(skb);
-	}
-	else
-		napi_gro_frags(&ss->napi);
+	napi_gro_frags(&ss->napi);
 
 	return 1;
 }
@@ -1669,14 +1539,9 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
-	/* Try later if the busy_poll handler is running. */
-	if (!myri10ge_ss_lock_napi(ss))
-		return budget;
-
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
-	myri10ge_ss_unlock_napi(ss);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
 		put_be32(htonl(3), ss->irq_claim);
@@ -1684,34 +1549,6 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int myri10ge_busy_poll(struct napi_struct *napi)
-{
-	struct myri10ge_slice_state *ss =
-	    container_of(napi, struct myri10ge_slice_state, napi);
-	struct myri10ge_priv *mgp = ss->mgp;
-	int work_done;
-
-	/* Poll only when the link is up */
-	if (mgp->link_state != MXGEFW_LINK_UP)
-		return LL_FLUSH_FAILED;
-
-	if (!myri10ge_ss_lock_poll(ss))
-		return LL_FLUSH_BUSY;
-
-	/* Process a small number of packets */
-	work_done = myri10ge_clean_rx_done(ss, 4);
-	if (work_done)
-		ss->busy_poll_cnt += work_done;
-	else
-		ss->busy_poll_miss++;
-
-	myri10ge_ss_unlock_poll(ss);
-
-	return work_done;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 static irqreturn_t myri10ge_intr(int irq, void *arg)
 {
 	struct myri10ge_slice_state *ss = arg;
@@ -1919,10 +1756,6 @@ static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
 	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
 	"rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "tx_linearized",
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	"rx_lock_napi_yield", "rx_lock_poll_yield", "rx_busy_poll_miss",
-	"rx_busy_poll_cnt",
-#endif
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -2022,12 +1855,6 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 		data[i++] = (unsigned int)ss->tx.wake_queue;
 		data[i++] = (unsigned int)ss->tx.stop_queue;
 		data[i++] = (unsigned int)ss->tx.linearized;
-#ifdef CONFIG_NET_RX_BUSY_POLL
-		data[i++] = ss->lock_napi_yield;
-		data[i++] = ss->lock_poll_yield;
-		data[i++] = ss->busy_poll_miss;
-		data[i++] = ss->busy_poll_cnt;
-#endif
 	}
 }
 
@@ -2589,9 +2416,6 @@ static int myri10ge_open(struct net_device *dev)
 			goto abort_with_rings;
 		}
 
-		/* Initialize the slice spinlock and state used for polling */
-		myri10ge_ss_init_lock(ss);
-
 		/* must happen prior to any irq */
 		napi_enable(&(ss)->napi);
 	}
@@ -2668,19 +2492,9 @@ static int myri10ge_close(struct net_device *dev)
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	for (i = 0; i < mgp->num_slices; i++) {
+	for (i = 0; i < mgp->num_slices; i++)
 		napi_disable(&mgp->ss[i].napi);
-		local_bh_disable(); /* myri10ge_ss_lock_napi needs this */
-		/* Lock the slice to prevent the busy_poll handler from
-		 * accessing it.  Later when we bring the NIC up, myri10ge_open
-		 * resets the slice including this lock.
-		 */
-		while (!myri10ge_ss_lock_napi(&mgp->ss[i])) {
-			pr_info("Slice %d locked\n", i);
-			mdelay(1);
-		}
-		local_bh_enable();
-	}
+
 	netif_carrier_off(dev);
 
 	netif_tx_stop_all_queues(dev);
@@ -3953,9 +3767,6 @@ static const struct net_device_ops myri10ge_netdev_ops = {
 	.ndo_change_mtu		= myri10ge_change_mtu,
 	.ndo_set_rx_mode	= myri10ge_set_multicast_list,
 	.ndo_set_mac_address	= myri10ge_set_mac_address,
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= myri10ge_busy_poll,
-#endif
 };
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
