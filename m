From: Stephen Hemminger <shemminger@linux-founsation.org>
Subject: [PATCH 1/4] tcp: congestion control initialization
Date: Mon, 23 Apr 2007 20:31:18 -0700
Message-ID: <20070424033316.957480198@linux-foundation.org>
References: <20070424033117.873984872@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:57774 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161572AbXDXDgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 23:36:20 -0400
Content-Disposition: inline; filename=tcp-cong-start.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change to defer congestion control initialization.

If setsockopt() was used to change TCP_CONGESTION before
connection is established, then protocols that use sequence numbers
to keep track of one RTT interval (vegas, illinois, ...) get confused.

Change the init hook to be called after handshake.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/tcp_cong.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp_cong.c
+++ net-2.6.22/net/ipv4/tcp_cong.c
@@ -79,18 +79,19 @@ void tcp_init_congestion_control(struct 
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_congestion_ops *ca;
 
-	if (icsk->icsk_ca_ops != &tcp_init_congestion_ops)
-		return;
+	/* if no choice made yet assign the current value set as default */
+	if (icsk->icsk_ca_ops == &tcp_init_congestion_ops) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+			if (try_module_get(ca->owner)) {
+				icsk->icsk_ca_ops = ca;
+				break;
+			}
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
-		if (try_module_get(ca->owner)) {
-			icsk->icsk_ca_ops = ca;
-			break;
+			/* fallback to next available */
 		}
-
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
 
 	if (icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
@@ -238,6 +239,7 @@ int tcp_set_congestion_control(struct so
 
 	rcu_read_lock();
 	ca = tcp_ca_find(name);
+
 	/* no change asking for existing value */
 	if (ca == icsk->icsk_ca_ops)
 		goto out;
@@ -263,7 +265,8 @@ int tcp_set_congestion_control(struct so
 	else {
 		tcp_cleanup_congestion_control(sk);
 		icsk->icsk_ca_ops = ca;
-		if (icsk->icsk_ca_ops->init)
+
+		if (sk->sk_state != TCP_CLOSE && icsk->icsk_ca_ops->init)
 			icsk->icsk_ca_ops->init(sk);
 	}
  out:

-- 

