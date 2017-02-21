From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 7/8] bnxt: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:16 -0800
Message-ID: <20170221193417.3641224-8-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40151 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754141AbdBUTec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:32 -0500
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJT4Ab016664
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:31 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rk81hkmr-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:31 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 c306adccf86c11e6850a0002c9931860-23fdca00 for <netdev@vger.kernel.org>;        Tue,
 21 Feb 2017 11:34:29 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 14 --------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 46 +++++++++++++++------------
 3 files changed, 27 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6dacdf1..d8b9733 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2098,9 +2098,6 @@ static void bnxt_free_rx_rings(struct bnxt *bp)
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (rxr->xdp_prog)
-			bpf_prog_put(rxr->xdp_prog);
-
 		kfree(rxr->rx_tpa);
 		rxr->rx_tpa = NULL;
 
@@ -2388,15 +2385,6 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 	ring = &rxr->rx_ring_struct;
 	bnxt_init_rxbd_pages(ring, type);
 
-	if (BNXT_RX_PAGE_MODE(bp) && bp->xdp_prog) {
-		rxr->xdp_prog = bpf_prog_add(bp->xdp_prog, 1);
-		if (IS_ERR(rxr->xdp_prog)) {
-			int rc = PTR_ERR(rxr->xdp_prog);
-
-			rxr->xdp_prog = NULL;
-			return rc;
-		}
-	}
 	prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
 		if (bnxt_alloc_rx_data(bp, rxr, prod, GFP_KERNEL) != 0) {
@@ -7198,8 +7186,6 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	bnxt_dcb_free(bp);
 	kfree(bp->edev);
 	bp->edev = NULL;
-	if (bp->xdp_prog)
-		bpf_prog_put(bp->xdp_prog);
 	bnxt_cleanup_pci(bp);
 	free_netdev(dev);
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index faf26a2..61bb375 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1180,7 +1180,7 @@ struct bnxt {
 	u8			num_leds;
 	struct bnxt_led_info	leds[BNXT_MAX_LED];
 
-	struct bpf_prog		*xdp_prog;
+	bool			xdp_enabled;
 };
 
 #define BNXT_RX_STATS_OFFSET(counter)			\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 899c30f..3cfdc94 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -85,18 +85,18 @@ void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, u8 **data_ptr, unsigned int *len, u8 *event)
 {
-	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);
 	struct bnxt_tx_ring_info *txr;
 	struct bnxt_sw_rx_bd *rx_buf;
 	struct pci_dev *pdev;
 	struct xdp_buff xdp;
+	struct xdp_hook *last_hook;
 	dma_addr_t mapping;
 	void *orig_data;
 	u32 tx_avail;
 	u32 offset;
 	u32 act;
 
-	if (!xdp_prog)
+	if (!xdp_hook_run_needed_check(bp->dev, &rxr->bnapi->napi))
 		return false;
 
 	pdev = bp->pdev;
@@ -113,7 +113,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 	dma_sync_single_for_cpu(&pdev->dev, mapping + offset, *len, bp->rx_dir);
 
 	rcu_read_lock();
-	act = bpf_prog_run_xdp(xdp_prog, &xdp);
+	act = xdp_hook_run_ret_last(&rxr->bnapi->napi, &xdp, &last_hook);
 	rcu_read_unlock();
 
 	tx_avail = bnxt_tx_avail(bp, txr);
@@ -134,7 +134,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 
 	case XDP_TX:
 		if (tx_avail < 2) {
-			trace_xdp_exception(bp->dev, xdp_prog, act);
+			trace_xdp_hook_exception(bp->dev, last_hook, act);
 			bnxt_reuse_rx_data(rxr, cons, page);
 			return true;
 		}
@@ -147,10 +147,10 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		bnxt_reuse_rx_data(rxr, cons, page);
 		return true;
 	default:
-		bpf_warn_invalid_xdp_action(act);
+		xdp_warn_invalid_action(act);
 		/* Fall thru */
 	case XDP_ABORTED:
-		trace_xdp_exception(bp->dev, xdp_prog, act);
+		trace_xdp_hook_exception(bp->dev, last_hook, act);
 		/* Fall thru */
 	case XDP_DROP:
 		bnxt_reuse_rx_data(rxr, cons, page);
@@ -160,13 +160,15 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 }
 
 /* Under rtnl_lock */
-static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
+static int bnxt_xdp_init(struct bnxt *bp, bool enable)
 {
 	struct net_device *dev = bp->dev;
 	int tx_xdp = 0, rc, tc;
-	struct bpf_prog *old;
 
-	if (prog && bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU) {
+	if (bp->xdp_enabled == enable)
+		return 0;
+
+	if (enable && bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU) {
 		netdev_warn(dev, "MTU %d larger than largest XDP supported MTU %d.\n",
 			    bp->dev->mtu, BNXT_MAX_PAGE_MODE_MTU);
 		return -EOPNOTSUPP;
@@ -175,7 +177,7 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 		netdev_warn(dev, "ethtool rx/tx channels must be combined to support XDP.\n");
 		return -EOPNOTSUPP;
 	}
-	if (prog)
+	if (enable)
 		tx_xdp = bp->rx_nr_rings;
 
 	tc = netdev_get_num_tc(dev);
@@ -190,11 +192,7 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	if (netif_running(dev))
 		bnxt_close_nic(bp, true, false);
 
-	old = xchg(&bp->xdp_prog, prog);
-	if (old)
-		bpf_prog_put(old);
-
-	if (prog) {
+	if (enable) {
 		bnxt_set_rx_skb_mode(bp, true);
 	} else {
 		int rx, tx;
@@ -210,6 +208,7 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tc + tx_xdp;
 	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
 	bp->num_stat_ctxs = bp->cp_nr_rings;
+	bp->xdp_enabled = enable;
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 
@@ -219,18 +218,25 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	return 0;
 }
 
+static int bnxt_xdp_check_bpf(struct net_device *dev, struct bpf_prog *prog)
+{
+	return 0;
+}
+
 int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	int rc;
 
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		rc = bnxt_xdp_set(bp, xdp->prog);
+	case XDP_MODE_ON:
+		rc = bnxt_xdp_init(bp, true);
+		break;
+	case XDP_MODE_OFF:
+		rc = bnxt_xdp_init(bp, false);
 		break;
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!bp->xdp_prog;
-		rc = 0;
+	case XDP_CHECK_BPF_PROG:
+		rc = bnxt_xdp_check_bpf(dev, xdp->prog);
 		break;
 	default:
 		rc = -EINVAL;
-- 
2.9.3
