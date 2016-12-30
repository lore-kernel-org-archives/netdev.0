From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Thu, 29 Dec 2016 22:21:02 -0800
Message-ID: <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19681 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750973AbcL2V2L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 16:28:11 -0500
In-Reply-To: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In switchdev mode, broadcast filter is not enabled on VFs, The broadcasts and
unknown frames from VFs are received by the PF and passed to corresponding VF
port representator netdev.
A host based switching entity like a linux bridge or OVS redirects these frames
to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
directed transmits to the corresponding VFs. To enable directed transmit, skb
metadata dst is used to pass the VF id and the frame is requeued to call the PFs
transmit routine.

Small script to demonstrate inter VF pings in switchdev mode.
PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1

# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip link set enp5s0f0 vf 0 mac 00:11:22:33:44:55
# ip link set enp5s0f0 vf 1 mac 00:11:22:33:44:56
# rmmod i40evf; modprobe i40evf

/* Create 2 namespaces and move the VFs to
# ip netns add ns0
# ip link set enp5s2 netns ns0
# ip netns exec ns0 ip addr add 192.168.1.10/24 dev enp5s2
# ip netns exec ns0 ip link set enp5s2 up
# ip netns add ns1
# ip link set enp5s2f1 netns ns1
# ip netns exec ns1 ip addr add 192.168.1.11/24 dev enp5s2f1
# ip netns exec ns1 ip link set enp5s2f1 up

/* bring up pf and vfpr netdevs */
# ip link set enp5s0f0 up
# ip link set enp5s0f0-vf0 up
# ip link set enp5s0f0-vf1 up

/* Create a linux bridge and add vfpr netdevs to it. */
# ip link add vfpr-br type bridge
# ip link set enp5s0f0-vf0 master vfpr-br
# ip link set enp5s0f0-vf1 master vfpr-br
# ip addr add 192.168.1.1/24 dev vfpr-br
# ip link set vfpr-br up

# ip netns exec ns0 ping -c3 192.168.1.11
# ip netns exec ns1 ping -c3 192.168.1.10

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 92 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 19 ++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 +
 7 files changed, 114 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 410f83d..1c88db5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -55,6 +55,7 @@
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
 #include <net/devlink.h>
+#include <net/dst_metadata.h>
 
 #include "i40e_type.h"
 #include "i40e_prototype.h"
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 03d07dd..431694e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10938,6 +10938,7 @@ static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 {
 	struct i40e_pf *pf = devlink_priv(devlink);
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_vf *vf;
 	int i, err = 0;
 
@@ -10951,6 +10952,8 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 			i40e_free_vfpr_netdev(vf);
 		}
 		pf->eswitch_mode = mode;
+		vsi->netdev->priv_flags |=
+			(IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM);
 		break;
 	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
 		for (i = 0; i < pf->num_alloc_vfs; i++) {
@@ -10958,6 +10961,7 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 			i40e_alloc_vfpr_netdev(vf, i);
 		}
                 pf->eswitch_mode = mode;
+		netif_keep_dst(vsi->netdev);
 		break;
 	default:
 		err = -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 352cf7c..b46ddaa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1176,16 +1176,37 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
  * @rx_ring:  rx ring in play
  * @skb: packet to send up
  * @vlan_tag: vlan tag for packet
+ * @lpbk: is it a loopback frame?
  **/
 static void i40e_receive_skb(struct i40e_ring *rx_ring,
-			     struct sk_buff *skb, u16 vlan_tag)
+			     struct sk_buff *skb, u16 vlan_tag, bool lpbk)
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
+	struct i40e_pf *pf = rx_ring->vsi->back;
+	struct i40e_vf *vf;
+	struct ethhdr *eth;
+	int vf_id;
 
 	if ((rx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    (vlan_tag & VLAN_VID_MASK))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
+	if ((pf->eswitch_mode == DEVLINK_ESWITCH_MODE_LEGACY) || !lpbk)
+		goto gro_receive;
+
+	/* If a loopback packet is received from a VF in switchdev mode, pass the
+	 * frame to the corresponding VFPR netdev based on the source MAC in the frame.
+	 */
+	eth = (struct ethhdr *)skb_mac_header(skb);
+	for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
+		vf = &pf->vf[vf_id];
+		if (ether_addr_equal(eth->h_source, vf->default_lan_addr.addr)) {
+			skb->dev = vf->vfpr_netdev;
+			break;
+		}
+	}
+
+gro_receive:
 	napi_gro_receive(&q_vector->napi, skb);
 }
 
@@ -1394,6 +1415,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
  * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being populated
  * @rx_ptype: the packet type decoded by hardware
+ * @lpbk: is it a loopback frame?
  *
  * This function checks the ring, descriptor, and packet information in
  * order to populate the hash, checksum, VLAN, protocol, and
