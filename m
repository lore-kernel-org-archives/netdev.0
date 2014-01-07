From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Mon,  6 Jan 2014 21:25:55 -0800
Message-ID: <1389072355-20666-4-git-send-email-mwdalton@google.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389072355-20666-1-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Add initial support for debugfs to virtio-net. Each virtio-net network
device will have a directory under /virtio-net in debugfs. The
per-network device directory will contain one sub-directory per active,
enabled receive queue. If mergeable receive buffers are enabled, each
receive queue directory will contain a read-only file that returns the
current packet buffer size for the receive queue.

Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 drivers/net/virtio_net.c | 314 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 296 insertions(+), 18 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f6e1ee0..5da18d6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -27,6 +27,9 @@
 #include <linux/slab.h>
 #include <linux/cpu.h>
 #include <linux/average.h>
+#include <linux/seqlock.h>
+#include <linux/kref.h>
+#include <linux/debugfs.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -35,6 +38,9 @@ static bool csum = true, gso = true;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
+/* Debugfs root directory for all virtio-net devices. */
+static struct dentry *virtnet_debugfs_root;
+
 /* FIXME: MTU in config. */
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
@@ -102,9 +108,6 @@ struct receive_queue {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
-	/* Average packet length for mergeable receive buffers. */
-	struct ewma mrg_avg_pkt_len;
-
 	/* Page frag for packet buffer allocation. */
 	struct page_frag alloc_frag;
 
@@ -115,6 +118,28 @@ struct receive_queue {
 	char name[40];
 };
 
+/* Per-receive queue statistics exported via debugfs. */
+struct receive_queue_stats {
+	/* Average packet length of receive queue (for mergeable rx buffers). */
+	struct ewma avg_pkt_len;
+
+	/* Per-receive queue stats debugfs directory. */
+	struct dentry *dbg;
+
+	/* Reference count for the receive queue statistics, needed because
+	 * an open debugfs file may outlive the receive queue and netdevice.
+	 * Open files will remain in-use until all outstanding file descriptors
+	 * are closed, even after the underlying file is unlinked.
+	 */
+	struct kref refcount;
+
+	/* Sequence counter to allow debugfs readers to safely access stats.
+	 * Assumes a single virtio-net writer, which is enforced by virtio-net
+	 * and NAPI.
+	 */
+	seqcount_t dbg_seq;
+};
+
 struct virtnet_info {
 	struct virtio_device *vdev;
 	struct virtqueue *cvq;
@@ -147,6 +172,15 @@ struct virtnet_info {
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
+	/* Per-receive queue statstics exported via debugfs. Stored in
+	 * virtnet_info to survive freeze/restore -- a task may have a per-rq
+	 * debugfs file open at the time of freeze.
+	 */
+	struct receive_queue_stats **rq_stats;
+
+	/* Per-netdevice debugfs directory. */
+	struct dentry *dbg_dev_root;
+
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
@@ -358,6 +392,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 unsigned int len)
 {
 	struct skb_vnet_hdr *hdr = ctx->buf;
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct receive_queue_stats *rq_stats = vi->rq_stats[vq2rxq(rq->vq)];
 	int num_buf = hdr->mhdr.num_buffers;
 	struct page *page = virt_to_head_page(ctx->buf);
 	int offset = ctx->buf - page_address(page);
@@ -413,7 +449,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		}
 	}
 
-	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
+	write_seqcount_begin(&rq_stats->dbg_seq);
+	ewma_add(&rq_stats->avg_pkt_len, head_skb->len);
+	write_seqcount_end(&rq_stats->dbg_seq);
 	return head_skb;
 
 err_skb:
@@ -600,18 +638,30 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 	return err;
 }
 
