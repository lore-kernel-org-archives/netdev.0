From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
Date: Wed, 7 Oct 2009 14:08:35 -0400
Message-ID: <20091007180835.GB20524@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	socketcan@hartkopp.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44241 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757615AbZJGSJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 14:09:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new socket level option to report number of queue overflows

Recently I augmented the AF_PACKET protocol to report the number of frames lost
on the socket receive queue between any two enqueued frames.  This value was
exported via a SOL_PACKET level cmsg.  AFter I completed that work it was
requested that this feature be generalized so that any datagram oriented socket
could make use of this option.  As such I've created this patch, It creates a
new SOL_SOCKET level option called SO_RXQ_OVFL, which when enabled exports a
SOL_SOCKET level cmsg that reports the nubmer of times the sk_receive_queue
overflowed between any two given frames.  It also augments the AF_PACKET
protocol to take advantage of this new feature (as it previously did not touch
sk->sk_drops, which this patch uses to record the overflow count).  Tested
successfully by me.

Notes:

1) Unlike my previous patch, this patch simply records the sk_drops value, which
is not a number of drops between packets, but rather a total number of drops.
Deltas must be computed in user space.

2) While this patch currently works with datagram oriented protocols, it will
also be accepted by non-datagram oriented protocols. I'm not sure if thats
agreeable to everyone, but my argument in favor of doing so is that, for those
protocols which aren't applicable to this option, sk_drops will always be zero,
and reporting no drops on a receive queue that isn't used for those
non-participating protocols seems reasonable to me.  This also saves us having
to code in a per-protocol opt in mechanism.

3) This applies cleanly to net-next assuming that commit
977750076d98c7ff6cbda51858bb5a5894a9d9ab (my af packet cmsg patch) is reverted.

Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 538991c..7cde78e 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -63,4 +63,5 @@
 #define SO_PROTOCOL		38
 #define SO_DOMAIN		39
 
+#define SO_RXQ_OVFL		40
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index 529a093..b7dafdd 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -69,6 +69,7 @@ struct net;
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
+#define SOCK_RXQ_OVFL		5
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..8c866b5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -389,8 +389,10 @@ struct sk_buff {
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32			secmark;
 #endif
-
-	__u32			mark;
+	union {
+		__u32		mark;
+		__u32		dropcount;
+	};
 
 	__u16			vlan_tci;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 7626b6a..8bd366f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -306,6 +306,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	skb_len = skb->len;
 
 	skb_queue_tail(&sk->sk_receive_queue, skb);
+	skb->dropcount = atomic_read(&sk->sk_drops);
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb_len);
@@ -702,6 +703,12 @@ set_rcvbuf:
 
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
+	case SO_RXQ_OVFL:
+		if (valbool)
+			set_bit(SOCK_RXQ_OVFL, &sock->flags);
+		else
+			clear_bit(SOCK_RXQ_OVFL, &sock->flags);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -901,6 +908,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_mark;
 		break;
 
+	case SO_RXQ_OVFL:
+		v.val = test_bit(SOCK_RXQ_OVFL, &sock->flags);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d7ecca0..920ae1e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -617,6 +617,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
 
+	skb->dropcount = atomic_read(&sk->sk_drops);
 	skb_set_owner_r(skb, sk);
 	skb->dev = NULL;
 	skb_dst_drop(skb);
@@ -634,6 +635,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 drop_n_acct:
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_drops++;
+	atomic_inc(&sk->sk_drops);
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 drop_n_restore:
diff --git a/net/socket.c b/net/socket.c
index 7565536..ad157a3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -673,6 +673,12 @@ static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
+	struct sk_buff *skb;
+	int rc;
+	struct sock *sk = sock->sk;
+	unsigned long cpu_flags;
+	__u32 gap = 0;
+	int check_drops = test_bit(SOCK_RXQ_OVFL, &sock->flags);
 
 	si->sock = sock;
 	si->scm = NULL;
@@ -684,7 +690,21 @@ static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		return err;
 
-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	if (check_drops) {
+		skb = skb_recv_datagram(sk, flags|MSG_PEEK,
+				flags & MSG_DONTWAIT, &err);
+		if (skb) {
+			gap = skb->dropcount;
+			consume_skb(skb);
+		}
+	}
+
+	rc = sock->ops->recvmsg(iocb, sock, msg, size, flags);
+
+	if (check_drops && (rc > 0))
+		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &gap);
+
+	return rc;
 }
 
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
