From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH V2 5/5] i40e/ethtool: support coalesce setting by queue
Date: Fri, 8 Jan 2016 19:55:46 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0770586E7D8@SHSMSX103.ccr.corp.intel.com>
References: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
 <1451912041-8860-5-git-send-email-kan.liang@intel.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFE2A3B@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Nelson, Shannon" <shannon.nelson@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6955 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbcAHTzv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:55:51 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFE2A3B@fmsmsx115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> This looks reasonable, but be aware that since there's no concept of
> queue-specific settings in the driver proper, these settings will get lost on
> the next reset - see i40e_vsi_configure_msix().  A reset can be driven by a
> number of things such as MTU changes, LLDP events, tx timeout recovery,
> promiscuous on/off, and various other configuration changes.  This might
> not be acceptable for your needs.
> 

Yes, the reset could be an issue.
I guess we may make the concept of queue-specific settings for i40e by moving
rx_itr_setting and tx_itr_setting to i40e_ring.

How about the patch as below?
The patch only move itr_setting from i40e_vsi to i40e_ring.
There should be no behavior change. 

------
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c202f9b..d51c650 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -499,13 +499,6 @@ struct i40e_vsi {
 	struct i40e_ring **tx_rings;
 
 	u16 work_limit;
-	/* high bit set means dynamic, use accessor routines to read/write.
-	 * hardware only supports 2us resolution for the ITR registers.
-	 * these values always store the USER setting, and must be converted
-	 * before programming to a register.
-	 */
-	u16 rx_itr_setting;
-	u16 tx_itr_setting;
 	u16 int_rate_limit;  /* value in usecs */
 
 	u16 rss_table_size; /* HW RSS table size */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 10744a6..40d49f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -533,6 +533,10 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 "    rx_rings[%i]: vsi = %p, q_vector = %p\n",
 			 i, rx_ring->vsi,
 			 rx_ring->q_vector);
+		dev_info(&pf->pdev->dev,
+			 "    rx_rings[%i]: rx_itr_setting = %d (%s)\n",
+			 i, rx_ring->rx_itr_setting,
+			 ITR_IS_DYNAMIC(rx_ring->rx_itr_setting) ? "dynamic" : "fixed");
 	}
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		struct i40e_ring *tx_ring = ACCESS_ONCE(vsi->tx_rings[i]);
@@ -583,14 +587,15 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		dev_info(&pf->pdev->dev,
 			 "    tx_rings[%i]: DCB tc = %d\n",
 			 i, tx_ring->dcb_tc);
+		dev_info(&pf->pdev->dev,
+			 "    tx_rings[%i]: tx_itr_setting = %d (%s)\n",
+			 i, tx_ring->tx_itr_setting,
+			 ITR_IS_DYNAMIC(tx_ring->tx_itr_setting) ? "dynamic" : "fixed");
 	}
 	rcu_read_unlock();
 	dev_info(&pf->pdev->dev,
-		 "    work_limit = %d, rx_itr_setting = %d (%s), tx_itr_setting = %d (%s)\n",
-		 vsi->work_limit, vsi->rx_itr_setting,
-		 ITR_IS_DYNAMIC(vsi->rx_itr_setting) ? "dynamic" : "fixed",
-		 vsi->tx_itr_setting,
-		 ITR_IS_DYNAMIC(vsi->tx_itr_setting) ? "dynamic" : "fixed");
+		 "    work_limit = %d\n",
+		 vsi->work_limit);
 	dev_info(&pf->pdev->dev,
 		 "    max_frame = %d, rx_hdr_len = %d, rx_buf_len = %d dtype = %d\n",
 		 vsi->max_frame, vsi->rx_hdr_len, vsi->rx_buf_len, vsi->dtype);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 29d5833..3e477a9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1845,8 +1845,9 @@ static int i40e_set_phys_id(struct net_device *netdev,
  * 125us (8000 interrupts per second) == ITR(62)
  */
 
-static int i40e_get_coalesce(struct net_device *netdev,
-			     struct ethtool_coalesce *ec)
+static int __i40e_get_coalesce(struct net_device *netdev,
+			       struct ethtool_coalesce *ec,
+			       int queue)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -1854,14 +1855,20 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	ec->tx_max_coalesced_frames_irq = vsi->work_limit;
 	ec->rx_max_coalesced_frames_irq = vsi->work_limit;
 
-	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting))
-		ec->use_adaptive_rx_coalesce = 1;
+	/*
+	 * rx and tx usecs has per queue value. If user doesn't specify the queue,
+	 * return queue 0's value to represent.
+	 */
+	if (queue < 0) {
+		if (ITR_IS_DYNAMIC(vsi->rx_rings[0]->rx_itr_setting))
+			ec->use_adaptive_rx_coalesce = 1;
 
-	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting))
-		ec->use_adaptive_tx_coalesce = 1;
+		if (ITR_IS_DYNAMIC(vsi->tx_rings[0]->tx_itr_setting))
+			ec->use_adaptive_tx_coalesce = 1;
 
