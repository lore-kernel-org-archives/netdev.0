From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 24 Jul 2004 09:33:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090675993.1161.11.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
	 <1090612669.1218.47.camel@jzny.localdomain>
	 <20040723135945.7f50b02c.davem@redhat.com>
	 <1090630154.1134.6.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Wuxvn3vFz2yEmJYKNOxp"
Cc: yoshfuji@linux-ipv6.org, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1090630154.1134.6.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Wuxvn3vFz2yEmJYKNOxp
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


alright heres a patch against the old code(before Stevens patch).
Makes the performance counters a separate TLV -  a little bit of a pain,
but acceptable given its optional.
Compiles but hasnt been tested; user space code will have to change.
I dont want to touch the policer for now.
Dont apply yet, i need to run my regression tests when i get back.
In the minimal back out Stephens change.

cheers,
jamal


--=-Wuxvn3vFz2yEmJYKNOxp
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=ols1
Content-Type: text/plain; name=ols1; charset=ISO-8859-1

--- a/include/linux/pkt_cls.h	2004/07/24 12:35:40	1.1
+++ b/include/linux/pkt_cls.h	2004/07/24 12:57:20
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
@@ -140,6 +129,17 @@
 	__u32			mtu;
 	struct tc_ratespec	rate;
 	struct tc_ratespec	peakrate;
+#ifdef CONFIG_NET_CLS_ACT
+	int 			refcnt;
+	int 			bindcnt;
+#endif
+/* Turned off because it requires new tc
+ * to work (for now maintain ABI)
+ *
+#ifdef CONFIG_NET_CLS_ACT
+	__u32			capab;
+#endif
+*/
 };
 
 struct tcf_t
@@ -195,12 +195,9 @@
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
 
@@ -212,9 +209,6 @@
 	__u32		val;
 	int		off;
 	int		offmask;
-#ifdef CONFIG_CLS_U32_PERF
-	unsigned long	kcnt;
-#endif
 };
 
 struct tc_u32_sel
@@ -229,13 +223,17 @@
 
 	short			hoff;
 	__u32			hmask;
+	struct tc_u32_key	keys[0];
+};
+
 #ifdef CONFIG_CLS_U32_PERF
+struct tc_u32_pcnt
+{
 	unsigned long		rcnt;
 	unsigned long		rhit;
-#endif
-	struct tc_u32_key	keys[0];
+	unsigned long		kcnts[];
 };
-
+#endif
 /* Flags */
 
 #define TC_U32_TERMINAL		1
@@ -300,12 +298,8 @@
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
 
--- a/net/sched/cls_u32.c	2004/07/24 12:38:52	1.1
+++ b/net/sched/cls_u32.c	2004/07/24 13:22:29
@@ -76,6 +76,9 @@
 	struct tcf_result	res;
 	struct tc_u_hnode	*ht_down;
 	struct tc_u32_sel	sel;
+#ifdef CONFIG_CLS_U32_PERF
+	struct tc_u32_pcnt	pf;
+#endif
 };
 
 struct tc_u_hnode
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
+		n->pf.rcnt +=1;
+		j = 0;
 #endif
 		for (i = n->sel.nkeys; i>0; i--, key++) {
 
@@ -139,7 +146,8 @@
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
-			key->kcnt +=1;
+			n->pf.kcnts[j] +=1;
+			j++;
 #endif
 		}
 		if (n->ht_down == NULL) {
@@ -164,7 +172,7 @@
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-		n->sel.rhit +=1;
+		n->pf.rhit +=1;
 #endif
 				if (n->action) {
 					int pol_res = tcf_action_exec(skb, n->action);
@@ -682,16 +690,10 @@
 
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
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
@@ -851,6 +853,11 @@
 	}
 #endif
 #endif
+#ifdef CONFIG_CLS_U32_PERF
+	RTA_PUT(skb, TCA_U32_PCNT, 
+		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(unsigned long),
+			&n->pf);
+#endif
 	return skb->len;
 
 rtattr_failure:

--=-Wuxvn3vFz2yEmJYKNOxp--
