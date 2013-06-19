From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH] treewide: Add __GFP_NOWARN to k.alloc calls with
 v.alloc fallbacks
Date: Wed, 19 Jun 2013 12:15:53 -0700
Message-ID: <1371669353.2038.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Lars Ellenberg <drbd-dev@lists.linbit.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Chris Mason <chris.mason@fusionio.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	cluster-devel <cluster-devel@redhat.com>
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't emit OOM warnings when k.alloc calls fail when
there there is a v.alloc immediately afterwards.

Converted a kmalloc/vmalloc with memset to kzalloc/vzalloc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/block/drbd/drbd_bitmap.c                   | 2 +-
 drivers/infiniband/hw/ehca/ipz_pt_fn.c             | 3 ++-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 2 +-
 drivers/scsi/cxgbi/libcxgbi.h                      | 8 ++++----
 fs/btrfs/send.c                                    | 2 +-
 fs/ext4/super.c                                    | 4 ++--
 fs/gfs2/dir.c                                      | 2 +-
 net/sched/sch_choke.c                              | 3 ++-
 9 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 64fbb83..b12c11e 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -393,7 +393,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 	 * we must not block on IO to ourselves.
 	 * Context is receiver thread or dmsetup. */
 	bytes = sizeof(struct page *)*want;
-	new_pages = kzalloc(bytes, GFP_NOIO);
+	new_pages = kzalloc(bytes, GFP_NOIO | __GFP_NOWARN);
 	if (!new_pages) {
 		new_pages = __vmalloc(bytes,
 				GFP_NOIO | __GFP_HIGHMEM | __GFP_ZERO,
diff --git a/drivers/infiniband/hw/ehca/ipz_pt_fn.c b/drivers/infiniband/hw/ehca/ipz_pt_fn.c
index 62c71fa..8d59451 100644
--- a/drivers/infiniband/hw/ehca/ipz_pt_fn.c
+++ b/drivers/infiniband/hw/ehca/ipz_pt_fn.c
@@ -222,7 +222,8 @@ int ipz_queue_ctor(struct ehca_pd *pd, struct ipz_queue *queue,
 	queue->small_page = NULL;
 
 	/* allocate queue page pointers */
-	queue->queue_pages = kzalloc(nr_of_pages * sizeof(void *), GFP_KERNEL);
+	queue->queue_pages = kzalloc(nr_of_pages * sizeof(void *),
+				     GFP_KERNEL | __GFP_NOWARN);
 	if (!queue->queue_pages) {
 		queue->queue_pages = vzalloc(nr_of_pages * sizeof(void *));
 		if (!queue->queue_pages) {
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 4058b85..76ae0999 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1157,7 +1157,7 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new,
  */
 void *cxgb_alloc_mem(unsigned long size)
 {
-	void *p = kzalloc(size, GFP_KERNEL);
+	void *p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 
 	if (!p)
 		p = vzalloc(size);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5a3256b..5d5f268 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1133,7 +1133,7 @@ out:	release_firmware(fw);
  */
 void *t4_alloc_mem(size_t size)
 {
-	void *p = kzalloc(size, GFP_KERNEL);
+	void *p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 
 	if (!p)
 		p = vzalloc(size);
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 80fa99b..8135f04 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -658,11 +658,11 @@ static inline u32 cxgbi_tag_nonrsvd_bits(struct cxgbi_tag_format *tformat,
 static inline void *cxgbi_alloc_big_mem(unsigned int size,
 					gfp_t gfp)
 {
-	void *p = kmalloc(size, gfp);
+	void *p = kzalloc(size, gfp | __GFP_NOWARN);
+
 	if (!p)
-		p = vmalloc(size);
-	if (p)
-		memset(p, 0, size);
+		p = vzalloc(size);
+
 	return p;
 }
 
diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index ff40f1c..f7499ed 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -219,7 +219,7 @@ static int fs_path_ensure_buf(struct fs_path *p, int len)
 	len = PAGE_ALIGN(len);
 
 	if (p->buf == p->inline_buf) {
-		tmp_buf = kmalloc(len, GFP_NOFS);
+		tmp_buf = kmalloc(len, GFP_NOFS | __GFP_NOWARN);
 		if (!tmp_buf) {
 			tmp_buf = vmalloc(len);
 			if (!tmp_buf)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 85b3dd6..0f94f55 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -162,7 +162,7 @@ void *ext4_kvmalloc(size_t size, gfp_t flags)
 {
 	void *ret;
 
-	ret = kmalloc(size, flags);
+	ret = kmalloc(size, flags | __GFP_NOWARN);
 	if (!ret)
 		ret = __vmalloc(size, flags, PAGE_KERNEL);
 	return ret;
@@ -172,7 +172,7 @@ void *ext4_kvzalloc(size_t size, gfp_t flags)
 {
 	void *ret;
 
-	ret = kzalloc(size, flags);
+	ret = kzalloc(size, flags | __GFP_NOWARN);
 	if (!ret)
 		ret = __vmalloc(size, flags | __GFP_ZERO, PAGE_KERNEL);
 	return ret;
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index 147fcc5..9ba9e0c 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -1867,7 +1867,7 @@ static int leaf_dealloc(struct gfs2_inode *dip, u32 index, u32 len,
 
 	memset(&rlist, 0, sizeof(struct gfs2_rgrp_list));
 
-	ht = kzalloc(size, GFP_NOFS);
+	ht = kzalloc(size, GFP_NOFS | __GFP_NOWARN);
 	if (ht == NULL)
 		ht = vzalloc(size);
 	if (!ht)
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ef53ab8..ddd73cb 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -438,7 +438,8 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 	if (mask != q->tab_mask) {
 		struct sk_buff **ntab;
 
-		ntab = kcalloc(mask + 1, sizeof(struct sk_buff *), GFP_KERNEL);
+		ntab = kcalloc(mask + 1, sizeof(struct sk_buff *),
+			       GFP_KERNEL | __GFP_NOWARN);
 		if (!ntab)
 			ntab = vzalloc((mask + 1) * sizeof(struct sk_buff *));
 		if (!ntab)
