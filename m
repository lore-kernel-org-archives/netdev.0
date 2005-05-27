From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/7] [PKT_SCHED] Fix dsmark to apply changes consistent
Date: Fri, 27 May 2005 16:53:32 +0200
Message-ID: <20050527145332.GW15391@postel.suug.ch>
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

Fixes dsmark to do all configuration sanity checks first and
only apply the changes if all of them can be applied without
any errors. Also fixes the weak sanity checks for DSMARK_VALUE
and DSMASK_MASK.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 76061832cc84456bd970769c0dfcdfefc20d22fa
tree ffa2efa3cf35b0a3c8c983060731be7b4d3330db
parent c49bbdd22621352b9b96097ffdb9e5c14b4ed95e
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 15:15:26 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 15:15:26 +0200

 net/sched/sch_dsmark.c |  129 ++++++++++++++++++++++++++++++-------------------
 1 files changed, 81 insertions(+), 48 deletions(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- 6204e59b7aa59cf79632003c621e521db1297b1b/net/sched/sch_dsmark.c  (mode:100644)
+++ ffa2efa3cf35b0a3c8c983060731be7b4d3330db/net/sched/sch_dsmark.c  (mode:100644)
@@ -62,6 +62,21 @@
 	int			set_tc_index;
 };
 
+static inline int dsmark_valid_indices(u16 indices)
+{
+	while (indices != 1) {
+		if (indices & 1)
+			return 0;
+		indices >>= 1;
+	}
+ 
+	return 1;
+}
+
+static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
+{
+	return (index <= p->indices && index > 0);
+}
 
 /* ------------------------- Class/flow operations ------------------------- */
 
@@ -120,31 +135,39 @@
 
 
 static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
-    struct rtattr **tca, unsigned long *arg)
+			 struct rtattr **tca, unsigned long *arg)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_DSMARK_MAX];
+	int err = -EINVAL;
+	u8 mask = 0;
 
 	DPRINTK("dsmark_change(sch %p,[qdisc %p],classid %x,parent %x),"
-	    "arg 0x%lx\n",sch,p,classid,parent,*arg);
-	if (*arg > p->indices)
-		return -ENOENT;
-	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt))
-		return -EINVAL;
-	if (tb[TCA_DSMARK_MASK-1]) {
-		if (!RTA_PAYLOAD(tb[TCA_DSMARK_MASK-1]))
-			return -EINVAL;
-		p->mask[*arg-1] = *(__u8 *) RTA_DATA(tb[TCA_DSMARK_MASK-1]);
-	}
-	if (tb[TCA_DSMARK_VALUE-1]) {
-		if (!RTA_PAYLOAD(tb[TCA_DSMARK_VALUE-1]))
-			return -EINVAL;
-		p->value[*arg-1] = *(__u8 *) RTA_DATA(tb[TCA_DSMARK_VALUE-1]);
+		"arg 0x%lx\n", sch, p, classid, parent, *arg);
+
+	if (!dsmark_valid_index(p, *arg)) {
+		err = -ENOENT;
+		goto rtattr_failure;
 	}
-	return 0;
-}
 
+	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt))
+		goto rtattr_failure;
+
+	if (tb[TCA_DSMARK_MASK-1])
+		mask = RTA_GET_U8(tb[TCA_DSMARK_MASK-1]);
+
+	if (tb[TCA_DSMARK_VALUE-1])
+		p->value[*arg-1] = RTA_GET_U8(tb[TCA_DSMARK_VALUE-1]);
+		
+	if (tb[TCA_DSMARK_MASK-1])
+		p->mask[*arg-1] = mask;
+
+	err = 0;
+
+rtattr_failure:
+	return err;
+}
 
 static int dsmark_delete(struct Qdisc *sch,unsigned long arg)
 {
@@ -328,43 +351,53 @@
 }
 
 
-static int dsmark_init(struct Qdisc *sch,struct rtattr *opt)
+static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	struct rtattr *tb[TCA_DSMARK_MAX];
-	__u16 tmp;
+	int err = -EINVAL;
+	u32 default_index = NO_DEFAULT_INDEX;
+	u16 indices;
+	u8 *mask;
 
-	DPRINTK("dsmark_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
-	if (!opt ||
-	    rtattr_parse(tb,TCA_DSMARK_MAX,RTA_DATA(opt),RTA_PAYLOAD(opt)) < 0 ||
-	    !tb[TCA_DSMARK_INDICES-1] ||
-	    RTA_PAYLOAD(tb[TCA_DSMARK_INDICES-1]) < sizeof(__u16))
-                return -EINVAL;
-	p->indices = *(__u16 *) RTA_DATA(tb[TCA_DSMARK_INDICES-1]);
-	if (!p->indices)
-		return -EINVAL;
-	for (tmp = p->indices; tmp != 1; tmp >>= 1) {
-		if (tmp & 1)
-			return -EINVAL;
-	}
-	p->default_index = NO_DEFAULT_INDEX;
-	if (tb[TCA_DSMARK_DEFAULT_INDEX-1]) {
-		if (RTA_PAYLOAD(tb[TCA_DSMARK_DEFAULT_INDEX-1]) < sizeof(__u16))
-			return -EINVAL;
-		p->default_index =
-		    *(__u16 *) RTA_DATA(tb[TCA_DSMARK_DEFAULT_INDEX-1]);
+	DPRINTK("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
+
+	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt) < 0)
+		goto errout;
+
+	indices = RTA_GET_U16(tb[TCA_DSMARK_INDICES-1]);
+	if (!indices || !dsmark_valid_indices(indices))
+		goto errout;
+
+	if (tb[TCA_DSMARK_DEFAULT_INDEX-1])
+		default_index = RTA_GET_U16(tb[TCA_DSMARK_DEFAULT_INDEX-1]);
+
+	mask = kmalloc(indices * 2, GFP_KERNEL);
+	if (mask == NULL) {
+		err = -ENOMEM;
+		goto errout;
 	}
-	p->set_tc_index = !!tb[TCA_DSMARK_SET_TC_INDEX-1];
-	p->mask = kmalloc(p->indices*2,GFP_KERNEL);
-	if (!p->mask)
-		return -ENOMEM;
-	p->value = p->mask+p->indices;
-	memset(p->mask,0xff,p->indices);
-	memset(p->value,0,p->indices);
-	if (!(p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops)))
+
+	p->mask = mask;
+	memset(p->mask, 0xff, indices);
+
+	p->value = p->mask + indices;
+	memset(p->value, 0, indices);
+
+	p->indices = indices;
+	p->default_index = default_index;
+	p->set_tc_index = RTA_GET_FLAG(tb[TCA_DSMARK_SET_TC_INDEX-1]);
+
+	p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+	if (p->q == NULL)
 		p->q = &noop_qdisc;
-	DPRINTK("dsmark_init: qdisc %p\n",&p->q);
-	return 0;
+
+	DPRINTK("dsmark_init: qdisc %p\n", p->q);
+
+	err = 0;
+errout:
+rtattr_failure:
+	return err;
 }
 
 
