From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v2 3/5] virtio_net: Do not clear memory for struct virtio_net_hdr twice.
Date: Fri, 18 Nov 2016 15:40:40 -0800
Message-ID: <1479512442-61601-3-git-send-email-jarno@ovn.org>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:45304 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753025AbcKRXk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:40:58 -0500
In-Reply-To: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio_net_hdr_from_skb() clears the memory for the header, so there
is no point for the callers to do the same.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 drivers/net/tun.c          | 3 +--
 include/linux/virtio_net.h | 2 +-
 net/packet/af_packet.c     | 2 --
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3b8d8cc..64e694c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1360,8 +1360,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	}
 
 	if (vnet_hdr_sz) {
-		struct virtio_net_hdr gso = { 0 }; /* no info leak */
-		int ret;
+		struct virtio_net_hdr gso;
 
 		if (iov_iter_count(iter) < vnet_hdr_sz)
 			return -EINVAL;
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 74f1e33..6620400 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -58,7 +58,7 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 					  struct virtio_net_hdr *hdr,
 					  bool little_endian)
 {
-	memset(hdr, 0, sizeof(*hdr));
+	memset(hdr, 0, sizeof(*hdr));   /* no info leak */
 
 	if (skb_is_gso(skb)) {
 		struct skb_shared_info *sinfo = skb_shinfo(skb);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d2238b2..abe6c0b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1970,8 +1970,6 @@ static unsigned int run_filter(struct sk_buff *skb,
 static int __packet_rcv_vnet(const struct sk_buff *skb,
 			     struct virtio_net_hdr *vnet_hdr)
 {
-	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
-
 	if (virtio_net_hdr_from_skb(skb, vnet_hdr, vio_le()))
 		BUG();
 
-- 
2.1.4
