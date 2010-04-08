From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2] packet: support for TX time stamps on RAW sockets
Date: Thu, 8 Apr 2010 10:41:28 +0200
Message-ID: <20100408084128.GA17098@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:43675 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab0DHIld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:41:33 -0400
Received: by fxm23 with SMTP id 23so1835194fxm.21
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 01:41:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the SO_TIMESTAMPING socket infrastructure for raw packet sockets.
We introduce PACKET_TX_TIMESTAMP for the control message cmsg_type.

Similar support for UDP and CAN sockets was added in commit
51f31cabe3ce5345b51e4a4f82138b38c4d5dc91

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   61 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index aa57a5f..6ac23ef 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -47,6 +47,7 @@ struct sockaddr_ll {
 #define PACKET_TX_RING			13
 #define PACKET_LOSS			14
 #define PACKET_VNET_HDR			15
+#define PACKET_TX_TIMESTAMP		16
 
 struct tpacket_stats {
 	unsigned int	tp_packets;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b0f037c..1199b20 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -81,6 +81,7 @@
 #include <linux/mutex.h>
 #include <linux/if_vlan.h>
 #include <linux/virtio_net.h>
+#include <linux/errqueue.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -314,6 +315,8 @@ static inline struct packet_sock *pkt_sk(struct sock *sk)
 
 static void packet_sock_destruct(struct sock *sk)
 {
+	skb_queue_purge(&sk->sk_error_queue);
+
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 
@@ -482,6 +485,9 @@ retry:
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
+	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	if (err < 0)
+		goto out_unlock;
 
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
@@ -1187,6 +1193,9 @@ static int packet_snd(struct socket *sock,
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
+	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	if (err < 0)
+		goto out_free;
 
 	skb->protocol = proto;
 	skb->dev = dev;
@@ -1486,6 +1495,51 @@ out:
 	return err;
 }
 
+static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
+{
+	struct sock_exterr_skb *serr;
+	struct sk_buff *skb, *skb2;
+	int copied, err;
+
+	err = -EAGAIN;
+	skb = skb_dequeue(&sk->sk_error_queue);
+	if (skb == NULL)
+		goto out;
+
+	copied = skb->len;
+	if (copied > len) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto out_free_skb;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	serr = SKB_EXT_ERR(skb);
+	put_cmsg(msg, SOL_PACKET, PACKET_TX_TIMESTAMP,
+		 sizeof(serr->ee), &serr->ee);
+
+	msg->msg_flags |= MSG_ERRQUEUE;
+	err = copied;
+
+	/* Reset and regenerate socket error */
+	spin_lock_bh(&sk->sk_error_queue.lock);
+	sk->sk_err = 0;
+	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
+		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+		sk->sk_error_report(sk);
+	} else
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+
+out_free_skb:
+	kfree_skb(skb);
+out:
+	return err;
+}
+
 /*
  *	Pull a packet from our receive queue and hand it to the user.
  *	If necessary we block.
@@ -1501,7 +1555,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int vnet_hdr_len = 0;
 
 	err = -EINVAL;
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE))
 		goto out;
 
 #if 0
@@ -1510,6 +1564,11 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return -ENODEV;
 #endif
 
+	if (flags & MSG_ERRQUEUE) {
+		err = packet_recv_error(sk, msg, len);
+		goto out;
+	}
+
 	/*
 	 *	Call the generic datagram receiver. This handles all sorts
 	 *	of horrible races and re-entrancy so we can forget about it
-- 
1.6.0.4

