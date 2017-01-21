From: Kevin Cernekee <cernekee@chromium.org>
Subject: [PATCH 1/4] xfrm: Constify xfrm_user arguments and xfrm_mgr callback APIs
Date: Fri, 20 Jan 2017 16:05:04 -0800
Message-ID: <20170121000507.34381-2-cernekee@chromium.org>
References: <20170121000507.34381-1-cernekee@chromium.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, fan.du@windriver.com,
        dianders@chromium.org, dtor@chromium.org
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, paul@paul-moore.com, sds@tycho.nsa.gov,
        eparis@parisplace.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170121000507.34381-1-cernekee@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This provides a better sense of the data flow and inputs/outputs.  No
change to code size or functionality.

Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
---
 include/net/xfrm.h     |  36 ++++--
 net/key/af_key.c       |  34 +++--
 net/xfrm/xfrm_policy.c |   8 +-
 net/xfrm/xfrm_state.c  |   2 +-
 net/xfrm/xfrm_user.c   | 342 +++++++++++++++++++++++++++++--------------------
 5 files changed, 253 insertions(+), 169 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 31947b9c21d6..34298d78ba45 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -228,7 +228,7 @@ struct xfrm_state {
 	void			*data;
 };
 
-static inline struct net *xs_net(struct xfrm_state *x)
+static inline struct net *xs_net(const struct xfrm_state *x)
 {
 	return read_pnet(&x->xs_net);
 }
@@ -587,12 +587,23 @@ struct xfrm_migrate {
 struct xfrm_mgr {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, const struct km_event *c);
-	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp);
-	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
-	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
-	int			(*notify_policy)(struct xfrm_policy *x, int dir, const struct km_event *c);
-	int			(*report)(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+	int			(*notify)(const struct xfrm_state *x,
+					  const struct km_event *c);
+	int			(*acquire)(struct xfrm_state *x,
+					   const struct xfrm_tmpl *,
+					   const struct xfrm_policy *xp);
+	struct xfrm_policy	*(*compile_policy)(struct sock *sk,
+						   int opt, u8 *data,
+						   int len, int *dir);
+	int			(*new_mapping)(struct xfrm_state *x,
+					       const xfrm_address_t *ipaddr,
+					       __be16 sport);
+	int			(*notify_policy)(const struct xfrm_policy *x,
+						 int dir,
+						 const struct km_event *c);
+	int			(*report)(struct net *net, u8 proto,
+					  const struct xfrm_selector *sel,
+					  const xfrm_address_t *addr);
 	int			(*migrate)(const struct xfrm_selector *sel,
 					   u8 dir, u8 type,
 					   const struct xfrm_migrate *m,
@@ -1432,7 +1443,7 @@ static inline void xfrm_sysctl_fini(struct net *net)
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
 			  struct xfrm_address_filter *filter);
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
-		    int (*func)(struct xfrm_state *, int, void*), void *);
+		    int (*func)(const struct xfrm_state *, int, void*), void *);
 void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
 struct xfrm_state *xfrm_state_alloc(struct net *net);
 struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
@@ -1584,13 +1595,13 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
 void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
 int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
-		     int (*func)(struct xfrm_policy *, int, int, void*),
+		     int (*func)(const struct xfrm_policy *, int, int, void*),
 		     void *);
 void xfrm_policy_walk_done(struct xfrm_policy_walk *walk, struct net *net);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 					  u8 type, int dir,
-					  struct xfrm_selector *sel,
+					  const struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
 struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
@@ -1695,7 +1706,7 @@ static inline int xfrm_acquire_is_on(struct net *net)
 }
 #endif
 
-static inline int aead_len(struct xfrm_algo_aead *alg)
+static inline int aead_len(const struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
@@ -1710,7 +1721,8 @@ static inline int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static inline int xfrm_replay_state_esn_len(struct xfrm_replay_state_esn *replay_esn)
+static inline int xfrm_replay_state_esn_len(
+		const struct xfrm_replay_state_esn *replay_esn)
 {
 	return sizeof(*replay_esn) + replay_esn->bmp_len * sizeof(__u32);
 }
diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed42c1d..b09a48c4c1fb 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1433,7 +1433,7 @@ static inline int event2keytype(int event)
 }
 
 /* ADD/UPD/DEL */
-static int key_notify_sa(struct xfrm_state *x, const struct km_event *c)
+static int key_notify_sa(const struct xfrm_state *x, const struct km_event *c)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -1744,7 +1744,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_m
 	return 0;
 }
 
