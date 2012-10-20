From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] ixgbevf: Add VF DCB + SR-IOV support
Date: Fri, 19 Oct 2012 23:25:59 -0700
Message-ID: <1350714367-24208-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18923 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab2JTG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:40 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for DCB and SR-IOV from the VF.  With this change
in place the VF will correctly use a traffic class other than 0 in the case
that the PF is configured with the default user priority belonging to a
traffic class other than 0.

Cc: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      |   7 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 159 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  58 ++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 6 files changed, 232 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index da17ccf..3147795 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -33,8 +33,11 @@
 #define IXGBE_DEV_ID_X540_VF            0x1515
 
 #define IXGBE_VF_IRQ_CLEAR_MASK         7
-#define IXGBE_VF_MAX_TX_QUEUES          1
-#define IXGBE_VF_MAX_RX_QUEUES          1
+#define IXGBE_VF_MAX_TX_QUEUES          8
+#define IXGBE_VF_MAX_RX_QUEUES          8
+
+/* DCB define */
+#define IXGBE_VF_MAX_TRAFFIC_CLASS	8
 
 /* Link speed */
 typedef u32 ixgbe_link_speed;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 4a9c9c2..2323ccd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -89,8 +89,8 @@ struct ixgbevf_ring {
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGBEVF_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
-#define MAX_RX_QUEUES 1
-#define MAX_TX_QUEUES 1
+#define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
+#define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
 
 #define IXGBEVF_DEFAULT_TXD   1024
 #define IXGBEVF_DEFAULT_RXD   512
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index de1ad50..33444b5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -99,6 +99,7 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /* forward decls */
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector);
+static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter);
 
 static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
 					   struct ixgbevf_ring *rx_ring,
@@ -1335,7 +1336,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
 static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int api[] = { ixgbe_mbox_api_10,
+	int api[] = { ixgbe_mbox_api_11,
+		      ixgbe_mbox_api_10,
 		      ixgbe_mbox_api_unknown };
 	int err = 0, idx = 0;
 
@@ -1413,12 +1415,87 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 }
 
+static int ixgbevf_reset_queues(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbevf_ring *rx_ring;
+	unsigned int def_q = 0;
+	unsigned int num_tcs = 0;
+	unsigned int num_rx_queues = 1;
+	int err, i;
+
+	spin_lock(&adapter->mbx_lock);
+
+	/* fetch queue configuration from the PF */
+	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
+
+	spin_unlock(&adapter->mbx_lock);
+
+	if (err)
+		return err;
+
+	if (num_tcs > 1) {
+		/* update default Tx ring register index */
+		adapter->tx_ring[0].reg_idx = def_q;
+
+		/* we need as many queues as traffic classes */
+		num_rx_queues = num_tcs;
+	}
+
+	/* nothing to do if we have the correct number of queues */
+	if (adapter->num_rx_queues == num_rx_queues)
+		return 0;
+
+	/* allocate new rings */
+	rx_ring = kcalloc(num_rx_queues,
+			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
+	if (!rx_ring)
+		return -ENOMEM;
+
+	/* setup ring fields */
+	for (i = 0; i < num_rx_queues; i++) {
+		rx_ring[i].count = adapter->rx_ring_count;
+		rx_ring[i].queue_index = i;
+		rx_ring[i].reg_idx = i;
+		rx_ring[i].dev = &adapter->pdev->dev;
+		rx_ring[i].netdev = adapter->netdev;
+
+		/* allocate resources on the ring */
+		err = ixgbevf_setup_rx_resources(adapter, &rx_ring[i]);
+		if (err) {
+			while (i) {
+				i--;
+				ixgbevf_free_rx_resources(adapter, &rx_ring[i]);
+			}
+			kfree(rx_ring);
+			return err;
+		}
+	}
+
+	/* free the existing rings and queues */
+	ixgbevf_free_all_rx_resources(adapter);
+	adapter->num_rx_queues = 0;
+	kfree(adapter->rx_ring);
+
+	/* move new rings into position on the adapter struct */
+	adapter->rx_ring = rx_ring;
+	adapter->num_rx_queues = num_rx_queues;
+
+	/* reset ring to vector mapping */
+	ixgbevf_reset_q_vectors(adapter);
+	ixgbevf_map_rings_to_vectors(adapter);
+
+	return 0;
+}
+
 void ixgbevf_up(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	ixgbevf_negotiate_api(adapter);
 
+	ixgbevf_reset_queues(adapter);
+
 	ixgbevf_configure(adapter);
 
 	ixgbevf_up_complete(adapter);
@@ -1717,6 +1794,7 @@ static int ixgbevf_alloc_queues(struct ixgbevf_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		adapter->tx_ring[i].count = adapter->tx_ring_count;
 		adapter->tx_ring[i].queue_index = i;
+		/* reg_idx may be remapped later by DCB config */
 		adapter->tx_ring[i].reg_idx = i;
 		adapter->tx_ring[i].dev = &adapter->pdev->dev;
 		adapter->tx_ring[i].netdev = adapter->netdev;
@@ -1950,8 +2028,11 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	hw->subsystem_device_id = pdev->subsystem_device;
 
 	hw->mbx.ops.init_params(hw);
-	hw->mac.max_tx_queues = MAX_TX_QUEUES;
-	hw->mac.max_rx_queues = MAX_RX_QUEUES;
+
+	/* assume legacy case in which PF would only give VF 2 queues */
+	hw->mac.max_tx_queues = 2;
+	hw->mac.max_rx_queues = 2;
+
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
@@ -2377,6 +2458,63 @@ static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter)
 						  &adapter->rx_ring[i]);
 }
 
