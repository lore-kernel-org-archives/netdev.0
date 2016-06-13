From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 2/4] ovs/vxlan: fix rtnl notifications on iface deletion
Date: Mon, 13 Jun 2016 10:31:05 +0200
Message-ID: <1465806667-23148-3-git-send-email-nicolas.dichtel@6wind.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
 <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@ovn.org, jesse@kernel.org,
	linville@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38140 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964899AbcFMIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:31:13 -0400
In-Reply-To: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function vxlan_dev_create() (only used by ovs) never calls
rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
never set to RTNL_LINK_INITIALIZED.
During the deletion phase, the function rollback_registered_many() sends
a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.

Note that the function vxlan_dev_create() is moved after the rtnl stuff so
that vxlan_dellink() can be called in this function.

Fixes: dcc38c033b32 ("openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN")
CC: Thomas Graf <tgraf@suug.ch>
CC: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 58 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 24 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f999db2f97b4..b3b9db68f758 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2952,30 +2952,6 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	return 0;
 }
 
-struct net_device *vxlan_dev_create(struct net *net, const char *name,
-				    u8 name_assign_type, struct vxlan_config *conf)
-{
-	struct nlattr *tb[IFLA_MAX+1];
-	struct net_device *dev;
-	int err;
-
-	memset(&tb, 0, sizeof(tb));
-
-	dev = rtnl_create_link(net, name, name_assign_type,
-			       &vxlan_link_ops, tb);
-	if (IS_ERR(dev))
-		return dev;
-
-	err = vxlan_dev_configure(net, dev, conf);
-	if (err < 0) {
-		free_netdev(dev);
-		return ERR_PTR(err);
-	}
-
-	return dev;
-}
-EXPORT_SYMBOL_GPL(vxlan_dev_create);
-
 static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
@@ -3268,6 +3244,40 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.get_link_net	= vxlan_get_link_net,
 };
 
+struct net_device *vxlan_dev_create(struct net *net, const char *name,
+				    u8 name_assign_type,
+				    struct vxlan_config *conf)
+{
+	struct nlattr *tb[IFLA_MAX + 1];
+	struct net_device *dev;
+	int err;
+
+	memset(&tb, 0, sizeof(tb));
+
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &vxlan_link_ops, tb);
+	if (IS_ERR(dev))
+		return dev;
+
+	err = vxlan_dev_configure(net, dev, conf);
+	if (err < 0) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0) {
+		LIST_HEAD(list_kill);
+
+		vxlan_dellink(dev, &list_kill);
+		unregister_netdevice_many(&list_kill);
+		return ERR_PTR(err);
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(vxlan_dev_create);
+
 static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
 					     struct net_device *dev)
 {
-- 
2.4.2
