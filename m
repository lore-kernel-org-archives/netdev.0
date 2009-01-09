From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 06/16] dma-debug: add kernel command line parameters
Date: Fri, 9 Jan 2009 17:19:20 +0100
Message-ID: <1231517970-20288-7-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:45975 "EHLO
	SG2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbZAIQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:46 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add dma_debug= and dma_debug_entries= kernel parameters

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 Documentation/kernel-parameters.txt |   10 +++++++++
 lib/dma-debug.c                     |   38 +++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index fb84902..4045f76 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -486,6 +486,16 @@ and is between 256 and 4096 characters. It is defined in the file
 			Range: 0 - 8192
 			Default: 64
 
+	dma_debug=off	If the kernel is compiled with DMA_API_DEBUG support
+			this option disables the debugging code at boot.
+
+	dma_debug_entries=<number>
+			This option allows to tune the number of preallocated
+			entries for DMA-API debugging code. One entry is
+			required per DMA-API allocation. Use this if the
+			DMA-API debugging code disables itself because the
+			architectural default is too low.
+
 	hpet=		[X86-32,HPET] option to control HPET usage
 			Format: { enable (default) | disable | force }
 			disable: disable HPET and use PIT instead
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index b932f15..4e58d09 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -61,6 +61,9 @@ static bool global_disable __read_mostly;
 static u32 num_free_entries;
 static u32 min_free_entries;
 
+/* number of preallocated entries requested by kernel cmdline */
+static u32 req_entries;
+
 /*
  * Hash related functions
  *
@@ -250,6 +253,9 @@ void dma_debug_init(u32 num_entries)
 		dma_entry_hash[i].lock = SPIN_LOCK_UNLOCKED;
 	}
 
+	if (req_entries)
+		num_entries = req_entries;
+
 	if (prealloc_memory(num_entries) != 0) {
 		printk(KERN_ERR "DMA-API: debugging out of memory error "
 				"- disabled\n");
@@ -261,3 +267,35 @@ void dma_debug_init(u32 num_entries)
 	printk(KERN_INFO "DMA-API: debugging enabled by kernel config\n");
 }
 
+static __init int dma_debug_cmdline(char *str)
+{
+	if (!str)
+		return -EINVAL;
+
+	if (strncmp(str, "off", 3) == 0) {
+		printk(KERN_INFO "DMA-API: debugging disabled on kernel "
+				 "command line\n");
+		global_disable = true;
+	}
+
+	return 0;
+}
+
+static __init int dma_debug_entries_cmdline(char *str)
+{
+	int res;
+
+	if (!str)
+		return -EINVAL;
+
+	res = get_option(&str, &req_entries);
+
+	if (!res)
+		req_entries = 0;
+
+	return 0;
+}
+
+__setup("dma_debug=", dma_debug_cmdline);
+__setup("dma_debug_entries=", dma_debug_entries_cmdline);
+
-- 
1.5.6.4


