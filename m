From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net-next 2/3] bridge: Simplify pvid checks.
Date: Fri,  3 Oct 2014 11:29:17 -0400
Message-ID: <1412350158-19061-3-git-send-email-vyasevic@redhat.com>
References: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	toshiaki.makita1@gmail.com, cwang@twopensource.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:41920 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaJCP3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:29:31 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so1089110qgf.34
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:29:30 -0700 (PDT)
In-Reply-To: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if the pvid is not set, we return an illegal vlan value
even though the pvid value is set to 0.  Since pvid of 0 is currently
invalid, just return 0 instead.  This makes the current and future
checks simpler.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_private.h | 7 ++-----
 net/bridge/br_vlan.c    | 4 ++--
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5a347eb..f671561 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -643,11 +643,8 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 
 static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
-	/* Return just the VID if it is set, or VLAN_N_VID (invalid vid) if
-	 * vid wasn't set
-	 */
 	smp_rmb();
-	return v->pvid ?: VLAN_N_VID;
+	return v->pvid;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
@@ -746,7 +743,7 @@ static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 }
 static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
-	return VLAN_N_VID;	/* Returns invalid vid */
+	return 0;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index dfa7c9a..e11c993 100644
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
