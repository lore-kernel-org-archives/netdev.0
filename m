From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/5] net: tcp: assign tcp cong_ops when tcp sk is created
Date: Mon, 12 May 2014 22:59:40 +0200
Message-ID: <1399928384-24143-2-git-send-email-fw@strlen.de>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56525 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753647AbaELVfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:35:45 -0400
In-Reply-To: <1399928384-24143-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split assignment and initialization from one into two functions.

This is required by followup patches that add Datacenter TCP
(DCTCP) congestion control algorithm - we need to be able to
determine if the connection is moderated by DCTCP before the
3WHS has finished.

Joint work with Daniel Borkmann and Glenn Judd.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h        | 10 +++++++++-
 net/ipv4/tcp.c           |  2 +-
 net/ipv4/tcp_cong.c      | 24 ++++++++++--------------
 net/ipv4/tcp_minisocks.c |  2 +-
 4 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3c94184..8ae165f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -815,7 +815,7 @@ struct tcp_congestion_ops {
 int tcp_register_congestion_control(struct tcp_congestion_ops *type);
 void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
 
-void tcp_init_congestion_control(struct sock *sk);
+void tcp_assign_congestion_control(struct sock *sk);
 void tcp_cleanup_congestion_control(struct sock *sk);
 int tcp_set_default_congestion_control(const char *name);
 void tcp_get_default_congestion_control(char *name);
@@ -831,6 +831,14 @@ u32 tcp_reno_ssthresh(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
+static inline void tcp_init_congestion_control(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (icsk->icsk_ca_ops->init)
+		icsk->icsk_ca_ops->init(sk);
+}
+
 static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eb1dde3..f3ff83d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -405,7 +405,7 @@ void tcp_init_sock(struct sock *sk)
 
 	tp->reordering = sysctl_tcp_reordering;
 	tcp_enable_early_retrans(tp);
-	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
+	tcp_assign_congestion_control(sk);
 
 	tp->tsoffset = 0;
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 7b09d8b..65609ac 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -74,27 +74,23 @@ void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
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
+		if (try_module_get(ca->owner)) {
+			icsk->icsk_ca_ops = ca;
+			goto out;
 		}
-		rcu_read_unlock();
 	}
 
-	if (icsk->icsk_ca_ops->init)
-		icsk->icsk_ca_ops->init(sk);
+	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
+
+ out:
+	rcu_read_unlock();
 }
 
 /* Manage refcounts on socket close. */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 05c1b15..b810071 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -422,7 +422,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 
 		if (newicsk->icsk_ca_ops != &tcp_init_congestion_ops &&
 		    !try_module_get(newicsk->icsk_ca_ops->owner))
-			newicsk->icsk_ca_ops = &tcp_init_congestion_ops;
+			tcp_assign_congestion_control(newsk);
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
-- 
1.8.1.5
