From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 15:07:00 +0800
Message-ID: <1366700820-26052-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661Ab3DWHHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 03:07:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

They well deserve a separated unit.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> 
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 net/ipv6/Makefile     |    2 
 net/ipv6/mcast.c      |  370 -----------------------------------------------
 net/ipv6/mcast_proc.c |  386 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 387 insertions(+), 371 deletions(-)

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 309af19..157b5e7 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -19,7 +19,7 @@ ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
-ipv6-$(CONFIG_PROC_FS) += proc.o
+ipv6-$(CONFIG_PROC_FS) += proc.o mcast_proc.o
 ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 
 ipv6-objs += $(ipv6-y)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..821665b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -26,7 +26,6 @@
  *		- MLDv2 support
  */
 
-#include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -41,8 +40,6 @@
 #include <linux/if_arp.h>
 #include <linux/route.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <net/mld.h>
 
@@ -2307,370 +2304,3 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 	write_unlock_bh(&idev->lock);
 }
 
-#ifdef CONFIG_PROC_FS
-struct igmp6_mc_iter_state {
-	struct seq_net_private p;
-	struct net_device *dev;
-	struct inet6_dev *idev;
-};
-
-#define igmp6_mc_seq_private(seq)	((struct igmp6_mc_iter_state *)(seq)->private)
-
-static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
-{
-	struct ifmcaddr6 *im = NULL;
-	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
-	struct net *net = seq_file_net(seq);
-
-	state->idev = NULL;
-	for_each_netdev_rcu(net, state->dev) {
-		struct inet6_dev *idev;
-		idev = __in6_dev_get(state->dev);
-		if (!idev)
-			continue;
-		read_lock_bh(&idev->lock);
-		im = idev->mc_list;
-		if (im) {
-			state->idev = idev;
-			break;
-		}
-		read_unlock_bh(&idev->lock);
-	}
-	return im;
-}
-
-static struct ifmcaddr6 *igmp6_mc_get_next(struct seq_file *seq, struct ifmcaddr6 *im)
-{
-	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
-
-	im = im->next;
-	while (!im) {
-		if (likely(state->idev != NULL))
-			read_unlock_bh(&state->idev->lock);
-
-		state->dev = next_net_device_rcu(state->dev);
-		if (!state->dev) {
-			state->idev = NULL;
-			break;
-		}
-		state->idev = __in6_dev_get(state->dev);
-		if (!state->idev)
-			continue;
-		read_lock_bh(&state->idev->lock);
-		im = state->idev->mc_list;
-	}
-	return im;
-}
-
-static struct ifmcaddr6 *igmp6_mc_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct ifmcaddr6 *im = igmp6_mc_get_first(seq);
-	if (im)
-		while (pos && (im = igmp6_mc_get_next(seq, im)) != NULL)
-			--pos;
-	return pos ? NULL : im;
-}
-
-static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	return igmp6_mc_get_idx(seq, *pos);
-}
-
-static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct ifmcaddr6 *im = igmp6_mc_get_next(seq, v);
-
-	++*pos;
-	return im;
-}
-
-static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
-{
-	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
-
-	if (likely(state->idev != NULL)) {
-		read_unlock_bh(&state->idev->lock);
-		state->idev = NULL;
-	}
-	state->dev = NULL;
-	rcu_read_unlock();
-}
-
-static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
-{
-	struct ifmcaddr6 *im = (struct ifmcaddr6 *)v;
-	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
-
-	seq_printf(seq,
-		   "%-4d %-15s %pi6 %5d %08X %ld\n",
-		   state->dev->ifindex, state->dev->name,
-		   &im->mca_addr,
-		   im->mca_users, im->mca_flags,
-		   (im->mca_flags&MAF_TIMER_RUNNING) ?
-		   jiffies_to_clock_t(im->mca_timer.expires-jiffies) : 0);
-	return 0;
-}
-
-static const struct seq_operations igmp6_mc_seq_ops = {
-	.start	=	igmp6_mc_seq_start,
-	.next	=	igmp6_mc_seq_next,
-	.stop	=	igmp6_mc_seq_stop,
-	.show	=	igmp6_mc_seq_show,
-};
-
-static int igmp6_mc_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &igmp6_mc_seq_ops,
-			    sizeof(struct igmp6_mc_iter_state));
-}
-
-static const struct file_operations igmp6_mc_seq_fops = {
-	.owner		=	THIS_MODULE,
-	.open		=	igmp6_mc_seq_open,
-	.read		=	seq_read,
-	.llseek		=	seq_lseek,
-	.release	=	seq_release_net,
-};
-
-struct igmp6_mcf_iter_state {
-	struct seq_net_private p;
-	struct net_device *dev;
-	struct inet6_dev *idev;
-	struct ifmcaddr6 *im;
-};
-
-#define igmp6_mcf_seq_private(seq)	((struct igmp6_mcf_iter_state *)(seq)->private)
-
-static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
-{
-	struct ip6_sf_list *psf = NULL;
-	struct ifmcaddr6 *im = NULL;
-	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-	struct net *net = seq_file_net(seq);
-
-	state->idev = NULL;
-	state->im = NULL;
-	for_each_netdev_rcu(net, state->dev) {
-		struct inet6_dev *idev;
-		idev = __in6_dev_get(state->dev);
-		if (unlikely(idev == NULL))
-			continue;
-		read_lock_bh(&idev->lock);
-		im = idev->mc_list;
-		if (likely(im != NULL)) {
-			spin_lock_bh(&im->mca_lock);
-			psf = im->mca_sources;
-			if (likely(psf != NULL)) {
-				state->im = im;
-				state->idev = idev;
-				break;
-			}
-			spin_unlock_bh(&im->mca_lock);
-		}
-		read_unlock_bh(&idev->lock);
-	}
-	return psf;
-}
-
-static struct ip6_sf_list *igmp6_mcf_get_next(struct seq_file *seq, struct ip6_sf_list *psf)
-{
-	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-
-	psf = psf->sf_next;
-	while (!psf) {
-		spin_unlock_bh(&state->im->mca_lock);
-		state->im = state->im->next;
-		while (!state->im) {
-			if (likely(state->idev != NULL))
-				read_unlock_bh(&state->idev->lock);
-
-			state->dev = next_net_device_rcu(state->dev);
-			if (!state->dev) {
-				state->idev = NULL;
-				goto out;
-			}
-			state->idev = __in6_dev_get(state->dev);
-			if (!state->idev)
-				continue;
-			read_lock_bh(&state->idev->lock);
-			state->im = state->idev->mc_list;
-		}
-		if (!state->im)
-			break;
-		spin_lock_bh(&state->im->mca_lock);
-		psf = state->im->mca_sources;
-	}
-out:
-	return psf;
-}
-
-static struct ip6_sf_list *igmp6_mcf_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct ip6_sf_list *psf = igmp6_mcf_get_first(seq);
-	if (psf)
-		while (pos && (psf = igmp6_mcf_get_next(seq, psf)) != NULL)
-			--pos;
-	return pos ? NULL : psf;
-}
-
-static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
-}
-
-static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct ip6_sf_list *psf;
-	if (v == SEQ_START_TOKEN)
-		psf = igmp6_mcf_get_first(seq);
-	else
-		psf = igmp6_mcf_get_next(seq, v);
-	++*pos;
-	return psf;
-}
-
-static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
-{
-	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-	if (likely(state->im != NULL)) {
-		spin_unlock_bh(&state->im->mca_lock);
-		state->im = NULL;
-	}
-	if (likely(state->idev != NULL)) {
-		read_unlock_bh(&state->idev->lock);
-		state->idev = NULL;
-	}
-	state->dev = NULL;
-	rcu_read_unlock();
-}
-
-static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
-{
-	struct ip6_sf_list *psf = (struct ip6_sf_list *)v;
-	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-
-	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq,
-			   "%3s %6s "
-			   "%32s %32s %6s %6s\n", "Idx",
-			   "Device", "Multicast Address",
-			   "Source Address", "INC", "EXC");
-	} else {
-		seq_printf(seq,
-			   "%3d %6.6s %pi6 %pi6 %6lu %6lu\n",
-			   state->dev->ifindex, state->dev->name,
-			   &state->im->mca_addr,
-			   &psf->sf_addr,
-			   psf->sf_count[MCAST_INCLUDE],
-			   psf->sf_count[MCAST_EXCLUDE]);
-	}
-	return 0;
-}
-
-static const struct seq_operations igmp6_mcf_seq_ops = {
-	.start	=	igmp6_mcf_seq_start,
-	.next	=	igmp6_mcf_seq_next,
-	.stop	=	igmp6_mcf_seq_stop,
-	.show	=	igmp6_mcf_seq_show,
-};
-
-static int igmp6_mcf_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &igmp6_mcf_seq_ops,
-			    sizeof(struct igmp6_mcf_iter_state));
-}
-
-static const struct file_operations igmp6_mcf_seq_fops = {
-	.owner		=	THIS_MODULE,
-	.open		=	igmp6_mcf_seq_open,
-	.read		=	seq_read,
-	.llseek		=	seq_lseek,
-	.release	=	seq_release_net,
-};
-
-static int __net_init igmp6_proc_init(struct net *net)
-{
-	int err;
-
-	err = -ENOMEM;
-	if (!proc_create("igmp6", S_IRUGO, net->proc_net, &igmp6_mc_seq_fops))
-		goto out;
-	if (!proc_create("mcfilter6", S_IRUGO, net->proc_net,
-			 &igmp6_mcf_seq_fops))
-		goto out_proc_net_igmp6;
-
-	err = 0;
-out:
-	return err;
-
-out_proc_net_igmp6:
-	remove_proc_entry("igmp6", net->proc_net);
-	goto out;
-}
-
-static void __net_exit igmp6_proc_exit(struct net *net)
-{
-	remove_proc_entry("mcfilter6", net->proc_net);
-	remove_proc_entry("igmp6", net->proc_net);
-}
-#else
-static inline int igmp6_proc_init(struct net *net)
-{
-	return 0;
-}
-static inline void igmp6_proc_exit(struct net *net)
-{
-}
-#endif
-
-static int __net_init igmp6_net_init(struct net *net)
-{
-	int err;
-
-	err = inet_ctl_sock_create(&net->ipv6.igmp_sk, PF_INET6,
-				   SOCK_RAW, IPPROTO_ICMPV6, net);
-	if (err < 0) {
-		pr_err("Failed to initialize the IGMP6 control socket (err %d)\n",
-		       err);
-		goto out;
-	}
-
-	inet6_sk(net->ipv6.igmp_sk)->hop_limit = 1;
-
-	err = igmp6_proc_init(net);
-	if (err)
-		goto out_sock_create;
-out:
-	return err;
-
-out_sock_create:
-	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
-	goto out;
-}
-
-static void __net_exit igmp6_net_exit(struct net *net)
-{
-	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
-	igmp6_proc_exit(net);
-}
-
-static struct pernet_operations igmp6_net_ops = {
-	.init = igmp6_net_init,
-	.exit = igmp6_net_exit,
-};
-
-int __init igmp6_init(void)
-{
-	return register_pernet_subsys(&igmp6_net_ops);
-}
-
-void igmp6_cleanup(void)
-{
-	unregister_pernet_subsys(&igmp6_net_ops);
-}
diff --git a/net/ipv6/mcast_proc.c b/net/ipv6/mcast_proc.c
new file mode 100644
index 0000000..887af797
--- /dev/null
+++ b/net/ipv6/mcast_proc.c
@@ -0,0 +1,386 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/jiffies.h>
+#include <linux/times.h>
+#include <linux/net.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/route.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <net/mld.h>
+
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include <net/ipv6.h>
+#include <net/protocol.h>
+#include <net/if_inet6.h>
+#include <net/addrconf.h>
+#include <net/inet_common.h>
+
+struct igmp6_mc_iter_state {
+	struct seq_net_private p;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+};
+
+#define igmp6_mc_seq_private(seq)	((struct igmp6_mc_iter_state *)(seq)->private)
+
+static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
+{
+	struct ifmcaddr6 *im = NULL;
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+	struct net *net = seq_file_net(seq);
+
+	state->idev = NULL;
+	for_each_netdev_rcu(net, state->dev) {
+		struct inet6_dev *idev;
+		idev = __in6_dev_get(state->dev);
+		if (!idev)
+			continue;
+		read_lock_bh(&idev->lock);
+		im = idev->mc_list;
+		if (im) {
+			state->idev = idev;
+			break;
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	return im;
+}
+
+static struct ifmcaddr6 *igmp6_mc_get_next(struct seq_file *seq, struct ifmcaddr6 *im)
+{
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+
+	im = im->next;
+	while (!im) {
+		if (likely(state->idev != NULL))
+			read_unlock_bh(&state->idev->lock);
+
+		state->dev = next_net_device_rcu(state->dev);
+		if (!state->dev) {
+			state->idev = NULL;
+			break;
+		}
+		state->idev = __in6_dev_get(state->dev);
+		if (!state->idev)
+			continue;
+		read_lock_bh(&state->idev->lock);
+		im = state->idev->mc_list;
+	}
+	return im;
+}
+
+static struct ifmcaddr6 *igmp6_mc_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ifmcaddr6 *im = igmp6_mc_get_first(seq);
+	if (im)
+		while (pos && (im = igmp6_mc_get_next(seq, im)) != NULL)
+			--pos;
+	return pos ? NULL : im;
+}
+
+static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
+{
+	rcu_read_lock();
+	return igmp6_mc_get_idx(seq, *pos);
+}
+
+static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ifmcaddr6 *im = igmp6_mc_get_next(seq, v);
+
+	++*pos;
+	return im;
+}
+
+static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
+{
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		state->idev = NULL;
+	}
+	state->dev = NULL;
+	rcu_read_unlock();
+}
+
+static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct ifmcaddr6 *im = (struct ifmcaddr6 *)v;
+	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+
+	seq_printf(seq,
+		   "%-4d %-15s %pi6 %5d %08X %ld\n",
+		   state->dev->ifindex, state->dev->name,
+		   &im->mca_addr,
+		   im->mca_users, im->mca_flags,
+		   (im->mca_flags&MAF_TIMER_RUNNING) ?
+		   jiffies_to_clock_t(im->mca_timer.expires-jiffies) : 0);
+	return 0;
+}
+
+static const struct seq_operations igmp6_mc_seq_ops = {
+	.start	=	igmp6_mc_seq_start,
+	.next	=	igmp6_mc_seq_next,
+	.stop	=	igmp6_mc_seq_stop,
+	.show	=	igmp6_mc_seq_show,
+};
+
+static int igmp6_mc_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &igmp6_mc_seq_ops,
+			    sizeof(struct igmp6_mc_iter_state));
+}
+
+static const struct file_operations igmp6_mc_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp6_mc_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_net,
+};
+
+struct igmp6_mcf_iter_state {
+	struct seq_net_private p;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct ifmcaddr6 *im;
+};
+
+#define igmp6_mcf_seq_private(seq)	((struct igmp6_mcf_iter_state *)(seq)->private)
+
+static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
+{
+	struct ip6_sf_list *psf = NULL;
+	struct ifmcaddr6 *im = NULL;
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+	struct net *net = seq_file_net(seq);
+
+	state->idev = NULL;
+	state->im = NULL;
+	for_each_netdev_rcu(net, state->dev) {
+		struct inet6_dev *idev;
+		idev = __in6_dev_get(state->dev);
+		if (unlikely(idev == NULL))
+			continue;
+		read_lock_bh(&idev->lock);
+		im = idev->mc_list;
+		if (likely(im != NULL)) {
+			spin_lock_bh(&im->mca_lock);
+			psf = im->mca_sources;
+			if (likely(psf != NULL)) {
+				state->im = im;
+				state->idev = idev;
+				break;
+			}
+			spin_unlock_bh(&im->mca_lock);
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	return psf;
+}
+
+static struct ip6_sf_list *igmp6_mcf_get_next(struct seq_file *seq, struct ip6_sf_list *psf)
+{
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
+	psf = psf->sf_next;
+	while (!psf) {
+		spin_unlock_bh(&state->im->mca_lock);
+		state->im = state->im->next;
+		while (!state->im) {
+			if (likely(state->idev != NULL))
+				read_unlock_bh(&state->idev->lock);
+
+			state->dev = next_net_device_rcu(state->dev);
+			if (!state->dev) {
+				state->idev = NULL;
+				goto out;
+			}
+			state->idev = __in6_dev_get(state->dev);
+			if (!state->idev)
+				continue;
+			read_lock_bh(&state->idev->lock);
+			state->im = state->idev->mc_list;
+		}
+		if (!state->im)
+			break;
+		spin_lock_bh(&state->im->mca_lock);
+		psf = state->im->mca_sources;
+	}
+out:
+	return psf;
+}
+
+static struct ip6_sf_list *igmp6_mcf_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct ip6_sf_list *psf = igmp6_mcf_get_first(seq);
+	if (psf)
+		while (pos && (psf = igmp6_mcf_get_next(seq, psf)) != NULL)
+			--pos;
+	return pos ? NULL : psf;
+}
+
+static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
+{
+	rcu_read_lock();
+	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip6_sf_list *psf;
+	if (v == SEQ_START_TOKEN)
+		psf = igmp6_mcf_get_first(seq);
+	else
+		psf = igmp6_mcf_get_next(seq, v);
+	++*pos;
+	return psf;
+}
+
+static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
+{
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+	if (likely(state->im != NULL)) {
+		spin_unlock_bh(&state->im->mca_lock);
+		state->im = NULL;
+	}
+	if (likely(state->idev != NULL)) {
+		read_unlock_bh(&state->idev->lock);
+		state->idev = NULL;
+	}
+	state->dev = NULL;
+	rcu_read_unlock();
+}
+
+static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
+{
+	struct ip6_sf_list *psf = (struct ip6_sf_list *)v;
+	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq,
+			   "%3s %6s "
+			   "%32s %32s %6s %6s\n", "Idx",
+			   "Device", "Multicast Address",
+			   "Source Address", "INC", "EXC");
+	} else {
+		seq_printf(seq,
+			   "%3d %6.6s %pi6 %pi6 %6lu %6lu\n",
+			   state->dev->ifindex, state->dev->name,
+			   &state->im->mca_addr,
+			   &psf->sf_addr,
+			   psf->sf_count[MCAST_INCLUDE],
+			   psf->sf_count[MCAST_EXCLUDE]);
+	}
+	return 0;
+}
+
+static const struct seq_operations igmp6_mcf_seq_ops = {
+	.start	=	igmp6_mcf_seq_start,
+	.next	=	igmp6_mcf_seq_next,
+	.stop	=	igmp6_mcf_seq_stop,
+	.show	=	igmp6_mcf_seq_show,
+};
+
+static int igmp6_mcf_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &igmp6_mcf_seq_ops,
+			    sizeof(struct igmp6_mcf_iter_state));
+}
+
+static const struct file_operations igmp6_mcf_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	igmp6_mcf_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release_net,
+};
+
+static int __net_init igmp6_proc_init(struct net *net)
+{
+	int err;
+
+	err = -ENOMEM;
+	if (!proc_create("igmp6", S_IRUGO, net->proc_net, &igmp6_mc_seq_fops))
+		goto out;
+	if (!proc_create("mcfilter6", S_IRUGO, net->proc_net,
+			 &igmp6_mcf_seq_fops))
+		goto out_proc_net_igmp6;
+
+	err = 0;
+out:
+	return err;
+
+out_proc_net_igmp6:
+	remove_proc_entry("igmp6", net->proc_net);
+	goto out;
+}
+
+static void __net_exit igmp6_proc_exit(struct net *net)
+{
+	remove_proc_entry("mcfilter6", net->proc_net);
+	remove_proc_entry("igmp6", net->proc_net);
+}
+
+static int __net_init igmp6_net_init(struct net *net)
+{
+	int err;
+
+	err = inet_ctl_sock_create(&net->ipv6.igmp_sk, PF_INET6,
+				   SOCK_RAW, IPPROTO_ICMPV6, net);
+	if (err < 0) {
+		pr_err("Failed to initialize the IGMP6 control socket (err %d)\n",
+		       err);
+		goto out;
+	}
+
+	inet6_sk(net->ipv6.igmp_sk)->hop_limit = 1;
+
+	err = igmp6_proc_init(net);
+	if (err)
+		goto out_sock_create;
+out:
+	return err;
+
+out_sock_create:
+	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
+	goto out;
+}
+
+static void __net_exit igmp6_net_exit(struct net *net)
+{
+	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
+	igmp6_proc_exit(net);
+}
+
+static struct pernet_operations igmp6_net_ops = {
+	.init = igmp6_net_init,
+	.exit = igmp6_net_exit,
+};
+
+int __init igmp6_init(void)
+{
+	return register_pernet_subsys(&igmp6_net_ops);
+}
+
+void igmp6_cleanup(void)
+{
+	unregister_pernet_subsys(&igmp6_net_ops);
+}
