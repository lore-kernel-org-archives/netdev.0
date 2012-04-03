From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net: fix /proc/net/dev regression
Date: Tue, 03 Apr 2012 10:33:02 +0200
Message-ID: <1333441982.18626.62.camel@edumazet-glaptop>
References: <4F7A7C98.1030103@candelatech.com>
	 <1333431810.18626.37.camel@edumazet-glaptop>
	 <4F7A905B.3080107@candelatech.com>
	 <1333434995.18626.39.camel@edumazet-glaptop>
	 <1333436789.18626.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60918 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab2DCIdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 04:33:13 -0400
Received: by bkcik5 with SMTP id ik5so3332610bkc.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 01:33:11 -0700 (PDT)
In-Reply-To: <1333436789.18626.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f04565ddf52 (dev: use name hash for dev_seq_ops) added a second
regression, as some devices are missing from /proc/net/dev if many
devices are defined.

When seq_file buffer is filled, the last ->next/show() method is
canceled (pos value is reverted to value prior ->next() call)

Problem is after above commit, we dont restart the lookup at right
position in ->start() method.

Fix this by removing the internal 'pos' pointer added in commit, since
we need to use the 'loff_t *pos' provided by seq_file layer.

This also reverts commit 5cac98dd0 (net: Fix corruption
in /proc/*/net/dev_mcast), since its not needed anymore.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mihai Maruseac <mmaruseac@ixiacom.com>
---
 include/linux/netdevice.h |    2 -
 net/core/dev.c            |   58 ++++++++----------------------------
 net/core/dev_addr_lists.c |    3 +
 3 files changed, 15 insertions(+), 48 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1f77540..5cbaa20 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2604,8 +2604,6 @@ extern void		net_disable_timestamp(void);
 extern void *dev_seq_start(struct seq_file *seq, loff_t *pos);
 extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 extern void dev_seq_stop(struct seq_file *seq, void *v);
-extern int dev_seq_open_ops(struct inode *inode, struct file *file,
-			    const struct seq_operations *ops);
 #endif
 
 extern int netdev_class_create_file(struct class_attribute *class_attr);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6c7dc9d..c25d453 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4028,54 +4028,41 @@ static int dev_ifconf(struct net *net, char __user *arg)
 
 #ifdef CONFIG_PROC_FS
 
-#define BUCKET_SPACE (32 - NETDEV_HASHBITS)
-
-struct dev_iter_state {
-	struct seq_net_private p;
-	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
-};
+#define BUCKET_SPACE (32 - NETDEV_HASHBITS - 1)
 
 #define get_bucket(x) ((x) >> BUCKET_SPACE)
 #define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
 #define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
 
-static inline struct net_device *dev_from_same_bucket(struct seq_file *seq)
+static inline struct net_device *dev_from_same_bucket(struct seq_file *seq, loff_t *pos)
 {
-	struct dev_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
 	struct net_device *dev;
 	struct hlist_node *p;
 	struct hlist_head *h;
-	unsigned int count, bucket, offset;
+	unsigned int count = 0, offset = get_offset(*pos);
 
-	bucket = get_bucket(state->pos);
-	offset = get_offset(state->pos);
-	h = &net->dev_name_head[bucket];
-	count = 0;
+	h = &net->dev_name_head[get_bucket(*pos)];
 	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
-		if (count++ == offset) {
-			state->pos = set_bucket_offset(bucket, count);
+		if (++count == offset)
 			return dev;
-		}
 	}
 
 	return NULL;
 }
 
-static inline struct net_device *dev_from_new_bucket(struct seq_file *seq)
+static inline struct net_device *dev_from_bucket(struct seq_file *seq, loff_t *pos)
 {
-	struct dev_iter_state *state = seq->private;
 	struct net_device *dev;
 	unsigned int bucket;
 
-	bucket = get_bucket(state->pos);
 	do {
-		dev = dev_from_same_bucket(seq);
+		dev = dev_from_same_bucket(seq, pos);
 		if (dev)
 			return dev;
 
-		bucket++;
-		state->pos = set_bucket_offset(bucket, 0);
+		bucket = get_bucket(*pos) + 1;
+		*pos = set_bucket_offset(bucket, 1);
 	} while (bucket < NETDEV_HASHENTRIES);
 
 	return NULL;
@@ -4088,33 +4075,20 @@ static inline struct net_device *dev_from_new_bucket(struct seq_file *seq)
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
-	struct dev_iter_state *state = seq->private;
-
 	rcu_read_lock();
 	if (!*pos)
 		return SEQ_START_TOKEN;
 
-	/* check for end of the hash */
-	if (state->pos == 0 && *pos > 1)
+	if (get_bucket(*pos) >= NETDEV_HASHENTRIES)
 		return NULL;
 
-	return dev_from_new_bucket(seq);
+	return dev_from_bucket(seq, pos);
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net_device *dev;
-
 	++*pos;
-
-	if (v == SEQ_START_TOKEN)
-		return dev_from_new_bucket(seq);
-
-	dev = dev_from_same_bucket(seq);
-	if (dev)
-		return dev;
-
-	return dev_from_new_bucket(seq);
+	return dev_from_bucket(seq, pos);
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
@@ -4213,13 +4187,7 @@ static const struct seq_operations dev_seq_ops = {
 static int dev_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &dev_seq_ops,
-			    sizeof(struct dev_iter_state));
-}
-
-int dev_seq_open_ops(struct inode *inode, struct file *file,
-		     const struct seq_operations *ops)
-{
-	return seq_open_net(inode, file, ops, sizeof(struct dev_iter_state));
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations dev_seq_fops = {
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 29c07fe..626698f 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -696,7 +696,8 @@ static const struct seq_operations dev_mc_seq_ops = {
 
 static int dev_mc_seq_open(struct inode *inode, struct file *file)
 {
-	return dev_seq_open_ops(inode, file, &dev_mc_seq_ops);
+	return seq_open_net(inode, file, &dev_mc_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations dev_mc_seq_fops = {
