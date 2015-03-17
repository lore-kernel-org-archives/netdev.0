From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/6] netfilter: xt_socket: prepare for TCP_NEW_SYN_RECV support
Date: Mon, 16 Mar 2015 21:06:17 -0700
Message-ID: <1426565180-26844-4-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:32880 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbCQEGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:46 -0400
Received: by igjz20 with SMTP id z20so26108igj.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:45 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP request socks soon will be visible in ehash table.

xt_socket will be able to match them, but first we need
to make sure to not consider them as full sockets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_socket.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 13332dbf291d..895534e87a47 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -129,6 +129,20 @@ xt_socket_get_sock_v4(struct net *net, const u8 protocol,
 	return NULL;
 }
 
+static bool xt_socket_sk_is_transparent(struct sock *sk)
+{
+	switch (sk->sk_state) {
+	case TCP_TIME_WAIT:
+		return inet_twsk(sk)->tw_transparent;
+
+	case TCP_NEW_SYN_RECV:
+		return inet_rsk(inet_reqsk(sk))->no_srccheck;
+
+	default:
+		return inet_sk(sk)->transparent;
+	}
+}
+
 static bool
 socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
@@ -195,16 +209,14 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		 * unless XT_SOCKET_NOWILDCARD is set
 		 */
 		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
-			    sk->sk_state != TCP_TIME_WAIT &&
+			    sk_fullsock(sk) &&
 			    inet_sk(sk)->inet_rcv_saddr == 0);
 
 		/* Ignore non-transparent sockets,
-		   if XT_SOCKET_TRANSPARENT is used */
+		 * if XT_SOCKET_TRANSPARENT is used
+		 */
 		if (info->flags & XT_SOCKET_TRANSPARENT)
-			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
-					inet_sk(sk)->transparent) ||
-				       (sk->sk_state == TCP_TIME_WAIT &&
-					inet_twsk(sk)->tw_transparent));
+			transparent = xt_socket_sk_is_transparent(sk);
 
 		if (sk != skb->sk)
 			sock_gen_put(sk);
@@ -363,16 +375,14 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 		 * unless XT_SOCKET_NOWILDCARD is set
 		 */
 		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
-			    sk->sk_state != TCP_TIME_WAIT &&
+			    sk_fullsock(sk) &&
 			    ipv6_addr_any(&sk->sk_v6_rcv_saddr));
 
 		/* Ignore non-transparent sockets,
-		   if XT_SOCKET_TRANSPARENT is used */
+		 * if XT_SOCKET_TRANSPARENT is used
+		 */
 		if (info->flags & XT_SOCKET_TRANSPARENT)
-			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
-					inet_sk(sk)->transparent) ||
-				       (sk->sk_state == TCP_TIME_WAIT &&
-					inet_twsk(sk)->tw_transparent));
+			transparent = xt_socket_sk_is_transparent(sk);
 
 		if (sk != skb->sk)
 			sock_gen_put(sk);
-- 
2.2.0.rc0.207.ga3a616c
