From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 5/7 RESEND] cxgb3 - CQ context operations time out too soon.
Date: Wed, 05 Sep 2007 15:58:30 -0700
Message-ID: <20070905225830.17290.99454.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31693 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758092AbXIEW7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 18:59:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Currently, the driver only tries up to 5 times (5us) to get the results
of a CQ context operation.  Testing has shown the chip can take as much
as 50us to return the response on SG_CONTEXT_CMD operations.  So we up
the retry count to 100 to cover high loads.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index bff1d02..0583293 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1870,6 +1870,8 @@ void t3_port_intr_clear(struct adapter *adapter, int idx)
 	phy->ops->intr_clear(phy);
 }
 
+#define SG_CONTEXT_CMD_ATTEMPTS 100
+
 /**
  * 	t3_sge_write_context - write an SGE context
  * 	@adapter: the adapter
@@ -1889,7 +1891,7 @@ static int t3_sge_write_context(struct adapter *adapter, unsigned int id,
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | type | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-			       0, 5, 1);
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2075,7 +2077,7 @@ int t3_sge_enable_ecntxt(struct adapter *adapter, unsigned int id, int enable)
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | F_EGRESS | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-			       0, 5, 1);
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2099,7 +2101,7 @@ int t3_sge_disable_fl(struct adapter *adapter, unsigned int id)
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | F_FREELIST | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-			       0, 5, 1);
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2123,7 +2125,7 @@ int t3_sge_disable_rspcntxt(struct adapter *adapter, unsigned int id)
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | F_RESPONSEQ | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-			       0, 5, 1);
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2147,7 +2149,7 @@ int t3_sge_disable_cqcntxt(struct adapter *adapter, unsigned int id)
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | F_CQ | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-			       0, 5, 1);
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2172,7 +2174,7 @@ int t3_sge_cqcntxt_op(struct adapter *adapter, unsigned int id, unsigned int op,
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD, V_CONTEXT_CMD_OPCODE(op) |
 		     V_CONTEXT(id) | F_CQ);
 	if (t3_wait_op_done_val(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
-				0, 5, 1, &val))
+				0, SG_CONTEXT_CMD_ATTEMPTS, 1, &val))
 		return -EIO;
 
 	if (op >= 2 && op < 7) {
@@ -2182,7 +2184,8 @@ int t3_sge_cqcntxt_op(struct adapter *adapter, unsigned int id, unsigned int op,
 		t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 			     V_CONTEXT_CMD_OPCODE(0) | F_CQ | V_CONTEXT(id));
 		if (t3_wait_op_done(adapter, A_SG_CONTEXT_CMD,
-				    F_CONTEXT_CMD_BUSY, 0, 5, 1))
+				    F_CONTEXT_CMD_BUSY, 0,
+				    SG_CONTEXT_CMD_ATTEMPTS, 1))
 			return -EIO;
 		return G_CQ_INDEX(t3_read_reg(adapter, A_SG_CONTEXT_DATA0));
 	}
@@ -2208,7 +2211,7 @@ static int t3_sge_read_context(unsigned int type, struct adapter *adapter,
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(0) | type | V_CONTEXT(id));
 	if (t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY, 0,
-			    5, 1))
+			    SG_CONTEXT_CMD_ATTEMPTS, 1))
 		return -EIO;
 	data[0] = t3_read_reg(adapter, A_SG_CONTEXT_DATA0);
 	data[1] = t3_read_reg(adapter, A_SG_CONTEXT_DATA1);
