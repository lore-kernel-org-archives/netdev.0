From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 6/7] net-tcp: Fast Open client - detecting SYN-data drops
Date: Mon, 16 Jul 2012 14:16:49 -0700
Message-ID: <1342473410-6265-7-git-send-email-ycheng@google.com>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:55439 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2GPVXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 17:23:53 -0400
Received: by wibhr14 with SMTP id hr14so179400wib.1
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 14:23:52 -0700 (PDT)
In-Reply-To: <1342473410-6265-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On paths with firewalls dropping SYN with data or experimental TCP options,
Fast Open connections will have experience SYN timeout and bad performance.
The solution is to track such incidents in the cookie cache and disables
Fast Open temporarily.

Since only the original SYN includes data and/or Fast Open option, the
SYN-ACK has some tell-tale sign (tcp_rcv_fastopen_synack()) to detect
such drops. If a path has recurring Fast Open SYN drops, Fast Open is
disabled for 2^(recurring_losses) minutes starting from four minutes up to
roughly one and half day. sendmsg with MSG_FASTOPEN flag will succeed but
it behaves as connect() then write().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h       |    6 ++++--
 net/ipv4/tcp_fastopen.c |   16 ++++++++++++++--
 net/ipv4/tcp_input.c    |   10 +++++++++-
 net/ipv4/tcp_output.c   |   13 +++++++++++--
 4 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8c20edd..1b70444 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -391,9 +391,11 @@ enum tcp_tw_status {
 /* From tcp_fastopen.c */
 extern int tcp_fastopen_size_cache(int size);
 extern void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
-				   struct tcp_fastopen_cookie *cookie);
+				   struct tcp_fastopen_cookie *cookie,
+				   int *syn_loss, unsigned long *last_syn_loss);
 extern void tcp_fastopen_cache_set(struct sock *sk, u16 *mss,
-				   struct tcp_fastopen_cookie *cookie);
+				   struct tcp_fastopen_cookie *cookie,
+				   bool syn_lost);
 
 extern enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
 						     struct sk_buff *skb,
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 40fdf21..b10e8ca 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -22,6 +22,8 @@ int sysctl_tcp_fastopen;
  */
 struct fastopen_entry {
 	u16	mss;			/* TCP MSS value */
+	u16	syn_loss:10;		/* Recurring Fast Open SYN losses */
+	unsigned long	last_syn_loss;	/* Last Fast Open SYN loss */
 	struct	tcp_fastopen_cookie	cookie;	/* TCP Fast Open cookie */
 	struct	list_head	lru_list;	/* cookie cache lru_list node */
 	struct	inet_peer	*peer;	/* inetpeer entry (for fast lookup) */
@@ -82,7 +84,8 @@ static struct inet_peer *tcp_fastopen_inetpeer(struct sock *sk, int create)
 }
 
 void tcp_fastopen_cache_get(struct sock *sk, u32 *mss,
-			    struct tcp_fastopen_cookie *cookie)
+			    struct tcp_fastopen_cookie *cookie,
+			    int *syn_loss, unsigned long *last_syn_loss)
 {
 	struct inet_peer *peer = tcp_fastopen_inetpeer(sk, 0);
 	struct fastopen_entry *entry;
@@ -95,6 +98,8 @@ void tcp_fastopen_cache_get(struct sock *sk, u32 *mss,
 	if (entry != NULL) {
 		*mss = entry->mss;
 		*cookie = entry->cookie;
+		*syn_loss = entry->syn_loss;
+		*last_syn_loss = *syn_loss ? entry->last_syn_loss : 0;
 		list_move_tail(&entry->lru_list, &cookie_cache.lru_list);
 	}
 	spin_unlock_bh(&cookie_cache.lock);
@@ -103,7 +108,7 @@ void tcp_fastopen_cache_get(struct sock *sk, u32 *mss,
 }
 
 void tcp_fastopen_cache_set(struct sock *sk, u32 *mss,
-			    struct tcp_fastopen_cookie *cookie)
+			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
 {
 	struct inet_peer *peer = tcp_fastopen_inetpeer(sk, 1);
 	struct fastopen_entry *entry = NULL, *new_entry = NULL;
@@ -119,6 +124,8 @@ void tcp_fastopen_cache_set(struct sock *sk, u32 *mss,
 			goto out;
 		}
 		new_entry->peer = peer;
+		new_entry->mss = new_entry->cookie.len = 0;
+		new_entry->last_syn_loss = new_entry->syn_loss = 0;
 		INIT_LIST_HEAD(&new_entry->lru_list);
 		peer->fastopen = new_entry;
 		++cookie_cache.cnt;
@@ -127,6 +134,11 @@ void tcp_fastopen_cache_set(struct sock *sk, u32 *mss,
 	entry->mss = *mss;
 	if (cookie->len > 0)
 		entry->cookie = *cookie;
+	if (syn_lost) {
+		++entry->syn_loss;
+		entry->last_syn_loss = jiffies;
+	} else
+		entry->syn_loss = 0;
 	list_move_tail(&entry->lru_list, &cookie_cache.lru_list);
 	entry = __tcp_fastopen_remove_lru();
 	spin_unlock_bh(&cookie_cache.lock);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5b09f71..aef8514 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5616,6 +5616,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *data = tcp_write_queue_head(sk);
 	u16 mss = tp->rx_opt.mss_clamp;
+	bool syn_drop;
 
 	if (mss == tp->rx_opt.user_mss) {
 		struct tcp_options_received opt;
@@ -5628,7 +5629,14 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 		mss = opt.mss_clamp;
 	}
 
-	tcp_fastopen_cache_set(sk, &mss, cookie);
+	/* The SYN-ACK neither has cookie nor acknowledges the data. Presumably
+	 * the remote receives only the retransmitted (regular) SYNs: either
+	 * the original SYN-data or the corresponding SYN-ACK is lost.
+	 */
+	syn_drop = (cookie->len <= 0 && data &&
+		    inet_csk(sk)->icsk_retransmits);
+
+	tcp_fastopen_cache_set(sk, &mss, cookie, syn_drop);
 
 	if (data) { /* Retransmit unacked data in SYN */
 		tcp_retransmit_skb(sk, data);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8869328..c5cfd5e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2860,10 +2860,19 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_request *fo = tp->fastopen_req;
-	int space, i, err = 0, iovlen = fo->data->msg_iovlen;
+	int syn_loss = 0, space, i, err = 0, iovlen = fo->data->msg_iovlen;
 	struct sk_buff *syn_data = NULL, *data;
+	unsigned long last_syn_loss = 0;
+
+	tcp_fastopen_cache_get(sk, &tp->rx_opt.mss_clamp, &fo->cookie,
+			       &syn_loss, &last_syn_loss);
+	/* Recurring FO SYN losses: revert to regular handshake temporarily */
+	if (syn_loss > 1 &&
+	    time_before(jiffies, last_syn_loss + (60*HZ << syn_loss))) {
+		fo->cookie.len = -1;
+		goto fallback;
+	}
 
-	tcp_fastopen_cache_get(sk, &tp->rx_opt.mss_clamp, &fo->cookie);
 	if (fo->cookie.len <= 0)
 		goto fallback;
 
-- 
1.7.7.3
