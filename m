From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ipv6: sit: fix rcu annotations
Date: Thu, 20 Jan 2011 18:16:24 +0100
Message-ID: <1295543784.2825.409.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39128 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343Ab1ATRQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 12:16:27 -0500
Received: by wwa36 with SMTP id 36so876565wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 09:16:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix minor __rcu annotations and remove sparse warnings

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8ce38f1..b1599a3 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -412,7 +412,7 @@ static void prl_list_destroy_rcu(struct rcu_head *head)
 
 	p = container_of(head, struct ip_tunnel_prl_entry, rcu_head);
 	do {
-		n = p->next;
+		n = rcu_dereference_protected(p->next, 1);
 		kfree(p);
 		p = n;
 	} while (p);
@@ -421,15 +421,17 @@ static void prl_list_destroy_rcu(struct rcu_head *head)
 static int
 ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 {
-	struct ip_tunnel_prl_entry *x, **p;
+	struct ip_tunnel_prl_entry *x;
+	struct ip_tunnel_prl_entry __rcu **p;
 	int err = 0;
 
 	ASSERT_RTNL();
 
 	if (a && a->addr != htonl(INADDR_ANY)) {
-		for (p = &t->prl; *p; p = &(*p)->next) {
-			if ((*p)->addr == a->addr) {
-				x = *p;
+		for (p = &t->prl;
+		     (x = rtnl_dereference(*p)) != NULL;
+		     p = &x->next) {
+			if (x->addr == a->addr) {
 				*p = x->next;
 				call_rcu(&x->rcu_head, prl_entry_destroy_rcu);
 				t->prl_count--;
@@ -438,9 +440,9 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 		}
 		err = -ENXIO;
 	} else {
-		if (t->prl) {
+		x = rtnl_dereference(t->prl);
+		if (x) {
 			t->prl_count = 0;
-			x = t->prl;
 			call_rcu(&x->rcu_head, prl_list_destroy_rcu);
 			t->prl = NULL;
 		}
@@ -1179,7 +1181,7 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 	dev_hold(dev);
-	sitn->tunnels_wc[0]	= tunnel;
+	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 	return 0;
 }
 
@@ -1196,11 +1198,12 @@ static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_hea
 	for (prio = 1; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t = sitn->tunnels[prio][h];
+			struct ip_tunnel *t;
 
+			t = rtnl_dereference(sitn->tunnels[prio][h]);
 			while (t != NULL) {
 				unregister_netdevice_queue(t->dev, head);
-				t = t->next;
+				t = rtnl_dereference(t->next);
 			}
 		}
 	}


