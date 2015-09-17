From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v2] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Thu, 17 Sep 2015 16:34:54 -0400
Message-ID: <1442522094-876-1-git-send-email-linville@tuxdriver.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, Jesse Gross <jesse@nicira.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58721 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbbIQUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:45:12 -0400
In-Reply-To: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems to have been a "thinko".  IP_ECN_decapsulate needs info
from both internal and external headers.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
v2 -- ensure the collect_md path still calls IP_ECN_decapsulate

 drivers/net/geneve.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index da3259ce7c8d..549febac0579 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -126,6 +126,8 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	__be32 addr;
 	int err;
 
+	iph = ip_hdr(skb); /* outer IP header... */
+
 	if (gs->collect_md) {
 		static u8 zero_vni[3];
 
@@ -133,7 +135,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 		addr = 0;
 	} else {
 		vni = gnvh->vni;
-		iph = ip_hdr(skb); /* Still outer IP header... */
 		addr = iph->saddr;
 	}
 
@@ -178,7 +179,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	iph = ip_hdr(skb); /* Now inner IP header... */
 	err = IP_ECN_decapsulate(iph, skb);
 
 	if (unlikely(err)) {
-- 
2.4.3
