From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 42/51] netfilter: ebt_ulog: add net namespace support for ebt_ulog
Date: Sat,  6 Apr 2013 14:17:41 +0200
Message-ID: <1365250670-14993-43-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Add pernet support to ebt_ulog by means of the new nf_log_set
function added in (30e0c6a netfilter: nf_log: prepare net
namespace support for loggers).

This patch also make ulog_buffers and netlink socket
ebtulognl per netns.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_ulog.c |  125 +++++++++++++++++++++++++++------------
 1 file changed, 88 insertions(+), 37 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 442b032..0ddd612 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -41,6 +41,7 @@
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_ulog.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netns/generic.h>
 #include <net/sock.h>
 #include "../br_private.h"
 
@@ -62,13 +63,22 @@ typedef struct {
 	spinlock_t lock;		/* the per-queue lock */
 } ebt_ulog_buff_t;
 
-static ebt_ulog_buff_t ulog_buffers[EBT_ULOG_MAXNLGROUPS];
-static struct sock *ebtulognl;
+static int ebt_ulog_net_id __read_mostly;
+struct ebt_ulog_net {
+	unsigned int nlgroup[EBT_ULOG_MAXNLGROUPS];
+	ebt_ulog_buff_t ulog_buffers[EBT_ULOG_MAXNLGROUPS];
+	struct sock *ebtulognl;
+};
+
+static struct ebt_ulog_net *ebt_ulog_pernet(struct net *net)
+{
+	return net_generic(net, ebt_ulog_net_id);
+}
 
 /* send one ulog_buff_t to userspace */
-static void ulog_send(unsigned int nlgroup)
+static void ulog_send(struct ebt_ulog_net *ebt, unsigned int nlgroup)
 {
-	ebt_ulog_buff_t *ub = &ulog_buffers[nlgroup];
+	ebt_ulog_buff_t *ub = &ebt->ulog_buffers[nlgroup];
 
 	del_timer(&ub->timer);
 
@@ -80,7 +90,7 @@ static void ulog_send(unsigned int nlgroup)
 		ub->lastnlh->nlmsg_type = NLMSG_DONE;
 
 	NETLINK_CB(ub->skb).dst_group = nlgroup + 1;
-	netlink_broadcast(ebtulognl, ub->skb, 0, nlgroup + 1, GFP_ATOMIC);
+	netlink_broadcast(ebt->ebtulognl, ub->skb, 0, nlgroup + 1, GFP_ATOMIC);
 
 	ub->qlen = 0;
 	ub->skb = NULL;
@@ -89,10 +99,15 @@ static void ulog_send(unsigned int nlgroup)
 /* timer function to flush queue in flushtimeout time */
 static void ulog_timer(unsigned long data)
 {
-	spin_lock_bh(&ulog_buffers[data].lock);
-	if (ulog_buffers[data].skb)
-		ulog_send(data);
-	spin_unlock_bh(&ulog_buffers[data].lock);
+	struct ebt_ulog_net *ebt = container_of((void *)data,
+						struct ebt_ulog_net,
+						nlgroup[*(unsigned int *)data]);
+
+	ebt_ulog_buff_t *ub = &ebt->ulog_buffers[*(unsigned int *)data];
+	spin_lock_bh(&ub->lock);
+	if (ub->skb)
+		ulog_send(ebt, *(unsigned int *)data);
+	spin_unlock_bh(&ub->lock);
 }
 
 static struct sk_buff *ulog_alloc_skb(unsigned int size)
@@ -123,8 +138,10 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	ebt_ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
+	struct net *net = dev_net(in ? in : out);
+	struct ebt_ulog_net *ebt = ebt_ulog_pernet(net);
 	unsigned int group = uloginfo->nlgroup;
-	ebt_ulog_buff_t *ub = &ulog_buffers[group];
+	ebt_ulog_buff_t *ub = &ebt->ulog_buffers[group];
 	spinlock_t *lock = &ub->lock;
 	ktime_t kt;
 
@@ -146,7 +163,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 		if (!(ub->skb = ulog_alloc_skb(size)))
 			goto unlock;
 	} else if (size > skb_tailroom(ub->skb)) {
-		ulog_send(group);
+		ulog_send(ebt, group);
 
 		if (!(ub->skb = ulog_alloc_skb(size)))
 			goto unlock;
@@ -205,7 +222,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	ub->lastnlh = nlh;
 
 	if (ub->qlen >= uloginfo->qthreshold)
-		ulog_send(group);
+		ulog_send(ebt, group);
 	else if (!timer_pending(&ub->timer)) {
 		ub->timer.expires = jiffies + flushtimeout * HZ / 100;
 		add_timer(&ub->timer);
@@ -277,47 +294,39 @@ static struct nf_logger ebt_ulog_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static int __init ebt_ulog_init(void)
+static int __net_init ebt_ulog_net_init(struct net *net)
 {
-	int ret;
 	int i;
+	struct ebt_ulog_net *ebt = ebt_ulog_pernet(net);
+
 	struct netlink_kernel_cfg cfg = {
 		.groups	= EBT_ULOG_MAXNLGROUPS,
 	};
 
-	if (nlbufsiz >= 128*1024) {
-		pr_warning("Netlink buffer has to be <= 128kB,"
-			   " please try a smaller nlbufsiz parameter.\n");
-		return -EINVAL;
-	}
-
 	/* initialize ulog_buffers */
 	for (i = 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
-		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
-		spin_lock_init(&ulog_buffers[i].lock);
+		ebt->nlgroup[i] = i;
+		setup_timer(&ebt->ulog_buffers[i].timer, ulog_timer,
+			    (unsigned long)&ebt->nlgroup[i]);
+		spin_lock_init(&ebt->ulog_buffers[i].lock);
 	}
 
-	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG, &cfg);
-	if (!ebtulognl)
-		ret = -ENOMEM;
-	else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0)
-		netlink_kernel_release(ebtulognl);
+	ebt->ebtulognl = netlink_kernel_create(net, NETLINK_NFLOG, &cfg);
+	if (!ebt->ebtulognl)
+		return -ENOMEM;
 
-	if (ret == 0)
-		nf_log_register(NFPROTO_BRIDGE, &ebt_ulog_logger);
-
-	return ret;
+	nf_log_set(net, NFPROTO_BRIDGE, &ebt_ulog_logger);
+	return 0;
 }
 
