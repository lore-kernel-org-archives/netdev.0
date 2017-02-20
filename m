From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] vxlan: add changelink support
Date: Mon, 20 Feb 2017 08:29:19 -0800
Message-ID: <1487608159-970-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jbenc@redhat.com,
        pshelar@ovn.org, joe@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36638 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdBTQ3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:29:24 -0500
Received: by mail-pg0-f41.google.com with SMTP id s67so10011886pgb.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 08:29:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds changelink rtnl op support for vxlan netdevs.
code changes involve:
    - refactor vxlan_newlink into vxlan_nl2conf to be
    used by vxlan_newlink and vxlan_changelink
    - vxlan_nl2conf and vxlan_dev_configure take a
    changelink argument to isolate changelink checks
    and updates.
    - Allow changing only a few attributes:
        - return -EOPNOTSUPP for attributes that cannot
        be changed for now. Incremental patches can
        make the non-supported one available in the future
        if needed.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c |  383 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 270 insertions(+), 113 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c5db8f8..87f63f6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2835,39 +2835,40 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
-			       struct vxlan_config *conf)
+			       struct vxlan_config *conf,
+			       bool changelink)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev), *tmp;
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	unsigned short needed_headroom = ETH_HLEN;
-	int err;
 	bool use_ipv6 = false;
 	__be16 default_port = vxlan->cfg.dst_port;
 	struct net_device *lowerdev = NULL;
 
-	if (conf->flags & VXLAN_F_GPE) {
-		/* For now, allow GPE only together with COLLECT_METADATA.
-		 * This can be relaxed later; in such case, the other side
-		 * of the PtP link will have to be provided.
-		 */
-		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
-		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
-			pr_info("unsupported combination of extensions\n");
-			return -EINVAL;
+	if (!changelink) {
+		if (conf->flags & VXLAN_F_GPE) {
+			/* For now, allow GPE only together with
+			 * COLLECT_METADATA. This can be relaxed later; in such
+			 * case, the other side of the PtP link will have to be
+			 * provided.
+			 */
+			if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
+			    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+				pr_info("unsupported combination of extensions\n");
+				return -EINVAL;
+			}
+			vxlan_raw_setup(dev);
+		} else {
+			vxlan_ether_setup(dev);
 		}
 
-		vxlan_raw_setup(dev);
-	} else {
-		vxlan_ether_setup(dev);
+		/* MTU range: 68 - 65535 */
+		dev->min_mtu = ETH_MIN_MTU;
+		dev->max_mtu = ETH_MAX_MTU;
+		vxlan->net = src_net;
 	}
 
-	/* MTU range: 68 - 65535 */
-	dev->min_mtu = ETH_MIN_MTU;
-	dev->max_mtu = ETH_MAX_MTU;
-
-	vxlan->net = src_net;
-
 	dst->remote_vni = conf->vni;
 
 	memcpy(&dst->remote_ip, &conf->remote_ip, sizeof(conf->remote_ip));
@@ -2889,12 +2890,14 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (conf->remote_ifindex) {
+	if (conf->remote_ifindex &&
+	    conf->remote_ifindex != vxlan->cfg.remote_ifindex) {
 		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		dst->remote_ifindex = conf->remote_ifindex;
 
 		if (!lowerdev) {
-			pr_info("ifindex %d does not exist\n", dst->remote_ifindex);
+			pr_info("ifindex %d does not exist\n",
+				dst->remote_ifindex);
 			return -ENODEV;
 		}
 
@@ -2913,7 +2916,8 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 				   (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
 		needed_headroom = lowerdev->hard_header_len;
-	} else if (vxlan_addr_multicast(&dst->remote_ip)) {
+	} else if (!conf->remote_ifindex &&
+		   vxlan_addr_multicast(&dst->remote_ip)) {
 		pr_info("multicast destination requires interface to be specified\n");
 		return -EINVAL;
 	}
@@ -2953,6 +2957,9 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	if (!vxlan->cfg.age_interval)
 		vxlan->cfg.age_interval = FDB_AGE_DEFAULT;
 
+	if (changelink)
+		return 0;
+
 	list_for_each_entry(tmp, &vn->vxlan_list, next) {
 		if (tmp->cfg.vni == conf->vni &&
 		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
@@ -2965,147 +2972,296 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		}
 	}
 
-	dev->ethtool_ops = &vxlan_ethtool_ops;
-
-	/* create an fdb entry for a valid default destination */
-	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
-		err = vxlan_fdb_create(vxlan, all_zeros_mac,
-				       &vxlan->default_dst.remote_ip,
-				       NUD_REACHABLE|NUD_PERMANENT,
-				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan->cfg.dst_port,
-				       vxlan->default_dst.remote_vni,
-				       vxlan->default_dst.remote_vni,
-				       vxlan->default_dst.remote_ifindex,
-				       NTF_SELF);
-		if (err)
-			return err;
-	}
-
-	err = register_netdevice(dev);
-	if (err) {
-		vxlan_fdb_delete_default(vxlan, vxlan->cfg.vni);
-		return err;
-	}
-
-	list_add(&vxlan->next, &vn->vxlan_list);
-
 	return 0;
 }
 
