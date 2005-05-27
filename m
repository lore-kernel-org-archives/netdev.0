From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/7] [PKT_SCHED] Make dsmark use the new dumping macros
Date: Fri, 27 May 2005 16:54:15 +0200
Message-ID: <20050527145415.GX15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 36b5fe1b0094ab6d6ba2589076bec1975d5769ed
tree ff95a30a27c52aef9561f2ed04e9950d0afcae6a
parent 76061832cc84456bd970769c0dfcdfefc20d22fa
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 15:22:44 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 15:22:44 +0200

 net/sched/sch_dsmark.c |   52 ++++++++++++++++++++++---------------------------
 1 files changed, 24 insertions(+), 28 deletions(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- ffa2efa3cf35b0a3c8c983060731be7b4d3330db/net/sched/sch_dsmark.c  (mode:100644)
+++ ff95a30a27c52aef9561f2ed04e9950d0afcae6a/net/sched/sch_dsmark.c  (mode:100644)
@@ -428,50 +428,46 @@
 
 
 static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
-    struct sk_buff *skb, struct tcmsg *tcm)
+			     struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
-	unsigned char *b = skb->tail;
-	struct rtattr *rta;
+	struct rtattr *opts = NULL;
 
-	DPRINTK("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n",sch,p,cl);
-	if (!cl || cl > p->indices)
+	DPRINTK("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n", sch, p, cl);
+
+	if (!dsmark_valid_index(p, cl))
 		return -EINVAL;
-	tcm->tcm_handle = TC_H_MAKE(TC_H_MAJ(sch->handle),cl-1);
-	rta = (struct rtattr *) b;
-	RTA_PUT(skb,TCA_OPTIONS,0,NULL);
-	RTA_PUT(skb,TCA_DSMARK_MASK,1,&p->mask[cl-1]);
-	RTA_PUT(skb,TCA_DSMARK_VALUE,1,&p->value[cl-1]);
-	rta->rta_len = skb->tail-b;
-	return skb->len;
+
+	tcm->tcm_handle = TC_H_MAKE(TC_H_MAJ(sch->handle), cl-1);
+
+	opts = RTA_NEST(skb, TCA_OPTIONS);
+	RTA_PUT_U8(skb,TCA_DSMARK_MASK, p->mask[cl-1]);
+	RTA_PUT_U8(skb,TCA_DSMARK_VALUE, p->value[cl-1]);
+
+	return RTA_NEST_END(skb, opts);
 
 rtattr_failure:
-	skb_trim(skb,b-skb->data);
-	return -1;
+	return RTA_NEST_CANCEL(skb, opts);
 }
 
 static int dsmark_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
-	unsigned char *b = skb->tail;
-	struct rtattr *rta;
+	struct rtattr *opts = NULL;
+
+	opts = RTA_NEST(skb, TCA_OPTIONS);
+	RTA_PUT_U16(skb, TCA_DSMARK_INDICES, p->indices);
 
-	rta = (struct rtattr *) b;
-	RTA_PUT(skb,TCA_OPTIONS,0,NULL);
-	RTA_PUT(skb,TCA_DSMARK_INDICES,sizeof(__u16),&p->indices);
-	if (p->default_index != NO_DEFAULT_INDEX) {
-		__u16 tmp = p->default_index;
+	if (p->default_index != NO_DEFAULT_INDEX)
+		RTA_PUT_U16(skb, TCA_DSMARK_DEFAULT_INDEX, p->default_index);
 
-		RTA_PUT(skb,TCA_DSMARK_DEFAULT_INDEX, sizeof(__u16), &tmp);
-	}
 	if (p->set_tc_index)
-		RTA_PUT(skb, TCA_DSMARK_SET_TC_INDEX, 0, NULL);
-	rta->rta_len = skb->tail-b;
-	return skb->len;
+		RTA_PUT_FLAG(skb, TCA_DSMARK_SET_TC_INDEX);
+
+	return RTA_NEST_END(skb, opts);
 
 rtattr_failure:
-	skb_trim(skb,b-skb->data);
-	return -1;
+	return RTA_NEST_CANCEL(skb, opts);
 }
 
 static struct Qdisc_class_ops dsmark_class_ops = {
