From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 2/7] nfp: add IPv4 ttl and tos match offloading support
Date: Fri,  6 Oct 2017 10:21:21 +0200
Message-ID: <1507278086-3102-3-git-send-email-simon.horman@netronome.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:46442 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbdJFIVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:35 -0400
Received: by mail-wm0-f51.google.com with SMTP id m72so6131897wmc.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:34 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously matching on IPv4 ttl and tos fields were not offloaded. This
patch enables offloading IPv4 ttl and tos as match fields.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/match.c   | 11 ++++++++++-
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  4 ----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/match.c b/drivers/net/ethernet/netronome/nfp/flower/match.c
index e35ade9cd3d5..d6096b4f1391 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/match.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/match.c
@@ -156,7 +156,6 @@ nfp_flower_compile_ipv4(struct nfp_flower_ipv4 *frame,
 	struct flow_dissector_key_ipv4_addrs *addr;
 	struct flow_dissector_key_basic *basic;
 
-	/* Wildcard TOS/TTL for now. */
 	memset(frame, 0, sizeof(struct nfp_flower_ipv4));
 
 	if (dissector_uses_key(flow->dissector,
@@ -174,6 +173,16 @@ nfp_flower_compile_ipv4(struct nfp_flower_ipv4 *frame,
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
index a721a00a2bcc..3651db5dfb8b 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -216,10 +216,6 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 		/* Ethernet type is present in the key. */
 		switch (key_basic->n_proto) {
 		case cpu_to_be16(ETH_P_IP):
-			if (mask_ip && mask_ip->tos)
-				return -EOPNOTSUPP;
-			if (mask_ip && mask_ip->ttl)
-				return -EOPNOTSUPP;
 			key_layer |= NFP_FLOWER_LAYER_IPV4;
 			key_size += sizeof(struct nfp_flower_ipv4);
 			break;
-- 
2.1.4
