From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 04/10] RDMA/cxgb4: Add debugfs rdma memory stats
Date: Wed, 19 Oct 2011 22:40:58 +0530
Message-ID: <1319044264-779-5-git-send-email-vipul@chelsio.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1319044264-779-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/device.c   |   78 +++++++++++++++++++++++++++++++-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |   17 +++++++
 drivers/infiniband/hw/cxgb4/mem.c      |   11 ++++-
 drivers/infiniband/hw/cxgb4/provider.c |    8 +++
 drivers/infiniband/hw/cxgb4/resource.c |   44 ++++++++++++++++++
 5 files changed, 155 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 6d0df6e..8483111 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -240,6 +240,62 @@ static const struct file_operations stag_debugfs_fops = {
 	.llseek  = default_llseek,
 };
 
+static int stats_show(struct seq_file *seq, void *v)
+{
+	struct c4iw_dev *dev = seq->private;
+
+	seq_printf(seq, " Object: %10s %10s %10s\n", "Total", "Current", "Max");
+	seq_printf(seq, "     PDID: %10llu %10llu %10llu\n",
+			dev->rdev.stats.pd.total, dev->rdev.stats.pd.cur,
+			dev->rdev.stats.pd.max);
+	seq_printf(seq, "      QID: %10llu %10llu %10llu\n",
+			dev->rdev.stats.qid.total, dev->rdev.stats.qid.cur,
+			dev->rdev.stats.qid.max);
+	seq_printf(seq, "   TPTMEM: %10llu %10llu %10llu\n",
+			dev->rdev.stats.stag.total, dev->rdev.stats.stag.cur,
+			dev->rdev.stats.stag.max);
+	seq_printf(seq, "   PBLMEM: %10llu %10llu %10llu\n",
+			dev->rdev.stats.pbl.total, dev->rdev.stats.pbl.cur,
+			dev->rdev.stats.pbl.max);
+	seq_printf(seq, "   RQTMEM: %10llu %10llu %10llu\n",
+			dev->rdev.stats.rqt.total, dev->rdev.stats.rqt.cur,
+			dev->rdev.stats.rqt.max);
+	seq_printf(seq, "  OCQPMEM: %10llu %10llu %10llu\n",
+			dev->rdev.stats.ocqp.total, dev->rdev.stats.ocqp.cur,
+			dev->rdev.stats.ocqp.max);
+	return 0;
+}
+
+static int stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, stats_show, inode->i_private);
+}
+
+static ssize_t stats_clear(struct file *file, const char __user *buf,
+		size_t count, loff_t *pos)
+{
+	struct c4iw_dev *dev = ((struct seq_file *)file->private_data)->private;
+
+	mutex_lock(&dev->rdev.stats.lock);
+	dev->rdev.stats.pd.max = 0;
+	dev->rdev.stats.qid.max = 0;
+	dev->rdev.stats.stag.max = 0;
+	dev->rdev.stats.pbl.max = 0;
+	dev->rdev.stats.rqt.max = 0;
+	dev->rdev.stats.ocqp.max = 0;
+	mutex_unlock(&dev->rdev.stats.lock);
+	return count;
+}
+
+static const struct file_operations stats_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = stats_open,
+	.release = single_release,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.write   = stats_clear,
+};
+
 static int setup_debugfs(struct c4iw_dev *devp)
 {
 	struct dentry *de;
@@ -256,6 +312,12 @@ static int setup_debugfs(struct c4iw_dev *devp)
 				 (void *)devp, &stag_debugfs_fops);
 	if (de && de->d_inode)
 		de->d_inode->i_size = 4096;
+
+	de = debugfs_create_file("stats", S_IWUSR, devp->debugfs_root,
+			(void *)devp, &stats_debugfs_fops);
+	if (de && de->d_inode)
+		de->d_inode->i_size = 4096;
+
 	return 0;
 }
 
