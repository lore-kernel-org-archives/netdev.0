From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 07/16] dma-debug: add debugfs interface
Date: Fri, 9 Jan 2009 17:19:21 +0100
Message-ID: <1231517970-20288-8-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:31931 "EHLO
	WA4EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbZAIQTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:42 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add debugfs interface for configuring DMA-API debugging

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 lib/dma-debug.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 4e58d09..ca0ccb1 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -19,6 +19,7 @@
 
 #include <linux/dma-debug.h>
 #include <linux/spinlock.h>
+#include <linux/debugfs.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -58,12 +59,29 @@ static DEFINE_SPINLOCK(free_entries_lock);
 /* Global disable flag - will be set in case of an error */
 static bool global_disable __read_mostly;
 
+/* Global error count */
+static u32 error_count;
+
+/* Global error show enable*/
+static u32 show_all_errors __read_mostly;
+/* Number of errors to show */
+static u32 show_num_errors = 1;
+
 static u32 num_free_entries;
 static u32 min_free_entries;
 
 /* number of preallocated entries requested by kernel cmdline */
 static u32 req_entries;
 
+/* debugfs dentry's for the stuff above */
+static struct dentry *dma_debug_dent;
+static struct dentry *global_disable_dent;
+static struct dentry *error_count_dent;
+static struct dentry *show_all_errors_dent;
+static struct dentry *show_num_errors_dent;
+static struct dentry *num_free_entries_dent;
+static struct dentry *min_free_entries_dent;
+
 /*
  * Hash related functions
  *
@@ -238,6 +256,58 @@ out_err:
 	return -ENOMEM;
 }
 
+static int dma_debug_fs_init(void)
+{
+	dma_debug_dent = debugfs_create_dir("dma-api", NULL);
+	if (!dma_debug_dent) {
+		printk(KERN_ERR "DMA-API: can not create debugfs directory\n");
+		return -ENOMEM;
+	}
+
+	global_disable_dent = debugfs_create_bool("disabled", 0444,
+			dma_debug_dent,
+			(u32 *)&global_disable);
+	if (!global_disable_dent)
+		goto out_err;
+
+	error_count_dent = debugfs_create_u32("error_count", 0444,
+			dma_debug_dent, &error_count);
+	if (!error_count_dent)
+		goto out_err;
+
+	show_all_errors_dent = debugfs_create_u32("all_errors", 0644,
+			dma_debug_dent,
+			&show_all_errors);
+	if (!show_all_errors_dent)
+		goto out_err;
+
+	show_num_errors_dent = debugfs_create_u32("num_errors", 0644,
+			dma_debug_dent,
+			&show_num_errors);
+	if (!show_num_errors_dent)
+		goto out_err;
+
+	num_free_entries_dent = debugfs_create_u32("num_free_entries", 0444,
+			dma_debug_dent,
+			&num_free_entries);
+	if (!num_free_entries_dent)
+		goto out_err;
+
+	min_free_entries_dent = debugfs_create_u32("min_free_entries", 0444,
+			dma_debug_dent,
+			&min_free_entries);
+	if (!min_free_entries_dent)
+		goto out_err;
+
+	return 0;
+
+out_err:
+	debugfs_remove_recursive(dma_debug_dent);
+
+	return -ENOMEM;
+}
+
+
 /*
  * Let the architectures decide how many entries should be preallocated.
  */
@@ -253,6 +323,14 @@ void dma_debug_init(u32 num_entries)
 		dma_entry_hash[i].lock = SPIN_LOCK_UNLOCKED;
 	}
 
+	if (dma_debug_fs_init() != 0) {
+		printk(KERN_ERR "DMA-API: error creating debugfs entries "
+				"- disabling\n");
+		global_disable = true;
+
+		return;
+	}
+
 	if (req_entries)
 		num_entries = req_entries;
 
-- 
1.5.6.4


