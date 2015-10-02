From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 17/17] tcp: do not lock listener to process SYN packets
Date: Fri,  2 Oct 2015 11:43:39 -0700
Message-ID: <1443811419-4798-18-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35979 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbbJBSod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:33 -0400
Received: by pablk4 with SMTP id lk4so112698091pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:32 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everything should now be ready to finally allow SYN
packets processing without holding listener lock.

Tested:

3.5 Mpps SYNFLOOD. Plenty of cpu cycles available.

Next bottleneck is the refcount taken on listener,
that could be avoided if we remove SLAB_DESTROY_BY_RCU
strict semantic for listeners, and use regular RCU.

    13.18%  [kernel]  [k] __inet_lookup_listener
     9.61%  [kernel]  [k] tcp_conn_request
     8.16%  [kernel]  [k] sha_transform
     5.30%  [kernel]  [k] inet_reqsk_alloc
     4.22%  [kernel]  [k] sock_put
     3.74%  [kernel]  [k] tcp_make_synack
     2.88%  [kernel]  [k] ipt_do_table
     2.56%  [kernel]  [k] memcpy_erms
     2.53%  [kernel]  [k] sock_wfree
     2.40%  [kernel]  [k] tcp_v4_rcv
     2.08%  [kernel]  [k] fib_table_lookup
     1.84%  [kernel]  [k] tcp_openreq_init_rwin

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 11 +++++++++--
 net/ipv6/tcp_ipv6.c | 11 +++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ac2ea73e9aaf..34310748a365 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1355,7 +1355,7 @@ static struct sock *tcp_v4_cookie_check(struct sock *sk, struct sk_buff *skb)
 }
 
 /* The socket must have it's spinlock held when we get
- * here.
+ * here, unless it is a TCP_LISTEN socket.
  *
  * We have a potential double-lock case here, so even when
  * doing backlog processing we use the BH locking scheme.
@@ -1619,9 +1619,15 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
+	if (sk->sk_state == TCP_LISTEN) {
+		ret = tcp_v4_do_rcv(sk, skb);
+		goto put_and_return;
+	}
+
+	sk_incoming_cpu_update(sk);
+
 	bh_lock_sock_nested(sk);
 	tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
 	ret = 0;
@@ -1636,6 +1642,7 @@ process:
 	}
 	bh_unlock_sock(sk);
 
+put_and_return:
 	sock_put(sk);
 
 	return ret;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3d18571811c5..33334f0c217d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1161,7 +1161,7 @@ out:
 }
 
 /* The socket must have it's spinlock held when we get
- * here.
+ * here, unless it is a TCP_LISTEN socket.
  *
  * We have a potential double-lock case here, so even when
  * doing backlog processing we use the BH locking scheme.
@@ -1415,9 +1415,15 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
+	if (sk->sk_state == TCP_LISTEN) {
+		ret = tcp_v6_do_rcv(sk, skb);
+		goto put_and_return;
+	}
+
+	sk_incoming_cpu_update(sk);
+
 	bh_lock_sock_nested(sk);
 	tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
 	ret = 0;
@@ -1432,6 +1438,7 @@ process:
 	}
 	bh_unlock_sock(sk);
 
+put_and_return:
 	sock_put(sk);
 	return ret ? -1 : 0;
 
-- 
2.6.0.rc2.230.g3dd15c0