+static unsigned int get_mergeable_buf_len(struct ewma *avg_pkt_len)
+{
+	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	unsigned int len;
+
+	len = hdr_len + clamp_t(unsigned int, ewma_read(avg_pkt_len),
+				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
+	return ALIGN(len, L1_CACHE_BYTES);
+}
+
 static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	const unsigned int ring_size = rq->mrg_buf_ctx_size;
-	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	struct page_frag *alloc_frag = &rq->alloc_frag;
+	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct mergeable_receive_buf_ctx *ctx;
 	int err;
 	unsigned int len, hole;
 
-	len = hdr_len + clamp_t(unsigned int, ewma_read(&rq->mrg_avg_pkt_len),
-				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
-	len = ALIGN(len, L1_CACHE_BYTES);
+	/* avg_pkt_len is written only in NAPI rx softirq context. We may
+	 * read avg_pkt_len without using the dbg_seq seqcount, as this code
+	 * is called only in NAPI rx softirq context or when NAPI is disabled.
+	 */
+	len = get_mergeable_buf_len(&vi->rq_stats[vq2rxq(rq->vq)]->avg_pkt_len);
 	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
 		return -ENOMEM;
 
@@ -1274,13 +1324,101 @@ static void virtnet_get_drvinfo(struct net_device *dev,
 
 }
 
+static ssize_t mergeable_rx_buffer_size_read(struct file *file,
+					     char __user *userbuf,
+					     size_t count,
+					     loff_t *ppos)
+{
+	struct receive_queue_stats *rq_stats = file->private_data;
+	char buf[32];
+	struct ewma avg;
+	unsigned int start, len;
+
+	/* Don't allow partial reads. */
+	if (*ppos)
+		return 0;
+	do {
+		start = read_seqcount_begin(&rq_stats->dbg_seq);
+		avg = rq_stats->avg_pkt_len;
+	} while (read_seqcount_retry(&rq_stats->dbg_seq, start));
+	len = scnprintf(buf, sizeof(buf), "%u\n", get_mergeable_buf_len(&avg));
+	return simple_read_from_buffer(userbuf, count, ppos, buf, len);
+}
+
+void receive_queue_stats_free(struct kref *ref)
+{
+	struct receive_queue_stats *rq_stats;
+
+	rq_stats = container_of(ref, struct receive_queue_stats, refcount);
+	kfree(rq_stats);
+}
+
+static int receive_queue_stats_debugfs_open(struct inode *inode,
+					    struct file *file)
+{
+	struct receive_queue_stats *rq_stats = inode->i_private;
+	kref_get(&rq_stats->refcount);
+	file->private_data = rq_stats;
+	return 0;
+}
+
+static int receive_queue_stats_debugfs_release(struct inode *inode,
+					       struct file *file)
+{
+	struct receive_queue_stats *rq_stats = inode->i_private;
+	kref_put(&rq_stats->refcount, receive_queue_stats_free);
+	file->private_data = NULL;
+	return 0;
+}
+
+static const struct file_operations mergeable_rx_buffer_size_fops = {
+	.owner = THIS_MODULE,
+	.open = receive_queue_stats_debugfs_open,
+	.read = mergeable_rx_buffer_size_read,
+	.llseek = default_llseek,
+	.release = receive_queue_stats_debugfs_release,
+};
+
+static void receive_queue_debugfs_add(struct receive_queue *rq)
+{
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	unsigned int rq_index = vq2rxq(rq->vq);
+	struct receive_queue_stats *rq_stats = vi->rq_stats[rq_index];
+	struct dentry *dentry;
+	char name[32];
+
+	if (IS_ERR_OR_NULL(vi->dbg_dev_root))
+		return;
+	scnprintf(name, sizeof(name), "rx-%u", rq_index);
+	dentry = debugfs_create_dir(name, vi->dbg_dev_root);
+	if (IS_ERR_OR_NULL(dentry)) {
+		pr_warn("%s: could not create %s rx queue debugfs dir\n",
+			vi->dev->name, name);
+		return;
+	}
+	rq_stats->dbg = dentry;
+	if (vi->mergeable_rx_bufs)
+		debugfs_create_file("mergeable_rx_buffer_size", S_IRUSR,
+				rq_stats->dbg, rq_stats,
+				&mergeable_rx_buffer_size_fops);
+}
+
+static void receive_queue_debugfs_del(struct receive_queue *rq)
+{
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	struct receive_queue_stats *rq_stats = vi->rq_stats[vq2rxq(rq->vq)];
+	debugfs_remove_recursive(rq_stats->dbg);
+	rq_stats->dbg = NULL;
+}
+
 /* TODO: Eliminate OOO packets during switching */
 static int virtnet_set_channels(struct net_device *dev,
 				struct ethtool_channels *channels)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	u16 queue_pairs = channels->combined_count;
-	int err;
+	u16 new_queue_pairs = channels->combined_count;
+	u16 old_queue_pairs = vi->curr_queue_pairs;
+	int err, i;
 
 	/* We don't support separate rx/tx channels.
 	 * We don't allow setting 'other' channels.
@@ -1288,14 +1426,21 @@ static int virtnet_set_channels(struct net_device *dev,
 	if (channels->rx_count || channels->tx_count || channels->other_count)
 		return -EINVAL;
 
-	if (queue_pairs > vi->max_queue_pairs)
+	if (new_queue_pairs > vi->max_queue_pairs)
 		return -EINVAL;
 
 	get_online_cpus();
-	err = virtnet_set_queues(vi, queue_pairs);
+	err = virtnet_set_queues(vi, new_queue_pairs);
 	if (!err) {
-		netif_set_real_num_tx_queues(dev, queue_pairs);
-		netif_set_real_num_rx_queues(dev, queue_pairs);
+		if (new_queue_pairs < old_queue_pairs) {
+			for (i = new_queue_pairs; i < old_queue_pairs; i++)
+				receive_queue_debugfs_del(&vi->rq[i]);
+		} else {
+			for (i = old_queue_pairs; i < new_queue_pairs; i++)
+				receive_queue_debugfs_add(&vi->rq[i]);
+		}
+		netif_set_real_num_tx_queues(dev, new_queue_pairs);
+		netif_set_real_num_rx_queues(dev, new_queue_pairs);
 
 		virtnet_set_affinity(vi);
 	}
@@ -1336,7 +1481,44 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* Must be called only after the net_device name has been expanded. */
+static void virtnet_debugfs_init(struct virtnet_info *vi)
+{
+	int i;
+
+	if (IS_ERR_OR_NULL(virtnet_debugfs_root))
+		return;
+	vi->dbg_dev_root = debugfs_create_dir(vi->dev->name,
+					      virtnet_debugfs_root);
+	if (IS_ERR_OR_NULL(vi->dbg_dev_root)) {
+		pr_warn("%s: could not create netdevice debugfs dir\n",
+			vi->dev->name);
+		return;
+	}
+	for (i = 0; i < vi->curr_queue_pairs; i++)
+		receive_queue_debugfs_add(&vi->rq[i]);
+}
+
+static void virtnet_debugfs_cleanup(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++)
+		receive_queue_debugfs_del(&vi->rq[i]);
+	debugfs_remove_recursive(vi->dbg_dev_root);
+	vi->dbg_dev_root = NULL;
+}
+
+static int virtnet_init(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	virtnet_debugfs_init(vi);
+	return 0;
+}
+
 static const struct net_device_ops virtnet_netdev = {
+	.ndo_init	     = virtnet_init,
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
 	.ndo_start_xmit      = start_xmit,
@@ -1560,7 +1742,6 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
-		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
 		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
 	}
 
@@ -1614,6 +1795,39 @@ err:
 	return ret;
 }
 