-static int vxlan_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
+			 struct net_device *dev, struct vxlan_config *conf,
+			 bool changelink)
 {
-	struct vxlan_config conf;
+	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	memset(&conf, 0, sizeof(conf));
+	memset(conf, 0, sizeof(*conf));
 
-	if (data[IFLA_VXLAN_ID])
-		conf.vni = cpu_to_be32(nla_get_u32(data[IFLA_VXLAN_ID]));
+	/* if changelink operation, start with old existing cfg */
+	if (changelink)
+		memcpy(conf, &vxlan->cfg, sizeof(*conf));
+
+	if (data[IFLA_VXLAN_ID]) {
+		__be32 vni = cpu_to_be32(nla_get_u32(data[IFLA_VXLAN_ID]));
+
+		if (changelink && (vni != conf->vni))
+			return -EOPNOTSUPP;
+		conf->vni = cpu_to_be32(nla_get_u32(data[IFLA_VXLAN_ID]));
+	}
 
 	if (data[IFLA_VXLAN_GROUP]) {
-		conf.remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
+		conf->remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
 	} else if (data[IFLA_VXLAN_GROUP6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
-		conf.remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
-		conf.remote_ip.sa.sa_family = AF_INET6;
+		conf->remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
+		conf->remote_ip.sa.sa_family = AF_INET6;
 	}
 
 	if (data[IFLA_VXLAN_LOCAL]) {
-		conf.saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
-		conf.saddr.sa.sa_family = AF_INET;
+		conf->saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
+		conf->saddr.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_LOCAL6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
 		/* TODO: respect scope id */
-		conf.saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
-		conf.saddr.sa.sa_family = AF_INET6;
+		conf->saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
+		conf->saddr.sa.sa_family = AF_INET6;
 	}
 
 	if (data[IFLA_VXLAN_LINK])
-		conf.remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]);
+		conf->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]);
 
 	if (data[IFLA_VXLAN_TOS])
-		conf.tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
+		conf->tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
 
 	if (data[IFLA_VXLAN_TTL])
-		conf.ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
+		conf->ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
 
 	if (data[IFLA_VXLAN_LABEL])
-		conf.label = nla_get_be32(data[IFLA_VXLAN_LABEL]) &
+		conf->label = nla_get_be32(data[IFLA_VXLAN_LABEL]) &
 			     IPV6_FLOWLABEL_MASK;
 
-	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
-		conf.flags |= VXLAN_F_LEARN;
+	if (data[IFLA_VXLAN_LEARNING]) {
+		if (nla_get_u8(data[IFLA_VXLAN_LEARNING])) {
+			conf->flags |= VXLAN_F_LEARN;
+		} else {
+			conf->flags &= ~VXLAN_F_LEARN;
+			vxlan->flags &= ~VXLAN_F_LEARN;
+		}
+	} else if (!changelink) {
+		/* default to learn on a new device */
+		conf->flags |= VXLAN_F_LEARN;
+	}
 
