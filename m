From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 2/4] cxgb4: For T4, don't read the Firmware Mailbox Control register
Date: Thu,  1 Oct 2015 13:48:46 +0530
Message-ID: <1443687528-25836-3-git-send-email-hariprasad@chelsio.com>
References: <1443687528-25836-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30607 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752403AbbJAISH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 04:18:07 -0400
In-Reply-To: <1443687528-25836-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T4 doesn't have the Shadow copy of the register which we can read without
side effect. So don't read mbox control register for T4 adapter

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0a87a32..b4ace19 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1128,18 +1128,26 @@ static const struct file_operations devlog_fops = {
 static int mbox_show(struct seq_file *seq, void *v)
 {
 	static const char * const owner[] = { "none", "FW", "driver",
-					      "unknown" };
+					      "unknown", "<unread>" };
 
 	int i;
 	unsigned int mbox = (uintptr_t)seq->private & 7;
 	struct adapter *adap = seq->private - mbox;
 	void __iomem *addr = adap->regs + PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
-	unsigned int ctrl_reg = (is_t4(adap->params.chip)
-				 ? CIM_PF_MAILBOX_CTRL_A
-				 : CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A);
-	void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
 
-	i = MBOWNER_G(readl(ctrl));
+	/* For T4 we don't have a shadow copy of the Mailbox Control register.
+	 * And since reading that real register causes a side effect of
+	 * granting ownership, we're best of simply not reading it at all.
+	 */
+	if (is_t4(adap->params.chip)) {
+		i = 4; /* index of "<unread>" */
+	} else {
+		unsigned int ctrl_reg = CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A;
+		void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
+
+		i = MBOWNER_G(readl(ctrl));
+	}
+
 	seq_printf(seq, "mailbox owned by %s\n\n", owner[i]);
 
 	for (i = 0; i < MBOX_LEN; i += 8)
-- 
2.3.4
