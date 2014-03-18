From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 02/13] xfrm: Introduce xfrm_input_afinfo to access the the callbacks properly
Date: Tue, 18 Mar 2014 08:21:27 +0100
Message-ID: <1395127298-24083-3-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53245 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbaCRHVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:51 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 can be build as a module, so we need mechanism to access
the address family dependent callback functions properly.
Therefore we introduce xfrm_input_afinfo, similar to that
what we have for the address family dependent part of
policies and states.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |   23 +++++++-------
 net/ipv4/xfrm4_policy.c   |    1 +
 net/ipv4/xfrm4_protocol.c |   13 +++++++-
 net/xfrm/xfrm_input.c     |   75 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 99 insertions(+), 13 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ce3d96f..af13599 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -349,6 +349,16 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
 struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
 void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
+struct xfrm_input_afinfo {
+	unsigned int		family;
+	struct module		*owner;
+	int			(*callback)(struct sk_buff *skb, u8 protocol,
+					    int err);
+};
+
+int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo);
+int xfrm_input_unregister_afinfo(struct xfrm_input_afinfo *afinfo);
+
 void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
 struct xfrm_type {
@@ -1392,6 +1402,7 @@ void xfrm4_init(void);
 int xfrm_state_init(struct net *net);
 void xfrm_state_fini(struct net *net);
 void xfrm4_state_init(void);
+void xfrm4_protocol_init(void);
 #ifdef CONFIG_XFRM
 int xfrm6_init(void);
 void xfrm6_fini(void);
@@ -1773,18 +1784,6 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
-static inline int xfrm_rcv_cb(struct sk_buff *skb, unsigned int family,
-			      u8 protocol, int err)
-{
-	switch(family) {
-#ifdef CONFIG_INET
-	case AF_INET:
-		return xfrm4_rcv_cb(skb, protocol, err);
-#endif
-	}
-	return 0;
-}
-
 static inline int xfrm_tunnel_check(struct sk_buff *skb, struct xfrm_state *x,
 				    unsigned int family)
 {
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index e1a6393..6156f68 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -325,6 +325,7 @@ void __init xfrm4_init(void)
 
 	xfrm4_state_init();
 	xfrm4_policy_init();
+	xfrm4_protocol_init();
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&xfrm4_net_ops);
 #endif
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index cdc09ef..7f7b243 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -179,6 +179,12 @@ static const struct net_protocol ipcomp4_protocol = {
 	.netns_ok	=	1,
 };
 
+static struct xfrm_input_afinfo xfrm4_input_afinfo = {
+	.family		=	AF_INET,
+	.owner		=	THIS_MODULE,
+	.callback	=	xfrm4_rcv_cb,
+};
+
 static inline const struct net_protocol *netproto(unsigned char protocol)
 {
 	switch (protocol) {
@@ -199,7 +205,6 @@ int xfrm4_protocol_register(struct xfrm4_protocol *handler,
 	struct xfrm4_protocol __rcu **pprev;
 	struct xfrm4_protocol *t;
 	bool add_netproto = false;
-
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
@@ -273,3 +278,9 @@ int xfrm4_protocol_deregister(struct xfrm4_protocol *handler,
 	return ret;
 }
 EXPORT_SYMBOL(xfrm4_protocol_deregister);
+
+void __init xfrm4_protocol_init(void)
+{
+	xfrm_input_register_afinfo(&xfrm4_input_afinfo);
+}
+EXPORT_SYMBOL(xfrm4_protocol_init);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 4218164..85d1d47 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -16,6 +16,81 @@
 
 static struct kmem_cache *secpath_cachep __read_mostly;
 
+static DEFINE_SPINLOCK(xfrm_input_afinfo_lock);
+static struct xfrm_input_afinfo __rcu *xfrm_input_afinfo[NPROTO];
+
+int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
+{
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EINVAL;
+	if (unlikely(afinfo->family >= NPROTO))
+		return -EAFNOSUPPORT;
+	spin_lock_bh(&xfrm_input_afinfo_lock);
+	if (unlikely(xfrm_input_afinfo[afinfo->family] != NULL))
+		err = -ENOBUFS;
+	else
+		rcu_assign_pointer(xfrm_input_afinfo[afinfo->family], afinfo);
+	spin_unlock_bh(&xfrm_input_afinfo_lock);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_input_register_afinfo);
+
+int xfrm_input_unregister_afinfo(struct xfrm_input_afinfo *afinfo)
+{
+	int err = 0;
+
+	if (unlikely(afinfo == NULL))
+		return -EINVAL;
+	if (unlikely(afinfo->family >= NPROTO))
+		return -EAFNOSUPPORT;
+	spin_lock_bh(&xfrm_input_afinfo_lock);
+	if (likely(xfrm_input_afinfo[afinfo->family] != NULL)) {
+		if (unlikely(xfrm_input_afinfo[afinfo->family] != afinfo))
+			err = -EINVAL;
+		else
+			RCU_INIT_POINTER(xfrm_input_afinfo[afinfo->family], NULL);
+	}
+	spin_unlock_bh(&xfrm_input_afinfo_lock);
+	synchronize_rcu();
+	return err;
+}
+EXPORT_SYMBOL(xfrm_input_unregister_afinfo);
+
+static struct xfrm_input_afinfo *xfrm_input_get_afinfo(unsigned int family)
+{
+	struct xfrm_input_afinfo *afinfo;
+
+	if (unlikely(family >= NPROTO))
+		return NULL;
+	rcu_read_lock();
+	afinfo = rcu_dereference(xfrm_input_afinfo[family]);
+	if (unlikely(!afinfo))
+		rcu_read_unlock();
+	return afinfo;
+}
+
+static void xfrm_input_put_afinfo(struct xfrm_input_afinfo *afinfo)
+{
+	rcu_read_unlock();
+}
+
+static int xfrm_rcv_cb(struct sk_buff *skb, unsigned int family, u8 protocol,
+		       int err)
+{
+	int ret;
+	struct xfrm_input_afinfo *afinfo = xfrm_input_get_afinfo(family);
+
+	if (!afinfo)
+		return -EAFNOSUPPORT;
+
+	ret = afinfo->callback(skb, protocol, err);
+	xfrm_input_put_afinfo(afinfo);
+
+	return ret;
+}
+
 void __secpath_destroy(struct sec_path *sp)
 {
 	int i;
-- 
1.7.9.5
