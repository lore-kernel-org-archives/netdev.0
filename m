From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH net-2.6.26] [AF_KEY]: Dump SA/SP entries non-atomically
Date: Mon, 03 Mar 2008 10:06:16 +0200
Message-ID: <47CBB178.2020809@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:55372 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbYCCIDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 03:03:54 -0500
Received: by fg-out-1718.google.com with SMTP id e21so5258113fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 00:03:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop dumping of entries when af_key socket receive queue is getting full
and continue it later when there is more room again.

This fixes dumping of large databases. Currently the entries not fitting
into the receive queue are just dropped (including the end-of-dump
message) which can confuse applications.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---

 net/key/af_key.c |  120 +++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 91 insertions(+), 29 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7cb6f12..50c442f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -48,6 +48,17 @@ struct pfkey_sock {
 	struct sock	sk;
 	int		registered;
 	int		promisc;
+
+	struct {
+		uint8_t		msg_version;
+		uint32_t	msg_pid;
+		int		(*dump)(struct pfkey_sock *sk);
+		void		(*done)(struct pfkey_sock *sk);
+		union {
+			struct xfrm_policy_walk	policy;
+			struct xfrm_state_walk	state;
+		} u;
+	} dump;
 };
 
 static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
@@ -55,6 +66,27 @@ static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
 	return (struct pfkey_sock *)sk;
 }
 
+static int pfkey_can_dump(struct sock *sk)
+{
+	if (3 * atomic_read(&sk->sk_rmem_alloc) <= 2 * sk->sk_rcvbuf)
+		return 1;
+	return 0;
+}
+
+static int pfkey_do_dump(struct pfkey_sock *pfk)
+{
+	int rc;
+
+	rc = pfk->dump.dump(pfk);
+	if (rc == -ENOBUFS)
+		return 0;
+
+	pfk->dump.done(pfk);
+	pfk->dump.dump = NULL;
+	pfk->dump.done = NULL;
+	return rc;
+}
+
 static void pfkey_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -1709,51 +1741,60 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	return 0;
 }
 
-struct pfkey_dump_data
-{
-	struct sk_buff *skb;
-	struct sadb_msg *hdr;
-	struct sock *sk;
-};
-
 static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 {
-	struct pfkey_dump_data *data = ptr;
+	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 
+	if (!pfkey_can_dump(&pfk->sk))
+		return -ENOBUFS;
+
 	out_skb = pfkey_xfrm_state2msg(x);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = data->hdr->sadb_msg_version;
+	out_hdr->sadb_msg_version = pfk->dump.msg_version;
 	out_hdr->sadb_msg_type = SADB_DUMP;
 	out_hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_reserved = 0;
 	out_hdr->sadb_msg_seq = count;
-	out_hdr->sadb_msg_pid = data->hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, data->sk);
+	out_hdr->sadb_msg_pid = pfk->dump.msg_pid;
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
 	return 0;
 }
 
+static int pfkey_dump_sa(struct pfkey_sock *pfk)
+{
+	return xfrm_state_walk(&pfk->dump.u.state, dump_sa, (void *) pfk);
+}
+
+static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
+{
+	xfrm_state_walk_done(&pfk->dump.u.state);
+}
+
 static int pfkey_dump(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	u8 proto;
-	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
-	struct xfrm_state_walk walk;
-	int rc;
+	struct pfkey_sock *pfk = pfkey_sk(sk);
+
+	if (pfk->dump.dump != NULL)
+		return -EBUSY;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
 		return -EINVAL;
 
-	xfrm_state_walk_init(&walk, proto);
-	rc = xfrm_state_walk(&walk, dump_sa, &data);
-	xfrm_state_walk_done(&walk);
+	pfk->dump.msg_version = hdr->sadb_msg_version;
+	pfk->dump.msg_pid = hdr->sadb_msg_pid;
+	pfk->dump.dump = pfkey_dump_sa;
+	pfk->dump.done = pfkey_dump_sa_done;
+	xfrm_state_walk_init(&pfk->dump.u.state, proto);
 
-	return rc;
+	return pfkey_do_dump(pfk);
 }
 
 static int pfkey_promisc(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
@@ -2648,11 +2689,14 @@ out:
 
 static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
-	struct pfkey_dump_data *data = ptr;
+	struct pfkey_sock *pfk = ptr;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 	int err;
 
+	if (!pfkey_can_dump(&pfk->sk))
+		return -ENOBUFS;
+
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
@@ -2662,27 +2706,40 @@ static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 		return err;
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
-	out_hdr->sadb_msg_version = data->hdr->sadb_msg_version;
+	out_hdr->sadb_msg_version = pfk->dump.msg_version;
 	out_hdr->sadb_msg_type = SADB_X_SPDDUMP;
 	out_hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = count;
-	out_hdr->sadb_msg_pid = data->hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, data->sk);
+	out_hdr->sadb_msg_pid = pfk->dump.msg_pid;
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
 	return 0;
 }
 
+static int pfkey_dump_sp(struct pfkey_sock *pfk)
+{
+	return xfrm_policy_walk(&pfk->dump.u.policy, dump_sp, (void *) pfk);
+}
+
+static void pfkey_dump_sp_done(struct pfkey_sock *pfk)
+{
+	xfrm_policy_walk_done(&pfk->dump.u.policy);
+}
+
 static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	struct pfkey_dump_data data = { .skb = skb, .hdr = hdr, .sk = sk };
-	struct xfrm_policy_walk walk;
-	int rc;
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 
-	xfrm_policy_walk_init(&walk, XFRM_POLICY_TYPE_MAIN);
-	rc = xfrm_policy_walk(&walk, dump_sp, &data);
-	xfrm_policy_walk_done(&walk);
+	if (pfk->dump.dump != NULL)
+		return -EBUSY;
 
-	return rc;
+	pfk->dump.msg_version = hdr->sadb_msg_version;
+	pfk->dump.msg_pid = hdr->sadb_msg_pid;
+	pfk->dump.dump = pfkey_dump_sp;
+	pfk->dump.done = pfkey_dump_sp_done;
+	xfrm_policy_walk_init(&pfk->dump.u.policy, XFRM_POLICY_TYPE_MAIN);
+
+	return pfkey_do_dump(pfk);
 }
 
 static int key_notify_policy_flush(struct km_event *c)
@@ -3687,6 +3744,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 			 int flags)
 {
 	struct sock *sk = sock->sk;
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 	struct sk_buff *skb;
 	int copied, err;
 
@@ -3714,6 +3772,10 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 
 	err = (flags & MSG_TRUNC) ? skb->len : copied;
 
+	if (pfk->dump.dump != NULL &&
+	    3 * atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
+		pfkey_do_dump(pfk);
+
 out_free:
 	skb_free_datagram(sk, skb);
 out:
-- 
1.5.2.5

