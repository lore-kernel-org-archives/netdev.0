From: David Ahern <dsahern@gmail.com>
Subject: [RFC net-next 3/4] mlxsw: spectrum: router: Add support for address validator notifier
Date: Tue, 10 Oct 2017 09:41:04 -0700
Message-ID: <1507653665-20540-4-git-send-email-dsahern@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38833 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932436AbdJJQlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:41:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id a7so36889819pfj.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:41:13 -0700 (PDT)
In-Reply-To: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for inetaddr_validator and inet6addr_validator. The
notifiers provide a means for validating ipv4 and ipv6 addresses
before the addresses are installed and on failure the error
is propagated back to the user.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 10 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 53 ++++++++++++++++++++++
 3 files changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 321988ac57cc..da4ee91235be 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4505,11 +4505,19 @@ static struct notifier_block mlxsw_sp_netdevice_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_netdevice_event,
 };
 
+static struct notifier_block mlxsw_sp_inetaddr_valid_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inetaddr_valid_event,
+};
+
 static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_inetaddr_event,
 	.priority = 10,	/* Must be called before FIB notifier block */
 };
 
+static struct notifier_block mlxsw_sp_inet6addr_valid_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inet6addr_valid_event,
+};
+
 static struct notifier_block mlxsw_sp_inet6addr_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_inet6addr_event,
 };
@@ -4533,7 +4541,9 @@ static int __init mlxsw_sp_module_init(void)
 	int err;
 
 	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
+	register_inetaddr_validator_notifier(&mlxsw_sp_inetaddr_valid_nb);
 	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	register_inet6addr_validator_notifier(&mlxsw_sp_inet6addr_valid_nb);
 	register_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 8e45183dc9bb..4865a6f58c83 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -390,8 +390,12 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
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
 void
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 6a356f4b99a3..7d53fdf2c0a8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5656,6 +5656,33 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
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
+/* only expected to be called for event == NETDEV_UP */
+int mlxsw_sp_inetaddr_valid_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct in_validator_info *ivi = (struct in_validator_info *)ptr;
+	struct net_device *dev = ivi->ivi_dev->dev;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *rif;
+	int err = 0;
+
 	mlxsw_sp = mlxsw_sp_lower_get(dev);
 	if (!mlxsw_sp)
 		goto out;
@@ -5708,6 +5735,10 @@ int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 	struct mlxsw_sp_inet6addr_event_work *inet6addr_work;
 	struct net_device *dev = if6->idev->dev;
 
+	/* NETDEV_UP event is handled by mlxsw_sp_inet6addr_valid_event */
+	if (event == NETDEV_UP)
+		return NOTIFY_DONE;
+
 	if (!mlxsw_sp_port_dev_lower_find_rcu(dev))
 		return NOTIFY_DONE;
 
@@ -5724,6 +5755,28 @@ int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
+int mlxsw_sp_inet6addr_valid_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr)
+{
+	struct in6_validator_info *i6vi = (struct in6_validator_info *)ptr;
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
