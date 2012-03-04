From: Dmitry Tarnyagin <abi.dmitryt@gmail.com>
Subject: [PATCH] caif: Fix for a race in socket transmit with flow control.
Date: Sun,  4 Mar 2012 19:39:18 +0100
Message-ID: <1330886358-4857-1-git-send-email-abi.dmitryt@gmail.com>
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjurbren@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46921 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754650Ab2CDSjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 13:39:08 -0500
Received: by mail-lpp01m010-f46.google.com with SMTP id j13so3800705lah.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 10:39:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

There is a race between socket transmit and caif flow stop. The race itself
is not something invalid, but handling of the race in net/caif/caif_socket.c
was not correct. Non-fatal -EAGAIN code coming from cfsrvl_ready() led to
killing of calling process by SIGPIPE.

Patch implements retry of transmit if CAIF channel is not ready. It works both for
blocking and non-blocking cases, and both for seqpacket and stream sockets.

Reviewed-by: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Signed-off-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
---
 net/caif/caif_dev.c    |    8 +++-
 net/caif/caif_socket.c |   83 +++++++++++++++++++++++++++++-------------------
 net/caif/cfdbgl.c      |    4 ++-
 net/caif/cfdgml.c      |    9 ++++-
 net/caif/cfrfml.c      |   25 ++++++--------
 net/caif/cfsrvl.c      |    6 +---
 net/caif/cfutill.c     |    5 ++-
 net/caif/cfvidl.c      |    6 +++-
 8 files changed, 87 insertions(+), 59 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index aa6f716..8b5c485 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -224,8 +224,12 @@ noxoff:
 	rcu_read_unlock_bh();
 
 	err = dev_queue_xmit(skb);
-	if (err > 0)
-		err = -EIO;
+	if (unlikely(err > 0)) {
+		if (err == NET_XMIT_DROP)
+			err = -EAGAIN;
+		else
+			err = -EIO;
+	}
 
 	return err;
 }
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 5016fa5..3e464ac 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -541,47 +541,55 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	ret = -EINVAL;
 	if (unlikely(msg->msg_iov->iov_base == NULL))
 		goto err;
-	noblock = msg->msg_flags & MSG_DONTWAIT;
-
-	timeo = sock_sndtimeo(sk, noblock);
-	timeo = caif_wait_for_flow_on(container_of(sk, struct caifsock, sk),
-				1, timeo, &ret);
-
-	if (ret)
-		goto err;
-	ret = -EPIPE;
-	if (cf_sk->sk.sk_state != CAIF_CONNECTED ||
-		sock_flag(sk, SOCK_DEAD) ||
-		(sk->sk_shutdown & RCV_SHUTDOWN))
-		goto err;
 
 	/* Error if trying to write more than maximum frame size. */
 	ret = -EMSGSIZE;
 	if (len > cf_sk->maxframe && cf_sk->sk.sk_protocol != CAIFPROTO_RFM)
 		goto err;
 
-	buffer_size = len + cf_sk->headroom + cf_sk->tailroom;
+	noblock = msg->msg_flags & MSG_DONTWAIT;
+	timeo = sock_sndtimeo(sk, noblock);
 
-	ret = -ENOMEM;
-	skb = sock_alloc_send_skb(sk, buffer_size, noblock, &ret);
+	do {
+		timeo = caif_wait_for_flow_on(
+				container_of(sk, struct caifsock, sk),
+				1, timeo, &ret);
+		if (ret)
+			goto err;
 
-	if (!skb || skb_tailroom(skb) < buffer_size)
-		goto err;
+		ret = -EPIPE;
+		if (cf_sk->sk.sk_state != CAIF_CONNECTED ||
+			sock_flag(sk, SOCK_DEAD) ||
+			(sk->sk_shutdown & RCV_SHUTDOWN))
+			goto err;
 
-	skb_reserve(skb, cf_sk->headroom);
+		buffer_size = len + cf_sk->headroom + cf_sk->tailroom;
 
-	ret = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+		ret = -ENOMEM;
+		skb = sock_alloc_send_skb(sk, buffer_size, noblock, &ret);
 
-	if (ret)
-		goto err;
-	ret = transmit_skb(skb, cf_sk, noblock, timeo);
-	if (ret < 0)
+		if (!skb || skb_tailroom(skb) < buffer_size)
+			goto err_skb;
+
+		skb_reserve(skb, cf_sk->headroom);
+
+		ret = memcpy_fromiovecend(skb_put(skb, len),
+				msg->msg_iov, 0, len);
+		if (ret)
+			goto err_skb;
+
+		ret = transmit_skb(skb, cf_sk, noblock, timeo);
+	} while (ret == -EAGAIN);
+
+	if (unlikely(ret < 0))
 		/* skb is already freed */
-		return ret;
+		goto err;
 
 	return len;
-err:
+
+err_skb:
 	kfree_skb(skb);
+err:
 	return ret;
 }
 
