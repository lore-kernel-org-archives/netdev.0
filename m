From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] vxlan: fix ovs support
Date: Mon, 13 Mar 2017 16:24:03 +0100
Message-ID: <1489418643-32092-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:46390 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdCMPck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:32:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The required changes in the function vxlan_dev_create() were missing
in commit 8bcdc4f3a20b.
The vxlan device is not registered anymore after this patch and the error
path causes an stack dump:
 WARNING: CPU: 3 PID: 1498 at net/core/dev.c:6713 rollback_registered_many+0x9d/0x3f0

Fixes: 8bcdc4f3a20b ("vxlan: add changelink support")
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 73 +++++++++++++++++++++++++++++------------------------
 1 file changed, 40 insertions(+), 33 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e375560cc74e..bdb6ae16d4a8 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2976,6 +2976,44 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	return 0;
 }
 
+static int __vxlan_dev_create(struct net *net, struct net_device *dev,
+			      struct vxlan_config *conf)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	int err;
+
+	err = vxlan_dev_configure(net, dev, conf, false);
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
+	return 0;
+}
+
 static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 			 struct net_device *dev, struct vxlan_config *conf,
 			 bool changelink)
@@ -3172,8 +3210,6 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
-	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_config conf;
 	int err;
 
@@ -3181,36 +3217,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		return err;
 
-	err = vxlan_dev_configure(src_net, dev, &conf, false);
-	if (err)
-		return err;
-
-	dev->ethtool_ops = &vxlan_ethtool_ops;
-
-	/* create an fdb entry for a valid default destination */
-	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
-		err = vxlan_fdb_create(vxlan, all_zeros_mac,
-				       &vxlan->default_dst.remote_ip,
-				       NUD_REACHABLE | NUD_PERMANENT,
-				       NLM_F_EXCL | NLM_F_CREATE,
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
-		vxlan_fdb_delete_default(vxlan, vxlan->default_dst.remote_vni);
-		return err;
-	}
-
-	list_add(&vxlan->next, &vn->vxlan_list);
-
-	return 0;
+	return __vxlan_dev_create(src_net, dev, &conf);
 }
 
 static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
@@ -3440,7 +3447,7 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = vxlan_dev_configure(net, dev, conf, false);
+	err = __vxlan_dev_create(net, dev, conf);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
2.8.1
