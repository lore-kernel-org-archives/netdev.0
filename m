From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] bnxt_en: Fix a VXLAN vs GENEVE issue
Date: Tue, 22 Nov 2016 06:14:40 +0100
Message-ID: <20161122051440.9748-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: davem@davemloft.net, michael.chan@broadcom.com,
        prashant.sreedharan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp07.smtpout.orange.fr ([80.12.242.129]:38213 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbcKVFOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 00:14:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Knowing that:
  #define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN        (0x1UL << 0)
  #define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE       (0x5UL << 0)
and that 'bnxt_hwrm_tunnel_dst_port_alloc()' is only called with one of
these 2 constants, the TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE can not
trigger.

Replace the bit test that overlap by an equality test, just as in
'bnxt_hwrm_tunnel_dst_port_free()' above.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
Compile-tested only
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d313b02485a1..25d9ffe51825 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3210,11 +3210,17 @@ static int bnxt_hwrm_tunnel_dst_port_alloc(struct bnxt *bp, __be16 port,
 		goto err_out;
 	}
 
-	if (tunnel_type & TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_VXLAN)
+	switch (tunnel_type) {
+	case TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_VXLAN:
 		bp->vxlan_fw_dst_port_id = resp->tunnel_dst_port_id;
-
-	else if (tunnel_type & TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE)
+		break;
+	case TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE:
 		bp->nge_fw_dst_port_id = resp->tunnel_dst_port_id;
+		break;
+	default:
+		break;
+	}
+
 err_out:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
-- 
2.9.3
