From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] netfilter: use sk_fullsock() helper
Date: Mon, 16 Mar 2015 21:06:15 -0700
Message-ID: <1426565180-26844-2-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:32786 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbCQEG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:29 -0400
Received: by ykp131 with SMTP id 131so6967533ykp.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:29 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upcoming request sockets have TCP_NEW_SYN_RECV state and should
be special cased a bit like TCP_TIME_WAIT sockets.

Signed-off-by; Eric Dumazet <edumazet@google.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c      | 2 +-
 net/netfilter/nf_log_common.c        | 2 +-
 net/netfilter/nfnetlink_log.c        | 2 +-
 net/netfilter/nfnetlink_queue_core.c | 2 +-
 net/netfilter/nft_meta.c             | 4 ++--
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3aedbda7658a..f35c15b0de6b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -209,7 +209,7 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
 	struct sock *sk = skb->sk;
 	struct rtable *ort = skb_rtable(skb);
 
-	if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+	if (!skb->dev && sk && sk_fullsock(sk))
 		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 }
 
diff --git a/net/netfilter/nf_log_common.c b/net/netfilter/nf_log_common.c
index a2233e77cf39..2631876ac55b 100644
--- a/net/netfilter/nf_log_common.c
+++ b/net/netfilter/nf_log_common.c
@@ -133,7 +133,7 @@ EXPORT_SYMBOL_GPL(nf_log_dump_tcp_header);
 
 void nf_log_dump_sk_uid_gid(struct nf_log_buf *m, struct sock *sk)
 {
-	if (!sk || sk->sk_state == TCP_TIME_WAIT)
+	if (!sk || !sk_fullsock(sk))
 		return;
 
 	read_lock_bh(&sk->sk_callback_lock);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 11d85b3813f2..61d04bf9be2b 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -539,7 +539,7 @@ __build_packet_message(struct nfnl_log_net *log,
 
 	/* UID */
 	sk = skb->sk;
-	if (sk && sk->sk_state != TCP_TIME_WAIT) {
+	if (sk && sk_fullsock(sk)) {
 		read_lock_bh(&sk->sk_callback_lock);
 		if (sk->sk_socket && sk->sk_socket->file) {
 			struct file *file = sk->sk_socket->file;
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0db8515e76da..86ee8b05adae 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -257,7 +257,7 @@ static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
 {
 	const struct cred *cred;
 
-	if (sk->sk_state == TCP_TIME_WAIT)
+	if (!sk_fullsock(sk))
 		return 0;
 
 	read_lock_bh(&sk->sk_callback_lock);
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e99911eda915..abe68119a76c 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -83,7 +83,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*(u16 *)dest->data = out->type;
 		break;
 	case NFT_META_SKUID:
-		if (skb->sk == NULL || skb->sk->sk_state == TCP_TIME_WAIT)
+		if (skb->sk == NULL || !sk_fullsock(skb->sk))
 			goto err;
 
 		read_lock_bh(&skb->sk->sk_callback_lock);
@@ -99,7 +99,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 		break;
 	case NFT_META_SKGID:
-		if (skb->sk == NULL || skb->sk->sk_state == TCP_TIME_WAIT)
+		if (skb->sk == NULL || !sk_fullsock(skb->sk))
 			goto err;
 
 		read_lock_bh(&skb->sk->sk_callback_lock);
-- 
2.2.0.rc0.207.ga3a616c
