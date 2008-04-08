From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/6 net-2.6.26] [TCP]: Cleanup /proc/tcp[6] creation/removal.
Date: Tue,  8 Apr 2008 17:34:27 +0400
Message-ID: <1207661669-13667-4-git-send-email-den@openvz.org>
References: <1207661633.7171.25.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24684 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbYDHNeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:34:08 -0400
In-Reply-To: <1207661633.7171.25.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace seq_open with seq_open_net and remove tcp_seq_release
completely.  seq_release_net will do this job just fine.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |   41 +++++++----------------------------------
 1 files changed, 7 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0d0e220..287af10 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2212,46 +2212,19 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 static int tcp_seq_open(struct inode *inode, struct file *file)
 {
 	struct tcp_seq_afinfo *afinfo = PDE(inode)->data;
-	struct seq_file *seq;
 	struct tcp_iter_state *s;
-	struct net *net;
-	int rc;
+	int err;
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
 
-	s = kzalloc(sizeof(*s), GFP_KERNEL);
-	if (!s)
-		return -ENOMEM;
-
-	rc = -ENXIO;
-	net = get_proc_net(inode);
-	if (!net)
-		goto out_kfree;
+	err = seq_open_net(inode, file, &afinfo->seq_ops,
+			  sizeof(struct tcp_iter_state));
+	if (err < 0)
+		return err;
 
+	s = ((struct seq_file *)file->private_data)->private;
 	s->family		= afinfo->family;
-	s->p.net                = net;
-
-	rc = seq_open(file, &afinfo->seq_ops);
-	if (rc)
-		goto out_put_net;
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
-static int tcp_seq_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq = file->private_data;
-
-	put_net(seq_file_net(seq));
-	seq_release_private(inode, file);
 	return 0;
 }
 
@@ -2264,7 +2237,7 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	afinfo->seq_fops->open		= tcp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
 	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= tcp_seq_release;
+	afinfo->seq_fops->release	= seq_release_net;
 
 	afinfo->seq_ops.start		= tcp_seq_start;
 	afinfo->seq_ops.next		= tcp_seq_next;
-- 
1.5.3.rc5

