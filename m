From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 29 Jul 2004 07:22:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091100138.1044.549.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
	 <1090612669.1218.47.camel@jzny.localdomain>
	 <20040723135945.7f50b02c.davem@redhat.com>
	 <1090630154.1134.6.camel@jzny.localdomain>
	 <1090675993.1161.11.camel@jzny.localdomain>
	 <20040724222853.752137d6.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ntp7cnPbJrTVEws5Jy23"
Cc: yoshfuji@linux-ipv6.org, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040724222853.752137d6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ntp7cnPbJrTVEws5Jy23
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

On Sun, 2004-07-25 at 01:28, David S. Miller wrote:

> Ok, I'll keep this in my inbox until you give the word.

[Still trying to recover after all those conferences].

Heres a patch that passes all my regression tests. I use a 
__u64 instead of u64 for perf counters since user space understands it.

cheers,
jamal

PS:- at some point we need to scrub the general backward compatibility
issues going forward. 

--=-ntp7cnPbJrTVEws5Jy23
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=p2
Content-Type: text/plain; name=p2; charset=ISO-8859-1

--- a/267-bk20-act+dummy/net/sched/cls_u32.c	2004/07/24 12:38:52	1.1
+++ b/267-bk20-act+dummy/net/sched/cls_u32.c	2004/07/28 18:37:06
@@ -64,17 +64,20 @@
 	struct tc_u_hnode	*ht_up;
 #ifdef CONFIG_NET_CLS_ACT
 	struct tc_action	*action;
-#ifdef CONFIG_NET_CLS_IND
-	char                     indev[IFNAMSIZ];
-#endif
 #else
 #ifdef CONFIG_NET_CLS_POLICE
 	struct tcf_police	*police;
 #endif
 #endif
+#ifdef CONFIG_NET_CLS_IND
+	char                     indev[IFNAMSIZ];
+#endif
 	u8			fshift;
 	struct tcf_result	res;
 	struct tc_u_hnode	*ht_down;
+#ifdef CONFIG_CLS_U32_PERF
+	struct tc_u32_pcnt	*pf;
+#endif
 	struct tc_u32_sel	sel;
 };
 
@@ -120,6 +123,9 @@
 	int sdepth = 0;
 	int off2 = 0;
 	int sel = 0;
+#ifdef CONFIG_CLS_U32_PERF
+	int j;
+#endif
 	int i;
 
 next_ht:
@@ -130,7 +136,8 @@
 		struct tc_u32_key *key = n->sel.keys;
 
 #ifdef CONFIG_CLS_U32_PERF
-		n->sel.rcnt +=1;
+		n->pf->rcnt +=1;
+		j = 0;
 #endif
 		for (i = n->sel.nkeys; i>0; i--, key++) {
 
@@ -139,7 +146,8 @@
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
-			key->kcnt +=1;
+			n->pf->kcnts[j] +=1;
+			j++;
 #endif
 		}
 		if (n->ht_down == NULL) {
@@ -147,7 +155,6 @@
 			if (n->sel.flags&TC_U32_TERMINAL) {
 
 				*res = n->res;
-#ifdef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NET_CLS_IND
 				/* yes, i know it sucks but the feature is 
 				** optional dammit! - JHS */
@@ -164,8 +171,9 @@
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-		n->sel.rhit +=1;
+				n->pf->rhit +=1;
 #endif
+#ifdef CONFIG_NET_CLS_ACT
 				if (n->action) {
 					int pol_res = tcf_action_exec(skb, n->action);
 					if (skb->tc_classid > 0) {
@@ -358,6 +366,10 @@
 #endif
 	if (n->ht_down)
 		n->ht_down->refcnt--;
+#ifdef CONFIG_CLS_U32_PERF
+	if (n && (NULL != n->pf))
+		kfree(n->pf);
+#endif
 	kfree(n);
 	return 0;
 }
@@ -571,18 +583,6 @@
 		tcf_action_destroy(act, TCA_ACT_UNBIND);
 	}
 
-#ifdef CONFIG_NET_CLS_IND
-	n->indev[0] = 0;
-	if(tb[TCA_U32_INDEV-1]) {
-		struct rtattr *input_dev = tb[TCA_U32_INDEV-1];
-		if (RTA_PAYLOAD(input_dev) >= IFNAMSIZ) {
-			printk("cls_u32: bad indev name %s\n",(char*)RTA_DATA(input_dev));
-			/* should we clear state first? */
-			return  -EINVAL;
-		}
-		sprintf(n->indev, "%s", (char*)RTA_DATA(input_dev));
-	}
-#endif
 
 #else
 #ifdef CONFIG_NET_CLS_POLICE
@@ -595,6 +595,19 @@
 	}
 #endif
 #endif
+#ifdef CONFIG_NET_CLS_IND
+	n->indev[0] = 0;
+	if(tb[TCA_U32_INDEV-1]) {
+		struct rtattr *input_dev = tb[TCA_U32_INDEV-1];
+		if (RTA_PAYLOAD(input_dev) >= IFNAMSIZ) {
+			printk("cls_u32: bad indev name %s\n",(char*)RTA_DATA(input_dev));
+			/* should we clear state first? */
+			return  -EINVAL;
+		}
+		sprintf(n->indev, "%s", (char*)RTA_DATA(input_dev));
+		printk("got IND %s\n",n->indev);
+	}
+#endif
 
 	return 0;
 }
