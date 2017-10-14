From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 2/2] net: add skb_memcpy_to[from]_msg() to optimize skb code
Date: Sat, 14 Oct 2017 10:27:12 +0800
Message-ID: <1507948032-4786-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:54275 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753229AbdJNC1m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 22:27:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

add these two wrappers in skbuff.h which is better named
than previous and only used for skb.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/isdn/mISDN/socket.c        |  2 +-
 drivers/staging/irda/net/af_irda.c |  2 +-
 include/linux/skbuff.h             | 10 ++++++++++
 net/appletalk/ddp.c                |  2 +-
 net/ax25/af_ax25.c                 |  2 +-
 net/bluetooth/hci_sock.c           |  4 ++--
 net/bluetooth/rfcomm/sock.c        |  2 +-
 net/bluetooth/sco.c                |  2 +-
 net/caif/caif_socket.c             |  6 +++---
 net/can/bcm.c                      |  4 ++--
 net/can/raw.c                      |  4 ++--
 net/dccp/proto.c                   |  2 +-
 net/decnet/af_decnet.c             |  4 ++--
 net/ieee802154/socket.c            |  4 ++--
 net/ipx/ipx_route.c                |  2 +-
 net/key/af_key.c                   |  2 +-
 net/l2tp/l2tp_ip.c                 |  2 +-
 net/l2tp/l2tp_ppp.c                |  2 +-
 net/llc/af_llc.c                   |  2 +-
 net/netlink/af_netlink.c           |  2 +-
 net/nfc/rawsock.c                  |  2 +-
 net/packet/af_packet.c             |  2 +-
 net/phonet/datagram.c              |  2 +-
 net/phonet/pep.c                   |  2 +-
 24 files changed, 40 insertions(+), 30 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index c5603d1..19ecf62 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -202,7 +202,7 @@ mISDN_sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (!skb)
 		goto done;
 
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		err = -EFAULT;
 		goto done;
 	}
diff --git a/drivers/staging/irda/net/af_irda.c b/drivers/staging/irda/net/af_irda.c
index 23fa7c8..159fc1a 100644
--- a/drivers/staging/irda/net/af_irda.c
+++ b/drivers/staging/irda/net/af_irda.c
@@ -1469,7 +1469,7 @@ static int irda_recvmsg_stream(struct socket *sock, struct msghdr *msg,
 		}
 
 		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_to_msg(msg, skb->data, chunk)) {
+		if (skb_memcpy_to_msg(msg, skb, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (copied == 0)
 				copied = -EFAULT;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 90868d1..901fa60 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3294,6 +3294,16 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
 			     gfp_t gfp);
 
+static inline int skb_memcpy_from_msg(struct sk_buff *skb, struct msghdr *msg, int len)
+{
+	return memcpy_from_msg(skb_put(skb, len), msg, len);
+}
+
+static inline int skb_memcpy_to_msg(struct msghdr *msg, struct sk_buff *skb, int len)
+{
+	return memcpy_to_msg(msg, skb->data, len);
+}
+
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
 	__wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 5d035c1..c7846c3 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1658,7 +1658,7 @@ static int atalk_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	SOCK_DEBUG(sk, "SK %p: Copy user data (%zd bytes).\n", sk, len);
 
-	err = memcpy_from_msg(skb_put(skb, len), msg, len);
+	err = skb_memcpy_from_msg(skb, msg, len);
 	if (err) {
 		kfree_skb(skb);
 		err = -EFAULT;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f3f9d18..442763e 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1552,7 +1552,7 @@ static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	skb_reserve(skb, size - len);
 
 	/* User data follows immediately after the AX.25 data */
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		err = -EFAULT;
 		kfree_skb(skb);
 		goto out;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 65d734c..349c79a 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -1601,7 +1601,7 @@ static int hci_logging_frame(struct sock *sk, struct msghdr *msg, int len)
 	if (!skb)
 		return err;
 
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		err = -EFAULT;
 		goto drop;
 	}
@@ -1726,7 +1726,7 @@ static int hci_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (!skb)
 		goto done;
 
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		err = -EFAULT;
 		goto drop;
 	}
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 1aaccf6..41d19dc 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -594,7 +594,7 @@ static int rfcomm_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 		}
 		skb_reserve(skb, RFCOMM_SKB_HEAD_RESERVE);
 
