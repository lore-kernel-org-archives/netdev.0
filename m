From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 7/8] netns: ip6mr: declare ip6mr /proc/net entries
 per-namespace
Date: Mon, 08 Dec 2008 17:02:03 +0100
Message-ID: <20081208160157.992788348@localhost.localdomain>
References: <20081208160156.343758157@localhost.localdomain>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35193 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069AbYLHQEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:04:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare IPv6 multicast forwarding /proc/net entries per-namespace:
/proc/net/ip6_mr_vif
/proc/net/ip6_mr_cache

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6mr.c |  104 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 59 insertions(+), 45 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index b9f03f7..ad540a0 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -91,19 +91,21 @@ static struct timer_list ipmr_expire_timer;
 #ifdef CONFIG_PROC_FS
 
 struct ipmr_mfc_iter {
+	struct seq_net_private p;
 	struct mfc6_cache **cache;
 	int ct;
 };
 
 
-static struct mfc6_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
+static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
+					   struct ipmr_mfc_iter *it, loff_t pos)
 {
 	struct mfc6_cache *mfc;
 
-	it->cache = init_net.ipv6.mfc6_cache_array;
+	it->cache = net->ipv6.mfc6_cache_array;
 	read_lock(&mrt_lock);
 	for (it->ct = 0; it->ct < MFC6_LINES; it->ct++)
-		for (mfc = init_net.ipv6.mfc6_cache_array[it->ct];
+		for (mfc = net->ipv6.mfc6_cache_array[it->ct];
 		     mfc; mfc = mfc->next)
 			if (pos-- == 0)
 				return mfc;
@@ -128,17 +130,19 @@ static struct mfc6_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
  */
 
 struct ipmr_vif_iter {
+	struct seq_net_private p;
 	int ct;
 };
 
-static struct mif_device *ip6mr_vif_seq_idx(struct ipmr_vif_iter *iter,
+static struct mif_device *ip6mr_vif_seq_idx(struct net *net,
+					    struct ipmr_vif_iter *iter,
 					    loff_t pos)
 {
-	for (iter->ct = 0; iter->ct < init_net.ipv6.maxvif; ++iter->ct) {
-		if (!MIF_EXISTS(&init_net, iter->ct))
+	for (iter->ct = 0; iter->ct < net->ipv6.maxvif; ++iter->ct) {
+		if (!MIF_EXISTS(net, iter->ct))
 			continue;
 		if (pos-- == 0)
-			return &init_net.ipv6.vif6_table[iter->ct];
+			return &net->ipv6.vif6_table[iter->ct];
 	}
 	return NULL;
 }
@@ -146,23 +150,26 @@ static struct mif_device *ip6mr_vif_seq_idx(struct ipmr_vif_iter *iter,
 static void *ip6mr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(mrt_lock)
 {
+	struct net *net = seq_file_net(seq);
+
 	read_lock(&mrt_lock);
-	return (*pos ? ip6mr_vif_seq_idx(seq->private, *pos - 1)
-		: SEQ_START_TOKEN);
+	return *pos ? ip6mr_vif_seq_idx(net, seq->private, *pos - 1)
+		: SEQ_START_TOKEN;
 }
 
 static void *ip6mr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ipmr_vif_iter *iter = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return ip6mr_vif_seq_idx(iter, 0);
+		return ip6mr_vif_seq_idx(net, iter, 0);
 
-	while (++iter->ct < init_net.ipv6.maxvif) {
-		if (!MIF_EXISTS(&init_net, iter->ct))
+	while (++iter->ct < net->ipv6.maxvif) {
+		if (!MIF_EXISTS(net, iter->ct))
 			continue;
-		return &init_net.ipv6.vif6_table[iter->ct];
+		return &net->ipv6.vif6_table[iter->ct];
 	}
 	return NULL;
 }
@@ -175,6 +182,8 @@ static void ip6mr_vif_seq_stop(struct seq_file *seq, void *v)
 
 static int ip6mr_vif_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
 			 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags\n");
@@ -184,7 +193,7 @@ static int ip6mr_vif_seq_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq,
 			   "%2td %-10s %8ld %7ld  %8ld %7ld %05X\n",
-			   vif - init_net.ipv6.vif6_table,
+			   vif - net->ipv6.vif6_table,
 			   name, vif->bytes_in, vif->pkt_in,
 			   vif->bytes_out, vif->pkt_out,
 			   vif->flags);
@@ -201,8 +210,8 @@ static struct seq_operations ip6mr_vif_seq_ops = {
 
 static int ip6mr_vif_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ip6mr_vif_seq_ops,
-				sizeof(struct ipmr_vif_iter));
+	return seq_open_net(inode, file, &ip6mr_vif_seq_ops,
+			    sizeof(struct ipmr_vif_iter));
 }
 
 static struct file_operations ip6mr_vif_fops = {
@@ -210,24 +219,27 @@ static struct file_operations ip6mr_vif_fops = {
 	.open    = ip6mr_vif_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	return (*pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1)
-		: SEQ_START_TOKEN);
+	struct net *net = seq_file_net(seq);
+
+	return *pos ? ipmr_mfc_seq_idx(net, seq->private, *pos - 1)
+		: SEQ_START_TOKEN;
 }
 
 static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct mfc6_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	++*pos;
 
 	if (v == SEQ_START_TOKEN)
-		return ipmr_mfc_seq_idx(seq->private, 0);
+		return ipmr_mfc_seq_idx(net, seq->private, 0);
 
 	if (mfc->next)
 		return mfc->next;
@@ -235,10 +247,10 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (it->cache == &mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != init_net.ipv6.mfc6_cache_array);
+	BUG_ON(it->cache != net->ipv6.mfc6_cache_array);
 
 	while (++it->ct < MFC6_LINES) {
-		mfc = init_net.ipv6.mfc6_cache_array[it->ct];
+		mfc = net->ipv6.mfc6_cache_array[it->ct];
 		if (mfc)
 			return mfc;
 	}
@@ -263,16 +275,18 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	if (it->cache == &mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == init_net.ipv6.mfc6_cache_array)
+	else if (it->cache == net->ipv6.mfc6_cache_array)
 		read_unlock(&mrt_lock);
 }
 
 static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 {
 	int n;
+	struct net *net = seq_file_net(seq);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -294,7 +308,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++) {
-				if (MIF_EXISTS(&init_net, n) &&
+				if (MIF_EXISTS(net, n) &&
 				    mfc->mfc_un.res.ttls[n] < 255)
 					seq_printf(seq,
 						   " %2d:%-3d",
@@ -320,8 +334,8 @@ static struct seq_operations ipmr_mfc_seq_ops = {
 
 static int ipmr_mfc_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ipmr_mfc_seq_ops,
-				sizeof(struct ipmr_mfc_iter));
+	return seq_open_net(inode, file, &ipmr_mfc_seq_ops,
+			    sizeof(struct ipmr_mfc_iter));
 }
 
 static struct file_operations ip6mr_mfc_fops = {
@@ -329,7 +343,7 @@ static struct file_operations ip6mr_mfc_fops = {
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 #endif
 
@@ -985,8 +999,22 @@ static int __net_init ip6mr_net_init(struct net *net)
 #ifdef CONFIG_IPV6_PIMSM_V2
 	net->ipv6.mroute_reg_vif_num = -1;
 #endif
+
+#ifdef CONFIG_PROC_FS
+	err = -ENOMEM;
+	if (!proc_net_fops_create(net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(net, "ip6_mr_cache", 0, &ip6mr_mfc_fops))
+		goto proc_cache_fail;
+#endif
 	return 0;
 
+#ifdef CONFIG_PROC_FS
+proc_cache_fail:
+	proc_net_remove(net, "ip6_mr_vif");
+proc_vif_fail:
+	kfree(net->ipv6.mfc6_cache_array);
+#endif
 fail_mfc6_cache:
 	kfree(net->ipv6.vif6_table);
 fail:
@@ -995,6 +1023,10 @@ fail:
 
 static void __net_exit ip6mr_net_exit(struct net *net)
 {
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(net, "ip6_mr_cache");
+	proc_net_remove(net, "ip6_mr_vif");
+#endif
 	kfree(net->ipv6.mfc6_cache_array);
 	kfree(net->ipv6.vif6_table);
 }
@@ -1023,21 +1055,7 @@ int __init ip6_mr_init(void)
 	err = register_netdevice_notifier(&ip6_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
-#ifdef CONFIG_PROC_FS
-	err = -ENOMEM;
-	if (!proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
-		goto proc_vif_fail;
-	if (!proc_net_fops_create(&init_net, "ip6_mr_cache",
-				     0, &ip6mr_mfc_fops))
-		goto proc_cache_fail;
-#endif
 	return 0;
-#ifdef CONFIG_PROC_FS
-proc_cache_fail:
-	proc_net_remove(&init_net, "ip6_mr_vif");
-proc_vif_fail:
-	unregister_netdevice_notifier(&ip6_mr_notifier);
-#endif
 reg_notif_fail:
 	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ip6mr_net_ops);
@@ -1048,10 +1066,6 @@ reg_pernet_fail:
 
 void ip6_mr_cleanup(void)
 {
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "ip6_mr_cache");
-	proc_net_remove(&init_net, "ip6_mr_vif");
-#endif
 	unregister_netdevice_notifier(&ip6_mr_notifier);
 	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ip6mr_net_ops);

