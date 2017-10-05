From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Add extack for VLAN enslavements
Date: Thu,  5 Oct 2017 23:39:59 +0200
Message-ID: <20171005214000.14022-2-jiri@resnulli.us>
References: <20171005214000.14022-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35171 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdJEVkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:40:02 -0400
Received: by mail-wr0-f194.google.com with SMTP id y44so5219139wry.2
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 14:40:02 -0700 (PDT)
In-Reply-To: <20171005214000.14022-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Similar to physical ports, enslavement of VLAN devices can also fail.
Use extack to indicate why the enslavement failed.

$ ip link add link enp1s0np1 name enp1s0np1.10 type vlan id 10
$ ip link add name bond0 type bond mode 802.3ad
$ ip link set dev enp1s0np1.10 master bond0
Error: spectrum: VLAN devices only support bridge and VRF uppers.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5cd4df0..5ab4fd7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -53,6 +53,7 @@
 #include <linux/notifier.h>
 #include <linux/dcbnl.h>
 #include <linux/inetdevice.h>
+#include <linux/netlink.h>
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
@@ -4389,18 +4390,25 @@ static int mlxsw_sp_netdevice_port_vlan_event(struct net_device *vlan_dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct netdev_notifier_changeupper_info *info = ptr;
+	struct netlink_ext_ack *extack;
 	struct net_device *upper_dev;
 	int err = 0;
 
+	extack = netdev_notifier_info_to_extack(&info->info);
+
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!netif_is_bridge_master(upper_dev))
+		if (!netif_is_bridge_master(upper_dev)) {
+			NL_SET_ERR_MSG(extack, "spectrum: VLAN devices only support bridge and VRF uppers");
 			return -EINVAL;
+		}
 		if (!info->linking)
 			break;
-		if (netdev_has_any_upper_dev(upper_dev))
+		if (netdev_has_any_upper_dev(upper_dev)) {
+			NL_SET_ERR_MSG(extack, "spectrum: Enslaving a port to a device that already has an upper device is not supported");
 			return -EINVAL;
+		}
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-- 
2.9.5
