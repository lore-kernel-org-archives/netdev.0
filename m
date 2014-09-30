From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net 2/3] bridge: Simplify pvid checks.
Date: Tue, 30 Sep 2014 15:31:01 -0400
Message-ID: <1412105462-340-3-git-send-email-vyasevic@redhat.com>
References: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
Cc: toshiaki.makita1@gmail.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:65145 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbaI3TbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 15:31:15 -0400
Received: by mail-qg0-f46.google.com with SMTP id a108so2352517qge.5
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 12:31:14 -0700 (PDT)
In-Reply-To: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if the pvid is not set, we return an illegal vlan value
even though the pvid value is set to 0.  Since pvid of 0 is currently
invalid, just return 0 instead.  This makes the current and future
checks simpler.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_private.h | 2 +-
 net/bridge/br_vlan.c    | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6fe8680..873d9da 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -647,7 +647,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	 * vid wasn't set
 	 */
 	smp_rmb();
-	return v->pvid ?: VLAN_N_VID;
+	return v->pvid;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 295ad0d..f5eee61 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -223,7 +223,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		 * See if pvid is set on this port.  That tells us which
 		 * vlan untagged or priority-tagged traffic belongs to.
 		 */
-		if (pvid == VLAN_N_VID)
+		if (!pvid)
 			goto drop;
 
 		/* PVID is set on this port.  Any untagged or priority-tagged
@@ -292,7 +292,7 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 
 	if (!*vid) {
 		*vid = br_get_pvid(v);
-		if (*vid == VLAN_N_VID)
+		if (!*vid)
 			return false;
 
 		return true;
-- 
1.9.3
