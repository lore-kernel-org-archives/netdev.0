From: Ingo Molnar <mingo@elte.hu>
Subject: [PATCH, REVERT] Re: [forcedeth bug] Re: [GIT] Networking
Date: Fri, 5 Aug 2011 12:16:25 +0200
Message-ID: <20110805101625.GA11502@elte.hu>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
 <20110801151308.GA31256@elte.hu>
 <20110804215354.GA7056@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39383 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab1HEKRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 06:17:36 -0400
Content-Disposition: inline
In-Reply-To: <20110804215354.GA7056@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> >  0891b0e08937: forcedeth: fix vlans
> 
> Hm, forcedeth is still giving me trouble even on latest -git that has 
> the above fix included.
> 
> The symptom is a stuck interface, no packets in. There's a frame 
> error RX packet:
> 
>  [root@mercury ~]# ifconfig eth0
>  eth0      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12  
>            inet addr:10.0.1.13  Bcast:10.0.1.255  Mask:255.255.255.0
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:0 errors:1 dropped:0 overruns:0 frame:1
>            TX packets:531 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:1000 
>            RX bytes:0 (0.0 b)  TX bytes:34112 (33.3 KiB)
>            Interrupt:35 
> 
> Weirdly enough a defconfig x86 bootup works just fine - it's certain 
> .config combinations that trigger the bug. I've attached such a 
> config.
> 
> Note that at least once i've observed a seemingly good kernel going 
> 'bad' after a couple of minutes uptime. I've also observed 
> intermittent behavior - apparent lost packets and a laggy network.
> 
> I have done 3 failed attempts to bisect it any further - i got to the 
> commit that got fixed by:
> 
>   0891b0e08937: forcedeth: fix vlans
> 
> ... but that's something we already knew.
> 
> Let me know if there's any data i can provide to help debug this 
> problem.

I have reverted the two forcedeth commits:

  0891b0e08937: forcedeth: fix vlans
  3326c784c9f4: forcedeth: do vlan cleanup

and also reverted two vlan commits that the pre-cleanup driver 
depended on:

  ffcf9b767293: vlan: kill vlan_gro_frags and vlan_gro_receive
  7890a5b9cbfd: vlan: kill ndo_vlan_rx_register

and this finally gave me a working forcedeth driver. I've attached 
the working revert below.

Thanks,

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e55df30..537b695 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -820,6 +820,9 @@ struct fe_priv {
 	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
 
+	/* vlan fields */
+	struct vlan_group *vlangrp;
+
 	/* msi/msi-x fields */
 	u32 msi_flags;
 	struct msix_entry msi_x_entry[NV_MSI_X_MAX_VECTORS];
@@ -2763,20 +2766,17 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			skb->protocol = eth_type_trans(skb, dev);
 			prefetch(skb->data);
 
-			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-
-			/*
-			 * There's need to check for NETIF_F_HW_VLAN_RX here.
-			 * Even if vlan rx accel is disabled,
-			 * NV_RX3_VLAN_TAG_PRESENT is pseudo randomly set.
-			 */
-			if (dev->features & NETIF_F_HW_VLAN_RX &&
-			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
-
-				__vlan_hwaccel_put_tag(skb, vid);
+			if (likely(!np->vlangrp)) {
+				napi_gro_receive(&np->napi, skb);
+			} else {
+				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
+				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
+					vlan_gro_receive(&np->napi, np->vlangrp,
+							 vlanflags & NV_RX3_VLAN_TAG_MASK, skb);
+				} else {
+					napi_gro_receive(&np->napi, skb);
+				}
 			}
-			napi_gro_receive(&np->napi, skb);
 
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
@@ -4484,27 +4484,6 @@ static u32 nv_fix_features(struct net_device *dev, u32 features)
 	return features;
 }
 
-static void nv_vlan_mode(struct net_device *dev, u32 features)
-{
-	struct fe_priv *np = get_nvpriv(dev);
-
-	spin_lock_irq(&np->lock);
-
-	if (features & NETIF_F_HW_VLAN_RX)
-		np->txrxctl_bits |= NVREG_TXRXCTL_VLANSTRIP;
-	else
-		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANSTRIP;
-
-	if (features & NETIF_F_HW_VLAN_TX)
-		np->txrxctl_bits |= NVREG_TXRXCTL_VLANINS;
-	else
-		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANINS;
-
-	writel(np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-
-	spin_unlock_irq(&np->lock);
-}
-
 static int nv_set_features(struct net_device *dev, u32 features)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -4525,9 +4504,6 @@ static int nv_set_features(struct net_device *dev, u32 features)
 		spin_unlock_irq(&np->lock);
 	}
 
