From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet_diag: fix access to tcp cc information
Date: Thu, 16 Apr 2015 18:10:35 -0700
Message-ID: <1429233035.7346.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35401 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbDQBKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 21:10:38 -0400
Received: by pabtp1 with SMTP id tp1so107771336pab.2
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 18:10:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Two different problems are fixed here :

1) inet_sk_diag_fill() might be called without socket lock held.
   icsk->icsk_ca_ops can change under us and module be unloaded.
   -> Access to freed memory.
   Fix this using rcu_read_lock() to prevent module unload.

2) Some TCP Congestion Control modules provide information
   but again this is not safe against icsk->icsk_ca_ops
   change and nla_put() errors were ignored. Some sockets
   could not get the additional info if skb was almost full.

Fix this by returning a status from get_info() handlers and
using rcu protection as well.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h       |    2 +-
 net/ipv4/inet_diag.c    |   28 ++++++++++++++++++++++------
 net/ipv4/tcp_dctcp.c    |    5 +++--
 net/ipv4/tcp_illinois.c |    6 +++---
 net/ipv4/tcp_vegas.c    |    5 +++--
 net/ipv4/tcp_vegas.h    |    2 +-
 net/ipv4/tcp_westwood.c |    6 +++---
 7 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9598871485ce..051dc5c2802d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -829,7 +829,7 @@ struct tcp_congestion_ops {
 	/* hook for packet ack accounting (optional) */
 	void (*pkts_acked)(struct sock *sk, u32 num_acked, s32 rtt_us);
 	/* get info for inet_diag (optional) */
-	void (*get_info)(struct sock *sk, u32 ext, struct sk_buff *skb);
+	int (*get_info)(struct sock *sk, u32 ext, struct sk_buff *skb);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 70e8b3c308ec..bb77ebdae3b3 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -111,6 +111,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      const struct nlmsghdr *unlh)
 {
 	const struct inet_sock *inet = inet_sk(sk);
+	const struct tcp_congestion_ops *ca_ops;
 	const struct inet_diag_handler *handler;
 	int ext = req->idiag_ext;
 	struct inet_diag_msg *r;
@@ -208,16 +209,31 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		info = nla_data(attr);
 	}
 
-	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops)
-		if (nla_put_string(skb, INET_DIAG_CONG,
-				   icsk->icsk_ca_ops->name) < 0)
+	if (ext & (1 << (INET_DIAG_CONG - 1))) {
+		int err = 0;
+
+		rcu_read_lock();
+		ca_ops = READ_ONCE(icsk->icsk_ca_ops);
+		if (ca_ops)
+			err = nla_put_string(skb, INET_DIAG_CONG, ca_ops->name);
+		rcu_read_unlock();
+		if (err < 0)
 			goto errout;
+	}
 
 	handler->idiag_get_info(sk, r, info);
 
-	if (sk->sk_state < TCP_TIME_WAIT &&
-	    icsk->icsk_ca_ops && icsk->icsk_ca_ops->get_info)
-		icsk->icsk_ca_ops->get_info(sk, ext, skb);
+	if (sk->sk_state < TCP_TIME_WAIT) {
+		int err = 0;
+
+		rcu_read_lock();
+		ca_ops = READ_ONCE(icsk->icsk_ca_ops);
+		if (ca_ops && ca_ops->get_info)
+			err = ca_ops->get_info(sk, ext, skb);
+		rcu_read_unlock();
+		if (err < 0)
+			goto errout;
+	}
 
 out:
 	nlmsg_end(skb, nlh);
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index b504371af742..4376016f7fa5 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -277,7 +277,7 @@ static void dctcp_cwnd_event(struct sock *sk, enum tcp_ca_event ev)
 	}
 }
 
-static void dctcp_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
+static int dctcp_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct dctcp *ca = inet_csk_ca(sk);
 
@@ -297,8 +297,9 @@ static void dctcp_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 			info.dctcp_ab_tot = ca->acked_bytes_total;
 		}
 
-		nla_put(skb, INET_DIAG_DCTCPINFO, sizeof(info), &info);
+		return nla_put(skb, INET_DIAG_DCTCPINFO, sizeof(info), &info);
 	}
+	return 0;
 }
 
 static struct tcp_congestion_ops dctcp __read_mostly = {
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 1d5a30a90adf..67476f085e48 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -300,8 +300,7 @@ static u32 tcp_illinois_ssthresh(struct sock *sk)
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
-static void tcp_illinois_info(struct sock *sk, u32 ext,
-			      struct sk_buff *skb)
+static int tcp_illinois_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct illinois *ca = inet_csk_ca(sk);
 
@@ -318,8 +317,9 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 			do_div(t, info.tcpv_rttcnt);
 			info.tcpv_rtt = t;
 		}
-		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+		return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
+	return 0;
 }
 
 static struct tcp_congestion_ops tcp_illinois __read_mostly = {
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index a6afde666ab1..c71a1b8f7bde 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -286,7 +286,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
-void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
+int tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct vegas *ca = inet_csk_ca(sk);
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
@@ -297,8 +297,9 @@ void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 			.tcpv_minrtt = ca->minRTT,
 		};
 
-		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+		return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
+	return 0;
 }
 EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 
diff --git a/net/ipv4/tcp_vegas.h b/net/ipv4/tcp_vegas.h
index 0531b99d8637..e8a6b33cc61d 100644
--- a/net/ipv4/tcp_vegas.h
+++ b/net/ipv4/tcp_vegas.h
@@ -19,6 +19,6 @@ void tcp_vegas_init(struct sock *sk);
 void tcp_vegas_state(struct sock *sk, u8 ca_state);
 void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
 void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
-void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
+int tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
 
 #endif	/* __TCP_VEGAS_H */
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index bb63fba47d47..b3c57cceb990 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -256,8 +256,7 @@ static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
-static void tcp_westwood_info(struct sock *sk, u32 ext,
-			      struct sk_buff *skb)
+static int tcp_westwood_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct westwood *ca = inet_csk_ca(sk);
 
@@ -268,8 +267,9 @@ static void tcp_westwood_info(struct sock *sk, u32 ext,
 			.tcpv_minrtt = jiffies_to_usecs(ca->rtt_min),
 		};
 
-		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+		return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
+	return 0;
 }
 
 static struct tcp_congestion_ops tcp_westwood __read_mostly = {
