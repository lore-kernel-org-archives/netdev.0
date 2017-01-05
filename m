From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 5/6] i40e: Add TX and RX support in switchdev
 mode.
Date: Thu, 5 Jan 2017 13:56:56 +0100
Message-ID: <20170105125656.GB2211@nanopsycho>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
 <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34460 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbdAEM5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 07:57:00 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so58046123wmi.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 04:56:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 03, 2017 at 07:07:53PM CET, sridhar.samudrala@intel.com wrote:
>In switchdev mode, broadcast filter is not enabled on VFs. The broadcasts and
>unknown frames from VFs are received by the PF and passed to corresponding VF
>port representator netdev.
>A host based switching entity like a linux bridge or OVS redirects these frames
>to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
>directed transmits to the corresponding VFs. To enable directed transmit, skb
>metadata dst is used to pass the VF id and the frame is requeued to call the PFs
>transmit routine.
>
>Small script to demonstrate inter VF pings in switchdev mode.
>PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1
>
># rmmod i40e; modprobe i40e
># devlink dev eswitch set pci/0000:05:00.0 mode switchdev
># echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
># ip link set enp5s0f0 vf 0 mac 00:11:22:33:44:55
># ip link set enp5s0f0 vf 1 mac 00:11:22:33:44:56
># rmmod i40evf; modprobe i40evf
>
>/* Create 2 namespaces and move the VFs to the corresponding ns. */
># ip netns add ns0
># ip link set enp5s2 netns ns0
># ip netns exec ns0 ip addr add 192.168.1.10/24 dev enp5s2
># ip netns exec ns0 ip link set enp5s2 up
># ip netns add ns1
># ip link set enp5s2f1 netns ns1
># ip netns exec ns1 ip addr add 192.168.1.11/24 dev enp5s2f1
># ip netns exec ns1 ip link set enp5s2f1 up
>
>/* bring up pf and vfpr netdevs */
># ip link set enp5s0f0 up
># ip link set enp5s0f0-vf0 up
># ip link set enp5s0f0-vf1 up
>
>/* Create a linux bridge and add vfpr netdevs to it. */
># ip link add vfpr-br type bridge
># ip link set enp5s0f0-vf0 master vfpr-br
># ip link set enp5s0f0-vf1 master vfpr-br
># ip addr add 192.168.1.1/24 dev vfpr-br
># ip link set vfpr-br up
>
># ip netns exec ns0 ping -c3 192.168.1.11
># ip netns exec ns1 ping -c3 192.168.1.10
>
>Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

[...]

>diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>index 352cf7c..b46ddaa 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>@@ -1176,16 +1176,37 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
>  * @rx_ring:  rx ring in play
>  * @skb: packet to send up
>  * @vlan_tag: vlan tag for packet
>+ * @lpbk: is it a loopback frame?
>  **/
> static void i40e_receive_skb(struct i40e_ring *rx_ring,
>-			     struct sk_buff *skb, u16 vlan_tag)
>+			     struct sk_buff *skb, u16 vlan_tag, bool lpbk)
> {
> 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
>+	struct i40e_pf *pf = rx_ring->vsi->back;
>+	struct i40e_vf *vf;
>+	struct ethhdr *eth;
>+	int vf_id;
> 
> 	if ((rx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
> 	    (vlan_tag & VLAN_VID_MASK))
> 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
> 
>+	if ((pf->eswitch_mode == DEVLINK_ESWITCH_MODE_LEGACY) || !lpbk)
>+		goto gro_receive;
>+
>+	/* If a loopback packet is received from a VF in switchdev mode, pass the
>+	 * frame to the corresponding VFPR netdev based on the source MAC in the frame.
>+	 */
>+	eth = (struct ethhdr *)skb_mac_header(skb);
>+	for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
>+		vf = &pf->vf[vf_id];
>+		if (ether_addr_equal(eth->h_source, vf->default_lan_addr.addr)) {
>+			skb->dev = vf->vfpr_netdev;

This sucks :( Is't there any identification coming from rx ring that
would tell you what vf this is? To match vrpr according to a single MAC
address seems a bit awkward. What if there is a macvlan configured
on the VF?



>+			break;
>+		}
>+	}
>+
>+gro_receive:
> 	napi_gro_receive(&q_vector->napi, skb);
> }
> 

[...]

>@@ -2998,3 +3064,19 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> 
> 	return i40e_xmit_frame_ring(skb, tx_ring);
> }
>+
>+netdev_tx_t i40e_vfpr_netdev_start_xmit(struct sk_buff *skb,
>+				        struct net_device *dev)
>+{
>+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
>+	struct i40e_vf *vf = priv->vf;
>+	struct i40e_pf *pf = vf->pf;
>+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
>+
>+	skb_dst_drop(skb);
>+	dst_hold(&priv->vfpr_dst->dst);
>+	skb_dst_set(skb, &priv->vfpr_dst->dst);
>+	skb->dev = vsi->netdev;

This dst dance seems a bit odd to me. Why don't you just call
i40e_xmit_frame_ring with an extra arg holding the needed metadata?


>+
>+	return dev_queue_xmit(skb);
>+}
>diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
>index e065321..850723f 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
>+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
>@@ -366,6 +366,7 @@ struct i40e_ring_container {
> 
> bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
> netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
>+netdev_tx_t i40e_vfpr_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev);
> void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
> void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
> int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
>diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
>index edc0abd..c136cc9 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
>+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
>@@ -728,6 +728,9 @@ enum i40e_rx_desc_status_bits {
> #define I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT  I40E_RX_DESC_STATUS_TSYNVALID_SHIFT
> #define I40E_RXD_QW1_STATUS_TSYNVALID_MASK \
> 				    BIT_ULL(I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
>+#define I40E_RXD_QW1_STATUS_LPBK_SHIFT  I40E_RX_DESC_STATUS_LPBK_SHIFT
>+#define I40E_RXD_QW1_STATUS_LPBK_MASK \
>+				BIT_ULL(I40E_RXD_QW1_STATUS_LPBK_SHIFT)
> 
> enum i40e_rx_desc_fltstat_values {
> 	I40E_RX_DESC_FLTSTAT_NO_DATA	= 0,
>diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>index 0c8687d..f0860ef 100644
>--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>@@ -1062,6 +1062,7 @@ static int i40e_vfpr_netdev_stop(struct net_device *dev)
> static const struct net_device_ops i40e_vfpr_netdev_ops = {
> 	.ndo_open       	= i40e_vfpr_netdev_open,
> 	.ndo_stop       	= i40e_vfpr_netdev_stop,
>+	.ndo_start_xmit		= i40e_vfpr_netdev_start_xmit,
> };
> 
> /**
>@@ -1121,16 +1122,22 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
> 
> 	priv = netdev_priv(vfpr_netdev);
> 	priv->vf = &(pf->vf[vf_num]);
>+	priv->vfpr_dst = metadata_dst_alloc(0, METADATA_HW_PORT_MUX, GFP_KERNEL);

I'm missing a patch here. In net-next, metadata_dst_alloc has 2 args.
