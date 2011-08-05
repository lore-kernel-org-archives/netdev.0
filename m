From: Andrei Warkentin <andreiw@motorola.com>
Subject: [PATCH] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.
Date: Thu,  4 Aug 2011 20:55:49 -0500
Message-ID: <1312509349-23363-2-git-send-email-andreiw@motorola.com>
References: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
Cc: Andrei Warkentin <andreiw@motorola.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og106.obsmtp.com ([64.18.0.182]:34196 "EHLO
	exprod5og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab1HEMb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 08:31:28 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.176.129.42])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p751xCXq006769
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 21:59:13 -0400 (EDT)
Received: from mail-iy0-f170.google.com (mail-iy0-f170.google.com [209.85.210.170])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p751xCHA006759
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 21:59:12 -0400 (EDT)
Received: by iye16 with SMTP id 16so2709591iye.29
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 19:02:37 -0700 (PDT)
In-Reply-To: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures the neighbor entries associated with the bridge
dev are flushed, also invalidating the associated cached L2 headers.

This means we br_add_if/br_del_if ports to implement hand-over and
not wind up with bridge packets going out with stale MAC.

This means we can also change MAC of port device and also not wind
up with bridge packets going out with stale MAC.

This builds on Stephen Hemminger's patch, also handling the br_del_if
case, port MAC change case, and bridge MAC manual assignment case.

Change-Id: I6039ba021006f854e0e7e83dd1c4261c500aeab7
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Andrei Warkentin <andreiw@motorola.com>
---
 net/bridge/br_device.c |    1 +
 net/bridge/br_if.c     |    6 +++++-
 net/bridge/br_notify.c |    2 ++
 net/bridge/br_stp_if.c |    2 +-
 4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index cf09fe5..ef18070 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -162,6 +162,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 	br->flags |= BR_SET_MAC_ADDR;
 	spin_unlock_bh(&br->lock);
 
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	return 0;
 }
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 204e542..36ad887 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -481,6 +481,7 @@ put_back:
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
+	bool changed_addr;
 
 	if (!br_port_exists(dev))
 		return -EINVAL;
@@ -492,10 +493,13 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-	br_stp_recalculate_bridge_id(br);
+	changed_addr = br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
 	spin_unlock_bh(&br->lock);
 
+	if (changed_addr)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
+
 	return 0;
 }
 
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 404d4e1..c7160b1 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -53,6 +53,8 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 		br_fdb_changeaddr(p, dev->dev_addr);
 		br_stp_recalculate_bridge_id(br);
 		spin_unlock_bh(&br->lock);
+
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
 		break;
 
 	case NETDEV_CHANGE:
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index c0990ba..4528e9a 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 
 	/* user has chosen a value so keep it */
 	if (br->flags & BR_SET_MAC_ADDR)
-		return;
+		return false;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
-- 
1.7.0.4

