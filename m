From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/14] tcp: constify tcp_syn_flood_action() socket argument
Date: Tue, 29 Sep 2015 07:42:51 -0700
Message-ID: <1443537772-15305-14-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33724 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbbI2Or5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:47:57 -0400
Received: by pacex6 with SMTP id ex6so8504515pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:56 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_syn_flood_action() will soon be called with unlocked socket.
In order to avoid SYN flood warning being emitted multiple times,
use xchg().
Extend max_qlen_log and synflood_warned fields in struct listen_sock
to u32

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 5 ++---
 net/ipv4/tcp_input.c       | 9 +++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 90247ec7955b..c146b5284786 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -129,9 +129,8 @@ struct listen_sock {
 	atomic_t		qlen_dec; /* qlen = qlen_inc - qlen_dec */
 	atomic_t		young_dec;
 
-	u8			max_qlen_log ____cacheline_aligned_in_smp;
-	u8			synflood_warned;
-	/* 2 bytes hole, try to use */
+	u32			max_qlen_log ____cacheline_aligned_in_smp;
+	u32			synflood_warned;
 	u32			hash_rnd;
 	u32			nr_table_entries;
 	struct request_sock	*syn_table[0];
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 67b27aee8d28..e58cbcd2f07e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6064,7 +6064,7 @@ EXPORT_SYMBOL(inet_reqsk_alloc);
 /*
  * Return true if a syncookie should be sent
  */
-static bool tcp_syn_flood_action(struct sock *sk,
+static bool tcp_syn_flood_action(const struct sock *sk,
 				 const struct sk_buff *skb,
 				 const char *proto)
 {
@@ -6082,11 +6082,12 @@ static bool tcp_syn_flood_action(struct sock *sk,
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
 
 	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
-	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
-		lopt->synflood_warned = 1;
+	if (!lopt->synflood_warned &&
+	    sysctl_tcp_syncookies != 2 &&
+	    xchg(&lopt->synflood_warned, 1) == 0)
 		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
 			proto, ntohs(tcp_hdr(skb)->dest), msg);
-	}
+
 	return want_cookie;
 }
 
-- 
2.6.0.rc2.230.g3dd15c0
