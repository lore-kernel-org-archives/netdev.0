From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/05]: sch_atm: Lindent
Date: Mon,  9 Jul 2007 22:46:13 +0200 (MEST)
Message-ID: <20070709204613.1461.25223.sendpatchset@localhost.localdomain>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41503 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbXGIUqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:15 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_atm: Lindent

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d040f72f96e69c5494179d4431e8db82e8a11c74
tree c222557e0331125f9ac157bf0206325668e53287
parent 10501d604facdda8ff5b0540adae573807e6a95a
author Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 19:26:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 19:26:14 +0200

 net/sched/sch_atm.c |  468 +++++++++++++++++++++++++--------------------------
 1 files changed, 232 insertions(+), 236 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 54b92d2..9b458c4 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -2,7 +2,6 @@
 
 /* Written 1998-2000 by Werner Almesberger, EPFL ICA */
 
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/string.h>
@@ -11,12 +10,11 @@
 #include <linux/atmdev.h>
 #include <linux/atmclip.h>
 #include <linux/rtnetlink.h>
-#include <linux/file.h> /* for fput */
+#include <linux/file.h>		/* for fput */
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
-
-extern struct socket *sockfd_lookup(int fd, int *err); /* @@@ fix this */
+extern struct socket *sockfd_lookup(int fd, int *err);	/* @@@ fix this */
 
 #if 0 /* control */
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
@@ -30,7 +28,6 @@ extern struct socket *sockfd_lookup(int fd, int *err); /* @@@ fix this */
 #define D2PRINTK(format,args...)
 #endif
 
-
 /*
  * The ATM queuing discipline provides a framework for invoking classifiers
  * (aka "filters"), which in turn select classes of this queuing discipline.
@@ -52,16 +49,15 @@ extern struct socket *sockfd_lookup(int fd, int *err); /* @@@ fix this */
  *  - should lock the flow while there is data in the queue (?)
  */
 
-
 #define PRIV(sch) qdisc_priv(sch)
 #define VCC2FLOW(vcc) ((struct atm_flow_data *) ((vcc)->user_back))
 
-
 struct atm_flow_data {
-	struct Qdisc		*q;		/* FIFO, TBF, etc. */
+	struct Qdisc		*q;	/* FIFO, TBF, etc. */
 	struct tcf_proto	*filter_list;
-	struct atm_vcc		*vcc;		/* VCC; NULL if VCC is closed */
-	void (*old_pop)(struct atm_vcc *vcc,struct sk_buff *skb); /* chaining */
+	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
+	void			(*old_pop)(struct atm_vcc *vcc,
+					   struct sk_buff * skb); /* chaining */
 	struct atm_qdisc_data	*parent;	/* parent qdisc */
 	struct socket		*sock;		/* for closing */
 	u32			classid;	/* x:y type ID */
@@ -82,76 +78,74 @@ struct atm_qdisc_data {
 	struct tasklet_struct	task;		/* requeue tasklet */
 };
 
-
 /* ------------------------- Class/flow operations ------------------------- */
 
-
-static int find_flow(struct atm_qdisc_data *qdisc,struct atm_flow_data *flow)
+static int find_flow(struct atm_qdisc_data *qdisc, struct atm_flow_data *flow)
 {
 	struct atm_flow_data *walk;
 
-	DPRINTK("find_flow(qdisc %p,flow %p)\n",qdisc,flow);
+	DPRINTK("find_flow(qdisc %p,flow %p)\n", qdisc, flow);
 	for (walk = qdisc->flows; walk; walk = walk->next)
-		if (walk == flow) return 1;
+		if (walk == flow)
+			return 1;
 	DPRINTK("find_flow: not found\n");
 	return 0;
 }
 
-
-static __inline__ struct atm_flow_data *lookup_flow(struct Qdisc *sch,
-    u32 classid)
+static inline struct atm_flow_data *lookup_flow(struct Qdisc *sch, u32 classid)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 
 	for (flow = p->flows; flow; flow = flow->next)
-		if (flow->classid == classid) break;
+		if (flow->classid == classid)
+			break;
 	return flow;
 }
 
