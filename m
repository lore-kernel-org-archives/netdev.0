From: roy.qing.li@gmail.com
Subject: [PATCH net-next] xen-netfront: use skb_partial_csum_set() to simplify the codes
Date: Thu,  6 Jun 2013 14:35:18 +0800
Message-ID: <1370500519-2244-1-git-send-email-roy.qing.li@gmail.com>
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:55238 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3FFGfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 02:35:22 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so2924260pdj.15
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 23:35:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

use skb_partial_csum_set() to simplify the codes

Cc: Jason Wang <jasowang@redhat.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/xen-netfront.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 62238a0..76a2236 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -858,7 +858,6 @@ static RING_IDX xennet_fill_frags(struct netfront_info *np,
 static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 {
 	struct iphdr *iph;
-	unsigned char *th;
 	int err = -EPROTO;
 	int recalculate_partial_csum = 0;
 
@@ -883,27 +882,27 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 		goto out;
 
 	iph = (void *)skb->data;
-	th = skb->data + 4 * iph->ihl;
-	if (th >= skb_tail_pointer(skb))
-		goto out;
 
-	skb->csum_start = th - skb->head;
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
-		skb->csum_offset = offsetof(struct tcphdr, check);
+		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
+					  offsetof(struct tcphdr, check)))
+			goto out;
 
 		if (recalculate_partial_csum) {
-			struct tcphdr *tcph = (struct tcphdr *)th;
+			struct tcphdr *tcph = tcp_hdr(skb);
 			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
 							 skb->len - iph->ihl*4,
 							 IPPROTO_TCP, 0);
 		}
 		break;
 	case IPPROTO_UDP:
-		skb->csum_offset = offsetof(struct udphdr, check);
+		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
+					  offsetof(struct udphdr, check)))
+			goto out;
 
 		if (recalculate_partial_csum) {
-			struct udphdr *udph = (struct udphdr *)th;
+			struct udphdr *udph = udp_hdr(skb);
 			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
 							 skb->len - iph->ihl*4,
 							 IPPROTO_UDP, 0);
@@ -917,9 +916,6 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 		goto out;
 	}
 
-	if ((th + skb->csum_offset + 2) > skb_tail_pointer(skb))
-		goto out;
-
 	err = 0;
 
 out:
-- 
1.7.10.4
