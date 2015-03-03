From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2] bridge: fix bridge netlink RCU usage
Date: Tue,  3 Mar 2015 14:46:27 +0100
Message-ID: <1425390387-17651-1-git-send-email-johannes@sipsolutions.net>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55891 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755628AbbCCNqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 08:46:32 -0500
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
 net/bridge/br_netlink.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 17e0177467f5..1583381eebce 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -24,20 +24,19 @@
 
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
-	struct net_port_vlans *pv;
+	unsigned int num_vlans;
 
+	rcu_read_lock();
 	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
+		num_vlans = nbp_get_vlan_info(br_port_get_rcu(dev))->num_vlans;
 	else if (dev->priv_flags & IFF_EBRIDGE)
-		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
+		num_vlans = br_get_vlan_info(netdev_priv(dev))->num_vlans;
 	else
-		return 0;
-
-	if (!pv)
-		return 0;
+		num_vlans = 0;
+	rcu_read_unlock();
 
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
 }
 
 static inline size_t br_port_info_size(void)
-- 
2.1.4