-
-static int atm_tc_graft(struct Qdisc *sch,unsigned long arg,
-    struct Qdisc *new,struct Qdisc **old)
+static int atm_tc_graft(struct Qdisc *sch, unsigned long arg,
+			struct Qdisc *new, struct Qdisc **old)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
-
-	DPRINTK("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",sch,
-	    p,flow,new,old);
-	if (!find_flow(p,flow)) return -EINVAL;
-	if (!new) new = &noop_qdisc;
-	*old = xchg(&flow->q,new);
-	if (*old) qdisc_reset(*old);
+	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
+
+	DPRINTK("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",
+		sch, p, flow, new, old);
+	if (!find_flow(p, flow))
+		return -EINVAL;
+	if (!new)
+		new = &noop_qdisc;
+	*old = xchg(&flow->q, new);
+	if (*old)
+		qdisc_reset(*old);
 	return 0;
 }
 
-
-static struct Qdisc *atm_tc_leaf(struct Qdisc *sch,unsigned long cl)
+static struct Qdisc *atm_tc_leaf(struct Qdisc *sch, unsigned long cl)
 {
-	struct atm_flow_data *flow = (struct atm_flow_data *) cl;
+	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 
-	DPRINTK("atm_tc_leaf(sch %p,flow %p)\n",sch,flow);
+	DPRINTK("atm_tc_leaf(sch %p,flow %p)\n", sch, flow);
 	return flow ? flow->q : NULL;
 }
 
-
-static unsigned long atm_tc_get(struct Qdisc *sch,u32 classid)
+static unsigned long atm_tc_get(struct Qdisc *sch, u32 classid)
 {
-	struct atm_qdisc_data *p __attribute__((unused)) = PRIV(sch);
+	struct atm_qdisc_data *p __maybe_unused = PRIV(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_get(sch %p,[qdisc %p],classid %x)\n",sch,p,classid);
-	flow = lookup_flow(sch,classid);
-	if (flow) flow->ref++;
-	DPRINTK("atm_tc_get: flow %p\n",flow);
-	return (unsigned long) flow;
+	DPRINTK("atm_tc_get(sch %p,[qdisc %p],classid %x)\n", sch, p, classid);
+	flow = lookup_flow(sch, classid);
+	if (flow)
+		flow->ref++;
+	DPRINTK("atm_tc_get: flow %p\n", flow);
+	return (unsigned long)flow;
 }
 
-
 static unsigned long atm_tc_bind_filter(struct Qdisc *sch,
-    unsigned long parent, u32 classid)
+					unsigned long parent, u32 classid)
 {
-	return atm_tc_get(sch,classid);
+	return atm_tc_get(sch, classid);
 }
 
 /*
@@ -159,72 +153,75 @@ static unsigned long atm_tc_bind_filter(struct Qdisc *sch,
  * requested (atm_tc_destroy, etc.). The assumption here is that we never drop
  * anything that still seems to be in use.
  */
-
 static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) cl;
+	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 	struct atm_flow_data **prev;
 
-	DPRINTK("atm_tc_put(sch %p,[qdisc %p],flow %p)\n",sch,p,flow);
-	if (--flow->ref) return;
+	DPRINTK("atm_tc_put(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
+	if (--flow->ref)
+		return;
 	DPRINTK("atm_tc_put: destroying\n");
 	for (prev = &p->flows; *prev; prev = &(*prev)->next)
-		if (*prev == flow) break;
+		if (*prev == flow)
+			break;
 	if (!*prev) {
-		printk(KERN_CRIT "atm_tc_put: class %p not found\n",flow);
+		printk(KERN_CRIT "atm_tc_put: class %p not found\n", flow);
 		return;
 	}
 	*prev = flow->next;
-	DPRINTK("atm_tc_put: qdisc %p\n",flow->q);
+	DPRINTK("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
 	tcf_destroy_chain(flow->filter_list);
 	if (flow->sock) {
 		DPRINTK("atm_tc_put: f_count %d\n",
-		    file_count(flow->sock->file));
+			file_count(flow->sock->file));
 		flow->vcc->pop = flow->old_pop;
 		sockfd_put(flow->sock);
 	}
-	if (flow->excess) atm_tc_put(sch,(unsigned long) flow->excess);
-	if (flow != &p->link) kfree(flow);
+	if (flow->excess)
+		atm_tc_put(sch, (unsigned long)flow->excess);
+	if (flow != &p->link)
+		kfree(flow);
 	/*
 	 * If flow == &p->link, the qdisc no longer works at this point and
 	 * needs to be removed. (By the caller of atm_tc_put.)
 	 */
 }
 
