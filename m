From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Wed, 12 Oct 2011 12:57:26 +0300
Message-ID: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
Cc: eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl,
	therbert@google.com, jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dbaluta@ixiacom.com,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of using the dev->next chain and trying to resync at each call to
dev_seq_start, use the ifindex, keeping the last index in seq->private field.

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
 net/core/dev.c |   53 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 70ecb86..3ca0df8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4041,6 +4041,35 @@ static int dev_ifconf(struct net *net, char __user *arg)
 }
 
 #ifdef CONFIG_PROC_FS
+
+struct dev_iter_state {
+	struct seq_net_private p;
+	int ifindex;
+};
+
+static inline struct net_device *next_dev(struct seq_file *seq, loff_t *pos)
+{
+	struct dev_iter_state *state = seq->private;
+	struct net *net = seq_file_net(seq);
+	struct net_device *dev = NULL;
+	loff_t off;
+
+	++*pos;
+	dev = dev_get_by_index_rcu(net, state->ifindex);
+	state->ifindex++;
+	if (likely(dev))
+		return dev;
+
+	off = 1;
+	for_each_netdev_rcu(net, dev)
+		if (off++ == *pos) {
+			state->ifindex = dev->ifindex + 1;
+			return dev;
+		}
+
+	return NULL;
+}
+
 /*
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
@@ -4048,33 +4077,15 @@ static int dev_ifconf(struct net *net, char __user *arg)
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
-
-	off = 1;
-	for_each_netdev_rcu(net, dev)
-		if (off++ == *pos)
-			return dev;
-
-	return NULL;
+	return next_dev(seq, pos);
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net_device *dev = v;
-
-	if (v == SEQ_START_TOKEN)
-		dev = first_net_device_rcu(seq_file_net(seq));
-	else
-		dev = next_net_device_rcu(dev);
-
-	++*pos;
-	return dev;
+	return next_dev(seq, pos);
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
@@ -4173,7 +4184,7 @@ static const struct seq_operations dev_seq_ops = {
 static int dev_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &dev_seq_ops,
-			    sizeof(struct seq_net_private));
+			    sizeof(struct dev_iter_state));
 }
 
 static const struct file_operations dev_seq_fops = {
-- 
1.7.4.1
