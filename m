From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH 3/3] xfrm: allow to overwrite incoming dev after decryption
Date: Mon, 28 Nov 2011 21:14:52 +0100
Message-ID: <1322511292-1413-4-git-send-email-ulrich.weber@sophos.com>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.sophos.com ([216.47.234.212]:42258 "EHLO mx3.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753768Ab1K1UU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:20:58 -0500
In-Reply-To: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

and flush related xfrm states if interface goes down.

If XFRMA_RECV_DEV is set to an interface index, all decrypted
packets of the associated xfrm state will have the incoming
interface set to that interface.

This allows to create multiple virtual IPsec devices, which
all receive their packets via the same uplink interface.

Xfrm policies can then match against these virtual IPsec
interfaces. Otherwise only one policy could be installed
matching the uplink interface.

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 include/linux/xfrm.h  |    1 +
 include/net/xfrm.h    |    6 +++++-
 net/key/af_key.c      |    2 +-
 net/xfrm/xfrm_input.c |    5 +++++
 net/xfrm/xfrm_state.c |   44 +++++++++++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_user.c  |   14 +++++++++++++-
 6 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index bb1bb49..13b04f4 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -295,6 +295,7 @@ enum xfrm_attr_type_t {
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
+	XFRMA_RECV_DEV,		/* __u32 */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 89174e2..3febf6a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -226,6 +226,9 @@ struct xfrm_state {
 	/* Security context */
 	struct xfrm_sec_ctx	*security;
 
+	/* Overwrite incoming device */
+	struct net_device	*dev;
+
 	/* Private data of this transformer, format is opaque,
 	 * interpreted by xfrm_type methods. */
 	void			*data;
@@ -1442,7 +1445,8 @@ struct xfrmk_spdinfo {
 extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark,
 					      u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
-extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
+extern int xfrm_state_flush(struct net *net, u8 proto, struct net_device *dev,
+			    struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 extern u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index bfc0bef..3bd8075 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1726,7 +1726,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_m
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
 	audit_info.secid = 0;
-	err = xfrm_state_flush(net, proto, &audit_info);
+	err = xfrm_state_flush(net, proto, NULL, &audit_info);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
 		if (err == -ESRCH) /* empty table - go quietly */
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 54a0dc2..80eb73a 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -239,6 +239,11 @@ resume:
 			goto drop;
 		}
 
+		if (x->dev) {
+			skb->dev = x->dev;
+			skb->skb_iif = skb->dev->ifindex;
+		}
+
 		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5b228f9..41c6cc5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -368,6 +368,8 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
 	}
+	if (x->dev)
+		dev_put(x->dev);
 	security_xfrm_state_free(x);
 	kfree(x);
 }
@@ -567,7 +569,8 @@ EXPORT_SYMBOL(xfrm_state_delete);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int
-xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct net_device *dev,
+			      struct xfrm_audit *audit_info)
 {
 	int i, err = 0;
 
@@ -577,6 +580,7 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 
 		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
+			   (!dev || dev == x->dev) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
 				xfrm_audit_state_delete(x, 0,
 							audit_info->loginuid,
@@ -591,18 +595,20 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 }
 #else
 static inline int
-xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct net_device *dev,
+			      struct xfrm_audit *audit_info)
 {
 	return 0;
 }
 #endif
 
-int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+int xfrm_state_flush(struct net *net, u8 proto, struct net_device *dev,
+		     struct xfrm_audit *audit_info)
 {
 	int i, err = 0, cnt = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
-	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
+	err = xfrm_state_flush_secctx_check(net, proto, dev, audit_info);
 	if (err)
 		goto out;
 
@@ -613,6 +619,7 @@ int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 restart:
 		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
+			    (!dev || x->dev == dev) &&
 			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
@@ -1185,6 +1192,11 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 
 	memcpy(&x->mark, &orig->mark, sizeof(x->mark));
 
+	if (orig->dev) {
+		dev_hold(dev);
+		x->dev = orig->dev;
+	}
+
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
@@ -2005,6 +2017,26 @@ int xfrm_init_state(struct xfrm_state *x)
 
 EXPORT_SYMBOL(xfrm_init_state);
 
+
+static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct xfrm_audit audit_info;
+
+	switch (event) {
+	case NETDEV_DOWN:
+		audit_info.loginuid = -1;
+		audit_info.sessionid = -1;
+		audit_info.secid = 0;
+		xfrm_state_flush(dev_net(dev), IPSEC_PROTO_ANY, dev, &audit_info);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block xfrm_dev_notifier = {
+	.notifier_call	= xfrm_dev_event,
+};
+
 int __net_init xfrm_state_init(struct net *net)
 {
 	unsigned int sz;
@@ -2029,6 +2061,8 @@ int __net_init xfrm_state_init(struct net *net)
 	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
 	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	init_waitqueue_head(&net->xfrm.km_waitq);
+	if (net_eq(net, &init_net))
+		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
 
 out_byspi:
@@ -2048,7 +2082,7 @@ void xfrm_state_fini(struct net *net)
 	audit_info.loginuid = -1;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
-	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
+	xfrm_state_flush(net, IPSEC_PROTO_ANY, NULL, &audit_info);
 	flush_work(&net->xfrm.state_gc_work);
 
 	WARN_ON(!list_empty(&net->xfrm.state_all));
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d0a42df..46bd7ad 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -532,6 +532,12 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
+	if (attrs[XFRMA_RECV_DEV]) {
+		x->dev = dev_get_by_index(net, *(int *) nla_data(attrs[XFRMA_RECV_DEV]));
+		if (x->dev == NULL)
+			goto error;
+	}
+
 	xfrm_mark_get(attrs, &x->mark);
 
 	err = __xfrm_init_state(x, false);
@@ -762,6 +768,9 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->lastused)
 		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
 
+	if (x->dev)
+		NLA_PUT_U32(skb, XFRMA_RECV_DEV, x->dev->ifindex);
+
 	if (x->aead)
 		NLA_PUT(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead);
 	if (x->aalg) {
@@ -1642,7 +1651,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
 	security_task_getsecid(current, &audit_info.secid);
-	err = xfrm_state_flush(net, p->proto, &audit_info);
+	err = xfrm_state_flush(net, p->proto, NULL, &audit_info);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
 			return 0;
@@ -2243,6 +2252,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_mark) },
 	[XFRMA_TFCPAD]		= { .type = NLA_U32 },
 	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
+	[XFRMA_RECV_DEV]	= { .type = NLA_U32 },
 };
 
 static struct xfrm_link {
@@ -2432,6 +2442,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 				    x->security->ctx_len);
 	if (x->coaddr)
 		l += nla_total_size(sizeof(*x->coaddr));
+	if (x->dev)
+		l += nla_total_size(sizeof(u32));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
 	l += nla_total_size(sizeof(u64));
-- 
1.7.4.1
