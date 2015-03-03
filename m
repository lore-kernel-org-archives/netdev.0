From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v4] bridge: fix bridge netlink RCU usage
Date: Tue,  3 Mar 2015 16:02:16 +0100
Message-ID: <1425394936-11595-1-git-send-email-johannes@sipsolutions.net>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56255 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbbCCPCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 10:02:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

When the STP timer fires, it can call br_ifinfo_notify(),
which in turn ends up in the new br_get_link_af_size().
This function is annotated to be using RTNL locking, which
clearly isn't the case here, and thus lockdep warns:

  ===============================
  [ INFO: suspicious RCU usage. ]
  3.19.0+ #569 Not tainted
  -------------------------------
  net/bridge/br_private.h:204 suspicious rcu_dereference_protected() usage!

Fix this by doing RCU locking here.

Fixes: b7853d73e39b ("bridge: add vlan info to bridge setlink and dellink notification messages")
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/bridge/br_netlink.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3de0eefe2b82..c72083968768 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -81,17 +81,19 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 	struct net_port_vlans *pv;
 	int num_vlan_infos;
 
+	rcu_read_lock();
 	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
+		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
 	else if (dev->priv_flags & IFF_EBRIDGE)
 		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
 	else
-		return 0;
-
-	if (!pv)
-		return 0;
+		pv = NULL;
+	if (pv)
+		num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
+	else
+		num_vlan_infos = 0;
+	rcu_read_unlock();
 
-	num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
 	if (!num_vlan_infos)
 		return 0;
 
-- 
2.1.4
