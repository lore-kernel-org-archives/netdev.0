From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 2/2] netns: igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Fri, 19 Dec 2008 15:25:07 +0100
Message-ID: <20081219142508.685066728@theryb.frec.bull.fr>
References: <20081219142505.469589973@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33757 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbYLSO1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:27:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the followinf proc entries per-netns:
/proc/net/igmp
/proc/net/mcfilter

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/igmp.c |   49 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index f92733e..9eb6219 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2275,6 +2275,7 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 
 #if defined(CONFIG_PROC_FS)
 struct igmp_mc_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct in_device *in_dev;
 };
@@ -2283,11 +2284,12 @@ struct igmp_mc_iter_state {
 
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
@@ -2408,7 +2410,7 @@ static const struct seq_operations igmp_mc_seq_ops = {
 
 static int igmp_mc_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mc_seq_ops,
+	return seq_open_net(inode, file, &igmp_mc_seq_ops,
 			sizeof(struct igmp_mc_iter_state));
 }
 
@@ -2417,10 +2419,11 @@ static const struct file_operations igmp_mc_seq_fops = {
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
@@ -2430,13 +2433,14 @@ struct igmp_mcf_iter_state {
 
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
@@ -2567,7 +2571,7 @@ static const struct seq_operations igmp_mcf_seq_ops = {
 
 static int igmp_mcf_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mcf_seq_ops,
+	return seq_open_net(inode, file, &igmp_mcf_seq_ops,
 			sizeof(struct igmp_mcf_iter_state));
 }
 
@@ -2576,14 +2580,41 @@ static const struct file_operations igmp_mcf_seq_fops = {
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
 