-	ec->rx_coalesce_usecs = vsi->rx_itr_setting & ~I40E_ITR_DYNAMIC;
-	ec->tx_coalesce_usecs = vsi->tx_itr_setting & ~I40E_ITR_DYNAMIC;
+		ec->rx_coalesce_usecs = vsi->rx_rings[0]->rx_itr_setting & ~I40E_ITR_DYNAMIC;
+		ec->tx_coalesce_usecs = vsi->tx_rings[0]->tx_itr_setting & ~I40E_ITR_DYNAMIC;
+	}
 	/* we use the _usecs_high to store/set the interrupt rate limit
 	 * that the hardware supports, that almost but not quite
 	 * fits the original intent of the ethtool variable,
@@ -1874,15 +1881,23 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
-static int i40e_set_coalesce(struct net_device *netdev,
+static int i40e_get_coalesce(struct net_device *netdev,
 			     struct ethtool_coalesce *ec)
 {
+	return __i40e_get_coalesce(netdev, ec, -1);
+}
+
+static int __i40e_set_coalesce(struct net_device *netdev,
+			       struct ethtool_coalesce *ec,
+			       int queue)
+{
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_q_vector *q_vector;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	u16 vector;
+	u16 intrl;
 	int i;
 
 	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
@@ -1900,58 +1915,62 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	}
 
 	vector = vsi->base_vector;
-	if ((ec->rx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
-	    (ec->rx_coalesce_usecs <= (I40E_MAX_ITR << 1))) {
-		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
-	} else if (ec->rx_coalesce_usecs == 0) {
-		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
+	if (ec->rx_coalesce_usecs == 0) {
 		if (ec->use_adaptive_rx_coalesce)
 			netif_info(pf, drv, netdev, "rx-usecs=0, need to disable adaptive-rx for a complete disable\n");
-	} else {
-		netif_info(pf, drv, netdev, "Invalid value, rx-usecs range is 0-8160\n");
-		return -EINVAL;
+	} else if ((ec->rx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
+		   (ec->rx_coalesce_usecs > (I40E_MAX_ITR << 1))) {
+			netif_info(pf, drv, netdev, "Invalid value, rx-usecs range is 0-8160\n");
+			return -EINVAL;
 	}
 
 	vsi->int_rate_limit = ec->rx_coalesce_usecs_high;
 
-	if ((ec->tx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
-	    (ec->tx_coalesce_usecs <= (I40E_MAX_ITR << 1))) {
-		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
-	} else if (ec->tx_coalesce_usecs == 0) {
-		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
+	if (ec->tx_coalesce_usecs == 0) {
 		if (ec->use_adaptive_tx_coalesce)
 			netif_info(pf, drv, netdev, "tx-usecs=0, need to disable adaptive-tx for a complete disable\n");
-	} else {
-		netif_info(pf, drv, netdev,
-			   "Invalid value, tx-usecs range is 0-8160\n");
-		return -EINVAL;
+	} else if ((ec->tx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
+		   (ec->tx_coalesce_usecs > (I40E_MAX_ITR << 1))) {
+			netif_info(pf, drv, netdev, "Invalid value, tx-usecs range is 0-8160\n");
+			return -EINVAL;
 	}
 
-	if (ec->use_adaptive_rx_coalesce)
-		vsi->rx_itr_setting |= I40E_ITR_DYNAMIC;
-	else
-		vsi->rx_itr_setting &= ~I40E_ITR_DYNAMIC;
+	if (queue < 0) {
+		for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
+			intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
 
-	if (ec->use_adaptive_tx_coalesce)
-		vsi->tx_itr_setting |= I40E_ITR_DYNAMIC;
-	else
-		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
+			vsi->rx_rings[i]->rx_itr_setting = ec->rx_coalesce_usecs;
+			vsi->tx_rings[i]->tx_itr_setting = ec->tx_coalesce_usecs;
+
+			if (ec->use_adaptive_rx_coalesce)
+				vsi->rx_rings[i]->rx_itr_setting |= I40E_ITR_DYNAMIC;
+			else
+				vsi->rx_rings[i]->rx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
-	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
-		u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
+			if (ec->use_adaptive_tx_coalesce)
+				vsi->tx_rings[i]->tx_itr_setting |= I40E_ITR_DYNAMIC;
+			else
+				vsi->tx_rings[i]->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
-		q_vector = vsi->q_vectors[i];
-		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
-		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
-		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
-		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
-		wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
-		i40e_flush(hw);
+			q_vector = vsi->q_vectors[i];
+			q_vector->rx.itr = ITR_TO_REG(vsi->rx_rings[i]->rx_itr_setting);
+			wr32(hw, I40E_PFINT_ITRN(I40E_RX_ITR, vector - 1), q_vector->rx.itr);
+			q_vector->tx.itr = ITR_TO_REG(vsi->tx_rings[i]->tx_itr_setting);
+			wr32(hw, I40E_PFINT_ITRN(I40E_TX_ITR, vector - 1), q_vector->tx.itr);
+			wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
+			i40e_flush(hw);
+		}
 	}
 
 	return 0;
 }
 
+static int i40e_set_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	return __i40e_set_coalesce(netdev, ec, -1);
+}
+
 /**
  * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
  * @pf: pointer to the physical function struct
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1598fb3..02c4557 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3098,11 +3098,11 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
 		struct i40e_q_vector *q_vector = vsi->q_vectors[i];
 
 		q_vector->itr_countdown = ITR_COUNTDOWN_START;
-		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+		q_vector->rx.itr = ITR_TO_REG(vsi->rx_rings[i]->rx_itr_setting);
 		q_vector->rx.latency_range = I40E_LOW_LATENCY;
 		wr32(hw, I40E_PFINT_ITRN(I40E_RX_ITR, vector - 1),
 		     q_vector->rx.itr);
-		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
+		q_vector->tx.itr = ITR_TO_REG(vsi->tx_rings[i]->tx_itr_setting);
 		q_vector->tx.latency_range = I40E_LOW_LATENCY;
 		wr32(hw, I40E_PFINT_ITRN(I40E_TX_ITR, vector - 1),
 		     q_vector->tx.itr);
@@ -3194,10 +3194,10 @@ static void i40e_configure_msi_and_legacy(struct i40e_vsi *vsi)
 
 	/* set the ITR configuration */
 	q_vector->itr_countdown = ITR_COUNTDOWN_START;
