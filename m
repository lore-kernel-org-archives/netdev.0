From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_dsmark: improve memory locality
Date: Thu, 17 Sep 2015 16:37:13 -0700
Message-ID: <1442533033.7946.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33869 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbIQXhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:37:15 -0400
Received: by padhy16 with SMTP id hy16so32291355pad.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 16:37:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Memory placement in sch_dsmark is silly : Better place mask/value
in the same cache line.

Also, we can embed small arrays in the first cache line and
remove a potential cache miss.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_dsmark.c |   63 ++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index c4d45fd8c551..f357f34d02d2 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -35,14 +35,20 @@
 
 #define NO_DEFAULT_INDEX	(1 << 16)
 
+struct mask_value {
+	u8			mask;
+	u8			value;
+};
+
 struct dsmark_qdisc_data {
 	struct Qdisc		*q;
 	struct tcf_proto __rcu	*filter_list;
-	u8			*mask;	/* "owns" the array */
-	u8			*value;
+	struct mask_value	*mv;
 	u16			indices;
+	u8			set_tc_index;
 	u32			default_index;	/* index range is 0...0xffff */
-	int			set_tc_index;
+#define DSMARK_EMBEDDED_SZ	16
+	struct mask_value	embedded[DSMARK_EMBEDDED_SZ];
 };
 
 static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
@@ -116,7 +122,6 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_DSMARK_MAX + 1];
 	int err = -EINVAL;
-	u8 mask = 0;
 
 	pr_debug("%s(sch %p,[qdisc %p],classid %x,parent %x), arg 0x%lx\n",
 		 __func__, sch, p, classid, parent, *arg);
@@ -133,14 +138,11 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 	if (err < 0)
 		goto errout;
 
-	if (tb[TCA_DSMARK_MASK])
-		mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
-
 	if (tb[TCA_DSMARK_VALUE])
-		p->value[*arg - 1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
+		p->mv[*arg - 1].value = nla_get_u8(tb[TCA_DSMARK_VALUE]);
 
 	if (tb[TCA_DSMARK_MASK])
-		p->mask[*arg - 1] = mask;
+		p->mv[*arg - 1].mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
 
 	err = 0;
 
@@ -155,8 +157,8 @@ static int dsmark_delete(struct Qdisc *sch, unsigned long arg)
 	if (!dsmark_valid_index(p, arg))
 		return -EINVAL;
 
-	p->mask[arg - 1] = 0xff;
-	p->value[arg - 1] = 0;
+	p->mv[arg - 1].mask = 0xff;
+	p->mv[arg - 1].value = 0;
 
 	return 0;
 }
@@ -173,7 +175,7 @@ static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 		return;
 
 	for (i = 0; i < p->indices; i++) {
-		if (p->mask[i] == 0xff && !p->value[i])
+		if (p->mv[i].mask == 0xff && !p->mv[i].value)
 			goto ignore;
 		if (walker->count >= walker->skip) {
 			if (walker->fn(sch, i + 1, walker) < 0) {
@@ -291,12 +293,12 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
-		ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
-				    p->value[index]);
+		ipv4_change_dsfield(ip_hdr(skb), p->mv[index].mask,
+				    p->mv[index].value);
 			break;
 	case htons(ETH_P_IPV6):
-		ipv6_change_dsfield(ipv6_hdr(skb), p->mask[index],
-				    p->value[index]);
+		ipv6_change_dsfield(ipv6_hdr(skb), p->mv[index].mask,
+				    p->mv[index].value);
 			break;
 	default:
 		/*
@@ -304,7 +306,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		 * This way, we can send non-IP traffic through dsmark
 		 * and don't need yet another qdisc as a bypass.
 		 */
-		if (p->mask[index] != 0xff || p->value[index])
+		if (p->mv[index].mask != 0xff || p->mv[index].value)
 			pr_warn("%s: unsupported protocol %d\n",
 				__func__, ntohs(tc_skb_protocol(skb)));
 		break;
@@ -346,7 +348,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	int err = -EINVAL;
 	u32 default_index = NO_DEFAULT_INDEX;
 	u16 indices;
-	u8 *mask;
+	int i;
 
 	pr_debug("%s(sch %p,[qdisc %p],opt %p)\n", __func__, sch, p, opt);
 
@@ -366,18 +368,18 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_DSMARK_DEFAULT_INDEX])
 		default_index = nla_get_u16(tb[TCA_DSMARK_DEFAULT_INDEX]);
 
-	mask = kmalloc(indices * 2, GFP_KERNEL);
-	if (mask == NULL) {
+	if (indices <= DSMARK_EMBEDDED_SZ)
+		p->mv = p->embedded;
+	else
+		p->mv = kmalloc_array(indices, sizeof(*p->mv), GFP_KERNEL);
+	if (!p->mv) {
 		err = -ENOMEM;
 		goto errout;
 	}
-
-	p->mask = mask;
-	memset(p->mask, 0xff, indices);
-
-	p->value = p->mask + indices;
-	memset(p->value, 0, indices);
-
+	for (i = 0; i < indices; i++) {
+		p->mv[i].mask = 0xff;
+		p->mv[i].value = 0;
+	}
 	p->indices = indices;
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
@@ -410,7 +412,8 @@ static void dsmark_destroy(struct Qdisc *sch)
 
 	tcf_destroy_chain(&p->filter_list);
 	qdisc_destroy(p->q);
-	kfree(p->mask);
+	if (p->mv != p->embedded)
+		kfree(p->mv);
 }
 
 static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
@@ -430,8 +433,8 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;
-	if (nla_put_u8(skb, TCA_DSMARK_MASK, p->mask[cl - 1]) ||
-	    nla_put_u8(skb, TCA_DSMARK_VALUE, p->value[cl - 1]))
+	if (nla_put_u8(skb, TCA_DSMARK_MASK, p->mv[cl - 1].mask) ||
+	    nla_put_u8(skb, TCA_DSMARK_VALUE, p->mv[cl - 1].value))
 		goto nla_put_failure;
 
 	return nla_nest_end(skb, opts);