-static int dump_sa(struct xfrm_state *x, int count, void *ptr)
+static int dump_sa(const struct xfrm_state *x, int count, void *ptr)
 {
 	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
@@ -1851,7 +1851,8 @@ static int pfkey_promisc(struct sock *sk, struct sk_buff *skb, const struct sadb
 	return 0;
 }
 
-static int check_reqid(struct xfrm_policy *xp, int dir, int count, void *ptr)
+static int check_reqid(const struct xfrm_policy *xp, int dir, int count,
+		       void *ptr)
 {
 	int i;
 	u32 reqid = *(u32*)ptr;
@@ -2157,7 +2158,9 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	return 0;
 }
 
-static int key_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
+static int key_notify_policy(const struct xfrm_policy *xp,
+			     int dir,
+			     const struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
@@ -2628,7 +2631,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	return err;
 }
 
-static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
+static int dump_sp(const struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
 	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
@@ -2961,12 +2964,14 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 	}
 }
 
-static int key_notify_policy_expire(struct xfrm_policy *xp, const struct km_event *c)
+static int key_notify_policy_expire(const struct xfrm_policy *xp,
+				    const struct km_event *c)
 {
 	return 0;
 }
 
-static int key_notify_sa_expire(struct xfrm_state *x, const struct km_event *c)
+static int key_notify_sa_expire(const struct xfrm_state *x,
+				const struct km_event *c)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
@@ -2996,7 +3001,8 @@ static int key_notify_sa_expire(struct xfrm_state *x, const struct km_event *c)
 	return 0;
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, const struct km_event *c)
+static int pfkey_send_notify(const struct xfrm_state *x,
+			     const struct km_event *c)
 {
 	struct net *net = x ? xs_net(x) : c->net;
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
@@ -3023,7 +3029,9 @@ static int pfkey_send_notify(struct xfrm_state *x, const struct km_event *c)
 	return 0;
 }
 
-static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
+static int pfkey_send_policy_notify(const struct xfrm_policy *xp,
+				    int dir,
+				    const struct km_event *c)
 {
 	if (xp && xp->type != XFRM_POLICY_TYPE_MAIN)
 		return 0;
@@ -3076,7 +3084,9 @@ static bool pfkey_is_alive(const struct km_event *c)
 	return is_alive;
 }
 
-static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *xp)
+static int pfkey_send_acquire(struct xfrm_state *x,
+			      const struct xfrm_tmpl *t,
+			      const struct xfrm_policy *xp)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
@@ -3273,7 +3283,9 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 	return NULL;
 }
 
-static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport)
+static int pfkey_send_new_mapping(struct xfrm_state *x,
+				  const xfrm_address_t *ipaddr,
+				  __be16 sport)
 {
 	struct sk_buff *skb;
 	struct sadb_msg *hdr;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 177e208e8ff5..dc51dec54043 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -709,7 +709,8 @@ static u32 xfrm_gen_index(struct net *net, int dir, u32 index)
 	}
 }
 
