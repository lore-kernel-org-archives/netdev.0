From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 02/17] new helper: memcpy_from_msg()
Date: Tue, 25 Nov 2014 14:02:16 +0000
Message-ID: <1416924151-28698-2-git-send-email-viro@ZenIV.linux.org.uk>
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
 crypto/algif_skcipher.c     |   10 +++++-----
 drivers/isdn/mISDN/socket.c |    2 +-
 drivers/net/ppp/pppoe.c     |    2 +-
 include/linux/skbuff.h      |    5 +++++
 include/net/sctp/sm.h       |    2 +-
 net/appletalk/ddp.c         |    2 +-
 net/ax25/af_ax25.c          |    2 +-
 net/bluetooth/hci_sock.c    |    2 +-
 net/bluetooth/mgmt.c        |    2 +-
 net/bluetooth/rfcomm/sock.c |    2 +-
 net/bluetooth/sco.c         |    2 +-
 net/caif/caif_socket.c      |    4 ++--
 net/can/bcm.c               |   19 ++++++++-----------
 net/can/raw.c               |    2 +-
 net/dccp/proto.c            |    2 +-
 net/decnet/af_decnet.c      |    2 +-
 net/ieee802154/dgram.c      |    2 +-
 net/ieee802154/raw.c        |    2 +-
 net/ipv4/ping.c             |    2 +-
 net/ipv4/tcp_input.c        |    2 +-
 net/irda/af_irda.c          |    6 +++---
 net/iucv/af_iucv.c          |    2 +-
 net/key/af_key.c            |    2 +-
 net/l2tp/l2tp_ip.c          |    2 +-
 net/l2tp/l2tp_ppp.c         |    3 +--
 net/llc/af_llc.c            |    2 +-
 net/netlink/af_netlink.c    |    2 +-
 net/netrom/af_netrom.c      |    2 +-
 net/nfc/llcp_commands.c     |    4 ++--
 net/nfc/rawsock.c           |    2 +-
 net/packet/af_packet.c      |    5 ++---
 net/phonet/datagram.c       |    2 +-
 net/phonet/pep.c            |    2 +-
 net/rose/af_rose.c          |    2 +-
 net/sctp/sm_make_chunk.c    |    4 ++--
 net/x25/af_x25.c            |    2 +-
 36 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 83187f4..c3b482b 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -298,9 +298,9 @@ static int skcipher_sendmsg(struct kiocb *unused, struct socket *sock,
 			len = min_t(unsigned long, len,
 				    PAGE_SIZE - sg->offset - sg->length);
 
-			err = memcpy_fromiovec(page_address(sg_page(sg)) +
-					       sg->offset + sg->length,
-					       msg->msg_iov, len);
+			err = memcpy_from_msg(page_address(sg_page(sg)) +
+					      sg->offset + sg->length,
+					      msg, len);
 			if (err)
 				goto unlock;
 
@@ -337,8 +337,8 @@ static int skcipher_sendmsg(struct kiocb *unused, struct socket *sock,
 			if (!sg_page(sg + i))
 				goto unlock;
 
-			err = memcpy_fromiovec(page_address(sg_page(sg + i)),
-					       msg->msg_iov, plen);
+			err = memcpy_from_msg(page_address(sg_page(sg + i)),
+					      msg, plen);
 			if (err) {
 				__free_page(sg_page(sg + i));
 				sg_assign_page(sg + i, NULL);
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index dcbd858..84b3592 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -203,7 +203,7 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!skb)
 		goto done;
 
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		err = -EFAULT;
 		goto done;
 	}
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 443cbbf..d2408a5 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -869,7 +869,7 @@ static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
 	ph = (struct pppoe_hdr *)skb_put(skb, total_len + sizeof(struct pppoe_hdr));
 	start = (char *)&ph->tag[0];
 
-	error = memcpy_fromiovec(start, m->msg_iov, total_len);
+	error = memcpy_from_msg(start, m, total_len);
 	if (error < 0) {
 		kfree_skb(skb);
 		goto end;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cbe4b20..97dc5f8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2687,6 +2687,11 @@ int skb_ensure_writable(struct sk_buff *skb, int write_len);
 int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 
+static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
+{
+	return memcpy_fromiovec(data, msg->msg_iov, len);
+}
+
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 72a31db..487ef34 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -219,7 +219,7 @@ struct sctp_chunk *sctp_make_abort_no_data(const struct sctp_association *,
 				      const struct sctp_chunk *,
 				      __u32 tsn);
 struct sctp_chunk *sctp_make_abort_user(const struct sctp_association *,
-					const struct msghdr *, size_t msg_len);
+					struct msghdr *, size_t msg_len);
 struct sctp_chunk *sctp_make_abort_violation(const struct sctp_association *,
 				   const struct sctp_chunk *,
 				   const __u8 *,
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 425942d..0d0766e 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1659,7 +1659,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 
 	SOCK_DEBUG(sk, "SK %p: Copy user data (%Zd bytes).\n", sk, len);
 
-	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (err) {
 		kfree_skb(skb);
 		err = -EFAULT;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f4f835e19..ca049a7 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1549,7 +1549,7 @@ static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, size - len);
 
 	/* User data follows immediately after the AX.25 data */
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		err = -EFAULT;
 		kfree_skb(skb);
 		goto out;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 5e2cd25..2c245fd 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -947,7 +947,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!skb)
 		goto done;
 
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		err = -EFAULT;
 		goto drop;
 	}
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index cbeef5f..f3e4a16 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -5767,7 +5767,7 @@ int mgmt_control(struct sock *sk, struct msghdr *msg, size_t msglen)
 	if (!buf)
 		return -ENOMEM;
 
