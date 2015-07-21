From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Tue, 21 Jul 2015 18:14:07 +0200
Message-ID: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	davem@davemloft.net, mostrows@earthlink.net,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38197 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932492AbbGUQOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 12:14:41 -0400
Received: by wibxm9 with SMTP id xm9so62302141wib.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 09:14:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

9c70776 added validation for the packet size in packet_snd. This change
enforced that every packet needs a long enough header and at least one
byte payload.

However, when trying to establish a PPPoE connection the following message
is printed every time a PPPoE discovery packet is sent:
pppd: packet size is too short (24 <= 24)

>From what I can see in the PPPoE code the "PADI" discovery packet can
consist of only a header with no payload (when there is neither a service
name nor a Host-Uniq configured).

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 net/packet/af_packet.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c9e8741..d983f8f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2199,18 +2199,6 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	sock_wfree(skb);
 }
 
-static bool ll_header_truncated(const struct net_device *dev, int len)
-{
-	/* net device doesn't like empty head */
-	if (unlikely(len <= dev->hard_header_len)) {
-		net_warn_ratelimited("%s: packet size is too short (%d <= %d)\n",
-				     current->comm, len, dev->hard_header_len);
-		return true;
-	}
-
-	return false;
-}
-
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, int size_max,
 		__be16 proto, unsigned char *addr, int hlen)
@@ -2286,8 +2274,14 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err < 0))
 			return -EINVAL;
 	} else if (dev->hard_header_len) {
-		if (ll_header_truncated(dev, tp_len))
+		/* net device doesn't like empty head */
+		if (unlikely(len <= dev->hard_header_len)) {
+			net_warn_ratelimited("%s: packet size is too short "
+					"(%d <= %d)\n",
+					current->comm, len,
+					dev->hard_header_len);
 			return -EINVAL;
+		}
 
 		skb_push(skb, dev->hard_header_len);
 		err = skb_store_bits(skb, 0, data,
@@ -2624,8 +2618,13 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		if (unlikely(offset < 0))
 			goto out_free;
 	} else {
-		if (ll_header_truncated(dev, len))
+		if (unlikely(len < dev->hard_header_len)) {
+			net_warn_ratelimited("%s: packet size is shorter than "
+					"minimum header size (%d < %d)\n",
+					current->comm, len,
+					dev->hard_header_len);
 			goto out_free;
+		}
 	}
 
 	/* Returns -EFAULT on error */
-- 
2.4.6
