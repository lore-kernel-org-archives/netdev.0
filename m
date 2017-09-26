From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] packet: only test po->has_vnet_hdr once in packet_snd
Date: Tue, 26 Sep 2017 12:20:17 -0400
Message-ID: <20170926162017.60750-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:32880 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964791AbdIZQUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 12:20:20 -0400
Received: by mail-qt0-f195.google.com with SMTP id b1so7359263qtc.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 09:20:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Packet socket option po->has_vnet_hdr can be updated concurrently with
other operations if no ring is attached.

Do not test the option twice in packet_snd, as the value may change in
between calls. A race on setsockopt disable may cause a packet > mtu
to be sent without having GSO options set.

Fixes: bfd5f4a3d605 ("packet: Add GSO/csum offload support.")
Signed-off-by: Willem de Bruijn <willemb@google.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
---
 net/packet/af_packet.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d288f52c53f7..1da0851f51f2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2840,6 +2840,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	struct packet_sock *po = pkt_sk(sk);
+	bool has_vnet_hdr = false;
 	int hlen, tlen, linear;
 	int extra_len = 0;
 
@@ -2883,6 +2884,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		err = packet_snd_vnet_parse(msg, &len, &vnet_hdr);
 		if (err)
 			goto out_unlock;
+		has_vnet_hdr = true;
 	}
 
 	if (unlikely(sock_flag(sk, SOCK_NOFCS))) {
@@ -2941,7 +2943,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->priority = sk->sk_priority;
 	skb->mark = sockc.mark;
 
-	if (po->has_vnet_hdr) {
+	if (has_vnet_hdr) {
 		err = virtio_net_hdr_to_skb(skb, &vnet_hdr, vio_le());
 		if (err)
 			goto out_free;
-- 
2.14.1.821.g8fa685d3b7-goog
