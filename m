From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next 2/2] vxlan: add back error messages to vxlan_config_validate() as extended netlink acks
Date: Tue, 27 Jun 2017 22:47:58 +0200
Message-ID: <b190d4e8bb6a90a00105473287b19e09ad8c4c58.1498595233.git.mschiffer@universe-factory.net>
References: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, roopa@cumulusnetworks.com,
        pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:50776 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753537AbdF0UsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 16:48:22 -0400
In-Reply-To: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
In-Reply-To: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
References: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When refactoring the vxlan config validation, some kernel log messages were
removed. This brings them back using the new netlink_ext_ack support, and
adds some more in the recently added code handling link-local IPv6
addresses.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/vxlan.c | 43 ++++++++++++++++++++++++++++++-------------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 01957e39f2cd..8d4248ab09c2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2909,7 +2909,8 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 
 static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 				 struct net_device **lower,
-				 struct vxlan_dev *old)
+				 struct vxlan_dev *old,
+				 struct netlink_ext_ack *extack)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *tmp;
@@ -2923,6 +2924,8 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		 */
 		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
 		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+			NL_SET_ERR_MSG(extack,
+				       "unsupported combination of extensions");
 			return -EINVAL;
 		}
 	}
@@ -2957,14 +2960,20 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 
 			if (local_type & IPV6_ADDR_LINKLOCAL) {
 				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
-				    (remote_type != IPV6_ADDR_ANY))
+				    (remote_type != IPV6_ADDR_ANY)) {
+					NL_SET_ERR_MSG(extack,
+						       "invalid combination of address scopes");
 					return -EINVAL;
+				}
 
 				conf->flags |= VXLAN_F_IPV6_LINKLOCAL;
 			} else {
 				if (remote_type ==
-				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL))
+				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
+					NL_SET_ERR_MSG(extack,
+						       "invalid combination of address scopes");
 					return -EINVAL;
+				}
 
 				conf->flags &= ~VXLAN_F_IPV6_LINKLOCAL;
 			}
@@ -2991,12 +3000,18 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 
 		*lower = lowerdev;
 	} else {
-		if (vxlan_addr_multicast(&conf->remote_ip))
+		if (vxlan_addr_multicast(&conf->remote_ip)) {
+			NL_SET_ERR_MSG(extack,
+				       "multicast destination requires interface to be specified");
 			return -EINVAL;
+		}
 
 #if IS_ENABLED(CONFIG_IPV6)
-		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL)
+		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL) {
+			NL_SET_ERR_MSG(extack,
+				       "link-local local/remote addresses require interface to be specified");
 			return -EINVAL;
+		}
 #endif
 
 		*lower = NULL;
@@ -3028,6 +3043,7 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		    tmp->cfg.remote_ifindex != conf->remote_ifindex)
 			continue;
 
+		NL_SET_ERR_MSG(extack, "duplicate VNI");
 		return -EEXIST;
 	}
 
@@ -3083,14 +3099,14 @@ static void vxlan_config_apply(struct net_device *dev,
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
 
@@ -3100,13 +3116,14 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
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
 
@@ -3352,7 +3369,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		return err;
 
-	return __vxlan_dev_create(src_net, dev, &conf);
+	return __vxlan_dev_create(src_net, dev, &conf, extack);
 }
 
 static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
@@ -3372,7 +3389,7 @@ static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
 
 	memcpy(&old_dst, dst, sizeof(struct vxlan_rdst));
 
-	err = vxlan_dev_configure(vxlan->net, dev, &conf, true);
+	err = vxlan_dev_configure(vxlan->net, dev, &conf, true, extack);
 	if (err)
 		return err;
 
@@ -3578,7 +3595,7 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = __vxlan_dev_create(net, dev, conf);
+	err = __vxlan_dev_create(net, dev, conf, NULL);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
2.13.2
