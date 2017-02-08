From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v2 7/8] bnxt: Changes to use generic XDP infrastructure
Date: Wed, 8 Feb 2017 15:41:26 -0800
Message-ID: <20170208234127.3041579-8-tom@herbertland.com>
References: <20170208234127.3041579-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55491 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751812AbdBIBQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:16:52 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18NXZk0025163
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 15:41:51 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28g59k2082-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:41:51 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 2982c370ee5811e6a8b624be05956610-1fad0a50 for <netdev@vger.kernel.org>;        Wed,
 08 Feb 2017 15:41:50 -0800
In-Reply-To: <20170208234127.3041579-1-tom@herbertland.com>
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
index cda1c78..ce311fb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2091,9 +2091,6 @@ static void bnxt_free_rx_rings(struct bnxt *bp)
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring;
 
-		if (rxr->xdp_prog)
-			bpf_prog_put(rxr->xdp_prog);
-
 		kfree(rxr->rx_tpa);
 		rxr->rx_tpa = NULL;
 
@@ -2381,15 +2378,6 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
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
@@ -7157,8 +7145,6 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, bp->bar0);
 	kfree(bp->edev);
 	bp->edev = NULL;
-	if (bp->xdp_prog)
-		bpf_prog_put(bp->xdp_prog);
 	free_netdev(dev);
 
 	pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 9f07b9c..3efe7af 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1175,7 +1175,7 @@ struct bnxt {
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
