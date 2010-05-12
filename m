From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] net sched: printk message severity
Date: Wed, 12 May 2010 09:37:05 -0700
Message-ID: <20100512163719.414013223@vyatta.com>
References: <20100512163704.780058547@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36016 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470Ab0ELQlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 12:41:11 -0400
Content-Disposition: inline; filename=sched-message.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous patch encourage me to go look at all the messages in
the network scheduler and fix them. Many messages were missing
any severity level. Some serious ones that should never happen
were turned into WARN(), and the random noise messages that were
handled changed to pr_debug().

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/sched/act_api.c    |   20 +++++++++++---------
 net/sched/act_gact.c   |    4 ++--
 net/sched/act_ipt.c    |    3 ++-
 net/sched/act_mirred.c |    6 +++---
 net/sched/act_pedit.c  |   11 ++++++-----
 net/sched/act_simple.c |    4 ++--
 net/sched/cls_u32.c    |   10 +++++-----
 net/sched/ematch.c     |    3 ++-
 8 files changed, 33 insertions(+), 28 deletions(-)

--- a/net/sched/act_api.c	2010-05-11 17:59:27.089343653 -0700
+++ b/net/sched/act_api.c	2010-05-11 18:02:54.579345210 -0700
@@ -153,7 +153,7 @@ int tcf_generic_walker(struct sk_buff *s
 	} else if (type == RTM_GETACTION) {
 		return tcf_dump_walker(skb, cb, a, hinfo);
 	} else {
-		printk("tcf_generic_walker: unknown action %d\n", type);
+		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
 	}
 }
@@ -403,8 +403,9 @@ void tcf_action_destroy(struct tc_action
 				module_put(a->ops->owner);
 			act = act->next;
 			kfree(a);
-		} else { /*FIXME: Remove later - catch insertion bugs*/
-			printk("tcf_action_destroy: BUG? destroying NULL ops\n");
+		} else {
+			/*FIXME: Remove later - catch insertion bugs*/
+			WARN(1, "tcf_action_destroy: BUG? destroying NULL ops\n");
 			act = act->next;
 			kfree(a);
 		}
@@ -744,7 +745,7 @@ static struct tc_action *create_a(int i)
 
 	act = kzalloc(sizeof(*act), GFP_KERNEL);
 	if (act == NULL) {
-		printk("create_a: failed to alloc!\n");
+		pr_debug("create_a: failed to alloc!\n");
 		return NULL;
 	}
 	act->order = i;
@@ -766,13 +767,13 @@ static int tca_action_flush(struct net *
 	int err = -ENOMEM;
 
 	if (a == NULL) {
-		printk("tca_action_flush: couldnt create tc_action\n");
+		pr_debug("tca_action_flush: couldnt create tc_action\n");
 		return err;
 	}
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
-		printk("tca_action_flush: failed skb alloc\n");
+		pr_debug("tca_action_flush: failed skb alloc\n");
 		kfree(a);
 		return err;
 	}