-static inline int selector_cmp(struct xfrm_selector *s1, struct xfrm_selector *s2)
+static inline int selector_cmp(const struct xfrm_selector *s1,
+			       const struct xfrm_selector *s2)
 {
 	u32 *p1 = (u32 *) s1;
 	u32 *p2 = (u32 *) s2;
@@ -833,7 +834,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 EXPORT_SYMBOL(xfrm_policy_insert);
 
 struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
-					  int dir, struct xfrm_selector *sel,
+					  int dir,
+					  const struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err)
 {
@@ -1016,7 +1018,7 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 EXPORT_SYMBOL(xfrm_policy_flush);
 
 int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
-		     int (*func)(struct xfrm_policy *, int, int, void*),
+		     int (*func)(const struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
 	struct xfrm_policy *pol;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 64e3c82eedf6..4513a621b0d5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1642,7 +1642,7 @@ static bool __xfrm_state_filter_match(struct xfrm_state *x,
 }
 
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
-		    int (*func)(struct xfrm_state *, int, void*),
+		    int (*func)(const struct xfrm_state *, int, void*),
 		    void *data)
 {
 	struct xfrm_state *state;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9705c279494b..ed389aad4994 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -115,7 +115,7 @@ static inline int verify_sec_ctx_len(struct nlattr **attrs)
 	return 0;
 }
 
-static inline int verify_replay(struct xfrm_usersa_info *p,
+static inline int verify_replay(const struct xfrm_usersa_info *p,
 				struct nlattr **attrs)
 {
 	struct nlattr *rt = attrs[XFRMA_REPLAY_ESN_VAL];
@@ -148,7 +148,7 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 	return 0;
 }
 
-static int verify_newsa_info(struct xfrm_usersa_info *p,
+static int verify_newsa_info(const struct xfrm_usersa_info *p,
 			     struct nlattr **attrs)
 {
 	int err;
@@ -264,11 +264,14 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 	return err;
 }
 
-static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
-			   struct xfrm_algo_desc *(*get_byname)(const char *, int),
-			   struct nlattr *rta)
+static int attach_one_algo(
+	struct xfrm_algo **algpp,
+	u8 *props,
+	struct xfrm_algo_desc *(*get_byname)(const char *, int),
+	const struct nlattr *rta)
 {
-	struct xfrm_algo *p, *ualg;
+	const struct xfrm_algo *ualg;
+	struct xfrm_algo *p;
 	struct xfrm_algo_desc *algo;
 
 	if (!rta)
@@ -290,9 +293,10 @@ static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 	return 0;
 }
 
-static int attach_crypt(struct xfrm_state *x, struct nlattr *rta)
+static int attach_crypt(struct xfrm_state *x, const struct nlattr *rta)
 {
-	struct xfrm_algo *p, *ualg;
+	const struct xfrm_algo *ualg;
+	struct xfrm_algo *p;
 	struct xfrm_algo_desc *algo;
 
 	if (!rta)
@@ -316,9 +320,9 @@ static int attach_crypt(struct xfrm_state *x, struct nlattr *rta)
 }
 
 static int attach_auth(struct xfrm_algo_auth **algpp, u8 *props,
-		       struct nlattr *rta)
+		       const struct nlattr *rta)
 {
-	struct xfrm_algo *ualg;
+	const struct xfrm_algo *ualg;
 	struct xfrm_algo_auth *p;
 	struct xfrm_algo_desc *algo;
 
@@ -346,9 +350,10 @@ static int attach_auth(struct xfrm_algo_auth **algpp, u8 *props,
 }
 
 static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
-			     struct nlattr *rta)
+			     const struct nlattr *rta)
 {
-	struct xfrm_algo_auth *p, *ualg;
+	const struct xfrm_algo_auth *ualg;
+	struct xfrm_algo_auth *p;
 	struct xfrm_algo_desc *algo;
 
 	if (!rta)
@@ -375,9 +380,10 @@ static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
 	return 0;
 }
 
-static int attach_aead(struct xfrm_state *x, struct nlattr *rta)
+static int attach_aead(struct xfrm_state *x, const struct nlattr *rta)
 {
-	struct xfrm_algo_aead *p, *ualg;
+	const struct xfrm_algo_aead *ualg;
+	struct xfrm_algo_aead *p;
 	struct xfrm_algo_desc *algo;
 
 	if (!rta)
@@ -400,10 +406,11 @@ static int attach_aead(struct xfrm_state *x, struct nlattr *rta)
 	return 0;
 }
 
-static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_esn,
-					 struct nlattr *rp)
+static inline int xfrm_replay_verify_len(
+	const struct xfrm_replay_state_esn *replay_esn,
+	const struct nlattr *rp)
 {
-	struct xfrm_replay_state_esn *up;
+	const struct xfrm_replay_state_esn *up;
 	int ulen;
 
 	if (!replay_esn || !rp)
@@ -418,11 +425,13 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
 	return 0;
 }
 
-static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn,
-				       struct xfrm_replay_state_esn **preplay_esn,
-				       struct nlattr *rta)
+static int xfrm_alloc_replay_state_esn(
+	struct xfrm_replay_state_esn **replay_esn,
+	struct xfrm_replay_state_esn **preplay_esn,
+	const struct nlattr *rta)
 {
-	struct xfrm_replay_state_esn *p, *pp, *up;
+	struct xfrm_replay_state_esn *p, *pp;
+	const struct xfrm_replay_state_esn *up;
 	int klen, ulen;
 
 	if (!rta)
@@ -451,7 +460,7 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
 	return 0;
 }
 
-static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
+static inline int xfrm_user_sec_ctx_size(const struct xfrm_sec_ctx *xfrm_ctx)
 {
 	int len = 0;
 
@@ -462,7 +471,8 @@ static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 	return len;
 }
 
-static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
+static void copy_from_user_state(struct xfrm_state *x,
+				 const struct xfrm_usersa_info *p)
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
 	memcpy(&x->sel, &p->sel, sizeof(x->sel));
