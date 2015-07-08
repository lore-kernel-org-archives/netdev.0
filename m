From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] inet: inet_twsk_deschedule factorization
Date: Wed,  8 Jul 2015 14:28:30 -0700
Message-ID: <1436390910-13117-4-git-send-email-edumazet@google.com>
References: <1436390910-13117-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35809 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759118AbbGHV2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:28:50 -0400
Received: by igcqs7 with SMTP id qs7so66255146igc.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:28:50 -0700 (PDT)
In-Reply-To: <1436390910-13117-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_twsk_deschedule() calls are followed by inet_twsk_put().

Only particular case is in inet_twsk_purge() but there is no point
to defer the inet_twsk_put() after re-enabling BH.

Lets rename inet_twsk_deschedule() to inet_twsk_deschedule_put()
and move the inet_twsk_put() inside.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_timewait_sock.h |  2 +-
 net/ipv4/inet_hashtables.c       |  9 +++------
 net/ipv4/inet_timewait_sock.c    | 13 ++++++++-----
 net/ipv4/tcp_ipv4.c              |  3 +--
 net/ipv4/tcp_minisocks.c         |  6 ++----
 net/ipv6/inet6_hashtables.c      |  3 +--
 net/ipv6/tcp_ipv6.c              |  3 +--
 net/netfilter/xt_TPROXY.c        |  6 ++----
 8 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 96f52a4711c8..879d6e5a973b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -111,7 +111,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 			   struct inet_hashinfo *hashinfo);
 
 void inet_twsk_schedule(struct inet_timewait_sock *tw, const int timeo);
-void inet_twsk_deschedule(struct inet_timewait_sock *tw);
+void inet_twsk_deschedule_put(struct inet_timewait_sock *tw);
 
 void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 		     struct inet_timewait_death_row *twdr, int family);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index e58840330da7..f8b3701a6c3c 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -380,8 +380,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 		*twp = tw;
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw);
-		inet_twsk_put(tw);
+		inet_twsk_deschedule_put(tw);
 	}
 	return 0;
 
@@ -558,10 +557,8 @@ ok:
 			inet_twsk_bind_unhash(tw, hinfo);
 		spin_unlock(&head->lock);
 
-		if (tw) {
-			inet_twsk_deschedule(tw);
-			inet_twsk_put(tw);
-		}
+		if (tw)
+			inet_twsk_deschedule_put(tw);
 
 		ret = 0;
 		goto out;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 92cd4d50404e..ae22cc24fbe8 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -205,13 +205,17 @@ EXPORT_SYMBOL_GPL(inet_twsk_alloc);
  * tcp_input.c to verify this.
  */
 
-/* This is for handling early-kills of TIME_WAIT sockets. */
-void inet_twsk_deschedule(struct inet_timewait_sock *tw)
+/* This is for handling early-kills of TIME_WAIT sockets.
+ * Warning : consume reference.
+ * Caller should not access tw anymore.
+ */
+void inet_twsk_deschedule_put(struct inet_timewait_sock *tw)
 {
 	if (del_timer_sync(&tw->tw_timer))
 		inet_twsk_kill(tw);
+	inet_twsk_put(tw);
 }
-EXPORT_SYMBOL(inet_twsk_deschedule);
+EXPORT_SYMBOL(inet_twsk_deschedule_put);
 
 void inet_twsk_schedule(struct inet_timewait_sock *tw, const int timeo)
 {
@@ -281,9 +285,8 @@ restart:
 
 			rcu_read_unlock();
 			local_bh_disable();
-			inet_twsk_deschedule(tw);
+			inet_twsk_deschedule_put(tw);
 			local_bh_enable();
-			inet_twsk_put(tw);
 			goto restart_rcu;
 		}
 		/* If the nulls value we got at the end of this lookup is
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d7d4c2b79cf2..486ba96ae91a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1683,8 +1683,7 @@ do_time_wait:
 							iph->daddr, th->dest,
 							inet_iif(skb));
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk));
-			inet_twsk_put(inet_twsk(sk));
+			inet_twsk_deschedule_put(inet_twsk(sk));
 			sk = sk2;
 			goto process;
 		}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4bc00cb79e60..6d8795b066ac 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -147,8 +147,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		if (!th->fin ||
 		    TCP_SKB_CB(skb)->end_seq != tcptw->tw_rcv_nxt + 1) {
 kill_with_rst:
-			inet_twsk_deschedule(tw);
-			inet_twsk_put(tw);
+			inet_twsk_deschedule_put(tw);
 			return TCP_TW_RST;
 		}
 
@@ -198,8 +197,7 @@ kill_with_rst:
 			 */
 			if (sysctl_tcp_rfc1337 == 0) {
 kill:
-				inet_twsk_deschedule(tw);
-				inet_twsk_put(tw);
+				inet_twsk_deschedule_put(tw);
 				return TCP_TW_SUCCESS;
 			}
 		}
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index a237398aa2b4..6ac8dad0138a 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -243,8 +243,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		*twp = tw;
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw);
-		inet_twsk_put(tw);
+		inet_twsk_deschedule_put(tw);
 	}
 	return 0;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6748c4277aff..d540846a1a79 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1481,8 +1481,7 @@ do_time_wait:
 					    ntohs(th->dest), tcp_v6_iif(skb));
 		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
-			inet_twsk_deschedule(tw);
-			inet_twsk_put(tw);
+			inet_twsk_deschedule_put(tw);
 			sk = sk2;
 			tcp_v6_restore_cb(skb);
 			goto process;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index cca96cec1b68..d0c96c5ae29a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -272,8 +272,7 @@ tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 					    hp->source, lport ? lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk));
-			inet_twsk_put(inet_twsk(sk));
+			inet_twsk_deschedule_put(inet_twsk(sk));
 			sk = sk2;
 		}
 	}
@@ -437,8 +436,7 @@ tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
 					    tgi->lport ? tgi->lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk));
-			inet_twsk_put(inet_twsk(sk));
+			inet_twsk_deschedule_put(inet_twsk(sk));
 			sk = sk2;
 		}
 	}
-- 
2.4.3.573.g4eafbef
