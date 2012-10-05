From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: [PATCH] Packet mmap : allow the user to choose the offset of the tx payload.
Date: Fri,  5 Oct 2012 15:10:29 +0200
Message-ID: <1349442629-10960-1-git-send-email-paul.chavent@onera.fr>
Cc: Paul Chavent <Paul.Chavent@onera.fr>
To: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net, uaca@alumni.uv.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:51386 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927Ab2JEN0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 09:26:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx offset of packet mmap tx ring used to be :
(TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))

The problem is that depending on the usage of SOCK_DGRAM or
SOCK_RAW, the payload could be aligned or not.

This patch allow to let the user give an offset for it's tx
payload if he desires.

Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
---
 net/packet/af_packet.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 94060ed..5bf3100 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1851,7 +1851,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		struct tpacket2_hdr *h2;
 		void *raw;
 	} ph;
-	int to_write, offset, len, tp_len, nr_frags, len_max;
+	int to_write, offset, len, tp_len, nr_frags, len_max, off;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
 	void *data;
@@ -1868,9 +1868,11 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	switch (po->tp_version) {
 	case TPACKET_V2:
 		tp_len = ph.h2->tp_len;
+		off = ph.h2->tp_net;
 		break;
 	default:
 		tp_len = ph.h1->tp_len;
+		off = ph.h1->tp_net;
 		break;
 	}
 	if (unlikely(tp_len > size_max)) {
@@ -1882,6 +1884,16 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb_reset_network_header(skb);
 
 	data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
+	if (sock->type != SOCK_DGRAM)
+		off -= dev->hard_header_len;
+	if (likely((po->tp_hdrlen - sizeof(struct sockaddr_ll)) < off)) {
+		if (unlikely((off + tp_len) > size_max)) {
+			pr_err("packet size is too long (%d + %d > %d)\n",
+				off, tp_len, size_max);
+			return -EMSGSIZE;
+		}
+		data = ph.raw + off;
+	}
 	to_write = tp_len;
 
 	if (sock->type == SOCK_DGRAM) {
-- 
1.7.12.1
