From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH v2] net/netfilter/x_tables.c: use __seq_open_private()
Date: Tue, 23 Sep 2014 18:05:55 +0100
Message-ID: <1411491955-9131-1-git-send-email-rob.jones@codethink.co.uk>
Cc: netfilter@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-kernel@codethink.co.uk,
	rob.jones@codethink.co.uk
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce boilerplate code by using __seq_open_private() instead of seq_open()
in xt_match_open() and xt_target_open().

Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
---

This patch uses an existing variant of seq_open() to reduce the kernel code
size.

The only significant variation from the pre-existing code is the fact that
__seq_open_private() calls kzalloc() rather than kmalloc(), which could
conceivably have an impact on timing.

This version 2 incorporates a minor initialisation simplification (resulting
from kzalloc() being used) requested by netfilter-devel@vger.kernel.org

 net/netfilter/x_tables.c |   31 ++++---------------------------
 1 file changed, 4 insertions(+), 27 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 227aa11..393f17b 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1080,7 +1080,6 @@ static void *xt_mttg_seq_start(struct seq_file *seq, loff_t *pos,
 	struct nf_mttg_trav *trav = seq->private;
 	unsigned int j;
 
-	trav->class = MTTG_TRAV_INIT;
 	for (j = 0; j < *pos; ++j)
 		if (xt_mttg_seq_next(seq, NULL, NULL, is_target) == NULL)
 			return NULL;
@@ -1137,22 +1136,11 @@ static const struct seq_operations xt_match_seq_ops = {
 
 static int xt_match_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
 	struct nf_mttg_trav *trav;
-	int ret;
-
-	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
-	if (trav == NULL)
+	trav = __seq_open_private(file, &xt_match_seq_ops, sizeof(*trav));
+	if (!trav)
 		return -ENOMEM;
 
-	ret = seq_open(file, &xt_match_seq_ops);
-	if (ret < 0) {
-		kfree(trav);
-		return ret;
-	}
-
-	seq = file->private_data;
-	seq->private = trav;
 	trav->nfproto = (unsigned long)PDE_DATA(inode);
 	return 0;
 }
@@ -1201,22 +1189,11 @@ static const struct seq_operations xt_target_seq_ops = {
 
 static int xt_target_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
 	struct nf_mttg_trav *trav;
-	int ret;
-
-	trav = kmalloc(sizeof(*trav), GFP_KERNEL);
-	if (trav == NULL)
+	trav = __seq_open_private(file, &xt_target_seq_ops, sizeof(*trav));
+	if (!trav)
 		return -ENOMEM;
 
-	ret = seq_open(file, &xt_target_seq_ops);
-	if (ret < 0) {
-		kfree(trav);
-		return ret;
-	}
-
-	seq = file->private_data;
-	seq->private = trav;
 	trav->nfproto = (unsigned long)PDE_DATA(inode);
 	return 0;
 }
-- 
1.7.10.4

