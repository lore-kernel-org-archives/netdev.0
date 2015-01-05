From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 6/6] net: tcp: add per route congestion control
Date: Mon,  5 Jan 2015 23:57:48 +0100
Message-ID: <1420498668-4660-7-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720AbbAEW6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:07 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds the possibility to define a per route/destination
congestion control algorithm. Generally, this opens up the possibility
for a machine with different links to enforce specific congestion
control algorithms with optimal strategies for each of them based
on their network characteristics, even transparently for a single
application listening on all links.

For our specific use case, this additionally facilitates deployment
of DCTCP, for example, applications can easily serve internal
traffic/dsts in DCTCP and external one with CUBIC. Other scenarios
would also allow for utilizing e.g. long living, low priority
background flows for certain destinations/routes while still being
able for normal traffic to utilize the default congestion control
algorithm. We also thought about a per netns setting (where different
defaults are possible), but given its actually a link specific
property, we argue that a per route/destination setting is the most
natural and flexible.

The administrator can utilize this through ip-route(8) by appending
"congctl [lock] <name>", where <name> denotes the name of a
congestion control algorithm and the optional lock parameter allows
to enforce the given algorithm so that applications in user space
would not be allowed to overwrite that algorithm for that destination.

The dst metric lookups are being done when a dst entry is already
available in order to avoid a costly lookup and still before the
algorithms are being initialized, thus overhead is very low when the
feature is not being used. While the client side would need to drop
the current reference on the module, on server side this can actually
even be avoided as we just got a flat-copied socket clone.

Joint work with Florian Westphal.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/tcp.h        |  6 ++++++
 net/ipv4/tcp_ipv4.c      |  2 ++
 net/ipv4/tcp_minisocks.c | 30 ++++++++++++++++++++++++++----
 net/ipv4/tcp_output.c    | 21 +++++++++++++++++++++
 net/ipv6/tcp_ipv6.c      |  2 ++
 5 files changed, 57 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 95bb237..b8fdc6b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -448,6 +448,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_create_openreq_child(struct sock *sk,
 				      struct request_sock *req,
 				      struct sk_buff *skb);
+void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst);
 struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req,
 				  struct dst_entry *dst);
@@ -636,6 +637,11 @@ static inline u32 tcp_rto_min_us(struct sock *sk)
 	return jiffies_to_usecs(tcp_rto_min(sk));
 }
 
+static inline bool tcp_ca_dst_locked(const struct dst_entry *dst)
+{
+	return dst_metric_locked(dst, RTAX_CC_ALGO);
+}
+
 /* Compute the actual receive window we are currently advertising.
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a3f72d7..ad3e65b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1340,6 +1340,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 	sk_setup_caps(newsk, dst);
 
+	tcp_ca_openreq_child(newsk, dst);
+
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
 	if (tcp_sk(sk)->rx_opt.user_mss &&
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 63d2680..bc9216d 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -399,6 +399,32 @@ static void tcp_ecn_openreq_child(struct tcp_sock *tp,
 	tp->ecn_flags = inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
 }
 
+void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	u32 ca_key = dst_metric(dst, RTAX_CC_ALGO);
+	bool ca_got_dst = false;
+
+	if (ca_key != TCP_CA_UNSPEC) {
+		const struct tcp_congestion_ops *ca;
+
+		rcu_read_lock();
+		ca = tcp_ca_find_key(ca_key);
+		if (likely(ca && try_module_get(ca->owner))) {
+			icsk->icsk_ca_dst_locked = tcp_ca_dst_locked(dst);
+			icsk->icsk_ca_ops = ca;
+			ca_got_dst = true;
+		}
+		rcu_read_unlock();
+	}
+
+	if (!ca_got_dst && !try_module_get(icsk->icsk_ca_ops->owner))
+		tcp_assign_congestion_control(sk);
+
+	tcp_set_ca_state(sk, TCP_CA_Open);
+}
+EXPORT_SYMBOL_GPL(tcp_ca_openreq_child);
+
 /* This is not only more efficient than what we used to do, it eliminates
  * a lot of code duplication between IPv4/IPv6 SYN recv processing. -DaveM
  *
@@ -451,10 +477,6 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->snd_cwnd = TCP_INIT_CWND;
 		newtp->snd_cwnd_cnt = 0;
 
-		if (!try_module_get(newicsk->icsk_ca_ops->owner))
-			tcp_assign_congestion_control(newsk);
-
-		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		__skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = newtp->pushed_seq = treq->snt_isn + 1;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f18262..dc30cb5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2939,6 +2939,25 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 }
 EXPORT_SYMBOL(tcp_make_synack);
 
+static void tcp_ca_dst_init(struct sock *sk, const struct dst_entry *dst)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcp_congestion_ops *ca;
+	u32 ca_key = dst_metric(dst, RTAX_CC_ALGO);
+
+	if (ca_key == TCP_CA_UNSPEC)
+		return;
+
+	rcu_read_lock();
+	ca = tcp_ca_find_key(ca_key);
+	if (likely(ca && try_module_get(ca->owner))) {
+		module_put(icsk->icsk_ca_ops->owner);
+		icsk->icsk_ca_dst_locked = tcp_ca_dst_locked(dst);
+		icsk->icsk_ca_ops = ca;
+	}
+	rcu_read_unlock();
+}
+
 /* Do all connect socket setups that can be done AF independent. */
 static void tcp_connect_init(struct sock *sk)
 {
@@ -2964,6 +2983,8 @@ static void tcp_connect_init(struct sock *sk)
 	tcp_mtup_init(sk);
 	tcp_sync_mss(sk, dst_mtu(dst));
 
+	tcp_ca_dst_init(sk, dst);
+
 	if (!tp->window_clamp)
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
 	tp->advmss = dst_metric_advmss(dst);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9c0b54e..5d46832 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1199,6 +1199,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
 						     newnp->opt->opt_flen);
 
+	tcp_ca_openreq_child(newsk, dst);
+
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
 	if (tcp_sk(sk)->rx_opt.user_mss &&
-- 
1.7.11.7
