From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Subject: [PATCH net 3/3] nfp: remove incorrect mask check for vlan matching
Date: Fri, 25 Aug 2017 19:31:03 +0200
Message-ID: <1503682263-17858-4-git-send-email-pieter.jansenvanvuuren@netronome.com>
References: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        simon.horman@netronome.com, jakub.kicinski@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:33839 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757334AbdHYRbP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 13:31:15 -0400
Received: by mail-wr0-f180.google.com with SMTP id z91so1354082wrc.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 10:31:15 -0700 (PDT)
In-Reply-To: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously the vlan tci field was incorrectly exact matched. This patch
fixes this by using the flow dissector to populate the vlan tci field.

Fixes: 5571e8c9f241 ("nfp: extend flower matching capabilities")
Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/match.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/match.c b/drivers/net/ethernet/netronome/nfp/flower/match.c
index b365110..d25b503 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/match.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/match.c
@@ -42,6 +42,7 @@ nfp_flower_compile_meta_tci(struct nfp_flower_meta_two *frame,
 			    struct tc_cls_flower_offload *flow, u8 key_type,
 			    bool mask_version)
 {
+	struct fl_flow_key *target = mask_version ? flow->mask : flow->key;
 	struct flow_dissector_key_vlan *flow_vlan;
 	u16 tmp_tci;
 
@@ -50,15 +51,10 @@ nfp_flower_compile_meta_tci(struct nfp_flower_meta_two *frame,
 	frame->nfp_flow_key_layer = key_type;
 	frame->mask_id = ~0;
 
-	if (mask_version) {
-		frame->tci = cpu_to_be16(~0);
-		return;
-	}
-
 	if (dissector_uses_key(flow->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
 		flow_vlan = skb_flow_dissector_target(flow->dissector,
 						      FLOW_DISSECTOR_KEY_VLAN,
-						      flow->key);
+						      target);
 		/* Populate the tci field. */
 		if (flow_vlan->vlan_id) {
 			tmp_tci = FIELD_PREP(NFP_FLOWER_MASK_VLAN_PRIO,
-- 
2.7.4
