From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net v2 1/3] nfp: add whitelist of supported flow dissector
Date: Wed, 13 Sep 2017 10:15:58 -0700
Message-ID: <20170913171600.31049-2-jakub.kicinski@netronome.com>
References: <20170913171600.31049-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:45928 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdIMRQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 13:16:52 -0400
Received: by mail-pf0-f180.google.com with SMTP id q76so1226584pfq.2
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 10:16:51 -0700 (PDT)
In-Reply-To: <20170913171600.31049-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously we did not check the flow dissector against a list of allowed
and supported flow key dissectors. This patch introduces such a list and
correctly rejects unsupported flow keys.

Fixes: 43f84b72c50d ("nfp: add metadata to each flow offload")
Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index d396183108f7..a18b4d2b1d3e 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -44,6 +44,16 @@
 #include "../nfp_net.h"
 #include "../nfp_port.h"
 
+#define NFP_FLOWER_WHITELIST_DISSECTOR \
+	(BIT(FLOW_DISSECTOR_KEY_CONTROL) | \
+	 BIT(FLOW_DISSECTOR_KEY_BASIC) | \
+	 BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) | \
+	 BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) | \
+	 BIT(FLOW_DISSECTOR_KEY_PORTS) | \
+	 BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) | \
+	 BIT(FLOW_DISSECTOR_KEY_VLAN) | \
+	 BIT(FLOW_DISSECTOR_KEY_IP))
+
 static int
 nfp_flower_xmit_flow(struct net_device *netdev,
 		     struct nfp_fl_payload *nfp_flow, u8 mtype)
@@ -112,6 +122,9 @@ nfp_flower_calculate_key_layers(struct nfp_fl_key_ls *ret_key_ls,
 	u8 key_layer;
 	int key_size;
 
+	if (flow->dissector->used_keys & ~NFP_FLOWER_WHITELIST_DISSECTOR)
+		return -EOPNOTSUPP;
+
 	if (dissector_uses_key(flow->dissector,
 			       FLOW_DISSECTOR_KEY_ENC_CONTROL)) {
 		struct flow_dissector_key_control *mask_enc_ctl =
-- 
2.14.1
