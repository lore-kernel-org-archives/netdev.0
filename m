From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1] net/ipv4: Use proper RCU APIs for writer-side in udp_offload.c
Date: Sun,  2 Feb 2014 15:42:10 +0200
Message-ID: <1391348530-31643-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Shlomo Pongratz <shlomop@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50734 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751317AbaBBNmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Feb 2014 08:42:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

RCU writer side should use rcu_dereference_protected() and not
rcu_dereference(), fix that. This also removes the "suspicious RCU usage"
warning seen when running with CONFIG_PROVE_RCU.

Also, don't use rcu_assign_pointer/rcu_dereference for pointers
which are invisible beyond the udp offload code.

Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
Reported-by: Eric Dumazet <edumazet@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
---

changes from V0, followed feedback from Eric:

 - avoid using rcu_assign_pointer/rcu_dereference for pointers which are 
   invisible beyond the udp offload code in udp_add_offload

 - set a udp_deref_protected(X) macro to make the code more readable and easy
   to indent

 net/ipv4/udp_offload.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 2ffea6f..88b4023 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -17,6 +17,8 @@
 static DEFINE_SPINLOCK(udp_offload_lock);
 static struct udp_offload_priv __rcu *udp_offload_base __read_mostly;
 
+#define udp_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&udp_offload_lock))
+
 struct udp_offload_priv {
 	struct udp_offload	*offload;
 	struct rcu_head		rcu;
@@ -100,7 +102,6 @@ out:
 
 int udp_add_offload(struct udp_offload *uo)
 {
-	struct udp_offload_priv __rcu **head = &udp_offload_base;
 	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
 
 	if (!new_offload)
@@ -109,8 +110,8 @@ int udp_add_offload(struct udp_offload *uo)
 	new_offload->offload = uo;
 
 	spin_lock(&udp_offload_lock);
-	rcu_assign_pointer(new_offload->next, rcu_dereference(*head));
-	rcu_assign_pointer(*head, new_offload);
+	new_offload->next = udp_offload_base;
+	rcu_assign_pointer(udp_offload_base, new_offload);
 	spin_unlock(&udp_offload_lock);
 
 	return 0;
@@ -130,12 +131,12 @@ void udp_del_offload(struct udp_offload *uo)
 
 	spin_lock(&udp_offload_lock);
 
-	uo_priv = rcu_dereference(*head);
+	uo_priv = udp_deref_protected(*head);
 	for (; uo_priv != NULL;
-		uo_priv = rcu_dereference(*head)) {
-
+	     uo_priv = udp_deref_protected(*head)) {
 		if (uo_priv->offload == uo) {
-			rcu_assign_pointer(*head, rcu_dereference(uo_priv->next));
+			rcu_assign_pointer(*head,
+					   udp_deref_protected(uo_priv->next));
 			goto unlock;
 		}
 		head = &uo_priv->next;
-- 
1.7.1
