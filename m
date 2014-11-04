From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Tue, 4 Nov 2014 15:13:55 +0000
Message-ID: <20141104151353.GG7996@ZenIV.linux.org.uk>
References: <20141104033818.GA11149@gondor.apana.org.au>
 <E1XlZWY-0003HZ-Ef@gondolin.me.apana.org.au>
 <20141104143200.GC7996@ZenIV.linux.org.uk>
 <20141104144258.GA14743@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141104144258.GA14743@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2014 at 10:42:58PM +0800, Herbert Xu wrote:
> On Tue, Nov 04, 2014 at 02:32:00PM +0000, Al Viro wrote:
> >
> > Too noisy, IMO.  How about skb_copy_datagram_msg() first?  The fewer
> > places have to even think of iovec or iov_iter, the better...
> 
> We have places like tcp ucopy and tun that do not have msghdr.
> So doing skb_copy_datagram_msg means that we'd have to create
> a fake msghdr wrapper around them.  The point is not everything
> comes in via sendmsg/recvmsg.

I'm certainly not suggesting it as a primitive.

> What is your motivation for hiding iov/iov_iter? Do you plan to
> change their API at some future point?

Think of it that way: every sendmsg/recvmsg path leading to memcpy_fromiovec
and its friends (including the open-coded ones) would need to be changed
at some point.  Assuming we do not end up passing struct iov_iter * as
an extra argument through a fairly large part of net/* (and that would
be prohibitively hard and messy, not to mention the effects on the stack
footprint, etc.), the most obvious strategy is to have that thing passed
where msg_iov/msg_iovlen are - in struct msghdr.  *IF* we go that way,
it makes a whole lot of sense to start with a bunch of cleanups that
will make sense on their own (most of callers of skb_copy_datagram_iovec
do look like skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied); might
as well give it an inlined helper) and will reduce the amount of places
where ->msg_iov is used.  With such cleanups standing on their own and
being splittable from the rest of the queue.  And leaving us with fewer
places in code that deal with ->msg_iov and need to be dealt with.

Please, look through my yesterday posting upthread.  Outline of the
proposed strategy is there...

FWIW, this is from the beginning of April queue - rebased to current,
but very likely incomplete.  Variant taking iov_iter would come later
and yes, it would replace the ..._iovec() one as primitive.  With much
fewer places to worry about.

commit 8241142acab3451239029085286b717ca30aac33
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Sun Apr 6 18:41:28 2014 -0400

    new helper: skb_copy_datagram_msg()
    
    Absolute majority of skb_copy_datagram_iovec() callers (49 out of 56)
    are passing it msg->msg_iov as iovec.  Provide a trivial wrapper that
    takes msg as argument instead of iovec.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 1be8228..dcbd858 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -163,7 +163,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	memcpy(skb_push(skb, MISDN_HEADER_LEN), mISDN_HEAD_P(skb),
 	       MISDN_HEADER_LEN);
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	mISDN_sock_cmsg(sk, msg, skb);
 
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 6c9c16d..443cbbf 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -981,7 +981,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (skb) {
 		total_len = min_t(size_t, total_len, skb->len);
-		error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
+		error = skb_copy_datagram_msg(skb, 0, m, total_len);
 		if (error == 0) {
 			consume_skb(skb);
 			return total_len;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6c8b6f6..379ab46 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2662,6 +2662,12 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
 
+static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
+			    struct msghdr *msg, int size)
+{
+	return skb_copy_datagram_iovec(from, offset, msg->msg_iov, size);
+}
+
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c00897f..425942d 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1758,7 +1758,7 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
-	err = skb_copy_datagram_iovec(skb, offset, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, offset, msg, copied);
 
 	if (!err && msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_at *, sat, msg->msg_name);
diff --git a/net/atm/common.c b/net/atm/common.c
index 6a76515..9cd1cca 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -554,7 +554,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	error = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	error = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (error)
 		return error;
 	sock_recv_ts_and_drops(msg, sk, skb);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index c35c3f4..f4f835e19 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1634,7 +1634,7 @@ static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	if (msg->msg_name) {
 		ax25_digi digi;
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 339c74a..0a7cc56 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -237,7 +237,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err == 0) {
 		sock_recv_ts_and_drops(msg, sk, skb);
 
@@ -328,7 +328,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		chunk = min_t(unsigned int, skb->len, size);
-		if (skb_copy_datagram_iovec(skb, 0, msg->msg_iov, chunk)) {
+		if (skb_copy_datagram_msg(skb, 0, msg, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (!copied)
 				copied = -EFAULT;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 115f149..29e1ec7 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -878,7 +878,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	switch (hci_pi(sk)->channel) {
 	case HCI_CHANNEL_RAW:
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 43f750e..fbcd156 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -293,7 +293,7 @@ static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copylen = len;
 	}
 
-	ret = skb_copy_datagram_iovec(skb, 0, m->msg_iov, copylen);
+	ret = skb_copy_datagram_msg(skb, 0, m, copylen);
 	if (ret)
 		goto out_free;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 15e0c67..ac56dd0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2457,7 +2457,7 @@ int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 5ab6627..8e6ae94 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -896,7 +896,7 @@ verify_sock_status:
 		else if (len < skb->len)
 			msg->msg_flags |= MSG_TRUNC;
 
-		if (skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len)) {
+		if (skb_copy_datagram_msg(skb, 0, msg, len)) {
 			/* Exception. Bailout! */
 			len = -EFAULT;
 			break;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index ef2ad8a..fc9193e 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -324,7 +324,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	/* FIXME: skip headers if necessary ?! */
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 9d1f648..73a4d53 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -195,7 +195,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c373a9a..21894df 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -424,7 +424,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 57f7c98..736236c 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -875,7 +875,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	/* Don't bother checking the checksum */
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 739db31..ee8fa4b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -718,7 +718,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39ec0c3..c239f47 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1377,7 +1377,7 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
 	/* XXX -- need to support SO_PEEK_OFF */
 
 	skb_queue_walk(&sk->sk_write_queue, skb) {
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, skb->len);
+		err = skb_copy_datagram_msg(skb, 0, msg, skb->len);
 		if (err)
 			break;
 