@@ -1402,7 +1424,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
 static inline
 void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 			     union i40e_rx_desc *rx_desc, struct sk_buff *skb,
-			     u8 rx_ptype)
+			     u8 rx_ptype, bool *lpbk)
 {
 	u64 qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 	u32 rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
@@ -1411,6 +1433,9 @@ void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 	u32 tsyn = (rx_status & I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
 		   I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT;
 
+	*lpbk = !!((rx_status & I40E_RXD_QW1_STATUS_LPBK_MASK) >>
+		   I40E_RXD_QW1_STATUS_LPBK_SHIFT);
+
 	if (unlikely(tsynvalid))
 		i40e_ptp_rx_hwtstamp(rx_ring->vsi->back, skb, tsyn);
 
@@ -1736,6 +1761,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	while (likely(total_rx_packets < budget)) {
 		union i40e_rx_desc *rx_desc;
 		struct sk_buff *skb;
+		bool lpbk;
 		u16 vlan_tag;
 		u8 rx_ptype;
 		u64 qword;
@@ -1794,7 +1820,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			   I40E_RXD_QW1_PTYPE_SHIFT;
 
 		/* populate checksum, VLAN, and protocol */
-		i40e_process_skb_fields(rx_ring, rx_desc, skb, rx_ptype);
+		i40e_process_skb_fields(rx_ring, rx_desc, skb, rx_ptype, &lpbk);
 
 #ifdef I40E_FCOE
 		if (unlikely(
@@ -1808,7 +1834,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		vlan_tag = (qword & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)) ?
 			   le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1) : 0;
 
-		i40e_receive_skb(rx_ring, skb, vlan_tag);
+		i40e_receive_skb(rx_ring, skb, vlan_tag, lpbk);
 
 		/* update budget accounting */
 		total_rx_packets++;
@@ -2346,6 +2372,27 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 }
 
 /**
+ * i40e_tvsi - set up the target vsi in TX context descriptor
+ * @tx_ring:  ptr to the target vsi
+ * @cd_type_cmd_tso_mss: Quad Word 1
+ *
+ * Returns 0
+ **/
+static int i40e_tvsi(struct i40e_vsi *tvsi, u64 *cd_type_cmd_tso_mss)
+{
+	u64 cd_cmd, cd_tvsi;
+
+	cd_cmd = I40E_TX_CTX_DESC_SWTCH_VSI;
+	cd_tvsi = tvsi->id;
+	cd_tvsi = (cd_tvsi << I40E_TXD_CTX_QW1_VSI_SHIFT) &
+		   I40E_TXD_CTX_QW1_VSI_MASK;
+	*cd_type_cmd_tso_mss |= (cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
+				 cd_tvsi;
+
+	return 0;
+}
+
+/**
  * i40e_tsyn - set up the tsyn context descriptor
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
@@ -2887,8 +2934,12 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 					struct i40e_ring *tx_ring)
 {
 	u64 cd_type_cmd_tso_mss = I40E_TX_DESC_DTYPE_CONTEXT;
+	struct metadata_dst *md_dst = skb_metadata_dst(skb);
 	u32 cd_tunneling = 0, cd_l2tag2 = 0;
 	struct i40e_tx_buffer *first;
+	struct i40e_vsi *t_vsi = NULL;
+	struct i40e_vf *t_vf;
+	struct i40e_pf *pf;
 	u32 td_offset = 0;
 	u32 tx_flags = 0;
 	__be16 protocol;
@@ -2935,7 +2986,22 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
-	tso = i40e_tso(skb, &hdr_len, &cd_type_cmd_tso_mss);
+	/* If skb metadata dst points to a VF id, do a directed transmit to
+	 * that VSI. TSO is mutually exclusive with this option. So TSO is not
+	 * enabled when doing a directed transmit.
+	 */
+	if (md_dst && (md_dst->type == METADATA_HW_PORT_MUX)) {
+		pf = tx_ring->vsi->back;
+		if (md_dst->u.port_info.port_id < pf->num_alloc_vfs) {
+			t_vf = &pf->vf[md_dst->u.port_info.port_id];
+			t_vsi = pf->vsi[t_vf->lan_vsi_idx];
+		}
+	}
+
+	if (t_vsi)
+		tso = i40e_tvsi(t_vsi, &cd_type_cmd_tso_mss);
+	else
+		tso = i40e_tso(skb, &hdr_len, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
@@ -2998,3 +3064,19 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	return i40e_xmit_frame_ring(skb, tx_ring);
 }
+
+netdev_tx_t i40e_vfpr_netdev_start_xmit(struct sk_buff *skb,
+				        struct net_device *dev)
+{
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+
+	skb_dst_drop(skb);
+	dst_hold(&priv->vfpr_dst->dst);
+	skb_dst_set(skb, &priv->vfpr_dst->dst);
+	skb->dev = vsi->netdev;
+
+	return dev_queue_xmit(skb);
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index e065321..850723f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -366,6 +366,7 @@ struct i40e_ring_container {
 
 bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+netdev_tx_t i40e_vfpr_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
 int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index edc0abd..c136cc9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -728,6 +728,9 @@ enum i40e_rx_desc_status_bits {
 #define I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT  I40E_RX_DESC_STATUS_TSYNVALID_SHIFT
 #define I40E_RXD_QW1_STATUS_TSYNVALID_MASK \
 				    BIT_ULL(I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
+#define I40E_RXD_QW1_STATUS_LPBK_SHIFT  I40E_RX_DESC_STATUS_LPBK_SHIFT
+#define I40E_RXD_QW1_STATUS_LPBK_MASK \
+				BIT_ULL(I40E_RXD_QW1_STATUS_LPBK_SHIFT)
 
 enum i40e_rx_desc_fltstat_values {
 	I40E_RX_DESC_FLTSTAT_NO_DATA	= 0,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 3ea7235..e3fded1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1062,6 +1062,7 @@ static int i40e_vfpr_netdev_stop(struct net_device *dev)
 static const struct net_device_ops i40e_vfpr_netdev_ops = {
 	.ndo_open       	= i40e_vfpr_netdev_open,
 	.ndo_stop       	= i40e_vfpr_netdev_stop,
+	.ndo_start_xmit		= i40e_vfpr_netdev_start_xmit,
 };
 
 /**
@@ -1121,16 +1122,22 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
 
 	priv = netdev_priv(vfpr_netdev);
 	priv->vf = &(pf->vf[vf_num]);
+	priv->vfpr_dst = metadata_dst_alloc(0, METADATA_HW_PORT_MUX, GFP_KERNEL);
+	priv->vfpr_dst->u.port_info.lower_dev = vsi->netdev;
+	priv->vfpr_dst->u.port_info.port_id = vf->vf_id;
 
 	vfpr_netdev->netdev_ops = &i40e_vfpr_netdev_ops;
 
 	netif_carrier_off(vfpr_netdev);
 	netif_tx_disable(vfpr_netdev);
 
+	eth_hw_addr_inherit(vfpr_netdev, vsi->netdev);
+
 	err = register_netdev(vfpr_netdev);
 	if (err) {
 		dev_err(&pf->pdev->dev, "register_netdev failed for vf: %s\n",
 			vf->vfpr_netdev->name);
+		dst_release((struct dst_entry *)priv->vfpr_dst);
 		free_netdev(vfpr_netdev);
 		return err;
 	}
@@ -1159,14 +1166,18 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
  **/
 void i40e_free_vfpr_netdev(struct i40e_vf *vf)
 {
+	struct i40e_vfpr_netdev_priv *priv;
 	struct i40e_pf *pf = vf->pf;
 
 	if (!vf->vfpr_netdev)
 		return;
 
+	priv = netdev_priv(vf->vfpr_netdev);
+
 	dev_info(&pf->pdev->dev, "Freeing VF Port representor(%s)\n",
 		 vf->vfpr_netdev->name);
 
+	dst_release((struct dst_entry *)priv->vfpr_dst);
 	unregister_netdev(vf->vfpr_netdev);
 	free_netdev(vf->vfpr_netdev);
 
@@ -1933,8 +1944,10 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	if (i40e_vsi_start_rings(pf->vsi[vf->lan_vsi_idx]))
 		aq_ret = I40E_ERR_TIMEOUT;
 
-	if ((0 == aq_ret) && vf->vfpr_netdev)
+	if ((0 == aq_ret) && vf->vfpr_netdev) {
+		netif_tx_start_all_queues(vf->vfpr_netdev);
 		netif_carrier_on(vf->vfpr_netdev);
+	}
 
 error_param:
 	/* send the response to the VF */
@@ -1975,8 +1988,10 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	i40e_vsi_stop_rings(pf->vsi[vf->lan_vsi_idx]);
 
-	if ((0 == aq_ret) && vf->vfpr_netdev)
+	if ((0 == aq_ret) && vf->vfpr_netdev) {
+		netif_tx_stop_all_queues(vf->vfpr_netdev);
 		netif_carrier_off(vf->vfpr_netdev);
+	}
 
 error_param:
 	/* send the response to the VF */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 1e5def1..3c3db8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -74,6 +74,7 @@ enum i40e_vf_capabilities {
 
 /* VF Port representor netdev private structure */
 struct i40e_vfpr_netdev_priv {
+	struct metadata_dst *vfpr_dst;
 	struct i40e_vf *vf;
 };
 
-- 
2.5.5