-
-static void sch_atm_pop(struct atm_vcc *vcc,struct sk_buff *skb)
+static void sch_atm_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct atm_qdisc_data *p = VCC2FLOW(vcc)->parent;
 
-	D2PRINTK("sch_atm_pop(vcc %p,skb %p,[qdisc %p])\n",vcc,skb,p);
-	VCC2FLOW(vcc)->old_pop(vcc,skb);
+	D2PRINTK("sch_atm_pop(vcc %p,skb %p,[qdisc %p])\n", vcc, skb, p);
+	VCC2FLOW(vcc)->old_pop(vcc, skb);
 	tasklet_schedule(&p->task);
 }
 
 static const u8 llc_oui_ip[] = {
-	0xaa,		/* DSAP: non-ISO */
-	0xaa,		/* SSAP: non-ISO */
-	0x03,		/* Ctrl: Unnumbered Information Command PDU */
-	0x00,		/* OUI: EtherType */
+	0xaa,			/* DSAP: non-ISO */
+	0xaa,			/* SSAP: non-ISO */
+	0x03,			/* Ctrl: Unnumbered Information Command PDU */
+	0x00,			/* OUI: EtherType */
 	0x00, 0x00,
-	0x08, 0x00 };	/* Ethertype IP (0800) */
+	0x08, 0x00
+};				/* Ethertype IP (0800) */
 
 static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
-    struct rtattr **tca, unsigned long *arg)
+			 struct rtattr **tca, unsigned long *arg)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) *arg;
+	struct atm_flow_data *flow = (struct atm_flow_data *)*arg;
 	struct atm_flow_data *excess = NULL;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
+	struct rtattr *opt = tca[TCA_OPTIONS - 1];
 	struct rtattr *tb[TCA_ATM_MAX];
 	struct socket *sock;
-	int fd,error,hdr_len;
+	int fd, error, hdr_len;
 	void *hdr;
 
 	DPRINTK("atm_tc_change(sch %p,[qdisc %p],classid %x,parent %x,"
-	    "flow %p,opt %p)\n",sch,p,classid,parent,flow,opt);
+		"flow %p,opt %p)\n", sch, p, classid, parent, flow, opt);
 	/*
 	 * The concept of parents doesn't apply for this qdisc.
 	 */
@@ -237,33 +234,36 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	 * class needs to be removed and a new one added. (This may be changed
 	 * later.)
 	 */
-	if (flow) return -EBUSY;
+	if (flow)
+		return -EBUSY;
 	if (opt == NULL || rtattr_parse_nested(tb, TCA_ATM_MAX, opt))
 		return -EINVAL;
-	if (!tb[TCA_ATM_FD-1] || RTA_PAYLOAD(tb[TCA_ATM_FD-1]) < sizeof(fd))
+	if (!tb[TCA_ATM_FD - 1] || RTA_PAYLOAD(tb[TCA_ATM_FD - 1]) < sizeof(fd))
 		return -EINVAL;
