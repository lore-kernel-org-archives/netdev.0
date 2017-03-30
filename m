From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 5/7] i40e: Add TX and RX support over port netdev's in switchdev mode
Date: Wed, 29 Mar 2017 17:22:53 -0700
Message-ID: <1490833375-2788-6-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42898 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933105AbdC3AXA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:23:00 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In switchdev mode, broadcasts from VFs are received by the PF and passed
to corresponding port representor netdev.
Any frames sent via port netdevs are sent as directed transmits to the
corresponding VFs. To enable directed transmit, skb metadata dst is used
to pass the port id and the frame is requeued to call the PFs transmit
routine. VF id is used as port id for VFs and PF port id is defined as
I40_MAIN_VSI_PORT_ID.

Small script to demonstrate inter VF and PF to VF pings in switchdev mode.
PF: p4p1, VFs: p4p1_0,p4p1_1 VF Port Reps:p4p1-vf0, p4p1-vf1
PF Port rep: p4p1-pf

# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/p4p1/device/sriov_numvfs
# ip link set p4p1 vf 0 mac 00:11:22:33:44:55
# ip link set p4p1 vf 1 mac 00:11:22:33:44:56
# rmmod i40evf; modprobe i40evf

/* Create 2 namespaces and move the VFs to the corresponding ns */
# ip netns add ns0
# ip link set p4p1_0 netns ns0
# ip netns exec ns0 ip addr add 192.168.1.10/24 dev p4p1_0
# ip netns exec ns0 ip link set p4p1_0 up
# ip netns add ns1
# ip link set p4p1_1 netns ns1
# ip netns exec ns1 ip addr add 192.168.1.11/24 dev p4p1_1
# ip netns exec ns1 ip link set p4p1_1 up

/* bring up pf and port netdevs */
# ip addr add 192.168.1.1/24 dev p4p1
# ip link set p4p1 up
# ip link set p4p1-vf0 up
# ip link set p4p1-vf1 up
# ip link set p4p1-pf up

# ip netns exec ns0 ping -c3 192.168.1.11  /* VF0 -> VF1 */
# ip netns exec ns1 ping -c3 192.168.1.10  /* VF1 -> VF0 */
# ping -c3 192.168.1.10   /* PF -> VF0 */
# ping -c3 192.168.1.11   /* PF -> VF1 */

/* VF0 -> IP in same subnet - broadcasts will be seen on p4p1-vf0 & p4p1 */
# ip netns exec ns0 ping -c1 -W1 192.168.1.200
/* VF1 -> IP in same subnet -  broadcasts will be seen on p4p1-vf1 & p4p1*/
# ip netns exec ns0 ping -c1 -W1 192.168.1.200
/* port rep VF0 -> IP in same subnet - broadcasts will be seen on p4p1_0 */
# ping -I p4p1-vf0 -c1 -W1 192.168.1.200
/* port rep VF1 -> IP in same subnet  - broadcasts will be seen on p4p1_1 */
# ping -I p4p1-vf1 -c1 -W1 192.168.1.200

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  27 +++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 148 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   8 +-
 6 files changed, 184 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c865803..ac11005 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -55,6 +55,7 @@
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
 #include <net/devlink.h>
+#include <net/dst_metadata.h>
 
 #include "i40e_type.h"
 #include "i40e_prototype.h"
@@ -320,6 +321,8 @@ struct i40e_flex_pit {
 	u8 pit_index;
 };
 
+#define I40E_MAIN_VSI_PORT_ID	(1 << 15)
+
 enum i40e_port_netdev_type {
 	I40E_PORT_NETDEV_PF,
 	I40E_PORT_NETDEV_VF
@@ -328,6 +331,7 @@ enum i40e_port_netdev_type {
 /* Port representor netdev private structure */
 struct i40e_port_netdev_priv {
 	enum i40e_port_netdev_type type;	/* type - PF or VF */
+	struct metadata_dst *dst;		/* port id */
 	void *f;				/* ptr to PF or VF struct */
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 683aa20..e9c5c6b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5519,8 +5519,10 @@ int i40e_open(struct net_device *netdev)
 
 	udp_tunnel_get_rx_info(netdev);
 
-	if (pf->port_netdev)
+	if (pf->port_netdev) {
 		netif_carrier_on(pf->port_netdev);
+		netif_tx_start_all_queues(pf->port_netdev);
+	}
 
 	return 0;
 }
@@ -5675,8 +5677,10 @@ int i40e_close(struct net_device *netdev)
 
 	i40e_vsi_close(vsi);
 
-	if (pf->port_netdev)
+	if (pf->port_netdev) {
 		netif_carrier_off(pf->port_netdev);
+		netif_tx_stop_all_queues(pf->port_netdev);
+	}
 
 	return 0;
 }
@@ -10872,6 +10876,7 @@ static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 {
 	struct i40e_pf *pf = devlink_priv(devlink);
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_vf *vf;
 	int i, j, err = 0;
 
@@ -10886,6 +10891,8 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 		}
 		i40e_free_port_netdev(pf, I40E_PORT_NETDEV_PF);
 		pf->eswitch_mode = mode;
+		vsi->netdev->priv_flags |=
+			(IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM);
 		break;
 	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
 		err = i40e_alloc_port_netdev(pf, I40E_PORT_NETDEV_PF);
@@ -10905,6 +10912,7 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 			}
 		}
 		pf->eswitch_mode = mode;
