From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 1/6] vxlan: refactor verification and application of configuration
Date: Fri, 14 Apr 2017 18:44:41 +0200
Message-ID: <9faa4f174e16e4ae0de3e7a6360ca11c7c4dc190.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vxlan_dev_configure function was mixing validation and application of
the vxlan configuration; this could easily lead to bugs with the changelink
operation, as it was hard to see if the function wcould return an error
after parts of the configuration had already been applied.

This commit splits validation and application out of vxlan_dev_configure as
separate functions to make it clearer where error returns are allowed and
where the vxlan_dev or net_device may be configured.

In addition, some validation is moved to vxlan_validate and some
initialization to vxlan_setup where this improves grouping of similar
settings.

Finally, this also fixes two actual bugs:

* if set, conf->mtu would overwrite dev->mtu in each changelink operation,
  reverting other changes of dev->mtu
* the "if (!conf->dst_port)" branch would never be run, as conf->dst_port
  was set in vxlan_setup before. This caused VXLAN-GPE to use the same
  default port as other VXLAN sockets instead of the intended IANA-assigned
  4790.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

v2: new patch

 drivers/net/vxlan.c | 202 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 114 insertions(+), 88 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ebc98bb17a51..86471e961708 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2598,6 +2598,10 @@ static void vxlan_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_NO_QUEUE;
 
+	/* MTU range: 68 - 65535 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = ETH_MAX_MTU;
+
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
 
@@ -2605,9 +2609,8 @@ static void vxlan_setup(struct net_device *dev)
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
-	vxlan->cfg.dst_port = htons(vxlan_port);
-
 	vxlan->dev = dev;
+	vxlan->net = dev_net(dev);
 
 	gro_cells_init(&vxlan->gro_cells, dev);
 
@@ -2676,11 +2679,19 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		}
 	}
 
+	if (tb[IFLA_MTU]) {
+		u32 mtu = nla_get_u32(data[IFLA_MTU]);
+
+		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU)
+			return -EINVAL;
+	}
+
 	if (!data)
 		return -EINVAL;
 
 	if (data[IFLA_VXLAN_ID]) {
-		__u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
+		u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
+
 		if (id >= VXLAN_N_VID)
 			return -ERANGE;
 	}
@@ -2839,55 +2850,36 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 	return ret;
 }
 
-static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
-			       struct vxlan_config *conf,
-			       bool changelink)
+static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
+				 struct net_device **lower,
+				 struct vxlan_dev *old)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
-	struct vxlan_dev *vxlan = netdev_priv(dev), *tmp;
-	struct vxlan_rdst *dst = &vxlan->default_dst;
-	unsigned short needed_headroom = ETH_HLEN;
+	struct vxlan_dev *tmp;
 	bool use_ipv6 = false;
-	__be16 default_port = vxlan->cfg.dst_port;
-	struct net_device *lowerdev = NULL;
 
-	if (!changelink) {
-		if (conf->flags & VXLAN_F_GPE) {
-			/* For now, allow GPE only together with
-			 * COLLECT_METADATA. This can be relaxed later; in such
-			 * case, the other side of the PtP link will have to be
-			 * provided.
-			 */
-			if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
-			    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
-				pr_info("unsupported combination of extensions\n");
-				return -EINVAL;
-			}
-			vxlan_raw_setup(dev);
-		} else {
-			vxlan_ether_setup(dev);
+	if (conf->flags & VXLAN_F_GPE) {
+		/* For now, allow GPE only together with
+		 * COLLECT_METADATA. This can be relaxed later; in such
+		 * case, the other side of the PtP link will have to be
+		 * provided.
+		 */
+		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
+		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+			pr_info("unsupported combination of extensions\n");
+			return -EINVAL;
 		}
-
-		/* MTU range: 68 - 65535 */
-		dev->min_mtu = ETH_MIN_MTU;
-		dev->max_mtu = ETH_MAX_MTU;
-		vxlan->net = src_net;
 	}
 
-	dst->remote_vni = conf->vni;
-
-	memcpy(&dst->remote_ip, &conf->remote_ip, sizeof(conf->remote_ip));
-
-	/* Unless IPv6 is explicitly requested, assume IPv4 */
-	if (!dst->remote_ip.sa.sa_family)
-		dst->remote_ip.sa.sa_family = AF_INET;
+	if (!conf->remote_ip.sa.sa_family)
+		conf->remote_ip.sa.sa_family = AF_INET;
 
