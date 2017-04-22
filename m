From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/5] bnxt_en: Fix VF attributes reporting.
Date: Fri, 21 Apr 2017 20:11:23 -0400
Message-ID: <1492819886-19625-3-git-send-email-michael.chan@broadcom.com>
References: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:34070 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162703AbdDVALk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:11:40 -0400
Received: by mail-wr0-f174.google.com with SMTP id z109so62846596wrb.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:11:39 -0700 (PDT)
In-Reply-To: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The .ndo_get_vf_config() is returning the wrong qos attribute.  Fix
the code that checks and reports the qos and spoofchk attributes.  The
BNXT_VF_QOS and BNXT_VF_LINK_UP flags should not be set by default
during init. time.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index f893531..b8e7248 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -138,8 +138,11 @@ int bnxt_get_vf_config(struct net_device *dev, int vf_id,
 	ivi->max_tx_rate = vf->max_tx_rate;
 	ivi->min_tx_rate = vf->min_tx_rate;
 	ivi->vlan = vf->vlan;
-	ivi->qos = vf->flags & BNXT_VF_QOS;
-	ivi->spoofchk = vf->flags & BNXT_VF_SPOOFCHK;
+	if (vf->flags & BNXT_VF_QOS)
+		ivi->qos = vf->vlan >> VLAN_PRIO_SHIFT;
+	else
+		ivi->qos = 0;
+	ivi->spoofchk = !!(vf->flags & BNXT_VF_SPOOFCHK);
 	if (!(vf->flags & BNXT_VF_LINK_FORCED))
 		ivi->linkstate = IFLA_VF_LINK_STATE_AUTO;
 	else if (vf->flags & BNXT_VF_LINK_UP)
@@ -304,7 +307,6 @@ static int bnxt_set_vf_attr(struct bnxt *bp, int num_vfs)
 	for (i = 0; i < num_vfs; i++) {
 		vf = &bp->pf.vf[i];
 		memset(vf, 0, sizeof(*vf));
-		vf->flags = BNXT_VF_QOS | BNXT_VF_LINK_UP;
 	}
 	return 0;
 }
-- 
1.8.3.1
