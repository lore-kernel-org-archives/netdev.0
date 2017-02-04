From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 3/4] bridge: move write-heavy fdb members in their own cache line
Date: Sat,  4 Feb 2017 18:05:08 +0100
Message-ID: <1486227909-18319-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36668 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdBDRFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 12:05:19 -0500
Received: by mail-wm0-f47.google.com with SMTP id c85so74575867wmi.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 09:05:19 -0800 (PST)
In-Reply-To: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fdb's used and updated fields are written to on every packet forward and
packet receive respectively. Thus if we are receiving packets from a
particular fdb, they'll cause false-sharing with everyone who has looked
it up (even if it didn't match, since mac/vid share cache line!). The
"used" field is even worse since it is updated on every packet forward
to that fdb, thus the standard config where X ports use a single gateway
results in 100% fdb false-sharing. Note that this patch does not prevent
the last scenario, but it makes it better for other bridge participants
which are not using that fdb (and are only doing lookups over it).
The point is with this move we make sure that only communicating parties
get the false-sharing, in a later patch we'll show how to avoid that too.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_private.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 47fd64bf5022..1cbbf63a5ef7 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -160,19 +160,21 @@ struct net_bridge_vlan_group {
 	u16				pvid;
 };
 
-struct net_bridge_fdb_entry
-{
+struct net_bridge_fdb_entry {
 	struct hlist_node		hlist;
 	struct net_bridge_port		*dst;
 
-	unsigned long			updated;
-	unsigned long			used;
 	mac_addr			addr;
 	__u16				vlan_id;
 	unsigned char			is_local:1,
 					is_static:1,
 					added_by_user:1,
 					added_by_external_learn:1;
+
+	/* write-heavy members should not affect lookups */
+	unsigned long			updated ____cacheline_aligned_in_smp;
+	unsigned long			used;
+
 	struct rcu_head			rcu;
 };
 
-- 
2.1.4
