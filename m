From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 06/10] netfilter: ipt_ulog: add net namespace support for ipt_ulog
Date: Thu, 7 Feb 2013 15:49:46 +0800
Message-ID: <1360223390-15589-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, pablo@netfilter.org,
	ebiederm@xmission.com, netdev@vger.kernel.org, lve@guap.ru,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1611 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752502Ab3BGHtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 02:49:32 -0500
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pernet_operations for ipt_ulog, in pernet_ops,
we call nf_log_set/unset to set/unset nf_loggers
of per net.

This patch also make ulog_buffers and netlink socket
nflognl per netns.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/ipt_ULOG.c | 127 +++++++++++++++++++++++++++++-------------
 1 file changed, 88 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 09a03e4..21ff7ef 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -45,6 +45,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ipt_ULOG.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netns/generic.h>
 #include <net/sock.h>
 #include <linux/bitops.h>
 #include <asm/unaligned.h>
@@ -79,14 +80,22 @@ typedef struct {
 	spinlock_t lock;		/* the pre-queue lock */
 } ulog_buff_t;
 
-static ulog_buff_t ulog_buffers[ULOG_MAXNLGROUPS];	/* array of buffers */
+static int ulog_net_id __read_mostly;
+struct ulog_net {
+	unsigned int nlgroup[ULOG_MAXNLGROUPS];
+	ulog_buff_t ulog_buffers[ULOG_MAXNLGROUPS];	/* array of buffers */
+	struct sock *nflognl;		/* our socket */
+};
 
-static struct sock *nflognl;		/* our socket */
+static struct ulog_net *ulog_pernet(struct net *net)
+{
+	return net_generic(net, ulog_net_id);
+}
 
 /* send one ulog_buff_t to userspace */
