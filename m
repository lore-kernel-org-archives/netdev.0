From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/22] mlxsw: spectrum_router: Configure RIFs based on IPv6 addresses
Date: Tue, 18 Jul 2017 10:10:13 +0200
Message-ID: <20170718081030.2781-6-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35568 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdGRIKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:44 -0400
Received: by mail-wr0-f196.google.com with SMTP id a10so2870689wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:43 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

When a netdev is configured with an IP address a router interface (RIF)
should be configured for it in the device. Allow configuration of RIFs
based on IPv6 address notifications as well as IPv4.

Note that the RIF exists as long as an IP address is configured on the
netdev, regardless of the address family.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  8 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 79 ++++++++++++++++++++--
 3 files changed, 84 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d6dc3dc..88b668b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -58,6 +58,7 @@
 #include <net/tc_act/tc_mirred.h>
 #include <net/netevent.h>
 #include <net/tc_act/tc_sample.h>
+#include <net/addrconf.h>
 
 #include "spectrum.h"
 #include "pci.h"
@@ -4393,6 +4394,10 @@ static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
 	.priority = 10,	/* Must be called before FIB notifier block */
 };
 
+static struct notifier_block mlxsw_sp_inet6addr_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inet6addr_event,
+};
+
 static struct notifier_block mlxsw_sp_router_netevent_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_router_netevent_event,
 };
@@ -4413,6 +4418,7 @@ static int __init mlxsw_sp_module_init(void)
 
 	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	register_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 
 	err = mlxsw_core_driver_register(&mlxsw_sp_driver);
@@ -4429,6 +4435,7 @@ static int __init mlxsw_sp_module_init(void)
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
 err_core_driver_register:
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
+	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	return err;
@@ -4439,6 +4446,7 @@ static void __exit mlxsw_sp_module_exit(void)
 	mlxsw_pci_driver_unregister(&mlxsw_sp_pci_driver);
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
+	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5ef98d4..e848f06 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -384,6 +384,8 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 int mlxsw_sp_netdevice_router_port_event(struct net_device *dev);
 int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr);
+int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr);
 int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 				 struct netdev_notifier_changeupper_info *info);
 void
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 690bb9f..7224066 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -49,6 +49,7 @@
 #include <net/ip_fib.h>
 #include <net/fib_rules.h>
 #include <net/l3mdev.h>
+#include <net/addrconf.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -2941,17 +2942,30 @@ static void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, rif);
 }
 
-static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *rif,
-				       const struct in_device *in_dev,
-				       unsigned long event)
+static bool
+mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *rif, struct net_device *dev,
+			   unsigned long event)
 {
+	struct inet6_dev *inet6_dev;
+	bool addr_list_empty = true;
+	struct in_device *idev;
+
 	switch (event) {
 	case NETDEV_UP:
 		if (!rif)
 			return true;
 		return false;
 	case NETDEV_DOWN:
-		if (rif && !in_dev->ifa_list &&
+		idev = __in_dev_get_rtnl(dev);
+		if (idev && idev->ifa_list)
+			addr_list_empty = false;
+
+		inet6_dev = __in6_dev_get(dev);
+		if (addr_list_empty && inet6_dev &&
+		    !list_empty(&inet6_dev->addr_list))
+			addr_list_empty = false;
+
+		if (rif && addr_list_empty &&
 		    !netif_is_l3_slave(rif->dev))
 			return true;
 		/* It is possible we already removed the RIF ourselves
@@ -3349,7 +3363,7 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 		goto out;
 
 	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!mlxsw_sp_rif_should_config(rif, ifa->ifa_dev, event))
+	if (!mlxsw_sp_rif_should_config(rif, dev, event))
 		goto out;
 
 	err = __mlxsw_sp_inetaddr_event(dev, event);
@@ -3357,6 +3371,61 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	return notifier_from_errno(err);
 }
 
+struct mlxsw_sp_inet6addr_event_work {
+	struct work_struct work;
+	struct net_device *dev;
+	unsigned long event;
+};
+
+static void mlxsw_sp_inet6addr_event_work(struct work_struct *work)
+{
+	struct mlxsw_sp_inet6addr_event_work *inet6addr_work =
+		container_of(work, struct mlxsw_sp_inet6addr_event_work, work);
+	struct net_device *dev = inet6addr_work->dev;
+	unsigned long event = inet6addr_work->event;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *rif;
+
+	rtnl_lock();
+	mlxsw_sp = mlxsw_sp_lower_get(dev);
+	if (!mlxsw_sp)
+		goto out;
+
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!mlxsw_sp_rif_should_config(rif, dev, event))
+		goto out;
+
+	__mlxsw_sp_inetaddr_event(dev, event);
+out:
+	rtnl_unlock();
+	dev_put(dev);
+	kfree(inet6addr_work);
+}
+
+/* Called with rcu_read_lock() */
+int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *if6 = (struct inet6_ifaddr *) ptr;
+	struct mlxsw_sp_inet6addr_event_work *inet6addr_work;
+	struct net_device *dev = if6->idev->dev;
+
+	if (!mlxsw_sp_port_dev_lower_find_rcu(dev))
+		return NOTIFY_DONE;
+
+	inet6addr_work = kzalloc(sizeof(*inet6addr_work), GFP_ATOMIC);
+	if (!inet6addr_work)
+		return NOTIFY_BAD;
+
+	INIT_WORK(&inet6addr_work->work, mlxsw_sp_inet6addr_event_work);
+	inet6addr_work->dev = dev;
+	inet6addr_work->event = event;
+	dev_hold(dev);
+	mlxsw_core_schedule_work(&inet6addr_work->work);
+
+	return NOTIFY_DONE;
+}
+
 static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif_index,
 			     const char *mac, int mtu)
 {
-- 
2.9.3
