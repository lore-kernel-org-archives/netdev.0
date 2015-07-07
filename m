From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Enable cim_la dump to support T6
Date: Tue,  7 Jul 2015 21:49:21 +0530
Message-ID: <1436285961-8674-5-git-send-email-hariprasad@chelsio.com>
References: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27923 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756886AbbGGLFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:05:39 -0400
In-Reply-To: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 54 ++++++++++++++++++++--
 1 file changed, 51 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 484eb8c..42d48dd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -151,6 +151,45 @@ static int cim_la_show_3in1(struct seq_file *seq, void *v, int idx)
 	return 0;
 }
 
+static int cim_la_show_t6(struct seq_file *seq, void *v, int idx)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Status   Inst    Data      PC     LS0Stat  "
+			 "LS0Addr  LS0Data  LS1Stat  LS1Addr  LS1Data\n");
+	} else {
+		const u32 *p = v;
+
+		seq_printf(seq, "  %02x   %04x%04x %04x%04x %04x%04x %08x %08x %08x %08x %08x %08x\n",
+			   (p[9] >> 16) & 0xff,       /* Status */
+			   p[9] & 0xffff, p[8] >> 16, /* Inst */
+			   p[8] & 0xffff, p[7] >> 16, /* Data */
+			   p[7] & 0xffff, p[6] >> 16, /* PC */
+			   p[2], p[1], p[0],      /* LS0 Stat, Addr and Data */
+			   p[5], p[4], p[3]);     /* LS1 Stat, Addr and Data */
+	}
+	return 0;
+}
+
+static int cim_la_show_pc_t6(struct seq_file *seq, void *v, int idx)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Status   Inst    Data      PC\n");
+	} else {
+		const u32 *p = v;
+
+		seq_printf(seq, "  %02x   %08x %08x %08x\n",
+			   p[3] & 0xff, p[2], p[1], p[0]);
+		seq_printf(seq, "  %02x   %02x%06x %02x%06x %02x%06x\n",
+			   (p[6] >> 8) & 0xff, p[6] & 0xff, p[5] >> 8,
+			   p[5] & 0xff, p[4] >> 8, p[4] & 0xff, p[3] >> 8);
+		seq_printf(seq, "  %02x   %04x%04x %04x%04x %04x%04x\n",
+			   (p[9] >> 16) & 0xff, p[9] & 0xffff, p[8] >> 16,
+			   p[8] & 0xffff, p[7] >> 16, p[7] & 0xffff,
+			   p[6] >> 16);
+	}
+	return 0;
+}
+
 static int cim_la_open(struct inode *inode, struct file *file)
 {
 	int ret;
@@ -162,9 +201,18 @@ static int cim_la_open(struct inode *inode, struct file *file)
 	if (ret)
 		return ret;
 
-	p = seq_open_tab(file, adap->params.cim_la_size / 8, 8 * sizeof(u32), 1,
-			 cfg & UPDBGLACAPTPCONLY_F ?
-			 cim_la_show_3in1 : cim_la_show);
+	if (is_t6(adap->params.chip)) {
+		/* +1 to account for integer division of CIMLA_SIZE/10 */
+		p = seq_open_tab(file, (adap->params.cim_la_size / 10) + 1,
+				 10 * sizeof(u32), 1,
+				 cfg & UPDBGLACAPTPCONLY_F ?
+					cim_la_show_pc_t6 : cim_la_show_t6);
+	} else {
+		p = seq_open_tab(file, adap->params.cim_la_size / 8,
+				 8 * sizeof(u32), 1,
+				 cfg & UPDBGLACAPTPCONLY_F ? cim_la_show_3in1 :
+							     cim_la_show);
+	}
 	if (!p)
 		return -ENOMEM;
 
-- 
2.3.4
