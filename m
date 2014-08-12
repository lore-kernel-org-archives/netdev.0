From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net 2/2] xen-netback: fix debugfs entry creation
Date: Tue, 12 Aug 2014 11:59:30 +0100
Message-ID: <1407841170-20916-3-git-send-email-wei.liu2@citrix.com>
References: <1407841170-20916-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42370 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbaHLK7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 06:59:32 -0400
In-Reply-To: <1407841170-20916-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code is bogus. The function gets called in a loop which
leaks entries created in previous rounds.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/xenbus.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 4c9041e..9c47b89 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -174,10 +174,9 @@ static const struct file_operations xenvif_dbg_io_ring_ops_fops = {
 	.write = xenvif_write_io_ring,
 };
 
-static void xenvif_debugfs_addif(struct xenvif_queue *queue)
+static void xenvif_debugfs_addif(struct xenvif *vif)
 {
 	struct dentry *pfile;
-	struct xenvif *vif = queue->vif;
 	int i;
 
 	if (IS_ERR_OR_NULL(xen_netback_dbg_root))
@@ -736,10 +735,11 @@ static void connect(struct backend_info *be)
 			be->vif->num_queues = queue_index;
 			goto err;
 		}
+	}
+
 #ifdef CONFIG_DEBUG_FS
-		xenvif_debugfs_addif(queue);
+	xenvif_debugfs_addif(be->vif);
 #endif /* CONFIG_DEBUG_FS */
-	}
 
 	/* Initialisation completed, tell core driver the number of
 	 * active queues.
-- 
1.7.10.4
