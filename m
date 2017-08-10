From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to use netlink_ext_ack for error reporting
Date: Thu, 10 Aug 2017 14:16:35 -0700
Message-ID: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
To: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
        mschiffer@universe-factory.net, jbenc@redhat.com,
        roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41171 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdHJV3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 17:29:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel log is not where users expect error messages for netlink
requests; as we have extended acks now, we can replace pr_debug() with
NL_SET_ERR_MSG_ATTR().

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

---
v1 -> v2:
   - addressed, error messages rewording, comments from Jiri Benc
   - started off with what Matthias had, and I covered error reporting
     for all of the unsuccessful returns
---
 drivers/net/vxlan.c | 98 +++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 72 insertions(+), 26 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 35e84a9e..ec302cd7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2729,12 +2729,14 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
-			pr_debug("invalid link address (not ethernet)\n");
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "Provided link layer address is not Ethernet");
 			return -EINVAL;
 		}
 
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
-			pr_debug("invalid all zero ethernet address\n");
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "Provided Ethernet address is not unicast");
 			return -EADDRNOTAVAIL;
 		}
 	}
@@ -2742,18 +2744,27 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 	if (tb[IFLA_MTU]) {
 		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
 
-		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU)
+		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU) {
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_MTU],
+					    "MTU must be between 68 and 65535");
 			return -EINVAL;
+		}
 	}
 
-	if (!data)
+	if (!data) {
+		NL_SET_ERR_MSG(extack,
+			       "Not enough attributes provided to perform the operation");
 		return -EINVAL;
+	}
 
 	if (data[IFLA_VXLAN_ID]) {
 		u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
 
-		if (id >= VXLAN_N_VID)
+		if (id >= VXLAN_N_VID) {
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_VXLAN_ID],
+					    "VXLAN ID must be lower than 16777216");
 			return -ERANGE;
+		}
 	}
 
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
@@ -2761,8 +2772,8 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
 
 		if (ntohs(p->high) < ntohs(p->low)) {
-			pr_debug("port range %u .. %u not valid\n",
-				 ntohs(p->low), ntohs(p->high));
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_VXLAN_PORT_RANGE],
+					    "Provided source port range bounds is invalid");
 			return -EINVAL;
 		}
 	}
@@ -2919,7 +2930,8 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 
 static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 				 struct net_device **lower,
-				 struct vxlan_dev *old)
+				 struct vxlan_dev *old,
+				 struct netlink_ext_ack *extack)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *tmp;
@@ -2933,6 +2945,8 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		 */
 		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
 		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+			NL_SET_ERR_MSG(extack,
+				       "VXLAN GPE does not support this combination of attributes");
 			return -EINVAL;
 		}
 	}
@@ -2947,15 +2961,23 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		conf->saddr.sa.sa_family = conf->remote_ip.sa.sa_family;
 	}
 
-	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family)
+	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family) {
+		NL_SET_ERR_MSG(extack,
+			       "Local and remote address must be from the same family");
 		return -EINVAL;
+	}
 
-	if (vxlan_addr_multicast(&conf->saddr))
+	if (vxlan_addr_multicast(&conf->saddr)) {
+		NL_SET_ERR_MSG(extack, "Local address cannot be multicast");
 		return -EINVAL;
+	}
 
 	if (conf->saddr.sa.sa_family == AF_INET6) {
-		if (!IS_ENABLED(CONFIG_IPV6))
+		if (!IS_ENABLED(CONFIG_IPV6)) {
+			NL_SET_ERR_MSG(extack,
+				       "IPv6 support not enabled in the kernel");
 			return -EPFNOSUPPORT;
+		}
 		use_ipv6 = true;
 		conf->flags |= VXLAN_F_IPV6;
 
@@ -2967,46 +2989,68 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 
 			if (local_type & IPV6_ADDR_LINKLOCAL) {
 				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
-				    (remote_type != IPV6_ADDR_ANY))
+				    (remote_type != IPV6_ADDR_ANY)) {
+					NL_SET_ERR_MSG(extack,
+						       "Invalid combination of local and remote address scopes");
 					return -EINVAL;
+				}
 
 				conf->flags |= VXLAN_F_IPV6_LINKLOCAL;
 			} else {
 				if (remote_type ==
-				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL))
+				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
+					NL_SET_ERR_MSG(extack,
+						       "Invalid combination of local and remote address scopes");
 					return -EINVAL;