@@ -484,17 +494,19 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
  * somehow made shareable and move it to xfrm_state.c - JHS
  *
 */
-static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs,
+static void xfrm_update_ae_params(struct xfrm_state *x,
+				  struct nlattr **attrs,
 				  int update_esn)
 {
-	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
-	struct nlattr *re = update_esn ? attrs[XFRMA_REPLAY_ESN_VAL] : NULL;
-	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
-	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
-	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
+	const struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	const struct nlattr *re =
+		update_esn ? attrs[XFRMA_REPLAY_ESN_VAL] : NULL;
+	const struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
+	const struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
+	const struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
 	if (re) {
-		struct xfrm_replay_state_esn *replay_esn;
+		const struct xfrm_replay_state_esn *replay_esn;
 		replay_esn = nla_data(re);
 		memcpy(x->replay_esn, replay_esn,
 		       xfrm_replay_state_esn_len(replay_esn));
@@ -503,14 +515,14 @@ static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs,
 	}
 
 	if (rp) {
-		struct xfrm_replay_state *replay;
+		const struct xfrm_replay_state *replay;
 		replay = nla_data(rp);
 		memcpy(&x->replay, replay, sizeof(*replay));
 		memcpy(&x->preplay, replay, sizeof(*replay));
 	}
 
 	if (lt) {
-		struct xfrm_lifetime_cur *ltime;
+		const struct xfrm_lifetime_cur *ltime;
 		ltime = nla_data(lt);
 		x->curlft.bytes = ltime->bytes;
 		x->curlft.packets = ltime->packets;
@@ -526,7 +538,7 @@ static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs,
 }
 
 static struct xfrm_state *xfrm_state_construct(struct net *net,
-					       struct xfrm_usersa_info *p,
+					       const struct xfrm_usersa_info *p,
 					       struct nlattr **attrs,
 					       int *errp)
 {
@@ -613,11 +625,11 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	return NULL;
 }
 
-static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
-	struct xfrm_usersa_info *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_info *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
@@ -655,7 +667,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 
 static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
-						 struct xfrm_usersa_id *p,
+						 const struct xfrm_usersa_id *p,
 						 struct nlattr **attrs,
 						 int *errp)
 {
@@ -688,14 +700,14 @@ static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
 	return x;
 }
 
-static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_del_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	int err = -ESRCH;
 	struct km_event c;
-	struct xfrm_usersa_id *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_id *p = nlmsg_data(nlh);
 
 	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
