From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 26/29] net: vrf: Change single_open_net to pass net_ctx
Date: Wed,  4 Feb 2015 18:34:27 -0700
Message-ID: <1423100070-31848-27-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34804 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756386AbbBEBgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:16 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so6721454iec.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:15 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 fs/proc/proc_net.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 4996f5e91a90..3745661b5370 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -56,6 +56,8 @@ int seq_open_net(struct inode *ino, struct file *f,
 #ifdef CONFIG_NET_NS
 	p->net_ctx.net = net;
 #endif
+	p->net_ctx.vrf = current->vrf;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(seq_open_net);
@@ -65,19 +67,32 @@ int single_open_net(struct inode *inode, struct file *file,
 {
 	int err;
 	struct net *net;
+	struct seq_net_private *p;
 
 	err = -ENXIO;
 	net = get_proc_net(inode);
 	if (net == NULL)
 		goto err_net;
 
-	err = single_open(file, show, net);
+	err = -ENOMEM;
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (p == NULL)
+		goto err_malloc;
+
+#ifdef CONFIG_NET_NS
+	p->net_ctx.net = net;
+#endif
+	p->net_ctx.vrf = current->vrf;
+
+	err = single_open(file, show, p);
 	if (err < 0)
 		goto err_open;
 
 	return 0;
 
 err_open:
+	kfree(p);
+err_malloc:
 	put_net(net);
 err_net:
 	return err;
@@ -99,7 +114,8 @@ EXPORT_SYMBOL_GPL(seq_release_net);
 int single_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq = f->private_data;
-	put_net(seq->private);
+	put_net(seq_file_net(seq));
+	kfree(seq->private);
 	return single_release(ino, f);
 }
 EXPORT_SYMBOL_GPL(single_release_net);
-- 
1.9.3 (Apple Git-50)
