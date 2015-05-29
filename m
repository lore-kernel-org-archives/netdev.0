From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix child sockets to use system default congestion control if not set
Date: Fri, 29 May 2015 13:47:07 -0400
Message-ID: <1432921627-10515-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:34200 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbbE2RrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 13:47:17 -0400
Received: by yhom41 with SMTP id m41so21295449yho.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 10:47:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux 3.17 and earlier are explicitly engineered so that if the app
doesn't specifically request a CC module on a listener before the SYN
arrives, then the child gets the system default CC when the connection
is established. See tcp_init_congestion_control() in 3.17 or earlier,
which says "if no choice made yet assign the current value set as
default". The change ("net: tcp: assign tcp cong_ops when tcp sk is
created") altered these semantics, so that children got their parent
listener's congestion control even if the system default had changed
after the listener was created.

This commit returns to those original semantics from 3.17 and earlier,
since they are the original semantics from 2007 in 4d4d3d1e8 ("[TCP]:
Congestion control initialization."), and some Linux congestion
control workflows depend on that.

In summary, if a listener socket specifically sets TCP_CONGESTION to
"x", or the route locks the CC module to "x", then the child gets
"x". Otherwise the child gets current system default from
net.ipv4.tcp_congestion_control. That's the behavior in 3.17 and
earlier, and this commit restores that.

Fixes: 55d8694fa82c ("net: tcp: assign tcp cong_ops when tcp sk is created")
Cc: Florian Westphal <fw@strlen.de>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Glenn Judd <glenn.judd@morganstanley.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/inet_connection_sock.h | 3 ++-
 net/ipv4/tcp_cong.c                | 5 ++++-
 net/ipv4/tcp_minisocks.c           | 5 ++++-
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 497bc14..0320bbb 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -98,7 +98,8 @@ struct inet_connection_sock {
 	const struct tcp_congestion_ops *icsk_ca_ops;
 	const struct inet_connection_sock_af_ops *icsk_af_ops;
 	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
-	__u8			  icsk_ca_state:7,
+	__u8			  icsk_ca_state:6,
+				  icsk_ca_setsockopt:1,
 				  icsk_ca_dst_locked:1;
 	__u8			  icsk_retransmits;
 	__u8			  icsk_pending;
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 7a5ae50..84be008 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -187,6 +187,7 @@ static void tcp_reinit_congestion_control(struct sock *sk,
 
 	tcp_cleanup_congestion_control(sk);
 	icsk->icsk_ca_ops = ca;
+	icsk->icsk_ca_setsockopt = 1;
 
 	if (sk->sk_state != TCP_CLOSE && icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
@@ -335,8 +336,10 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 	rcu_read_lock();
 	ca = __tcp_ca_find_autoload(name);
 	/* No change asking for existing value */
-	if (ca == icsk->icsk_ca_ops)
+	if (ca == icsk->icsk_ca_ops) {
+		icsk->icsk_ca_setsockopt = 1;
 		goto out;
+	}
 	if (!ca)
 		err = -ENOENT;
 	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b5732a5..17e7339 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -420,7 +420,10 @@ void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst)
 		rcu_read_unlock();
 	}
 
-	if (!ca_got_dst && !try_module_get(icsk->icsk_ca_ops->owner))
+	/* If no valid choice made yet, assign current system default ca. */
+	if (!ca_got_dst &&
+	    (!icsk->icsk_ca_setsockopt ||
+	     !try_module_get(icsk->icsk_ca_ops->owner)))
 		tcp_assign_congestion_control(sk);
 
 	tcp_set_ca_state(sk, TCP_CA_Open);
-- 
2.2.0.rc0.207.ga3a616c