-	fd = *(int *) RTA_DATA(tb[TCA_ATM_FD-1]);
-	DPRINTK("atm_tc_change: fd %d\n",fd);
-	if (tb[TCA_ATM_HDR-1]) {
-		hdr_len = RTA_PAYLOAD(tb[TCA_ATM_HDR-1]);
-		hdr = RTA_DATA(tb[TCA_ATM_HDR-1]);
-	}
-	else {
+	fd = *(int *)RTA_DATA(tb[TCA_ATM_FD - 1]);
+	DPRINTK("atm_tc_change: fd %d\n", fd);
+	if (tb[TCA_ATM_HDR - 1]) {
+		hdr_len = RTA_PAYLOAD(tb[TCA_ATM_HDR - 1]);
+		hdr = RTA_DATA(tb[TCA_ATM_HDR - 1]);
+	} else {
 		hdr_len = RFC1483LLC_LEN;
-		hdr = NULL; /* default LLC/SNAP for IP */
+		hdr = NULL;	/* default LLC/SNAP for IP */
 	}
-	if (!tb[TCA_ATM_EXCESS-1]) excess = NULL;
+	if (!tb[TCA_ATM_EXCESS - 1])
+		excess = NULL;
 	else {
-		if (RTA_PAYLOAD(tb[TCA_ATM_EXCESS-1]) != sizeof(u32))
+		if (RTA_PAYLOAD(tb[TCA_ATM_EXCESS - 1]) != sizeof(u32))
 			return -EINVAL;
-		excess = (struct atm_flow_data *) atm_tc_get(sch,
-		    *(u32 *) RTA_DATA(tb[TCA_ATM_EXCESS-1]));
-		if (!excess) return -ENOENT;
+		excess = (struct atm_flow_data *)
+			atm_tc_get(sch, *(u32 *)RTA_DATA(tb[TCA_ATM_EXCESS - 1]));
+		if (!excess)
+			return -ENOENT;
 	}
 	DPRINTK("atm_tc_change: type %d, payload %d, hdr_len %d\n",
-	    opt->rta_type,RTA_PAYLOAD(opt),hdr_len);
-	if (!(sock = sockfd_lookup(fd,&error))) return error; /* f_count++ */
-	DPRINTK("atm_tc_change: f_count %d\n",file_count(sock->file));
+		opt->rta_type, RTA_PAYLOAD(opt), hdr_len);
+	if (!(sock = sockfd_lookup(fd, &error)))
+		return error;	/* f_count++ */
+	DPRINTK("atm_tc_change: f_count %d\n", file_count(sock->file));
 	if (sock->ops->family != PF_ATMSVC && sock->ops->family != PF_ATMPVC) {
 		error = -EPROTOTYPE;
 		goto err_out;
@@ -276,37 +276,37 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			error = -EINVAL;
 			goto err_out;
 		}
-		if (find_flow(p,flow)) {
+		if (find_flow(p, flow)) {
 			error = -EEXIST;
 			goto err_out;
 		}
-	}
-	else {
+	} else {
 		int i;
 		unsigned long cl;
 
 		for (i = 1; i < 0x8000; i++) {
-			classid = TC_H_MAKE(sch->handle,0x8000 | i);
-			if (!(cl = atm_tc_get(sch,classid))) break;
-			atm_tc_put(sch,cl);
+			classid = TC_H_MAKE(sch->handle, 0x8000 | i);
+			if (!(cl = atm_tc_get(sch, classid)))
+				break;
+			atm_tc_put(sch, cl);
 		}
 	}
-	DPRINTK("atm_tc_change: new id %x\n",classid);
-	flow = kmalloc(sizeof(struct atm_flow_data)+hdr_len,GFP_KERNEL);
-	DPRINTK("atm_tc_change: flow %p\n",flow);
+	DPRINTK("atm_tc_change: new id %x\n", classid);
+	flow = kmalloc(sizeof(struct atm_flow_data) + hdr_len, GFP_KERNEL);
+	DPRINTK("atm_tc_change: flow %p\n", flow);
 	if (!flow) {
 		error = -ENOBUFS;
 		goto err_out;
 	}
-	memset(flow,0,sizeof(*flow));
+	memset(flow, 0, sizeof(*flow));
 	flow->filter_list = NULL;
-	if (!(flow->q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops,classid)))
+	if (!(flow->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid)))
 		flow->q = &noop_qdisc;
-	DPRINTK("atm_tc_change: qdisc %p\n",flow->q);
+	DPRINTK("atm_tc_change: qdisc %p\n", flow->q);
 	flow->sock = sock;
-	flow->vcc = ATM_SD(sock); /* speedup */
+	flow->vcc = ATM_SD(sock);	/* speedup */
 	flow->vcc->user_back = flow;
-	DPRINTK("atm_tc_change: vcc %p\n",flow->vcc);
+	DPRINTK("atm_tc_change: vcc %p\n", flow->vcc);
 	flow->old_pop = flow->vcc->pop;
 	flow->parent = p;
 	flow->vcc->pop = sch_atm_pop;
@@ -317,50 +317,53 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	p->link.next = flow;
 	flow->hdr_len = hdr_len;
 	if (hdr)
-		memcpy(flow->hdr,hdr,hdr_len);
+		memcpy(flow->hdr, hdr, hdr_len);
 	else
-		memcpy(flow->hdr,llc_oui_ip,sizeof(llc_oui_ip));
-	*arg = (unsigned long) flow;
+		memcpy(flow->hdr, llc_oui_ip, sizeof(llc_oui_ip));
+	*arg = (unsigned long)flow;
 	return 0;
 err_out:
