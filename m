From: sfeldma@gmail.com
Subject: [PATCH net-next v6 13/23] switchdev: remove old switchdev_port_bridge_setlink
Date: Sat,  9 May 2015 10:40:15 -0700
Message-ID: <1431193225-807-14-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34110 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbEIRna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:30 -0400
Received: by pacyx8 with SMTP id yx8so75718600pac.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:30 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

New attr-based bridge_setlink can recurse lower devs and recover on err, so
remove old wrapper (including ndo_dflt_switchdev_port_bridge_setlink).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    9 ---------
 net/switchdev/switchdev.c |   30 ------------------------------
 2 files changed, 39 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 6cf6de1..ce5ceb2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -132,8 +132,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
 					   struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags);
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -204,13 +202,6 @@ static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
 	return 0;
 }
 
-static inline int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-							 struct nlmsghdr *nlh,
-							 u16 flags)
-{
-	return 0;
-}
-
 static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
 					 struct fib_info *fi,
 					 u8 tos, u8 type,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b01791a..dcdec9d 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -537,36 +537,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
 /**
- *	ndo_dflt_switchdev_port_bridge_setlink - default ndo bridge setlink
- *						 op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
- *
- *	Notify master device slaves of bridge port attributes
- */
-int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int ret = 0, err = 0;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return ret;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_bridge_setlink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_setlink);
-
-/**
  *	ndo_dflt_switchdev_port_bridge_dellink - default ndo bridge dellink
  *						 op for master devices
  *
-- 
1.7.10.4
