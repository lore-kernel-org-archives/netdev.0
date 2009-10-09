From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
	(v3)
Date: Fri, 9 Oct 2009 19:56:31 -0400
Message-ID: <20091009235631.GA31501@hmsreliant.think-freely.org>
References: <20091007180835.GB20524@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	socketcan@hartkopp.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59124 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbZJIX5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 19:57:21 -0400
Content-Disposition: inline
In-Reply-To: <20091007180835.GB20524@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, take 3 with Erics new notes

Change Notes:

1) Modified inlining of sock_recv_ts_and_drops to be more efficient

2) modify getsockopt for SO_RXQ_OVFL to gurantee only a 1 or 0 return

=============================================================


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
977750076d98c7ff6cbda51858bb5a5894a9d9ab (my af packet cmsg patch) is reverted

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/asm-generic/socket.h |    1 +
 include/linux/skbuff.h       |    6 ++++--
 include/net/sock.h           |    3 +++
 net/atm/common.c             |    2 +-
 net/bluetooth/af_bluetooth.c |    2 +-
 net/bluetooth/rfcomm/sock.c  |    2 +-
 net/can/bcm.c                |    2 +-
 net/can/raw.c                |    2 +-
 net/core/sock.c              |   17 ++++++++++++++++-
 net/ieee802154/dgram.c       |    2 +-
 net/ieee802154/raw.c         |    2 +-
 net/ipv4/raw.c               |    2 +-
 net/ipv4/udp.c               |    2 +-
 net/ipv6/raw.c               |    2 +-
 net/ipv6/udp.c               |    2 +-
 net/key/af_key.c             |    2 +-
 net/packet/af_packet.c       |    7 +++----
 net/rxrpc/ar-recvmsg.c       |    2 +-
 net/sctp/socket.c            |    2 +-
 net/socket.c                 |   16 ++++++++++++++++
 20 files changed, 57 insertions(+), 21 deletions(-)

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 538991c..9a6115e 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -63,4 +63,5 @@
 #define SO_PROTOCOL		38
 #define SO_DOMAIN		39
 
+#define SO_RXQ_OVFL             40
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
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
 
diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -505,6 +505,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
+	SOCK_RXQ_OVFL,
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1493,6 +1494,8 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 		sk->sk_stamp = kt;
 }
 
+extern void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk, struct sk_buff *skb);
+
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
  * @msg:	outgoing packet
diff --git a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -496,7 +496,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	error = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
 	if (error)
 		return error;
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 	pr_debug("RcvM %d -= %d\n", atomic_read(&sk->sk_rmem_alloc), skb->truesize);
 	atm_return(vcc, skb->truesize);
 	skb_free_datagram(sk, skb);
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -257,7 +257,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
 	if (err == 0)
-		sock_recv_timestamp(msg, sk, skb);
+		sock_recv_ts_and_drops(msg, sk, skb);
 
 	skb_free_datagram(sk, skb);
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -703,7 +703,7 @@ static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copied += chunk;
 		size   -= chunk;
 
-		sock_recv_timestamp(msg, sk, skb);
+		sock_recv_ts_and_drops(msg, sk, skb);
 
 		if (!(flags & MSG_PEEK)) {
 			atomic_sub(chunk, &sk->sk_rmem_alloc);
diff --git a/net/can/bcm.c b/net/can/bcm.c
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1534,7 +1534,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 	}
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
 		msg->msg_namelen = sizeof(struct sockaddr_can);
diff --git a/net/can/raw.c b/net/can/raw.c
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -702,7 +702,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 	}
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
 		msg->msg_namelen = sizeof(struct sockaddr_can);
diff --git a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -276,6 +276,8 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
 	int skb_len;
+	unsigned long flags;
+	struct sk_buff_head *list = &sk->sk_receive_queue;
 
 	/* Cast sk->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
@@ -305,7 +307,10 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	skb_len = skb->len;
 
-	skb_queue_tail(&sk->sk_receive_queue, skb);
+	spin_lock_irqsave(&list->lock, flags);
+	skb->dropcount = atomic_read(&sk->sk_drops);
+	__skb_queue_tail(list, skb);
+	spin_unlock_irqrestore(&list->lock, flags);
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb_len);
@@ -702,6 +707,12 @@ set_rcvbuf:
 
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
+	case SO_RXQ_OVFL:
+		if (valbool)
+			sock_set_flag(sk, SOCK_RXQ_OVFL);
+		else
+			sock_reset_flag(sk, SOCK_RXQ_OVFL);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -901,6 +912,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_mark;
 		break;
 
+	case SO_RXQ_OVFL:
+		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -303,7 +303,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (err)
 		goto done;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -191,7 +191,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		goto done;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -682,7 +682,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		goto done;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	/* Copy the address. */
 	if (sin) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -951,7 +951,7 @@ try_again:
 		UDP_INC_STATS_USER(sock_net(sk),
 				UDP_MIB_INDATAGRAMS, is_udplite);
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	/* Copy the address. */
 	if (sin) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -497,7 +497,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			sin6->sin6_scope_id = IP6CB(skb)->iif;
 	}
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (np->rxopt.all)
 		datagram_recv_ctl(sk, msg, skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -252,7 +252,7 @@ try_again:
 					UDP_MIB_INDATAGRAMS, is_udplite);
 	}
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	/* Copy the address. */
 	if (msg->msg_name) {
diff --git a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3606,7 +3606,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 	if (err)
 		goto out_free;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	err = (flags & MSG_TRUNC) ? skb->len : copied;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -627,15 +627,14 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_packets++;
+	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
 	sk->sk_data_ready(sk, skb->len);
 	return 0;
 
 drop_n_acct:
-	spin_lock(&sk->sk_receive_queue.lock);
-	po->stats.tp_drops++;
-	spin_unlock(&sk->sk_receive_queue.lock);
+	po->stats.tp_drops = atomic_inc_return(&sk->sk_drops);
 
 drop_n_restore:
 	if (skb_head != skb->data && skb_shared(skb)) {
@@ -1478,7 +1477,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		goto out_free;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name)
 		memcpy(msg->msg_name, &PACKET_SKB_CB(skb)->sa,
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -146,7 +146,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				memcpy(msg->msg_name,
 				       &call->conn->trans->peer->srx,
 				       sizeof(call->conn->trans->peer->srx));
-			sock_recv_timestamp(msg, &rx->sk, skb);
+			sock_recv_ts_and_drops(msg, &rx->sk, skb);
 		}
 
 		/* receive the message */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1958,7 +1958,7 @@ SCTP_STATIC int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (err)
 		goto out_free;
 
-	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_ts_and_drops(msg, sk, skb);
 	if (sctp_ulpevent_is_notification(event)) {
 		msg->msg_flags |= MSG_NOTIFICATION;
 		sp->pf->event_msgname(event, msg->msg_name, addr_len);
diff --git a/net/socket.c b/net/socket.c
--- a/net/socket.c
+++ b/net/socket.c
@@ -668,6 +668,22 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
+inline void sock_recv_drops(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
+		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
+			sizeof(__u32), &skb->dropcount);
+}
+
+void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb)
+{
+	sock_recv_timestamp(msg, sk, skb);
+	sock_recv_drops(msg, sk, skb);
+	put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &skb->dropcount);
+}
+EXPORT_SYMBOL_GPL(sock_recv_ts_and_drops);
+
 static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size, int flags)
 {
