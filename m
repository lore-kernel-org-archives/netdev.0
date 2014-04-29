From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH v2 net-next 7/7] bridge: Automatically manage promisc mode when vlan filtering is on.
Date: Tue, 29 Apr 2014 17:20:28 -0400
Message-ID: <1398806428-640-8-git-send-email-vyasevic@redhat.com>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	jhs@mojatatu.com, john.r.fastabend@intel.com, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994AbaD2VUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 17:20:55 -0400
In-Reply-To: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user doesn't enable vlan filtering, we have to place all
bridge ports in promsic mode so that we retain the capability of
of receiving tagged frames.
When vlan filtering is enabled, the each port will be provided with
necessary vlan configuration and would be able to receive tagged
traffic without promiscouse mode set, thus allowing us to automatically
turn promiscuity on or off depending on the configuration.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_if.c      | 12 ++++++++----
 net/bridge/br_private.h |  9 +++++++++
 net/bridge/br_vlan.c    |  1 +
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d227ad6..ca1953c 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -126,6 +126,13 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
 void br_manage_promisc(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
+	int set_all = false;
+
+	/* If vlan filtering is disabled or bridge interface is placed
+	 * into promiscouse mode, place all ports in promiscuous mode.
+	 */
+	if ((br->dev->flags & IFF_PROMISC) || !br_vlan_enabled(br))
+		set_all = true;
 
 	/* Algorithm is simple.  If all the port require static
 	 * configuration, we know everything and can simply write
@@ -135,10 +142,7 @@ void br_manage_promisc(struct net_bridge *br)
 	 * to this one automatic port and still make non-promisc.
 	 */
 	list_for_each_entry(p, &br->port_list, list) {
-		if (br->dev->flags & IFF_PROMISC) {
-			/* PROMISC flag has been turned on for the bridge
-			 * itself.  Turn on promisc on all ports.
-			 */
+		if (set_all) {
 			br_port_set_promisc(p);
 		} else {
 			if (br->auto_cnt == 0 ||
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f2d93d7..df0bb49 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -643,6 +643,10 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	return v->pvid ?: VLAN_N_VID;
 }
 
+static inline int br_vlan_enabled(struct net_bridge *br)
+{
+	return br->vlan_enabled;
+}
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
@@ -723,6 +727,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
 	return VLAN_N_VID;	/* Returns invalid vid */
 }
+
+static inline int br_vlan_enabled(struct net_bridge *br);
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 4a37161..24c5cc5 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -332,6 +332,7 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 		goto unlock;
 
 	br->vlan_enabled = val;
+	br_manage_promisc(br);
 
 unlock:
 	rtnl_unlock();
-- 
1.9.0
