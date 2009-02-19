From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 3/7] fcoe: check offload features from LLD through netdev
Date: Thu, 19 Feb 2009 12:49:57 -0700
Message-ID: <20090219194957.22270.6428.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28180 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632AbZBSU5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 15:57:06 -0500
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This checkes if net_devices supports net_fcoe_ops, if it does, then sets up
the corresponding flags in the associated fc_lport.

Note that large sequence offload is already supported in the current
libfc/fcoe, only thing needed is to tell the corresponding fc_lport that LLD
is capabale of doing so by using fcoe_ops->features.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/fcoe_sw.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe_sw.c b/drivers/scsi/fcoe/fcoe_sw.c
index fe1bcaa..7632d7e 100644
--- a/drivers/scsi/fcoe/fcoe_sw.c
+++ b/drivers/scsi/fcoe/fcoe_sw.c
@@ -188,6 +188,33 @@ static int fcoe_sw_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	if (fc->real_dev->features & NETIF_F_SG)
 		lp->sg_supp = 1;
 
+	lp->crc_offload = 0;
+	lp->seq_offload = 0;
+	lp->lro_enabled = 0;
+	if (netdev->fcoe_ops) {
+		struct net_fcoe_ops *fops = netdev->fcoe_ops;
+
+		if (fops->features & NET_FCOE_CRC) {
+			lp->crc_offload = 1;
+			FCOE_DBG("%s supports FCoE FCCRC offload\n",
+				 netdev->name);
+		}
+
+		if (fops->features & NET_FCOE_LSO) {
+			lp->seq_offload = 1;
+			FCOE_DBG("%s supports FCoE large send offload\n",
+				 netdev->name);
+		}
+
+		if ((fops->features & NET_FCOE_LRO) &&
+		    (fops->lro_xid)) {
+			lp->lro_enabled = 1;
+			lp->lro_xid = fops->lro_xid;
+			FCOE_DBG("%s supports FCoE large receive offload "
+				 "with max read exchange id for ddp %d\n",
+				 netdev->name, lp->lro_xid);
+		}
+	}
 
 	skb_queue_head_init(&fc->fcoe_pending_queue);
 

