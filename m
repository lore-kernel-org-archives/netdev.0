From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 19:48:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:47869 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2CLCss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 22:48:48 -0400
Received: by yhgm50 with SMTP id m50so815385yhg.1
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 19:48:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows a server application to get the TCP SYN packets for
its passive connections.  This is useful if the server is doing
fingerprinting of clients based on SYN packet contents.

Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.  The
first is used on a listener socket to enable saving the SYN packets
for child connections.  The latter is used to retrieve the SYN for
and accepted connection.  TCP_SAVED_SYN is read once, it frees the
saved SYN packet.

The data returned TCP_SAVED_SYN is the IP header (v4 or v6) through
the TCP header.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/tcp.h                |    2 ++
 include/net/inet_connection_sock.h |   31 +++++++++++++++++++++++++++++++
 include/net/request_sock.h         |    6 +++++-
 net/ipv4/inet_connection_sock.c    |    2 ++
 net/ipv4/tcp.c                     |   32 ++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                |    2 ++
 net/ipv4/tcp_minisocks.c           |    2 ++
 net/ipv6/tcp_ipv6.c                |    2 ++
 8 files changed, 78 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b6c62d2..1f6bde9 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,8 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_SAVE_SYN		19	/* SYN recorded for incoming connection */
+#define TCP_SAVED_SYN		20	/* Return SYN recorded for incoming connection */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index dbf9aab..16279c3 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -82,6 +82,8 @@ struct inet_connection_sock_af_ops {
  * @icsk_ext_hdr_len:	   Network protocol overhead (IP/IPv6 options)
  * @icsk_ack:		   Delayed ACK control data
  * @icsk_mtup;		   MTU probing control data
+ * @icsk_save_syn:	   Save SYN packets in children
+ * @icsk_saved_syn:	   SYN packet for passive connection
  */
 struct inet_connection_sock {
 	/* inet_sock has to be the first member! */
@@ -124,6 +126,8 @@ struct inet_connection_sock {
 		/* Information on the current probe. */
 		int		  probe_size;
 	} icsk_mtup;
+	__u8			  icsk_save_syn:1;
+	struct sk_buff		  *icsk_saved_syn;
 	u32			  icsk_ca_priv[16];
 	u32			  icsk_user_timeout;
 #define ICSK_CA_PRIV_SIZE	(16 * sizeof(u32))
@@ -311,11 +315,38 @@ static inline void inet_csk_reqsk_queue_drop(struct sock *sk,
 	reqsk_free(req);
 }
 
+static inline void inet_csk_reqsk_record_syn(struct sock *sk,
+					     struct request_sock *req,
+					     struct sk_buff *skb)
+{
+	if (inet_csk(sk)->icsk_save_syn) {
+		BUG_ON(req->saved_syn);
+		req->saved_syn = skb_clone(skb, GFP_ATOMIC);
+	}
+}
+
+static inline void inet_csk_reqsk_move_syn(struct sock *sk,
+					   struct request_sock *req)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	icsk->icsk_saved_syn = req->saved_syn;
+	req->saved_syn = NULL;
+}
+
 extern void inet_csk_reqsk_queue_prune(struct sock *parent,
 				       const unsigned long interval,
 				       const unsigned long timeout,
 				       const unsigned long max_rto);
 
+static inline void inet_csk_free_syn(struct sock *sk)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	kfree_skb(icsk->icsk_saved_syn);
+	icsk->icsk_saved_syn = NULL;
+}
+
 extern void inet_csk_destroy_sock(struct sock *sk);
 
 /*
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 4c0766e..1cf8fd1 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -65,20 +65,24 @@ struct request_sock {
 	struct sock			*sk;
 	u32				secid;
 	u32				peer_secid;
+	struct sk_buff			*saved_syn;
 };
 
 static inline struct request_sock *reqsk_alloc(const struct request_sock_ops *ops)
 {
 	struct request_sock *req = kmem_cache_alloc(ops->slab, GFP_ATOMIC);
 
-	if (req != NULL)
+	if (req != NULL) {
+		req->saved_syn = NULL;
 		req->rsk_ops = ops;
+	}
 
 	return req;
 }
 
 static inline void __reqsk_free(struct request_sock *req)
 {
+	kfree_skb(req->saved_syn);
 	kmem_cache_free(req->rsk_ops->slab, req);
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19d66ce..c5f1cd3 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -646,6 +646,8 @@ void inet_csk_destroy_sock(struct sock *sk)
 	/* If it has not 0 inet_sk(sk)->inet_num, it must be bound */
 	WARN_ON(inet_sk(sk)->inet_num && !inet_csk(sk)->icsk_bind_hash);
 
+	inet_csk_free_syn(sk);
+
 	sk->sk_prot->destroy(sk);
 
 	sk_stream_kill_queues(sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..6725561 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2352,6 +2352,13 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			icsk->icsk_syn_retries = val;
 		break;
 
+	case TCP_SAVE_SYN:
+		if (val < 0 || val > 1)
+			err = -EINVAL;
+		else
+			icsk->icsk_save_syn = val;
+		break;
+
 	case TCP_LINGER2:
 		if (val < 0)
 			tp->linger2 = -1;
@@ -2632,6 +2639,31 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_SAVE_SYN:
+		val = icsk->icsk_save_syn;
+		break;
+	case TCP_SAVED_SYN: {
+		if (get_user(len, optlen))
+			return -EFAULT;
+
+		if (icsk->icsk_saved_syn) {
+			struct sk_buff *skb = icsk->icsk_saved_syn;
+			void *b = skb_network_header(skb);
+			void *e = (void *)tcp_hdr(skb) + tcp_hdrlen(skb);
+
+			len = min_t(unsigned int, e - b, len);
+			if (put_user(len, optlen))
+				return -EFAULT;
+			if (copy_to_user(optval, b, len))
+				return -EFAULT;
+			inet_csk_free_syn(sk);
+		} else {
+			len = 0;
+			if (put_user(len, optlen))
+				return -EFAULT;
+		}
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 507924b..6e265af 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1414,6 +1414,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	    want_cookie)
 		goto drop_and_free;
 
+	inet_csk_reqsk_record_syn(sk, req, skb);
+
 	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3cabafb..b2ba421 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -554,6 +554,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 
+		inet_csk_reqsk_move_syn(newsk, req);
+
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 12c6ece..9b3efb8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1219,6 +1219,8 @@ have_isn:
 	    want_cookie)
 		goto drop_and_free;
 
+	inet_csk_reqsk_record_syn(sk, req, skb);
+
 	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
 
-- 
1.7.7.3
