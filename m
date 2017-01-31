From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH RFC net-next 3/4] bridge: move write-heavy fdb members in their own cache line
Date: Tue, 31 Jan 2017 16:31:57 +0100
Message-ID: <1485876718-18091-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35522 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdAaPcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:32:25 -0500
Received: by mail-wm0-f45.google.com with SMTP id b65so84085291wmf.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:32:24 -0800 (PST)
In-Reply-To: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
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
index 9658c6484935..1e1b9a07e2da 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -150,19 +150,21 @@ struct net_bridge_vlan_group {
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