-	if (memcpy_fromiovec(buf, msg->msg_iov, msglen)) {
+	if (memcpy_from_msg(buf, msg, msglen)) {
 		err = -EFAULT;
 		goto done;
 	}
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8bbbb5e..2348176 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -588,7 +588,7 @@ static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		}
 		skb_reserve(skb, RFCOMM_SKB_HEAD_RESERVE);
 
-		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		err = memcpy_from_msg(skb_put(skb, size), msg, size);
 		if (err) {
 			kfree_skb(skb);
 			if (sent == 0)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 7ee9e4a..30e5ea3 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -285,7 +285,7 @@ static int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
 	if (!skb)
 		return err;
 
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		kfree_skb(skb);
 		return -EFAULT;
 	}
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index fbcd156..230f140 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -566,7 +566,7 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	skb_reserve(skb, cf_sk->headroom);
 
-	ret = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	ret = memcpy_from_msg(skb_put(skb, len), msg, len);
 
 	if (ret)
 		goto err;
@@ -641,7 +641,7 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		err = memcpy_from_msg(skb_put(skb, size), msg, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index dcb75c0..b9a1f71 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -858,8 +858,7 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 
 		/* update can_frames content */
 		for (i = 0; i < msg_head->nframes; i++) {
-			err = memcpy_fromiovec((u8 *)&op->frames[i],
-					       msg->msg_iov, CFSIZ);
+			err = memcpy_from_msg((u8 *)&op->frames[i], msg, CFSIZ);
 
 			if (op->frames[i].can_dlc > 8)
 				err = -EINVAL;
@@ -894,8 +893,7 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			op->frames = &op->sframe;
 
 		for (i = 0; i < msg_head->nframes; i++) {
-			err = memcpy_fromiovec((u8 *)&op->frames[i],
-					       msg->msg_iov, CFSIZ);
+			err = memcpy_from_msg((u8 *)&op->frames[i], msg, CFSIZ);
 
 			if (op->frames[i].can_dlc > 8)
 				err = -EINVAL;
@@ -1024,9 +1022,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 
 		if (msg_head->nframes) {
 			/* update can_frames content */
-			err = memcpy_fromiovec((u8 *)op->frames,
-					       msg->msg_iov,
-					       msg_head->nframes * CFSIZ);
+			err = memcpy_from_msg((u8 *)op->frames, msg,
+					      msg_head->nframes * CFSIZ);
 			if (err < 0)
 				return err;
 
@@ -1072,8 +1069,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		}
 
 		if (msg_head->nframes) {
-			err = memcpy_fromiovec((u8 *)op->frames, msg->msg_iov,
-					       msg_head->nframes * CFSIZ);
+			err = memcpy_from_msg((u8 *)op->frames, msg,
+					      msg_head->nframes * CFSIZ);
 			if (err < 0) {
 				if (op->frames != &op->sframe)
 					kfree(op->frames);
@@ -1209,7 +1206,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 
 	can_skb_reserve(skb);
 
-	err = memcpy_fromiovec(skb_put(skb, CFSIZ), msg->msg_iov, CFSIZ);
+	err = memcpy_from_msg(skb_put(skb, CFSIZ), msg, CFSIZ);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
@@ -1285,7 +1282,7 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	/* read message head information */
 
-	ret = memcpy_fromiovec((u8 *)&msg_head, msg->msg_iov, MHSIZ);
+	ret = memcpy_from_msg((u8 *)&msg_head, msg, MHSIZ);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/can/raw.c b/net/can/raw.c
index 081e81f..0e4004f 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -703,7 +703,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 
-	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	err = memcpy_from_msg(skb_put(skb, size), msg, size);
 	if (err < 0)
 		goto free_skb;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 8e6ae94..19f0387 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -781,7 +781,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out_release;
 
 	skb_reserve(skb, sk->sk_prot->max_header);
-	rc = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (rc != 0)
 		goto out_discard;
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 25733d5..e2e2e3c 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2032,7 +2032,7 @@ static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		skb_reserve(skb, 64 + DN_MAX_NSP_DATA_HEADER);
 
-		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+		if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 			err = -EFAULT;
 			goto out;
 		}
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index b8555ec..2c7a93e 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -276,7 +276,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (err < 0)
 		goto out_skb;
 
-	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	err = memcpy_from_msg(skb_put(skb, size), msg, size);
 	if (err < 0)
 		goto out_skb;
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 21c3894..61e9d29 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -150,7 +150,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk,
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 
-	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	err = memcpy_from_msg(skb_put(skb, size), msg, size);
 	if (err < 0)
 		goto out_skb;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index ce2920f..ef8f6ee 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -660,7 +660,7 @@ int ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 	 *	Fetch the ICMP header provided by the userland.
 	 *	iovec is modified! The ICMP header is consumed.
 	 */
-	if (memcpy_fromiovec(user_icmph, msg->msg_iov, icmph_len))
+	if (memcpy_from_msg(user_icmph, msg, icmph_len))
 		return -EFAULT;
 
 	if (family == AF_INET) {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d22a31f..69de1a1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4368,7 +4368,7 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
 		goto err_free;
 
-	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
+	if (memcpy_from_msg(skb_put(skb, size), msg, size))
 		goto err_free;
 
 	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index e8c4090..9052462 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1319,7 +1319,7 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reserve(skb, self->max_header_size + 16);
 	skb_reset_transport_header(skb);
 	skb_put(skb, len);
-	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_transport_header(skb), msg, len);
 	if (err) {
 		kfree_skb(skb);
 		goto out_err;
@@ -1569,7 +1569,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 
 	pr_debug("%s(), appending user data\n", __func__);
 	skb_put(skb, len);
-	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_transport_header(skb), msg, len);
 	if (err) {
 		kfree_skb(skb);
 		goto out;
@@ -1678,7 +1678,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 	pr_debug("%s(), appending user data\n", __func__);
 	skb_put(skb, len);
-	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_transport_header(skb), msg, len);
 	if (err) {
 		kfree_skb(skb);
 		goto out;
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 057b564..1cd3f81 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1122,7 +1122,7 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 	if (iucv->transport == AF_IUCV_TRANS_HIPER)
 		skb_reserve(skb, sizeof(struct af_iucv_trans_hdr) + ETH_HLEN);
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		err = -EFAULT;
 		goto fail;
 	}
diff --git a/net/key/af_key.c b/net/key/af_key.c
index e588309..f8ac939 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3611,7 +3611,7 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 		goto out;
 
 	err = -EFAULT;
-	if (memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len))
+	if (memcpy_from_msg(skb_put(skb,len), msg, len))
 		goto out;
 
 	hdr = pfkey_get_base_msg(skb, &err);
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index a6cc1fe..05dfc8a 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -441,7 +441,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	*((__be32 *) skb_put(skb, 4)) = 0;
 
 	/* Copy user data into skb */
-	rc = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (rc < 0) {
 		kfree_skb(skb);
 		goto error;
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index c559bcd..cc7a828 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -346,8 +346,7 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	skb_put(skb, 2);
 
 	/* Copy user data into skb */
-	error = memcpy_fromiovec(skb_put(skb, total_len), m->msg_iov,
-				 total_len);
+	error = memcpy_from_msg(skb_put(skb, total_len), m, total_len);
 	if (error < 0) {
 		kfree_skb(skb);
 		goto error_put_sess_tun;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index af662669..2c0b83c 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -921,7 +921,7 @@ static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb->dev      = llc->dev;
 	skb->protocol = llc_proto_type(addr->sllc_arphrd);
 	skb_reserve(skb, hdrlen);
-	rc = memcpy_fromiovec(skb_put(skb, copied), msg->msg_iov, copied);
+	rc = memcpy_from_msg(skb_put(skb, copied), msg, copied);
 	if (rc)
 		goto out;
 	if (sk->sk_type == SOCK_DGRAM || addr->sllc_ua) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e1aad6e..63aa5c8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2325,7 +2325,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
-	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		kfree_skb(skb);
 		goto out;
 	}
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 7e13f6a..69f1d5e 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1113,7 +1113,7 @@ static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb_put(skb, len);
 
 	/* User data follows immediately after the NET/ROM transport header */
-	if (memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len)) {
+	if (memcpy_from_msg(skb_transport_header(skb), msg, len)) {
 		kfree_skb(skb);
 		err = -EFAULT;
 		goto out;
diff --git a/net/nfc/llcp_commands.c b/net/nfc/llcp_commands.c
index a3ad69a..c4da0c2 100644
--- a/net/nfc/llcp_commands.c
+++ b/net/nfc/llcp_commands.c
@@ -665,7 +665,7 @@ int nfc_llcp_send_i_frame(struct nfc_llcp_sock *sock,
 	if (msg_data == NULL)
 		return -ENOMEM;
 
-	if (memcpy_fromiovec(msg_data, msg->msg_iov, len)) {
+	if (memcpy_from_msg(msg_data, msg, len)) {
 		kfree(msg_data);
 		return -EFAULT;
 	}
@@ -731,7 +731,7 @@ int nfc_llcp_send_ui_frame(struct nfc_llcp_sock *sock, u8 ssap, u8 dsap,
 	if (msg_data == NULL)
 		return -ENOMEM;
 
-	if (memcpy_fromiovec(msg_data, msg->msg_iov, len)) {
+	if (memcpy_from_msg(msg_data, msg, len)) {
 		kfree(msg_data);
 		return -EFAULT;
 	}
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 9d7d2b7..373e138 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -231,7 +231,7 @@ static int rawsock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (skb == NULL)
 		return rc;
 
-	rc = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (rc < 0) {
 		kfree_skb(skb);
 		return rc;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 58af5802..07ac950 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1676,7 +1676,7 @@ retry:
 			if (len < hhlen)
 				skb_reset_network_header(skb);
 		}
-		err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+		err = memcpy_from_msg(skb_put(skb, len), msg, len);
 		if (err)
 			goto out_free;
 		goto retry;
@@ -2446,8 +2446,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 
 		len -= vnet_hdr_len;
 
-		err = memcpy_fromiovec((void *)&vnet_hdr, msg->msg_iov,
-				       vnet_hdr_len);
+		err = memcpy_from_msg((void *)&vnet_hdr, msg, vnet_hdr_len);
 		if (err < 0)
 			goto out_unlock;
 
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 0918bc2..26054b4 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -109,7 +109,7 @@ static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
 		return err;
 	skb_reserve(skb, MAX_PHONET_HEADER);
 
-	err = memcpy_fromiovec((void *)skb_put(skb, len), msg->msg_iov, len);
+	err = memcpy_from_msg((void *)skb_put(skb, len), msg, len);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9cd069d..5d3f2b7 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1141,7 +1141,7 @@ static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
 		return err;
 
 	skb_reserve(skb, MAX_PHONET_HEADER + 3 + pn->aligned);
-	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (err < 0)
 		goto outfree;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 9b600c2..43bac7c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1121,7 +1121,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	skb_put(skb, len);
 
-	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
+	err = memcpy_from_msg(skb_transport_header(skb), msg, len);
 	if (err) {
 		kfree_skb(skb);
 		return err;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9f32741..e49bcce 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1001,7 +1001,7 @@ no_mem:
 
 /* Helper to create ABORT with a SCTP_ERROR_USER_ABORT error.  */
 struct sctp_chunk *sctp_make_abort_user(const struct sctp_association *asoc,
-					const struct msghdr *msg,
+					struct msghdr *msg,
 					size_t paylen)
 {
 	struct sctp_chunk *retval;
@@ -1018,7 +1018,7 @@ struct sctp_chunk *sctp_make_abort_user(const struct sctp_association *asoc,
 		if (!payload)
 			goto err_payload;
 
-		err = memcpy_fromiovec(payload, msg->msg_iov, paylen);
+		err = memcpy_from_msg(payload, msg, paylen);
 		if (err < 0)
 			goto err_copy;
 	}
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 59e785b..d9149b6 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1170,7 +1170,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	skb_put(skb, len);
 
-	rc = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
+	rc = memcpy_from_msg(skb_transport_header(skb), msg, len);
 	if (rc)
 		goto out_kfree_skb;
 
-- 
1.7.10.4
