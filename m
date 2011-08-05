From: Andrei Warkentin <andreiw@motorola.com>
Subject: [PATCHv4] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.
Date: Fri,  5 Aug 2011 16:04:10 -0500
Message-ID: <1312578250-2944-2-git-send-email-andreiw@motorola.com>
References: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
Cc: Andrei Warkentin <andreiw@motorola.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:49202 "EHLO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974Ab1HEVLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 17:11:01 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.22.94.167])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p75L7X1l005695
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 17:07:33 -0400 (EDT)
Received: from mail-iy0-f170.google.com (mail-iy0-f170.google.com [209.85.210.170])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p75L6fXM005366
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 17:07:33 -0400 (EDT)
Received: by mail-iy0-f170.google.com with SMTP id 16so4373654iye.29
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2011 14:10:59 -0700 (PDT)
In-Reply-To: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures the neighbor entries associated with the bridge
dev are flushed, also invalidating the associated cached L2 headers.

This means we br_add_if/br_del_if ports to implement hand-over and
not wind up with bridge packets going out with stale MAC.

This means we can also change MAC of port device and also not wind
up with bridge packets going out with stale MAC.

This builds on Stephen Hemminger's patch, also handling the br_del_if
case and the port MAC change case.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Andrei Warkentin <andreiw@motorola.com>
---
 net/bridge/br_if.c     |    6 +++++-
 net/bridge/br_notify.c |    7 ++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 3176e2e..2cdf007 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -417,6 +417,7 @@ put_back:
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
+	bool changed_addr;
 
 	p = br_port_get_rtnl(dev);
 	if (!p || p->br != br)
@@ -425,9 +426,12 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-	br_stp_recalculate_bridge_id(br);
+	changed_addr = br_stp_recalculate_bridge_id(br);
 	spin_unlock_bh(&br->lock);
 
+	if (changed_addr)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
+
 	netdev_update_features(br->dev);
 
 	return 0;
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 6545ee9..a76b621 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -34,6 +34,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	struct net_device *dev = ptr;
 	struct net_bridge_port *p;
 	struct net_bridge *br;
+	bool changed_addr;
 	int err;
 
 	/* register of bridge completed, add sysfs entries */
@@ -57,8 +58,12 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	case NETDEV_CHANGEADDR:
 		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
-		br_stp_recalculate_bridge_id(br);
+		changed_addr = br_stp_recalculate_bridge_id(br);
 		spin_unlock_bh(&br->lock);
+
+		if (changed_addr)
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
+
 		break;
 
 	case NETDEV_CHANGE:
-- 
1.7.0.4

