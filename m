From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] [ATM] Simplify /proc/net/atm/arp opening
Date: Thu, 10 Jan 2008 14:30:44 +0300
Message-ID: <20080110113044.GA16213@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:52642 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753712AbYAJL1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 06:27:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iterator state->ns.neigh_sub_iter initialization is moved from
arp_seq_open to clip_seq_start for convinience. This should not be a problem
as the iterator will be used only after the seq_start callback.

Signed-off-by: Denis V. Lunev <den@openvz.org>

---

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 47fbdc0..de5b780 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -903,6 +903,8 @@ static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
 
 static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
 {
+	struct clip_seq_state *state = seq->private;
+	state->ns.neigh_sub_iter = clip_seq_sub_iter;
 	return neigh_seq_start(seq, pos, &clip_tbl, NEIGH_SEQ_NEIGH_ONLY);
 }
 
@@ -932,49 +934,15 @@ static const struct seq_operations arp_seq_ops = {
 
 static int arp_seq_open(struct inode *inode, struct file *file)
 {
-	struct clip_seq_state *state;
-	struct seq_file *seq;
-	int rc = -EAGAIN;
-
-	state = kzalloc(sizeof(*state), GFP_KERNEL);
-	if (!state) {
-		rc = -ENOMEM;
-		goto out_kfree;
-	}
-	state->ns.neigh_sub_iter = clip_seq_sub_iter;
-
-	rc = seq_open(file, &arp_seq_ops);
-	if (rc)
-		goto out_kfree;
-
-	seq = file->private_data;
-	seq->private = state;
-	state->ns.net = get_proc_net(inode);
-	if (!state->ns.net) {
-		seq_release_private(inode, file);
-		rc = -ENXIO;
-	}
-out:
-	return rc;
-
-out_kfree:
-	kfree(state);
-	goto out;
-}
-
-static int arp_seq_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq = file->private_data;
-	struct clip_seq_state *state = seq->private;
-	put_net(state->ns.net);
-	return seq_release_private(inode, file);
+	return seq_open_net(inode, file, &arp_seq_ops,
+			    sizeof(struct clip_seq_state));
 }
 
 static const struct file_operations arp_seq_fops = {
 	.open		= arp_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= arp_seq_release,
+	.release	= seq_release_net,
 	.owner		= THIS_MODULE
 };
 #endif
