From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/8] xfrm: eradicate size_t
Date: Mon, 30 Oct 2017 09:39:32 +0100
Message-ID: <1509352775-9563-6-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41268 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752529AbdJ3Ijo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:44 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

All netlink message sizes are a) unsigned, b) can't be >= 4GB in size
because netlink doesn't support >= 64KB messages in the first place.

All those size_t across the code are a scam especially across networking
which likes to work with small numbers like 1500 or 65536.

Propagate unsignedness and flip some "int" to "unsigned int" as well.

This is preparation to switching nlmsg_new() to "unsigned int".

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 83718db..f7a12aa 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -458,9 +458,9 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
 	return 0;
 }
 
-static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
+static inline unsigned int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 {
-	int len = 0;
+	unsigned int len = 0;
 
 	if (xfrm_ctx) {
 		len += sizeof(struct xfrm_user_sec_ctx);
@@ -1031,7 +1031,7 @@ static inline int xfrm_nlmsg_multicast(struct net *net, struct sk_buff *skb,
 		return -1;
 }
 
-static inline size_t xfrm_spdinfo_msgsize(void)
+static inline unsigned int xfrm_spdinfo_msgsize(void)
 {
 	return NLMSG_ALIGN(4)
 	       + nla_total_size(sizeof(struct xfrmu_spdinfo))
@@ -1157,7 +1157,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
 
-static inline size_t xfrm_sadinfo_msgsize(void)
+static inline unsigned int xfrm_sadinfo_msgsize(void)
 {
 	return NLMSG_ALIGN(4)
 	       + nla_total_size(sizeof(struct xfrmu_sadhinfo))
@@ -1633,7 +1633,7 @@ static inline int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *s
 		return copy_sec_ctx(xp->security, skb);
 	return 0;
 }
-static inline size_t userpolicy_type_attrsize(void)
+static inline unsigned int userpolicy_type_attrsize(void)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
 	return nla_total_size(sizeof(struct xfrm_userpolicy_type));
@@ -1850,9 +1850,9 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	return 0;
 }
 
-static inline size_t xfrm_aevent_msgsize(struct xfrm_state *x)
+static inline unsigned int xfrm_aevent_msgsize(struct xfrm_state *x)
 {
-	size_t replay_size = x->replay_esn ?
+	unsigned int replay_size = x->replay_esn ?
 			      xfrm_replay_state_esn_len(x->replay_esn) :
 			      sizeof(struct xfrm_replay_state);
 
@@ -2321,8 +2321,8 @@ static int copy_to_user_kmaddress(const struct xfrm_kmaddress *k, struct sk_buff
 	return nla_put(skb, XFRMA_KMADDRESS, sizeof(uk), &uk);
 }
 
-static inline size_t xfrm_migrate_msgsize(int num_migrate, int with_kma,
-					  int with_encp)
+static inline unsigned int xfrm_migrate_msgsize(int num_migrate, int with_kma,
+						int with_encp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_userpolicy_id))
 	      + (with_kma ? nla_total_size(sizeof(struct xfrm_kmaddress)) : 0)
@@ -2566,7 +2566,7 @@ static void xfrm_netlink_rcv(struct sk_buff *skb)
 	mutex_unlock(&net->xfrm.xfrm_cfg_mutex);
 }
 
-static inline size_t xfrm_expire_msgsize(void)
+static inline unsigned int xfrm_expire_msgsize(void)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire))
 	       + nla_total_size(sizeof(struct xfrm_mark));
@@ -2654,9 +2654,9 @@ static int xfrm_notify_sa_flush(const struct km_event *c)
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_SA);
 }
 
-static inline size_t xfrm_sa_len(struct xfrm_state *x)
+static inline unsigned int xfrm_sa_len(struct xfrm_state *x)
 {
-	size_t l = 0;
+	unsigned int l = 0;
 	if (x->aead)
 		l += nla_total_size(aead_len(x->aead));
 	if (x->aalg) {
@@ -2701,8 +2701,9 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int len = xfrm_sa_len(x);
-	int headlen, err;
+	unsigned int len = xfrm_sa_len(x);
+	unsigned int headlen;
+	int err;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELSA) {
@@ -2776,8 +2777,8 @@ static int xfrm_send_state_notify(struct xfrm_state *x, const struct km_event *c
 
 }
 
-static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
-					  struct xfrm_policy *xp)
+static inline unsigned int xfrm_acquire_msgsize(struct xfrm_state *x,
+						struct xfrm_policy *xp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
@@ -2900,7 +2901,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	return xp;
 }
 
-static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
+static inline unsigned int xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
@@ -2957,13 +2958,14 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, const struct
 
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
-	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
+	unsigned int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	struct net *net = xp_net(xp);
 	struct xfrm_userpolicy_info *p;
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	int headlen, err;
+	unsigned int headlen;
+	int err;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELPOLICY) {
@@ -3070,7 +3072,7 @@ static int xfrm_send_policy_notify(struct xfrm_policy *xp, int dir, const struct
 
 }
 
-static inline size_t xfrm_report_msgsize(void)
+static inline unsigned int xfrm_report_msgsize(void)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_report));
 }
@@ -3115,7 +3117,7 @@ static int xfrm_send_report(struct net *net, u8 proto,
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_REPORT);
 }
 
-static inline size_t xfrm_mapping_msgsize(void)
+static inline unsigned int xfrm_mapping_msgsize(void)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_mapping));
 }
-- 
2.7.4
