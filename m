From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 1/7] nfp: add mpls match offloading support
Date: Fri,  6 Oct 2017 10:21:20 +0200
Message-ID: <1507278086-3102-2-git-send-email-simon.horman@netronome.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:54382 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdJFIVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:32 -0400
Received: by mail-wm0-f48.google.com with SMTP id i124so6347085wmf.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:31 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously MPLS match offloading was not supported. This patch enables
MPLS match offloading support for label, bos and tc fields.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h    |  5 +++++
 drivers/net/ethernet/netronome/nfp/flower/match.c   | 17 +++++++++++++++--
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  6 +-----
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 504ddaa21701..fe4751607b2b 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -57,6 +57,11 @@
 #define NFP_FLOWER_MASK_VLAN_CFI	BIT(12)
 #define NFP_FLOWER_MASK_VLAN_VID	GENMASK(11, 0)
 
+#define NFP_FLOWER_MASK_MPLS_LB		GENMASK(31, 12)
+#define NFP_FLOWER_MASK_MPLS_TC		GENMASK(11, 9)
+#define NFP_FLOWER_MASK_MPLS_BOS	BIT(8)
+#define NFP_FLOWER_MASK_MPLS_Q		BIT(0)
+
 #define NFP_FL_SC_ACT_DROP		0x80000000
 #define NFP_FL_SC_ACT_USER		0x7D000000
 #define NFP_FL_SC_ACT_POPV		0x6A000000
diff --git a/drivers/net/ethernet/netronome/nfp/flower/match.c b/drivers/net/ethernet/netronome/nfp/flower/match.c
index 865a815ab92a..e35ade9cd3d5 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/match.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/match.c
@@ -111,8 +111,21 @@ nfp_flower_compile_mac(struct nfp_flower_mac_mpls *frame,
 		ether_addr_copy(frame->mac_src, &addr->src[0]);
 	}
 
-	if (mask_version)
-		frame->mpls_lse = cpu_to_be32(~0);
+	if (dissector_uses_key(flow->dissector, FLOW_DISSECTOR_KEY_MPLS)) {
+		struct flow_dissector_key_mpls *mpls;
+		u32 t_mpls;
+
+		mpls = skb_flow_dissector_target(flow->dissector,
+						 FLOW_DISSECTOR_KEY_MPLS,
+						 target);
+
+		t_mpls = FIELD_PREP(NFP_FLOWER_MASK_MPLS_LB, mpls->mpls_label) |
+			 FIELD_PREP(NFP_FLOWER_MASK_MPLS_TC, mpls->mpls_tc) |
+			 FIELD_PREP(NFP_FLOWER_MASK_MPLS_BOS, mpls->mpls_bos) |
+			 NFP_FLOWER_MASK_MPLS_Q;
+
+		frame->mpls_lse = cpu_to_be32(t_mpls);
+	}
 }
 
 static void
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 3d9537ebdea4..a721a00a2bcc 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -57,6 +57,7 @@
 	 BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) | \
 	 BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL) | \
 	 BIT(FLOW_DISSECTOR_KEY_ENC_PORTS) | \
+	 BIT(FLOW_DISSECTOR_KEY_MPLS) | \
 	 BIT(FLOW_DISSECTOR_KEY_IP))
 
 #define NFP_FLOWER_WHITELIST_TUN_DISSECTOR \
@@ -238,11 +239,6 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 		case cpu_to_be16(ETH_P_ARP):
 			return -EOPNOTSUPP;
 
-		/* Currently we do not offload MPLS. */
-		case cpu_to_be16(ETH_P_MPLS_UC):
-		case cpu_to_be16(ETH_P_MPLS_MC):
-			return -EOPNOTSUPP;
-
 		/* Will be included in layer 2. */
 		case cpu_to_be16(ETH_P_8021Q):
 			break;
-- 
2.1.4
