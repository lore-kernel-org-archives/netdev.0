From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Subject: [PATCH net 2/3] nfp: fix supported key layers calculation
Date: Fri, 25 Aug 2017 19:31:02 +0200
Message-ID: <1503682263-17858-3-git-send-email-pieter.jansenvanvuuren@netronome.com>
References: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        simon.horman@netronome.com, jakub.kicinski@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35792 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756096AbdHYRbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 13:31:14 -0400
Received: by mail-wr0-f178.google.com with SMTP id p8so1345761wrf.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 10:31:13 -0700 (PDT)
In-Reply-To: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously when calculating the supported key layers MPLS, IPv4/6
TTL and TOS were not considered. This patch checks that the TTL and
TOS fields are masked out before offloading. Additionally this patch
checks that MPLS packets are correctly handled, by not offloading them.

Fixes: af9d842c1354 ("nfp: extend flower add flow offload")
Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 6c8ecc2..74a96d6 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -107,6 +107,7 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 {
 	struct flow_dissector_key_basic *mask_basic = NULL;
 	struct flow_dissector_key_basic *key_basic = NULL;
+	struct flow_dissector_key_ip *mask_ip = NULL;
 	u32 key_layer_two;
 	u8 key_layer;
 	int key_size;
@@ -132,6 +133,11 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 						      flow->key);
 	}
 
+	if (dissector_uses_key(flow->dissector, FLOW_DISSECTOR_KEY_IP))
+		mask_ip = skb_flow_dissector_target(flow->dissector,
+						    FLOW_DISSECTOR_KEY_IP,
+						    flow->mask);
+
 	key_layer_two = 0;
 	key_layer = NFP_FLOWER_LAYER_PORT | NFP_FLOWER_LAYER_MAC;
 	key_size = sizeof(struct nfp_flower_meta_one) +
@@ -142,11 +148,19 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 		/* Ethernet type is present in the key. */
 		switch (key_basic->n_proto) {
 		case cpu_to_be16(ETH_P_IP):
+			if (mask_ip && mask_ip->tos)
+				return -EOPNOTSUPP;
+			if (mask_ip && mask_ip->ttl)
+				return -EOPNOTSUPP;
 			key_layer |= NFP_FLOWER_LAYER_IPV4;
 			key_size += sizeof(struct nfp_flower_ipv4);
 			break;
 
 		case cpu_to_be16(ETH_P_IPV6):
+			if (mask_ip && mask_ip->tos)
+				return -EOPNOTSUPP;
+			if (mask_ip && mask_ip->ttl)
+				return -EOPNOTSUPP;
 			key_layer |= NFP_FLOWER_LAYER_IPV6;
 			key_size += sizeof(struct nfp_flower_ipv6);
 			break;
@@ -157,6 +171,11 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 		case cpu_to_be16(ETH_P_ARP):
 			return -EOPNOTSUPP;
 
+		/* Currently we do not offload MPLS. */
+		case cpu_to_be16(ETH_P_MPLS_UC):
+		case cpu_to_be16(ETH_P_MPLS_MC):
+			return -EOPNOTSUPP;
+
 		/* Will be included in layer 2. */
 		case cpu_to_be16(ETH_P_8021Q):
 			break;
-- 
2.7.4
