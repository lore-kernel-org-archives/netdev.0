From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3] bridge: fix bridge netlink RCU usage
Date: Tue,  3 Mar 2015 14:49:16 +0100
Message-ID: <1425390556-17844-1-git-send-email-johannes@sipsolutions.net>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55900 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754148AbbCCNtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 08:49:19 -0500
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
 net/bridge/br_netlink.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 17e0177467f5..72d8efa9b1eb 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -25,19 +25,20 @@
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
 	struct net_port_vlans *pv;
+	unsigned int num_vlans;
 
+	rcu_read_lock();
 	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
+		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
 	else if (dev->priv_flags & IFF_EBRIDGE)
-		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
+		pv = br_get_vlan_info(netdev_priv(dev));
 	else
-		return 0;
-
-	if (!pv)
-		return 0;
+		pv = NULL;
+	num_vlans = pv ? pv->num_vlans : 0;
+	rcu_read_unlock();
 
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
 }
 
 static inline size_t br_port_info_size(void)
-- 
2.1.4