-	if (excess) atm_tc_put(sch,(unsigned long) excess);
+	if (excess)
+		atm_tc_put(sch, (unsigned long)excess);
 	sockfd_put(sock);
 	return error;
 }
 
-
-static int atm_tc_delete(struct Qdisc *sch,unsigned long arg)
+static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
+	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	DPRINTK("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n",sch,p,flow);
-	if (!find_flow(PRIV(sch),flow)) return -EINVAL;
-	if (flow->filter_list || flow == &p->link) return -EBUSY;
+	DPRINTK("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
+	if (!find_flow(PRIV(sch), flow))
+		return -EINVAL;
+	if (flow->filter_list || flow == &p->link)
+		return -EBUSY;
 	/*
 	 * Reference count must be 2: one for "keepalive" (set at class
 	 * creation), and one for the reference held when calling delete.
 	 */
 	if (flow->ref < 2) {
-		printk(KERN_ERR "atm_tc_delete: flow->ref == %d\n",flow->ref);
+		printk(KERN_ERR "atm_tc_delete: flow->ref == %d\n", flow->ref);
 		return -EINVAL;
 	}
-	if (flow->ref > 2) return -EBUSY; /* catch references via excess, etc.*/
-	atm_tc_put(sch,arg);
+	if (flow->ref > 2)
+		return -EBUSY;	/* catch references via excess, etc. */
+	atm_tc_put(sch, arg);
 	return 0;
 }
 
-
-static void atm_tc_walk(struct Qdisc *sch,struct qdisc_walker *walker)
+static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_walk(sch %p,[qdisc %p],walker %p)\n",sch,p,walker);
-	if (walker->stop) return;
+	DPRINTK("atm_tc_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
+	if (walker->stop)
+		return;
 	for (flow = p->flows; flow; flow = flow->next) {
 		if (walker->count >= walker->skip)
-			if (walker->fn(sch,(unsigned long) flow,walker) < 0) {
+			if (walker->fn(sch, (unsigned long)flow, walker) < 0) {
 				walker->stop = 1;
 				break;
 			}
@@ -368,73 +371,74 @@ static void atm_tc_walk(struct Qdisc *sch,struct qdisc_walker *walker)
 	}
 }
 
-
-static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch,unsigned long cl)
+static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) cl;
+	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 
-	DPRINTK("atm_tc_find_tcf(sch %p,[qdisc %p],flow %p)\n",sch,p,flow);
+	DPRINTK("atm_tc_find_tcf(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	return flow ? &flow->filter_list : &p->link.filter_list;
 }
 
-
 /* --------------------------- Qdisc operations ---------------------------- */
 
-
-static int atm_tc_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = NULL ; /* @@@ */
+	struct atm_flow_data *flow = NULL;	/* @@@ */
 	struct tcf_result res;
 	int result;
 	int ret = NET_XMIT_POLICED;
 
-	D2PRINTK("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
-	result = TC_POLICE_OK; /* be nice to gcc */
+	D2PRINTK("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	result = TC_POLICE_OK;	/* be nice to gcc */
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
-	    !(flow = (struct atm_flow_data *) atm_tc_get(sch,skb->priority)))
+	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority)))
 		for (flow = p->flows; flow; flow = flow->next)
 			if (flow->filter_list) {
-				result = tc_classify(skb,flow->filter_list,
-				    &res);
-				if (result < 0) continue;
-				flow = (struct atm_flow_data *) res.class;
-				if (!flow) flow = lookup_flow(sch,res.classid);
+				result = tc_classify(skb, flow->filter_list,
+						     &res);
+				if (result < 0)
+					continue;
+				flow = (struct atm_flow_data *)res.class;
+				if (!flow)
+					flow = lookup_flow(sch, res.classid);
 				break;
 			}
