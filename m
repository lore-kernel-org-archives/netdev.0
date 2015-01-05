From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 3/6] net: tcp: refactor reinitialization of congestion control
Date: Mon,  5 Jan 2015 23:57:45 +0100
Message-ID: <1420498668-4660-4-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbbAEW6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:01 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can just move this to an extra function and make the code
a bit more readable, no functional change.

Joint work with Florian Westphal.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_cong.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 27ead0d..38f2f8a 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -107,6 +107,18 @@ void tcp_init_congestion_control(struct sock *sk)
 		icsk->icsk_ca_ops->init(sk);
 }
 
+static void tcp_reinit_congestion_control(struct sock *sk,
+					  const struct tcp_congestion_ops *ca)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	tcp_cleanup_congestion_control(sk);
+	icsk->icsk_ca_ops = ca;
+
+	if (sk->sk_state != TCP_CLOSE && icsk->icsk_ca_ops->init)
+		icsk->icsk_ca_ops->init(sk);
+}
+
 /* Manage refcounts on socket close. */
 void tcp_cleanup_congestion_control(struct sock *sk)
 {
@@ -262,21 +274,13 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 #endif
 	if (!ca)
 		err = -ENOENT;
-
 	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
 		   ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))
 		err = -EPERM;
-
 	else if (!try_module_get(ca->owner))
 		err = -EBUSY;
-
-	else {
-		tcp_cleanup_congestion_control(sk);
-		icsk->icsk_ca_ops = ca;
-
-		if (sk->sk_state != TCP_CLOSE && icsk->icsk_ca_ops->init)
-			icsk->icsk_ca_ops->init(sk);
-	}
+	else
+		tcp_reinit_congestion_control(sk, ca);
  out:
 	rcu_read_unlock();
 	return err;
-- 
1.7.11.7
