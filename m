From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/6] vlan: rename vlan_dev_info to vlan_dev_priv
Date: Thu,  8 Dec 2011 15:11:15 +0100
Message-ID: <1323353480-1900-2-git-send-email-jpirko@redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab1LHOLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:35 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As this structure is priv, name it approprietely. Also for pointer to it
use name "vlan".

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h  |    2 +-
 net/8021q/vlan.c         |   24 +++++++-------
 net/8021q/vlan.h         |    8 ++--
 net/8021q/vlan_core.c    |    8 ++--
 net/8021q/vlan_dev.c     |   72 +++++++++++++++++++++++-----------------------
 net/8021q/vlan_gvrp.c    |    4 +-
 net/8021q/vlan_netlink.c |   10 +++---
 net/8021q/vlanproc.c     |   42 +++++++++++++-------------
 8 files changed, 85 insertions(+), 85 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 070ac50..31d7c97 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -386,7 +386,7 @@ struct vlan_ioctl_args {
 		unsigned int skb_priority;
 		unsigned int name_type;
 		unsigned int bind_type;
-		unsigned int flag; /* Matches vlan_dev_info flags */
+		unsigned int flag; /* Matches vlan_dev_priv flags */
         } u;
 
 	short vlan_qos;   
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5471628..e075625 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -99,7 +99,7 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct vlan_group *grp;
@@ -167,7 +167,7 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 
 int register_vlan_dev(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	u16 vlan_id = vlan->vlan_id;
@@ -192,7 +192,7 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_applicant;
 
-	/* Account for reference in struct vlan_dev_info */
+	/* Account for reference in struct vlan_dev_priv */
 	dev_hold(real_dev);
 
 	netif_stacked_transfer_operstate(real_dev, dev);
@@ -267,7 +267,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
-	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name, vlan_setup);
+	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name, vlan_setup);
 
 	if (new_dev == NULL)
 		return -ENOBUFS;
@@ -278,10 +278,10 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 */
 	new_dev->mtu = real_dev->mtu;
 