-	if (!flow) flow = &p->link;
+	if (!flow)
+		flow = &p->link;
 	else {
 		if (flow->vcc)
 			ATM_SKB(skb)->atm_options = flow->vcc->atm_options;
-			/*@@@ looks good ... but it's not supposed to work :-)*/
+		/*@@@ looks good ... but it's not supposed to work :-) */
 #ifdef CONFIG_NET_CLS_POLICE
 		switch (result) {
-			case TC_POLICE_SHOT:
-				kfree_skb(skb);
-				break;
-			case TC_POLICE_RECLASSIFY:
-				if (flow->excess) flow = flow->excess;
-				else {
-					ATM_SKB(skb)->atm_options |=
-					    ATM_ATMOPT_CLP;
-					break;
-				}
-				/* fall through */
-			case TC_POLICE_OK:
-				/* fall through */
-			default:
+		case TC_POLICE_SHOT:
+			kfree_skb(skb);
+			break;
+		case TC_POLICE_RECLASSIFY:
+			if (flow->excess)
+				flow = flow->excess;
+			else {
+				ATM_SKB(skb)->atm_options |= ATM_ATMOPT_CLP;
 				break;
+			}
+			/* fall through */
+		case TC_POLICE_OK:
+			/* fall through */
+		default:
+			break;
 		}
 #endif
 	}
 	if (
 #ifdef CONFIG_NET_CLS_POLICE
-	    result == TC_POLICE_SHOT ||
+		   result == TC_POLICE_SHOT ||
 #endif
-	    (ret = flow->q->enqueue(skb,flow->q)) != 0) {
+		   (ret = flow->q->enqueue(skb, flow->q)) != 0) {
 		sch->qstats.drops++;
-		if (flow) flow->qstats.drops++;
+		if (flow)
+			flow->qstats.drops++;
 		return ret;
 	}
 	sch->bstats.bytes += skb->len;
@@ -458,7 +462,6 @@ static int atm_tc_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 	return NET_XMIT_BYPASS;
 }
 
-
 /*
  * Dequeue packets and send them over ATM. Note that we quite deliberately
  * avoid checking net_device's flow control here, simply because sch_atm
@@ -466,167 +469,163 @@ static int atm_tc_enqueue(struct sk_buff *skb,struct Qdisc *sch)
  * non-ATM interfaces.
  */
 
