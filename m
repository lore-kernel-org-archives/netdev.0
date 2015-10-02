From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/17] tcp: cleanup tcp_v[46]_inbound_md5_hash()
Date: Fri,  2 Oct 2015 11:43:28 -0700
Message-ID: <1443811419-4798-7-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34118 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbbJBSoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:02 -0400
Received: by padhy16 with SMTP id hy16so113390477pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:02 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll soon have to call tcp_v[46]_inbound_md5_hash() twice.
Also add const attribute to the socket, as it might be the
unlocked listener for SYN packets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 16 ++++++----------
 net/ipv6/tcp_ipv6.c | 10 ++++++----
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2fb0945b9d83..56f8c6395966 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1112,10 +1112,13 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
+#endif
+
 /* Called with rcu_read_lock() */
-static bool tcp_v4_inbound_md5_hash(struct sock *sk,
+static bool tcp_v4_inbound_md5_hash(const struct sock *sk,
 				    const struct sk_buff *skb)
 {
+#ifdef CONFIG_TCP_MD5SIG
 	/*
 	 * This gets called for each TCP segment that arrives
 	 * so we want to be efficient.
@@ -1165,8 +1168,9 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk,
 		return true;
 	}
 	return false;
-}
 #endif
+	return false;
+}
 
 static void tcp_v4_init_req(struct request_sock *req,
 			    const struct sock *sk_listener,
@@ -1607,16 +1611,8 @@ process:
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-#ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * We really want to reject the packet as early as possible
-	 * if:
-	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
-	 *  o There is an MD5 option and we're not expecting one
-	 */
 	if (tcp_v4_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
-#endif
 
 	nf_reset(skb);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e463583c39ee..65e797dba504 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -622,8 +622,12 @@ clear_hash_noput:
 	return 1;
 }
 
-static bool tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+#endif
+
+static bool tcp_v6_inbound_md5_hash(const struct sock *sk,
+				    const struct sk_buff *skb)
 {
+#ifdef CONFIG_TCP_MD5SIG
 	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
@@ -660,9 +664,9 @@ static bool tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 				     &ip6h->daddr, ntohs(th->dest));
 		return true;
 	}
+#endif
 	return false;
 }
-#endif
 
 static void tcp_v6_init_req(struct request_sock *req,
 			    const struct sock *sk_listener,
@@ -1408,10 +1412,8 @@ process:
 
 	tcp_v6_fill_cb(skb, hdr, th);
 
-#ifdef CONFIG_TCP_MD5SIG
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
-#endif
 
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
-- 
2.6.0.rc2.230.g3dd15c0
