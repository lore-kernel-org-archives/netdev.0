From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 13:18:58 -0400
Message-ID: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, Pravin B Shelar <pshelar@nicira.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55530 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbIQRXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 13:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These seem to have been accidentally dropped in commit 371bd1061d29
("geneve: Consolidate Geneve functionality in single module.").

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index a917ae1cfbf3..0aaf302cc31b 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/hash.h>
 #include <net/dst_metadata.h>
 #include <net/gro_cells.h>
@@ -532,13 +533,20 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	int err;
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
+			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err)) {
 		kfree_skb(skb);
 		goto free_rt;
 	}
 
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb)) {
+		err = -ENOMEM;
+		goto free_rt;
+	}
+
 	skb = udp_tunnel_handle_offloads(skb, csum);
 	if (IS_ERR(skb)) {
 		err = PTR_ERR(skb);
-- 
2.4.3