-static void ulog_send(unsigned int nlgroupnum)
+static void ulog_send(struct ulog_net *ulog, unsigned int nlgroupnum)
 {
-	ulog_buff_t *ub = &ulog_buffers[nlgroupnum];
+	ulog_buff_t *ub = &ulog->ulog_buffers[nlgroupnum];
 
 	if (timer_pending(&ub->timer)) {
 		pr_debug("ulog_send: timer was pending, deleting\n");
@@ -105,7 +114,8 @@ static void ulog_send(unsigned int nlgroupnum)
 	NETLINK_CB(ub->skb).dst_group = nlgroupnum + 1;
 	pr_debug("throwing %d packets to netlink group %u\n",
 		 ub->qlen, nlgroupnum + 1);
-	netlink_broadcast(nflognl, ub->skb, 0, nlgroupnum + 1, GFP_ATOMIC);
+	netlink_broadcast(ulog->nflognl, ub->skb, 0, nlgroupnum + 1,
+			  GFP_ATOMIC);
 
 	ub->qlen = 0;
 	ub->skb = NULL;
@@ -116,13 +126,18 @@ static void ulog_send(unsigned int nlgroupnum)
 /* timer function to flush queue in flushtimeout time */
 static void ulog_timer(unsigned long data)
 {
+	struct ulog_net *ulog = container_of((void *)data,
+					     struct ulog_net,
+					     nlgroup[*(unsigned int *)data]);
+	ulog_buff_t *ub = &ulog->ulog_buffers[*(unsigned int *)data];
+
 	pr_debug("timer function called, calling ulog_send\n");
 
 	/* lock to protect against somebody modifying our structure
 	 * from ipt_ulog_target at the same time */
-	spin_lock_bh(&ulog_buffers[data].lock);
-	ulog_send(data);
-	spin_unlock_bh(&ulog_buffers[data].lock);
+	spin_lock_bh(&ub->lock);
+	ulog_send(ulog, *(unsigned int *)data);
+	spin_unlock_bh(&ub->lock);
 }
 
 static struct sk_buff *ulog_alloc_skb(unsigned int size)
@@ -162,6 +177,8 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
 	struct timeval tv;
+	struct net *net = dev_net((in != NULL) ? in : out);
+	struct ulog_net *ulog = ulog_pernet(net);
 
 	/* ffs == find first bit set, necessary because userspace
 	 * is already shifting groupnumber, but we need unshifted.
@@ -176,7 +193,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
 
-	ub = &ulog_buffers[groupnum];
+	ub = &ulog->ulog_buffers[groupnum];
 
 	spin_lock_bh(&ub->lock);
 
@@ -188,7 +205,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 		/* either the queue len is too high or we don't have
 		 * enough room in nlskb left. send it to userspace. */
 
-		ulog_send(groupnum);
+		ulog_send(ulog, groupnum);
 
 		if (!(ub->skb = ulog_alloc_skb(size)))
 			goto alloc_failure;
@@ -262,7 +279,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	if (ub->qlen >= loginfo->qthreshold) {
 		if (loginfo->qthreshold > 1)
 			nlh->nlmsg_type = NLMSG_DONE;
-		ulog_send(groupnum);
+		ulog_send(ulog, groupnum);
 	}
 out_unlock:
 	spin_unlock_bh(&ub->lock);
@@ -378,56 +395,44 @@ static struct nf_logger ipt_ulog_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static int __init ulog_tg_init(void)
+static int __net_init ulog_tg_net_init(struct net *net)
 {
-	int ret, i;
+	unsigned int i;
+	struct ulog_net *ulog = ulog_pernet(net);
+
 	struct netlink_kernel_cfg cfg = {
 		.groups	= ULOG_MAXNLGROUPS,
 	};
 
-	pr_debug("init module\n");
-
-	if (nlbufsiz > 128*1024) {
-		pr_warning("Netlink buffer has to be <= 128kB\n");
-		return -EINVAL;
-	}
-
 	/* initialize ulog_buffers */
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++) {
-		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
-		spin_lock_init(&ulog_buffers[i].lock);
+		setup_timer(&ulog->ulog_buffers[i].timer, ulog_timer, i);
+		spin_lock_init(&ulog->ulog_buffers[i].lock);
 	}
 
-	nflognl = netlink_kernel_create(&init_net, NETLINK_NFLOG, &cfg);
-	if (!nflognl)
+	ulog->nflognl = netlink_kernel_create(net, NETLINK_NFLOG, &cfg);
+	if (!ulog->nflognl)
 		return -ENOMEM;
 
-	ret = xt_register_target(&ulog_tg_reg);
-	if (ret < 0) {
-		netlink_kernel_release(nflognl);
-		return ret;
-	}
 	if (nflog)
-		nf_log_register(NFPROTO_IPV4, &ipt_ulog_logger);
-
+		nf_log_set(net, NFPROTO_IPV4, &ipt_ulog_logger);
 	return 0;
 }
 
-static void __exit ulog_tg_exit(void)
+static void __net_exit ulog_tg_net_exit(struct net *net)
 {
+	unsigned int i;
 	ulog_buff_t *ub;
-	int i;
-
-	pr_debug("cleanup_module\n");
+	struct ulog_net *ulog = ulog_pernet(net);
 
 	if (nflog)
-		nf_log_unregister(&ipt_ulog_logger);
-	xt_unregister_target(&ulog_tg_reg);
-	netlink_kernel_release(nflognl);
+		nf_log_unset(net, &ipt_ulog_logger);
+
+	netlink_kernel_release(ulog->nflognl);
 
 	/* remove pending timers and free allocated skb's */
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++) {
-		ub = &ulog_buffers[i];
+		ub = &ulog->ulog_buffers[i];
 		if (timer_pending(&ub->timer)) {
 			pr_debug("timer was pending, deleting\n");
 			del_timer(&ub->timer);
@@ -441,5 +446,49 @@ static void __exit ulog_tg_exit(void)
 	}
 }
 
+static struct pernet_operations ulog_tg_net_ops = {
+	.init = ulog_tg_net_init,
+	.exit = ulog_tg_net_exit,
+	.id   = &ulog_net_id,
+	.size = sizeof(struct ulog_net),
+};
+
+static int __init ulog_tg_init(void)
+{
+	int ret;
+	pr_debug("init module\n");
+
+	if (nlbufsiz > 128*1024) {
+		pr_warn("Netlink buffer has to be <= 128kB\n");
+		return -EINVAL;
+	}
+
+	ret = register_pernet_subsys(&ulog_tg_net_ops);
+	if (ret)
+		goto out_pernet;
+
+	ret = xt_register_target(&ulog_tg_reg);
+	if (ret < 0)
+		goto out_target;
+
+	if (nflog)
+		nf_log_register(NFPROTO_IPV4, &ipt_ulog_logger);
+
+	return 0;
+out_target:
+	unregister_pernet_subsys(&ulog_tg_net_ops);
+out_pernet:
+	return ret;
+}
+
+static void __exit ulog_tg_exit(void)
+{
+	pr_debug("cleanup_module\n");
+	if (nflog)
+		nf_log_unregister(&ipt_ulog_logger);
+	xt_unregister_target(&ulog_tg_reg);
+	unregister_pernet_subsys(&ulog_tg_net_ops);
+}
+
 module_init(ulog_tg_init);
 module_exit(ulog_tg_exit);
-- 
1.7.11.7