@@ -682,17 +695,20 @@
 
 	s = RTA_DATA(tb[TCA_U32_SEL-1]);
 
-#ifdef CONFIG_CLS_U32_PERF
-	if (RTA_PAYLOAD(tb[TCA_U32_SEL-1]) < 
-		(s->nkeys*sizeof(struct tc_u32_key)) + sizeof(struct tc_u32_sel)) {
-			printk("Please upgrade your iproute2 tools or compile proper options in!\n");
-			return -EINVAL;
-}
-#endif
 	n = kmalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL);
 	if (n == NULL)
 		return -ENOBUFS;
+
 	memset(n, 0, sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key));
+#ifdef CONFIG_CLS_U32_PERF
+	n->pf = kmalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(__u64), GFP_KERNEL);
+	if (n->pf == NULL) {
+		kfree(n);
+		return -ENOBUFS;
+	}
+	memset(n->pf, 0, sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(__u64));
+#endif
+
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
 	n->handle = handle;
@@ -721,6 +737,10 @@
 		*arg = (unsigned long)n;
 		return 0;
 	}
+#ifdef CONFIG_CLS_U32_PERF
+	if (n && (NULL != n->pf))
+		kfree(n->pf);
+#endif
 	kfree(n);
 	return err;
 }
@@ -812,13 +832,6 @@
 
 			p_rta->rta_len = skb->tail - (u8*)p_rta;
 		}
-#ifdef CONFIG_NET_CLS_IND
-		if(strlen(n->indev)) {
-			struct rtattr * p_rta = (struct rtattr*)skb->tail;
-			RTA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
-			p_rta->rta_len = skb->tail - (u8*)p_rta;
-		}
-#endif
 
 #else
 #ifdef CONFIG_NET_CLS_POLICE
@@ -834,13 +847,28 @@
 		}
 #endif
 #endif
+
+#ifdef CONFIG_NET_CLS_IND
+		if(strlen(n->indev)) {
+			struct rtattr * p_rta = (struct rtattr*)skb->tail;
+			RTA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
+			p_rta->rta_len = skb->tail - (u8*)p_rta;
+		}
+#endif
+#ifdef CONFIG_CLS_U32_PERF
+		RTA_PUT(skb, TCA_U32_PCNT, 
+		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(__u64),
+			n->pf);
+#endif
 	}
 
 	rta->rta_len = skb->tail - b;
 #ifdef CONFIG_NET_CLS_ACT