@@ -269,9 +331,13 @@ void c4iw_release_dev_ucontext(struct c4iw_rdev *rdev,
 	list_for_each_safe(pos, nxt, &uctx->qpids) {
 		entry = list_entry(pos, struct c4iw_qid_list, entry);
 		list_del_init(&entry->entry);
-		if (!(entry->qid & rdev->qpmask))
+		if (!(entry->qid & rdev->qpmask)) {
 			c4iw_put_resource(&rdev->resource.qid_fifo, entry->qid,
-					  &rdev->resource.qid_fifo_lock);
+					&rdev->resource.qid_fifo_lock);
+			mutex_lock(&rdev->stats.lock);
+			rdev->stats.qid.cur -= rdev->qpmask + 1;
+			mutex_unlock(&rdev->stats.lock);
+		}
 		kfree(entry);
 	}
 
@@ -332,6 +398,13 @@ static int c4iw_rdev_open(struct c4iw_rdev *rdev)
 		goto err1;
 	}
 
+	rdev->stats.pd.total = T4_MAX_NUM_PD;
+	rdev->stats.stag.total = rdev->lldi.vr->stag.size;
+	rdev->stats.pbl.total = rdev->lldi.vr->pbl.size;
+	rdev->stats.rqt.total = rdev->lldi.vr->rq.size;
+	rdev->stats.ocqp.total = rdev->lldi.vr->ocq.size;
+	rdev->stats.qid.total = rdev->lldi.vr->qp.size;
+
 	err = c4iw_init_resource(rdev, c4iw_num_stags(rdev), T4_MAX_NUM_PD);
 	if (err) {
 		printk(KERN_ERR MOD "error %d initializing resources\n", err);
@@ -440,6 +513,7 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 	idr_init(&devp->qpidr);
 	idr_init(&devp->mmidr);
 	spin_lock_init(&devp->lock);
+	mutex_init(&devp->rdev.stats.lock);
 
 	if (c4iw_debugfs_root) {
 		devp->debugfs_root = debugfs_create_dir(
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 62cea0e..ec7c848 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -103,6 +103,22 @@ enum c4iw_rdev_flags {
 	T4_FATAL_ERROR = (1<<0),
 };
 
+struct c4iw_stat {
+	u64 total;
+	u64 cur;
+	u64 max;
+};
+
+struct c4iw_stats {
+	struct mutex lock;
+	struct c4iw_stat qid;
+	struct c4iw_stat pd;
+	struct c4iw_stat stag;
+	struct c4iw_stat pbl;
+	struct c4iw_stat rqt;
+	struct c4iw_stat ocqp;
+};
+
 struct c4iw_rdev {
 	struct c4iw_resource resource;
 	unsigned long qpshift;
@@ -117,6 +133,7 @@ struct c4iw_rdev {
 	struct cxgb4_lld_info lldi;
 	unsigned long oc_mw_pa;
 	void __iomem *oc_mw_kva;
+	struct c4iw_stats stats;
 };
 
 static inline int c4iw_fatal_error(struct c4iw_rdev *rdev)
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 40c8353..2a87379 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -135,6 +135,11 @@ static int write_tpt_entry(struct c4iw_rdev *rdev, u32 reset_tpt_entry,
 					     &rdev->resource.tpt_fifo_lock);
 		if (!stag_idx)
 			return -ENOMEM;
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.stag.cur += 32;
+		if (rdev->stats.stag.cur > rdev->stats.stag.max)
+			rdev->stats.stag.max = rdev->stats.stag.cur;
+		mutex_unlock(&rdev->stats.lock);
 		*stag = (stag_idx << 8) | (atomic_inc_return(&key) & 0xff);
 	}
 	PDBG("%s stag_state 0x%0x type 0x%0x pdid 0x%0x, stag_idx 0x%x\n",
@@ -165,9 +170,13 @@ static int write_tpt_entry(struct c4iw_rdev *rdev, u32 reset_tpt_entry,
 				(rdev->lldi.vr->stag.start >> 5),
 				sizeof(tpt), &tpt);
 
-	if (reset_tpt_entry)
+	if (reset_tpt_entry) {
 		c4iw_put_resource(&rdev->resource.tpt_fifo, stag_idx,
 				  &rdev->resource.tpt_fifo_lock);
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.stag.cur -= 32;
+		mutex_unlock(&rdev->stats.lock);
+	}
 	return err;
 }
 
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 247fe70..c2554ef 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -190,6 +190,9 @@ static int c4iw_deallocate_pd(struct ib_pd *pd)
 	PDBG("%s ibpd %p pdid 0x%x\n", __func__, pd, php->pdid);
 	c4iw_put_resource(&rhp->rdev.resource.pdid_fifo, php->pdid,
 			  &rhp->rdev.resource.pdid_fifo_lock);
+	mutex_lock(&rhp->rdev.stats.lock);
+	rhp->rdev.stats.pd.cur--;
+	mutex_unlock(&rhp->rdev.stats.lock);
 	kfree(php);
 	return 0;
 }
@@ -222,6 +225,11 @@ static struct ib_pd *c4iw_allocate_pd(struct ib_device *ibdev,
 			return ERR_PTR(-EFAULT);
 		}
 	}
+	mutex_lock(&rhp->rdev.stats.lock);
+	rhp->rdev.stats.pd.cur++;
+	if (rhp->rdev.stats.pd.cur > rhp->rdev.stats.pd.max)
+		rhp->rdev.stats.pd.max = rhp->rdev.stats.pd.cur;
+	mutex_unlock(&rhp->rdev.stats.lock);
 	PDBG("%s pdid 0x%0x ptr 0x%p\n", __func__, pdid, php);
 	return &php->ibpd;
 }
