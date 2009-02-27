From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 10/11] fcoe: add support to FCoE offload support in fcoe_sw
	through net_device
Date: Fri, 27 Feb 2009 14:07:26 -0800
Message-ID: <20090227220726.4987.33461.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30173 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759147AbZB0XPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:15:03 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds implementation of ddp_setup()/ddp_done() in fcoe_sw for its
fcoe_sw_libfc_fcn_templ.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/fcoe_sw.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe_sw.c b/drivers/scsi/fcoe/fcoe_sw.c
index d99217d..2bbbe3c 100644
--- a/drivers/scsi/fcoe/fcoe_sw.c
+++ b/drivers/scsi/fcoe/fcoe_sw.c
@@ -373,8 +373,46 @@ static int fcoe_sw_destroy(struct net_device *netdev)
 	return 0;
 }
 
+/*
+ * fcoe_sw_ddp_setup - calls LLD's ddp_setup through net_device
+ * @lp:	the corresponding fc_lport
+ * @xid: the exchange id for this ddp transfer
+ * @sgl: the scatterlist describing this transfer
+ * @sgc: number of sg items
+ *
+ * Returns : 0 no ddp
+ */
+static int fcoe_sw_ddp_setup(struct fc_lport *lp, u16 xid,
+			     struct scatterlist *sgl, unsigned int sgc)
+{
+	struct net_device *n = fcoe_netdev(lp);
+
+	if (n->netdev_ops && n->netdev_ops->ndo_fcoe_ddp_setup)
+		return n->netdev_ops->ndo_fcoe_ddp_setup(n, xid, sgl, sgc);
+
+	return 0;
+}
+
+/*
+ * fcoe_sw_ddp_done - calls LLD's ddp_done through net_device
+ * @lp:	the corresponding fc_lport
+ * @xid: the exchange id for this ddp transfer
+ *
+ * Returns : the length of data that have been completed by ddp
+ */
+static int fcoe_sw_ddp_done(struct fc_lport *lp, u16 xid)
+{
+	struct net_device *n = fcoe_netdev(lp);
+
+	if (n->netdev_ops && n->netdev_ops->ndo_fcoe_ddp_done)
+		return n->netdev_ops->ndo_fcoe_ddp_done(n, xid);
+	return 0;
+}
+
 static struct libfc_function_template fcoe_sw_libfc_fcn_templ = {
 	.frame_send = fcoe_xmit,
+	.ddp_setup = fcoe_sw_ddp_setup,
+	.ddp_done = fcoe_sw_ddp_done,
 };
 
 /**

