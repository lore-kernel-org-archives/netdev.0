From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 4/5] mlxsw: spectrum: router: Add support for address validator notifier
Date: Wed, 18 Oct 2017 09:56:55 -0700
Message-ID: <1508345816-25678-5-git-send-email-dsahern@gmail.com>
References: <1508345816-25678-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:54051 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdJRQ5H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:57:07 -0400
Received: by mail-pf0-f195.google.com with SMTP id t188so4387460pfd.10
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 09:57:07 -0700 (PDT)
In-Reply-To: <1508345816-25678-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for inetaddr_validator and inet6addr_validator. The
notifiers provide a means for validating ipv4 and ipv6 addresses
before the addresses are installed and on failure the error
is propagated back to the user.

Signed-off-by: David Ahern <dsahern@gmail.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 15 ++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 52 ++++++++++++++++++++++
 3 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e1e11c726c16..e6519f2906a4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4521,9 +4521,16 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *nb,
 	return notifier_from_errno(err);
 }
 
+static struct notifier_block mlxsw_sp_inetaddr_valid_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inetaddr_valid_event,
+};
+
 static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_inetaddr_event,
-	.priority = 10,	/* Must be called before FIB notifier block */
+};
+
+static struct notifier_block mlxsw_sp_inet6addr_valid_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inet6addr_valid_event,
 };
 
 static struct notifier_block mlxsw_sp_inet6addr_nb __read_mostly = {
@@ -4548,7 +4555,9 @@ static int __init mlxsw_sp_module_init(void)
 {
 	int err;
 
+	register_inetaddr_validator_notifier(&mlxsw_sp_inetaddr_valid_nb);
 	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	register_inet6addr_validator_notifier(&mlxsw_sp_inet6addr_valid_nb);
 	register_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 
@@ -4567,7 +4576,9 @@ static int __init mlxsw_sp_module_init(void)
 err_core_driver_register:
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
+	unregister_inet6addr_validator_notifier(&mlxsw_sp_inet6addr_valid_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	unregister_inetaddr_validator_notifier(&mlxsw_sp_inetaddr_valid_nb);
 	return err;
 }
 
@@ -4577,7 +4588,9 @@ static void __exit mlxsw_sp_module_exit(void)
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
+	unregister_inet6addr_validator_notifier(&mlxsw_sp_inet6addr_valid_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	unregister_inetaddr_validator_notifier(&mlxsw_sp_inetaddr_valid_nb);
 }
 
 module_init(mlxsw_sp_module_init);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 28feb745a38a..2a2472a09d8c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -391,8 +391,12 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 int mlxsw_sp_netdevice_router_port_event(struct net_device *dev);
 int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr);
+int mlxsw_sp_inetaddr_valid_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr);
 int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 			     unsigned long event, void *ptr);
+int mlxsw_sp_inet6addr_valid_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr);
 int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 				 struct netdev_notifier_changeupper_info *info);
 bool mlxsw_sp_netdev_is_ipip(const struct mlxsw_sp *mlxsw_sp,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3330120f2f8e..66bab9ce2881 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5781,6 +5781,32 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	struct mlxsw_sp_rif *rif;
 	int err = 0;
 
+	/* NETDEV_UP event is handled by mlxsw_sp_inetaddr_valid_event */
+	if (event == NETDEV_UP)
+		goto out;
+
+	mlxsw_sp = mlxsw_sp_lower_get(dev);
+	if (!mlxsw_sp)
+		goto out;
+
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!mlxsw_sp_rif_should_config(rif, dev, event))
+		goto out;
+
+	err = __mlxsw_sp_inetaddr_event(dev, event);
+out:
+	return notifier_from_errno(err);
+}
+
+int mlxsw_sp_inetaddr_valid_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct in_validator_info *ivi = (struct in_validator_info *) ptr;
+	struct net_device *dev = ivi->ivi_dev->dev;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *rif;
+	int err = 0;
+
 	mlxsw_sp = mlxsw_sp_lower_get(dev);
 	if (!mlxsw_sp)
 		goto out;
@@ -5833,6 +5859,10 @@ int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 	struct mlxsw_sp_inet6addr_event_work *inet6addr_work;
 	struct net_device *dev = if6->idev->dev;
 
+	/* NETDEV_UP event is handled by mlxsw_sp_inet6addr_valid_event */
+	if (event == NETDEV_UP)
+		return NOTIFY_DONE;
+
 	if (!mlxsw_sp_port_dev_lower_find_rcu(dev))
 		return NOTIFY_DONE;
 
@@ -5849,6 +5879,28 @@ int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
+int mlxsw_sp_inet6addr_valid_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr)
+{
+	struct in6_validator_info *i6vi = (struct in6_validator_info *) ptr;
+	struct net_device *dev = i6vi->i6vi_dev->dev;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *rif;
+	int err = 0;
+
+	mlxsw_sp = mlxsw_sp_lower_get(dev);
+	if (!mlxsw_sp)
+		goto out;
+
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!mlxsw_sp_rif_should_config(rif, dev, event))
+		goto out;
+
+	err = __mlxsw_sp_inetaddr_event(dev, event);
+out:
+	return notifier_from_errno(err);
+}
+
 static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif_index,
 			     const char *mac, int mtu)
 {
-- 
2.1.4
