From: Yuejie Shi <syjcnss@gmail.com>
Subject: [PATCH] af_key: Add lock to key dump
Date: Fri, 31 Mar 2017 15:10:20 +0800
Message-ID: <1490944220-578-1-git-send-email-syjcnss@gmail.com>
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33092 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932271AbdCaHK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 03:10:27 -0400
Received: by mail-pg0-f66.google.com with SMTP id 79so15255268pgf.0
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 00:10:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A dump may come in the middle of another dump, modifying its dump
structure members. This race condition will result in NULL pointer
dereference in kernel. So add a lock to prevent that race.

Fixes: 83321d6b9872 ("[AF_KEY]: Dump SA/SP entries non-atomically")
Signed-off-by: Yuejie Shi <syjcnss@gmail.com>
---
 net/key/af_key.c | 46 ++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 38 insertions(+), 8 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed..1b0ea80 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -63,6 +63,7 @@ struct pfkey_sock {
 		} u;
 		struct sk_buff	*skb;
 	} dump;
+	struct mutex dump_lock;
 };
 
 static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
@@ -139,6 +140,7 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 	struct sock *sk;
+	struct pfkey_sock *pfk;
 	int err;
 
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -153,6 +155,9 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 	if (sk == NULL)
 		goto out;
 
+	pfk = pfkey_sk(sk);
+	mutex_init(&pfk->dump_lock);
+
 	sock->ops = &pfkey_ops;
 	sock_init_data(sock, sk);
 
@@ -281,13 +286,23 @@ static int pfkey_do_dump(struct pfkey_sock *pfk)
 	struct sadb_msg *hdr;
 	int rc;
 
+	mutex_lock(&pfk->dump_lock);
+	if (!pfk->dump.dump) {
+		rc = 0;
+		goto out;
+	}
+
 	rc = pfk->dump.dump(pfk);
-	if (rc == -ENOBUFS)
-		return 0;
+	if (rc == -ENOBUFS) {
+		rc = 0;
+		goto out;
+	}
 
 	if (pfk->dump.skb) {
-		if (!pfkey_can_dump(&pfk->sk))
-			return 0;
+		if (!pfkey_can_dump(&pfk->sk)) {
+			rc = 0;
+			goto out;
+		}
 
 		hdr = (struct sadb_msg *) pfk->dump.skb->data;
 		hdr->sadb_msg_seq = 0;
@@ -298,6 +313,9 @@ static int pfkey_do_dump(struct pfkey_sock *pfk)
 	}
 
 	pfkey_terminate_dump(pfk);
+
+out:
+	mutex_unlock(&pfk->dump_lock);
 	return rc;
 }
 
@@ -1793,19 +1811,26 @@ static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_ms
 	struct xfrm_address_filter *filter = NULL;
 	struct pfkey_sock *pfk = pfkey_sk(sk);
 
-	if (pfk->dump.dump != NULL)
+	mutex_lock(&pfk->dump_lock);
+	if (pfk->dump.dump != NULL) {
+		mutex_unlock(&pfk->dump_lock);
 		return -EBUSY;
+	}
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
-	if (proto == 0)
+	if (proto == 0) {
+		mutex_unlock(&pfk->dump_lock);
 		return -EINVAL;
+	}
 
 	if (ext_hdrs[SADB_X_EXT_FILTER - 1]) {
 		struct sadb_x_filter *xfilter = ext_hdrs[SADB_X_EXT_FILTER - 1];
 
 		filter = kmalloc(sizeof(*filter), GFP_KERNEL);
-		if (filter == NULL)
+		if (filter == NULL) {
+			mutex_unlock(&pfk->dump_lock);
 			return -ENOMEM;
+		}
 
 		memcpy(&filter->saddr, &xfilter->sadb_x_filter_saddr,
 		       sizeof(xfrm_address_t));
@@ -1821,6 +1846,7 @@ static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_ms
 	pfk->dump.dump = pfkey_dump_sa;
 	pfk->dump.done = pfkey_dump_sa_done;
 	xfrm_state_walk_init(&pfk->dump.u.state, proto, filter);
+	mutex_unlock(&pfk->dump_lock);
 
 	return pfkey_do_dump(pfk);
 }
@@ -2679,14 +2705,18 @@ static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, const struct sadb
 {
 	struct pfkey_sock *pfk = pfkey_sk(sk);
 
-	if (pfk->dump.dump != NULL)
+	mutex_lock(&pfk->dump_lock);
+	if (pfk->dump.dump != NULL) {
+		mutex_unlock(&pfk->dump_lock);
 		return -EBUSY;
+	}
 
 	pfk->dump.msg_version = hdr->sadb_msg_version;
 	pfk->dump.msg_portid = hdr->sadb_msg_pid;
 	pfk->dump.dump = pfkey_dump_sp;
 	pfk->dump.done = pfkey_dump_sp_done;
 	xfrm_policy_walk_init(&pfk->dump.u.policy, XFRM_POLICY_TYPE_MAIN);
+	mutex_unlock(&pfk->dump_lock);
 
 	return pfkey_do_dump(pfk);
 }
-- 
2.7.4
