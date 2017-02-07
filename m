From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 2/2] packet: round up linear to header len
Date: Tue,  7 Feb 2017 15:57:21 -0500
Message-ID: <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35281 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932357AbdBGU52 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:57:28 -0500
Received: by mail-qt0-f194.google.com with SMTP id s58so20736951qtc.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:57:28 -0800 (PST)
In-Reply-To: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Link layer protocols may unconditionally pull headers, as Ethernet
does in eth_type_trans. Ensure that the entire link layer header
always lies in the skb linear segment. tpacket_snd has such a check.
Extend this to packet_snd.

Variable length link layer headers complicate the computation
somewhat. Here skb->len may be smaller than dev->hard_header_len.

Round up the linear length to be at least as long as the smallest of
the two.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3d555c79a7b5..d56ee46b11fc 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2755,7 +2755,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	struct packet_sock *po = pkt_sk(sk);
-	int hlen, tlen;
+	int hlen, tlen, linear;
 	int extra_len = 0;
 
 	/*
@@ -2816,8 +2816,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	err = -ENOBUFS;
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
-	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
-			       __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
+	linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
+	linear = max(linear, min_t(int, len, dev->hard_header_len));
+	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
 			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out_unlock;
-- 
2.11.0.483.g087da7b7c-goog
