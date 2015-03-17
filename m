From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] inet: move ir_mark to fill a hole
Date: Mon, 16 Mar 2015 21:06:18 -0700
Message-ID: <1426565180-26844-5-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:33058 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbCQEGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:52 -0400
Received: by pdbfl12 with SMTP id fl12so12463571pdb.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:52 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64bit arches, we can save 8 bytes in inet_request_sock
by moving ir_mark to fill a hole.

While we are at it, inet_request_mark() can get a const qualifier
for listener socket.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 3d8c09abb097..c9ed91891887 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -94,11 +94,11 @@ struct inet_request_sock {
 				acked	   : 1,
 				no_srccheck: 1;
 	kmemcheck_bitfield_end(flags);
+	u32                     ir_mark;
 	union {
 		struct ip_options_rcu	*opt;
 		struct sk_buff		*pktopts;
 	};
-	u32                     ir_mark;
 };
 
 static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
@@ -106,13 +106,12 @@ static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
 	return (struct inet_request_sock *)sk;
 }
 
-static inline u32 inet_request_mark(struct sock *sk, struct sk_buff *skb)
+static inline u32 inet_request_mark(const struct sock *sk, struct sk_buff *skb)
 {
-	if (!sk->sk_mark && sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept) {
+	if (!sk->sk_mark && sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
 		return skb->mark;
-	} else {
-		return sk->sk_mark;
-	}
+
+	return sk->sk_mark;
 }
 
 struct inet_cork {
-- 
2.2.0.rc0.207.ga3a616c
