From: Shaohua Li <shli@kernel.org>
Subject: [RFC net 2/2] net: tcp_v6_send_reset should set flowlabel
Date: Thu, 13 Jul 2017 10:56:58 -0700
Message-ID: <2d68d821379dae77eccdd99ef8673641eb9acdd5.1499967945.git.shli@fb.com>
References: <cover.1499967945.git.shli@fb.com>
Cc: eric.dumazet@gmail.com, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37468 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752654AbdGMR5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 13:57:02 -0400
In-Reply-To: <cover.1499967945.git.shli@fb.com>
In-Reply-To: <cover.1499967945.git.shli@fb.com>
References: <cover.1499967945.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

Currently tcp_v6_send_reset ignores user defined flowlabel, so the reset
packet doesn't include the flowlabel info.

Signed-off-by: Shaohua Li <shli@fb.com>
---
 net/ipv6/tcp_ipv6.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2e656d2..eaf4b8e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -898,6 +898,8 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	struct sock *sk1 = NULL;
 #endif
 	int oif;
+	u8 tclass = 0;
+	__be32 flowlabel = 0;
 
 	if (th->rst)
 		return;
@@ -946,7 +948,21 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 			  (th->doff << 2);
 
 	oif = sk ? sk->sk_bound_dev_if : 0;
-	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1, 0, 0);
+	if (sk) {
+		if (sk_fullsock(sk)) {
+			struct ipv6_pinfo *np = inet6_sk(sk);
+
+			tclass = np->tclass;
+			flowlabel = np->flow_label & IPV6_FLOWLABEL_MASK;
+		} else {
+			struct inet_timewait_sock *tw = inet_twsk(sk);
+
+			tclass = tw->tw_tclass;
+			flowlabel = cpu_to_be32(tw->tw_flowlabel);
+		}
+	}
+	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1,
+		tclass, flowlabel);
 
 #ifdef CONFIG_TCP_MD5SIG
 out:
-- 
2.9.3