-	if (dst->remote_ip.sa.sa_family == AF_INET6 ||
-	    vxlan->cfg.saddr.sa.sa_family == AF_INET6) {
+	if (conf->remote_ip.sa.sa_family == AF_INET6 ||
+	    conf->saddr.sa.sa_family == AF_INET6) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 		use_ipv6 = true;
-		vxlan->flags |= VXLAN_F_IPV6;
+		conf->flags |= VXLAN_F_IPV6;
 	}
 
 	if (conf->label && !use_ipv6) {
@@ -2895,14 +2887,13 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (conf->remote_ifindex &&
-	    conf->remote_ifindex != vxlan->cfg.remote_ifindex) {
-		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
-		dst->remote_ifindex = conf->remote_ifindex;
+	if (conf->remote_ifindex) {
+		struct net_device *lowerdev;
 
+		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		if (!lowerdev) {
 			pr_info("ifindex %d does not exist\n",
-				dst->remote_ifindex);
+				conf->remote_ifindex);
 			return -ENODEV;
 		}
 
@@ -2916,39 +2907,83 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		}
 #endif
 
-		if (!conf->mtu)
-			dev->mtu = lowerdev->mtu -
-				   (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+		*lower = lowerdev;
+	} else {
+		if (vxlan_addr_multicast(&conf->remote_ip)) {
+			pr_info("multicast destination requires interface to be specified\n");
+			return -EINVAL;
+		}
 
-		needed_headroom = lowerdev->hard_header_len;
-	} else if (!conf->remote_ifindex &&
-		   vxlan_addr_multicast(&dst->remote_ip)) {
-		pr_info("multicast destination requires interface to be specified\n");
-		return -EINVAL;
+		*lower = NULL;
 	}
 
-	if (lowerdev) {
-		dev->gso_max_size = lowerdev->gso_max_size;
-		dev->gso_max_segs = lowerdev->gso_max_segs;
+	if (!conf->dst_port) {
+		if (conf->flags & VXLAN_F_GPE)
+			conf->dst_port = htons(4790); /* IANA VXLAN-GPE port */
+		else
+			conf->dst_port = htons(vxlan_port);
 	}
 
-	if (conf->mtu) {
-		int max_mtu = ETH_MAX_MTU;
+	if (!conf->age_interval)
+		conf->age_interval = FDB_AGE_DEFAULT;
 
-		if (lowerdev)
-			max_mtu = lowerdev->mtu;
+	list_for_each_entry(tmp, &vn->vxlan_list, next) {
+		if (tmp == old)
+			continue;
 
-		max_mtu -= (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
+		if (tmp->cfg.vni == conf->vni &&
+		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
+		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
+		    tmp->cfg.dst_port == conf->dst_port &&
+		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
+		    (conf->flags & VXLAN_F_RCV_FLAGS)) {
+			pr_info("duplicate VNI %u\n", be32_to_cpu(conf->vni));
+			return -EEXIST;
+		}
+	}
 
-		if (conf->mtu < dev->min_mtu || conf->mtu > dev->max_mtu)
-			return -EINVAL;
+	return 0;
+}
 
-		dev->mtu = conf->mtu;
+static void vxlan_config_apply(struct net_device *dev,
+			       struct vxlan_config *conf,
+			       struct net_device *lowerdev, bool changelink)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	unsigned short needed_headroom = ETH_HLEN;
+	bool use_ipv6 = !!(conf->flags & VXLAN_F_IPV6);
+	int max_mtu = ETH_MAX_MTU;
 
-		if (conf->mtu > max_mtu)
-			dev->mtu = max_mtu;
+	if (!changelink) {
+		if (conf->flags & VXLAN_F_GPE)
+			vxlan_raw_setup(dev);
+		else
+			vxlan_ether_setup(dev);
+
+		if (conf->mtu)
+			dev->mtu = conf->mtu;
 	}
 
+	dst->remote_vni = conf->vni;
+
+	memcpy(&dst->remote_ip, &conf->remote_ip, sizeof(conf->remote_ip));
+
+	if (lowerdev) {
+		dst->remote_ifindex = conf->remote_ifindex;
+
+		dev->gso_max_size = lowerdev->gso_max_size;
+		dev->gso_max_segs = lowerdev->gso_max_segs;
+
+		needed_headroom = lowerdev->hard_header_len;
+
+		max_mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM :
+					   VXLAN_HEADROOM);
+	}
+
+	if (dev->mtu > max_mtu)
+		dev->mtu = max_mtu;
+
 	if (use_ipv6 || conf->flags & VXLAN_F_COLLECT_METADATA)
 		needed_headroom += VXLAN6_HEADROOM;
 	else
@@ -2956,31 +2991,22 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	dev->needed_headroom = needed_headroom;
 
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
-	if (!vxlan->cfg.dst_port) {
-		if (conf->flags & VXLAN_F_GPE)
-			vxlan->cfg.dst_port = htons(4790); /* IANA VXLAN-GPE port */
-		else
-			vxlan->cfg.dst_port = default_port;
-	}
 	vxlan->flags |= conf->flags;
+}
 
-	if (!vxlan->cfg.age_interval)
-		vxlan->cfg.age_interval = FDB_AGE_DEFAULT;
+static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
+			       struct vxlan_config *conf,
+			       bool changelink)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct net_device *lowerdev;
+	int ret;
 
-	if (changelink)
-		return 0;
+	ret = vxlan_config_validate(src_net, conf, &lowerdev, vxlan);
+	if (ret)
+		return ret;
 
-	list_for_each_entry(tmp, &vn->vxlan_list, next) {
-		if (tmp->cfg.vni == conf->vni &&
-		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
-		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
-		    tmp->cfg.dst_port == vxlan->cfg.dst_port &&
-		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
-		    (vxlan->flags & VXLAN_F_RCV_FLAGS)) {
-			pr_info("duplicate VNI %u\n", be32_to_cpu(conf->vni));
-			return -EEXIST;
-		}
-	}
+	vxlan_config_apply(dev, conf, lowerdev, changelink);
 
 	return 0;
 }
-- 
2.12.2