+static int ixgbevf_setup_queues(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbevf_ring *rx_ring;
+	unsigned int def_q = 0;
+	unsigned int num_tcs = 0;
+	unsigned int num_rx_queues = 1;
+	int err, i;
+
+	spin_lock(&adapter->mbx_lock);
+
+	/* fetch queue configuration from the PF */
+	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
+
+	spin_unlock(&adapter->mbx_lock);
+
+	if (err)
+		return err;
+
+	if (num_tcs > 1) {
+		/* update default Tx ring register index */
+		adapter->tx_ring[0].reg_idx = def_q;
+
+		/* we need as many queues as traffic classes */
+		num_rx_queues = num_tcs;
+	}
+
+	/* nothing to do if we have the correct number of queues */
+	if (adapter->num_rx_queues == num_rx_queues)
+		return 0;
+
+	/* allocate new rings */
+	rx_ring = kcalloc(num_rx_queues,
+			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
+	if (!rx_ring)
+		return -ENOMEM;
+
+	/* setup ring fields */
+	for (i = 0; i < num_rx_queues; i++) {
+		rx_ring[i].count = adapter->rx_ring_count;
+		rx_ring[i].queue_index = i;
+		rx_ring[i].reg_idx = i;
+		rx_ring[i].dev = &adapter->pdev->dev;
+		rx_ring[i].netdev = adapter->netdev;
+	}
+
+	/* free the existing ring and queues */
+	adapter->num_rx_queues = 0;
+	kfree(adapter->rx_ring);
+
+	/* move new rings into position on the adapter struct */
+	adapter->rx_ring = rx_ring;
+	adapter->num_rx_queues = num_rx_queues;
+
+	return 0;
+}
+
 /**
  * ixgbevf_open - Called when a network interface is made active
  * @netdev: network interface device structure
@@ -2413,6 +2551,11 @@ static int ixgbevf_open(struct net_device *netdev)
 
 	ixgbevf_negotiate_api(adapter);
 
+	/* setup queue reg_idx and Rx queue count */
+	err = ixgbevf_setup_queues(adapter);
+	if (err)
+		goto err_setup_queues;
+
 	/* allocate transmit descriptors */
 	err = ixgbevf_setup_all_tx_resources(adapter);
 	if (err)
@@ -2451,6 +2594,7 @@ err_setup_rx:
 	ixgbevf_free_all_rx_resources(adapter);
 err_setup_tx:
 	ixgbevf_free_all_tx_resources(adapter);
+err_setup_queues:
 	ixgbevf_reset(adapter);
 
 err_setup_reset:
@@ -2925,8 +3069,15 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
 
-	if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
+	switch (adapter->hw.api_version) {
+	case ixgbe_mbox_api_11:
 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
+		break;
+	default:
+		if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
+			max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
+		break;
+	}
 
 	/* MTU < 68 is an error and causes problems on some kernels */
 	if ((new_mtu < 68) || (max_frame > max_possible_frame))
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 946ce86..0bc3005 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -85,6 +85,7 @@
 enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
+	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
@@ -100,6 +101,15 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_SET_MACVLAN	0x06 /* VF requests PF for unicast filter */
 #define IXGBE_VF_API_NEGOTIATE	0x08 /* negotiate API version */
 
+/* mailbox API, version 1.1 VF requests */
+#define IXGBE_VF_GET_QUEUE	0x09 /* get queue configuration */
+
+/* GET_QUEUES return data indices within the mailbox */
+#define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
+#define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
+#define IXGBE_VF_TRANS_VLAN	3	/* Indication of port vlan */
+#define IXGBE_VF_DEF_QUEUE	4	/* Default queue offset */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 0c7447e..5fa397b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -513,6 +513,64 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api)
 	return err;
 }
 