-	if (data[IFLA_VXLAN_AGEING])
-		conf.age_interval = nla_get_u32(data[IFLA_VXLAN_AGEING]);
+	if (data[IFLA_VXLAN_AGEING]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->age_interval = nla_get_u32(data[IFLA_VXLAN_AGEING]);
+	}
 
-	if (data[IFLA_VXLAN_PROXY] && nla_get_u8(data[IFLA_VXLAN_PROXY]))
-		conf.flags |= VXLAN_F_PROXY;
+	if (data[IFLA_VXLAN_PROXY]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_PROXY]))
+			conf->flags |= VXLAN_F_PROXY;
+	}
 
-	if (data[IFLA_VXLAN_RSC] && nla_get_u8(data[IFLA_VXLAN_RSC]))
-		conf.flags |= VXLAN_F_RSC;
+	if (data[IFLA_VXLAN_RSC]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_RSC]))
+			conf->flags |= VXLAN_F_RSC;
+	}
 
-	if (data[IFLA_VXLAN_L2MISS] && nla_get_u8(data[IFLA_VXLAN_L2MISS]))
-		conf.flags |= VXLAN_F_L2MISS;
+	if (data[IFLA_VXLAN_L2MISS]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_L2MISS]))
+			conf->flags |= VXLAN_F_L2MISS;
+	}
 
-	if (data[IFLA_VXLAN_L3MISS] && nla_get_u8(data[IFLA_VXLAN_L3MISS]))
-		conf.flags |= VXLAN_F_L3MISS;
+	if (data[IFLA_VXLAN_L3MISS]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_L3MISS]))
+			conf->flags |= VXLAN_F_L3MISS;
+	}
 
-	if (data[IFLA_VXLAN_LIMIT])
-		conf.addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
+	if (data[IFLA_VXLAN_LIMIT]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
+	}
 
-	if (data[IFLA_VXLAN_COLLECT_METADATA] &&
-	    nla_get_u8(data[IFLA_VXLAN_COLLECT_METADATA]))
-		conf.flags |= VXLAN_F_COLLECT_METADATA;
+	if (data[IFLA_VXLAN_COLLECT_METADATA]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_COLLECT_METADATA]))
+			conf->flags |= VXLAN_F_COLLECT_METADATA;
+	}
 
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
-		const struct ifla_vxlan_port_range *p
-			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
-		conf.port_min = ntohs(p->low);
-		conf.port_max = ntohs(p->high);
+		if (!changelink) {
+			const struct ifla_vxlan_port_range *p
+				= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
+			conf->port_min = ntohs(p->low);
+			conf->port_max = ntohs(p->high);
+		} else {
+			return -EOPNOTSUPP;
+		}
 	}
 
-	if (data[IFLA_VXLAN_PORT])
-		conf.dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
+	if (data[IFLA_VXLAN_PORT]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
+	}
 
-	if (data[IFLA_VXLAN_UDP_CSUM] &&
-	    !nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
-		conf.flags |= VXLAN_F_UDP_ZERO_CSUM_TX;
+	if (data[IFLA_VXLAN_UDP_CSUM]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (!nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
+			conf->flags |= VXLAN_F_UDP_ZERO_CSUM_TX;
+	}
 
-	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
-	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
-		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
+	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
+			conf->flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
+	}
 
-	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
-	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
-		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
+	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
+			conf->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
+	}
 