-	q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+	q_vector->rx.itr = ITR_TO_REG(vsi->rx_rings[0]->rx_itr_setting);
 	q_vector->rx.latency_range = I40E_LOW_LATENCY;
 	wr32(hw, I40E_PFINT_ITR0(I40E_RX_ITR), q_vector->rx.itr);
-	q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
+	q_vector->tx.itr = ITR_TO_REG(vsi->tx_rings[0]->tx_itr_setting);
 	q_vector->tx.latency_range = I40E_LOW_LATENCY;
 	wr32(hw, I40E_PFINT_ITR0(I40E_TX_ITR), q_vector->tx.itr);
 
@@ -7284,8 +7284,6 @@ static int i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	set_bit(__I40E_DOWN, &vsi->state);
 	vsi->flags = 0;
 	vsi->idx = vsi_idx;
-	vsi->rx_itr_setting = pf->rx_itr_default;
-	vsi->tx_itr_setting = pf->tx_itr_default;
 	vsi->int_rate_limit = 0;
 	vsi->rss_table_size = (vsi->type == I40E_VSI_MAIN) ?
 				pf->rss_table_size : 64;
@@ -7454,6 +7452,7 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 			tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
 		if (vsi->back->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
 			tx_ring->flags |= I40E_TXR_FLAGS_OUTER_UDP_CSUM;
+		tx_ring->tx_itr_setting = pf->tx_itr_default;
 		vsi->tx_rings[i] = tx_ring;
 
 		rx_ring = &tx_ring[1];
@@ -7470,6 +7469,7 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 			set_ring_16byte_desc_enabled(rx_ring);
 		else
 			clear_ring_16byte_desc_enabled(rx_ring);
+		rx_ring->rx_itr_setting = pf->rx_itr_default;
 		vsi->rx_rings[i] = rx_ring;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e9e9a37..19b82dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1810,6 +1810,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	bool rx = false, tx = false;
 	u32 rxval, txval;
 	int vector;
+	int idx = q_vector->v_idx;
 
 	vector = (q_vector->v_idx + vsi->base_vector);
 
@@ -1819,17 +1820,17 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
 
 	if (q_vector->itr_countdown > 0 ||
-	    (!ITR_IS_DYNAMIC(vsi->rx_itr_setting) &&
-	     !ITR_IS_DYNAMIC(vsi->tx_itr_setting))) {
+	    (!ITR_IS_DYNAMIC(vsi->rx_rings[idx]->rx_itr_setting) &&
+	     !ITR_IS_DYNAMIC(vsi->tx_rings[idx]->tx_itr_setting))) {
 		goto enable_int;
 	}
 
-	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
+	if (ITR_IS_DYNAMIC(vsi->rx_rings[idx]->rx_itr_setting)) {
 		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
 		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
 	}
 
-	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
+	if (ITR_IS_DYNAMIC(vsi->tx_rings[idx]->tx_itr_setting)) {
 		tx = i40e_set_new_dynamic_itr(&q_vector->tx);
 		txval = i40e_buildreg_itr(I40E_TX_ITR, q_vector->tx.itr);
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 3f081e2..ea1f479 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -246,6 +246,14 @@ struct i40e_ring {
 	u8 dcb_tc;			/* Traffic class of ring */
 	u8 __iomem *tail;
 
+	/* high bit set means dynamic, use accessor routines to read/write.
+	 * hardware only supports 2us resolution for the ITR registers.
+	 * these values always store the USER setting, and must be converted
+	 * before programming to a register.
+	 */
+	u16 rx_itr_setting;
+	u16 tx_itr_setting;
+
 	u16 count;			/* Number of descriptors */
 	u16 reg_idx;			/* HW register index of the ring */
 	u16 rx_hdr_len;