diff --git a/drivers/infiniband/hw/cxgb4/resource.c b/drivers/infiniband/hw/cxgb4/resource.c
index 407ff39..1b948d1 100644
--- a/drivers/infiniband/hw/cxgb4/resource.c
+++ b/drivers/infiniband/hw/cxgb4/resource.c
@@ -185,6 +185,9 @@ u32 c4iw_get_cqid(struct c4iw_rdev *rdev, struct c4iw_dev_ucontext *uctx)
 					&rdev->resource.qid_fifo_lock);
 		if (!qid)
 			goto out;
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.qid.cur += rdev->qpmask + 1;
+		mutex_unlock(&rdev->stats.lock);
 		for (i = qid+1; i & rdev->qpmask; i++) {
 			entry = kmalloc(sizeof *entry, GFP_KERNEL);
 			if (!entry)
@@ -213,6 +216,10 @@ u32 c4iw_get_cqid(struct c4iw_rdev *rdev, struct c4iw_dev_ucontext *uctx)
 out:
 	mutex_unlock(&uctx->lock);
 	PDBG("%s qid 0x%x\n", __func__, qid);
+	mutex_lock(&rdev->stats.lock);
+	if (rdev->stats.qid.cur > rdev->stats.qid.max)
+		rdev->stats.qid.max = rdev->stats.qid.cur;
+	mutex_unlock(&rdev->stats.lock);
 	return qid;
 }
 
@@ -249,6 +256,9 @@ u32 c4iw_get_qpid(struct c4iw_rdev *rdev, struct c4iw_dev_ucontext *uctx)
 					&rdev->resource.qid_fifo_lock);
 		if (!qid)
 			goto out;
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.qid.cur += rdev->qpmask + 1;
+		mutex_unlock(&rdev->stats.lock);
 		for (i = qid+1; i & rdev->qpmask; i++) {
 			entry = kmalloc(sizeof *entry, GFP_KERNEL);
 			if (!entry)
@@ -277,6 +287,10 @@ u32 c4iw_get_qpid(struct c4iw_rdev *rdev, struct c4iw_dev_ucontext *uctx)
 out:
 	mutex_unlock(&uctx->lock);
 	PDBG("%s qid 0x%x\n", __func__, qid);
+	mutex_lock(&rdev->stats.lock);
+	if (rdev->stats.qid.cur > rdev->stats.qid.max)
+		rdev->stats.qid.max = rdev->stats.qid.cur;
+	mutex_unlock(&rdev->stats.lock);
 	return qid;
 }
 