+int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
+		       unsigned int *default_tc)
+{
+	int err;
+	u32 msg[5];
+
+	/* do nothing if API doesn't support ixgbevf_get_queues */
+	switch (hw->api_version) {
+	case ixgbe_mbox_api_11:
+		break;
+	default:
+		return 0;
+	}
+
+	/* Fetch queue configuration from the PF */
+	msg[0] = IXGBE_VF_GET_QUEUE;
+	msg[1] = msg[2] = msg[3] = msg[4] = 0;
+	err = hw->mbx.ops.write_posted(hw, msg, 5);
+
+	if (!err)
+		err = hw->mbx.ops.read_posted(hw, msg, 5);
+
+	if (!err) {
+		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
+
+		/*
+		 * if we we didn't get an ACK there must have been
+		 * some sort of mailbox error so we should treat it
+		 * as such
+		 */
+		if (msg[0] != (IXGBE_VF_GET_QUEUE | IXGBE_VT_MSGTYPE_ACK))
+			return IXGBE_ERR_MBX;
+
+		/* record and validate values from message */
+		hw->mac.max_tx_queues = msg[IXGBE_VF_TX_QUEUES];
+		if (hw->mac.max_tx_queues == 0 ||
+		    hw->mac.max_tx_queues > IXGBE_VF_MAX_TX_QUEUES)
+			hw->mac.max_tx_queues = IXGBE_VF_MAX_TX_QUEUES;
+
+		hw->mac.max_rx_queues = msg[IXGBE_VF_RX_QUEUES];
+		if (hw->mac.max_rx_queues == 0 ||
+		    hw->mac.max_rx_queues > IXGBE_VF_MAX_RX_QUEUES)
+			hw->mac.max_rx_queues = IXGBE_VF_MAX_RX_QUEUES;
+
+		*num_tcs = msg[IXGBE_VF_TRANS_VLAN];
+		/* in case of unknown state assume we cannot tag frames */
+		if (*num_tcs > hw->mac.max_rx_queues)
+			*num_tcs = 1;
+
+		*default_tc = msg[IXGBE_VF_DEF_QUEUE];
+		/* default to queue 0 on out-of-bounds queue number */
+		if (*default_tc >= hw->mac.max_tx_queues)
+			*default_tc = 0;
+	}
+
+	return err;
+}
+
 static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.init_hw             = ixgbevf_init_hw_vf,
 	.reset_hw            = ixgbevf_reset_hw_vf,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 47f11a5..7b1f502 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -174,5 +174,7 @@ struct ixgbevf_info {
 
 void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
 int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
+int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
+		       unsigned int *default_tc);
 #endif /* __IXGBE_VF_H__ */
 
-- 
1.7.11.7
