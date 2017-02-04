From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] bridge: fdb: write to used and updated at most once per jiffy
Date: Sat,  4 Feb 2017 18:05:09 +0100
Message-ID: <1486227909-18319-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36673 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdBDRFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 12:05:20 -0500
Received: by mail-wm0-f47.google.com with SMTP id c85so74576183wmi.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 09:05:20 -0800 (PST)
In-Reply-To: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writing once per jiffy is enough to limit the bridge's false sharing.
After this change the bridge doesn't show up in the local load HitM stats.

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c   | 3 ++-
 net/bridge/br_input.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5cbed5c0db88..5028691fa68a 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -597,7 +597,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				fdb->dst = source;
 				fdb_modified = true;
 			}
-			fdb->updated = jiffies;
+			if (jiffies != fdb->updated)
+				fdb->updated = jiffies;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
 			if (unlikely(fdb_modified))
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index fba38d8a1a08..220943f920d2 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -198,7 +198,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		if (dst->is_local)
 			return br_pass_frame_up(skb);
 
-		dst->used = jiffies;
+		if (jiffies != dst->used)
+			dst->used = jiffies;
 		br_forward(dst->dst, skb, local_rcv, false);
 	} else {
 		if (!mcast_hit)
-- 
2.1.4
