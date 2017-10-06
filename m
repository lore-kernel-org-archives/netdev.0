From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 3/7] nfp: add IPv6 ttl and tos match offloading support
Date: Fri,  6 Oct 2017 10:21:22 +0200
Message-ID: <1507278086-3102-4-git-send-email-simon.horman@netronome.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:56416 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751477AbdJFIVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:36 -0400
Received: by mail-wm0-f41.google.com with SMTP id l68so6347409wmd.5
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:36 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously matching on IPv6 ttl and tos fields were not offloaded. This
patch enables offloading IPv6 ttl and tos as match fields.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/match.c   | 11 ++++++++++-
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 10 ----------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/match.c b/drivers/net/ethernet/netronome/nfp/flower/match.c
index d6096b4f1391..60614d4f0e22 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/match.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/match.c
@@ -194,7 +194,6 @@ nfp_flower_compile_ipv6(struct nfp_flower_ipv6 *frame,
 	struct flow_dissector_key_ipv6_addrs *addr;
 	struct flow_dissector_key_basic *basic;
 
-	/* Wildcard LABEL/TOS/TTL for now. */
 	memset(frame, 0, sizeof(struct nfp_flower_ipv6));
 
 	if (dissector_uses_key(flow->dissector,
@@ -212,6 +211,16 @@ nfp_flower_compile_ipv6(struct nfp_flower_ipv6 *frame,
 						  target);
 		frame->proto = basic->ip_proto;
 	}
+
+	if (dissector_uses_key(flow->dissector, FLOW_DISSECTOR_KEY_IP)) {
+		struct flow_dissector_key_ip *flow_ip;
+
+		flow_ip = skb_flow_dissector_target(flow->dissector,
+						    FLOW_DISSECTOR_KEY_IP,
+						    target);
+		frame->tos = flow_ip->tos;
+		frame->ttl = flow_ip->ttl;
+	}
 }
 
 static void
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 3651db5dfb8b..6f239c27964e 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -135,7 +135,6 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 {
 	struct flow_dissector_key_basic *mask_basic = NULL;
 	struct flow_dissector_key_basic *key_basic = NULL;
-	struct flow_dissector_key_ip *mask_ip = NULL;
 	u32 key_layer_two;
 	u8 key_layer;
 	int key_size;
@@ -207,11 +206,6 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 						      flow->key);
 	}
 
-	if (dissector_uses_key(flow->dissector, FLOW_DISSECTOR_KEY_IP))
-		mask_ip = skb_flow_dissector_target(flow->dissector,
-						    FLOW_DISSECTOR_KEY_IP,
-						    flow->mask);
-
 	if (mask_basic && mask_basic->n_proto) {
 		/* Ethernet type is present in the key. */
 		switch (key_basic->n_proto) {
@@ -221,10 +215,6 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 			break;
 
 		case cpu_to_be16(ETH_P_IPV6):
-			if (mask_ip && mask_ip->tos)
-				return -EOPNOTSUPP;
-			if (mask_ip && mask_ip->ttl)
-				return -EOPNOTSUPP;
 			key_layer |= NFP_FLOWER_LAYER_IPV6;
 			key_size += sizeof(struct nfp_flower_ipv6);
 			break;
-- 
2.1.4
