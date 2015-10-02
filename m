From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/17] tcp: move synflood_warned into struct request_sock_queue
Date: Fri,  2 Oct 2015 11:43:25 -0700
Message-ID: <1443811419-4798-4-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33616 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbbJBSny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:54 -0400
Received: by pacex6 with SMTP id ex6so113532224pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:53 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

long term plan is to remove struct listen_sock when its hash
table is no longer there.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 2 +-
 net/ipv4/tcp_input.c       | 7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index d128e7f89042..273fb7235ce3 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -123,7 +123,6 @@ extern int sysctl_max_syn_backlog;
  */
 struct listen_sock {
 	u32			max_qlen_log;
-	u32			synflood_warned;
 	u32			hash_rnd;
 	u32			nr_table_entries;
 	struct request_sock	*syn_table[0];
@@ -171,6 +170,7 @@ struct fastopen_queue {
 struct request_sock_queue {
 	spinlock_t		rskq_lock;
 	u8			rskq_defer_accept;
+	u32			synflood_warned;
 
 	atomic_t		qlen;
 	atomic_t		young;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e58cbcd2f07e..8b0ce73c2049 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6068,9 +6068,9 @@ static bool tcp_syn_flood_action(const struct sock *sk,
 				 const struct sk_buff *skb,
 				 const char *proto)
 {
+	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
 	const char *msg = "Dropping request";
 	bool want_cookie = false;
-	struct listen_sock *lopt;
 
 #ifdef CONFIG_SYN_COOKIES
 	if (sysctl_tcp_syncookies) {
@@ -6081,10 +6081,9 @@ static bool tcp_syn_flood_action(const struct sock *sk,
 #endif
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
 
-	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
-	if (!lopt->synflood_warned &&
+	if (!queue->synflood_warned &&
 	    sysctl_tcp_syncookies != 2 &&
-	    xchg(&lopt->synflood_warned, 1) == 0)
+	    xchg(&queue->synflood_warned, 1) == 0)
 		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
 			proto, ntohs(tcp_hdr(skb)->dest), msg);
 
-- 
2.6.0.rc2.230.g3dd15c0