@@ -979,7 +980,7 @@ static int tc_ctl_action(struct sk_buff 
 		return ret;
 
 	if (tca[TCA_ACT_TAB] == NULL) {
-		printk("tc_ctl_action: received NO action attribs\n");
+		pr_notice("tc_ctl_action: received NO action attribs\n");
 		return -EINVAL;
 	}
 
@@ -1056,7 +1057,7 @@ tc_dump_action(struct sk_buff *skb, stru
 	struct nlattr *kind = find_dump_kind(cb->nlh);
 
 	if (kind == NULL) {
-		printk("tc_dump_action: action bad kind\n");
+		pr_info("tc_dump_action: action bad kind\n");
 		return 0;
 	}
 
@@ -1069,7 +1070,8 @@ tc_dump_action(struct sk_buff *skb, stru
 	a.ops = a_o;
 
 	if (a_o->walk == NULL) {
-		printk("tc_dump_action: %s !capable of dumping table\n", a_o->kind);
+		WARN(1, "tc_dump_action: %s !capable of dumping table\n",
+		     a_o->kind);
 		goto nla_put_failure;
 	}
 
--- a/net/sched/act_gact.c	2010-05-11 18:03:06.760617958 -0700
+++ b/net/sched/act_gact.c	2010-05-11 20:28:32.882491695 -0700
@@ -202,9 +202,9 @@ MODULE_LICENSE("GPL");
 static int __init gact_init_module(void)
 {
 #ifdef CONFIG_GACT_PROB
-	printk("GACT probability on\n");
+	printk(KERN_INFO "GACT probability on\n");
 #else
-	printk("GACT probability NOT on\n");
+	printk(KERN_INFO "GACT probability NOT on\n");
 #endif
 	return tcf_register_action(&act_gact_ops);
 }
--- a/net/sched/act_ipt.c	2010-05-11 18:03:25.010617859 -0700
+++ b/net/sched/act_ipt.c	2010-05-11 18:04:42.629656321 -0700
@@ -235,7 +235,8 @@ static int tcf_ipt(struct sk_buff *skb, 
 		break;
 	default:
 		if (net_ratelimit())
-			printk("Bogus netfilter code %d assume ACCEPT\n", ret);
+			pr_notice("tc filter: Bogus netfilter code"
+				  " %d assume ACCEPT\n", ret);
 		result = TC_POLICE_OK;
 		break;
 	}
--- a/net/sched/act_mirred.c	2010-05-11 18:04:49.181580377 -0700
+++ b/net/sched/act_mirred.c	2010-05-11 18:05:28.039827235 -0700
@@ -164,8 +164,8 @@ static int tcf_mirred(struct sk_buff *sk
 	dev = m->tcfm_dev;
 	if (!(dev->flags & IFF_UP)) {
 		if (net_ratelimit())
-			printk("mirred to Houston: device %s is gone!\n",
-			       dev->name);
+			pr_notice("tc mirred to Houston: device %s is gone!\n",
+				  dev->name);
 		goto out;
 	}
 
@@ -252,7 +252,7 @@ MODULE_LICENSE("GPL");
 
 static int __init mirred_init_module(void)
 {
-	printk("Mirror/redirect action on\n");
+	pr_info("Mirror/redirect action on\n");
 	return tcf_register_action(&act_mirred_ops);
 }
 
--- a/net/sched/act_pedit.c	2010-05-11 18:05:34.920985457 -0700
+++ b/net/sched/act_pedit.c	2010-05-11 18:09:39.250387042 -0700
@@ -158,11 +158,13 @@ static int tcf_pedit(struct sk_buff *skb
 			}
 
 			if (offset % 4) {
-				printk("offset must be on 32 bit boundaries\n");
+				pr_info("tc filter pedit"
+					" offset must be on 32 bit boundaries\n");
 				goto bad;
 			}
 			if (offset > 0 && offset > skb->len) {
-				printk("offset %d cant exceed pkt length %d\n",
+				pr_info("tc filter pedit"
+					" offset %d cant exceed pkt length %d\n",
 				       offset, skb->len);
 				goto bad;
 			}
@@ -176,9 +178,8 @@ static int tcf_pedit(struct sk_buff *skb
 		if (munged)
 			skb->tc_verd = SET_TC_MUNGED(skb->tc_verd);
 		goto done;
-	} else {
-		printk("pedit BUG: index %d\n", p->tcf_index);
-	}
+	} else
+		WARN(1, "pedit BUG: index %d\n", p->tcf_index);
 
 bad:
 	p->tcf_qstats.overlimits++;
--- a/net/sched/act_simple.c	2010-05-11 18:07:17.519655758 -0700
+++ b/net/sched/act_simple.c	2010-05-11 18:07:34.339349407 -0700
@@ -49,7 +49,7 @@ static int tcf_simp(struct sk_buff *skb,
 	 * Example if this was the 3rd packet and the string was "hello"
 	 * then it would look like "hello_3" (without quotes)
 	 **/
-	printk("simple: %s_%d\n",
+	pr_info("simple: %s_%d\n",
 	       (char *)d->tcfd_defdata, d->tcf_bstats.packets);
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -205,7 +205,7 @@ static int __init simp_init_module(void)
 {
 	int ret = tcf_register_action(&act_simp_ops);
 	if (!ret)
-		printk("Simple TC action Loaded\n");
+		pr_info("Simple TC action Loaded\n");
 	return ret;
 }
 
--- a/net/sched/cls_u32.c	2010-05-11 18:07:43.169988635 -0700
+++ b/net/sched/cls_u32.c	2010-05-11 20:28:57.908985524 -0700
@@ -211,7 +211,7 @@ check_terminal:
 
 deadloop:
 	if (net_ratelimit())
-		printk("cls_u32: dead loop\n");
+		printk(KERN_WARNING "cls_u32: dead loop\n");
 	return -1;
 }
 
@@ -768,15 +768,15 @@ static struct tcf_proto_ops cls_u32_ops 
 
 static int __init init_u32(void)
 {
-	printk("u32 classifier\n");
+	pr_info("u32 classifier\n");
 #ifdef CONFIG_CLS_U32_PERF
-	printk("    Performance counters on\n");
+	pr_info("    Performance counters on\n");
 #endif
 #ifdef CONFIG_NET_CLS_IND
-	printk("    input device check on\n");
+	pr_info("    input device check on\n");
 #endif
 #ifdef CONFIG_NET_CLS_ACT
-	printk("    Actions configured\n");
+	pr_info("    Actions configured\n");
 #endif
 	return register_tcf_proto_ops(&cls_u32_ops);
 }
--- a/net/sched/ematch.c	2010-05-11 18:08:17.389656613 -0700
+++ b/net/sched/ematch.c	2010-05-11 20:28:47.147714188 -0700
@@ -527,7 +527,8 @@ pop_stack:
 
 stack_overflow:
 	if (net_ratelimit())
-		printk("Local stack overflow, increase NET_EMATCH_STACK\n");
+		printk(KERN_WARNING "tc ematch: local stack overflow,"
+			" increase NET_EMATCH_STACK\n");
 	return -1;
 }
 EXPORT_SYMBOL(__tcf_em_tree_match);


