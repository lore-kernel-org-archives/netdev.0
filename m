From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] openvswitch: introduce rtnl ops stub
Date: Wed, 25 Jun 2014 14:28:00 +0200
Message-ID: <1403699280-12837-2-git-send-email-jiri@resnulli.us>
References: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:59653 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043AbaFYM2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:28:11 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so1934271wgg.25
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 05:28:10 -0700 (PDT)
In-Reply-To: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
IFLA_INFO_SLAVE_KIND for slave.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/openvswitch/datapath.c           |  9 ++++++++-
 net/openvswitch/vport-internal_dev.c | 16 ++++++++++++++++
 net/openvswitch/vport-internal_dev.h |  2 ++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0d407bc..fe95b6c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -2054,10 +2054,14 @@ static int __init dp_init(void)
 
 	pr_info("Open vSwitch switching datapath\n");
 
-	err = ovs_flow_init();
+	err = ovs_internal_dev_rtnl_link_register();
 	if (err)
 		goto error;
 
+	err = ovs_flow_init();
+	if (err)
+		goto error_unreg_rtnl_link;
+
 	err = ovs_vport_init();
 	if (err)
 		goto error_flow_exit;
@@ -2084,6 +2088,8 @@ error_vport_exit:
 	ovs_vport_exit();
 error_flow_exit:
 	ovs_flow_exit();
+error_unreg_rtnl_link:
+	ovs_internal_dev_rtnl_link_unregister();
 error:
 	return err;
 }
@@ -2096,6 +2102,7 @@ static void dp_cleanup(void)
 	rcu_barrier();
 	ovs_vport_exit();
 	ovs_flow_exit();
+	ovs_internal_dev_rtnl_link_unregister();
 }
 
 module_init(dp_init);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 789af92..295471a 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -26,6 +26,7 @@
 
 #include <net/dst.h>
 #include <net/xfrm.h>
+#include <net/rtnetlink.h>
 
 #include "datapath.h"
 #include "vport-internal_dev.h"
@@ -121,6 +122,10 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_get_stats64 = internal_dev_get_stats,
 };
 
+static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
+	.kind = "openvswitch",
+};
+
 static void do_setup(struct net_device *netdev)
 {
 	ether_setup(netdev);
@@ -131,6 +136,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	netdev->destructor = internal_dev_destructor;
 	netdev->ethtool_ops = &internal_dev_ethtool_ops;
+	netdev->rtnl_link_ops = &internal_dev_link_ops;
 	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
@@ -248,3 +254,13 @@ struct vport *ovs_internal_dev_get_vport(struct net_device *netdev)
 
 	return internal_dev_priv(netdev)->vport;
 }
+
+int ovs_internal_dev_rtnl_link_register(void)
+{
+	return rtnl_link_register(&internal_dev_link_ops);
+}
+
+void ovs_internal_dev_rtnl_link_unregister(void)
+{
+	rtnl_link_unregister(&internal_dev_link_ops);
+}
diff --git a/net/openvswitch/vport-internal_dev.h b/net/openvswitch/vport-internal_dev.h
index 9a7d30e..1b179a1 100644
--- a/net/openvswitch/vport-internal_dev.h
+++ b/net/openvswitch/vport-internal_dev.h
@@ -24,5 +24,7 @@
 
 int ovs_is_internal_dev(const struct net_device *);
 struct vport *ovs_internal_dev_get_vport(struct net_device *);
+int ovs_internal_dev_rtnl_link_register(void);
+void ovs_internal_dev_rtnl_link_unregister(void);
 
 #endif /* vport-internal_dev.h */
-- 
1.9.0
