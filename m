From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/5] netlink: update listeners directly when removing socket
Date: Mon, 22 Dec 2014 18:56:37 +0100
Message-ID: <1419270999-22165-4-git-send-email-johannes@sipsolutions.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35034 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525AbaLVR4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:46 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The code is now confusing to read - first in one function down
(netlink_remove) any group subscriptions are implicitly removed
by calling __sk_del_bind_node(), but the subscriber database is
only updated far later by calling netlink_update_listeners().

Move the latter call to just after removal from the list so it
is easier to follow the code.

This also enables moving the locking inside the kernel-socket
conditional, which improves the normal socket destruction path.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1117a2cc7c28..df6086f69592 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1111,8 +1111,10 @@ static void netlink_remove(struct sock *sk)
 	mutex_unlock(&nl_sk_hash_lock);
 
 	netlink_table_grab();
-	if (nlk_sk(sk)->subscriptions)
+	if (nlk_sk(sk)->subscriptions) {
 		__sk_del_bind_node(sk);
+		netlink_update_listeners(sk);
+	}
 	netlink_table_ungrab();
 }
 
@@ -1246,8 +1248,8 @@ static int netlink_release(struct socket *sock)
 
 	module_put(nlk->module);
 
-	netlink_table_grab();
 	if (netlink_is_kernel(sk)) {
+		netlink_table_grab();
 		BUG_ON(nl_table[sk->sk_protocol].registered == 0);
 		if (--nl_table[sk->sk_protocol].registered == 0) {
 			struct listeners *old;
@@ -1261,10 +1263,8 @@ static int netlink_release(struct socket *sock)
 			nl_table[sk->sk_protocol].flags = 0;
 			nl_table[sk->sk_protocol].registered = 0;
 		}
-	} else if (nlk->subscriptions) {
-		netlink_update_listeners(sk);
+		netlink_table_ungrab();
 	}
-	netlink_table_ungrab();
 
 	kfree(nlk->groups);
 	nlk->groups = NULL;
-- 
2.1.1
