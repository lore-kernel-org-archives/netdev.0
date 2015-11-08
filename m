From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 6/6] netfilter: nft_meta: use skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:12 -0800
Message-ID: <1447008853-16060-7-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35390 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbKHSyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:45 -0500
Received: by pasz6 with SMTP id z6so179536977pas.2
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:44 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets might be attached to request sockets.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/nft_meta.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e4ad2c24bc41..9dfaf4d55ee0 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -31,6 +31,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
 	const struct net_device *in = pkt->in, *out = pkt->out;
+	struct sock *sk;
 	u32 *dest = &regs->data[priv->dreg];
 
 	switch (priv->key) {
@@ -86,33 +87,35 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*(u16 *)dest = out->type;
 		break;
 	case NFT_META_SKUID:
-		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+		sk = skb_to_full_sk(skb);
+		if (!sk || !sk_fullsock(sk))
 			goto err;
 
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket == NULL ||
-		    skb->sk->sk_socket->file == NULL) {
-			read_unlock_bh(&skb->sk->sk_callback_lock);
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk->sk_socket == NULL ||
+		    sk->sk_socket->file == NULL) {
+			read_unlock_bh(&sk->sk_callback_lock);
 			goto err;
 		}
 
 		*dest =	from_kuid_munged(&init_user_ns,
-				skb->sk->sk_socket->file->f_cred->fsuid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+				sk->sk_socket->file->f_cred->fsuid);
+		read_unlock_bh(&sk->sk_callback_lock);
 		break;
 	case NFT_META_SKGID:
-		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+		sk = skb_to_full_sk(skb);
+		if (!sk || !sk_fullsock(sk))
 			goto err;
 
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket == NULL ||
-		    skb->sk->sk_socket->file == NULL) {
-			read_unlock_bh(&skb->sk->sk_callback_lock);
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk->sk_socket == NULL ||
+		    sk->sk_socket->file == NULL) {
+			read_unlock_bh(&sk->sk_callback_lock);
 			goto err;
 		}
 		*dest =	from_kgid_munged(&init_user_ns,
-				 skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+				 sk->sk_socket->file->f_cred->fsgid);
+		read_unlock_bh(&sk->sk_callback_lock);
 		break;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	case NFT_META_RTCLASSID: {
@@ -168,9 +171,10 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		break;
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
-		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+		sk = skb_to_full_sk(skb);
+		if (!sk || !sk_fullsock(sk))
 			goto err;
-		*dest = skb->sk->sk_classid;
+		*dest = sk->sk_classid;
 		break;
 #endif
 	default:
-- 
2.6.0.rc2.230.g3dd15c0
