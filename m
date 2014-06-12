From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] openvswitch: introduce rtnl ops stub
Date: Thu, 12 Jun 2014 16:20:08 +0200
Message-ID: <1402582808-10443-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:51151 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbaFLOUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 10:20:18 -0400
Received: by mail-we0-f173.google.com with SMTP id t60so1358340wes.4
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 07:20:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
IFLA_INFO_SLAVE_KIND for slave.

Note that I added ops->setup check into newlink and dellink in order to
prevent creating and deleting openvswitch instances using rtnl for now.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c                 |  5 ++++-
 net/openvswitch/datapath.c           |  9 ++++++++-
 net/openvswitch/vport-internal_dev.c | 16 ++++++++++++++++
 net/openvswitch/vport-internal_dev.h |  2 ++
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 233b5ae..b874139 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1767,7 +1767,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -ENODEV;
 
 	ops = dev->rtnl_link_ops;
-	if (!ops)
+	if (!ops || !ops->setup)
 		return -EOPNOTSUPP;
 
 	ops->dellink(dev, &list_kill);
@@ -2028,6 +2028,9 @@ replay:
 			return -EOPNOTSUPP;
 		}
 
+		if (!ops->setup)
+			return -EOPNOTSUPP;
+
 		if (!ifname[0])
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0d407bc..5692fb1 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -2070,12 +2070,18 @@ static int __init dp_init(void)
 	if (err)
 		goto error_netns_exit;
 
+	err = ovs_internal_dev_rtnl_link_register();
+	if (err)
+		goto error_unreg_notifier;
+
 	err = dp_register_genl();
 	if (err < 0)
-		goto error_unreg_notifier;
+		goto error_unreg_rtnl_link;
 
 	return 0;
 
+error_unreg_rtnl_link:
+	ovs_internal_dev_rtnl_link_unregister();
 error_unreg_notifier:
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 error_netns_exit:
@@ -2091,6 +2097,7 @@ error:
 static void dp_cleanup(void)
 {
 	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
+	ovs_internal_dev_rtnl_link_unregister();
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 	unregister_pernet_device(&ovs_net_ops);
 	rcu_barrier();
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
