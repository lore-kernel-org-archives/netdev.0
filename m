From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 4/4] tunnels: add _rcu annotations
Date: Mon, 25 Oct 2010 09:33:16 +0200
Message-ID: <1287991996.2658.5385.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53560 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab0JYHd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 03:33:27 -0400
Received: by wwe15 with SMTP id 15so430522wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(struct ip6_tnl)->next is rcu protected :
(struct ip_tunnel)->next is rcu protected :
(struct xfrm6_tunnel)->next is rcu protected :

add __rcu annotation and proper rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip6_tunnel.h |    2 +-
 include/net/ipip.h       |    2 +-
 include/net/xfrm.h       |    2 +-
 net/ipv4/gre.c           |    5 +++--
 net/ipv6/tunnel6.c       |   24 +++++++++++++++---------
 5 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fc94ec5..fc73e66 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -13,7 +13,7 @@
 /* IPv6 tunnel */
 
 struct ip6_tnl {
-	struct ip6_tnl *next;	/* next tunnel in list */
+	struct ip6_tnl __rcu *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
 	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 58abbf9..0403fe4 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -16,7 +16,7 @@ struct ip_tunnel_6rd_parm {
 };
 
 struct ip_tunnel {
-	struct ip_tunnel	*next;
+	struct ip_tunnel __rcu	*next;
 	struct net_device	*dev;
 
 	int			err_count;	/* Number of arrived ICMP errors */
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f28d7c9..ffcd478 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1272,7 +1272,7 @@ struct xfrm6_tunnel {
 	int (*handler)(struct sk_buff *skb);
 	int (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			   u8 type, u8 code, int offset, __be32 info);
-	struct xfrm6_tunnel *next;
+	struct xfrm6_tunnel __rcu *next;
 	int priority;
 };
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index caea688..c6933f2 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -22,7 +22,7 @@
 #include <net/gre.h>
 
 
-static const struct gre_protocol *gre_proto[GREPROTO_MAX] __read_mostly;
+static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
 static DEFINE_SPINLOCK(gre_proto_lock);
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
@@ -51,7 +51,8 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 		goto err_out;
 
 	spin_lock(&gre_proto_lock);
-	if (gre_proto[version] != proto)
+	if (rcu_dereference_protected(gre_proto[version],
+			lockdep_is_held(&gre_proto_lock)) != proto)
 		goto err_out_unlock;
 	rcu_assign_pointer(gre_proto[version], NULL);
 	spin_unlock(&gre_proto_lock);
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index d986472..4f3cec1 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -30,23 +30,26 @@
 #include <net/protocol.h>
 #include <net/xfrm.h>
 
-static struct xfrm6_tunnel *tunnel6_handlers __read_mostly;
-static struct xfrm6_tunnel *tunnel46_handlers __read_mostly;
+static struct xfrm6_tunnel __rcu *tunnel6_handlers __read_mostly;
+static struct xfrm6_tunnel __rcu *tunnel46_handlers __read_mostly;
 static DEFINE_MUTEX(tunnel6_mutex);
 
 int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family)
 {
-	struct xfrm6_tunnel **pprev;
+	struct xfrm6_tunnel __rcu **pprev;
+	struct xfrm6_tunnel *t;
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
 	mutex_lock(&tunnel6_mutex);
 
 	for (pprev = (family == AF_INET6) ? &tunnel6_handlers : &tunnel46_handlers;
-	     *pprev; pprev = &(*pprev)->next) {
-		if ((*pprev)->priority > priority)
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&tunnel6_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t->priority > priority)
 			break;
-		if ((*pprev)->priority == priority)
+		if (t->priority == priority)
 			goto err;
 	}
 
@@ -65,14 +68,17 @@ EXPORT_SYMBOL(xfrm6_tunnel_register);
 
 int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
 {
-	struct xfrm6_tunnel **pprev;
+	struct xfrm6_tunnel __rcu **pprev;
+	struct xfrm6_tunnel *t;
 	int ret = -ENOENT;
 
 	mutex_lock(&tunnel6_mutex);
 
 	for (pprev = (family == AF_INET6) ? &tunnel6_handlers : &tunnel46_handlers;
-	     *pprev; pprev = &(*pprev)->next) {
-		if (*pprev == handler) {
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&tunnel6_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t == handler) {
 			*pprev = handler->next;
 			ret = 0;
 			break;


