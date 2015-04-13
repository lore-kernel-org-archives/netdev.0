From: sfeldma@gmail.com
Subject: [PATCH net-next v4 10/24] rocker: cut over to new swdev_port_bridge_setlink
Date: Sun, 12 Apr 2015 23:17:04 -0700
Message-ID: <1428905838-14920-11-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35319 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbbDMGQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:43 -0400
Received: by pabtp1 with SMTP id tp1so91905626pab.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:43 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker can now use the swdev bridge setlink to parse raw netlink; no need
to duplicate this code in each driver.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   41 +---------------------------------
 1 file changed, 1 insertion(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index f81e362..b2d0477 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4245,45 +4245,6 @@ skip:
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
 				      u32 filter_mask)
@@ -4321,7 +4282,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
-	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
+	.ndo_bridge_setlink		= swdev_port_bridge_setlink,
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
-- 
1.7.10.4
