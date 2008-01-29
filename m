From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: sch_ingress: remove netfilter support
Date: Tue, 29 Jan 2008 16:28:11 +0100
Message-ID: <479F460B.2060104@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030509070602070004020605"
Cc: jamal <hadi@cyberus.ca>, Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57451 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbYA2P2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 10:28:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030509070602070004020605
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------030509070602070004020605
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 3b27667029825ba16f8509fb119bca1b445a3dc9
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jan 28 13:57:56 2008 +0100

    [NET_SCHED]: sch_ingress: remove netfilter support
    
    Since the old policer code is gone, TC actions are needed for policing.
    The ingress qdisc can get packets directly from netif_receive_skb()
    in case TC actions are enabled or through netfilter otherwise, but
    since without TC actions there is no policer the only thing it actually
    does is count packets.
    
    Remove the netfilter support and always require TC actions.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 87af7c9..7d4085a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -198,7 +198,7 @@ config NET_SCH_NETEM
 
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
-	depends on NET_CLS_ACT || NETFILTER
+	depends on NET_CLS_ACT
 	---help---
 	  Say Y here if you want to use classifiers for incoming packets.
 	  If unsure, say Y.
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 3f72d52..274b1dd 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -12,18 +12,10 @@
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/netfilter_ipv6.h>
-#include <linux/netfilter.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 
-/* Thanks to Doron Oz for this hack */
-#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
-static int nf_registered;
-#endif
-
 struct ingress_qdisc_data {
 	struct tcf_proto	*filter_list;
 };
@@ -84,11 +76,6 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	result = tc_classify(skb, p->filter_list, &res);
 
-	/*
-	 * Unlike normal "enqueue" functions, ingress_enqueue returns a
-	 * firewall FW_* code.
-	 */
-#ifdef CONFIG_NET_CLS_ACT
 	sch->bstats.packets++;
 	sch->bstats.bytes += skb->len;
 	switch (result) {
@@ -107,71 +94,10 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		result = TC_ACT_OK;
 		break;
 	}
-#else
-	result = NF_ACCEPT;
-	sch->bstats.packets++;
-	sch->bstats.bytes += skb->len;
-#endif
 
 	return result;
 }
 
-#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
-static unsigned int ing_hook(unsigned int hook, struct sk_buff *skb,
-			     const struct net_device *indev,
-			     const struct net_device *outdev,
-			     int (*okfn)(struct sk_buff *))
-{
-
-	struct Qdisc *q;
-	struct net_device *dev = skb->dev;
-	int fwres = NF_ACCEPT;
-
-	if (dev->qdisc_ingress) {
-		spin_lock(&dev->ingress_lock);
-		if ((q = dev->qdisc_ingress) != NULL)
-			fwres = q->enqueue(skb, q);
-		spin_unlock(&dev->ingress_lock);
-	}
-
-	return fwres;
-}
-
-/* after ipt_filter */
-static struct nf_hook_ops ing_ops[] __read_mostly = {
-	{
-		.hook           = ing_hook,
-		.owner		= THIS_MODULE,
-		.pf             = PF_INET,
-		.hooknum        = NF_INET_PRE_ROUTING,
-		.priority       = NF_IP_PRI_FILTER + 1,
-	},
-	{
-		.hook           = ing_hook,
-		.owner		= THIS_MODULE,
-		.pf             = PF_INET6,
-		.hooknum        = NF_INET_PRE_ROUTING,
-		.priority       = NF_IP6_PRI_FILTER + 1,
-	},
-};
-#endif
-
-static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
-{
-#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
-	printk("Ingress scheduler: Classifier actions prefered over netfilter\n");
-
-	if (!nf_registered) {
-		if (nf_register_hooks(ing_ops, ARRAY_SIZE(ing_ops)) < 0) {
-			printk("ingress qdisc registration error \n");
-			return -EINVAL;
-		}
-		nf_registered++;
-	}
-#endif
-	return 0;
-}
-
 /* ------------------------------------------------------------- */
 
 static void ingress_destroy(struct Qdisc *sch)
@@ -213,7 +139,6 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
 	.enqueue	=	ingress_enqueue,
-	.init		=	ingress_init,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
 	.owner		=	THIS_MODULE,
@@ -227,10 +152,6 @@ static int __init ingress_module_init(void)
 static void __exit ingress_module_exit(void)
 {
 	unregister_qdisc(&ingress_qdisc_ops);
-#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
-	if (nf_registered)
-		nf_unregister_hooks(ing_ops, ARRAY_SIZE(ing_ops));
-#endif
 }
 
 module_init(ingress_module_init)

--------------030509070602070004020605--