-	if (TC_U32_KEY(n->handle) && n->action && n->action->type == TCA_OLD_COMPAT) {
-		if (tcf_action_copy_stats(skb,n->action))
-			goto rtattr_failure;
+	if (TC_U32_KEY(n->handle) != 0) {
+		if (TC_U32_KEY(n->handle) && n->action && n->action->type == TCA_OLD_COMPAT) {
+			if (tcf_action_copy_stats(skb,n->action))
+				goto rtattr_failure;
+		}
 	}
 #else
 #ifdef CONFIG_NET_CLS_POLICE
@@ -875,6 +903,19 @@
 
 static int __init init_u32(void)
 {
+	printk("u32 classifier\n");
+#ifdef CONFIG_CLS_U32_PERF
+	printk("    Perfomance counters on\n");
+#endif
+#ifdef CONFIG_NET_CLS_POLICE
+	printk("    OLD policer on \n");
+#endif
+#ifdef CONFIG_NET_CLS_IND
+	printk("    input device check on \n");
+#endif
+#ifdef CONFIG_NET_CLS_ACT
+	printk("    Actions configured \n");
+#endif
 	return register_tcf_proto_ops(&cls_u32_ops);
 }
 
--- a/267-bk20-act+dummy/include/linux/pkt_cls.h	2004/07/24 12:35:40	1.1
+++ b/267-bk20-act+dummy/include/linux/pkt_cls.h	2004/07/28 18:38:01
@@ -117,17 +117,6 @@
 struct tc_police
 {
 	__u32			index;
-#ifdef CONFIG_NET_CLS_ACT
-	int 			refcnt;
-	int 			bindcnt;
-#endif
-/* Turned off because it requires new tc
- * to work (for now maintain ABI)
- *
-#ifdef CONFIG_NET_CLS_ACT
-	__u32			capab;
-#endif
-*/
 	int			action;
 #define TC_POLICE_UNSPEC	TC_ACT_UNSPEC
 #define TC_POLICE_OK		TC_ACT_OK
@@ -140,6 +129,9 @@
 	__u32			mtu;
 	struct tc_ratespec	rate;
 	struct tc_ratespec	peakrate;
+	int 			refcnt;
+	int 			bindcnt;
+	__u32			capab;
 };
 
 struct tcf_t
@@ -195,12 +187,9 @@
 	TCA_U32_DIVISOR,
 	TCA_U32_SEL,
 	TCA_U32_POLICE,
-#ifdef CONFIG_NET_CLS_ACT
 	TCA_U32_ACT,   
-#endif
-#ifdef CONFIG_NET_CLS_IND
 	TCA_U32_INDEV,
-#endif
+	TCA_U32_PCNT,
 	__TCA_U32_MAX
 };
 
@@ -212,9 +201,6 @@
 	__u32		val;
 	int		off;
 	int		offmask;
-#ifdef CONFIG_CLS_U32_PERF
-	unsigned long	kcnt;
-#endif
 };
 
 struct tc_u32_sel
@@ -229,13 +215,17 @@
 
 	short			hoff;
 	__u32			hmask;
-#ifdef CONFIG_CLS_U32_PERF
-	unsigned long		rcnt;
-	unsigned long		rhit;
-#endif
 	struct tc_u32_key	keys[0];
 };
 
+#ifdef CONFIG_CLS_U32_PERF
+struct tc_u32_pcnt
+{
+	__u64 rcnt;
+	__u64 rhit;
+	__u64 kcnts[0];
+};
+#endif
 /* Flags */
 
 #define TC_U32_TERMINAL		1
@@ -300,12 +290,8 @@
 	TCA_FW_UNSPEC,
 	TCA_FW_CLASSID,
 	TCA_FW_POLICE,
-#ifdef CONFIG_NET_CLS_IND
-	TCA_FW_INDEV,
-#endif
-#ifdef CONFIG_NET_CLS_ACT
-	TCA_FW_ACT,
-#endif
+	TCA_FW_INDEV, /*  used by CONFIG_NET_CLS_IND */
+	TCA_FW_ACT, /* used by CONFIG_NET_CLS_ACT */
 	__TCA_FW_MAX
 };
 

--=-ntp7cnPbJrTVEws5Jy23--