@@ -315,12 +329,22 @@ u32 c4iw_pblpool_alloc(struct c4iw_rdev *rdev, int size)
 	if (!addr)
 		printk_ratelimited(KERN_WARNING MOD "%s: Out of PBL memory\n",
 		       pci_name(rdev->lldi.pdev));
+	if (addr) {
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.pbl.cur += roundup(size, 1 << MIN_PBL_SHIFT);
+		if (rdev->stats.pbl.cur > rdev->stats.pbl.max)
+			rdev->stats.pbl.max = rdev->stats.pbl.cur;
+		mutex_unlock(&rdev->stats.lock);
+	}
 	return (u32)addr;
 }
 
 void c4iw_pblpool_free(struct c4iw_rdev *rdev, u32 addr, int size)
 {
 	PDBG("%s addr 0x%x size %d\n", __func__, addr, size);
+	mutex_lock(&rdev->stats.lock);
+	rdev->stats.pbl.cur -= roundup(size, 1 << MIN_PBL_SHIFT);
+	mutex_unlock(&rdev->stats.lock);
 	gen_pool_free(rdev->pbl_pool, (unsigned long)addr, size);
 }
 
@@ -377,12 +401,22 @@ u32 c4iw_rqtpool_alloc(struct c4iw_rdev *rdev, int size)
 	if (!addr)
 		printk_ratelimited(KERN_WARNING MOD "%s: Out of RQT memory\n",
 		       pci_name(rdev->lldi.pdev));
+	if (addr) {
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.rqt.cur += roundup(size << 6, 1 << MIN_RQT_SHIFT);
+		if (rdev->stats.rqt.cur > rdev->stats.rqt.max)
+			rdev->stats.rqt.max = rdev->stats.rqt.cur;
+		mutex_unlock(&rdev->stats.lock);
+	}
 	return (u32)addr;
 }
 
 void c4iw_rqtpool_free(struct c4iw_rdev *rdev, u32 addr, int size)
 {
 	PDBG("%s addr 0x%x size %d\n", __func__, addr, size << 6);
+	mutex_lock(&rdev->stats.lock);
+	rdev->stats.rqt.cur -= roundup(size << 6, 1 << MIN_RQT_SHIFT);
+	mutex_unlock(&rdev->stats.lock);
 	gen_pool_free(rdev->rqt_pool, (unsigned long)addr, size << 6);
 }
 
@@ -433,12 +467,22 @@ u32 c4iw_ocqp_pool_alloc(struct c4iw_rdev *rdev, int size)
 {
 	unsigned long addr = gen_pool_alloc(rdev->ocqp_pool, size);
 	PDBG("%s addr 0x%x size %d\n", __func__, (u32)addr, size);
+	if (addr) {
+		mutex_lock(&rdev->stats.lock);
+		rdev->stats.ocqp.cur += roundup(size, 1 << MIN_OCQP_SHIFT);
+		if (rdev->stats.ocqp.cur > rdev->stats.ocqp.max)
+			rdev->stats.ocqp.max = rdev->stats.ocqp.cur;
+		mutex_unlock(&rdev->stats.lock);
+	}
 	return (u32)addr;
 }
 
 void c4iw_ocqp_pool_free(struct c4iw_rdev *rdev, u32 addr, int size)
 {
 	PDBG("%s addr 0x%x size %d\n", __func__, addr, size);
+	mutex_lock(&rdev->stats.lock);
+	rdev->stats.ocqp.cur -= roundup(size, 1 << MIN_OCQP_SHIFT);
+	mutex_unlock(&rdev->stats.lock);
 	gen_pool_free(rdev->ocqp_pool, (unsigned long)addr, size);
 }
 
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
