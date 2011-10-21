From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: [PATCH] dev: use name hash for dev_seq_ops
Date: Fri, 21 Oct 2011 09:45:10 +0300
Message-ID: <1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
References: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
Cc: mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: davem@davemloft.net, shemminger@vyatta.com, eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of using the dev->next chain and trying to resync at each call to
dev_seq_start, use the name hash, keeping the bucket and the offset in
seq->private field.

Tests revealed the following results for ifconfig > /dev/null
	* 1000 interfaces:
		* 0.114s without patch
		* 0.089s with patch
	* 3000 interfaces:
		* 0.489s without patch
		* 0.110s with patch
	* 5000 interfaces:
		* 1.363s without patch
		* 0.250s with patch
	* 128000 interfaces (other setup):
		* ~100s without patch
		* ~30s with patch

Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
---
 net/core/dev.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 69 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 70ecb86..6edbcc5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4041,6 +4041,60 @@ static int dev_ifconf(struct net *net, char __user *arg)
 }
 
 #ifdef CONFIG_PROC_FS
+
+#define BUCKET_SPACE (32 - NETDEV_HASHBITS)
+
+struct dev_iter_state {
+	struct seq_net_private p;
+	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
+};
+
+#define get_bucket(x) ((x) >> BUCKET_SPACE)
+#define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
+#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
+
+static inline struct net_device *dev_from_same_bucket(struct seq_file *seq)
+{
+	struct dev_iter_state *state = seq->private;
+	struct net *net = seq_file_net(seq);
+	struct net_device *dev;
+	struct hlist_node *p;
+	struct hlist_head *h;
+	unsigned int count, bucket, offset;
+
+	bucket = get_bucket(state->pos);
+	offset = get_offset(state->pos);
+	h = &net->dev_name_head[bucket];
+	count = 0;
+	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
+		if (count++ == offset) {
+			state->pos = set_bucket_offset(bucket, count);
+			return dev;
+		}
+	}
+
+	return NULL;
+}
+
+static inline struct net_device *dev_from_new_bucket(struct seq_file *seq)
+{
+	struct dev_iter_state *state = seq->private;
+	struct net_device *dev;
+	unsigned int bucket;
+
+	bucket = get_bucket(state->pos);
+	do {
+		dev = dev_from_same_bucket(seq);
+		if (dev)
+			return dev;
+
+		bucket++;
+		state->pos = set_bucket_offset(bucket, 0);
+	} while (bucket < NETDEV_HASHENTRIES);
+
+	return NULL;
+}
+
 /*
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
@@ -4048,33 +4102,33 @@ static int dev_ifconf(struct net *net, char __user *arg)
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
-	struct net *net = seq_file_net(seq);
-	loff_t off;
-	struct net_device *dev;
+	struct dev_iter_state *state = seq->private;
 
 	rcu_read_lock();
 	if (!*pos)
 		return SEQ_START_TOKEN;
 
-	off = 1;
-	for_each_netdev_rcu(net, dev)
-		if (off++ == *pos)
-			return dev;
+	/* check for end of the hash */
+	if (state->pos == 0 && *pos > 1)
+		return NULL;
 
-	return NULL;
+	return dev_from_new_bucket(seq);
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net_device *dev = v;
+	struct net_device *dev;
+
+	++*pos;
 
 	if (v == SEQ_START_TOKEN)
-		dev = first_net_device_rcu(seq_file_net(seq));
-	else
-		dev = next_net_device_rcu(dev);
+		return dev_from_new_bucket(seq);
 
-	++*pos;
-	return dev;
+	dev = dev_from_same_bucket(seq);
+	if (dev)
+		return dev;
+
+	return dev_from_new_bucket(seq);
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
@@ -4173,7 +4227,7 @@ static const struct seq_operations dev_seq_ops = {
 static int dev_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &dev_seq_ops,
-			    sizeof(struct seq_net_private));
+			    sizeof(struct dev_iter_state));
 }
 
 static const struct file_operations dev_seq_fops = {
-- 
1.7.4.1
