From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/8] qed: Don't close the OUT_EN during init
Date: Thu, 6 Apr 2017 15:58:31 +0300
Message-ID: <1491483515-13502-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53189 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757072AbdDFM7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:16 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before initializing the chip's engine, driver currently closes a set
of registers on the HW's ingress flow to prevent packets from slipping
in while they're not supposed to.

This configuration is insufficient, as there are some scenarios where
packets would still arrive even when said registers are set,
but the management firmware already closes other per-port registers
that do suffice, making this setting unnecessray.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index c5f4886..fb759ba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1279,18 +1279,6 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 
 	qed_cxt_hw_init_common(p_hwfn);
 
-	/* Close gate from NIG to BRB/Storm; By default they are open, but
-	 * we close them to prevent NIG from passing data to reset blocks.
-	 * Should have been done in the ENGINE phase, but init-tool lacks
-	 * proper port-pretend capabilities.
-	 */
-	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_BRB_OUT_EN, 0);
-	qed_wr(p_hwfn, p_ptt, NIG_REG_STORM_OUT_EN, 0);
-	qed_port_pretend(p_hwfn, p_ptt, p_hwfn->port_id ^ 1);
-	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_BRB_OUT_EN, 0);
-	qed_wr(p_hwfn, p_ptt, NIG_REG_STORM_OUT_EN, 0);
-	qed_port_unpretend(p_hwfn, p_ptt);
-
 	qed_init_cache_line_size(p_hwfn, p_ptt);
 
 	rc = qed_init_run(p_hwfn, p_ptt, PHASE_ENGINE, ANY_PHASE_ID, hw_mode);
-- 
1.9.3
