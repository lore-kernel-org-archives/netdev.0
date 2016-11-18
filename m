From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v2 5/5] af_packet: Use virtio_net_hdr_from_skb() directly.
Date: Fri, 18 Nov 2016 15:40:42 -0800
Message-ID: <1479512442-61601-5-git-send-email-jarno@ovn.org>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:44212 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753219AbcKRXlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:41:00 -0500
In-Reply-To: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove static function __packet_rcv_vnet(), which only called
virtio_net_hdr_from_skb() and BUG()ged out if an error code was
returned.  Instead, call virtio_net_hdr_from_skb() from the former
call sites of __packet_rcv_vnet() and actually use the error handling
code that is already there.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/packet/af_packet.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1816b77..fab9bbf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1967,15 +1967,6 @@ static unsigned int run_filter(struct sk_buff *skb,
 	return res;
 }
 
-static int __packet_rcv_vnet(const struct sk_buff *skb,
-			     struct virtio_net_hdr *vnet_hdr)
-{
-	if (virtio_net_hdr_from_skb(skb, vnet_hdr, vio_le()))
-		BUG();
-
-	return 0;
-}
-
 static int packet_rcv_vnet(struct msghdr *msg, const struct sk_buff *skb,
 			   size_t *len)
 {
@@ -1985,7 +1976,7 @@ static int packet_rcv_vnet(struct msghdr *msg, const struct sk_buff *skb,
 		return -EINVAL;
 	*len -= sizeof(vnet_hdr);
 
-	if (__packet_rcv_vnet(skb, &vnet_hdr))
+	if (virtio_net_hdr_from_skb(skb, &vnet_hdr, vio_le()))
 		return -EINVAL;
 
 	return memcpy_to_msg(msg, (void *)&vnet_hdr, sizeof(vnet_hdr));
@@ -2244,8 +2235,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	if (po->has_vnet_hdr) {
-		if (__packet_rcv_vnet(skb, h.raw + macoff -
-					   sizeof(struct virtio_net_hdr))) {
+		if (virtio_net_hdr_from_skb(skb, h.raw + macoff -
+					    sizeof(struct virtio_net_hdr),
+					    vio_le())) {
 			spin_lock(&sk->sk_receive_queue.lock);
 			goto drop_n_account;
 		}
-- 
2.1.4