-static void __exit ebt_ulog_fini(void)
+static void __net_exit ebt_ulog_net_fini(struct net *net)
 {
-	ebt_ulog_buff_t *ub;
 	int i;
+	struct ebt_ulog_net *ebt = ebt_ulog_pernet(net);
 
-	nf_log_unregister(&ebt_ulog_logger);
-	xt_unregister_target(&ebt_ulog_tg_reg);
+	nf_log_unset(net, &ebt_ulog_logger);
 	for (i = 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
-		ub = &ulog_buffers[i];
+		ebt_ulog_buff_t *ub = &ebt->ulog_buffers[i];
 		del_timer(&ub->timer);
 
 		if (ub->skb) {
@@ -325,7 +334,49 @@ static void __exit ebt_ulog_fini(void)
 			ub->skb = NULL;
 		}
 	}
-	netlink_kernel_release(ebtulognl);
+	netlink_kernel_release(ebt->ebtulognl);
+}
+
+static struct pernet_operations ebt_ulog_net_ops = {
+	.init = ebt_ulog_net_init,
+	.exit = ebt_ulog_net_fini,
+	.id   = &ebt_ulog_net_id,
+	.size = sizeof(struct ebt_ulog_net),
+};
+
+static int __init ebt_ulog_init(void)
+{
+	int ret;
+
+	if (nlbufsiz >= 128*1024) {
+		pr_warn("Netlink buffer has to be <= 128kB,"
+			"please try a smaller nlbufsiz parameter.\n");
+		return -EINVAL;
+	}
+
+	ret = register_pernet_subsys(&ebt_ulog_net_ops);
+	if (ret)
+		goto out_pernet;
+
+	ret = xt_register_target(&ebt_ulog_tg_reg);
+	if (ret)
+		goto out_target;
+
+	nf_log_register(NFPROTO_BRIDGE, &ebt_ulog_logger);
+
+	return 0;
+
+out_target:
+	unregister_pernet_subsys(&ebt_ulog_net_ops);
+out_pernet:
+	return ret;
+}
+
+static void __exit ebt_ulog_fini(void)
+{
+	nf_log_unregister(&ebt_ulog_logger);
+	xt_unregister_target(&ebt_ulog_tg_reg);
+	unregister_pernet_subsys(&ebt_ulog_net_ops);
 }
 
 module_init(ebt_ulog_init);
-- 
1.7.10.4

