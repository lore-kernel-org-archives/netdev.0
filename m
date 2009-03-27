From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 2/5] cxgb3: sge setup fixes
Date: Thu, 26 Mar 2009 19:39:14 -0700
Message-ID: <20090327023914.32137.29655.stgit@speedy5>
References: <20090327023909.32137.93884.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31288 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755724AbZC0CjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:17 -0400
In-Reply-To: <20090327023909.32137.93884.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Enable timestamps, update delayed ack threshold for iSCSI/iWARP traffic
Remove the len flag in Tx requests. It might corrupt offload trace packets.
Update SGE context setup to avoid potential H/W misprogrammation.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c   |    2 +-
 drivers/net/cxgb3/t3_hw.c |   45 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index fcd1a4f..54667f0 100755
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1089,7 +1089,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 	struct tx_desc *d = &q->desc[pidx];
 	struct cpl_tx_pkt *cpl = (struct cpl_tx_pkt *)d;
 
-	cpl->len = htonl(skb->len | 0x80000000);
+	cpl->len = htonl(skb->len);
 	cntrl = V_TXPKT_INTF(pi->port_id);
 
 	if (vlan_tx_tag_present(skb) && pi->vlan_grp)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
old mode 100644
new mode 100755
index ff262a0..7d8fbae
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -2128,16 +2128,40 @@ void t3_port_intr_clear(struct adapter *adapter, int idx)
 static int t3_sge_write_context(struct adapter *adapter, unsigned int id,
 				unsigned int type)
 {
-	t3_write_reg(adapter, A_SG_CONTEXT_MASK0, 0xffffffff);
-	t3_write_reg(adapter, A_SG_CONTEXT_MASK1, 0xffffffff);
-	t3_write_reg(adapter, A_SG_CONTEXT_MASK2, 0xffffffff);
-	t3_write_reg(adapter, A_SG_CONTEXT_MASK3, 0xffffffff);
+	if (type == F_RESPONSEQ) {
+		/*
+		 * Can't write the Response Queue Context bits for
+		 * Interrupt Armed or the Reserve bits after the chip
+		 * has been initialized out of reset.  Writing to these
+		 * bits can confuse the hardware.
+		 */
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK0, 0xffffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK1, 0xffffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK2, 0x17ffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK3, 0xffffffff);
+	} else {
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK0, 0xffffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK1, 0xffffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK2, 0xffffffff);
+		t3_write_reg(adapter, A_SG_CONTEXT_MASK3, 0xffffffff);
+	}
 	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
 		     V_CONTEXT_CMD_OPCODE(1) | type | V_CONTEXT(id));
 	return t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
 			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
+/**
+ *	clear_sge_ctxt - completely clear an SGE context
+ *	@adapter: the adapter
+ *	@id: the context id
+ *	@type: the context type
+ *
+ *	Completely clear an SGE context.  Used predominantly at post-reset
+ *	initialization.  Note in particular that we don't skip writing to any
+ *	"sensitive bits" in the contexts the way that t3_sge_write_context()
+ *	does ...
+ */
 static int clear_sge_ctxt(struct adapter *adap, unsigned int id,
 			  unsigned int type)
 {
@@ -2145,7 +2169,14 @@ static int clear_sge_ctxt(struct adapter *adap, unsigned int id,
 	t3_write_reg(adap, A_SG_CONTEXT_DATA1, 0);
 	t3_write_reg(adap, A_SG_CONTEXT_DATA2, 0);
 	t3_write_reg(adap, A_SG_CONTEXT_DATA3, 0);
-	return t3_sge_write_context(adap, id, type);
+	t3_write_reg(adap, A_SG_CONTEXT_MASK0, 0xffffffff);
+	t3_write_reg(adap, A_SG_CONTEXT_MASK1, 0xffffffff);
+	t3_write_reg(adap, A_SG_CONTEXT_MASK2, 0xffffffff);
+	t3_write_reg(adap, A_SG_CONTEXT_MASK3, 0xffffffff);
+	t3_write_reg(adap, A_SG_CONTEXT_CMD,
+		     V_CONTEXT_CMD_OPCODE(1) | type | V_CONTEXT(id));
+	return t3_wait_op_done(adap, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY,
+			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
 /**
@@ -2729,10 +2760,10 @@ static void tp_config(struct adapter *adap, const struct tp_params *p)
 		     F_TCPCHECKSUMOFFLOAD | V_IPTTL(64));
 	t3_write_reg(adap, A_TP_TCP_OPTIONS, V_MTUDEFAULT(576) |
 		     F_MTUENABLE | V_WINDOWSCALEMODE(1) |
-		     V_TIMESTAMPSMODE(0) | V_SACKMODE(1) | V_SACKRX(1));
+		     V_TIMESTAMPSMODE(1) | V_SACKMODE(1) | V_SACKRX(1));
 	t3_write_reg(adap, A_TP_DACK_CONFIG, V_AUTOSTATE3(1) |
 		     V_AUTOSTATE2(1) | V_AUTOSTATE1(0) |
-		     V_BYTETHRESHOLD(16384) | V_MSSTHRESHOLD(2) |
+		     V_BYTETHRESHOLD(26880) | V_MSSTHRESHOLD(2) |
 		     F_AUTOCAREFUL | F_AUTOENABLE | V_DACK_MODE(1));
 	t3_set_reg_field(adap, A_TP_IN_CONFIG, F_RXFBARBPRIO | F_TXFBARBPRIO,
 			 F_IPV6ENABLE | F_NICMODE);