@@ -1833,8 +1833,7 @@ do_prequeue:
 		}
 
 		if (!(flags & MSG_TRUNC)) {
-			err = skb_copy_datagram_iovec(skb, offset,
-						      msg->msg_iov, used);
+			err = skb_copy_datagram_msg(skb, offset, msg, used);
 			if (err) {
 				/* Exception. Bailout! */
 				if (!copied)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..d7266f7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1281,8 +1281,8 @@ try_again:
 	}
 
 	if (skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied);
+		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
+					      msg, copied);
 	else {
 		err = skb_copy_and_csum_datagram_iovec(skb,
 						       sizeof(struct udphdr),
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2cdc383..5c6996e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -351,7 +351,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free_skb;
 
@@ -445,7 +445,7 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len,
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free_skb;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 896af88..f642598 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -486,11 +486,11 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	if (skb_csum_unnecessary(skb)) {
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+		err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	} else if (msg->msg_flags&MSG_TRUNC) {
 		if (__skb_checksum_complete(skb))
 			goto csum_copy_err;
-		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+		err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	} else {
 		err = skb_copy_and_csum_datagram_iovec(skb, 0, msg->msg_iov);
 		if (err == -EINVAL)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f6ba535..5f68cd72 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -424,8 +424,8 @@ try_again:
 	}
 
 	if (skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied);
+		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
+					      msg, copied);
 	else {
 		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
 		if (err == -EINVAL)
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 91729b8..8b7ca1c 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1805,7 +1805,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	rc = skb_copy_datagram_iovec(skb, sizeof(struct ipxhdr), msg->msg_iov,
+	rc = skb_copy_datagram_msg(skb, sizeof(struct ipxhdr), msg,
 				     copied);
 	if (rc)
 		goto out_free;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 3f3a6cb..3f1a37b 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1394,7 +1394,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	skb_free_datagram(sk, skb);
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a089b6b..057b564 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1355,7 +1355,7 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		sk->sk_shutdown = sk->sk_shutdown | RCV_SHUTDOWN;
 
 	cskb = skb;
-	if (skb_copy_datagram_iovec(cskb, offset, msg->msg_iov, copied)) {
+	if (skb_copy_datagram_msg(cskb, offset, msg, copied)) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -EFAULT;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1847ec4..e588309 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3654,7 +3654,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 	}
 
 	skb_reset_transport_header(skb);
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free;
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 369a982..a6cc1fe 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -528,7 +528,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 0edb263..2177b96 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -672,7 +672,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		copied = len;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto done;
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index b704a93..c559bcd 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -208,7 +208,7 @@ static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock,
 	else if (len < skb->len)
 		msg->msg_flags |= MSG_TRUNC;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	err = skb_copy_datagram_msg(skb, 0, msg, len);
 	if (likely(err == 0))
 		err = len;
 
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index bb9cbc1..8fa230b 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -819,8 +819,8 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 			used = len;
 
 		if (!(flags & MSG_TRUNC)) {
-			int rc = skb_copy_datagram_iovec(skb, offset,
-							 msg->msg_iov, used);
+			int rc = skb_copy_datagram_msg(skb, offset,
+							 msg, used);
 			if (rc) {
 				/* Exception. Bailout! */
 				if (!copied)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f1de72d..580b794 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2401,7 +2401,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	}
 
 	skb_reset_transport_header(data_skb);
-	err = skb_copy_datagram_iovec(data_skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(data_skb, 0, msg, copied);
 
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 1b06a1f..7e13f6a 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1167,7 +1167,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	er = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	er = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (er < 0) {
 		skb_free_datagram(sk, skb);
 		release_sock(sk);
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 51f077a..83bc785 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -832,7 +832,7 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	copied = min_t(unsigned int, rlen, len);
 
 	cskb = skb;
-	if (skb_copy_datagram_iovec(cskb, 0, msg->msg_iov, copied)) {
+	if (skb_copy_datagram_msg(cskb, 0, msg, copied)) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -EFAULT;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 11c3544..9d7d2b7 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -269,7 +269,7 @@ static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copied = len;
 	}
 
-	rc = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	rc = skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	skb_free_datagram(sk, skb);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 87d20f4..4cd13d8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2953,7 +2953,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (err)
 		goto out_free;
 
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 290352c..0918bc2 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -150,7 +150,7 @@ static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
 		copylen = len;
 	}
 
-	rval = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copylen);
+	rval = skb_copy_datagram_msg(skb, 0, msg, copylen);
 	if (rval) {
 		rval = -EFAULT;
 		goto out;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 70a547e..44b2123 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1296,7 +1296,7 @@ copy:
 	else
 		len = skb->len;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	err = skb_copy_datagram_msg(skb, 0, msg, len);
 	if (!err)
 		err = (flags & MSG_TRUNC) ? skb->len : len;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index a85c1a0..9b600c2 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1249,7 +1249,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	if (msg->msg_name) {
 		struct sockaddr_rose *srose;
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index e9aaa65..4575485 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -180,7 +180,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 		if (copy > len - copied)
 			copy = len - copied;
 
-		ret = skb_copy_datagram_iovec(skb, offset, msg->msg_iov, copy);
+		ret = skb_copy_datagram_msg(skb, offset, msg, copy);
 
 		if (ret < 0)
 			goto copy_error;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 634a2ab..2120292 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2095,7 +2095,7 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (copied > len)
 		copied = len;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_msg(skb, 0, msg, copied);
 
 	event = sctp_skb2event(skb);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 51bddc2..f726eaa 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1372,8 +1372,8 @@ restart:
 			sz = buf_len;
 			m->msg_flags |= MSG_TRUNC;
 		}
-		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg),
-					      m->msg_iov, sz);
+		res = skb_copy_datagram_msg(buf, msg_hdr_sz(msg),
+					      m, sz);
 		if (res)
 			goto exit;
 		res = sz;
@@ -1473,8 +1473,8 @@ restart:
 		needed = (buf_len - sz_copied);
 		sz_to_copy = (sz <= needed) ? sz : needed;
 
-		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg) + offset,
-					      m->msg_iov, sz_to_copy);
+		res = skb_copy_datagram_msg(buf, msg_hdr_sz(msg) + offset,
+					      m, sz_to_copy);
 		if (res)
 			goto exit;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e968843..350771a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1825,7 +1825,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	else if (size < skb->len - skip)
 		msg->msg_flags |= MSG_TRUNC;
 
-	err = skb_copy_datagram_iovec(skb, skip, msg->msg_iov, size);
+	err = skb_copy_datagram_msg(skb, skip, msg, size);
 	if (err)
 		goto out_free;
 
@@ -2030,8 +2030,8 @@ again:
 		}
 
 		chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
-		if (skb_copy_datagram_iovec(skb, UNIXCB(skb).consumed + skip,
-					    msg->msg_iov, chunk)) {
+		if (skb_copy_datagram_msg(skb, UNIXCB(skb).consumed + skip,
+					    msg, chunk)) {
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 9bb63ff..a57ddef 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1773,8 +1773,7 @@ static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 	}
 
 	/* Place the datagram payload in the user's iovec. */
-	err = skb_copy_datagram_iovec(skb, sizeof(*dg), msg->msg_iov,
-		payload_len);
+	err = skb_copy_datagram_msg(skb, sizeof(*dg), msg, payload_len);
 	if (err)
 		goto out;
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5ad4418..59e785b 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1335,7 +1335,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 	/* Currently, each datagram always contains a complete record */
 	msg->msg_flags |= MSG_EOR;
 
-	rc = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	rc = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (rc)
 		goto out_free_dgram;
 
