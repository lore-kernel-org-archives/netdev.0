From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Add debugfs facility to inject FL starvation
Date: Sun, 17 May 2015 16:15:22 +0530
Message-ID: <1431859523-7423-3-git-send-email-hariprasad@chelsio.com>
References: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1926 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751487AbbEQFcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 01:32:41 -0400
In-Reply-To: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add debugfs entry to inject Freelist starvation, used only for debugging
purpose.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 56 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 14 +++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  3 ++
 4 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 25c19ef..6016f0d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -650,6 +650,7 @@ struct sge {
 	struct sge_rspq **ingr_map; /* qid->queue ingress queue map */
 	unsigned long *starving_fl;
 	unsigned long *txq_maperr;
+	unsigned long *blocked_fl;
 	struct timer_list rx_timer; /* refills starving FLs */
 	struct timer_list tx_timer; /* checks Tx queues */
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 371f75e..3fa3632 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1959,6 +1959,61 @@ static void add_debugfs_mem(struct adapter *adap, const char *name,
 				 size_mb << 20);
 }
 
+static int blocked_fl_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t blocked_fl_read(struct file *filp, char __user *ubuf,
+			       size_t count, loff_t *ppos)
+{
+	int len;
+	const struct adapter *adap = filp->private_data;
+	char *buf;
+	ssize_t size = (adap->sge.egr_sz + 3) / 4 +
+			adap->sge.egr_sz / 32 + 2; /* includes ,/\n/\0 */
+
+	buf = kzalloc(size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	len = snprintf(buf, size - 1, "%*pb\n",
+		       adap->sge.egr_sz, adap->sge.blocked_fl);
+	len += sprintf(buf + len, "\n");
+	size = simple_read_from_buffer(ubuf, count, ppos, buf, len);
+	t4_free_mem(buf);
+	return size;
+}
+
+static ssize_t blocked_fl_write(struct file *filp, const char __user *ubuf,
+				size_t count, loff_t *ppos)
+{
+	int err;
+	unsigned long *t;
+	struct adapter *adap = filp->private_data;
+
+	t = kcalloc(BITS_TO_LONGS(adap->sge.egr_sz), sizeof(long), GFP_KERNEL);
+	if (!t)
+		return -ENOMEM;
+
+	err = bitmap_parse_user(ubuf, count, t, adap->sge.egr_sz);
+	if (err)
+		return err;
+
+	bitmap_copy(adap->sge.blocked_fl, t, adap->sge.egr_sz);
+	t4_free_mem(t);
+	return count;
+}
+
+static const struct file_operations blocked_fl_fops = {
+	.owner   = THIS_MODULE,
+	.open    = blocked_fl_open,
+	.read    = blocked_fl_read,
+	.write   = blocked_fl_write,
+	.llseek  = generic_file_llseek,
+};
+
 /* Add an array of Debug FS files.
  */
 void add_debugfs_files(struct adapter *adap,
@@ -2022,6 +2077,7 @@ int t4_setup_debugfs(struct adapter *adap)
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
+		{ "blocked_fl", &blocked_fl_fops, S_IRUSR | S_IWUSR, 0 },
 	};
 
 	/* Debug FS nodes common to all T5 and later adapters.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 888406e..4ec9492 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3780,7 +3780,7 @@ static int adap_init0(struct adapter *adap)
 	}
 
 	/* Allocate the memory for the vaious egress queue bitmaps
-	 * ie starving_fl and txq_maperr.
+	 * ie starving_fl, txq_maperr and blocked_fl.
 	 */
 	adap->sge.starving_fl =	kcalloc(BITS_TO_LONGS(adap->sge.egr_sz),
 					sizeof(long), GFP_KERNEL);
@@ -3796,6 +3796,15 @@ static int adap_init0(struct adapter *adap)
 		goto bye;
 	}
 
+#ifdef CONFIG_DEBUG_FS
+	adap->sge.blocked_fl = kcalloc(BITS_TO_LONGS(adap->sge.egr_sz),
+				       sizeof(long), GFP_KERNEL);
+	if (!adap->sge.blocked_fl) {
+		ret = -ENOMEM;
+		goto bye;
+	}
+#endif
+
 	params[0] = FW_PARAM_PFVF(CLIP_START);
 	params[1] = FW_PARAM_PFVF(CLIP_END);
 	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
@@ -4008,6 +4017,7 @@ bye:
 	kfree(adap->sge.ingr_map);
 	kfree(adap->sge.starving_fl);
 	kfree(adap->sge.txq_maperr);
+	kfree(adap->sge.blocked_fl);
 	if (ret != -ETIMEDOUT && ret != -EIO)
 		t4_fw_bye(adap, adap->mbox);
 	return ret;
@@ -4451,6 +4461,7 @@ static void free_some_resources(struct adapter *adapter)
 	kfree(adapter->sge.ingr_map);
 	kfree(adapter->sge.starving_fl);
 	kfree(adapter->sge.txq_maperr);
+	kfree(adapter->sge.blocked_fl);
 	disable_msi(adapter);
 
 	for_each_port(adapter, i)
@@ -4597,6 +4608,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	setup_memwin(adapter);
 	err = adap_init0(adapter);
+	bitmap_zero(adapter->sge.blocked_fl, adapter->sge.egr_sz);
 	setup_memwin_rdma(adapter);
 	if (err)
 		goto out_unmap_bar;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 0d4dd48..9871165 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -588,6 +588,9 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	int node;
 
+	if (test_bit(q->cntxt_id - adap->sge.egr_start, adap->sge.blocked_fl))
+		goto out;
+
 	gfp |= __GFP_NOWARN;
 	node = dev_to_node(adap->pdev_dev);
 
-- 
2.3.4
