From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inetpeer: fix RCU lookup()
Date: Fri, 01 Sep 2017 14:03:32 -0700
Message-ID: <1504299812.15310.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37822 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdIAVDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 17:03:34 -0400
Received: by mail-pg0-f67.google.com with SMTP id t193so773159pgc.4
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 14:03:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Excess of seafood or something happened while I cooked the commit
adding RB tree to inetpeer.

Of course, RCU rules need to be respected or bad things can happen.

In this particular loop, we need to read *pp once per iteration, not
twice.

Fixes: b145425f269a ("inetpeer: remove AVL implementation in favor of RB tree")
Reported-by: John Sperbeck <jsperbeck@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inetpeer.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 337ad41bb80a5fcd3db7ac674292c5b5d462982e..e7eb590c86ce2b33654c17c61619de74ff07bfd1 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -102,15 +102,18 @@ static struct inet_peer *lookup(const struct inetpeer_addr *daddr,
 				struct rb_node **parent_p,
 				struct rb_node ***pp_p)
 {
-	struct rb_node **pp, *parent;
+	struct rb_node **pp, *parent, *next;
 	struct inet_peer *p;
 
 	pp = &base->rb_root.rb_node;
 	parent = NULL;
-	while (*pp) {
+	while (1) {
 		int cmp;
 
-		parent = rcu_dereference_raw(*pp);
+		next = rcu_dereference_raw(*pp);
+		if (!next)
+			break;
+		parent = next;
 		p = rb_entry(parent, struct inet_peer, rb_node);
 		cmp = inetpeer_addr_cmp(daddr, &p->daddr);
 		if (cmp == 0) {
