From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/53] netns xfrm: add struct xfrm_state::xs_net
Date: Tue, 25 Nov 2008 20:26:35 +0300
Message-ID: <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:41337 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbYKYRXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:36 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23232eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:34 -0800 (PST)
In-Reply-To: <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid unnecessary complications with passing netns around.

* set once, very early after allocating
* once set, never changes

For a while create every xfrm_state in init_net.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h    |   10 +++++++++-
 net/ipv4/ipcomp.c     |    2 +-
 net/ipv6/ipcomp6.c    |    2 +-
 net/key/af_key.c      |    2 +-
 net/xfrm/xfrm_state.c |    9 +++++----
 net/xfrm/xfrm_user.c  |    4 ++--
 6 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9107d6f..9da8903 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -130,6 +130,9 @@ struct xfrm_state_walk {
 /* Full description of state of transformer. */
 struct xfrm_state
 {
+#ifdef CONFIG_NET_NS
+	struct net		*xs_net;
+#endif
 	union {
 		struct hlist_node	gclist;
 		struct hlist_node	bydst;
@@ -223,6 +226,11 @@ struct xfrm_state
 	void			*data;
 };
 
+static inline struct net *xs_net(struct xfrm_state *x)
+{
+	return read_pnet(&x->xs_net);
+}
+
 /* xflags - make enum if more show up */
 #define XFRM_TIME_DEFER	1
 
@@ -1296,7 +1304,7 @@ extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
 extern int xfrm_state_walk(struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
 extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
-extern struct xfrm_state *xfrm_state_alloc(void);
+extern struct xfrm_state *xfrm_state_alloc(struct net *net);
 extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ec8264a..0a35f1b 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -49,7 +49,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 {
 	struct xfrm_state *t;
 
-	t = xfrm_state_alloc();
+	t = xfrm_state_alloc(&init_net);
 	if (t == NULL)
 		goto out;
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index d4576a9..c369638 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -76,7 +76,7 @@ static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 {
 	struct xfrm_state *t = NULL;
 
-	t = xfrm_state_alloc();
+	t = xfrm_state_alloc(&init_net);
 	if (!t)
 		goto out;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b22e01..bde8aad 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1122,7 +1122,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct sadb_msg *hdr,
 	     (key->sadb_key_bits+7) / 8 > key->sadb_key_len * sizeof(uint64_t)))
 		return ERR_PTR(-EINVAL);
 
-	x = xfrm_state_alloc();
+	x = xfrm_state_alloc(&init_net);
 	if (x == NULL)
 		return ERR_PTR(-ENOBUFS);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 268fe3f..81bde76 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -504,13 +504,14 @@ out:
 
 static void xfrm_replay_timer_handler(unsigned long data);
 
-struct xfrm_state *xfrm_state_alloc(void)
+struct xfrm_state *xfrm_state_alloc(struct net *net)
 {
 	struct xfrm_state *x;
 
 	x = kzalloc(sizeof(struct xfrm_state), GFP_ATOMIC);
 
 	if (x) {
+		write_pnet(&x->xs_net, net);
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
 		INIT_LIST_HEAD(&x->km.all);
@@ -835,7 +836,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			error = -EEXIST;
 			goto out;
 		}
-		x = xfrm_state_alloc();
+		x = xfrm_state_alloc(&init_net);
 		if (x == NULL) {
 			error = -ENOMEM;
 			goto out;
@@ -1017,7 +1018,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 	if (!create)
 		return NULL;
 
-	x = xfrm_state_alloc();
+	x = xfrm_state_alloc(&init_net);
 	if (likely(x)) {
 		switch (family) {
 		case AF_INET:
@@ -1125,7 +1126,7 @@ EXPORT_SYMBOL(xfrm_state_add);
 static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 {
 	int err = -ENOMEM;
-	struct xfrm_state *x = xfrm_state_alloc();
+	struct xfrm_state *x = xfrm_state_alloc(&init_net);
 	if (!x)
 		goto error;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ee15d5d..65cdaa5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -320,7 +320,7 @@ static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
 					       struct nlattr **attrs,
 					       int *errp)
 {
-	struct xfrm_state *x = xfrm_state_alloc();
+	struct xfrm_state *x = xfrm_state_alloc(&init_net);
 	int err = -ENOMEM;
 
 	if (!x)
@@ -1663,7 +1663,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct nlattr *rt = attrs[XFRMA_TMPL];
 
 	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
-	struct xfrm_state *x = xfrm_state_alloc();
+	struct xfrm_state *x = xfrm_state_alloc(&init_net);
 	int err = -ENOMEM;
 
 	if (!x)
-- 
1.5.6.5

