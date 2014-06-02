From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv4: use skb frags api in udp4_hwcsum()
Date: Mon,  2 Jun 2014 16:12:02 -0700
Message-ID: <1401750722-4324-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:62879 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbaFBXMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:12:16 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so4718728pbb.11
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 16:12:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/udp.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e07d52b..3c07422 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -727,13 +727,12 @@ EXPORT_SYMBOL(udp_flush_pending_frames);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 {
 	struct udphdr *uh = udp_hdr(skb);
-	struct sk_buff *frags = skb_shinfo(skb)->frag_list;
 	int offset = skb_transport_offset(skb);
 	int len = skb->len - offset;
 	int hlen = len;
 	__wsum csum = 0;
 
-	if (!frags) {
+	if (!skb_has_frag_list(skb)) {
 		/*
 		 * Only one fragment on the socket.
 		 */
@@ -742,15 +741,17 @@ void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 		uh->check = ~csum_tcpudp_magic(src, dst, len,
 					       IPPROTO_UDP, 0);
 	} else {
+		struct sk_buff *frags;
+
 		/*
 		 * HW-checksum won't work as there are two or more
 		 * fragments on the socket so that all csums of sk_buffs
 		 * should be together
 		 */
-		do {
+		skb_walk_frags(skb, frags) {
 			csum = csum_add(csum, frags->csum);
 			hlen -= frags->len;
-		} while ((frags = frags->next));
+		}
 
 		csum = skb_checksum(skb, offset, hlen, csum);
 		skb->ip_summed = CHECKSUM_NONE;
-- 
1.8.3.1
