From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] nfmark modify extension to classifiers
Date: Mon, 6 Oct 2003 02:26:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006002619.GC11250@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

The netfilter mark field is heavly used nowadays to communicate
between tc, netfilter and ip rule.  Classifiers are not yet
capable of modifying the nfmark field. However it would make
sense, especially in ingress context.

Example:
$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32
match ip protocol 6 0xff nfmark 0x10 flowid 10:12
                         ^^^^^^^^^^^
Would set nfmark=0x10 for all icmp packets.

Applications (examples):
 - Differentiate source classifier if multiple classifiers
   classify into a single class (match again with cls_fw.c).
 - Mark packets in ingress and reuse nfmark in ip rules if
   netfilter is too slow.
 - Use rsvp(6)/route/tcindex capabilities in netfilter/ip rule.

Below is a patch to the u32 classifier adding this extension.
It would be easy to do the same for other classifiers.
(I also have a patch against tc if someone is interested.)

The ifdef mess cannot be avoided unless nfmark in skbuff is
freed from its ifdefs.

Regards

-- 
Thomas GRAF <tgraf@suug.ch>


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1495  -> 1.1496 
#	include/linux/pkt_cls.h	1.2     -> 1.3    
#	 net/sched/cls_u32.c	1.8     -> 1.9    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/06	tgraf@suug.ch	1.1496
# This changeset extends the u32 classifier to change the netfilter mark if the filter matches.
# --------------------------------------------
#
diff -Nru a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
--- a/include/linux/pkt_cls.h	Mon Oct  6 03:37:58 2003
+++ b/include/linux/pkt_cls.h	Mon Oct  6 03:37:58 2003
@@ -48,6 +48,7 @@
 	TCA_U32_LINK,
 	TCA_U32_DIVISOR,
 	TCA_U32_SEL,
+	TCA_U32_NFMARK,
 	TCA_U32_POLICE,
 };
 
diff -Nru a/net/sched/cls_u32.c b/net/sched/cls_u32.c
--- a/net/sched/cls_u32.c	Mon Oct  6 03:37:58 2003
+++ b/net/sched/cls_u32.c	Mon Oct  6 03:37:58 2003
@@ -62,6 +62,9 @@
 	struct tcf_police	*police;
 #endif
 	struct tcf_result	res;
+#ifdef CONFIG_NETFILTER
+	unsigned long   	nfmark;
+#endif
 	struct tc_u_hnode	*ht_down;
 	struct tc_u32_sel	sel;
 };
@@ -129,6 +132,10 @@
 check_terminal:
 			if (n->sel.flags&TC_U32_TERMINAL) {
 				*res = n->res;
+#ifdef CONFIG_NETFILTER
+				if (n->nfmark)
+					skb->nfmark = n->nfmark;
+#endif
 #ifdef CONFIG_NET_CLS_POLICE
 				if (n->police) {
 					int pol_res = tcf_police(skb, n->police);
@@ -470,6 +477,10 @@
 		if (cl)
 			q->ops->cl_ops->unbind_tcf(q, cl);
 	}
+#ifdef CONFIG_NETFILTER
+	if (tb[TCA_U32_NFMARK-1])
+		n->nfmark = *(u32*)RTA_DATA(tb[TCA_U32_NFMARK-1]);
+#endif
 #ifdef CONFIG_NET_CLS_POLICE
 	if (tb[TCA_U32_POLICE-1]) {
 		struct tcf_police *police = tcf_police_locate(tb[TCA_U32_POLICE-1], est);
@@ -654,6 +665,10 @@
 		}
 		if (n->res.classid)
 			RTA_PUT(skb, TCA_U32_CLASSID, 4, &n->res.classid);
+#ifdef CONFIG_NETFILTER
+		if (n->nfmark)
+			RTA_PUT(skb, TCA_U32_NFMARK, 4, &n->nfmark);
+#endif
 		if (n->ht_down)
 			RTA_PUT(skb, TCA_U32_LINK, 4, &n->ht_down->handle);
 #ifdef CONFIG_NET_CLS_POLICE