-	if (data[IFLA_VXLAN_REMCSUM_TX] &&
-	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
-		conf.flags |= VXLAN_F_REMCSUM_TX;
+	if (data[IFLA_VXLAN_REMCSUM_TX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
+			conf->flags |= VXLAN_F_REMCSUM_TX;
+	}
 
-	if (data[IFLA_VXLAN_REMCSUM_RX] &&
-	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
-		conf.flags |= VXLAN_F_REMCSUM_RX;
+	if (data[IFLA_VXLAN_REMCSUM_RX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
+			conf->flags |= VXLAN_F_REMCSUM_RX;
+	}
+
+	if (data[IFLA_VXLAN_GBP]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->flags |= VXLAN_F_GBP;
+	}
+
+	if (data[IFLA_VXLAN_GPE]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->flags |= VXLAN_F_GPE;
+	}
+
+	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->flags |= VXLAN_F_REMCSUM_NOPARTIAL;
+	}
+
+	if (tb[IFLA_MTU]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		conf->mtu = nla_get_u32(tb[IFLA_MTU]);
+	}
+
+	return 0;
+}
+
+static int vxlan_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_config conf;
+	int err;
+
+	err = vxlan_nl2conf(tb, data, dev, &conf, false);
+	if (err)
+		return err;
+
+	err = vxlan_dev_configure(src_net, dev, &conf, false);
+	if (err)
+		return err;
+
+	dev->ethtool_ops = &vxlan_ethtool_ops;
+
+	/* create an fdb entry for a valid default destination */
+	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
+		err = vxlan_fdb_create(vxlan, all_zeros_mac,
+				       &vxlan->default_dst.remote_ip,
+				       NUD_REACHABLE | NUD_PERMANENT,
+				       NLM_F_EXCL | NLM_F_CREATE,
+				       vxlan->cfg.dst_port,
+				       vxlan->default_dst.remote_vni,
+				       vxlan->default_dst.remote_vni,
+				       vxlan->default_dst.remote_ifindex,
+				       NTF_SELF);
+		if (err)
+			return err;
+	}
+
+	err = register_netdevice(dev);
+	if (err) {
+		vxlan_fdb_delete_default(vxlan, vxlan->default_dst.remote_vni);
+		return err;
+	}
+
+	list_add(&vxlan->next, &vn->vxlan_list);
+
+	return 0;
+}
 
-	if (data[IFLA_VXLAN_GBP])
-		conf.flags |= VXLAN_F_GBP;
+static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
+			    struct nlattr *data[])
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct vxlan_rdst old_dst;
+	struct vxlan_config conf;
+	int err;
+
+	err = vxlan_nl2conf(tb, data,
+			    dev, &conf, true);
+	if (err)
+		return err;
 
-	if (data[IFLA_VXLAN_GPE])
-		conf.flags |= VXLAN_F_GPE;
+	memcpy(&old_dst, dst, sizeof(struct vxlan_rdst));
 
-	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
-		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
+	err = vxlan_dev_configure(vxlan->net, dev, &conf, true);
+	if (err)
+		return err;
 
-	if (tb[IFLA_MTU])
-		conf.mtu = nla_get_u32(tb[IFLA_MTU]);
+	/* handle default dst entry */
+	if (!vxlan_addr_equal(&dst->remote_ip, &old_dst.remote_ip)) {
+		spin_lock_bh(&vxlan->hash_lock);
+		if (!vxlan_addr_any(&old_dst.remote_ip))
+			__vxlan_fdb_delete(vxlan, all_zeros_mac,
+					   old_dst.remote_ip,
+					   vxlan->cfg.dst_port,
+					   old_dst.remote_vni,
+					   old_dst.remote_vni,
+					   old_dst.remote_ifindex, 0);
+
+		if (!vxlan_addr_any(&dst->remote_ip)) {
+			err = vxlan_fdb_create(vxlan, all_zeros_mac,
+					       &dst->remote_ip,
+					       NUD_REACHABLE | NUD_PERMANENT,
+					       NLM_F_CREATE | NLM_F_APPEND,
+					       vxlan->cfg.dst_port,
+					       dst->remote_vni,
+					       dst->remote_vni,
+					       dst->remote_ifindex,
+					       NTF_SELF);
+			if (err) {
+				spin_unlock_bh(&vxlan->hash_lock);
+				return err;
+			}
+		}
+		spin_unlock_bh(&vxlan->hash_lock);
+	}
 
-	return vxlan_dev_configure(src_net, dev, &conf);
+	return 0;
 }
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
@@ -3261,6 +3417,7 @@ static struct net *vxlan_get_link_net(const struct net_device *dev)
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
@@ -3282,7 +3439,7 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = vxlan_dev_configure(net, dev, conf);
+	err = vxlan_dev_configure(net, dev, conf, false);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
1.7.10.4
