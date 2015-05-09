From: sfeldma@gmail.com
Subject: [PATCH net-next v6 15/23] switchdev: add new switchdev_port_bridge_dellink
Date: Sat,  9 May 2015 10:40:17 -0700
Message-ID: <1431193225-807-16-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34876 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbEIRnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:33 -0400
Received: by pabtp1 with SMTP id tp1so75743951pab.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:32 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Same change as setlink.  Provide the wrapper op for SELF ndo_bridge_dellink
and call into the switchdev driver to delete afspec VLANs.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    6 ++++++
 net/switchdev/switchdev.c |   24 ++++++++++++------------
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index ce5ceb2..8ffadca 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -164,6 +164,12 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int switchdev_port_bridge_dellink(struct net_device *dev,
+					    struct nlmsghdr *nlh, u16 flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index dcdec9d..8ce678e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -512,27 +512,27 @@ int switchdev_port_bridge_setlink(struct net_device *dev,
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_setlink);
 
 /**
- *	switchdev_port_bridge_dellink - Notify switch device port of bridge
- *	port attribute delete
+ *	switchdev_port_bridge_dellink - Set bridge port attributes
  *
  *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
+ *	@nlh: netlink header
+ *	@flags: netlink flags
  *
- *	Notify switch device port of bridge port attribute delete
+ *	Called for SELF on rtnl_bridge_dellink to set bridge port
+ *	attributes.
  */
 int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return 0;
+	struct nlattr *afspec;
 
-	if (!ops->ndo_bridge_dellink)
-		return -EOPNOTSUPP;
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				 IFLA_AF_SPEC);
+	if (afspec)
+		return switchdev_port_br_afspec(dev, afspec,
+						switchdev_port_obj_del);
 
-	return ops->ndo_bridge_dellink(dev, nlh, flags);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
-- 
1.7.10.4
