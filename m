From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 04/17] new helper: memcpy_to_msg()
Date: Tue, 25 Nov 2014 14:02:18 +0000
Message-ID: <1416924151-28698-4-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 crypto/algif_hash.c    |    2 +-
 include/linux/skbuff.h |    5 +++++
 net/caif/caif_socket.c |    2 +-
 net/can/bcm.c          |    2 +-
 net/can/raw.c          |    2 +-
 net/decnet/af_decnet.c |    2 +-
 net/ipv4/tcp.c         |    2 +-
 net/irda/af_irda.c     |    2 +-
 net/packet/af_packet.c |    3 +--
 9 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 8502462..35c93ff 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -174,7 +174,7 @@ static int hash_recvmsg(struct kiocb *unused, struct socket *sock,
 			goto unlock;
 	}
 
-	err = memcpy_toiovec(msg->msg_iov, ctx->result, len);
+	err = memcpy_to_msg(msg, ctx->result, len);
 
 unlock:
 	release_sock(sk);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 97dc5f8..d048347 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2692,6 +2692,11 @@ static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 	return memcpy_fromiovec(data, msg->msg_iov, len);
 }
 
+static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
+{
+	return memcpy_toiovec(msg->msg_iov, data, len);
+}
+
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 230f140..ac618b0 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -418,7 +418,7 @@ unlock:
 		}
 		release_sock(sk);
 		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+		if (memcpy_to_msg(msg, skb->data, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (copied == 0)
 				copied = -EFAULT;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index b9a1f71..0167118 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1555,7 +1555,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (skb->len < size)
 		size = skb->len;
 
-	err = memcpy_toiovec(msg->msg_iov, skb->data, size);
+	err = memcpy_to_msg(msg, skb->data, size);
 	if (err < 0) {
 		skb_free_datagram(sk, skb);
 		return err;
diff --git a/net/can/raw.c b/net/can/raw.c
index 0e4004f..dfdcffb 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -750,7 +750,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	else
 		size = skb->len;
 
-	err = memcpy_toiovec(msg->msg_iov, skb->data, size);
+	err = memcpy_to_msg(msg, skb->data, size);
 	if (err < 0) {
 		skb_free_datagram(sk, skb);
 		return err;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index e2e2e3c..8102286 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1760,7 +1760,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 		if ((chunk + copied) > size)
 			chunk = size - copied;
 
-		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+		if (memcpy_to_msg(msg, skb->data, chunk)) {
 			rv = -EFAULT;
 			break;
 		}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c239f47..435443b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1349,7 +1349,7 @@ static int tcp_recv_urg(struct sock *sk, struct msghdr *msg, int len, int flags)
 
 		if (len > 0) {
 			if (!(flags & MSG_TRUNC))
-				err = memcpy_toiovec(msg->msg_iov, &c, 1);
+				err = memcpy_to_msg(msg, &c, 1);
 			len = 1;
 		} else
 			msg->msg_flags |= MSG_TRUNC;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 9052462..568edc7 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1466,7 +1466,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 		}
 
 		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+		if (memcpy_to_msg(msg, skb->data, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (copied == 0)
 				copied = -EFAULT;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 07ac950..108d7f3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2949,8 +2949,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
 		} /* else everything is zero */
 
-		err = memcpy_toiovec(msg->msg_iov, (void *)&vnet_hdr,
-				     vnet_hdr_len);
+		err = memcpy_to_msg(msg, (void *)&vnet_hdr, vnet_hdr_len);
 		if (err < 0)
 			goto out_free;
 	}
-- 
1.7.10.4
