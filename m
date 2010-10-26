From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tunnels: add __rcu annotations
Date: Tue, 26 Oct 2010 09:01:26 +0200
Message-ID: <1288076486.3296.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63715 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914Ab0JZHBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 03:01:34 -0400
Received: by wyf28 with SMTP id 28so4262324wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 00:01:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations to :
        (struct ip_tunnel)->prl
        (struct ip_tunnel_prl_entry)->next
        (struct xfrm_tunnel)->next
	struct xfrm_tunnel *tunnel4_handlers
	struct xfrm_tunnel *tunnel64_handlers

And use appropriate rcu primitives to reduce sparse warnings if
CONFIG_SPARSE_RCU_POINTER=y

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipip.h |    4 ++--
 include/net/xfrm.h |    2 +-
 net/ipv4/tunnel4.c |   29 +++++++++++++++++++----------
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 0403fe4..a32654d 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -34,12 +34,12 @@ struct ip_tunnel {
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd_parm	ip6rd;
 #endif
-	struct ip_tunnel_prl_entry	*prl;		/* potential router list */
+	struct ip_tunnel_prl_entry __rcu *prl;		/* potential router list */
 	unsigned int			prl_count;	/* # of entries in PRL */
 };
 
 struct ip_tunnel_prl_entry {
-	struct ip_tunnel_prl_entry	*next;
+	struct ip_tunnel_prl_entry __rcu *next;
 	__be32				addr;
 	u16				flags;
 	struct rcu_head			rcu_head;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ffcd478..bcfb6b2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1264,7 +1264,7 @@ struct xfrm_tunnel {
 	int (*handler)(struct sk_buff *skb);
 	int (*err_handler)(struct sk_buff *skb, u32 info);
 
-	struct xfrm_tunnel *next;
+	struct xfrm_tunnel __rcu *next;
 	int priority;
 };
 
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 9a17bd2..ac3b3ee 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -14,27 +14,32 @@
 #include <net/protocol.h>
 #include <net/xfrm.h>
 
-static struct xfrm_tunnel *tunnel4_handlers __read_mostly;
-static struct xfrm_tunnel *tunnel64_handlers __read_mostly;
+static struct xfrm_tunnel __rcu *tunnel4_handlers __read_mostly;
+static struct xfrm_tunnel __rcu *tunnel64_handlers __read_mostly;
 static DEFINE_MUTEX(tunnel4_mutex);
 
-static inline struct xfrm_tunnel **fam_handlers(unsigned short family)
+static inline struct xfrm_tunnel __rcu **fam_handlers(unsigned short family)
 {
 	return (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
 }
 
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
 {
-	struct xfrm_tunnel **pprev;
+	struct xfrm_tunnel __rcu **pprev;
+	struct xfrm_tunnel *t;
+
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = fam_handlers(family); *pprev; pprev = &(*pprev)->next) {
-		if ((*pprev)->priority > priority)
+	for (pprev = fam_handlers(family);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&tunnel4_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t->priority > priority)
 			break;
-		if ((*pprev)->priority == priority)
+		if (t->priority == priority)
 			goto err;
 	}
 
@@ -52,13 +57,17 @@ EXPORT_SYMBOL(xfrm4_tunnel_register);
 
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
 {
-	struct xfrm_tunnel **pprev;
+	struct xfrm_tunnel __rcu **pprev;
+	struct xfrm_tunnel *t;
 	int ret = -ENOENT;
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = fam_handlers(family); *pprev; pprev = &(*pprev)->next) {
-		if (*pprev == handler) {
+	for (pprev = fam_handlers(family);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&tunnel4_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t == handler) {
 			*pprev = handler->next;
 			ret = 0;
 			break;


