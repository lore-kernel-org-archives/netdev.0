From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] ipv6: addrlabel: remove refcounting
Date: Mon,  9 Oct 2017 09:52:25 -0700
Message-ID: <20171009165225.7008-3-edumazet@google.com>
References: <20171009165225.7008-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:48928 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754971AbdJIQwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:52:33 -0400
Received: by mail-pf0-f179.google.com with SMTP id b79so2051357pfk.5
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:52:33 -0700 (PDT)
In-Reply-To: <20171009165225.7008-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previous patch ("ipv6: addrlabel: rework ip6addrlbl_get()")
we can remove the refcount from struct ip6addrlbl_entry,
since it is no longer elevated in p6addrlbl_get()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrlabel.c | 33 ++++-----------------------------
 1 file changed, 4 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index f31489652c4ae1fc0c93d1756e13717f0689b0ab..2606d2fa3ac4c8e7d13071d1895cf4e6e36a4116 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -18,7 +18,6 @@
 #include <linux/if_addrlabel.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
-#include <linux/refcount.h>
 
 #if 0
 #define ADDRLABEL(x...) printk(x)
@@ -36,7 +35,6 @@ struct ip6addrlbl_entry {
 	int addrtype;
 	u32 label;
 	struct hlist_node list;
-	refcount_t refcnt;
 	struct rcu_head rcu;
 };
 
@@ -111,28 +109,6 @@ static const __net_initconst struct ip6addrlbl_init_table
 	}
 };
 
-/* Object management */
-static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
-{
-	kfree(p);
-}
-
-static void ip6addrlbl_free_rcu(struct rcu_head *h)
-{
-	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
-}
-
-static bool ip6addrlbl_hold(struct ip6addrlbl_entry *p)
-{
-	return refcount_inc_not_zero(&p->refcnt);
-}
-
-static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
-{
-	if (refcount_dec_and_test(&p->refcnt))
-		call_rcu(&p->rcu, ip6addrlbl_free_rcu);
-}
-
 /* Find label */
 static bool __ip6addrlbl_match(const struct ip6addrlbl_entry *p,
 			       const struct in6_addr *addr,
@@ -219,7 +195,6 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
-	refcount_set(&newp->refcnt, 1);
 	return newp;
 }
 
@@ -243,7 +218,7 @@ static int __ip6addrlbl_add(struct net *net, struct ip6addrlbl_entry *newp,
 				goto out;
 			}
 			hlist_replace_rcu(&p->list, &newp->list);
-			ip6addrlbl_put(p);
+			kfree_rcu(p, rcu);
 			goto out;
 		} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
 			   (p->prefixlen < newp->prefixlen)) {
@@ -281,7 +256,7 @@ static int ip6addrlbl_add(struct net *net,
 	ret = __ip6addrlbl_add(net, newp, replace);
 	spin_unlock(&net->ipv6.ip6addrlbl_table.lock);
 	if (ret)
-		ip6addrlbl_free(newp);
+		kfree(newp);
 	return ret;
 }
 
@@ -302,7 +277,7 @@ static int __ip6addrlbl_del(struct net *net,
 		    p->ifindex == ifindex &&
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
-			ip6addrlbl_put(p);
+			kfree_rcu(p, rcu);
 			ret = 0;
 			break;
 		}
@@ -360,7 +335,7 @@ static void __net_exit ip6addrlbl_net_exit(struct net *net)
 	spin_lock(&net->ipv6.ip6addrlbl_table.lock);
 	hlist_for_each_entry_safe(p, n, &net->ipv6.ip6addrlbl_table.head, list) {
 		hlist_del_rcu(&p->list);
-		ip6addrlbl_put(p);
+		kfree_rcu(p, rcu);
 	}
 	spin_unlock(&net->ipv6.ip6addrlbl_table.lock);
 }
-- 
2.14.2.920.gcf0c67979c-goog