-
 static void sch_atm_dequeue(unsigned long data)
 {
-	struct Qdisc *sch = (struct Qdisc *) data;
+	struct Qdisc *sch = (struct Qdisc *)data;
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 	struct sk_buff *skb;
 
-	D2PRINTK("sch_atm_dequeue(sch %p,[qdisc %p])\n",sch,p);
+	D2PRINTK("sch_atm_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	for (flow = p->link.next; flow; flow = flow->next)
 		/*
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
 		 */
 		while ((skb = flow->q->dequeue(flow->q))) {
-			if (!atm_may_send(flow->vcc,skb->truesize)) {
-				(void) flow->q->ops->requeue(skb,flow->q);
+			if (!atm_may_send(flow->vcc, skb->truesize)) {
+				(void)flow->q->ops->requeue(skb, flow->q);
 				break;
 			}
-			D2PRINTK("atm_tc_dequeue: sending on class %p\n",flow);
+			D2PRINTK("atm_tc_dequeue: sending on class %p\n", flow);
 			/* remove any LL header somebody else has attached */
 			skb_pull(skb, skb_network_offset(skb));
 			if (skb_headroom(skb) < flow->hdr_len) {
 				struct sk_buff *new;
 
-				new = skb_realloc_headroom(skb,flow->hdr_len);
+				new = skb_realloc_headroom(skb, flow->hdr_len);
 				dev_kfree_skb(skb);
-				if (!new) continue;
+				if (!new)
+					continue;
 				skb = new;
 			}
 			D2PRINTK("sch_atm_dequeue: ip %p, data %p\n",
 				 skb_network_header(skb), skb->data);
 			ATM_SKB(skb)->vcc = flow->vcc;
-			memcpy(skb_push(skb,flow->hdr_len),flow->hdr,
-			    flow->hdr_len);
+			memcpy(skb_push(skb, flow->hdr_len), flow->hdr,
+			       flow->hdr_len);
 			atomic_add(skb->truesize,
 				   &sk_atm(flow->vcc)->sk_wmem_alloc);
 			/* atm.atm_options are already set by atm_tc_enqueue */
-			(void) flow->vcc->send(flow->vcc,skb);
+			flow->vcc->send(flow->vcc, skb);
 		}
 }
 
-
 static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct sk_buff *skb;
 
-	D2PRINTK("atm_tc_dequeue(sch %p,[qdisc %p])\n",sch,p);
+	D2PRINTK("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
 	skb = p->link.q->dequeue(p->link.q);
-	if (skb) sch->q.qlen--;
+	if (skb)
+		sch->q.qlen--;
 	return skb;
 }
 
-
-static int atm_tc_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	int ret;
 
-	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
-	ret = p->link.q->ops->requeue(skb,p->link.q);
+	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	ret = p->link.q->ops->requeue(skb, p->link.q);
 	if (!ret) {
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-    } else {
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+	} else {
 		sch->qstats.drops++;
 		p->link.qstats.drops++;
 	}
 	return ret;
 }
 
-
 static unsigned int atm_tc_drop(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 	unsigned int len;
 
-	DPRINTK("atm_tc_drop(sch %p,[qdisc %p])\n",sch,p);
+	DPRINTK("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
 	for (flow = p->flows; flow; flow = flow->next)
 		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
 			return len;
 	return 0;
 }
 
-
-static int atm_tc_init(struct Qdisc *sch,struct rtattr *opt)
+static int atm_tc_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 
-	DPRINTK("atm_tc_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
+	DPRINTK("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->flows = &p->link;
-	if(!(p->link.q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops,
-					   sch->handle)))
+	if (!(p->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					    sch->handle)))
 		p->link.q = &noop_qdisc;
-	DPRINTK("atm_tc_init: link (%p) qdisc %p\n",&p->link,p->link.q);
+	DPRINTK("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
 	p->link.filter_list = NULL;
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
 	p->link.classid = sch->handle;
 	p->link.ref = 1;
 	p->link.next = NULL;
-	tasklet_init(&p->task,sch_atm_dequeue,(unsigned long) sch);
+	tasklet_init(&p->task, sch_atm_dequeue, (unsigned long)sch);
 	return 0;
 }
 
-
 static void atm_tc_reset(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_reset(sch %p,[qdisc %p])\n",sch,p);
-	for (flow = p->flows; flow; flow = flow->next) qdisc_reset(flow->q);
+	DPRINTK("atm_tc_reset(sch %p,[qdisc %p])\n", sch, p);
+	for (flow = p->flows; flow; flow = flow->next)
+		qdisc_reset(flow->q);
 	sch->q.qlen = 0;
 }
 
-
 static void atm_tc_destroy(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_destroy(sch %p,[qdisc %p])\n",sch,p);
+	DPRINTK("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
 	/* races ? */
 	while ((flow = p->flows)) {
 		tcf_destroy_chain(flow->filter_list);
 		flow->filter_list = NULL;
 		if (flow->ref > 1)
-			printk(KERN_ERR "atm_destroy: %p->ref = %d\n",flow,
-			    flow->ref);
-		atm_tc_put(sch,(unsigned long) flow);
+			printk(KERN_ERR "atm_destroy: %p->ref = %d\n", flow,
+			       flow->ref);
+		atm_tc_put(sch, (unsigned long)flow);
 		if (p->flows == flow) {
 			printk(KERN_ERR "atm_destroy: putting flow %p didn't "
-			    "kill it\n",flow);
-			p->flows = flow->next; /* brute force */
+			       "kill it\n", flow);
+			p->flows = flow->next;	/* brute force */
 			break;
 		}
 	}
 	tasklet_kill(&p->task);
 }
 
-
 static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
-    struct sk_buff *skb, struct tcmsg *tcm)
+			     struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct atm_qdisc_data *p = PRIV(sch);
-	struct atm_flow_data *flow = (struct atm_flow_data *) cl;
+	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct rtattr *rta;
 
 	DPRINTK("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
-	    sch,p,flow,skb,tcm);
-	if (!find_flow(p,flow)) return -EINVAL;
+		sch, p, flow, skb, tcm);
+	if (!find_flow(p, flow))
+		return -EINVAL;
 	tcm->tcm_handle = flow->classid;
 	tcm->tcm_info = flow->q->handle;