+				}
 
 				conf->flags &= ~VXLAN_F_IPV6_LINKLOCAL;
 			}
 		}
 	}
 
-	if (conf->label && !use_ipv6)
+	if (conf->label && !use_ipv6) {
+		NL_SET_ERR_MSG(extack,
+			       "Label attribute only applies for IPv6 VXLAN devices");
 		return -EINVAL;
+	}
 
 	if (conf->remote_ifindex) {
 		struct net_device *lowerdev;
 
 		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
-		if (!lowerdev)
+		if (!lowerdev) {
+			NL_SET_ERR_MSG(extack,
+				       "Specified interface for tunnel endpoint communications not found");
 			return -ENODEV;
+		}
 
 #if IS_ENABLED(CONFIG_IPV6)
 		if (use_ipv6) {
 			struct inet6_dev *idev = __in6_dev_get(lowerdev);
-			if (idev && idev->cnf.disable_ipv6)
+			if (idev && idev->cnf.disable_ipv6) {
+				NL_SET_ERR_MSG(extack,
+					       "IPv6 support disabled by administrator");
 				return -EPERM;
+			}
 		}
 #endif
 
 		*lower = lowerdev;
 	} else {
-		if (vxlan_addr_multicast(&conf->remote_ip))
+		if (vxlan_addr_multicast(&conf->remote_ip)) {
+			NL_SET_ERR_MSG(extack,
+				       "Interface need to be specified for multicast destination");
+
 			return -EINVAL;
+		}
 
 #if IS_ENABLED(CONFIG_IPV6)
-		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL)
+		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL) {
+			NL_SET_ERR_MSG(extack,
+				       "Interface need to be specified for link-local local/remote addresses");
 			return -EINVAL;
+		}
 #endif
 
 		*lower = NULL;
@@ -3038,6 +3082,7 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		    tmp->cfg.remote_ifindex != conf->remote_ifindex)
 			continue;
 
+		NL_SET_ERR_MSG(extack, "Specified VNI is duplicate");
 		return -EEXIST;
 	}
 
@@ -3097,14 +3142,14 @@ static void vxlan_config_apply(struct net_device *dev,
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
-			       struct vxlan_config *conf,
-			       bool changelink)
+			       struct vxlan_config *conf, bool changelink,
+			       struct netlink_ext_ack *extack)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct net_device *lowerdev;
 	int ret;
 
-	ret = vxlan_config_validate(src_net, conf, &lowerdev, vxlan);
+	ret = vxlan_config_validate(src_net, conf, &lowerdev, vxlan, extack);
 	if (ret)
 		return ret;
 
@@ -3114,13 +3159,14 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 }
 
 static int __vxlan_dev_create(struct net *net, struct net_device *dev,
-			      struct vxlan_config *conf)
+			      struct vxlan_config *conf,
+			      struct netlink_ext_ack *extack)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	int err;
 
-	err = vxlan_dev_configure(net, dev, conf, false);
+	err = vxlan_dev_configure(net, dev, conf, false, extack);
 	if (err)
 		return err;
 
@@ -3366,7 +3412,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		return err;
 
-	return __vxlan_dev_create(src_net, dev, &conf);
+	return __vxlan_dev_create(src_net, dev, &conf, extack);
 }
 
 static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
@@ -3386,7 +3432,7 @@ static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
 
 	memcpy(&old_dst, dst, sizeof(struct vxlan_rdst));
 
-	err = vxlan_dev_configure(vxlan->net, dev, &conf, true);
+	err = vxlan_dev_configure(vxlan->net, dev, &conf, true, extack);
 	if (err)
 		return err;
 
@@ -3592,7 +3638,7 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = __vxlan_dev_create(net, dev, conf);
+	err = __vxlan_dev_create(net, dev, conf, NULL);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
1.8.3.1
