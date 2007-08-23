From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 13/11] cxgb3 -  Set the CQ_ERR bit in CQ contexts.
Date: Wed, 22 Aug 2007 23:38:03 -0700
Message-ID: <20070823063803.30204.97658.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:13571 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758250AbXHWGiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 02:38:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The cxgb3 driver is incorrectly configuring the HW CQ context for CQ's
that use overflow-avoidance.  Namely the RDMA control CQ.  This results
in a bad DMA from the device to bus address 0.  The solution is to set
the CQ_ERR bit in the context for these types of CQs.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge_defs.h |    4 ++++
 drivers/net/cxgb3/t3_hw.c    |    3 ++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/sge_defs.h b/drivers/net/cxgb3/sge_defs.h
index 514869e..29b6c80 100644
--- a/drivers/net/cxgb3/sge_defs.h
+++ b/drivers/net/cxgb3/sge_defs.h
@@ -106,6 +106,10 @@
 #define V_CQ_GEN(x) ((x) << S_CQ_GEN)
 #define F_CQ_GEN    V_CQ_GEN(1U)
 
+#define S_CQ_ERR    30
+#define V_CQ_ERR(x) ((x) << S_CQ_ERR)
+#define F_CQ_ERR    V_CQ_ERR(1U)
+
 #define S_CQ_OVERFLOW_MODE    31
 #define V_CQ_OVERFLOW_MODE(x) ((x) << S_CQ_OVERFLOW_MODE)
 #define F_CQ_OVERFLOW_MODE    V_CQ_OVERFLOW_MODE(1U)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 538b254..9358959 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -2043,7 +2043,8 @@ int t3_sge_init_cqcntxt(struct adapter *adapter, unsigned int id, u64 base_addr,
 	base_addr >>= 32;
 	t3_write_reg(adapter, A_SG_CONTEXT_DATA2,
 		     V_CQ_BASE_HI((u32) base_addr) | V_CQ_RSPQ(rspq) |
-		     V_CQ_GEN(1) | V_CQ_OVERFLOW_MODE(ovfl_mode));
+		     V_CQ_GEN(1) | V_CQ_OVERFLOW_MODE(ovfl_mode) |
+		     V_CQ_ERR(ovfl_mode));
 	t3_write_reg(adapter, A_SG_CONTEXT_DATA3, V_CQ_CREDITS(credits) |
 		     V_CQ_CREDIT_THRES(credit_thres));
 	return t3_sge_write_context(adapter, id, F_CQ);
