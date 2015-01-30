From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next] cxgb4: Remove preprocessor check for CONFIG_CXGB4_DCB
Date: Fri, 30 Jan 2015 08:49:27 +0530
Message-ID: <1422587967-18405-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5061 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752358AbbA3DN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 22:13:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit dc9daab226aa ("cxgb4: Added support in debugfs to dump
sge_qinfo") a preprocessor check for CONFIG_CXGB4_DCB got added, which should
have been CONFIG_CHELSIO_T4_DCB. After adding the right preprocessor, build
fails due to missing function ethqset2pinfo. Fixing that as well.

Reported-by: Paul Bolle <pebolle@tiscal.nl>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

V2: Updated description since the patch also fixes build failure

---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   24 +++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 47c0869..61c000a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1229,6 +1229,28 @@ static const struct file_operations rss_vf_config_debugfs_fops = {
 	.release = seq_release_private
 };
 
+/**
+ * ethqset2pinfo - return port_info of an Ethernet Queue Set
+ * @adap: the adapter
+ * @qset: Ethernet Queue Set
+ */
+static inline struct port_info *ethqset2pinfo(struct adapter *adap, int qset)
+{
+	int pidx;
+
+	for_each_port(adap, pidx) {
+		struct port_info *pi = adap2pinfo(adap, pidx);
+
+		if (qset >= pi->first_qset &&
+		    qset < pi->first_qset + pi->nqsets)
+			return pi;
+	}
+
+	/* should never happen! */
+	BUG_ON(1);
+	return NULL;
+}
+
 static int sge_qinfo_show(struct seq_file *seq, void *v)
 {
 	struct adapter *adap = seq->private;
@@ -1272,7 +1294,7 @@ do { \
 		T("TxQ inuse:", q.in_use);
 		T("TxQ CIDX:", q.cidx);
 		T("TxQ PIDX:", q.pidx);
-#ifdef CONFIG_CXGB4_DCB
+#ifdef CONFIG_CHELSIO_T4_DCB
 		T("DCB Prio:", dcb_prio);
 		S3("u", "DCB PGID:",
 		   (ethqset2pinfo(adap, base_qset + i)->dcb.pgid >>
-- 
1.7.1
