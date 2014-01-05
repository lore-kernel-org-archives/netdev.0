From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net 3/5] bnx2x: Clean before update RSS arrives
Date: Sun, 5 Jan 2014 18:33:52 +0200
Message-ID: <1388939634-19948-4-git-send-email-yuvalmin@broadcom.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Michal Kalderon <michals@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:38815 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbaAEQeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 11:34:03 -0500
In-Reply-To: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <michals@broadcom.com>

When a PF receives a VF message indicating a change in RSS properties
it should clean the flags' bit-fields; Otherwise, it's possible that
some random values will be considered as flags by the lower layers configuring
the RSS in FW.

Signed-off-by: Michal Kalderon <michals@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   | 5 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 32c92ab..95feada 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4382,8 +4382,11 @@ int bnx2x_config_rss(struct bnx2x *bp,
 	struct bnx2x_raw_obj *r = &o->raw;
 
 	/* Do nothing if only driver cleanup was requested */
-	if (test_bit(RAMROD_DRV_CLR_ONLY, &p->ramrod_flags))
+	if (test_bit(RAMROD_DRV_CLR_ONLY, &p->ramrod_flags)) {
+		DP(BNX2X_MSG_SP, "Not configuring RSS ramrod_flags=%lx\n",
+		   p->ramrod_flags);
 		return 0;
+	}
 
 	r->set_pending(r);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 3dc2537..26fcba2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1805,6 +1805,9 @@ static void bnx2x_vf_mbx_update_rss(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	vf_op_params->rss_result_mask = rss_tlv->rss_result_mask;
 
 	/* flags handled individually for backward/forward compatability */
+	vf_op_params->rss_flags = 0;
+	vf_op_params->ramrod_flags = 0;
+
 	if (rss_tlv->rss_flags & VFPF_RSS_MODE_DISABLED)
 		__set_bit(BNX2X_RSS_MODE_DISABLED, &vf_op_params->rss_flags);
 	if (rss_tlv->rss_flags & VFPF_RSS_MODE_REGULAR)
-- 
1.8.1.227.g44fe835
