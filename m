From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet_diag: remove duplicate code from
 inet_twsk_diag_dump()
Date: Thu, 05 Mar 2015 10:18:14 -0800
Message-ID: <1425579494.5130.254.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36830 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbbCESSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 13:18:16 -0500
Received: by ierx19 with SMTP id x19so78923872ier.3
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 10:18:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

timewait sockets now share a common base with established sockets.

inet_twsk_diag_dump() can use inet_diag_bc_sk() instead of duplicating
code, granted that inet_diag_bc_sk() does proper userlocks
initialization.

twsk_build_assert() will catch any future changes that could break
the assumptions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c |   55 +++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 81751f12645f..0c974d3499ed 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -508,7 +508,7 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 	}
 	entry.sport = inet->inet_num;
 	entry.dport = ntohs(inet->inet_dport);
-	entry.userlocks = sk->sk_userlocks;
+	entry.userlocks = (sk->sk_state != TCP_TIME_WAIT) ? sk->sk_userlocks : 0;
 
 	return inet_diag_bc_run(bc, &entry);
 }
@@ -642,37 +642,44 @@ static int inet_csk_diag_dump(struct sock *sk,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
+static void twsk_build_assert(void)
+{
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_family) !=
+		     offsetof(struct sock, sk_family));
+
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_num) !=
+		     offsetof(struct inet_sock, inet_num));
+
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_dport) !=
+		     offsetof(struct inet_sock, inet_dport));
+
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_rcv_saddr) !=
+		     offsetof(struct inet_sock, inet_rcv_saddr));
+
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_daddr) !=
+		     offsetof(struct inet_sock, inet_daddr));
+
+#if IS_ENABLED(CONFIG_IPV6)
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_v6_rcv_saddr) !=
+		     offsetof(struct sock, sk_v6_rcv_saddr));
+
+	BUILD_BUG_ON(offsetof(struct inet_timewait_sock, tw_v6_daddr) !=
+		     offsetof(struct sock, sk_v6_daddr));
+#endif
+}
+
 static int inet_twsk_diag_dump(struct sock *sk,
 			       struct sk_buff *skb,
 			       struct netlink_callback *cb,
 			       struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
-	struct inet_timewait_sock *tw = inet_twsk(sk);
+	twsk_build_assert();
 
-	if (bc != NULL) {
-		struct inet_diag_entry entry;
-
-		entry.family = tw->tw_family;
-#if IS_ENABLED(CONFIG_IPV6)
-		if (tw->tw_family == AF_INET6) {
-			entry.saddr = tw->tw_v6_rcv_saddr.s6_addr32;
-			entry.daddr = tw->tw_v6_daddr.s6_addr32;
-		} else
-#endif
-		{
-			entry.saddr = &tw->tw_rcv_saddr;
-			entry.daddr = &tw->tw_daddr;
-		}
-		entry.sport = tw->tw_num;
-		entry.dport = ntohs(tw->tw_dport);
-		entry.userlocks = 0;
-
-		if (!inet_diag_bc_run(bc, &entry))
-			return 0;
-	}
+	if (!inet_diag_bc_sk(bc, sk))
+		return 0;
 
-	return inet_twsk_diag_fill(tw, skb, r,
+	return inet_twsk_diag_fill(inet_twsk(sk), skb, r,
 				   NETLINK_CB(cb->skb).portid,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