-	rta = (struct rtattr *) b;
-	RTA_PUT(skb,TCA_OPTIONS,0,NULL);
-	RTA_PUT(skb,TCA_ATM_HDR,flow->hdr_len,flow->hdr);
+	rta = (struct rtattr *)b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	RTA_PUT(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr);
 	if (flow->vcc) {
 		struct sockaddr_atmpvc pvc;
 		int state;
@@ -635,16 +634,16 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		pvc.sap_addr.itf = flow->vcc->dev ? flow->vcc->dev->number : -1;
 		pvc.sap_addr.vpi = flow->vcc->vpi;
 		pvc.sap_addr.vci = flow->vcc->vci;
-		RTA_PUT(skb,TCA_ATM_ADDR,sizeof(pvc),&pvc);
+		RTA_PUT(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc);
 		state = ATM_VF2VS(flow->vcc->flags);
-		RTA_PUT(skb,TCA_ATM_STATE,sizeof(state),&state);
+		RTA_PUT(skb, TCA_ATM_STATE, sizeof(state), &state);
 	}
 	if (flow->excess)
-		RTA_PUT(skb,TCA_ATM_EXCESS,sizeof(u32),&flow->classid);
+		RTA_PUT(skb, TCA_ATM_EXCESS, sizeof(u32), &flow->classid);
 	else {
 		static u32 zero;
 
-		RTA_PUT(skb,TCA_ATM_EXCESS,sizeof(zero),&zero);
+		RTA_PUT(skb, TCA_ATM_EXCESS, sizeof(zero), &zero);
 	}
 	rta->rta_len = skb_tail_pointer(skb) - b;
 	return skb->len;
@@ -655,9 +654,9 @@ rtattr_failure:
 }
 static int
 atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
-	struct gnet_dump *d)
+			struct gnet_dump *d)
 {
-	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
+	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
 	flow->qstats.qlen = flow->q->q.qlen;
 
@@ -674,38 +673,35 @@ static int atm_tc_dump(struct Qdisc *sch, struct sk_buff *skb)
 }
 
 static struct Qdisc_class_ops atm_class_ops = {
-	.graft		=	atm_tc_graft,
-	.leaf		=	atm_tc_leaf,
-	.get		=	atm_tc_get,
-	.put		=	atm_tc_put,
-	.change		=	atm_tc_change,
-	.delete		=	atm_tc_delete,
-	.walk		=	atm_tc_walk,
-	.tcf_chain	=	atm_tc_find_tcf,
-	.bind_tcf	=	atm_tc_bind_filter,
-	.unbind_tcf	=	atm_tc_put,
-	.dump		=	atm_tc_dump_class,
-	.dump_stats	=	atm_tc_dump_class_stats,
+	.graft		= atm_tc_graft,
+	.leaf		= atm_tc_leaf,
+	.get		= atm_tc_get,
+	.put		= atm_tc_put,
+	.change		= atm_tc_change,
+	.delete		= atm_tc_delete,
+	.walk		= atm_tc_walk,
+	.tcf_chain	= atm_tc_find_tcf,
+	.bind_tcf	= atm_tc_bind_filter,
+	.unbind_tcf	= atm_tc_put,
+	.dump		= atm_tc_dump_class,
+	.dump_stats	= atm_tc_dump_class_stats,
 };
 
 static struct Qdisc_ops atm_qdisc_ops = {
-	.next		=	NULL,
-	.cl_ops		=	&atm_class_ops,
-	.id		=	"atm",
-	.priv_size	=	sizeof(struct atm_qdisc_data),
-	.enqueue	=	atm_tc_enqueue,
-	.dequeue	=	atm_tc_dequeue,
-	.requeue	=	atm_tc_requeue,
-	.drop		=	atm_tc_drop,
-	.init		=	atm_tc_init,
-	.reset		=	atm_tc_reset,
-	.destroy	=	atm_tc_destroy,
-	.change		=	NULL,
-	.dump		=	atm_tc_dump,
-	.owner		=	THIS_MODULE,
+	.cl_ops		= &atm_class_ops,
+	.id		= "atm",
+	.priv_size	= sizeof(struct atm_qdisc_data),
+	.enqueue	= atm_tc_enqueue,
+	.dequeue	= atm_tc_dequeue,
+	.requeue	= atm_tc_requeue,
+	.drop		= atm_tc_drop,
+	.init		= atm_tc_init,
+	.reset		= atm_tc_reset,
+	.destroy	= atm_tc_destroy,
+	.dump		= atm_tc_dump,
+	.owner		= THIS_MODULE,
 };
 
-
 static int __init atm_init(void)
 {
 	return register_qdisc(&atm_qdisc_ops);
