From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [PATCH 3/3] i40e: Don't reset/rebuild rings on XDP program swap
Date: Thu,  8 Dec 2016 18:00:22 +0100
Message-ID: <20161208170022.11555-4-bjorn.topel@gmail.com>
References: <20161208170022.11555-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        john.r.fastabend@intel.com, magnus.karlsson@intel.com,
        netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65487 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932580AbcLHRBe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 12:01:34 -0500
In-Reply-To: <20161208170022.11555-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

Previously, when swapping from one XDP program to another, a
reset/rebuild rings was triggered. Now, the XDP program is simply
changed without that requirement.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c | 41 ++++++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 25 +++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |  2 +-
 4 files changed, 44 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index adc1f3f32729..9bc2a8cf5c2e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -549,7 +549,7 @@ struct i40e_vsi {
 	 * regular rings, i.e. alloc_queue_pairs/num_queue_pairs
 	 */
 	struct i40e_ring **xdp_rings;
-	struct bpf_prog *xdp_prog;
+	bool xdp_enabled;
 
 	u32  active_filters;
 	u32  promisc_threshold;
@@ -920,6 +920,6 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup);
  **/
 static inline bool i40e_enabled_xdp_vsi(const struct i40e_vsi *vsi)
 {
-	return vsi->xdp_prog;
+	return vsi->xdp_enabled;
 }
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9310a5712ae3..7cac13d1c244 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3116,15 +3116,6 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	ring->tail = hw->hw_addr + I40E_QRX_TAIL(pf_q);
 	writel(0, ring->tail);
 
-	if (i40e_enabled_xdp_vsi(vsi)) {
-		struct bpf_prog *prog;
-
-		prog = bpf_prog_add(vsi->xdp_prog, 1);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-		ring->xdp_prog = prog;
-	}
-
 	i40e_alloc_rx_buffers(ring, I40E_DESC_UNUSED(ring));
 
 	return 0;
@@ -9428,7 +9419,9 @@ static int i40e_xdp_setup(struct i40e_vsi *vsi,
 {
 	struct i40e_pf *pf = vsi->back;
 	struct net_device *netdev = vsi->netdev;
-	int frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	int i, frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	bool need_reset;
+	struct bpf_prog *old_prog;
 
 	if (frame_size > I40E_RXBUFFER_2048)
 		return -EINVAL;
@@ -9439,13 +9432,29 @@ static int i40e_xdp_setup(struct i40e_vsi *vsi,
 	if (!i40e_enabled_xdp_vsi(vsi) && !prog)
 		return 0;
 
-	i40e_prep_for_reset(pf);
+	if (prog) {
+		prog = bpf_prog_add(prog, vsi->num_queue_pairs - 1);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+	}
 
-	if (vsi->xdp_prog)
-		bpf_prog_put(vsi->xdp_prog);
-	vsi->xdp_prog = prog;
+	/* When turning XDP on->off/off->on we reset and rebuild the rings. */
+	need_reset = (i40e_enabled_xdp_vsi(vsi) != !!prog);
 
-	i40e_reset_and_rebuild(pf, true);
+	if (need_reset)
+		i40e_prep_for_reset(pf);
+
+	vsi->xdp_enabled = !!prog;
+
+	if (need_reset)
+		i40e_reset_and_rebuild(pf, true);
+
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		old_prog = rtnl_dereference(vsi->rx_rings[i]->xdp_prog);
+		rcu_assign_pointer(vsi->rx_rings[i]->xdp_prog, prog);
+		if (old_prog)
+			bpf_prog_put(old_prog);
+	}
 	return 0;
 }
 
@@ -11740,7 +11749,9 @@ static void i40e_remove(struct pci_dev *pdev)
 		pf->flags &= ~I40E_FLAG_SRIOV_ENABLED;
 	}
 
+	rtnl_lock();
 	i40e_fdir_teardown(pf);
+	rtnl_unlock();
 
 	/* If there is a switch structure or any orphans, remove them.
 	 * This will leave only the PF's VSI remaining.
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index fccdec7ae102..338b4c4c0199 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1112,6 +1112,7 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 	struct device *dev = rx_ring->dev;
 	unsigned long bi_size;
 	u16 i;
+	struct bpf_prog *old_prog;
 
 	/* ring already cleared, nothing to do */
 	if (!rx_ring->rx_bi)
@@ -1145,10 +1146,10 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
-	if (rx_ring->xdp_prog) {
-		bpf_prog_put(rx_ring->xdp_prog);
-		rx_ring->xdp_prog = NULL;
-	}
+	old_prog = rtnl_dereference(rx_ring->xdp_prog);
+	RCU_INIT_POINTER(rx_ring->xdp_prog, NULL);
+	if (old_prog)
+		bpf_prog_put(old_prog);
 }
 
 /**
@@ -1880,6 +1881,7 @@ bool i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 {
 	struct i40e_rx_buffer *rx_buffer;
 	struct page *page;
+	struct bpf_prog *xdp_prog;
 
 	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
 	page = rx_buffer->page;
@@ -1892,14 +1894,17 @@ bool i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				      I40E_RXBUFFER_2048,
 				      DMA_FROM_DEVICE);
 
-	if (rx_ring->xdp_prog) {
-		bool xdp_consumed;
-
-		xdp_consumed = i40e_run_xdp(rx_ring, rx_buffer,
-					    rx_desc, rx_ring->xdp_prog);
-		if (xdp_consumed)
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(rx_ring->xdp_prog);
+	if (xdp_prog) {
+		bool xdp_consumed = i40e_run_xdp(rx_ring, rx_buffer,
+						 rx_desc, xdp_prog);
+		if (xdp_consumed) {
+			rcu_read_unlock();
 			return true;
+		}
 	}
+	rcu_read_unlock();
 
 	*skb = rx_buffer->skb;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 4d9459134e69..cfb2c1016242 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -344,7 +344,7 @@ struct i40e_ring {
 	struct rcu_head rcu;		/* to avoid race on free */
 	u16 next_to_alloc;
 
-	struct bpf_prog *xdp_prog;
+	struct bpf_prog __rcu *xdp_prog;
 	struct i40e_ring *xdp_sibling;  /* rx to xdp, and xdp to rx */
 	bool xdp_needs_tail_bump;
 	u16 curr_in_use;
-- 
2.9.3
