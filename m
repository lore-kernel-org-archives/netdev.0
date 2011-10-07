From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: [PATCH] dev: use name hash for dev_seq_ops.
Date: Fri,  7 Oct 2011 18:20:49 +0300
Message-ID: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
Cc: eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl,
	therbert@google.com, jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dbaluta@ixiacom.com,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of using the dev->next chain and trying to resync at each call to
dev_seq_start, use this hash and store bucket number and bucket offset in
seq->private field.

Tests revealed the following results for ifconfig > /dev/null
	* 1000 interfaces:
		* 0.114s without patch
		* 0.020s with patch
	* 3000 interfaces:
		* 0.489s without patch
		* 0.048s with patch
	* 5000 interfaces:
		* 1.363s without patch
		* 0.131s with patch

As one can notice the improvement is of 1 order of magnitude.

Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
---
 net/core/dev.c |   73 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bf49a47..2d0f126 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4034,6 +4034,51 @@ static int dev_ifconf(struct net *net, char __user *arg)
 }
 
 #ifdef CONFIG_PROC_FS
+
+struct dev_iter_state {
+	struct seq_net_private p;
+	int bucket;
+	int offset;
+};
+
+static inline struct net_device *dev_from_same_bucket(struct seq_file *seq)
+{
+	struct net_device *dev = NULL;
+	struct net *net = seq_file_net(seq);
+	struct dev_iter_state *state = seq->private;
+	struct hlist_node *p;
+	struct hlist_head *h;
+	int count;
+
+	h = &net->dev_name_head[state->bucket];
+	count = 0;
+	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
+		if (count++ == state->offset) {
+			state->offset = count;
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
+	struct net_device *dev = NULL;
+
+	while (state->bucket < NETDEV_HASHENTRIES) {
+		dev = dev_from_same_bucket(seq);
+		if (dev)
+			return dev;
+
+		state->bucket++;
+		state->offset = 0;
+	}
+
+	return NULL;
+}
+
 /*
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
@@ -4041,33 +4086,27 @@ static int dev_ifconf(struct net *net, char __user *arg)
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
-	struct net *net = seq_file_net(seq);
-	loff_t off;
-	struct net_device *dev;
-
 	rcu_read_lock();
 	if (!*pos)
 		return SEQ_START_TOKEN;
 
-	off = 1;
-	for_each_netdev_rcu(net, dev)
-		if (off++ == *pos)
-			return dev;
-
-	return NULL;
+	return dev_from_new_bucket(seq);
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net_device *dev = v;
+	struct net_device *dev = NULL;
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
@@ -4166,7 +4205,7 @@ static const struct seq_operations dev_seq_ops = {
 static int dev_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &dev_seq_ops,
-			    sizeof(struct seq_net_private));
+			    sizeof(struct dev_iter_state));
 }
 
 static const struct file_operations dev_seq_fops = {
-- 
1.7.4.1
