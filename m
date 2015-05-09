From: sfeldma@gmail.com
Subject: [PATCH net-next v6 12/23] switchdev: cut over to new switchdev_port_bridge_setlink
Date: Sat,  9 May 2015 10:40:14 -0700
Message-ID: <1431193225-807-13-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33562 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbbEIRn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:29 -0400
Received: by pacwv17 with SMTP id wv17so75783484pac.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:29 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker, bonding, and team can now use the switchdev bridge setlink to parse
raw netlink; no need to duplicate this code in each driver.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c      |    2 +-
 drivers/net/ethernet/rocker/rocker.c |   41 +---------------------------------
 drivers/net/team/team.c              |    2 +-
 3 files changed, 3 insertions(+), 42 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8e62180..e1d8a03 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4039,7 +4039,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_bridge_setlink	= ndo_dflt_switchdev_port_bridge_setlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= ndo_dflt_switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index f9281ea..18f5468 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4249,45 +4249,6 @@ skip:
 	return idx;
 }
 
-static int rocker_port_bridge_setlink(struct net_device *dev,
-				      struct nlmsghdr *nlh, u16 flags)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct nlattr *protinfo;
-	struct nlattr *attr;
-	int err;
-
-	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
-				   IFLA_PROTINFO);
-	if (protinfo) {
-		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
-		if (attr) {
-			if (nla_len(attr) < sizeof(u8))
-				return -EINVAL;
-
-			if (nla_get_u8(attr))
-				rocker_port->brport_flags |= BR_LEARNING;
-			else
-				rocker_port->brport_flags &= ~BR_LEARNING;
-			err = rocker_port_set_learning(rocker_port);
-			if (err)
-				return err;
-		}
-		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING_SYNC);
-		if (attr) {
-			if (nla_len(attr) < sizeof(u8))
-				return -EINVAL;
-
-			if (nla_get_u8(attr))
-				rocker_port->brport_flags |= BR_LEARNING_SYNC;
-			else
-				rocker_port->brport_flags &= ~BR_LEARNING_SYNC;
-		}
-	}
-
-	return 0;
-}
-
 static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				      struct net_device *dev,
 				      u32 filter_mask, int nlflags)
@@ -4326,7 +4287,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
-	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
+	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index cfe8496..e6c4df2 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1977,7 +1977,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
-	.ndo_bridge_setlink     = ndo_dflt_switchdev_port_bridge_setlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink     = ndo_dflt_switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
-- 
1.7.10.4
