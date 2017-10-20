From: Christoph Paasch <cpaasch@apple.com>
Subject: [PATCH v2 net-next] tcp: Enable TFO without a cookie on a per-socket
 basis
Date: Fri, 20 Oct 2017 14:13:03 -0700
Message-ID: <20171020211303.76466-1-cpaasch@apple.com>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out7.apple.com ([17.151.62.29]:62295 "EHLO
        mail-in7.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752093AbdJTVNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:13:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already allow to enable TFO without a cookie by using the
fastopen-sysctl and setting it to TFO_SERVER_COOKIE_NOT_REQD (0x200).
This is safe to do in certain environments where we know that there
isn't a malicous host (aka., data-centers).

A server however might be talking to both sides (public Internet and
data-center). So, this server would want to enable cookie-less TFO for
the connections that go to the data-center while enforcing cookies for
the traffic from the Internet.

This patch exposes a socket-option to enable this (protected by
CAP_NET_ADMIN).

Signed-off-by: Christoph Paasch <cpaasch@apple.com>
---

Notes:
    v2: * Rename to fastopen_no_cookie and TCP_FASTOPEN_NO_COOKIE
        * Add per-route attribute for fastopen_no_cookie
        * Get rid of the capability check

 include/linux/tcp.h            |  3 ++-
 include/net/tcp.h              |  3 ++-
 include/uapi/linux/rtnetlink.h |  2 ++
 include/uapi/linux/tcp.h       |  1 +
 net/ipv4/tcp.c                 | 12 ++++++++++++
 net/ipv4/tcp_fastopen.c        | 14 +++++++++++---
 net/ipv4/tcp_input.c           |  2 +-
 7 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1d2c44e09e31..173a7c2f9636 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -215,7 +215,8 @@ struct tcp_sock {
 	u8	chrono_type:2,	/* current chronograph type */
 		rate_app_limited:1,  /* rate_{delivered,interval_us} limited? */
 		fastopen_connect:1, /* FASTOPEN_CONNECT sockopt */
-		unused:4;
+		fastopen_no_cookie:1, /* Allow send/recv SYN+data without a cookie */
+		unused:3;
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		unused1	    : 1,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1efe8365cb28..020b20c3f50a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1562,7 +1562,8 @@ int tcp_fastopen_reset_cipher(struct net *net, struct sock *sk,
 void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
-			      struct tcp_fastopen_cookie *foc);
+			      struct tcp_fastopen_cookie *foc,
+			      const struct dst_entry *dst);
 void tcp_fastopen_init_key_once(struct net *net);
 bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			     struct tcp_fastopen_cookie *cookie);
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index dab7dad9e01a..fe6679268901 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -430,6 +430,8 @@ enum {
 #define RTAX_QUICKACK RTAX_QUICKACK
 	RTAX_CC_ALGO,
 #define RTAX_CC_ALGO RTAX_CC_ALGO
+	RTAX_FASTOPEN_NO_COOKIE,
+#define RTAX_FASTOPEN_NO_COOKIE RTAX_FASTOPEN_NO_COOKIE
 	__RTAX_MAX
 };
 
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 69c7493e42f8..d67e1d40c6d6 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -120,6 +120,7 @@ enum {
 #define TCP_ULP			31	/* Attach a ULP to a TCP connection */
 #define TCP_MD5SIG_EXT		32	/* TCP MD5 Signature with extensions */
 #define TCP_FASTOPEN_KEY	33	/* Set the key for Fast Open (cookie) */
+#define TCP_FASTOPEN_NO_COOKIE	34	/* Enable TFO without a TFO cookie */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8b1fa4dd4538..a3d46a781abd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2832,6 +2832,14 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			err = -EOPNOTSUPP;
 		}
 		break;
+	case TCP_FASTOPEN_NO_COOKIE:
+		if (val > 1 || val < 0)
+			err = -EINVAL;
+		else if (!((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)))
+			err = -EINVAL;
+		else
+			tp->fastopen_no_cookie = 1;
+		break;
 	case TCP_TIMESTAMP:
 		if (!tp->repair)
 			err = -EPERM;
@@ -3252,6 +3260,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = tp->fastopen_connect;
 		break;
 
+	case TCP_FASTOPEN_NO_COOKIE:
+		val = tp->fastopen_no_cookie;
+		break;
+
 	case TCP_TIMESTAMP:
 		val = tcp_time_stamp_raw() + tp->tsoffset;
 		break;
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 21075ce19cb6..e704bd86fdf9 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -316,7 +316,8 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
  */
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
-			      struct tcp_fastopen_cookie *foc)
+			      struct tcp_fastopen_cookie *foc,
+			      const struct dst_entry *dst)
 {
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
 	int tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;
@@ -333,7 +334,9 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		return NULL;
 	}
 
-	if (syn_data && (tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
+	if (syn_data && ((tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD) ||
+			 tcp_sk(sk)->fastopen_no_cookie ||
+			 (dst && dst_metric(dst, RTAX_FASTOPEN_NO_COOKIE))))
 		goto fastopen;
 
 	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
@@ -370,6 +373,7 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			       struct tcp_fastopen_cookie *cookie)
 {
 	unsigned long last_syn_loss = 0;
+	const struct dst_entry *dst;
 	int syn_loss = 0;
 
 	tcp_fastopen_cache_get(sk, mss, cookie, &syn_loss, &last_syn_loss);
@@ -387,7 +391,11 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 		return false;
 	}
 
-	if (sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
+	dst = __sk_dst_get(sk);
+
+	if ((sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) ||
+	    tcp_sk(sk)->fastopen_no_cookie ||
+	    (dst && dst_metric(dst, RTAX_FASTOPEN_NO_COOKIE))) {
 		cookie->len = -1;
 		return true;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b2390bfdc68f..a6cf6407f780 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6329,7 +6329,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init_rwin(req, sk, dst);
 	if (!want_cookie) {
 		tcp_reqsk_record_syn(sk, req, skb);
-		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc);
+		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
 	}
 	if (fastopen_sk) {
 		af_ops->send_synack(fastopen_sk, dst, &fl, req,
-- 
2.14.1
