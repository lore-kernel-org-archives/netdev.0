From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Tue, 04 Nov 2014 22:27:27 -0500 (EST)
Message-ID: <20141104.222727.275422581392488793.davem@davemloft.net>
References: <20141104144258.GA14743@gondor.apana.org.au>
	<20141104151353.GG7996@ZenIV.linux.org.uk>
	<20141105022251.GA19136@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141105022251.GA19136@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Nov 2014 10:22:51 +0800

> On Tue, Nov 04, 2014 at 03:13:55PM +0000, Al Viro wrote:
>> 
>> Think of it that way: every sendmsg/recvmsg path leading to memcpy_fromiovec
>> and its friends (including the open-coded ones) would need to be changed
>> at some point.  Assuming we do not end up passing struct iov_iter * as
>> an extra argument through a fairly large part of net/* (and that would
>> be prohibitively hard and messy, not to mention the effects on the stack
>> footprint, etc.), the most obvious strategy is to have that thing passed
>> where msg_iov/msg_iovlen are - in struct msghdr.  *IF* we go that way,
>> it makes a whole lot of sense to start with a bunch of cleanups that
>> will make sense on their own (most of callers of skb_copy_datagram_iovec
>> do look like skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied); might
>> as well give it an inlined helper) and will reduce the amount of places
>> where ->msg_iov is used.  With such cleanups standing on their own and
>> being splittable from the rest of the queue.  And leaving us with fewer
>> places in code that deal with ->msg_iov and need to be dealt with.
> 
> I think your solution is great.  However, I don't see how my four
> patches impede in anyway the work that you're doing.  I presume
> your first patch will make skb_copy_datagram_msg just a wrapper
> around skb_copy_datagram_iovec.
> 
> Since I'm not removing skb_copy_datagram_iovec (it can't be removed
> until all users are gone) you can still do that and when you're
> ready to switch over to iov_iter you can just move the wrapper over
> to skb_copy_datagram_iter.  No?

Agreed, I think both efforts can proceed in parallel.

Al, is this the helper you are talking about?

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 1be8228..a08057d 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -163,7 +163,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	memcpy(skb_push(skb, MISDN_HEADER_LEN), mISDN_HEAD_P(skb),
 	       MISDN_HEADER_LEN);
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 
 	mISDN_sock_cmsg(sk, msg, skb);
 
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 6c9c16d..25234d9 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -981,7 +981,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (skb) {
 		total_len = min_t(size_t, total_len, skb->len);
-		error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
+		error = skb_copy_datagram_msghdr(skb, m, total_len);
 		if (error == 0) {
 			consume_skb(skb);
 			return total_len;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ad9675..19fe8cc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/kmemcheck.h>
 #include <linux/compiler.h>
+#include <linux/socket.h>
 #include <linux/time.h>
 #include <linux/bug.h>
 #include <linux/cache.h>
@@ -2637,6 +2638,11 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 			   struct poll_table_struct *wait);
 int skb_copy_datagram_iovec(const struct sk_buff *from, int offset,
 			    struct iovec *to, int size);
+static inline int skb_copy_datagram_msghdr(const struct sk_buff *from,
+					   struct msghdr *msg, int size)
+{
+	return skb_copy_datagram_iovec(from, 0, msg->msg_iov, size);
+}
 int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb, int hlen,
 				     struct iovec *iov);
 int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
diff --git a/net/atm/common.c b/net/atm/common.c
index 6a76515..7e42bbe 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -554,7 +554,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	error = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	error = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (error)
 		return error;
 	sock_recv_ts_and_drops(msg, sk, skb);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index c35c3f4..a91075c 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1634,7 +1634,7 @@ static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msghdr(skb, msg, copied);
 
 	if (msg->msg_name) {
 		ax25_digi digi;
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 339c74a..a68dd75 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -237,7 +237,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err == 0) {
 		sock_recv_ts_and_drops(msg, sk, skb);
 
@@ -328,7 +328,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		chunk = min_t(unsigned int, skb->len, size);
-		if (skb_copy_datagram_iovec(skb, 0, msg->msg_iov, chunk)) {
+		if (skb_copy_datagram_msghdr(skb, msg, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (!copied)
 				copied = -EFAULT;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 115f149..45d4fba 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -878,7 +878,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 
 	switch (hci_pi(sk)->channel) {
 	case HCI_CHANNEL_RAW:
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 43f750e..67e63b6 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -293,7 +293,7 @@ static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copylen = len;
 	}
 
-	ret = skb_copy_datagram_iovec(skb, 0, m->msg_iov, copylen);
+	ret = skb_copy_datagram_msghdr(skb, m, copylen);
 	if (ret)
 		goto out_free;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 15e0c67..220c791 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2457,7 +2457,7 @@ int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 5ab6627..7ccf58f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -896,7 +896,7 @@ verify_sock_status:
 		else if (len < skb->len)
 			msg->msg_flags |= MSG_TRUNC;
 
-		if (skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len)) {
+		if (skb_copy_datagram_msghdr(skb, msg, len)) {
 			/* Exception. Bailout! */
 			len = -EFAULT;
 			break;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index ef2ad8a..7017055 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -324,7 +324,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	/* FIXME: skip headers if necessary ?! */
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 9d1f648..5dd893a 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -195,7 +195,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c373a9a..d643882 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -424,7 +424,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 57f7c98..a6e0197 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -875,7 +875,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	/* Don't bother checking the checksum */
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 739db31..2f4bb30 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -718,7 +718,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39ec0c3..3638679 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1377,7 +1377,7 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
 	/* XXX -- need to support SO_PEEK_OFF */
 
 	skb_queue_walk(&sk->sk_write_queue, skb) {
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, skb->len);
+		err = skb_copy_datagram_msghdr(skb, msg, skb->len);
 		if (err)
 			break;
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2cdc383..4bd84fd 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -351,7 +351,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free_skb;
 