-	vlan_dev_info(new_dev)->vlan_id = vlan_id;
-	vlan_dev_info(new_dev)->real_dev = real_dev;
-	vlan_dev_info(new_dev)->dent = NULL;
-	vlan_dev_info(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
+	vlan_dev_priv(new_dev)->vlan_id = vlan_id;
+	vlan_dev_priv(new_dev)->real_dev = real_dev;
+	vlan_dev_priv(new_dev)->dent = NULL;
+	vlan_dev_priv(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
 
 	new_dev->rtnl_link_ops = &vlan_link_ops;
 	err = register_vlan_dev(new_dev);
@@ -298,7 +298,7 @@ out_free_newdev:
 static void vlan_sync_address(struct net_device *dev,
 			      struct net_device *vlandev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(vlandev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
 	/* May be called without an actual change */
 	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
@@ -362,7 +362,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct vlan_group *grp;
 	int i, flgs;
 	struct net_device *vlandev;
-	struct vlan_dev_info *vlan;
+	struct vlan_dev_priv *vlan;
 	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev))
@@ -447,7 +447,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!(flgs & IFF_UP))
 				continue;
 
-			vlan = vlan_dev_info(vlandev);
+			vlan = vlan_dev_priv(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 				dev_change_flags(vlandev, flgs & ~IFF_UP);
 			netif_stacked_transfer_operstate(dev, vlandev);
@@ -465,7 +465,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (flgs & IFF_UP)
 				continue;
 
-			vlan = vlan_dev_info(vlandev);
+			vlan = vlan_dev_priv(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 				dev_change_flags(vlandev, flgs | IFF_UP);
 			netif_stacked_transfer_operstate(dev, vlandev);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 9fd45f3..d3c4ea4 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -41,7 +41,7 @@ struct vlan_pcpu_stats {
 };
 
 /**
- *	struct vlan_dev_info - VLAN private device data
+ *	struct vlan_dev_priv - VLAN private device data
  *	@nr_ingress_mappings: number of ingress priority mappings
  *	@ingress_priority_map: ingress priority mappings
  *	@nr_egress_mappings: number of egress priority mappings
@@ -53,7 +53,7 @@ struct vlan_pcpu_stats {
  *	@dent: proc dir entry
  *	@vlan_pcpu_stats: ptr to percpu rx stats
  */
-struct vlan_dev_info {
+struct vlan_dev_priv {
 	unsigned int				nr_ingress_mappings;
 	u32					ingress_priority_map[8];
 	unsigned int				nr_egress_mappings;
@@ -69,7 +69,7 @@ struct vlan_dev_info {
 	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
 };
 
-static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
+static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
 {
 	return netdev_priv(dev);
 }
@@ -121,7 +121,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
 static inline u32 vlan_get_ingress_priority(struct net_device *dev,
 					    u16 vlan_tci)
 {
-	struct vlan_dev_info *vip = vlan_dev_info(dev);
+	struct vlan_dev_priv *vip = vlan_dev_priv(dev);
 
 	return vip->ingress_priority_map[(vlan_tci >> VLAN_PRIO_SHIFT) & 0x7];
 }
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 9c95e8e..85241f0 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -36,7 +36,7 @@ bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
 			skb->pkt_type = PACKET_HOST;
 	}
 
-	if (!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan_dev_priv(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
 		unsigned int offset = skb->data - skb_mac_header(skb);
 
 		/*
@@ -55,7 +55,7 @@ bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
 	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
-	rx_stats = this_cpu_ptr(vlan_dev_info(vlan_dev)->vlan_pcpu_stats);
+	rx_stats = this_cpu_ptr(vlan_dev_priv(vlan_dev)->vlan_pcpu_stats);
 
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
@@ -90,13 +90,13 @@ EXPORT_SYMBOL(__vlan_find_dev_deep);
 
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
-	return vlan_dev_info(dev)->real_dev;
+	return vlan_dev_priv(dev)->real_dev;
 }
 EXPORT_SYMBOL(vlan_dev_real_dev);
 
 u16 vlan_dev_vlan_id(const struct net_device *dev)
 {
-	return vlan_dev_info(dev)->vlan_id;
+	return vlan_dev_priv(dev)->vlan_id;
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2b5fcde..3b4db82 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -72,7 +72,7 @@ vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vlan_priority_tci_mapping *mp;
 
-	mp = vlan_dev_info(dev)->egress_priority_map[(skb->priority & 0xF)];
+	mp = vlan_dev_priv(dev)->egress_priority_map[(skb->priority & 0xF)];
 	while (mp) {
 		if (mp->priority == skb->priority) {
 			return mp->vlan_qos; /* This should already be shifted
@@ -103,10 +103,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	u16 vlan_tci = 0;
 	int rc;
 
-	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 
-		vlan_tci = vlan_dev_info(dev)->vlan_id;
+		vlan_tci = vlan_dev_priv(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
@@ -129,7 +129,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		saddr = dev->dev_addr;
 
 	/* Now make the underlying real hard header */
-	dev = vlan_dev_info(dev)->real_dev;
+	dev = vlan_dev_priv(dev)->real_dev;
 	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
 	if (rc > 0)
 		rc += vhdrlen;
@@ -149,27 +149,27 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
-	    vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
+	    vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
-		vlan_tci = vlan_dev_info(dev)->vlan_id;
+		vlan_tci = vlan_dev_priv(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
-	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
+	skb_set_dev(skb, vlan_dev_priv(dev)->real_dev);
 	len = skb->len;
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		struct vlan_pcpu_stats *stats;
 
-		stats = this_cpu_ptr(vlan_dev_info(dev)->vlan_pcpu_stats);
+		stats = this_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats);
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes += len;
 		u64_stats_update_end(&stats->syncp);
 	} else {
-		this_cpu_inc(vlan_dev_info(dev)->vlan_pcpu_stats->tx_dropped);
+		this_cpu_inc(vlan_dev_priv(dev)->vlan_pcpu_stats->tx_dropped);
 	}
 
 	return ret;
@@ -180,7 +180,7 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 	/* TODO: gotta make sure the underlying layer can handle it,
 	 * maybe an IFF_VLAN_CAPABLE flag for devices?
 	 */
-	if (vlan_dev_info(dev)->real_dev->mtu < new_mtu)
+	if (vlan_dev_priv(dev)->real_dev->mtu < new_mtu)
 		return -ERANGE;
 
 	dev->mtu = new_mtu;
@@ -191,7 +191,7 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, u16 vlan_prio)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 
 	if (vlan->ingress_priority_map[vlan_prio & 0x7] && !skb_prio)
 		vlan->nr_ingress_mappings--;
@@ -204,7 +204,7 @@ void vlan_dev_set_ingress_priority(const struct net_device *dev,
 int vlan_dev_set_egress_priority(const struct net_device *dev,
 				 u32 skb_prio, u16 vlan_prio)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct vlan_priority_tci_mapping *mp = NULL;
 	struct vlan_priority_tci_mapping *np;
 	u32 vlan_qos = (vlan_prio << VLAN_PRIO_SHIFT) & VLAN_PRIO_MASK;
@@ -241,7 +241,7 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 /* Flags are defined in the vlan_flags enum in include/linux/if_vlan.h file. */
 int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	u32 old_flags = vlan->flags;
 
 	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
@@ -261,12 +261,12 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result)
 {
-	strncpy(result, vlan_dev_info(dev)->real_dev->name, 23);
+	strncpy(result, vlan_dev_priv(dev)->real_dev->name, 23);
 }
 
 static int vlan_dev_open(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	int err;
 
@@ -313,7 +313,7 @@ out:
 
 static int vlan_dev_stop(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 
 	dev_mc_unsync(real_dev, dev);
@@ -332,7 +332,7 @@ static int vlan_dev_stop(struct net_device *dev)
 
 static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	struct sockaddr *addr = p;
 	int err;
 
@@ -358,7 +358,7 @@ out:
 
 static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct ifreq ifrr;
 	int err = -EOPNOTSUPP;
@@ -383,7 +383,7 @@ static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int err = 0;
 
@@ -397,7 +397,7 @@ static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
 static int vlan_dev_fcoe_ddp_setup(struct net_device *dev, u16 xid,
 				   struct scatterlist *sgl, unsigned int sgc)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int rc = 0;
 
@@ -409,7 +409,7 @@ static int vlan_dev_fcoe_ddp_setup(struct net_device *dev, u16 xid,
 
 static int vlan_dev_fcoe_ddp_done(struct net_device *dev, u16 xid)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int len = 0;
 
@@ -421,7 +421,7 @@ static int vlan_dev_fcoe_ddp_done(struct net_device *dev, u16 xid)
 
 static int vlan_dev_fcoe_enable(struct net_device *dev)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int rc = -EINVAL;
 
@@ -432,7 +432,7 @@ static int vlan_dev_fcoe_enable(struct net_device *dev)
 
 static int vlan_dev_fcoe_disable(struct net_device *dev)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int rc = -EINVAL;
 
@@ -443,7 +443,7 @@ static int vlan_dev_fcoe_disable(struct net_device *dev)
 
 static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int rc = -EINVAL;
 
@@ -455,7 +455,7 @@ static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
 static int vlan_dev_fcoe_ddp_target(struct net_device *dev, u16 xid,
 				    struct scatterlist *sgl, unsigned int sgc)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	int rc = 0;
 
@@ -468,7 +468,7 @@ static int vlan_dev_fcoe_ddp_target(struct net_device *dev, u16 xid,
 
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 
 	if (dev->flags & IFF_UP) {
 		if (change & IFF_ALLMULTI)
@@ -480,8 +480,8 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 
 static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
 {
-	dev_mc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
-	dev_uc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
+	dev_mc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
+	dev_uc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
 }
 
 /*
@@ -519,7 +519,7 @@ static const struct net_device_ops vlan_netdev_ops;
 
 static int vlan_dev_init(struct net_device *dev)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	int subclass = 0;
 
 	netif_carrier_off(dev);
@@ -568,8 +568,8 @@ static int vlan_dev_init(struct net_device *dev)
 
 	vlan_dev_set_lockdep_class(dev, subclass);
 
-	vlan_dev_info(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
-	if (!vlan_dev_info(dev)->vlan_pcpu_stats)
+	vlan_dev_priv(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
+	if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
 		return -ENOMEM;
 
 	return 0;
@@ -578,7 +578,7 @@ static int vlan_dev_init(struct net_device *dev)
 static void vlan_dev_uninit(struct net_device *dev)
 {
 	struct vlan_priority_tci_mapping *pm;
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	int i;
 
 	free_percpu(vlan->vlan_pcpu_stats);
@@ -594,7 +594,7 @@ static void vlan_dev_uninit(struct net_device *dev)
 static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
 	u32 old_features = features;
 
 	features &= real_dev->vlan_features;
@@ -610,7 +610,7 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 static int vlan_ethtool_get_settings(struct net_device *dev,
 				     struct ethtool_cmd *cmd)
 {
-	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 
 	return __ethtool_get_settings(vlan->real_dev, cmd);
 }
@@ -626,7 +626,7 @@ static void vlan_ethtool_get_drvinfo(struct net_device *dev,
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 
-	if (vlan_dev_info(dev)->vlan_pcpu_stats) {
+	if (vlan_dev_priv(dev)->vlan_pcpu_stats) {
 		struct vlan_pcpu_stats *p;
 		u32 rx_errors = 0, tx_dropped = 0;
 		int i;
@@ -635,7 +635,7 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 			u64 rxpackets, rxbytes, rxmulticast, txpackets, txbytes;
 			unsigned int start;
 
-			p = per_cpu_ptr(vlan_dev_info(dev)->vlan_pcpu_stats, i);
+			p = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
 			do {
 				start = u64_stats_fetch_begin_bh(&p->syncp);
 				rxpackets	= p->rx_packets;
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
index 061cece..6f97553 100644
--- a/net/8021q/vlan_gvrp.c
+++ b/net/8021q/vlan_gvrp.c
@@ -29,7 +29,7 @@ static struct garp_application vlan_gvrp_app __read_mostly = {
 
 int vlan_gvrp_request_join(const struct net_device *dev)
 {
-	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
 	return garp_request_join(vlan->real_dev, &vlan_gvrp_app,
@@ -38,7 +38,7 @@ int vlan_gvrp_request_join(const struct net_device *dev)
 
 void vlan_gvrp_request_leave(const struct net_device *dev)
 {
-	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
 	garp_request_leave(vlan->real_dev, &vlan_gvrp_app,
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 235c219..5071136 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -105,7 +105,7 @@ static int vlan_changelink(struct net_device *dev,
 static int vlan_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
 	int err;
 
@@ -149,7 +149,7 @@ static inline size_t vlan_qos_map_size(unsigned int n)
 
 static size_t vlan_get_size(const struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 
 	return nla_total_size(2) +	/* IFLA_VLAN_ID */
 	       sizeof(struct ifla_vlan_flags) + /* IFLA_VLAN_FLAGS */
@@ -159,14 +159,14 @@ static size_t vlan_get_size(const struct net_device *dev)
 
 static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct vlan_priority_tci_mapping *pm;
 	struct ifla_vlan_flags f;
 	struct ifla_vlan_qos_mapping m;
 	struct nlattr *nest;
 	unsigned int i;
 
-	NLA_PUT_U16(skb, IFLA_VLAN_ID, vlan_dev_info(dev)->vlan_id);
+	NLA_PUT_U16(skb, IFLA_VLAN_ID, vlan_dev_priv(dev)->vlan_id);
 	if (vlan->flags) {
 		f.flags = vlan->flags;
 		f.mask  = ~0;
@@ -218,7 +218,7 @@ struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.kind		= "vlan",
 	.maxtype	= IFLA_VLAN_MAX,
 	.policy		= vlan_policy,
-	.priv_size	= sizeof(struct vlan_dev_info),
+	.priv_size	= sizeof(struct vlan_dev_priv),
 	.setup		= vlan_setup,
 	.validate	= vlan_validate,
 	.newlink	= vlan_newlink,
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index d34b6da..c718fd3 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -168,13 +168,13 @@ err:
 
 int vlan_proc_add_dev(struct net_device *vlandev)
 {
-	struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
+	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 	struct vlan_net *vn = net_generic(dev_net(vlandev), vlan_net_id);
 
-	dev_info->dent =
+	vlan->dent =
 		proc_create_data(vlandev->name, S_IFREG|S_IRUSR|S_IWUSR,
 				 vn->proc_vlan_dir, &vlandev_fops, vlandev);
-	if (!dev_info->dent)
+	if (!vlan->dent)
 		return -ENOBUFS;
 	return 0;
 }
@@ -187,10 +187,10 @@ int vlan_proc_rem_dev(struct net_device *vlandev)
 	struct vlan_net *vn = net_generic(dev_net(vlandev), vlan_net_id);
 
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
-	if (vlan_dev_info(vlandev)->dent) {
-		remove_proc_entry(vlan_dev_info(vlandev)->dent->name,
+	if (vlan_dev_priv(vlandev)->dent) {
+		remove_proc_entry(vlan_dev_priv(vlandev)->dent->name,
 				  vn->proc_vlan_dir);
-		vlan_dev_info(vlandev)->dent = NULL;
+		vlan_dev_priv(vlandev)->dent = NULL;
 	}
 	return 0;
 }
@@ -268,10 +268,10 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 			   nmtype ? nmtype :  "UNKNOWN");
 	} else {
 		const struct net_device *vlandev = v;
-		const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
+		const struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
 		seq_printf(seq, "%-15s| %d  | %s\n",  vlandev->name,
-			   dev_info->vlan_id,    dev_info->real_dev->name);
+			   vlan->vlan_id,    vlan->real_dev->name);
 	}
 	return 0;
 }
@@ -279,7 +279,7 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
-	const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
 	static const char fmt64[] = "%30s %12llu\n";
@@ -291,8 +291,8 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	stats = dev_get_stats(vlandev, &temp);
 	seq_printf(seq,
 		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
-		   vlandev->name, dev_info->vlan_id,
-		   (int)(dev_info->flags & 1), vlandev->priv_flags);
+		   vlandev->name, vlan->vlan_id,
+		   (int)(vlan->flags & 1), vlandev->priv_flags);
 
 	seq_printf(seq, fmt64, "total frames received", stats->rx_packets);
 	seq_printf(seq, fmt64, "total bytes received", stats->rx_bytes);
@@ -300,23 +300,23 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	seq_puts(seq, "\n");
 	seq_printf(seq, fmt64, "total frames transmitted", stats->tx_packets);
 	seq_printf(seq, fmt64, "total bytes transmitted", stats->tx_bytes);
-	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
+	seq_printf(seq, "Device: %s", vlan->real_dev->name);
 	/* now show all PRIORITY mappings relating to this VLAN */
 	seq_printf(seq, "\nINGRESS priority mappings: "
 			"0:%u  1:%u  2:%u  3:%u  4:%u  5:%u  6:%u 7:%u\n",
-		   dev_info->ingress_priority_map[0],
-		   dev_info->ingress_priority_map[1],
-		   dev_info->ingress_priority_map[2],
-		   dev_info->ingress_priority_map[3],
-		   dev_info->ingress_priority_map[4],
-		   dev_info->ingress_priority_map[5],
-		   dev_info->ingress_priority_map[6],
-		   dev_info->ingress_priority_map[7]);
+		   vlan->ingress_priority_map[0],
+		   vlan->ingress_priority_map[1],
+		   vlan->ingress_priority_map[2],
+		   vlan->ingress_priority_map[3],
+		   vlan->ingress_priority_map[4],
+		   vlan->ingress_priority_map[5],
+		   vlan->ingress_priority_map[6],
+		   vlan->ingress_priority_map[7]);
 
 	seq_printf(seq, " EGRESS priority mappings: ");
 	for (i = 0; i < 16; i++) {
 		const struct vlan_priority_tci_mapping *mp
-			= dev_info->egress_priority_map[i];
+			= vlan->egress_priority_map[i];
 		while (mp) {
 			seq_printf(seq, "%u:%hu ",
 				   mp->priority, ((mp->vlan_qos >> 13) & 0x7));
-- 
1.7.6