-	if (changed & (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX))
-		nv_vlan_mode(dev, features);
-
 	return 0;
 }
 
@@ -4903,6 +4879,29 @@ static const struct ethtool_ops ops = {
 	.self_test = nv_self_test,
 };
 
+static void nv_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+
+	spin_lock_irq(&np->lock);
+
+	/* save vlan group */
+	np->vlangrp = grp;
+
+	if (grp) {
+		/* enable vlan on MAC */
+		np->txrxctl_bits |= NVREG_TXRXCTL_VLANSTRIP | NVREG_TXRXCTL_VLANINS;
+	} else {
+		/* disable vlan on MAC */
+		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANSTRIP;
+		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANINS;
+	}
+
+	writel(np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+
+	spin_unlock_irq(&np->lock);
+}
+
 /* The mgmt unit and driver use a semaphore to access the phy during init */
 static int nv_mgmt_acquire_sema(struct net_device *dev)
 {
@@ -5209,6 +5208,7 @@ static const struct net_device_ops nv_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_multicast_list	= nv_set_multicast,
+	.ndo_vlan_rx_register	= nv_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
@@ -5226,6 +5226,7 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_multicast_list	= nv_set_multicast,
+	.ndo_vlan_rx_register	= nv_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
@@ -5338,16 +5339,15 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
 		dev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_RXCSUM;
+		dev->features |= dev->hw_features;
 	}
 
 	np->vlanctl_bits = 0;
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
-		dev->hw_features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
+		dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
 	}
 
-	dev->features |= dev->hw_features;
-
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
 	if ((id->driver_data & DEV_HAS_PAUSEFRAME_TX_V1) ||
 	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V2) ||
@@ -5615,8 +5615,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out_error;
 	}
 
-	nv_vlan_mode(dev, dev->features);
-
 	netif_carrier_off(dev);
 
 	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 44da482..f2a4892 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -108,6 +108,12 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
+extern gro_result_t
+vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		 unsigned int vlan_tci, struct sk_buff *skb);
+extern gro_result_t
+vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+	       unsigned int vlan_tci);
 
 #else
 static inline struct net_device *
@@ -139,6 +145,20 @@ static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	return skb;
 }
+
+static inline gro_result_t
+vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		 unsigned int vlan_tci, struct sk_buff *skb)
+{
+	return GRO_DROP;
+}
+
+static inline gro_result_t
+vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+	       unsigned int vlan_tci)
+{
+	return GRO_DROP;
+}
 #endif
 
 /**
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..4537bff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -768,6 +768,12 @@ struct netdev_tc_txq {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
+ * void (*ndo_vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
+ *	If device support VLAN receive acceleration
+ *	(ie. dev->features & NETIF_F_HW_VLAN_RX), then this function is called
+ *	when vlan groups for the device changes.  Note: grp is NULL
+ *	if no vlan's groups are being used.
+ *
  * void (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
  *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
  *	this function is called when a VLAN id is registered.
@@ -886,6 +892,8 @@ struct net_device_ops {
 						     struct rtnl_link_stats64 *storage);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
+	void			(*ndo_vlan_rx_register)(struct net_device *dev,
+						        struct vlan_group *grp);
 	void			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
 						       unsigned short vid);
 	void			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8970ba1..d24c464 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -134,6 +134,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		vlan_gvrp_uninit_applicant(real_dev);
 
 		rcu_assign_pointer(real_dev->vlgrp, NULL);
+		if (ops->ndo_vlan_rx_register)
+			ops->ndo_vlan_rx_register(real_dev, NULL);
 
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
@@ -205,6 +207,8 @@ int register_vlan_dev(struct net_device *dev)
 	grp->nr_vlans++;
 
 	if (ngrp) {
+		if (ops->ndo_vlan_rx_register && (real_dev->features & NETIF_F_HW_VLAN_RX))
+			ops->ndo_vlan_rx_register(real_dev, ngrp);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 5f27f8e..68b04ea 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -96,6 +96,22 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
+gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+			      unsigned int vlan_tci, struct sk_buff *skb)
+{
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
+	return napi_gro_receive(napi, skb);
+}
+EXPORT_SYMBOL(vlan_gro_receive);
+
+gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+			    unsigned int vlan_tci)
+{
+	__vlan_hwaccel_put_tag(napi->skb, vlan_tci);
+	return napi_gro_frags(napi);
+}
+EXPORT_SYMBOL(vlan_gro_frags);
+
 static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
 	if (skb_cow(skb, skb_headroom(skb)) < 0)
