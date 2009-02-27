From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 06/11] fcoe,
	libfc: check offload features from LLD through netdev
Date: Fri, 27 Feb 2009 14:07:04 -0800
Message-ID: <20090227220704.4987.98233.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48449 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758610AbZB0XOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:14:41 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This checks if net_devices supports FCoE offload ops in netdev_ops and it
if it does, then sets up the corresponding flags in the associated fc_lport.

For large send offload, the maximum length supported in one large send is now
described by the added lso_max in fc_lport, which is setup initially from
netdev->gso_max_size.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/fcoe_sw.c |   29 ++++++++++++++++++++++++++++-
 include/scsi/libfc.h        |    1 +
 2 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe_sw.c b/drivers/scsi/fcoe/fcoe_sw.c
index da210eb..d99217d 100644
--- a/drivers/scsi/fcoe/fcoe_sw.c
+++ b/drivers/scsi/fcoe/fcoe_sw.c
@@ -133,6 +133,13 @@ static int fcoe_sw_lport_config(struct fc_lport *lp)
 	/* lport fc_lport related configuration */
 	fc_lport_config(lp);
 
+	/* offload related configuration */
+	lp->crc_offload = 0;
+	lp->seq_offload = 0;
+	lp->lro_enabled = 0;
+	lp->lro_xid = 0;
+	lp->lso_max = 0;
+
 	return 0;
 }
 
@@ -186,7 +193,27 @@ static int fcoe_sw_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	if (fc->real_dev->features & NETIF_F_SG)
 		lp->sg_supp = 1;
 
-
+#ifdef NETIF_F_FCOE_CRC
+	if (netdev->features & NETIF_F_FCOE_CRC) {
+		lp->crc_offload = 1;
+		printk(KERN_DEBUG "fcoe:%s supports FCCRC offload\n",
+		       netdev->name);
+	}
+#endif
+#ifdef NETIF_F_FSO
+	if (netdev->features & NETIF_F_FSO) {
+		lp->seq_offload = 1;
+		lp->lso_max = netdev->gso_max_size;
+		printk(KERN_DEBUG "fcoe:%s supports LSO for max len 0x%x\n",
+		       netdev->name, lp->lso_max);
+	}
+#endif
+	if (netdev->fcoe_ddp_xid) {
+		lp->lro_enabled = 1;
+		lp->lro_xid = netdev->fcoe_ddp_xid;
+		printk(KERN_DEBUG "fcoe:%s supports LRO for max xid 0x%x\n",
+		       netdev->name, lp->lro_xid);
+	}
 	skb_queue_head_init(&fc->fcoe_pending_queue);
 	fc->fcoe_pending_queue_active = 0;
 
diff --git a/include/scsi/libfc.h b/include/scsi/libfc.h
index a2e126b..61c746c 100644
--- a/include/scsi/libfc.h
+++ b/include/scsi/libfc.h
@@ -654,6 +654,7 @@ struct fc_lport {
 	u16			link_speed;
 	u16			link_supported_speeds;
 	u16			lro_xid;	/* max xid for fcoe lro */
+	unsigned int		lso_max;	/* max large send size */
 	struct fc_ns_fts	fcts;	        /* FC-4 type masks */
 	struct fc_els_rnid_gen	rnid_gen;	/* RNID information */
 

