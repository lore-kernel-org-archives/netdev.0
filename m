From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/15] nfp: document expected locking in the core
Date: Tue, 21 Mar 2017 17:59:11 -0700
Message-ID: <20170322005921.10965-6-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33528 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758584AbdCVBIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:42 -0400
Received: by mail-pg0-f44.google.com with SMTP id n190so101338711pga.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:40 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document which fields of nfp_cpp are protected by which locks.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 33 ++++++++++++++++++----
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 62aa7bcee93d..4e08362d8c97 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -65,28 +65,49 @@ struct nfp_cpp_resource {
 	u64 end;
 };
 
+/**
+ * struct nfp_cpp - main nfpcore device structure
+ * Following fields are read-only after probe() exits or netdevs are spawned.
+ * @dev:		embedded device structure
+ * @op:			low-level implementation ops
+ * @priv:		private data of the low-level implementation
+ * @model:		chip model
+ * @interface:		chip interface id we are using to reach it
+ * @serial:		chip serial number
+ * @imb_cat_table:	CPP Mapping Table
+ *
+ * Following fields can be used only in probe() or with rtnl held:
+ * @hwinfo:		HWInfo database fetched from the device
+ * @rtsym:		firmware run time symbols
+ *
+ * Following fields use explicit locking:
+ * @resource_list:	NFP CPP resource list
+ * @resource_lock:	protects @resource_list
+ *
+ * @area_cache_list:	cached areas for cpp/xpb read/write speed up
+ * @area_cache_mutex:	protects @area_cache_list
+ *
+ * @waitq:		area wait queue
+ */
 struct nfp_cpp {
 	struct device dev;
 
-	void *priv; /* Private data of the low-level implementation */
+	void *priv;
 
 	u32 model;
 	u16 interface;
 	u8 serial[NFP_SERIAL_LEN];
 
 	const struct nfp_cpp_operations *op;
-	struct list_head resource_list;	/* NFP CPP resource list */
+	struct list_head resource_list;
 	rwlock_t resource_lock;
 	wait_queue_head_t waitq;
 
-	/* NFP6000 CPP Mapping Table */
 	u32 imb_cat_table[16];
 
-	/* Cached areas for cpp/xpb readl/writel speedups */
-	struct mutex area_cache_mutex;  /* Lock for the area cache */
+	struct mutex area_cache_mutex;
 	struct list_head area_cache_list;
 
-	/* Cached information */
 	void *hwinfo;
 	void *rtsym;
 };
-- 
2.11.0