@@ -445,7 +445,7 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len,
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 075a0fb..5d37aa1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -486,11 +486,11 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	if (skb_csum_unnecessary(skb)) {
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+		err = skb_copy_datagram_msghdr(skb, msg, copied);
 	} else if (msg->msg_flags&MSG_TRUNC) {
 		if (__skb_checksum_complete(skb))
 			goto csum_copy_err;
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+		err = skb_copy_datagram_msghdr(skb, msg, copied);
 	} else {
 		err = skb_copy_and_csum_datagram_iovec(skb, 0, msg->msg_iov);
 		if (err == -EINVAL)
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 92fafd4..54db6dc 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1396,7 +1396,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msghdr(skb, msg, copied);
 
 	skb_free_datagram(sk, skb);
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1847ec4..f09a848 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3654,7 +3654,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free;
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 369a982..2913198 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -528,7 +528,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 0edb263..8613881 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -672,7 +672,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index b704a93..5f3c0f5 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -208,7 +208,7 @@ static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock,
 	else if (len < skb->len)
 		msg->msg_flags |= MSG_TRUNC;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	err = skb_copy_datagram_msghdr(skb, msg, len);
 	if (likely(err == 0))
 		err = len;
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f1de72d..123cffd 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2401,7 +2401,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(data_skb);
-	err = skb_copy_datagram_iovec(data_skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(data_skb, msg, copied);
 
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 1b06a1f..6bc3556 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1167,7 +1167,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	er = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	er = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (er < 0) {
 		skb_free_datagram(sk, skb);
 		release_sock(sk);
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 51f077a..e962c07 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -832,7 +832,7 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	copied = min_t(unsigned int, rlen, len);
 
 	cskb = skb;
-	if (skb_copy_datagram_iovec(cskb, 0, msg->msg_iov, copied)) {
+	if (skb_copy_datagram_msghdr(cskb, msg, copied)) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -EFAULT;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 11c3544..4467b2c 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -269,7 +269,7 @@ static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copied = len;
 	}
 
-	rc = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	rc = skb_copy_datagram_msghdr(skb, msg, copied);
 
 	skb_free_datagram(sk, skb);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 87d20f4..390b776 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2953,7 +2953,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (err)
 		goto out_free;
 
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 290352c..b4835bc 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -150,7 +150,7 @@ static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
 		copylen = len;
 	}
 
-	rval = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copylen);
+	rval = skb_copy_datagram_msghdr(skb, msg, copylen);
 	if (rval) {
 		rval = -EFAULT;
 		goto out;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 70a547e..f544658 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1296,7 +1296,7 @@ copy:
 	else
 		len = skb->len;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	err = skb_copy_datagram_msghdr(skb, msg, len);
 	if (!err)
 		err = (flags & MSG_TRUNC) ? skb->len : len;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index a85c1a0..b660504 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1249,7 +1249,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msghdr(skb, msg, copied);
 
 	if (msg->msg_name) {
 		struct sockaddr_rose *srose;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 634a2ab..0fca34c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2095,7 +2095,7 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (copied > len)
 		copied = len;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msghdr(skb, msg, copied);
 
 	event = sctp_skb2event(skb);
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5ad4418..fad0702 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1335,7 +1335,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 	/* Currently, each datagram always contains a complete record */
 	msg->msg_flags |= MSG_EOR;
 
-	rc = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	rc = skb_copy_datagram_msghdr(skb, msg, copied);
 	if (rc)
 		goto out_free_dgram;
 