-		err = memcpy_from_msg(skb_put(skb, size), msg, size);
+		err = skb_memcpy_from_msg(skb, msg, size);
 		if (err) {
 			kfree_skb(skb);
 			if (sent == 0)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 795e920..01958d2 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -288,7 +288,7 @@ static int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
 	if (!skb)
 		return err;
 
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		kfree_skb(skb);
 		return -EFAULT;
 	}
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 632d5a4..6b49e5a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -422,7 +422,7 @@ static int caif_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 		}
 		release_sock(sk);
 		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_to_msg(msg, skb->data, chunk)) {
+		if (skb_memcpy_to_msg(msg, skb, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			if (copied == 0)
 				copied = -EFAULT;
@@ -570,7 +570,7 @@ static int caif_seqpkt_sendmsg(struct socket *sock, struct msghdr *msg,
 
 	skb_reserve(skb, cf_sk->headroom);
 
-	ret = memcpy_from_msg(skb_put(skb, len), msg, len);
+	ret = skb_memcpy_from_msg(skb, msg, len);
 
 	if (ret)
 		goto err;
@@ -645,7 +645,7 @@ static int caif_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		err = memcpy_from_msg(skb_put(skb, size), msg, size);
+		err = skb_memcpy_from_msg(skb, msg, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 47a8748d..6fb4670 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1269,7 +1269,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk,
 
 	can_skb_reserve(skb);
 
-	err = memcpy_from_msg(skb_put(skb, cfsiz), msg, cfsiz);
+	err = skb_memcpy_from_msg(skb, msg, cfsiz);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
@@ -1642,7 +1642,7 @@ static int bcm_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	if (skb->len < size)
 		size = skb->len;
 
-	err = memcpy_to_msg(msg, skb->data, size);
+	err = skb_memcpy_to_msg(msg, skb, size);
 	if (err < 0) {
 		skb_free_datagram(sk, skb);
 		return err;
diff --git a/net/can/raw.c b/net/can/raw.c
index 864c80d..b52d1db 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -766,7 +766,7 @@ static int raw_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 	can_skb_prv(skb)->skbcnt = 0;
 
-	err = memcpy_from_msg(skb_put(skb, size), msg, size);
+	err = skb_memcpy_from_msg(skb, msg, size);
 	if (err < 0)
 		goto free_skb;
 
@@ -813,7 +813,7 @@ static int raw_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	else
 		size = skb->len;
 
-	err = memcpy_to_msg(msg, skb->data, size);
+	err = skb_memcpy_to_msg(msg, skb, size);
 	if (err < 0) {
 		skb_free_datagram(sk, skb);
 		return err;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index b68168f..affe21a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -785,7 +785,7 @@ int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		goto out_release;
 
 	skb_reserve(skb, sk->sk_prot->max_header);
-	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
+	rc = skb_memcpy_from_msg(skb, msg, len);
 	if (rc != 0)
 		goto out_discard;
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 73a0399..6fa54fd 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1765,7 +1765,7 @@ static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		if ((chunk + copied) > size)
 			chunk = size - copied;
 
-		if (memcpy_to_msg(msg, skb->data, chunk)) {
+		if (skb_memcpy_to_msg(msg, skb, chunk)) {
 			rv = -EFAULT;
 			break;
 		}
@@ -2036,7 +2036,7 @@ static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 
 		skb_reserve(skb, 64 + DN_MAX_NSP_DATA_HEADER);
 
-		if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+		if (skb_memcpy_from_msg(skb, msg, len)) {
 			err = -EFAULT;
 			goto out;
 		}
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index a60658c..c4072a4 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -296,7 +296,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 
-	err = memcpy_from_msg(skb_put(skb, size), msg, size);
+	err = skb_memcpy_from_msg(skb, msg, size);
 	if (err < 0)
 		goto out_skb;
 
@@ -684,7 +684,7 @@ static int dgram_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	if (err < 0)
 		goto out_skb;
 
-	err = memcpy_from_msg(skb_put(skb, size), msg, size);
+	err = skb_memcpy_from_msg(skb, msg, size);
 	if (err < 0)
 		goto out_skb;
 
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index b5d9144..72c8403 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -229,7 +229,7 @@ int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 	memcpy(ipx->ipx_dest.node, usipx->sipx_node, IPX_NODE_LEN);
 	ipx->ipx_dest.sock		= usipx->sipx_port;
 
-	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
+	rc = skb_memcpy_from_msg(skb, msg, len);
 	if (rc) {
 		kfree_skb(skb);
 		goto out_put;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index a00d607..af9b4b9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3637,7 +3637,7 @@ static int pfkey_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		goto out;
 
 	err = -EFAULT;
-	if (memcpy_from_msg(skb_put(skb,len), msg, len))
+	if (skb_memcpy_from_msg(skb, msg, len))
 		goto out;
 
 	hdr = pfkey_get_base_msg(skb, &err);
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 4d322c1..3640f92 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -458,7 +458,7 @@ static int l2tp_ip_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	*((__be32 *) skb_put(skb, 4)) = 0;
 
 	/* Copy user data into skb */
-	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
+	rc = skb_memcpy_from_msg(skb, msg, len);
 	if (rc < 0) {
 		kfree_skb(skb);
 		goto error;
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index bc6e8bf..c54ebaf 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -329,7 +329,7 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 	skb_put(skb, 2);
 
 	/* Copy user data into skb */
-	error = memcpy_from_msg(skb_put(skb, total_len), m, total_len);
+	error = skb_memcpy_from_msg(skb, m, total_len);
 	if (error < 0) {
 		kfree_skb(skb);
 		goto error_put_sess_tun;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c38d16f..aed88a1 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -928,7 +928,7 @@ static int llc_ui_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->dev      = llc->dev;
 	skb->protocol = llc_proto_type(addr->sllc_arphrd);
 	skb_reserve(skb, hdrlen);
-	rc = memcpy_from_msg(skb_put(skb, copied), msg, copied);
+	rc = skb_memcpy_from_msg(skb, msg, copied);
 	if (rc)
 		goto out;
 	if (sk->sk_type == SOCK_DGRAM || addr->sllc_ua) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f347506..5ce9ac2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1844,7 +1844,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
+	if (skb_memcpy_from_msg(skb, msg, len)) {
 		kfree_skb(skb);
 		goto out;
 	}
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index e2188de..a7bf4d4 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -230,7 +230,7 @@ static int rawsock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (skb == NULL)
 		return rc;
 
-	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
+	rc = skb_memcpy_from_msg(skb, msg, len);
 	if (rc < 0) {
 		kfree_skb(skb);
 		return rc;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3f5caa3..162460b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1972,7 +1972,7 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 			if (len < hhlen)
 				skb_reset_network_header(skb);
 		}
-		err = memcpy_from_msg(skb_put(skb, len), msg, len);
+		err = skb_memcpy_from_msg(skb, msg, len);
 		if (err)
 			goto out_free;
 		goto retry;
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index b44fb90..1ea1105 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -108,7 +108,7 @@ static int pn_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		return err;
 	skb_reserve(skb, MAX_PHONET_HEADER);
 
-	err = memcpy_from_msg((void *)skb_put(skb, len), msg, len);
+	err = skb_memcpy_from_msg(skb, msg, len);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9fc76b1..84870b6 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1143,7 +1143,7 @@ static int pep_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		return err;
 
 	skb_reserve(skb, MAX_PHONET_HEADER + 3 + pn->aligned);
-	err = memcpy_from_msg(skb_put(skb, len), msg, len);
+	err = skb_memcpy_from_msg(skb, msg, len);
 	if (err < 0)
 		goto outfree;
 
-- 
2.7.4
