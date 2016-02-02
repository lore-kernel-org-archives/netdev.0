From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 3/4] packet: parse tpacket header before skb alloc
Date: Tue,  2 Feb 2016 10:56:48 -0500
Message-ID: <1454428609-26885-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:36281 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933327AbcBBP45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:56:57 -0500
Received: by mail-qg0-f66.google.com with SMTP id u30so1067342qge.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:56:57 -0800 (PST)
In-Reply-To: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

GSO packet headers must be stored in the linear skb segment.
Move tpacket header parsing before sock_alloc_send_skb. The GSO
follow-on patch will later increase the skb linear argument to
sock_alloc_send_skb if needed for large packets.

The header parsing code does not require an allocated skb, so is
safe to move. After allocation, pass to tpacket_fill_skb the computed
data start and length.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 111 +++++++++++++++++++++++++++++--------------------
 1 file changed, 65 insertions(+), 46 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b26df32..89377bf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2494,14 +2494,13 @@ static int packet_snd_vnet_gso(struct sk_buff *skb,
 }
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
-		void *frame, struct net_device *dev, int size_max,
+		void *frame, struct net_device *dev, void *data, int tp_len,
 		__be16 proto, unsigned char *addr, int hlen)
 {
 	union tpacket_uhdr ph;
-	int to_write, offset, len, tp_len, nr_frags, len_max;
+	int to_write, offset, len, nr_frags, len_max;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
-	void *data;
 	int err;
 
 	ph.raw = frame;
@@ -2513,51 +2512,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
 	skb_shinfo(skb)->destructor_arg = ph.raw;
 
-	switch (po->tp_version) {
-	case TPACKET_V2:
-		tp_len = ph.h2->tp_len;
-		break;
-	default:
-		tp_len = ph.h1->tp_len;
-		break;
-	}
-	if (unlikely(tp_len > size_max)) {
-		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
-		return -EMSGSIZE;
-	}
-
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 
-	if (unlikely(po->tp_tx_has_off)) {
-		int off_min, off_max, off;
-		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
-		off_max = po->tx_ring.frame_size - tp_len;
-		if (sock->type == SOCK_DGRAM) {
-			switch (po->tp_version) {
-			case TPACKET_V2:
-				off = ph.h2->tp_net;
-				break;
-			default:
-				off = ph.h1->tp_net;
-				break;
-			}
-		} else {
-			switch (po->tp_version) {
-			case TPACKET_V2:
-				off = ph.h2->tp_mac;
-				break;
-			default:
-				off = ph.h1->tp_mac;
-				break;
-			}
-		}
-		if (unlikely((off < off_min) || (off_max < off)))
-			return -EINVAL;
-		data = ph.raw + off;
-	} else {
-		data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
-	}
 	to_write = tp_len;
 
 	if (sock->type == SOCK_DGRAM) {
@@ -2615,6 +2572,61 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	return tp_len;
 }
 
+static int tpacket_parse_header(struct packet_sock *po, void *frame,
+				int size_max, void **data)
+{
+	union tpacket_uhdr ph;
+	int tp_len, off;
+
+	ph.raw = frame;
+
+	switch (po->tp_version) {
+	case TPACKET_V2:
+		tp_len = ph.h2->tp_len;
+		break;
+	default:
+		tp_len = ph.h1->tp_len;
+		break;
+	}
+	if (unlikely(tp_len > size_max)) {
+		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
+		return -EMSGSIZE;
+	}
+
+	if (unlikely(po->tp_tx_has_off)) {
+		int off_min, off_max;
+
+		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
+		off_max = po->tx_ring.frame_size - tp_len;
+		if (po->sk.sk_type == SOCK_DGRAM) {
+			switch (po->tp_version) {
+			case TPACKET_V2:
+				off = ph.h2->tp_net;
+				break;
+			default:
+				off = ph.h1->tp_net;
+				break;
+			}
+		} else {
+			switch (po->tp_version) {
+			case TPACKET_V2:
+				off = ph.h2->tp_mac;
+				break;
+			default:
+				off = ph.h1->tp_mac;
+				break;
+			}
+		}
+		if (unlikely((off < off_min) || (off_max < off)))
+			return -EINVAL;
+	} else {
+		off = po->tp_hdrlen - sizeof(struct sockaddr_ll);
+	}
+
+	*data = frame + off;
+	return tp_len;
+}
+
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 {
 	struct sk_buff *skb;
@@ -2626,6 +2638,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	bool need_wait = !(msg->msg_flags & MSG_DONTWAIT);
 	int tp_len, size_max;
 	unsigned char *addr;
+	void *data;
 	int len_sum = 0;
 	int status = TP_STATUS_AVAILABLE;
 	int hlen, tlen;
@@ -2673,6 +2686,11 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			continue;
 		}
 
+		skb = NULL;
+		tp_len = tpacket_parse_header(po, ph, size_max, &data);
+		if (tp_len < 0)
+			goto tpacket_error;
+
 		status = TP_STATUS_SEND_REQUEST;
 		hlen = LL_RESERVED_SPACE(dev);
 		tlen = dev->needed_tailroom;
@@ -2686,7 +2704,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 				err = len_sum;
 			goto out_status;
 		}
-		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
+		tp_len = tpacket_fill_skb(po, skb, ph, dev, data, tp_len, proto,
 					  addr, hlen);
 		if (likely(tp_len >= 0) &&
 		    tp_len > dev->mtu + reserve &&
@@ -2694,6 +2712,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			tp_len = -EMSGSIZE;
 
 		if (unlikely(tp_len < 0)) {
+tpacket_error:
 			if (po->tp_loss) {
 				__packet_set_status(po, ph,
 						TP_STATUS_AVAILABLE);
-- 
2.7.0.rc3.207.g0ac5344
