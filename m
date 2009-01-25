From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] net: pppoe - stop using proc internals
Date: Sun, 25 Jan 2009 15:02:43 +0300
Message-ID: <20090125120243.GA29167@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Michal Ostrowski <mostrows@earthlink.net>,
	NKML <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>,
	LiNext <linux-next@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan pointed that using PDE_NET outside the
proc code is plain bogus (thanks Alexey!). Fix it.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: Alexey Dobriyan <adobriyan@gmail.com>
CC: Michal Ostrowski <mostrows@earthlink.net>
---

Hope I didn't miss anything. Compile tested.
Please review.

 drivers/net/pppoe.c |   34 ++++++----------------------------
 1 file changed, 6 insertions(+), 28 deletions(-)

Index: linux-2.6.git/drivers/net/pppoe.c
===================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -1041,7 +1041,7 @@ out:
 static void *pppoe_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(pn->hash_lock)
 {
-	struct pppoe_net *pn = pppoe_pernet(seq->private);
+	struct pppoe_net *pn = pppoe_pernet(seq_file_net(seq));
 	loff_t l = *pos;
 
 	read_lock_bh(&pn->hash_lock);
@@ -1050,7 +1050,7 @@ static void *pppoe_seq_start(struct seq_
 
 static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct pppoe_net *pn = pppoe_pernet(seq->private);
+	struct pppoe_net *pn = pppoe_pernet(seq_file_net(seq));
 	struct pppox_sock *po;
 
 	++*pos;
@@ -1078,7 +1078,7 @@ out:
 static void pppoe_seq_stop(struct seq_file *seq, void *v)
 	__releases(pn->hash_lock)
 {
-	struct pppoe_net *pn = pppoe_pernet(seq->private);
+	struct pppoe_net *pn = pppoe_pernet(seq_file_net(seq));
 	read_unlock_bh(&pn->hash_lock);
 }
 
@@ -1091,30 +1091,8 @@ static struct seq_operations pppoe_seq_o
 
 static int pppoe_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *m;
-	struct net *net;
-	int err;
-
-	err = seq_open(file, &pppoe_seq_ops);
-	if (err)
-		return err;
-
-	m = file->private_data;
-	net = maybe_get_net(PDE_NET(PDE(inode)));
-	BUG_ON(!net);
-	m->private = net;
-
-	return err;
-}
-
-static int pppoe_seq_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *m;
-
-	m = file->private_data;
-	put_net((struct net*)m->private);
-
-	return seq_release(inode, file);
+	return seq_open_net(inode, file, &pppoe_seq_ops,
+			sizeof(struct seq_net_private));
 }
 
 static const struct file_operations pppoe_seq_fops = {
@@ -1122,7 +1100,7 @@ static const struct file_operations pppo
 	.open		= pppoe_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= pppoe_seq_release,
+	.release	= seq_release_net,
 };
 
 #endif /* CONFIG_PROC_FS */
