From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] packet: make packet_snd fail on len smaller than l2 header
Date: Wed, 19 Nov 2014 11:56:05 -0500
Message-ID: <1416416165-24697-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, dborkman@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:42718 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910AbaKSQ4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 11:56:09 -0500
Received: by mail-yh0-f43.google.com with SMTP id z6so458537yhz.2
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 08:56:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
packet is at least as long as the device's expected link layer header.
This check already exists in tpacket_snd, but not in packet_snd.
Also rate limit the warning in tpacket_snd.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4cd13d8..0d3cb44 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2095,6 +2095,18 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	sock_wfree(skb);
 }
 
+static bool ll_header_truncated(int len, struct net_device *dev)
+{
+	/* net device doesn't like empty head */
+	if (unlikely(len <= dev->hard_header_len)) {
+		net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
+				     current->comm, len, dev->hard_header_len);
+		return true;
+	}
+
+	return false;
+}
+
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, int size_max,
 		__be16 proto, unsigned char *addr, int hlen)
@@ -2170,12 +2182,8 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err < 0))
 			return -EINVAL;
 	} else if (dev->hard_header_len) {
-		/* net device doesn't like empty head */
-		if (unlikely(tp_len <= dev->hard_header_len)) {
-			pr_err("packet size is too short (%d < %d)\n",
-			       tp_len, dev->hard_header_len);
+		if (ll_header_truncated(tp_len, dev))
 			return -EINVAL;
-		}
 
 		skb_push(skb, dev->hard_header_len);
 		err = skb_store_bits(skb, 0, data,
@@ -2500,9 +2508,15 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb_set_network_header(skb, reserve);
 
 	err = -EINVAL;
-	if (sock->type == SOCK_DGRAM &&
-	    (offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len)) < 0)
-		goto out_free;
+	if (sock->type == SOCK_DGRAM) {
+		offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL,
+					 len);
+		if (unlikely(offset) < 0)
+			goto out_free;
+	} else {
+		if (ll_header_truncated(len, dev))
+			goto out_free;
+	}
 
 	/* Returns -EFAULT on error */
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
-- 
2.1.0.rc2.206.gedb03e5