@@ -725,7 +737,8 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static void copy_to_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
+static void copy_to_user_state(const struct xfrm_state *x,
+			       struct xfrm_usersa_info *p)
 {
 	memset(p, 0, sizeof(*p));
 	memcpy(&p->id, &x->id, sizeof(p->id));
@@ -751,7 +764,7 @@ struct xfrm_dump_info {
 	u16 nlmsg_flags;
 };
 
-static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
+static int copy_sec_ctx(const struct xfrm_sec_ctx *s, struct sk_buff *skb)
 {
 	struct xfrm_user_sec_ctx *uctx;
 	struct nlattr *attr;
@@ -772,7 +785,8 @@ static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 	return 0;
 }
 
-static int copy_to_user_auth(struct xfrm_algo_auth *auth, struct sk_buff *skb)
+static int copy_to_user_auth(const struct xfrm_algo_auth *auth,
+			     struct sk_buff *skb)
 {
 	struct xfrm_algo *algo;
 	struct nlattr *nla;
@@ -791,7 +805,7 @@ static int copy_to_user_auth(struct xfrm_algo_auth *auth, struct sk_buff *skb)
 }
 
 /* Don't change this without updating xfrm_sa_len! */
-static int copy_to_user_state_extra(struct xfrm_state *x,
+static int copy_to_user_state_extra(const struct xfrm_state *x,
 				    struct xfrm_usersa_info *p,
 				    struct sk_buff *skb)
 {
@@ -868,7 +882,7 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	return ret;
 }
 
-static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
+static int dump_one_state(const struct xfrm_state *x, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *in_skb = sp->in_skb;
@@ -950,7 +964,8 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
-					  struct xfrm_state *x, u32 seq)
+					  const struct xfrm_state *x,
+					  u32 seq)
 {
 	struct xfrm_dump_info info;
 	struct sk_buff *skb;
@@ -1050,7 +1065,7 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	return 0;
 }
 
-static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
+static int xfrm_set_spdinfo(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			    struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1095,12 +1110,12 @@ static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_get_spdinfo(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			    struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
-	u32 *flags = nlmsg_data(nlh);
+	const u32 *flags = nlmsg_data(nlh);
 	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
 
@@ -1153,12 +1168,12 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 	return 0;
 }
 
-static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_get_sadinfo(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			    struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
-	u32 *flags = nlmsg_data(nlh);
+	const u32 *flags = nlmsg_data(nlh);
 	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
 
@@ -1172,11 +1187,11 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
 
-static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_get_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
-	struct xfrm_usersa_id *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
 	int err = -ESRCH;
@@ -1196,14 +1211,14 @@ static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_alloc_userspi(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
-	struct xfrm_userspi_info *p;
+	const struct xfrm_userspi_info *p;
 	struct sk_buff *resp_skb;
-	xfrm_address_t *daddr;
+	const xfrm_address_t *daddr;
 	int family;
 	int err;
 	u32 mark;
@@ -1286,7 +1301,7 @@ static int verify_policy_type(u8 type)
 	return 0;
 }
 
-static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
+static int verify_newpolicy_info(const struct xfrm_userpolicy_info *p)
 {
 	int ret;
 
@@ -1346,7 +1361,8 @@ static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs
 	return security_xfrm_policy_alloc(&pol->security, uctx, GFP_KERNEL);
 }
 
-static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
+static void copy_templates(struct xfrm_policy *xp,
+			   const struct xfrm_user_tmpl *ut,
 			   int nr)
 {
 	int i;
@@ -1444,7 +1460,8 @@ static int copy_from_user_policy_type(u8 *tp, struct nlattr **attrs)
 	return 0;
 }
 
-static void copy_from_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_info *p)
+static void copy_from_user_policy(struct xfrm_policy *xp,
+				  const struct xfrm_userpolicy_info *p)
 {
 	xp->priority = p->priority;
 	xp->index = p->index;
@@ -1456,7 +1473,9 @@ static void copy_from_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy
 	/* XXX xp->share = p->share; */
 }
 
-static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_info *p, int dir)
+static void copy_to_user_policy(const struct xfrm_policy *xp,
+				struct xfrm_userpolicy_info *p,
+				int dir)
 {
 	memset(p, 0, sizeof(*p));
 	memcpy(&p->sel, &xp->selector, sizeof(p->sel));
@@ -1471,7 +1490,11 @@ static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_i
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static struct xfrm_policy *xfrm_policy_construct(struct net *net, struct xfrm_userpolicy_info *p, struct nlattr **attrs, int *errp)
+static struct xfrm_policy *xfrm_policy_construct(
+	struct net *net,
+	const struct xfrm_userpolicy_info *p,
+	struct nlattr **attrs,
+	int *errp)
 {
 	struct xfrm_policy *xp = xfrm_policy_alloc(net, GFP_KERNEL);
 	int err;
@@ -1502,11 +1525,11 @@ static struct xfrm_policy *xfrm_policy_construct(struct net *net, struct xfrm_us
 	return NULL;
 }
 
-static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
-	struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
+	const struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
 	struct km_event c;
 	int err;
@@ -1547,7 +1570,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static int copy_to_user_tmpl(struct xfrm_policy *xp, struct sk_buff *skb)
+static int copy_to_user_tmpl(const struct xfrm_policy *xp, struct sk_buff *skb)
 {
 	struct xfrm_user_tmpl vec[XFRM_MAX_DEPTH];
 	int i;
@@ -1557,7 +1580,7 @@ static int copy_to_user_tmpl(struct xfrm_policy *xp, struct sk_buff *skb)
 
 	for (i = 0; i < xp->xfrm_nr; i++) {
 		struct xfrm_user_tmpl *up = &vec[i];
-		struct xfrm_tmpl *kp = &xp->xfrm_vec[i];
+		const struct xfrm_tmpl *kp = &xp->xfrm_vec[i];
 
 		memset(up, 0, sizeof(*up));
 		memcpy(&up->id, &kp->id, sizeof(up->id));
@@ -1576,7 +1599,8 @@ static int copy_to_user_tmpl(struct xfrm_policy *xp, struct sk_buff *skb)
 		       sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr, vec);
 }
 
-static inline int copy_to_user_state_sec_ctx(struct xfrm_state *x, struct sk_buff *skb)
+static inline int copy_to_user_state_sec_ctx(const struct xfrm_state *x,
+					     struct sk_buff *skb)
 {
 	if (x->security) {
 		return copy_sec_ctx(x->security, skb);
@@ -1584,7 +1608,8 @@ static inline int copy_to_user_state_sec_ctx(struct xfrm_state *x, struct sk_buf
 	return 0;
 }
 
-static inline int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *skb)
+static inline int copy_to_user_sec_ctx(const struct xfrm_policy *xp,
+				       struct sk_buff *skb)
 {
 	if (xp->security)
 		return copy_sec_ctx(xp->security, skb);
@@ -1616,7 +1641,10 @@ static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 }
 #endif
 
-static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
+static int dump_one_policy(const struct xfrm_policy *xp,
+			   int dir,
+			   int count,
+			   void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
 	struct xfrm_userpolicy_info *p;
@@ -1681,8 +1709,9 @@ static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
-					  struct xfrm_policy *xp,
-					  int dir, u32 seq)
+					   const struct xfrm_policy *xp,
+					   int dir,
+					   u32 seq)
 {
 	struct xfrm_dump_info info;
 	struct sk_buff *skb;
@@ -1706,12 +1735,12 @@ static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
-static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
-	struct xfrm_userpolicy_id *p;
+	const struct xfrm_userpolicy_id *p;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 	struct km_event c;
@@ -1785,12 +1814,12 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_flush_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct km_event c;
-	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_flush *p = nlmsg_data(nlh);
 	int err;
 
 	err = xfrm_state_flush(net, p->proto, true);
@@ -1809,7 +1838,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static inline size_t xfrm_aevent_msgsize(struct xfrm_state *x)
+static inline size_t xfrm_aevent_msgsize(const struct xfrm_state *x)
 {
 	size_t replay_size = x->replay_esn ?
 			      xfrm_replay_state_esn_len(x->replay_esn) :
@@ -1823,7 +1852,9 @@ static inline size_t xfrm_aevent_msgsize(struct xfrm_state *x)
 	       + nla_total_size(4); /* XFRM_AE_ETHR */
 }
 
-static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct km_event *c)
+static int build_aevent(struct sk_buff *skb,
+			const struct xfrm_state *x,
+			const struct km_event *c)
 {
 	struct xfrm_aevent_id *id;
 	struct nlmsghdr *nlh;
@@ -1880,8 +1911,8 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	return err;
 }
 
-static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_get_ae(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
@@ -1890,8 +1921,8 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	u32 mark;
 	struct xfrm_mark m;
-	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	struct xfrm_usersa_id *id = &p->sa_id;
+	const struct xfrm_aevent_id *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_id *id = &p->sa_id;
 
 	mark = xfrm_mark_get(attrs, &m);
 
@@ -1923,8 +1954,8 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_new_ae(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
@@ -1932,12 +1963,12 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err = -EINVAL;
 	u32 mark = 0;
 	struct xfrm_mark m;
-	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
-	struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
-	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
-	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
-	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
+	const struct xfrm_aevent_id *p = nlmsg_data(nlh);
+	const struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
+	const struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
+	const struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
+	const struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
+	const struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
 	if (!lt && !rp && !re && !et && !rt)
 		return err;
@@ -1974,8 +2005,8 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_flush_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct km_event c;
@@ -2002,13 +2033,13 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_add_pol_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
-	struct xfrm_user_polexpire *up = nlmsg_data(nlh);
-	struct xfrm_userpolicy_info *p = &up->pol;
+	const struct xfrm_user_polexpire *up = nlmsg_data(nlh);
+	const struct xfrm_userpolicy_info *p = &up->pol;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 	struct xfrm_mark m;
@@ -2062,14 +2093,14 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_add_sa_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	int err;
-	struct xfrm_user_expire *ue = nlmsg_data(nlh);
-	struct xfrm_usersa_info *p = &ue->state;
+	const struct xfrm_user_expire *ue = nlmsg_data(nlh);
+	const struct xfrm_usersa_info *p = &ue->state;
 	struct xfrm_mark m;
 	u32 mark = xfrm_mark_get(attrs, &m);
 
@@ -2096,8 +2127,8 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
-		struct nlattr **attrs)
+static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			    struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
@@ -2106,7 +2137,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct nlattr *rt = attrs[XFRMA_TMPL];
 	struct xfrm_mark mark;
 
-	struct xfrm_user_acquire *ua = nlmsg_data(nlh);
+	const struct xfrm_user_acquire *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc(net);
 	int err = -ENOMEM;
 
@@ -2160,12 +2191,12 @@ static int copy_from_user_migrate(struct xfrm_migrate *ma,
 				  struct xfrm_kmaddress *k,
 				  struct nlattr **attrs, int *num)
 {
-	struct nlattr *rt = attrs[XFRMA_MIGRATE];
-	struct xfrm_user_migrate *um;
+	const struct nlattr *rt = attrs[XFRMA_MIGRATE];
+	const struct xfrm_user_migrate *um;
 	int i, num_migrate;
 
 	if (k != NULL) {
-		struct xfrm_user_kmaddress *uk;
+		const struct xfrm_user_kmaddress *uk;
 
 		uk = nla_data(attrs[XFRMA_KMADDRESS]);
 		memcpy(&k->local, &uk->local, sizeof(k->local));
@@ -2198,10 +2229,10 @@ static int copy_from_user_migrate(struct xfrm_migrate *ma,
 	return 0;
 }
 
-static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
+static int xfrm_do_migrate(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			   struct nlattr **attrs)
 {
-	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
+	const struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
 	struct xfrm_kmaddress km, *kmp;
 	u8 type;
@@ -2230,7 +2261,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 #else
-static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
+static int xfrm_do_migrate(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			   struct nlattr **attrs)
 {
 	return -ENOPROTOOPT;
@@ -2238,7 +2269,8 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
-static int copy_to_user_migrate(const struct xfrm_migrate *m, struct sk_buff *skb)
+static int copy_to_user_migrate(const struct xfrm_migrate *m,
+				struct sk_buff *skb)
 {
 	struct xfrm_user_migrate um;
 
@@ -2256,7 +2288,8 @@ static int copy_to_user_migrate(const struct xfrm_migrate *m, struct sk_buff *sk
 	return nla_put(skb, XFRMA_MIGRATE, sizeof(um), &um);
 }
 
-static int copy_to_user_kmaddress(const struct xfrm_kmaddress *k, struct sk_buff *skb)
+static int copy_to_user_kmaddress(const struct xfrm_kmaddress *k,
+				  struct sk_buff *skb)
 {
 	struct xfrm_user_kmaddress uk;
 
@@ -2407,7 +2440,9 @@ static const struct nla_policy xfrma_spd_policy[XFRMA_SPD_MAX+1] = {
 };
 
 static const struct xfrm_link {
-	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
+	int (*doit)(struct sk_buff *,
+		    const struct nlmsghdr *,
+		    struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
 	const struct nla_policy *nla_pol;
@@ -2506,7 +2541,9 @@ static inline size_t xfrm_expire_msgsize(void)
 	       + nla_total_size(sizeof(struct xfrm_mark));
 }
 
-static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct km_event *c)
+static int build_expire(struct sk_buff *skb,
+			const struct xfrm_state *x,
+			const struct km_event *c)
 {
 	struct xfrm_user_expire *ue;
 	struct nlmsghdr *nlh;
@@ -2528,7 +2565,8 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 	return 0;
 }
 
-static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
+static int xfrm_exp_state_notify(const struct xfrm_state *x,
+				 const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2545,7 +2583,8 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, const struct km_event *c)
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
-static int xfrm_aevent_state_notify(struct xfrm_state *x, const struct km_event *c)
+static int xfrm_aevent_state_notify(const struct xfrm_state *x,
+				    const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2586,7 +2625,7 @@ static int xfrm_notify_sa_flush(const struct km_event *c)
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_SA);
 }
 
-static inline size_t xfrm_sa_len(struct xfrm_state *x)
+static inline size_t xfrm_sa_len(const struct xfrm_state *x)
 {
 	size_t l = 0;
 	if (x->aead)
@@ -2622,7 +2661,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 	return l;
 }
 
-static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
+static int xfrm_notify_sa(const struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = xs_net(x);
 	struct xfrm_usersa_info *p;
@@ -2679,7 +2718,8 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	return err;
 }
 
-static int xfrm_send_state_notify(struct xfrm_state *x, const struct km_event *c)
+static int xfrm_send_state_notify(const struct xfrm_state *x,
+				  const struct km_event *c)
 {
 
 	switch (c->event) {
@@ -2703,8 +2743,8 @@ static int xfrm_send_state_notify(struct xfrm_state *x, const struct km_event *c
 
 }
 
-static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
-					  struct xfrm_policy *xp)
+static inline size_t xfrm_acquire_msgsize(const struct xfrm_state *x,
+					  const struct xfrm_policy *xp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
@@ -2713,8 +2753,10 @@ static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
 	       + userpolicy_type_attrsize();
 }
 
-static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
-			 struct xfrm_tmpl *xt, struct xfrm_policy *xp)
+static int build_acquire(struct sk_buff *skb,
+			 struct xfrm_state *x,
+			 const struct xfrm_tmpl *xt,
+			 const struct xfrm_policy *xp)
 {
 	__u32 seq = xfrm_get_acqseq();
 	struct xfrm_user_acquire *ua;
@@ -2751,8 +2793,9 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	return 0;
 }
 
-static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
-			     struct xfrm_policy *xp)
+static int xfrm_send_acquire(struct xfrm_state *x,
+			     const struct xfrm_tmpl *xt,
+			     const struct xfrm_policy *xp)
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
@@ -2774,7 +2817,8 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 					       u8 *data, int len, int *dir)
 {
 	struct net *net = sock_net(sk);
-	struct xfrm_userpolicy_info *p = (struct xfrm_userpolicy_info *)data;
+	const struct xfrm_userpolicy_info *p =
+		(struct xfrm_userpolicy_info *)data;
 	struct xfrm_user_tmpl *ut = (struct xfrm_user_tmpl *) (p + 1);
 	struct xfrm_policy *xp;
 	int nr;
@@ -2827,7 +2871,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	return xp;
 }
 
-static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
+static inline size_t xfrm_polexpire_msgsize(const struct xfrm_policy *xp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
@@ -2836,8 +2880,10 @@ static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 	       + userpolicy_type_attrsize();
 }
 
-static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
-			   int dir, const struct km_event *c)
+static int build_polexpire(struct sk_buff *skb,
+			   const struct xfrm_policy *xp,
+			   int dir,
+			   const struct km_event *c)
 {
 	struct xfrm_user_polexpire *upe;
 	int hard = c->data.hard;
@@ -2867,7 +2913,9 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 	return 0;
 }
 
-static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
+static int xfrm_exp_policy_notify(const struct xfrm_policy *xp,
+				  int dir,
+				  const struct km_event *c)
 {
 	struct net *net = xp_net(xp);
 	struct sk_buff *skb;
@@ -2882,7 +2930,9 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
-static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
+static int xfrm_notify_policy(const struct xfrm_policy *xp,
+			      int dir,
+			      const struct km_event *c)
 {
 	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	struct net *net = xp_net(xp);
@@ -2976,7 +3026,9 @@ static int xfrm_notify_policy_flush(const struct km_event *c)
 	return err;
 }
 
-static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
+static int xfrm_send_policy_notify(const struct xfrm_policy *xp,
+				   int dir,
+				   const struct km_event *c)
 {
 
 	switch (c->event) {
@@ -3003,7 +3055,8 @@ static inline size_t xfrm_report_msgsize(void)
 }
 
 static int build_report(struct sk_buff *skb, u8 proto,
-			struct xfrm_selector *sel, xfrm_address_t *addr)
+			const struct xfrm_selector *sel,
+			const xfrm_address_t *addr)
 {
 	struct xfrm_user_report *ur;
 	struct nlmsghdr *nlh;
@@ -3027,8 +3080,10 @@ static int build_report(struct sk_buff *skb, u8 proto,
 	return 0;
 }
 
-static int xfrm_send_report(struct net *net, u8 proto,
-			    struct xfrm_selector *sel, xfrm_address_t *addr)
+static int xfrm_send_report(struct net *net,
+			    u8 proto,
+			    const struct xfrm_selector *sel,
+			    const xfrm_address_t *addr)
 {
 	struct sk_buff *skb;
 
@@ -3047,8 +3102,10 @@ static inline size_t xfrm_mapping_msgsize(void)
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_mapping));
 }
 
-static int build_mapping(struct sk_buff *skb, struct xfrm_state *x,
-			 xfrm_address_t *new_saddr, __be16 new_sport)
+static int build_mapping(struct sk_buff *skb,
+			 const struct xfrm_state *x,
+			 const xfrm_address_t *new_saddr,
+			 __be16 new_sport)
 {
 	struct xfrm_user_mapping *um;
 	struct nlmsghdr *nlh;
@@ -3073,7 +3130,8 @@ static int build_mapping(struct sk_buff *skb, struct xfrm_state *x,
 	return 0;
 }
 
-static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
+static int xfrm_send_mapping(struct xfrm_state *x,
+			     const xfrm_address_t *ipaddr,
 			     __be16 sport)
 {
 	struct net *net = xs_net(x);
-- 
2.11.0.483.g087da7b7c-goog
