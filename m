From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 3/3] net: consolidate 8021q tagging
Date: Sat, 30 Oct 2010 17:22:42 -0700
Message-ID: <20101031002242.8691.38060.stgit@jf-dev1-dcblab>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2888 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463Ab0JaAY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 20:24:57 -0400
In-Reply-To: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that VLAN packets are tagged in dev_hard_start_xmit()
at the bottom of the stack we no longer need to tag them
in the 8021Q module (Except in the !VLAN_FLAG_REORDER_HDR
case).

This allows the accel path and non accel paths to be consolidated.
Here the vlan_tci in the skb is always set and we allow the
stack to add the actual tag in dev_hard_start_xmit().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan.h     |    4 --
 net/8021q/vlan_dev.c |  105 +++-----------------------------------------------
 net/8021q/vlanproc.c |    4 --
 3 files changed, 7 insertions(+), 106 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index db01b31..4625ba6 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -45,8 +45,6 @@ struct vlan_rx_stats {
  *	@real_dev: underlying netdevice
  *	@real_dev_addr: address of underlying netdevice
  *	@dent: proc dir entry
- *	@cnt_inc_headroom_on_tx: statistic - number of skb expansions on TX
- *	@cnt_encap_on_xmit: statistic - number of skb encapsulations on TX
  *	@vlan_rx_stats: ptr to percpu rx stats
  */
 struct vlan_dev_info {
@@ -62,8 +60,6 @@ struct vlan_dev_info {
 	unsigned char				real_dev_addr[ETH_ALEN];
 
 	struct proc_dir_entry			*dent;
-	unsigned long				cnt_inc_headroom_on_tx;
-	unsigned long				cnt_encap_on_xmit;
 	struct vlan_rx_stats __percpu		*vlan_rx_stats;
 };
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index afb03c5..f3c9552 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -323,24 +323,12 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 */
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
 	    vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		unsigned int orig_headroom = skb_headroom(skb);
 		u16 vlan_tci;
-
-		vlan_dev_info(dev)->cnt_encap_on_xmit++;
-
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-		skb = __vlan_put_tag(skb, vlan_tci);
-		if (!skb) {
-			txq->tx_dropped++;
-			return NETDEV_TX_OK;
-		}
-
-		if (orig_headroom < VLAN_HLEN)
-			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
+		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
-
 	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
 	len = skb->len;
 	ret = dev_queue_xmit(skb);
@@ -354,32 +342,6 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
-static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
-						    struct net_device *dev)
-{
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-	u16 vlan_tci;
-	unsigned int len;
-	int ret;
-
-	vlan_tci = vlan_dev_info(dev)->vlan_id;
-	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
-
-	skb->dev = vlan_dev_info(dev)->real_dev;
-	len = skb->len;
-	ret = dev_queue_xmit(skb);
-
-	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
-	} else
-		txq->tx_dropped++;
-
-	return ret;
-}
-
 static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct net_device *rdev = vlan_dev_info(dev)->real_dev;
@@ -716,8 +678,7 @@ static const struct header_ops vlan_header_ops = {
 	.parse	 = eth_header_parse,
 };
 
-static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_ops,
-		    vlan_netdev_ops_sq, vlan_netdev_accel_ops_sq;
+static const struct net_device_ops vlan_netdev_ops, vlan_netdev_ops_sq;
 
 static int vlan_dev_init(struct net_device *dev)
 {
@@ -752,19 +713,16 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops = &vlan_netdev_accel_ops_sq;
-		else
-			dev->netdev_ops = &vlan_netdev_accel_ops;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops = &vlan_netdev_ops_sq;
-		else
-			dev->netdev_ops = &vlan_netdev_ops;
 	}
 
+	if (real_dev->netdev_ops->ndo_select_queue)
+		dev->netdev_ops = &vlan_netdev_ops_sq;
+	else
+		dev->netdev_ops = &vlan_netdev_ops;
+
 	if (is_vlan_dev(real_dev))
 		subclass = 1;
 
@@ -905,30 +863,6 @@ static const struct net_device_ops vlan_netdev_ops = {
 #endif
 };
 
-static const struct net_device_ops vlan_netdev_accel_ops = {
-	.ndo_change_mtu		= vlan_dev_change_mtu,
-	.ndo_init		= vlan_dev_init,
-	.ndo_uninit		= vlan_dev_uninit,
-	.ndo_open		= vlan_dev_open,
-	.ndo_stop		= vlan_dev_stop,
-	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		= vlan_dev_ioctl,
-	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats64	= vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
-#endif
-};
-
 static const struct net_device_ops vlan_netdev_ops_sq = {
 	.ndo_select_queue	= vlan_dev_select_queue,
 	.ndo_change_mtu		= vlan_dev_change_mtu,
@@ -954,31 +888,6 @@ static const struct net_device_ops vlan_netdev_ops_sq = {
 #endif
 };
 
-static const struct net_device_ops vlan_netdev_accel_ops_sq = {
-	.ndo_select_queue	= vlan_dev_select_queue,
-	.ndo_change_mtu		= vlan_dev_change_mtu,
-	.ndo_init		= vlan_dev_init,
-	.ndo_uninit		= vlan_dev_uninit,
-	.ndo_open		= vlan_dev_open,
-	.ndo_stop		= vlan_dev_stop,
-	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		= vlan_dev_ioctl,
-	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats64	= vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
-#endif
-};
-
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 80e280f..8a64db1 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -299,10 +299,6 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	seq_puts(seq, "\n");
 	seq_printf(seq, fmt64, "total frames transmitted", stats->tx_packets);
 	seq_printf(seq, fmt64, "total bytes transmitted", stats->tx_bytes);
-	seq_printf(seq, fmt, "total headroom inc",
-		   dev_info->cnt_inc_headroom_on_tx);
-	seq_printf(seq, fmt, "total encap on xmit",
-		   dev_info->cnt_encap_on_xmit);
 	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
 	/* now show all PRIORITY mappings relating to this VLAN */
 	seq_printf(seq, "\nINGRESS priority mappings: "

