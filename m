From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Mon, 8 Sep 2008 04:35:39 +0400
Message-ID: <20080908003539.GA575@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containters@lists.osdl.org
To: davem@devemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:19309 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbYIHAdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 20:33:53 -0400
Received: by ug-out-1314.google.com with SMTP id s2so118305uge.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 17:33:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/igmp.c |   49 ++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 40 insertions(+), 9 deletions(-)

--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2272,6 +2272,7 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 
 #if defined(CONFIG_PROC_FS)
 struct igmp_mc_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct in_device *in_dev;
 };
@@ -2280,11 +2281,12 @@ struct igmp_mc_iter_state {
 
 static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 {
+	struct net *net = seq_file_net(seq);
 	struct ip_mc_list *im = NULL;
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 
 	state->in_dev = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *in_dev;
 		in_dev = in_dev_get(state->dev);
 		if (!in_dev)
@@ -2405,7 +2407,7 @@ static const struct seq_operations igmp_mc_seq_ops = {
 
 static int igmp_mc_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mc_seq_ops,
+	return seq_open_net(inode, file, &igmp_mc_seq_ops,
 			sizeof(struct igmp_mc_iter_state));
 }
 
@@ -2414,10 +2416,11 @@ static const struct file_operations igmp_mc_seq_fops = {
 	.open		=	igmp_mc_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 
 struct igmp_mcf_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct in_device *idev;
 	struct ip_mc_list *im;
@@ -2427,13 +2430,14 @@ struct igmp_mcf_iter_state {
 
 static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 {
+	struct net *net = seq_file_net(seq);
 	struct ip_sf_list *psf = NULL;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *idev;
 		idev = in_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2564,7 +2568,7 @@ static const struct seq_operations igmp_mcf_seq_ops = {
 
 static int igmp_mcf_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mcf_seq_ops,
+	return seq_open_net(inode, file, &igmp_mcf_seq_ops,
 			sizeof(struct igmp_mcf_iter_state));
 }
 
@@ -2573,14 +2577,41 @@ static const struct file_operations igmp_mcf_seq_fops = {
 	.open		=	igmp_mcf_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 
-int __init igmp_mc_proc_init(void)
+static int igmp_net_init(struct net *net)
 {
-	proc_net_fops_create(&init_net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
-	proc_net_fops_create(&init_net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	struct proc_dir_entry *pde;
+
+	pde = proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
+	if (!pde)
+		goto out_igmp;
+	pde = proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	if (!pde)
+		goto out_mcfilter;
 	return 0;
+
+out_mcfilter:
+	proc_net_remove(net, "igmp");
+out_igmp:
+	return -ENOMEM;
+}
+
+static void igmp_net_exit(struct net *net)
+{
+	proc_net_remove(net, "mcfilter");
+	proc_net_remove(net, "igmp");
+}
+
+static struct pernet_operations igmp_net_ops = {
+	.init = igmp_net_init,
+	.exit = igmp_net_exit,
+};
+
+int __init igmp_mc_proc_init(void)
+{
+	return register_pernet_subsys(&igmp_net_ops);
 }
 #endif
 

