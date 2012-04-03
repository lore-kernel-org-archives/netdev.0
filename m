From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/dev is funky in 3.3.0
Date: Tue, 03 Apr 2012 09:06:29 +0200
Message-ID: <1333436789.18626.43.camel@edumazet-glaptop>
References: <4F7A7C98.1030103@candelatech.com>
	 <1333431810.18626.37.camel@edumazet-glaptop>
	 <4F7A905B.3080107@candelatech.com>
	 <1333434995.18626.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37283 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab2DCHGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 03:06:36 -0400
Received: by bkcik5 with SMTP id ik5so3265356bkc.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 00:06:35 -0700 (PDT)
In-Reply-To: <1333434995.18626.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 08:36 +0200, Eric Dumazet wrote:

> Hmm, I think I understand, commit f04565ddf52 added a regression here, I
> will send a fix.
> 

If you want to try following patch, please do so, I cant try it right
now...

I'll provide a proper changelog/attributions in a couple of hours, and
make tests myself of course.

Thanks

 net/core/dev.c |   46 ++++++++++++----------------------------------
 1 file changed, 12 insertions(+), 34 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6c7dc9d..f7e7de3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4028,54 +4028,45 @@ static int dev_ifconf(struct net *net, char __user *arg)
 
 #ifdef CONFIG_PROC_FS
 
-#define BUCKET_SPACE (32 - NETDEV_HASHBITS)
+#define BUCKET_SPACE (32 - NETDEV_HASHBITS - 1)
 
 struct dev_iter_state {
 	struct seq_net_private p;
-	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
 };
 
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
+		bucket = get_bucket(*pos);
+		*pos = set_bucket_offset(bucket + 1, 1);
 	} while (bucket < NETDEV_HASHENTRIES);
 
 	return NULL;
@@ -4088,33 +4079,20 @@ static inline struct net_device *dev_from_new_bucket(struct seq_file *seq)
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
