From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 8/8] percpu: add __percpu sparse annotations to what's left
Date: Tue, 26 Jan 2010 00:22:15 +0900
Message-ID: <1264432935-10453-9-git-send-email-tj__9905.536103952$1264432895$gmane$org@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42975 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855Ab0AYPTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:10 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to places which didn't make it in one
of the previous patches.  All converions are trivial.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <borislav.petkov@amd.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Len Brown <lenb@kernel.org>
Cc: Neil Brown <neilb@suse.de>
---
 crypto/cryptd.c                  |    2 +-
 drivers/acpi/processor_perflib.c |    2 +-
 drivers/dma/dmaengine.c          |    2 +-
 drivers/edac/amd64_edac.c        |    2 +-
 drivers/md/raid5.c               |    2 +-
 drivers/md/raid5.h               |    2 +-
 include/acpi/processor.h         |    2 +-
 include/linux/dmaengine.h        |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index 704c141..ef71318 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -31,7 +31,7 @@ struct cryptd_cpu_queue {
 };
 
 struct cryptd_queue {
-	struct cryptd_cpu_queue *cpu_queue;
+	struct cryptd_cpu_queue __percpu *cpu_queue;
 };
 
 struct cryptd_instance_ctx {
diff --git a/drivers/acpi/processor_perflib.c b/drivers/acpi/processor_perflib.c
index 2cabadc..8c6a649 100644
--- a/drivers/acpi/processor_perflib.c
+++ b/drivers/acpi/processor_perflib.c
@@ -557,7 +557,7 @@ end:
 }
 
 int acpi_processor_preregister_performance(
-		struct acpi_processor_performance *performance)
+		struct acpi_processor_performance __percpu *performance)
 {
 	int count, count_target;
 	int retval = 0;
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 6f51a0a..4eadd98 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -284,7 +284,7 @@ struct dma_chan_tbl_ent {
 /**
  * channel_table - percpu lookup table for memory-to-memory offload providers
  */
-static struct dma_chan_tbl_ent *channel_table[DMA_TX_TYPE_END];
+static struct dma_chan_tbl_ent __percpu *channel_table[DMA_TX_TYPE_END];
 
 static int __init dma_channel_table_init(void)
 {
diff --git a/drivers/edac/amd64_edac.c b/drivers/edac/amd64_edac.c
index 000dc67..7b36c88 100644
--- a/drivers/edac/amd64_edac.c
+++ b/drivers/edac/amd64_edac.c
@@ -13,7 +13,7 @@ module_param(report_gart_errors, int, 0644);
 static int ecc_enable_override;
 module_param(ecc_enable_override, int, 0644);
 
-static struct msr *msrs;
+static struct msr __percpu *msrs;
 
 /* Lookup table for all possible MC control instances */
 struct amd64_pvt;
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index e84204e..77cb3ab 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -4680,7 +4680,7 @@ static int raid5_alloc_percpu(raid5_conf_t *conf)
 {
 	unsigned long cpu;
 	struct page *spare_page;
-	struct raid5_percpu *allcpus;
+	struct raid5_percpu __percpu *allcpus;
 	void *scribble;
 	int err;
 
diff --git a/drivers/md/raid5.h b/drivers/md/raid5.h
index dd70835..0f86f5e 100644
--- a/drivers/md/raid5.h
+++ b/drivers/md/raid5.h
@@ -405,7 +405,7 @@ struct raid5_private_data {
 					      * lists and performing address
 					      * conversions
 					      */
-	} *percpu;
+	} __percpu *percpu;
 	size_t			scribble_len; /* size of scribble region must be
 					       * associated with conf to handle
 					       * cpu hotplug while reshaping
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 0ea5ef4..477544f 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -238,7 +238,7 @@ struct acpi_processor_errata {
 
 extern int acpi_processor_preregister_performance(struct
 						  acpi_processor_performance
-						  *performance);
+						  __percpu *performance);
 
 extern int acpi_processor_register_performance(struct acpi_processor_performance
 					       *performance, unsigned int cpu);
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 7878498..21fd9b7 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -162,7 +162,7 @@ struct dma_chan {
 	struct dma_chan_dev *dev;
 
 	struct list_head device_node;
-	struct dma_chan_percpu *local;
+	struct dma_chan_percpu __percpu *local;
 	int client_count;
 	int table_count;
 	void *private;
-- 
1.6.4.2

