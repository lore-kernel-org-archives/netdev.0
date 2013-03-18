From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 2/2] dma-debug: Update DMA debug API to better handle
 multiple mappings of a buffer
Date: Mon, 18 Mar 2013 15:12:49 -0700
Message-ID: <20130318221249.7349.85892.stgit@ahduyck-cp1.jf.intel.com>
References: <20130318220241.7349.5030.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, joerg.roedel@amd.com, konrad@kernel.org,
	christoph.paasch@uclouvain.be, mingo@redhat.com,
	shuahkhan@gmail.com, hpa@zytor.com, akpm@linux-foundation.org,
	shuah.khan@hp.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17016 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532Ab3CRWOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 18:14:50 -0400
In-Reply-To: <20130318220241.7349.5030.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were reports of the igb driver unmapping buffers without calling
dma_mapping_error.  On closer inspection issues were found in the DMA debug
API and how it handled multiple mappings of the same buffer.

The issue I found is the fact that the debug_dma_mapping_error would only set
the map_err_type to MAP_ERR_CHECKED in the case that the was only one match
for device and device address.  However in the case of non-IOMMU, multiple
addresses existed and as a result it was not setting this field once a
second mapping was instantiated.  I have resolved this by changing the search
so that it instead will now set MAP_ERR_CHECKED on the first buffer that
matches the device and DMA address that is currently in the state
MAP_ERR_NOT_CHECKED.

A secondary side effect of this patch is that in the case of multiple buffers
using the same address only the last mapping will have a valid map_err_type.
The previous mappings will all end up with map_err_type set to
MAP_ERR_CHECKED because of the dma_mapping_error call in debug_dma_map_page.
However this behavior may be preferable as it means you will likely only see
one real error per multi-mapped buffer, versus the current behavior of
multiple false errors mer multi-mapped buffer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 lib/dma-debug.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 724bd4d..aa465d9 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -1082,13 +1082,27 @@ void debug_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	ref.dev = dev;
 	ref.dev_addr = dma_addr;
 	bucket = get_hash_bucket(&ref, &flags);
-	entry = bucket_find_exact(bucket, &ref);
 
-	if (!entry)
-		goto out;
+	list_for_each_entry(entry, &bucket->list, list) {
+		if (!exact_match(&ref, entry))
+			continue;
+
+		/*
+		 * The same physical address can be mapped multiple
+		 * times. Without a hardware IOMMU this results in the
+		 * same device addresses being put into the dma-debug
+		 * hash multiple times too. This can result in false
+		 * positives being reported. Therefore we implement a
+		 * best-fit algorithm here which updates the first entry
+		 * from the hash which fits the reference value and is
+		 * not currently listed as being checked.
+		 */
+		if (entry->map_err_type == MAP_ERR_NOT_CHECKED) {
+			entry->map_err_type = MAP_ERR_CHECKED;
+			break;
+		}
+	}
 
-	entry->map_err_type = MAP_ERR_CHECKED;
-out:
 	put_hash_bucket(bucket, &flags);
 }
 EXPORT_SYMBOL(debug_dma_mapping_error);
