From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/22] drm/i915: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:18 -0600
Message-ID: <1492121135-4437-6-git-send-email-logang@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
 Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Ross Zwisler <ross.zwisler-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org, devel@driverd
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <1492121135-4437-1-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is a single straightforward conversion from kmap to sg_map.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/gpu/drm/i915/i915_gem.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 67b1fc5..1b1b91a 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2188,6 +2188,15 @@ static void __i915_gem_object_reset_page_iter(struct drm_i915_gem_object *obj)
 		radix_tree_delete(&obj->mm.get_page.radix, iter.index);
 }
 
+static void i915_gem_object_unmap(const struct drm_i915_gem_object *obj,
+				  void *ptr)
+{
+	if (is_vmalloc_addr(ptr))
+		vunmap(ptr);
+	else
+		sg_unmap(obj->mm.pages->sgl, ptr, SG_KMAP);
+}
+
 void __i915_gem_object_put_pages(struct drm_i915_gem_object *obj,
 				 enum i915_mm_subclass subclass)
 {
@@ -2215,10 +2224,7 @@ void __i915_gem_object_put_pages(struct drm_i915_gem_object *obj,
 		void *ptr;
 
 		ptr = ptr_mask_bits(obj->mm.mapping);
-		if (is_vmalloc_addr(ptr))
-			vunmap(ptr);
-		else
-			kunmap(kmap_to_page(ptr));
+		i915_gem_object_unmap(obj, ptr);
 
 		obj->mm.mapping = NULL;
 	}
@@ -2475,8 +2481,11 @@ static void *i915_gem_object_map(const struct drm_i915_gem_object *obj,
 	void *addr;
 
 	/* A single page can always be kmapped */
-	if (n_pages == 1 && type == I915_MAP_WB)
-		return kmap(sg_page(sgt->sgl));
+	if (n_pages == 1 && type == I915_MAP_WB) {
+		addr = sg_map(sgt->sgl, SG_KMAP);
+		if (IS_ERR(addr))
+			return NULL;
+	}
 
 	if (n_pages > ARRAY_SIZE(stack_pages)) {
 		/* Too big for stack -- allocate temporary array instead */
@@ -2543,11 +2552,7 @@ void *i915_gem_object_pin_map(struct drm_i915_gem_object *obj,
 			goto err_unpin;
 		}
 
-		if (is_vmalloc_addr(ptr))
-			vunmap(ptr);
-		else
-			kunmap(kmap_to_page(ptr));
-
+		i915_gem_object_unmap(obj, ptr);
 		ptr = obj->mm.mapping = NULL;
 	}
 
-- 
2.1.4
