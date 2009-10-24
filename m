From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next-2.6] ipv6 sit: RCU conversion phase I
Date: Sat, 24 Oct 2009 05:51:26 +0200
Message-ID: <4AE279BE.30600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Yoshifuji Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42356 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbZJXDva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 23:51:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIT tunnels use one rwlock to protect their prl entries.

This first patch adds RCU locking for prl management,
with standard call_rcu() calls.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipip.h |    1
 net/ipv6/sit.c     |   73 +++++++++++++++++++++++++++++--------------
 2 files changed, 51 insertions(+), 23 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 86f1c8b..290effb 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -45,6 +45,7 @@ struct ip_tunnel_prl_entry
 	struct ip_tunnel_prl_entry	*next;
 	__be32				addr;
 	u16				flags;
+	struct rcu_head			rcu_head;
 };
 
 #define IPTUNNEL_XMIT() do {						\
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 510d31f..8cdcc2a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -240,15 +240,22 @@ failed:
 	return NULL;
 }
 
+static DEFINE_SPINLOCK(ipip6_prl_lock);
+
+#define for_each_prl_rcu(start)			\
+	for (prl = rcu_dereference(start);	\
+	     prl;				\
+	     prl = rcu_dereference(prl->next))
+
 static struct ip_tunnel_prl_entry *
 __ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 {
-	struct ip_tunnel_prl_entry *p = (struct ip_tunnel_prl_entry *)NULL;
+	struct ip_tunnel_prl_entry *prl;
 
-	for (p = t->prl; p; p = p->next)
-		if (p->addr == addr)
+	for_each_prl_rcu(t->prl)
+		if (prl->addr == addr)
 			break;
-	return p;
+	return prl;
 
 }
 
@@ -273,7 +280,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 		kcalloc(cmax, sizeof(*kp), GFP_KERNEL) :
 		NULL;
 
-	read_lock(&ipip6_lock);
+	rcu_read_lock();
 
 	ca = t->prl_count < cmax ? t->prl_count : cmax;
 
@@ -291,7 +298,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 	}
 
 	c = 0;
-	for (prl = t->prl; prl; prl = prl->next) {
+	for_each_prl_rcu(t->prl) {
 		if (c >= cmax)
 			break;
 		if (kprl.addr != htonl(INADDR_ANY) && prl->addr != kprl.addr)
@@ -303,7 +310,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 			break;
 	}
 out:
-	read_unlock(&ipip6_lock);
+	rcu_read_unlock();
 
 	len = sizeof(*kp) * c;
 	ret = 0;
@@ -324,12 +331,14 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 	if (a->addr == htonl(INADDR_ANY))
 		return -EINVAL;
 
-	write_lock(&ipip6_lock);
+	spin_lock(&ipip6_prl_lock);
 
 	for (p = t->prl; p; p = p->next) {
 		if (p->addr == a->addr) {
-			if (chg)
-				goto update;
+			if (chg) {
+				p->flags = a->flags;
+				goto out;
+			}
 			err = -EEXIST;
 			goto out;
 		}
@@ -346,46 +355,63 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 		goto out;
 	}
 
+	INIT_RCU_HEAD(&p->rcu_head);
 	p->next = t->prl;
-	t->prl = p;
-	t->prl_count++;
-update:
 	p->addr = a->addr;
 	p->flags = a->flags;
+	t->prl_count++;
+	rcu_assign_pointer(t->prl, p);
 out:
-	write_unlock(&ipip6_lock);
+	spin_unlock(&ipip6_prl_lock);
 	return err;
 }
 
+static void prl_entry_destroy_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ip_tunnel_prl_entry, rcu_head));
+}
+
+static void prl_list_destroy_rcu(struct rcu_head *head)
+{
+	struct ip_tunnel_prl_entry *p, *n;
+
+	p = container_of(head, struct ip_tunnel_prl_entry, rcu_head);
+	do {
+		n = p->next;
+		kfree(p);
+		p = n;
+	} while (p);
+}
+
 static int
 ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 {
 	struct ip_tunnel_prl_entry *x, **p;
 	int err = 0;
 
-	write_lock(&ipip6_lock);
+	spin_lock(&ipip6_prl_lock);
 
 	if (a && a->addr != htonl(INADDR_ANY)) {
 		for (p = &t->prl; *p; p = &(*p)->next) {
 			if ((*p)->addr == a->addr) {
 				x = *p;
 				*p = x->next;
-				kfree(x);
+				call_rcu(&x->rcu_head, prl_entry_destroy_rcu);
 				t->prl_count--;
 				goto out;
 			}
 		}
 		err = -ENXIO;
 	} else {
-		while (t->prl) {
+		if (t->prl) {
+			t->prl_count = 0;
 			x = t->prl;
-			t->prl = t->prl->next;
-			kfree(x);
-			t->prl_count--;
+			call_rcu(&x->rcu_head, prl_list_destroy_rcu);
+			t->prl = NULL;
 		}
 	}
 out:
-	write_unlock(&ipip6_lock);
+	spin_unlock(&ipip6_prl_lock);
 	return err;
 }
 
@@ -395,7 +421,7 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 	struct ip_tunnel_prl_entry *p;
 	int ok = 1;
 
-	read_lock(&ipip6_lock);
+	rcu_read_lock();
 	p = __ipip6_tunnel_locate_prl(t, iph->saddr);
 	if (p) {
 		if (p->flags & PRL_DEFAULT)
@@ -411,7 +437,7 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 		else
 			ok = 0;
 	}
-	read_unlock(&ipip6_lock);
+	rcu_read_unlock();
 	return ok;
 }
 
@@ -1192,6 +1218,7 @@ static void __exit sit_cleanup(void)
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
 	unregister_pernet_gen_device(sit_net_id, &sit_net_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 static int __init sit_init(void)
