From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 43/51] netfilter: ipt_ULOG: add net namespace support for ipt_ULOG
Date: Sat,  6 Apr 2013 14:17:42 +0200
Message-ID: <1365250670-14993-44-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Add pernet support to ipt_ULOG by means of the new nf_log_set
function added in (30e0c6a netfilter: nf_log: prepare net
namespace support for loggers).

This patch also make ulog_buffers and netlink socket
nflognl per netns.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_ULOG.c |  129 ++++++++++++++++++++++++++++-------------
 1 file changed, 89 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 7d168dc..642ecfb 100644
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
@@ -78,15 +79,23 @@ typedef struct {
 	struct timer_list timer;	/* the timer function */
 } ulog_buff_t;
 
-static ulog_buff_t ulog_buffers[ULOG_MAXNLGROUPS];	/* array of buffers */
+static int ulog_net_id __read_mostly;
+struct ulog_net {
+	unsigned int nlgroup[ULOG_MAXNLGROUPS];
+	ulog_buff_t ulog_buffers[ULOG_MAXNLGROUPS];
+	struct sock *nflognl;
+	spinlock_t lock;
+};
 
-static struct sock *nflognl;		/* our socket */
-static DEFINE_SPINLOCK(ulog_lock);	/* spinlock */
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
 
 	pr_debug("ulog_send: timer is deleting\n");
 	del_timer(&ub->timer);
@@ -103,7 +112,8 @@ static void ulog_send(unsigned int nlgroupnum)
 	NETLINK_CB(ub->skb).dst_group = nlgroupnum + 1;
 	pr_debug("throwing %d packets to netlink group %u\n",
 		 ub->qlen, nlgroupnum + 1);
-	netlink_broadcast(nflognl, ub->skb, 0, nlgroupnum + 1, GFP_ATOMIC);
+	netlink_broadcast(ulog->nflognl, ub->skb, 0, nlgroupnum + 1,
+			  GFP_ATOMIC);
 
 	ub->qlen = 0;
 	ub->skb = NULL;
@@ -114,13 +124,16 @@ static void ulog_send(unsigned int nlgroupnum)
 /* timer function to flush queue in flushtimeout time */
 static void ulog_timer(unsigned long data)
 {
+	struct ulog_net *ulog = container_of((void *)data,
+					     struct ulog_net,
+					     nlgroup[*(unsigned int *)data]);
 	pr_debug("timer function called, calling ulog_send\n");
 
 	/* lock to protect against somebody modifying our structure
 	 * from ipt_ulog_target at the same time */
-	spin_lock_bh(&ulog_lock);
-	ulog_send(data);
-	spin_unlock_bh(&ulog_lock);
+	spin_lock_bh(&ulog->lock);
+	ulog_send(ulog, data);
+	spin_unlock_bh(&ulog->lock);
 }
 
 static struct sk_buff *ulog_alloc_skb(unsigned int size)
@@ -160,6 +173,8 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
 	struct timeval tv;
+	struct net *net = dev_net(in ? in : out);
+	struct ulog_net *ulog = ulog_pernet(net);
 
 	/* ffs == find first bit set, necessary because userspace
 	 * is already shifting groupnumber, but we need unshifted.
@@ -174,9 +189,9 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
 
-	ub = &ulog_buffers[groupnum];
+	ub = &ulog->ulog_buffers[groupnum];
 
-	spin_lock_bh(&ulog_lock);
+	spin_lock_bh(&ulog->lock);
 
 	if (!ub->skb) {
 		if (!(ub->skb = ulog_alloc_skb(size)))
@@ -186,7 +201,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 		/* either the queue len is too high or we don't have
 		 * enough room in nlskb left. send it to userspace. */
 
-		ulog_send(groupnum);
+		ulog_send(ulog, groupnum);
 
 		if (!(ub->skb = ulog_alloc_skb(size)))
 			goto alloc_failure;
@@ -260,16 +275,16 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	if (ub->qlen >= loginfo->qthreshold) {
 		if (loginfo->qthreshold > 1)
 			nlh->nlmsg_type = NLMSG_DONE;
-		ulog_send(groupnum);
+		ulog_send(ulog, groupnum);
 	}
 out_unlock:
-	spin_unlock_bh(&ulog_lock);
+	spin_unlock_bh(&ulog->lock);
 
 	return;
 
 alloc_failure:
 	pr_debug("Error building netlink message\n");
-	spin_unlock_bh(&ulog_lock);
+	spin_unlock_bh(&ulog->lock);
 }
 
 static unsigned int
@@ -376,54 +391,43 @@ static struct nf_logger ipt_ulog_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static int __init ulog_tg_init(void)
+static int __net_init ulog_tg_net_init(struct net *net)
 {
-	int ret, i;
+	int i;
+	struct ulog_net *ulog = ulog_pernet(net);
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
+	spin_lock_init(&ulog->lock);
 	/* initialize ulog_buffers */
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++)
-		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
+		setup_timer(&ulog->ulog_buffers[i].timer, ulog_timer, i);
 
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
+		nf_log_set(net, NFPROTO_IPV4, &ipt_ulog_logger);
 
 	return 0;
 }
 
-static void __exit ulog_tg_exit(void)
+static void __net_exit ulog_tg_net_exit(struct net *net)
 {
 	ulog_buff_t *ub;
 	int i;
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
 		pr_debug("timer is deleting\n");
 		del_timer(&ub->timer);
 
@@ -434,5 +438,50 @@ static void __exit ulog_tg_exit(void)
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
+
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
1.7.10.4

