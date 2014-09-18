From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 21/29] fm10k: Add support for MACVLAN acceleration
Date: Thu, 18 Sep 2014 18:39:05 -0400
Message-ID: <20140918223903.10373.72685.stgit@ahduyck-bv4.jf.intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4678 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbaIRWr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:47:57 -0400
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for L2 MACVLAN by making use of the fact that the
RRC provides a unique tag per filter called a Global Resource Tag, or GLORT.
In the case of this offload what I have done is assigned a linear block of
these so that each GLORT represents one of the MACVLAN netdevs.  By doing
this I can share the Rx queues and Tx queues for all of the MACVLAN netdevs
while allowing them to be demuxed in the Rx cleanup path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |   11 ++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |   32 +++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  154 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |    2 
 4 files changed, 198 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 19c3f8c..82efaed 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -54,6 +54,15 @@
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define FM10K_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
+#define FM10K_MAX_STATIONS	63
+struct fm10k_l2_accel {
+	int size;
+	u16 count;
+	u16 dglort;
+	struct rcu_head rcu;
+	struct net_device *macvlan[0];
+};
+
 enum fm10k_ring_state_t {
 	__FM10K_TX_DETECT_HANG,
 	__FM10K_HANG_CHECK_ARMED,
@@ -104,6 +113,7 @@ struct fm10k_ring {
 	struct fm10k_q_vector *q_vector;/* backpointer to host q_vector */
 	struct net_device *netdev;	/* netdev ring belongs to */
 	struct device *dev;		/* device for DMA mapping */
+	struct fm10k_l2_accel __rcu *l2_accel;	/* L2 acceleration list */
 	void *desc;			/* descriptor ring memory */
 	union {
 		struct fm10k_tx_buffer *tx_buffer;
@@ -217,6 +227,7 @@ struct fm10k_vxlan_port {
 struct fm10k_intfc {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device *netdev;
+	struct fm10k_l2_accel *l2_accel; /* pointer to L2 acceleration list */
 	struct pci_dev *pdev;
 	unsigned long state;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index baab163..1e4fcba 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -394,6 +394,35 @@ static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 }
 
+static void fm10k_type_trans(struct fm10k_ring *rx_ring,
+			     union fm10k_rx_desc *rx_desc,
+			     struct sk_buff *skb)
+{
+	struct net_device *dev = rx_ring->netdev;
+	struct fm10k_l2_accel *l2_accel = ACCESS_ONCE(rx_ring->l2_accel);
+
+	/* check to see if DGLORT belongs to a MACVLAN */
+	if (l2_accel) {
+		u16 idx = le16_to_cpu(FM10K_CB(skb)->fi.w.dglort) - 1;
+
+		idx -= l2_accel->dglort;
+		if (idx < l2_accel->size && l2_accel->macvlan[idx])
+			dev = l2_accel->macvlan[idx];
+		else
+			l2_accel = NULL;
+	}
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	if (!l2_accel)
+		return;
+
+	/* update MACVLAN statistics */
+	macvlan_count_rx(netdev_priv(dev), skb->len + ETH_HLEN, 1,
+			 !!(rx_desc->w.hdr_info &
+			    cpu_to_le16(FM10K_RXD_HDR_INFO_XC_MASK)));
+}
+
 /**
  * fm10k_process_skb_fields - Populate skb header fields from Rx descriptor
  * @rx_ring: rx descriptor ring packet is being transacted on
@@ -427,7 +456,7 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 
-	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+	fm10k_type_trans(rx_ring, rx_desc, skb);
 
 	return len;
 }
@@ -1567,6 +1596,7 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 		/* assign generic ring traits */
 		ring->dev = &interface->pdev->dev;
 		ring->netdev = interface->netdev;
+		ring->l2_accel = interface->l2_accel;
 
 		/* configure backlink on ring */
 		ring->q_vector = q_vector;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 6383db2..af30e25 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1144,6 +1144,155 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
+static void fm10k_assign_l2_accel(struct fm10k_intfc *interface,
+				  struct fm10k_l2_accel *l2_accel)
+{
+	struct fm10k_ring *ring;
+	int i;
+
+	for (i = 0; i < interface->num_rx_queues; i++) {
+		ring = interface->rx_ring[i];
+		rcu_assign_pointer(ring->l2_accel, l2_accel);
+	}
+
+	rcu_assign_pointer(interface->l2_accel, l2_accel);
+}
+
+static void *fm10k_dfwd_add_station(struct net_device *dev,
+				    struct net_device *sdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_l2_accel *l2_accel = ACCESS_ONCE(interface->l2_accel);
+	struct fm10k_l2_accel *old_l2_accel = NULL;
+	struct fm10k_dglort_cfg dglort = { 0 };
+	struct fm10k_hw *hw = &interface->hw;
+	int size = 0, i;
+	u16 glort;
+
+	/* allocate l2 accel structure if it is not available */
+	if (!l2_accel) {
+		/* verify there is enough free GLORTs to support l2_accel */
+		if (interface->glort_count < 7)
+			return ERR_PTR(-EBUSY);
+
+		size = offsetof(struct fm10k_l2_accel, macvlan[7]);
+		l2_accel = kzalloc(size, GFP_KERNEL);
+		if (!l2_accel)
+			return ERR_PTR(-ENOMEM);
+
+		l2_accel->size = 7;
+		l2_accel->dglort = interface->glort;
+
+		/* update pointers */
+		fm10k_assign_l2_accel(interface, l2_accel);
+	/* do not expand if we are at our limit */
+	} else if ((l2_accel->count == FM10K_MAX_STATIONS) ||
+		   (l2_accel->count == (interface->glort_count - 1))) {
+		return ERR_PTR(-EBUSY);
+	/* expand if we have hit the size limit */
+	} else if (l2_accel->count == l2_accel->size) {
+		old_l2_accel = l2_accel;
+		size = offsetof(struct fm10k_l2_accel,
+				macvlan[(l2_accel->size * 2) + 1]);
+		l2_accel = kzalloc(size, GFP_KERNEL);
+		if (!l2_accel)
+			return ERR_PTR(-ENOMEM);
+
+		memcpy(l2_accel, old_l2_accel,
+		       offsetof(struct fm10k_l2_accel,
+				macvlan[old_l2_accel->size]));
+
+		l2_accel->size = (old_l2_accel->size * 2) + 1;
+
+		/* update pointers */
+		fm10k_assign_l2_accel(interface, l2_accel);
+		kfree_rcu(old_l2_accel, rcu);
+	}
+
+	/* add macvlan to accel table, and record GLORT for position */
+	for (i = 0; i < l2_accel->size; i++) {
+		if (!l2_accel->macvlan[i])
+			break;
+	}
+
+	/* record station */
+	l2_accel->macvlan[i] = sdev;
+	l2_accel->count++;
+
+	/* configure default DGLORT mapping for RSS/DCB */
+	dglort.idx = fm10k_dglort_pf_rss;
+	dglort.inner_rss = 1;
+	dglort.rss_l = fls(interface->ring_feature[RING_F_RSS].mask);
+	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
+	dglort.glort = interface->glort;
+	dglort.shared_l = fls(l2_accel->size);
+	hw->mac.ops.configure_dglort_map(hw, &dglort);
+
+	/* Add rules for this specific dglort to the switch */
+	fm10k_mbx_lock(interface);
+
+	glort = l2_accel->dglort + 1 + i;
+	hw->mac.ops.update_xcast_mode(hw, glort, FM10K_XCAST_MODE_MULTI);
+	hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr, 0, true, 0);
+
+	fm10k_mbx_unlock(interface);
+
+	return sdev;
+}
+
+static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_l2_accel *l2_accel = ACCESS_ONCE(interface->l2_accel);
+	struct fm10k_dglort_cfg dglort = { 0 };
+	struct fm10k_hw *hw = &interface->hw;
+	struct net_device *sdev = priv;
+	int i;
+	u16 glort;
+
+	if (!l2_accel)
+		return;
+
+	/* search table for matching interface */
+	for (i = 0; i < l2_accel->size; i++) {
+		if (l2_accel->macvlan[i] == sdev)
+			break;
+	}
+
+	/* exit if macvlan not found */
+	if (i == l2_accel->size)
+		return;
+
+	/* Remove any rules specific to this dglort */
+	fm10k_mbx_lock(interface);
+
+	glort = l2_accel->dglort + 1 + i;
+	hw->mac.ops.update_xcast_mode(hw, glort, FM10K_XCAST_MODE_NONE);
+	hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr, 0, false, 0);
+
+	fm10k_mbx_unlock(interface);
+
+	/* record removal */
+	l2_accel->macvlan[i] = NULL;
+	l2_accel->count--;
+
+	/* configure default DGLORT mapping for RSS/DCB */
+	dglort.idx = fm10k_dglort_pf_rss;
+	dglort.inner_rss = 1;
+	dglort.rss_l = fls(interface->ring_feature[RING_F_RSS].mask);
+	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
+	dglort.glort = interface->glort;
+	if (l2_accel)
+		dglort.shared_l = fls(l2_accel->size);
+	hw->mac.ops.configure_dglort_map(hw, &dglort);
+
+	/* If table is empty remove it */
+	if (l2_accel->count == 0) {
+		fm10k_assign_l2_accel(interface, NULL);
+		kfree_rcu(l2_accel, rcu);
+	}
+}
+
 static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_open		= fm10k_open,
 	.ndo_stop		= fm10k_close,
@@ -1159,6 +1308,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_setup_tc		= fm10k_setup_tc,
 	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
 	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
+	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
+	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
@@ -1194,6 +1345,9 @@ struct net_device *fm10k_alloc_netdev(void)
 	/* all features defined to this point should be changeable */
 	dev->hw_features |= dev->features;
 
+	/* allow user to enable L2 forwarding acceleration */
+	dev->hw_features |= NETIF_F_HW_L2FW_DOFFLOAD;
+
 	/* configure VLAN features */
 	dev->vlan_features |= dev->features;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9b97da7..c61241a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -756,6 +756,8 @@ static void fm10k_configure_dglort(struct fm10k_intfc *interface)
 	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
 	/* configure DGLORT mapping for RSS/DCB */
 	dglort.idx = fm10k_dglort_pf_rss;
+	if (interface->l2_accel)
+		dglort.shared_l = fls(interface->l2_accel->size);
 	hw->mac.ops.configure_dglort_map(hw, &dglort);
 }
 