+static int virtnet_rename(struct notifier_block *this,
+			  unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct virtnet_info *vi;
+
+	if (event != NETDEV_CHANGENAME || dev->netdev_ops != &virtnet_netdev)
+		return NOTIFY_DONE;
+	vi = netdev_priv(dev);
+	if (IS_ERR_OR_NULL(vi->dbg_dev_root))
+		return NOTIFY_DONE;
+	if (IS_ERR_OR_NULL(debugfs_rename(virtnet_debugfs_root,
+					  vi->dbg_dev_root,
+					  virtnet_debugfs_root, dev->name))) {
+		pr_warn("%s: failed debugfs rename, removing old debugfs dir\n",
+			dev->name);
+		virtnet_debugfs_cleanup(vi);
+	}
+	return NOTIFY_DONE;
+}
+
+static void virtnet_release_receive_queue_stats(struct virtnet_info *vi)
+{
+	int i;
+
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		struct receive_queue_stats *rq_stats = vi->rq_stats[i];
+		if (rq_stats)
+			kref_put(&rq_stats->refcount, receive_queue_stats_free);
+	}
+	kfree(vi->rq_stats);
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int i, err;
@@ -1723,10 +1937,24 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vi->curr_queue_pairs = 1;
 	vi->max_queue_pairs = max_queue_pairs;
 