+		netif_keep_dst(vsi->netdev);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -10996,6 +11004,7 @@ static int i40e_port_netdev_stop(struct net_device *dev)
 static const struct net_device_ops i40e_port_netdev_ops = {
 	.ndo_open		= i40e_port_netdev_open,
 	.ndo_stop		= i40e_port_netdev_stop,
+	.ndo_start_xmit		= i40e_port_netdev_start_xmit,
 };
 
 /**
@@ -11034,6 +11043,10 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 		priv = netdev_priv(port_netdev);
 		priv->f = pf;
 		priv->type = I40E_PORT_NETDEV_PF;
+		priv->dst = metadata_dst_alloc(0, METADATA_HW_PORT_MUX,
+					       GFP_KERNEL);
+		priv->dst->u.port_info.lower_dev = vsi->netdev;
+		priv->dst->u.port_info.port_id = I40E_MAIN_VSI_PORT_ID;
 		break;
 	case I40E_PORT_NETDEV_VF:
 		vf = (struct i40e_vf *)f;
@@ -11055,6 +11068,10 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 		priv = netdev_priv(port_netdev);
 		priv->f = vf;
 		priv->type = I40E_PORT_NETDEV_VF;
+		priv->dst = metadata_dst_alloc(0, METADATA_HW_PORT_MUX,
+					       GFP_KERNEL);
+		priv->dst->u.port_info.lower_dev = vsi->netdev;
+		priv->dst->u.port_info.port_id = vf->vf_id;
 		break;
 	default:
 		return -EINVAL;
@@ -11070,6 +11087,7 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 	if (err) {
 		dev_err(&pf->pdev->dev, "register_netdev failed for port netdev: %s\n",
 			port_netdev->name);
+		dst_release((struct dst_entry *)priv->dst);
 		free_netdev(port_netdev);
 		return err;
 	}
@@ -11110,6 +11128,7 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
  **/
 void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 {
+	struct i40e_port_netdev_priv *priv;
 	struct i40e_pf *pf;
 	struct i40e_vf *vf;
 	struct i40e_vsi *vsi;
@@ -11123,6 +11142,8 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 			return;
 		dev_info(&pf->pdev->dev, "Freeing PF Port representor %s\n",
 			 pf->port_netdev->name);
+		priv = netdev_priv(pf->port_netdev);
+		dst_release((struct dst_entry *)priv->dst);
 		unregister_netdev(pf->port_netdev);
 		free_netdev(pf->port_netdev);
 		pf->port_netdev = NULL;
@@ -11140,6 +11161,8 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 			return;
 		dev_info(&pf->pdev->dev, "Freeing VF Port representor %s\n",
 			 vf->port_netdev->name);
+		priv = netdev_priv(vf->port_netdev);
+		dst_release((struct dst_entry *)priv->dst);
 		unregister_netdev(vf->port_netdev);
 		free_netdev(vf->port_netdev);
 		vf->port_netdev = NULL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index ebffca0..86d2510 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1302,20 +1302,64 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_handle_lpbk_skb - Update skb->dev of a loopback frame
+ * @rx_ring: rx ring in play
+ * @skb: packet to send up
+ **/
+static void i40e_handle_lpbk_skb(struct i40e_ring *rx_ring, struct sk_buff *skb)
+{
+	struct i40e_q_vector *q_vector = rx_ring->q_vector;
+	struct i40e_pf *pf = rx_ring->vsi->back;
+	struct sk_buff *nskb;
+	struct i40e_vf *vf;
+	struct ethhdr *eth;
+	int vf_id;
+
+	if ((skb->pkt_type != PACKET_BROADCAST) &&
+	    (skb->pkt_type != PACKET_MULTICAST) &&
+	    (skb->pkt_type != PACKET_OTHERHOST))
+		return;
+
+	eth = (struct ethhdr *)skb_mac_header(skb);
+
+	/* If a loopback packet is received in switchdev mode, clone the skb
+	 * and pass it to the corresponding port netdev based on the source MAC.
+	 */
+	for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
+		vf = &pf->vf[vf_id];
+		if (ether_addr_equal(eth->h_source,
+				     vf->default_lan_addr.addr)) {
+			nskb = skb_clone(skb, GFP_ATOMIC);
+			if (!nskb)
+				break;
+			nskb->offload_fwd_mark = 1;
+			nskb->dev = vf->port_netdev;
+			napi_gro_receive(&q_vector->napi, nskb);
+			break;
+		}
+	}
+}
+
+/**
  * i40e_receive_skb - Send a completed packet up the stack
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
 
 	if ((rx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    (vlan_tag & VLAN_VID_MASK))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
+	if ((pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV) && lpbk)
+		i40e_handle_lpbk_skb(rx_ring, skb);
+
 	napi_gro_receive(&q_vector->napi, skb);
 }
 
@@ -1528,6 +1572,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
  * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being populated
  * @rx_ptype: the packet type decoded by hardware
+ * @lpbk: is it a loopback frame?
  *
  * This function checks the ring, descriptor, and packet information in
  * order to populate the hash, checksum, VLAN, protocol, and
@@ -1536,7 +1581,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
 static inline
 void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 			     union i40e_rx_desc *rx_desc, struct sk_buff *skb,
-			     u8 rx_ptype)
+			     u8 rx_ptype, bool *lpbk)
 {
 	u64 qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 	u32 rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
@@ -1545,6 +1590,9 @@ void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 	u32 tsyn = (rx_status & I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
 		   I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT;
 
+	*lpbk = !!((rx_status & I40E_RXD_QW1_STATUS_LPBK_MASK) >>
+		I40E_RXD_QW1_STATUS_LPBK_SHIFT);
+
 	if (unlikely(tsynvalid))
 		i40e_ptp_rx_hwtstamp(rx_ring->vsi->back, skb, tsyn);
 
@@ -1898,6 +1946,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		u16 vlan_tag;
 		u8 rx_ptype;
 		u64 qword;
+		bool lpbk;
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
@@ -1970,12 +2019,12 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			   I40E_RXD_QW1_PTYPE_SHIFT;
 
 		/* populate checksum, VLAN, and protocol */
