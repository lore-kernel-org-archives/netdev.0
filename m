From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Thu, 17 Sep 2015 13:17:51 -0400
Message-ID: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55529 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbbIQRXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 13:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems to have been a "thinko".  IP_ECN_decapsulate needs info
from both internal and external headers.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index da3259ce7c8d..a917ae1cfbf3 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -121,10 +121,10 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	struct metadata_dst *tun_dst = NULL;
 	struct geneve_dev *geneve = NULL;
 	struct pcpu_sw_netstats *stats;
-	struct iphdr *iph;
+	struct iphdr *iph = NULL;
 	u8 *vni;
 	__be32 addr;
-	int err;
+	int err = 0;
 
 	if (gs->collect_md) {
 		static u8 zero_vni[3];
@@ -178,13 +178,15 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	iph = ip_hdr(skb); /* Now inner IP header... */
-	err = IP_ECN_decapsulate(iph, skb);
+	if (iph)
+		err = IP_ECN_decapsulate(iph, skb);
 
 	if (unlikely(err)) {
 		if (log_ecn_error)
-			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-					     &iph->saddr, iph->tos);
+			if (iph)
+				net_info_ratelimited("non-ECT from %pI4 "
+						     "with TOS=%#x\n",
+						     &iph->saddr, iph->tos);
 		if (err > 1) {
 			++geneve->dev->stats.rx_frame_errors;
 			++geneve->dev->stats.rx_errors;
-- 
2.4.3
