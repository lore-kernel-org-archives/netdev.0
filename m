From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 2/5] tcp: small user_mss code change
Date: Wed, 27 Oct 2010 17:28:07 +0400
Message-ID: <AANLkTi=H16k81X9yiAyxOO0Au2cK97o03hR008UUyxhL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37946 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761241Ab0J0N2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

No double access to user_mss part of socket.

This is done to prevent possible race conditions if accessed without
socket lock.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 net/ipv4/tcp_ipv4.c   |    7 ++++---
 net/ipv4/tcp_output.c |    6 ++++--
 2 files changed, 8 insertions(+), 5 deletions(-)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3de881e..c7e9b2a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1510,6 +1510,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock
*sk, struct sk_buff *skb,
 	struct inet_sock *newinet;
 	struct tcp_sock *newtp;
 	struct sock *newsk;
+	int user_mss;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
@@ -1545,9 +1546,9 @@ struct sock *tcp_v4_syn_recv_sock(struct sock
*sk, struct sk_buff *skb,
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
-	if (tcp_sk(sk)->rx_opt.user_mss &&
-	    tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
-		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
+	user_mss = tcp_sk(sk)->rx_opt.user_mss;
+	if (user_mss && user_mss < newtp->advmss)
+		newtp->advmss = user_mss;

 	tcp_initialize_rcv_mss(newsk);

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index eef2d66..561a7f3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2416,6 +2416,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk,
struct dst_entry *dst,
 	struct tcp_md5sig_key *md5;
 	int tcp_header_size;
 	int mss;
+	int user_mss;
 	int s_data_desired;

 	rcu_read_lock();
@@ -2439,8 +2440,9 @@ struct sk_buff *tcp_make_synack(struct sock *sk,
struct dst_entry *dst,
 	skb_dst_set(skb, dst_clone(dst));

 	mss = dst_metric(dst, RTAX_ADVMSS);
-	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
-		mss = tp->rx_opt.user_mss;
+	user_mss = tp->rx_opt.user_mss;
+	if (user_mss && user_mss < mss)
+		mss = user_mss;

 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
 		__u8 rcv_wscale;