@@ -608,10 +616,6 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto out_err;
 
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
-	timeo = caif_wait_for_flow_on(cf_sk, 1, timeo, &err);
-
-	if (unlikely(sk->sk_shutdown & SEND_SHUTDOWN))
-		goto pipe_err;
 
 	while (sent < len) {
 
@@ -627,6 +631,14 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (size > SKB_MAX_ALLOC)
 			size = SKB_MAX_ALLOC;
 
+		timeo = caif_wait_for_flow_on(cf_sk, 1, timeo, &err);
+		if (err)
+			goto out_err;
+
+		if (unlikely(sk->sk_shutdown & SEND_SHUTDOWN))
+			goto pipe_err;
+
+
 		skb = sock_alloc_send_skb(sk,
 					size + cf_sk->headroom +
 					cf_sk->tailroom,
@@ -645,16 +657,21 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		err = memcpy_fromiovecend(skb_put(skb, size),
+				msg->msg_iov, sent, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
 		}
 		err = transmit_skb(skb, cf_sk,
 				msg->msg_flags&MSG_DONTWAIT, timeo);
-		if (err < 0)
+		if (unlikely(err < 0)) {
 			/* skb is already freed */
-			goto pipe_err;
+			if (err == -EAGAIN)
+				continue;
+			else
+				goto pipe_err;
+		}
 
 		sent += size;
 	}
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 65d6ef3..2914659 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -41,8 +41,10 @@ static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	struct caif_payload_info *info;
 	int ret;
 
-	if (!cfsrvl_ready(service, &ret))
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
 
 	/* Add info for MUX-layer to route the packet out */
 	info = cfpkt_info(pkt);
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 0f5ff27..a63f4a5 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -86,12 +86,17 @@ static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	struct caif_payload_info *info;
 	struct cfsrvl *service = container_obj(layr);
 	int ret;
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
 
 	/* STE Modem cannot handle more than 1500 bytes datagrams */
-	if (cfpkt_getlen(pkt) > DGM_MTU)
+	if (cfpkt_getlen(pkt) > DGM_MTU) {
+		cfpkt_destroy(pkt);
 		return -EMSGSIZE;
+	}
 
 	cfpkt_add_head(pkt, &zero, 3);
 	packet_type = 0x08; /* B9 set - UNCLASSIFIED */
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 6dc75d4..2b563ad 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -184,6 +184,11 @@ out:
 					rfml->serv.dev_info.id);
 	}
 	spin_unlock(&rfml->sync);
+
+	if (unlikely(err == -EAGAIN))
+		/* It is not possible to recover after drop of a fragment */
+		err = -EIO;
+
 	return err;
 }
 
@@ -218,7 +223,7 @@ static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	caif_assert(layr->dn->transmit != NULL);
 
 	if (!cfsrvl_ready(&rfml->serv, &err))
-		return err;
+		goto out;
 
 	err = -EPROTO;
 	if (cfpkt_getlen(pkt) <= RFM_HEAD_SIZE-1)
@@ -251,8 +256,11 @@ static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 
 		err = cfrfml_transmit_segment(rfml, frontpkt);
 
-		if (err != 0)
+		if (err != 0) {
+			frontpkt = NULL;
 			goto out;
+		}
+
 		frontpkt = rearpkt;
 		rearpkt = NULL;
 
@@ -286,19 +294,8 @@ out:
 		if (rearpkt)
 			cfpkt_destroy(rearpkt);
 
-		if (frontpkt && frontpkt != pkt) {
-
+		if (frontpkt)
 			cfpkt_destroy(frontpkt);
-			/*
-			 * Socket layer will free the original packet,
-			 * but this packet may already be sent and
-			 * freed. So we have to return 0 in this case
-			 * to avoid socket layer to re-free this packet.
-			 * The return of shutdown indication will
-			 * cause connection to be invalidated anyhow.
-			 */
-			err = 0;
-		}
 	}
 
 	return err;
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index b99f5b2..4aa33d4 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -174,15 +174,11 @@ void cfsrvl_init(struct cfsrvl *service,
 
 bool cfsrvl_ready(struct cfsrvl *service, int *err)
 {
-	if (service->open && service->modem_flow_on && service->phy_flow_on)
-		return true;
 	if (!service->open) {
 		*err = -ENOTCONN;
 		return false;
 	}
-	caif_assert(!(service->modem_flow_on && service->phy_flow_on));
-	*err = -EAGAIN;
-	return false;
+	return true;
 }
 
 u8 cfsrvl_getphyid(struct cflayer *layer)
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 53e49f3..86d2dad 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -84,8 +84,11 @@ static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	caif_assert(layr != NULL);
 	caif_assert(layr->dn != NULL);
 	caif_assert(layr->dn->transmit != NULL);
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
 
 	cfpkt_add_head(pkt, &zero, 1);
 	/* Add info for MUX-layer to route the packet out. */
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index e3f37db..a8e2a2d 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -50,8 +50,12 @@ static int cfvidl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	struct caif_payload_info *info;
 	u32 videoheader = 0;
 	int ret;
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
+
 	cfpkt_add_head(pkt, &videoheader, 4);
 	/* Add info for MUX-layer to route the packet out */
 	info = cfpkt_info(pkt);
-- 
1.7.9
