From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 1/5] net: tcp: assign tcp cong_ops when tcp sk is created
Date: Fri, 26 Sep 2014 22:37:32 +0200
Message-ID: <1411763856-14230-2-git-send-email-dborkman@redhat.com>
References: <1411763856-14230-1-git-send-email-dborkman@redhat.com>
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	stephen@networkplumber.org, glenn.judd@morganstanley.com,
	dborkman@redhat.com, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755674AbaIZUh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 16:37:58 -0400
In-Reply-To: <1411763856-14230-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Split assignment and initialization from one into two functions.

This is required by followup patches that add Datacenter TCP
(DCTCP) congestion control algorithm - we need to be able to
determine if the connection is moderated by DCTCP before the
3WHS has finished.

As we walk the available congestion control list during the
assignment, we are always guaranteed to have Reno present as
it's fixed compiled-in. Therefore, since we're doing the
early assignment, we don't have a real use for the Reno alias
tcp_init_congestion_ops anymore and can thus remove it.

Actual usage of the congestion control operations are being
made after the 3WHS has finished, in some cases however we
can access get_info() via diag if implemented, therefore we
need to zero out the private area for those modules.

Joint work with Daniel Borkmann and Glenn Judd.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/net/tcp.h        |  2 +-
 net/ipv4/tcp.c           |  6 ++----
 net/ipv4/tcp_cong.c      | 46 ++++++++++++++++++++++------------------------
 net/ipv4/tcp_minisocks.c |  5 ++---
 4 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a4201ef..1c75356 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -805,6 +805,7 @@ struct tcp_congestion_ops {
 int tcp_register_congestion_control(struct tcp_congestion_ops *type);
 void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
 
+void tcp_assign_congestion_control(struct sock *sk);
 void tcp_init_congestion_control(struct sock *sk);
 void tcp_cleanup_congestion_control(struct sock *sk);
 int tcp_set_default_congestion_control(const char *name);
@@ -816,7 +817,6 @@ int tcp_set_congestion_control(struct sock *sk, const char *name);
 int tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
 
-extern struct tcp_congestion_ops tcp_init_congestion_ops;
 u32 tcp_reno_ssthresh(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 553b01f..cc2c757 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -405,7 +405,7 @@ void tcp_init_sock(struct sock *sk)
 
 	tp->reordering = sysctl_tcp_reordering;
 	tcp_enable_early_retrans(tp);
-	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
+	tcp_assign_congestion_control(sk);
 
 	tp->tsoffset = 0;
 
@@ -3258,8 +3258,6 @@ void __init tcp_init(void)
 		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_metrics_init();
-
-	tcp_register_congestion_control(&tcp_reno);
-
+	BUG_ON(tcp_register_congestion_control(&tcp_reno) != 0);
 	tcp_tasklet_init();
 }
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 80248f5..a6c8a57 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -74,24 +74,34 @@ void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
 EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
 
 /* Assign choice of congestion control. */
-void tcp_init_congestion_control(struct sock *sk)
+void tcp_assign_congestion_control(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_congestion_ops *ca;
 
-	/* if no choice made yet assign the current value set as default */
-	if (icsk->icsk_ca_ops == &tcp_init_congestion_ops) {
-		rcu_read_lock();
-		list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
-			if (try_module_get(ca->owner)) {
-				icsk->icsk_ca_ops = ca;
-				break;
-			}
-
-			/* fallback to next available */
+	rcu_read_lock();
+	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+		if (likely(try_module_get(ca->owner))) {
+			icsk->icsk_ca_ops = ca;
+			goto out;
 		}
-		rcu_read_unlock();
+		/* Fallback to next available. The last really
+		 * guaranteed fallback is Reno from this list.
+		 */
 	}
+out:
+	rcu_read_unlock();
+
+	/* Clear out private data before diag gets it and
+	 * the ca has not been initialized.
+	 */
+	if (ca->get_info)
+		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
+}
+
+void tcp_init_congestion_control(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	if (icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
@@ -345,15 +355,3 @@ struct tcp_congestion_ops tcp_reno = {
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
 };
-
-/* Initial congestion control used (until SYN)
- * really reno under another name so we can tell difference
- * during tcp_set_default_congestion_control
- */
-struct tcp_congestion_ops tcp_init_congestion_ops  = {
-	.name		= "",
-	.owner		= THIS_MODULE,
-	.ssthresh	= tcp_reno_ssthresh,
-	.cong_avoid	= tcp_reno_cong_avoid,
-};
-EXPORT_SYMBOL_GPL(tcp_init_congestion_ops);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a058f41..47b7350 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -451,9 +451,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->snd_cwnd = TCP_INIT_CWND;
 		newtp->snd_cwnd_cnt = 0;
 
-		if (newicsk->icsk_ca_ops != &tcp_init_congestion_ops &&
-		    !try_module_get(newicsk->icsk_ca_ops->owner))
-			newicsk->icsk_ca_ops = &tcp_init_congestion_ops;
+		if (!try_module_get(newicsk->icsk_ca_ops->owner))
+			tcp_assign_congestion_control(newsk);
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
-- 
1.7.11.7
