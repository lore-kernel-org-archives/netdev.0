From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/6 net-2.6.26] [UDP]: Cleanup /proc/udp[6] creation/removal.
Date: Thu, 27 Mar 2008 17:11:36 +0300
Message-ID: <1206627098-2456-4-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43332 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace seq_open with seq_open_net and remove udp_seq_release completely.
seq_release_net will do this job just fine.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/udp.c |   46 +++++++++-------------------------------------
 1 files changed, 9 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 43920f1..1b1f299 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1579,46 +1579,18 @@ static void udp_seq_stop(struct seq_file *seq, void *v)
 static int udp_seq_open(struct inode *inode, struct file *file)
 {
 	struct udp_seq_afinfo *afinfo = PDE(inode)->data;
-	struct seq_file *seq;
-	struct net *net;
-	int rc = -ENOMEM;
-	struct udp_iter_state *s = kzalloc(sizeof(*s), GFP_KERNEL);
-
-	if (!s)
-		goto out;
+	struct udp_iter_state *s;
+	int err;
 
-	rc = -ENXIO;
-	net = get_proc_net(inode);
-	if (!net)
-		goto out_kfree;
+	err = seq_open_net(inode, file, &afinfo->seq_ops,
+			   sizeof(struct udp_iter_state));
+	if (err < 0)
+		return err;
 
+	s = ((struct seq_file *)file->private_data)->private;
 	s->family		= afinfo->family;
 	s->hashtable		= afinfo->hashtable;
-	s->p.net                = net;
-
-	rc = seq_open(file, &afinfo->seq_ops);
-	if (rc)
-		goto out_put_net;
-
-	seq = file->private_data;
-	seq->private = s;
-out:
-	return rc;
-out_put_net:
-	put_net(net);
-out_kfree:
-	kfree(s);
-	goto out;
-}
-
-static int udp_seq_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq = file->private_data;
-	struct udp_iter_state *s = seq->private;
-
-	put_net(s->p.net);
-	seq_release_private(inode, file);
-	return 0;
+	return err;
 }
 
 /* ------------------------------------------------------------------------ */
@@ -1631,7 +1603,7 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	afinfo->seq_fops->open		= udp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
 	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= udp_seq_release;
+	afinfo->seq_fops->release	= seq_release_net;
 
 	afinfo->seq_ops.start		= udp_seq_start;
 	afinfo->seq_ops.next		= udp_seq_next;
-- 
1.5.3.rc5