-		i40e_process_skb_fields(rx_ring, rx_desc, skb, rx_ptype);
+		i40e_process_skb_fields(rx_ring, rx_desc, skb, rx_ptype, &lpbk);
 
 		vlan_tag = (qword & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)) ?
 			   le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1) : 0;
 
-		i40e_receive_skb(rx_ring, skb, vlan_tag);
+		i40e_receive_skb(rx_ring, skb, vlan_tag, lpbk);
 		skb = NULL;
 
 		/* update budget accounting */
@@ -3037,6 +3086,58 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 }
 
 /**
+ * i40e_tvsi - set up the target vsi in TX context descriptor
+ * @skb:     send buffer
+ * @tx_ring:  ptr to the target vsi
+ * @cd_type_cmd_tso_mss: Quad Word 1
+ *
+ * Returns 0 on success, -EINVAL on error
+ **/
+static int i40e_tvsi(struct sk_buff *skb, struct i40e_ring *tx_ring,
+		     u64 *cd_type_cmd_tso_mss)
+{
+	struct metadata_dst *md_dst = skb_metadata_dst(skb);
+	struct i40e_pf *pf;
+	struct i40e_vsi *t_vsi = NULL;
+	struct i40e_vf *t_vf;
+	u64 cd_cmd, cd_tvsi;
+	u32 port_id;
+
+	/* If skb metadata dst points to a port id, do a directed transmit to
+	 * that VSI. TSO is mutually exclusive with this option. So TSO is not
+	 * enabled when doing a directed transmit.
+	 */
+	if (!md_dst || (md_dst->type != METADATA_HW_PORT_MUX))
+		return 0;
+
+	port_id = md_dst->u.port_info.port_id;
+
+	pf = tx_ring->vsi->back;
+	if ((port_id >= pf->num_alloc_vfs) &&
+	    (port_id != I40E_MAIN_VSI_PORT_ID)) {
+		WARN_ONCE(1, "Unexpected port_id: %d num_vfs:%d\n",
+			  md_dst->u.port_info.port_id, pf->num_alloc_vfs);
+		return -EINVAL;
+	}
+
+	if (port_id == I40E_MAIN_VSI_PORT_ID) {
+		t_vsi = pf->vsi[pf->lan_vsi];
+	} else {
+		t_vf = &pf->vf[port_id];
+		t_vsi = pf->vsi[t_vf->lan_vsi_idx];
+	}
+
+	cd_cmd = I40E_TX_CTX_DESC_SWTCH_VSI;
+	cd_tvsi = t_vsi->id;
+	cd_tvsi = (cd_tvsi << I40E_TXD_CTX_QW1_VSI_SHIFT) &
+		  I40E_TXD_CTX_QW1_VSI_MASK;
+	*cd_type_cmd_tso_mss |= (cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
+				 cd_tvsi;
+
+	return 0;
+}
+
+/**
  * i40e_xmit_frame_ring - Sends buffer on Tx ring
  * @skb:     send buffer
  * @tx_ring: ring to send buffer on
@@ -3101,6 +3202,8 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
 	tso = i40e_tso(first, &hdr_len, &cd_type_cmd_tso_mss);
+	if (!tso)
+		tso = i40e_tvsi(skb, tx_ring, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
@@ -3164,3 +3267,40 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	return i40e_xmit_frame_ring(skb, tx_ring);
 }
+
+/**
+ * i40e_port_netdev_start_xmit
+ * @skb:    send buffer
+ * @netdev: network interface device structure
+ *
+ * Sets skb->dev to PF netdev, and port id in the skb->dst and requeues
+ * skb via dev_queue_xmit()
+ **/
+netdev_tx_t i40e_port_netdev_start_xmit(struct sk_buff *skb,
+					struct net_device *netdev)
+{
+	struct i40e_port_netdev_priv *priv = netdev_priv(netdev);
+	struct i40e_vsi *vsi;
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		pf = vf->pf;
+		break;
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)priv->f;
+		break;
+	default:
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	vsi = pf->vsi[pf->lan_vsi];
+	dst_hold(&priv->dst->dst);
+	skb_dst_set(skb, &priv->dst->dst);
+	skb->dev = vsi->netdev;
+
+	return dev_queue_xmit(skb);
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index d6609de..715de92 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -392,6 +392,8 @@ struct i40e_ring_container {
 
 bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+netdev_tx_t i40e_port_netdev_start_xmit(struct sk_buff *skb,
+					struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
 int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9200f2d..08364a4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -729,6 +729,9 @@ enum i40e_rx_desc_status_bits {
 #define I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT  I40E_RX_DESC_STATUS_TSYNVALID_SHIFT
 #define I40E_RXD_QW1_STATUS_TSYNVALID_MASK \
 				    BIT_ULL(I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
+#define I40E_RXD_QW1_STATUS_LPBK_SHIFT  I40E_RX_DESC_STATUS_LPBK_SHIFT
+#define I40E_RXD_QW1_STATUS_LPBK_MASK \
+				BIT_ULL(I40E_RXD_QW1_STATUS_LPBK_SHIFT)
 
 enum i40e_rx_desc_fltstat_values {
 	I40E_RX_DESC_FLTSTAT_NO_DATA	= 0,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7c2e7b0..f8d25cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1806,8 +1806,10 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	if (i40e_vsi_start_rings(pf->vsi[vf->lan_vsi_idx]))
 		aq_ret = I40E_ERR_TIMEOUT;
 
-	if ((aq_ret == 0) && vf->port_netdev)
+	if ((aq_ret == 0) && vf->port_netdev) {
 		netif_carrier_on(vf->port_netdev);
+		netif_tx_start_all_queues(vf->port_netdev);
+	}
 
 error_param:
 	/* send the response to the VF */
@@ -1848,8 +1850,10 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	i40e_vsi_stop_rings(pf->vsi[vf->lan_vsi_idx]);
 
-	if ((aq_ret == 0) && vf->port_netdev)
+	if ((aq_ret == 0) && vf->port_netdev) {
+		netif_tx_stop_all_queues(vf->port_netdev);
 		netif_carrier_off(vf->port_netdev);
+	}
 
 error_param:
 	/* send the response to the VF */
-- 
1.8.3.1
