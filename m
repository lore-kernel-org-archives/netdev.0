From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inetpeer: speed up inetpeer_invalidate_tree()
Date: Mon, 25 Sep 2017 09:14:14 -0700
Message-ID: <1506356054.6617.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:56867 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934227AbdIYQOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:14:16 -0400
Received: by mail-pf0-f178.google.com with SMTP id g65so4015765pfe.13
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:14:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As measured in my prior patch ("sch_netem: faster rb tree removal"),
rbtree_postorder_for_each_entry_safe() is nice looking but much slower
than using rb_next() directly, except when tree is small enough
to fit in CPU caches (then the cost is the same)

From: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inetpeer.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e7eb590c86ce2b33654c17c61619de74ff07bfd1..6e5626cc366c150b13fd44a8e36169c2fb54476d 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -284,14 +284,17 @@ EXPORT_SYMBOL(inet_peer_xrlim_allow);
 
 void inetpeer_invalidate_tree(struct inet_peer_base *base)
 {
-	struct inet_peer *p, *n;
+	struct rb_node *p = rb_first(&base->rb_root);
 
-	rbtree_postorder_for_each_entry_safe(p, n, &base->rb_root, rb_node) {
-		inet_putpeer(p);
+	while (p) {
+		struct inet_peer *peer = rb_entry(p, struct inet_peer, rb_node);
+
+		p = rb_next(p);
+		rb_erase(&peer->rb_node, &base->rb_root);
+		inet_putpeer(peer);
 		cond_resched();
 	}
 
-	base->rb_root = RB_ROOT;
 	base->total = 0;
 }
 EXPORT_SYMBOL(inetpeer_invalidate_tree);