+	vi->rq_stats = kzalloc(sizeof(vi->rq_stats[0]) *
+			       vi->max_queue_pairs, GFP_KERNEL);
+	if (!vi->rq_stats)
+		goto free_dev_stats;
+	for (i = 0; i < vi->max_queue_pairs; i++) {
+		vi->rq_stats[i] = kzalloc(sizeof(*vi->rq_stats[0]), GFP_KERNEL);
+		if (!vi->rq_stats[i])
+			goto free_rq_stats;
+		seqcount_init(&vi->rq_stats[i]->dbg_seq);
+		kref_init(&vi->rq_stats[i]->refcount);
+		ewma_init(&vi->rq_stats[i]->avg_pkt_len, 1,
+			  RECEIVE_AVG_WEIGHT);
+	}
+
 	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
 	err = init_vqs(vi);
 	if (err)
-		goto free_stats;
+		goto free_rq_stats;
 
 	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
 	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
@@ -1777,8 +2005,11 @@ free_recv_bufs:
 free_vqs:
 	cancel_delayed_work_sync(&vi->refill);
 	free_receive_page_frags(vi);
+	virtnet_debugfs_cleanup(vi);
 	virtnet_del_vqs(vi);
-free_stats:
+free_rq_stats:
+	virtnet_release_receive_queue_stats(vi);
+free_dev_stats:
 	free_percpu(vi->stats);
 free:
 	free_netdev(dev);
@@ -1812,10 +2043,12 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	unregister_netdev(vi->dev);
 
+	virtnet_debugfs_cleanup(vi);
 	remove_vq_common(vi);
 
 	flush_work(&vi->config_work);
 
+	virtnet_release_receive_queue_stats(vi);
 	free_percpu(vi->stats);
 	free_netdev(vi->dev);
 }
@@ -1884,6 +2117,19 @@ static int virtnet_restore(struct virtio_device *vdev)
 }
 #endif
 
+static void virtnet_register_debugfs(void)
+{
+	virtnet_debugfs_root = debugfs_create_dir("virtio-net", NULL);
+	if (IS_ERR_OR_NULL(virtnet_debugfs_root))
+		pr_warn("Could not create virtio-net debugfs dir\n");
+}
+
+static void virtnet_unregister_debugfs(void)
+{
+	debugfs_remove_recursive(virtnet_debugfs_root);
+	virtnet_debugfs_root = NULL;
+}
+
 static struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
 	{ 0 },
@@ -1917,7 +2163,39 @@ static struct virtio_driver virtio_net_driver = {
 #endif
 };
 
-module_virtio_driver(virtio_net_driver);
+static struct notifier_block virtnet_rename_notifier = {
+	.notifier_call = virtnet_rename,
+};
+
+static int __init init(void)
+{
+	int err;
+
+	virtnet_register_debugfs();
+	err = register_netdevice_notifier(&virtnet_rename_notifier);
+	if (err)
+		goto free_debugfs;
+	err = register_virtio_driver(&virtio_net_driver);
+	if (err)
+		goto free_notifier;
+	return 0;
+
+free_notifier:
+	unregister_netdevice_notifier(&virtnet_rename_notifier);
+free_debugfs:
+	virtnet_unregister_debugfs();
+	return err;
+}
+
+static void __exit cleanup(void)
+{
+	unregister_virtio_driver(&virtio_net_driver);
+	unregister_netdevice_notifier(&virtnet_rename_notifier);
+	virtnet_unregister_debugfs();
+}
+
+module_init(init);
+module_exit(cleanup);
 
 MODULE_DEVICE_TABLE(virtio, id_table);
 MODULE_DESCRIPTION("Virtio network driver");
-- 
1.8.5.1
