From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Teach the igmp code to handle multiple namespaces
Date: Fri, 11 Jul 2008 13:31:31 -0700
Message-ID: <m1zloocgd8.fsf@frodo.ebiederm.org>
References: <m1od54dwar.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@openvz.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48852 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758953AbYGKUcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 16:32:04 -0400
In-Reply-To: <m1od54dwar.fsf@frodo.ebiederm.org> (Eric W. Biederman's message
	of "Fri, 11 Jul 2008 13:02:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It turns out that I actually need working multicast reception in my
test environment, not something that just the something that doesn't
crash when a multicast packet comes in.

So on top of my previous patch that kept the kernel from crashing
when multicast frames come it.  Actual support for receiving multicast
data in a network namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

---
 net/ipv4/igmp.c |  118 +++++++++++++++++++++++++-----------------------------
 1 files changed, 55 insertions(+), 63 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1ee5a7c..417bc06 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -289,6 +289,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	struct rtable *rt;
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
+	struct net *net = dev_net(dev);
 
 	skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
@@ -299,7 +300,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 				    .nl_u = { .ip4_u = {
 				    .daddr = IGMPV3_ALL_MCR } },
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		if (ip_route_output_key(net, &rt, &fl)) {
 			kfree_skb(skb);
 			return NULL;
 		}
@@ -629,6 +630,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	struct igmphdr *ih;
 	struct rtable *rt;
 	struct net_device *dev = in_dev->dev;
+	struct net *net = dev_net(dev);
 	__be32	group = pmc ? pmc->multiaddr : 0;
 	__be32	dst;
 
@@ -643,7 +645,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		struct flowi fl = { .oif = dev->ifindex,
 				    .nl_u = { .ip4_u = { .daddr = dst } },
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(&init_net, &rt, &fl))
+		if (ip_route_output_key(net, &rt, &fl))
 			return -1;
 	}
 	if (rt->rt_src == 0) {
@@ -1196,9 +1198,6 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	for (im=in_dev->mc_list; im; im=im->next) {
 		if (im->multiaddr == addr) {
 			im->users++;
@@ -1278,9 +1277,6 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	for (ip=&in_dev->mc_list; (i=*ip)!=NULL; ip=&i->next) {
 		if (i->multiaddr==addr) {
 			if (--i->users == 0) {
@@ -1308,9 +1304,6 @@ void ip_mc_down(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	for (i=in_dev->mc_list; i; i=i->next)
 		igmp_group_dropped(i);
 
@@ -1331,9 +1324,6 @@ void ip_mc_init_dev(struct in_device *in_dev)
 {
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	in_dev->mc_tomb = NULL;
 #ifdef CONFIG_IP_MULTICAST
 	in_dev->mr_gq_running = 0;
@@ -1357,9 +1347,6 @@ void ip_mc_up(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
 	for (i=in_dev->mc_list; i; i=i->next)
@@ -1376,9 +1363,6 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return;
-
 	/* Deactivate timers */
 	ip_mc_down(in_dev);
 
@@ -1395,7 +1379,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 	write_unlock_bh(&in_dev->mc_list_lock);
 }
 
-static struct in_device * ip_mc_find_dev(struct ip_mreqn *imr)
+static struct in_device * ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
 	struct flowi fl = { .nl_u = { .ip4_u =
 				      { .daddr = imr->imr_multiaddr.s_addr } } };
@@ -1404,19 +1388,19 @@ static struct in_device * ip_mc_find_dev(struct ip_mreqn *imr)
 	struct in_device *idev = NULL;
 
 	if (imr->imr_ifindex) {
-		idev = inetdev_by_index(&init_net, imr->imr_ifindex);
+		idev = inetdev_by_index(net, imr->imr_ifindex);
 		if (idev)
 			__in_dev_put(idev);
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
-		dev = ip_dev_find(&init_net, imr->imr_address.s_addr);
+		dev = ip_dev_find(net, imr->imr_address.s_addr);
 		if (!dev)
 			return NULL;
 		dev_put(dev);
 	}
 
-	if (!dev && !ip_route_output_key(&init_net, &rt, &fl)) {
+	if (!dev && !ip_route_output_key(net, &rt, &fl)) {
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
 	}
@@ -1754,18 +1738,16 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	struct ip_mc_socklist *iml=NULL, *i;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	int ifindex;
 	int count = 0;
 
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
 
-	in_dev = ip_mc_find_dev(imr);
+	in_dev = ip_mc_find_dev(net, imr);
 
 	if (!in_dev) {
 		iml = NULL;
@@ -1825,17 +1807,15 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_mc_socklist *iml, **imlp;
 	struct in_device *in_dev;
 	__be32 group = imr->imr_multiaddr.s_addr;
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
-	in_dev = ip_mc_find_dev(imr);
+	in_dev = ip_mc_find_dev(net, imr);
 	ifindex = imr->imr_ifindex;
 	for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
 		if (iml->multi.imr_multiaddr.s_addr != group)
@@ -1872,6 +1852,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev = NULL;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_sf_socklist *psl;
 	int leavegroup = 0;
 	int i, j, rv;
@@ -1879,15 +1860,12 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
 
 	imr.imr_multiaddr.s_addr = mreqs->imr_multiaddr;
 	imr.imr_address.s_addr = mreqs->imr_interface;
 	imr.imr_ifindex = ifindex;
-	in_dev = ip_mc_find_dev(&imr);
+	in_dev = ip_mc_find_dev(net, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2006,6 +1984,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_sf_socklist *newpsl, *psl;
 	int leavegroup = 0;
 
@@ -2015,15 +1994,12 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
 
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = ifindex;
-	in_dev = ip_mc_find_dev(&imr);
+	in_dev = ip_mc_find_dev(net, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2093,20 +2069,18 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_sf_socklist *psl;
 
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
 
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = 0;
-	in_dev = ip_mc_find_dev(&imr);
+	in_dev = ip_mc_find_dev(net, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2163,9 +2137,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
-
 	rtnl_lock();
 
 	err = -EADDRNOTAVAIL;
@@ -2250,15 +2221,12 @@ void ip_mc_drop_socket(struct sock *sk)
 	if (inet->mc_list == NULL)
 		return;
 
-	if (sock_net(sk) != &init_net)
-		return;
-
 	rtnl_lock();
 	while ((iml = inet->mc_list) != NULL) {
 		struct in_device *in_dev;
 		inet->mc_list = iml->next;
 
-		in_dev = inetdev_by_index(&init_net, iml->multi.imr_ifindex);
+		in_dev = inetdev_by_index(sock_net(sk), iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL) {
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
@@ -2275,9 +2243,6 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 	struct ip_sf_list *psf;
 	int rv = 0;
 
-	if (dev_net(in_dev->dev) != &init_net)
-		return rv;
-
 	read_lock(&in_dev->mc_list_lock);
 	for (im=in_dev->mc_list; im; im=im->next) {
 		if (im->multiaddr == mc_addr)
@@ -2306,6 +2271,7 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 
 #if defined(CONFIG_PROC_FS)
 struct igmp_mc_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct in_device *in_dev;
 };
@@ -2316,9 +2282,10 @@ static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 {
 	struct ip_mc_list *im = NULL;
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
+	struct net *net = seq_file_net(seq);
 
 	state->in_dev = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *in_dev;
 		in_dev = in_dev_get(state->dev);
 		if (!in_dev)
@@ -2439,7 +2406,7 @@ static const struct seq_operations igmp_mc_seq_ops = {
 
 static int igmp_mc_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mc_seq_ops,
+	return seq_open_net(inode, file, &igmp_mc_seq_ops,
 			sizeof(struct igmp_mc_iter_state));
 }
 
@@ -2448,10 +2415,11 @@ static const struct file_operations igmp_mc_seq_fops = {
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
@@ -2464,10 +2432,11 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 	struct ip_sf_list *psf = NULL;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
+	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *idev;
 		idev = in_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2598,7 +2567,7 @@ static const struct seq_operations igmp_mcf_seq_ops = {
 
 static int igmp_mcf_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp_mcf_seq_ops,
+	return seq_open_net(inode, file, &igmp_mcf_seq_ops,
 			sizeof(struct igmp_mcf_iter_state));
 }
 
@@ -2607,14 +2576,37 @@ static const struct file_operations igmp_mcf_seq_fops = {
 	.open		=	igmp_mcf_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 
-int __init igmp_mc_proc_init(void)
+static int __net_init igmp_proc_init_net(struct net *net)
 {
-	proc_net_fops_create(&init_net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
-	proc_net_fops_create(&init_net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	if (!proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops))
+		goto out1;
+	if (!proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops))
+		goto out2;
+
 	return 0;
+out2:
+	proc_net_remove(net, "igmp");
+out1:
+	return -ENOMEM;
+}
+
+void __net_exit igmp_proc_exit_net(struct net *net)
+{
+	proc_net_remove(net, "igmp");
+	proc_net_remove(net, "mcfilter");
+}
+
+static struct pernet_operations igmp_net_ops = {
+	.init = igmp_proc_init_net,
+	.exit = igmp_proc_exit_net,
+};
+
+int __init igmp_mc_proc_init(void)
+{
+	return register_pernet_subsys(&igmp_net_ops);
 }
 #endif
 
-- 
1.5.3.rc6.17.g1911

