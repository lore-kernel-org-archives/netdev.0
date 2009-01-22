From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 8/9] netns: ipmr: declare ipmr /proc/net entries
 per-namespace
Date: Thu, 22 Jan 2009 15:56:22 +0100
Message-ID: <20090122145616.527616793@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59488 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbZAVO63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:58:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare IPv4 multicast forwarding /proc/net entries per-namespace:
/proc/net/ip_mr_vif
/proc/net/ip_mr_cache

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/ipmr.c |  101 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 62 insertions(+), 39 deletions(-)

Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -1671,17 +1671,19 @@ int ipmr_get_route(struct sk_buff *skb, 
  *	The /proc interfaces to multicast routing /proc/ip_mr_cache /proc/ip_mr_vif
  */
 struct ipmr_vif_iter {
+	struct seq_net_private p;
 	int ct;
 };
 
-static struct vif_device *ipmr_vif_seq_idx(struct ipmr_vif_iter *iter,
+static struct vif_device *ipmr_vif_seq_idx(struct net *net,
+					   struct ipmr_vif_iter *iter,
 					   loff_t pos)
 {
-	for (iter->ct = 0; iter->ct < init_net.ipv4.maxvif; ++iter->ct) {
-		if (!VIF_EXISTS(&init_net, iter->ct))
+	for (iter->ct = 0; iter->ct < net->ipv4.maxvif; ++iter->ct) {
+		if (!VIF_EXISTS(net, iter->ct))
 			continue;
 		if (pos-- == 0)
-			return &init_net.ipv4.vif_table[iter->ct];
+			return &net->ipv4.vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1689,23 +1691,26 @@ static struct vif_device *ipmr_vif_seq_i
 static void *ipmr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(mrt_lock)
 {
+	struct net *net = seq_file_net(seq);
+
 	read_lock(&mrt_lock);
-	return *pos ? ipmr_vif_seq_idx(seq->private, *pos - 1)
+	return *pos ? ipmr_vif_seq_idx(net, seq->private, *pos - 1)
 		: SEQ_START_TOKEN;
 }
 
 static void *ipmr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ipmr_vif_iter *iter = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return ipmr_vif_seq_idx(iter, 0);
+		return ipmr_vif_seq_idx(net, iter, 0);
 
-	while (++iter->ct < init_net.ipv4.maxvif) {
-		if (!VIF_EXISTS(&init_net, iter->ct))
+	while (++iter->ct < net->ipv4.maxvif) {
+		if (!VIF_EXISTS(net, iter->ct))
 			continue;
-		return &init_net.ipv4.vif_table[iter->ct];
+		return &net->ipv4.vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1718,6 +1723,8 @@ static void ipmr_vif_seq_stop(struct seq
 
 static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
 			 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote\n");
@@ -1727,7 +1734,7 @@ static int ipmr_vif_seq_show(struct seq_
 
 		seq_printf(seq,
 			   "%2Zd %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
-			   vif - init_net.ipv4.vif_table,
+			   vif - net->ipv4.vif_table,
 			   name, vif->bytes_in, vif->pkt_in,
 			   vif->bytes_out, vif->pkt_out,
 			   vif->flags, vif->local, vif->remote);
@@ -1744,8 +1751,8 @@ static const struct seq_operations ipmr_
 
 static int ipmr_vif_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ipmr_vif_seq_ops,
-			sizeof(struct ipmr_vif_iter));
+	return seq_open_net(inode, file, &ipmr_vif_seq_ops,
+			    sizeof(struct ipmr_vif_iter));
 }
 
 static const struct file_operations ipmr_vif_fops = {
@@ -1753,23 +1760,25 @@ static const struct file_operations ipmr
 	.open    = ipmr_vif_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 struct ipmr_mfc_iter {
+	struct seq_net_private p;
 	struct mfc_cache **cache;
 	int ct;
 };
 
 
-static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
+static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
+					  struct ipmr_mfc_iter *it, loff_t pos)
 {
 	struct mfc_cache *mfc;
 
-	it->cache = init_net.ipv4.mfc_cache_array;
+	it->cache = net->ipv4.mfc_cache_array;
 	read_lock(&mrt_lock);
 	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
-		for (mfc = init_net.ipv4.mfc_cache_array[it->ct];
+		for (mfc = net->ipv4.mfc_cache_array[it->ct];
 		     mfc; mfc = mfc->next)
 			if (pos-- == 0)
 				return mfc;
@@ -1778,7 +1787,8 @@ static struct mfc_cache *ipmr_mfc_seq_id
 	it->cache = &mfc_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
 	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
-		if (pos-- == 0)
+		if (net_eq(mfc_net(mfc), net) &&
+		    pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
 
@@ -1790,9 +1800,11 @@ static struct mfc_cache *ipmr_mfc_seq_id
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ipmr_mfc_iter *it = seq->private;
+	struct net *net = seq_file_net(seq);
+
 	it->cache = NULL;
 	it->ct = 0;
-	return *pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1)
+	return *pos ? ipmr_mfc_seq_idx(net, seq->private, *pos - 1)
 		: SEQ_START_TOKEN;
 }
 
@@ -1800,11 +1812,12 @@ static void *ipmr_mfc_seq_next(struct se
 {
 	struct mfc_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	++*pos;
 
 	if (v == SEQ_START_TOKEN)
-		return ipmr_mfc_seq_idx(seq->private, 0);
+		return ipmr_mfc_seq_idx(net, seq->private, 0);
 
 	if (mfc->next)
 		return mfc->next;
@@ -1812,10 +1825,10 @@ static void *ipmr_mfc_seq_next(struct se
 	if (it->cache == &mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != init_net.ipv4.mfc_cache_array);
+	BUG_ON(it->cache != net->ipv4.mfc_cache_array);
 
 	while (++it->ct < MFC_LINES) {
-		mfc = init_net.ipv4.mfc_cache_array[it->ct];
+		mfc = net->ipv4.mfc_cache_array[it->ct];
 		if (mfc)
 			return mfc;
 	}
@@ -1827,6 +1840,8 @@ static void *ipmr_mfc_seq_next(struct se
 
 	spin_lock_bh(&mfc_unres_lock);
 	mfc = mfc_unres_queue;
+	while (mfc && !net_eq(mfc_net(mfc), net))
+		mfc = mfc->next;
 	if (mfc)
 		return mfc;
 
@@ -1840,16 +1855,18 @@ static void *ipmr_mfc_seq_next(struct se
 static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	if (it->cache == &mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == init_net.ipv4.mfc_cache_array)
+	else if (it->cache == net->ipv4.mfc_cache_array)
 		read_unlock(&mrt_lock);
 }
 
 static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 {
 	int n;
+	struct net *net = seq_file_net(seq);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1870,7 +1887,7 @@ static int ipmr_mfc_seq_show(struct seq_
 				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++ ) {
-				if (VIF_EXISTS(&init_net, n) &&
+				if (VIF_EXISTS(net, n) &&
 				    mfc->mfc_un.res.ttls[n] < 255)
 					seq_printf(seq,
 					   " %2d:%-3d",
@@ -1896,8 +1913,8 @@ static const struct seq_operations ipmr_
 
 static int ipmr_mfc_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ipmr_mfc_seq_ops,
-			sizeof(struct ipmr_mfc_iter));
+	return seq_open_net(inode, file, &ipmr_mfc_seq_ops,
+			    sizeof(struct ipmr_mfc_iter));
 }
 
 static const struct file_operations ipmr_mfc_fops = {
@@ -1905,7 +1922,7 @@ static const struct file_operations ipmr
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 #endif
 
@@ -1942,8 +1959,22 @@ static int __net_init ipmr_net_init(stru
 #ifdef CONFIG_IP_PIMSM
 	net->ipv4.mroute_reg_vif_num = -1;
 #endif
+
+#ifdef CONFIG_PROC_FS
+	err = -ENOMEM;
+	if (!proc_net_fops_create(net, "ip_mr_vif", 0, &ipmr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(net, "ip_mr_cache", 0, &ipmr_mfc_fops))
+		goto proc_cache_fail;
+#endif
 	return 0;
 
+#ifdef CONFIG_PROC_FS
+proc_cache_fail:
+	proc_net_remove(net, "ip_mr_vif");
+proc_vif_fail:
+	kfree(net->ipv4.mfc_cache_array);
+#endif
 fail_mfc_cache:
 	kfree(net->ipv4.vif_table);
 fail:
@@ -1952,6 +1983,10 @@ fail:
 
 static void __net_exit ipmr_net_exit(struct net *net)
 {
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(net, "ip_mr_cache");
+	proc_net_remove(net, "ip_mr_vif");
+#endif
 	kfree(net->ipv4.mfc_cache_array);
 	kfree(net->ipv4.vif_table);
 }
@@ -1980,20 +2015,8 @@ int __init ip_mr_init(void)
 	err = register_netdevice_notifier(&ip_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
-#ifdef CONFIG_PROC_FS
-	err = -ENOMEM;
-	if (!proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops))
-		goto proc_vif_fail;
-	if (!proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops))
-		goto proc_cache_fail;
-#endif
 	return 0;
-#ifdef CONFIG_PROC_FS
-proc_cache_fail:
-	proc_net_remove(&init_net, "ip_mr_vif");
-proc_vif_fail:
-	unregister_netdevice_notifier(&ip_mr_notifier);
-#endif
+
 reg_notif_fail:
 	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ipmr_net_ops);

