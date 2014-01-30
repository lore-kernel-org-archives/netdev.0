From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/ipv4: Use proper RCU APIs for writer-side in udp_offload.c
Date: Thu, 30 Jan 2014 12:51:58 +0200
Message-ID: <1391079118-23922-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49260 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752751AbaA3KwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 05:52:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

RCU writer side should use rcu_dereference_protected() and not
rcu_dereference(), fix that. This also removes the "suspicious RCU usage"
warning seen when running with CONFIG_PROVE_RCU.

Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
---
 net/ipv4/udp_offload.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 2ffea6f..1bf21d4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -109,7 +109,8 @@ int udp_add_offload(struct udp_offload *uo)
 	new_offload->offload = uo;
 
 	spin_lock(&udp_offload_lock);
-	rcu_assign_pointer(new_offload->next, rcu_dereference(*head));
+	rcu_assign_pointer(new_offload->next,
+			   rcu_dereference_protected(*head, lockdep_is_held(&udp_offload_lock)));
 	rcu_assign_pointer(*head, new_offload);
 	spin_unlock(&udp_offload_lock);
 
@@ -130,12 +131,15 @@ void udp_del_offload(struct udp_offload *uo)
 
 	spin_lock(&udp_offload_lock);
 
-	uo_priv = rcu_dereference(*head);
+	uo_priv = rcu_dereference_protected(*head,
+					    lockdep_is_held(&udp_offload_lock));
 	for (; uo_priv != NULL;
-		uo_priv = rcu_dereference(*head)) {
-
+	     uo_priv = rcu_dereference_protected(*head,
+						 lockdep_is_held(&udp_offload_lock))) {
 		if (uo_priv->offload == uo) {
-			rcu_assign_pointer(*head, rcu_dereference(uo_priv->next));
+			rcu_assign_pointer(*head,
+					   rcu_dereference_protected(uo_priv->next,
+								     lockdep_is_held(&udp_offload_lock)));
 			goto unlock;
 		}
 		head = &uo_priv->next;
-- 
1.7.1
