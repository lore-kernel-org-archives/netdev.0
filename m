From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 21 Nov 2007 12:48:47 +0100
Message-ID: <47441B1F.5090505@trash.net>
References: <20071121.191840.07671434.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	t.kudoh@aist.go.jp
To: Ryousei Takano <takano-ryousei@aist.go.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61652 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252AbXKULtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 06:49:01 -0500
In-Reply-To: <20071121.191840.07671434.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ryousei Takano wrote:
> This patch includes the PSPacer (Precise Software Pacer) qdisc
> module, which achieves precise transmission bandwidth control.
> You can find more information at the project web page
> (http://www.gridmpi.org/gridtcp.jsp).


Looks good, but please run checkpatch over it. A few more comments
below.

+/* Precise Software Pacer section */
+
+#define TC_PSP_MAXDEPTH (8)
+
+typedef long long gapclock_t;
+
+enum {
+	MODE_NORMAL = 0,
+	MODE_STATIC = 1,
+};
+
+struct tc_psp_copt
+{
+	__u32	level;
+	__u32	mode;
+	__u32	rate;


What unit is rate measures in? Is 32 bit really enough?


> +static struct sk_buff *alloc_gap_packet(struct Qdisc* sch, int size)
> +{
> +	struct sk_buff *skb;
> +	struct net_device *dev = sch->dev;
> +	unsigned char *pkt;
> +	int pause_time = 0;
> +	int pktsize = size + 2;
> +
> +	skb = alloc_skb(pktsize, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, 2);
> +
> +	pkt = skb->data;
> +	memset(pkt, 0xff, pktsize);
> +	pkt[0] = 0x01; /* dst address: 01:80:c2:00:00:01 */
> +	pkt[1] = 0x80;
> +	pkt[2] = 0xc2;
> +	pkt[3] = 0x00;
> +	pkt[4] = 0x00;
> +	pkt[5] = 0x01;
> +	memcpy(pkt + 6, dev->dev_addr, ETH_ALEN /* dev->addr_len */);
> +
> +	pkt[12] = 0x88; /* MAC control:        88 08 */
> +	pkt[13] = 0x08;
> +	pkt[14] = 0;    /* MAC control opcode: 00 01 */
> +	pkt[15] = 1;

A few #defines for all these magic values and a struct for
the header would make this nicer.

> +	pkt[16] = pause_time >> 8;
> +	pkt[17] = pause_time;
> +
> +	skb_put(skb, size);
> +
> +	skb->dev = sch->dev;
> +	skb->protocol = ETH_P_802_3;
> +	skb_reset_network_header(skb); /* It is refered at dev_queue_xmit_nit(). */
> +
> +	return skb;
> +}
> +

> +static struct psp_class *psp_classify(struct sk_buff *skb, struct Qdisc *sch,
> +				      int *qres)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl;
> +	struct tcf_result res;
> +	struct tcf_proto *tcf;
> +	int result;
> +
> +	if ((cl = psp_find(skb->priority, sch)) != NULL && cl->level == 0)
> +		return cl;
> +	tcf = q->filter_list;

This should handle tc actions.

> +	if (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {

It seems you can have a hierarchy of classes, so why aren't
you classifying recursively?

> +		if ((cl = (struct psp_class *)res.class) == NULL) {
> +			if ((cl = psp_find(res.classid, sch)) == NULL) {
> +				/* filter selected invalid classid */
> +				goto try_default;
> +			}
> +		}
> +		if (is_leaf_class(cl))
> +			return cl; /* hit leaf class */
> +
> +		/* apply inner filter chain */
> +		tcf = cl->filter_list;
> +	}
> +
> + try_default:
> +	/* classification failed, try default class */
> +	cl = psp_find(TC_H_MAKE(TC_H_MAJ(sch->handle), q->defcls), sch);
> +	if (cl == NULL || cl->level > 0)
> +		return PSP_DIRECT;

I'd prefer if you don't follow the HTB way of using a "direct class"
for unclassified packets, it makes noticing when classification is
incomplete harder and thats what the default class is for.

> +	return cl;
> +}
> +
> +static inline void psp_activate(struct psp_sched_data *q, struct psp_class *cl)
> +{
> +	cl->activity |= FLAG_ACTIVE;
> +	list_add_tail(&cl->dlist, &q->drop_list);
> +}
> +
> +static inline void psp_deactivate(struct psp_sched_data *q,
> +				  struct psp_class *cl)
> +{
> +	cl->activity &= MASK_ACTIVE;

MASK_ACTIVE is misleading, its MASK_INACTIVE. I'd suggest
to simply use &= ~FLAG_ACTIVE or cl->q.qlen != 0 (which
indicates an active class).

> +	list_del_init(&cl->dlist);
> +}
> +
> +#define COUNT(x, y) (((x) + ((y) - 1)) / (y))

DIV_ROUND_UP

> +static void add_leaf_class(struct psp_sched_data *q, struct psp_class *cl)
> +{
> +	struct psp_class *p;
> +	int mtu = q->mtu + FCS;
> +
> +	/* chain normal/pacing class list */
> +	switch (cl->mode) {
> +	case MODE_NORMAL:
> +		list_add_tail(&cl->plist, &q->normal_list);
> +		break;
> +	case MODE_STATIC:
> +		cl->gapsize = (((q->max_rate / 1000) * mtu)
> +			       / (cl->rate / 1000)) - mtu;
> +		cl->gapsize -= (HW_GAP + FCS) * COUNT(q->max_rate, cl->rate);
> +		cl->gapsize = max_t(int, cl->gapsize, MIN_GAP);
> +		cl->activity |= FLAG_DMARK;
> +		list_for_each_entry(p, &q->pacing_list, plist) {
> +			if (cl->gapsize < p->gapsize)
> +				break;
> +		}
> +		list_add_tail(&cl->plist, &p->plist);
> +		break;
> +	}
> +}
> +
> +static int recalc_gapsize(struct sk_buff* skb, struct Qdisc *sch)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	int ret;
> +	struct psp_class *cl = psp_classify(skb, sch, &ret);
> +	int len = skb->len;
> +	int gapsize = 0;
> +
> +	switch (cl->mode) {
> +	case MODE_STATIC:
> +		gapsize = cl->gapsize;
> +		if (len < q->mtu) { /* workaround for overflow */
> +			if (gapsize > INT_MAX / len) {
> +				gapsize = (gapsize / q->mtu) * len;
> +			} else {
> +				gapsize = gapsize * len / q->mtu;

Shouldn't these also be rounded up?

> +			}
> +		}
> +		break;
> +	}
> +
> +	return max_t(int, gapsize, MIN_GAP);
> +}
> +
> +/* Update byte clocks
> + *   a packet is sent out:
> + *     Qdisc's clock += packet length;
> + *     if the class is the pacing class
> + *         class's clock += packet length + gap length
> + */
> +static void update_clocks(struct sk_buff *skb, struct Qdisc *sch, 
> +			  struct psp_class *cl)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	int len = skb->len;

skb->len is unsigned (also in a few other spots)

> +	int gaplen;
> +
> +	q->clock += len;
> +	if (cl == NULL || cl->mode == MODE_NORMAL)
> +		return;
> +
> +	/* pacing class */
> +	gaplen = recalc_gapsize(skb, sch);
> +	if (!(cl->activity & FLAG_DMARK)) {
> +		cl->clock += len + gaplen;
> +	} else { /* reset class clock */
> +		cl->activity &= MASK_DMARK;
> +		cl->clock = q->clock + gaplen;
> +	}
> +}
> +
> +/* Lookup next target class
> + * Firstly, search the pacing class list:
> + *     If the Qdisc's clock < the class's clock then the class is selected.
> + * Secondly, search the normal class list.
> + * 
> + * Finally, a gap packet is inserted, because there is not any packets
> + * to send out.  And it returns the size of the gap packet.
> + */
> +static struct psp_class *lookup_next_class(struct Qdisc *sch, int *gapsize)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl, *next = NULL;
> +	gapclock_t diff;
> +	int shortest;
> +
> +	/* pacing class */
> +	shortest = q->mtu;
> +	list_for_each_entry(cl, &q->pacing_list, plist) {
> +		diff = cl->clock - q->clock;
> +		if (diff > 0) {
> +			if (shortest > (int)diff)
> +				shortest = (int)diff;

Is diff guaranteed not to exceed an int?

> +			continue;
> +		}
> +		if (!(cl->activity & FLAG_ACTIVE)) {
> +			cl->activity |= FLAG_DMARK;
> +			continue;
> +		}
> +
> +		if (next == NULL)
> +			next = cl;
> +	}
> +	if (next)
> +		return next;
> +	
> +
> +	/* normal class */
> +	list_for_each_entry(cl, &q->normal_list, plist) {
> +		if (!(cl->activity & FLAG_ACTIVE))
> +			continue;
> +
> +		list_move_tail(&cl->plist, &q->normal_list);
> +		return cl;
> +	}
> +
> +	/* gap packet */
> +	*gapsize = max_t(int, shortest, 18);

sizeof(struct gap_pkt) or something like that?

> +	return NULL;
> +}
> +
> +static int psp_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	int ret;
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl = psp_classify(skb, sch, &ret);
> +
> +	if (cl == PSP_DIRECT) {
> +		/* enqueue to helper queue */
> +		__skb_queue_tail(&q->requeue, skb);
> +		q->direct_pkts++;
> +	} else if (cl == NULL) {
> +		kfree_skb(skb);
> +		sch->qstats.drops++;
> +		return NET_XMIT_DROP;
> +	} else {
> +		ret = cl->qdisc->ops->enqueue(skb, cl->qdisc);
> +		if (ret != NET_XMIT_SUCCESS) {
> +			sch->qstats.drops++;
> +			cl->qstats.drops++;
> +			return ret;
> +		}
> +
> +		cl->bstats.packets++;
> +		cl->bstats.bytes += skb->len;
> +		if (!(cl->activity & FLAG_ACTIVE))
> +			psp_activate(q, cl);
> +	}
> +
> +	sch->q.qlen++;
> +	sch->bstats.packets++;
> +	sch->bstats.bytes += skb->len;
> +
> +	return NET_XMIT_SUCCESS;
> +}
> +
> +static int psp_requeue(struct sk_buff *skb, struct Qdisc* sch)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +
> +	__skb_queue_head(&q->requeue, skb);
> +	sch->q.qlen++;
> +	sch->qstats.requeues++;
> +
> +	return NET_XMIT_SUCCESS;
> +}
> +
> +static struct sk_buff *psp_dequeue(struct Qdisc* sch)
> +{
> +	struct sk_buff *skb = NULL;
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl;
> +	int gapsize;
> +
> +	if (sch->q.qlen == 0)
> +		return NULL;
> +
> +	/* requeue */
> +	if ((skb = __skb_dequeue(&q->requeue)) != NULL) {
> +		sch->q.qlen--;
> +		return skb;
> +	}
> +
> +	/* normal/pacing class */
> +	cl = lookup_next_class(sch, &gapsize);
> +	if (cl != NULL) {
> +		skb = cl->qdisc->ops->dequeue(cl->qdisc);
> +		if (skb == NULL) {
> +			return NULL;

Shouldn't it also send a gap packet in this case?

> +		}
> +		sch->q.qlen--;
> +
> +		goto update_clocks;
> +	}
> +
> +	/* gap packets */
> +	skb = skb_clone(q->gap, GFP_ATOMIC);
> +	BUG_TRAP(skb);

This can fail and needs a proper check.

> +	skb_trim(skb, gapsize);
> +	cl = NULL;

cl is NULL already

> +	q->xstats.bytes += gapsize;
> +	q->xstats.packets++;
> +
> + update_clocks:
> +	update_clocks(skb, sch, cl);
> +	if (cl && cl->qdisc->q.qlen == 0)
> +		psp_deactivate(q, cl);
> +	return skb;
> +}
> +
> +static unsigned int psp_drop(struct Qdisc* sch)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl;
> +	unsigned int len;
> +
> +	list_for_each_entry(cl, &q->drop_list, dlist) {
> +		if (cl->qdisc->ops->drop != NULL
> +		    && (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
> +			if (cl->qdisc->q.qlen == 0) {
> +				psp_deactivate(q, cl);
> +			} else {
> +				list_move_tail(&cl->dlist, &q->drop_list);
> +			}
> +			cl->qstats.drops++;
> +			sch->qstats.drops++;
> +			sch->q.qlen--;
> +			return len;
> +		}
> +	}
> +	return 0;
> +}
> +
> +static void psp_reset(struct Qdisc* sch)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl;
> +	int i;
> +
> +	for (i = 0; i < PSP_HSIZE; i++) {
> +		list_for_each_entry(cl, &q->hash[i], hlist) {
> +			if (is_leaf_class(cl) && cl->qdisc != NULL)
> +				qdisc_reset(cl->qdisc);
> +		}
> +	}
> +
> +	sch->q.qlen = 0;
> +}
> +
> +static void psp_destroy_class(struct Qdisc* sch, struct psp_class *cl)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +
> +	if (cl->mode == MODE_STATIC) {
> +		if (cl->parent) {
> +			cl->parent->allocated_rate -= cl->rate;
> +		} else {
> +			q->allocated_rate -= cl->rate;
> +		}
> +	}
> +	if (is_leaf_class(cl)) {
> +		sch->q.qlen -= cl->qdisc->q.qlen;
> +		qdisc_destroy(cl->qdisc);
> +	}
> +
> +	tcf_destroy_chain(q->filter_list);
> +
> +	while (!list_empty(&cl->children))
> +		psp_destroy_class(sch, list_entry(cl->children.next,
> +						  struct psp_class, sibling));
> +
> +	list_del(&cl->hlist);
> +	list_del(&cl->sibling);
> +	psp_deactivate(q, cl);
> +	if (is_leaf_class(cl))
> +		list_del(&cl->plist);
> +	kfree(cl);
> +}
> +
> +static void psp_destroy(struct Qdisc* sch)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +
> +	tcf_destroy_chain(q->filter_list);
> +
> +	while (!list_empty(&q->root))
> +		psp_destroy_class(sch, list_entry(q->root.next,
> +						  struct psp_class, sibling));
> +	__skb_queue_purge(&q->requeue);
> +
> +	/* free gap packet */
> +	kfree_skb(q->gap);
> +}
> +
> +static int psp_change_qdisc(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct rtattr *tb[TCA_PSP_QOPT];
> +	struct tc_psp_qopt *qopt;
> +
> +	if (!opt || rtattr_parse_nested(tb, TCA_PSP_QOPT, opt) ||
> +	    tb[TCA_PSP_QOPT-1] == NULL ||
> +	    RTA_PAYLOAD(tb[TCA_PSP_QOPT-1]) < sizeof(*qopt)) {
> +		return -EINVAL;
> +	}
> +
> +	qopt = RTA_DATA(tb[TCA_PSP_QOPT-1]);
> +
> +	sch_tree_lock(sch);
> +	q->defcls = qopt->defcls;
> +	if (qopt->rate)
> +		q->max_rate = qopt->rate;
> +	sch_tree_unlock(sch);
> +	return 0;
> +}
> +
> +static int psp_init(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct rtattr *tb[TCA_PSP_QOPT];
> +	struct net_device *dev = sch->dev;
> +	struct tc_psp_qopt *qopt;
> +	struct ethtool_cmd cmd = { ETHTOOL_GSET };
> +	int i;
> +
> +	if (dev->type != ARPHRD_ETHER) {
> +		printk(KERN_ERR "psp: PSPacer only supports Ethernet " \
> +		       "devices.\n");
> +		return -EINVAL;
> +	}
> +
> +#ifdef NETIF_F_TSO
> +	/* check TSO support */
> +	if (ethtool_op_get_tso(dev)) {
> +		printk(KERN_ERR "psp: PSPacer does not support TSO.  " \
> +		       "You must disable it: \"ethtool -K %s tso off\"\n",
> +		       dev->name);
> +		return -EINVAL;
> +	}
> +#endif
> +
> +	if (!opt || rtattr_parse_nested(tb, TCA_PSP_QOPT, opt) ||
> +	    tb[TCA_PSP_QOPT-1] == NULL ||
> +	    RTA_PAYLOAD(tb[TCA_PSP_QOPT-1]) < sizeof(*qopt)) {
> +		return -EINVAL;
> +	}
> +
> +	qopt = RTA_DATA(tb[TCA_PSP_QOPT-1]);
> +
> +	memset(q, 0, sizeof(*q));
> +	q->defcls = qopt->defcls;
> +	q->mtu = dev->mtu + dev->hard_header_len;
> +	q->gap = alloc_gap_packet(sch, q->mtu);
> +	if (q->gap == NULL)
> +		return -ENOBUFS;
> +	if (qopt->rate == 0) {
> +		/* set qdisc max rate.  If the kernel supports ethtool ioctl,
> +		 * it sets to that value, otherwise it statically sets to 
> +		 * the GbE transmission rate (i.e. 125MB/s). */
> +		/* NOTE: Since ethtool's {cmd.speed} specifies Mbps, 
> +		   the value is converted in units of byte/sec */
> +		q->max_rate = 125000000;
> +
> +		if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
> +			if (dev->ethtool_ops->get_settings(dev, &cmd) == 0) {
> +				q->max_rate = BIT2BYTE(cmd.speed * 1000000);
> +			}
> +		}
> +	} else {
> +		q->max_rate = qopt->rate;
> +	}
> +
> +	INIT_LIST_HEAD(&q->root);
> +	for (i = 0; i < PSP_HSIZE; i++)
> +		INIT_LIST_HEAD(q->hash + i);
> +	INIT_LIST_HEAD(&q->drop_list);
> +	INIT_LIST_HEAD(&q->pacing_list);
> +	INIT_LIST_HEAD(&q->normal_list);
> +	skb_queue_head_init(&q->requeue);
> +
> +	return 0;
> +}
> +
> +static int psp_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct rtattr *rta;
> +	struct tc_psp_qopt qopt;
> +
> +	qopt.defcls = q->defcls;
> +	qopt.rate = q->max_rate;
> +	qopt.direct_pkts = q->direct_pkts;
> +	rta = (struct rtattr*)b;
> +	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
> +	RTA_PUT(skb, TCA_PSP_QOPT, sizeof(qopt), &qopt);
> +	rta->rta_len = skb_tail_pointer(skb) - b;
> +
> +	return skb->len;
> +
> +rtattr_failure:
> +	skb_trim(skb, skb_tail_pointer(skb) - skb->data);
> +	return -1;
> +}
> +
> +static int psp_dump_qdisc_stats(struct Qdisc *sch, struct gnet_dump *d)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +
> +	return gnet_stats_copy_app(d, &q->xstats, sizeof(q->xstats));
> +}
> +
> +static int psp_dump_class(struct Qdisc *sch, unsigned long arg, 
> +			  struct sk_buff *skb, struct tcmsg *tcm)
> +{
> +	struct psp_class *cl = (struct psp_class *)arg;
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct rtattr *rta;
> +	struct tc_psp_copt copt;
> +
> +	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
> +	tcm->tcm_handle = cl->classid;
> +	if (is_leaf_class(cl) && cl->qdisc != NULL) {

cl->qdisc can't be NULL, at least you assume that everywhere else.

> +		tcm->tcm_info = cl->qdisc->handle;
> +		cl->qstats.qlen = cl->qdisc->q.qlen;
> +	}
> +
> +	rta = (struct rtattr *)b;
> +	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
> +	memset(&copt, 0, sizeof(copt));
> +	copt.level = cl->level;
> +	copt.mode = cl->mode;
> +	copt.rate = cl->max_rate;
> +	RTA_PUT(skb, TCA_PSP_COPT, sizeof(copt), &copt);
> +	RTA_PUT(skb, TCA_PSP_QOPT, 0, NULL);
> +	rta->rta_len = skb_tail_pointer(skb) - b;
> +
> +	return skb->len;
> + rtattr_failure:
> +	skb_trim(skb, b - skb->data);
> +	return -1;
> +}
> +
> +static int psp_dump_class_stats(struct Qdisc *sch, unsigned long arg,
> +				struct gnet_dump *d)
> +{
> +	struct psp_class *cl = (struct psp_class *)arg;
> +
> +	if (gnet_stats_copy_basic(d, &cl->bstats) < 0
> +	    || gnet_stats_copy_queue(d, &cl->qstats) < 0)

I personally don't like the "||" on continuation line style. I don't
think its used anywhere in net/sched so far, please don't introduce it.

> +		return -1;
> +	return 0;
> +}
> +
> +static int psp_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
> +		     struct Qdisc **old)
> +{
> +	struct psp_class *cl = (struct psp_class *)arg;
> +
> +	if (cl == NULL)
> +		return -ENOENT;
> +	if (!is_leaf_class(cl))
> +		return -EINVAL;
> +	if (new == NULL) {
> +		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
> +					cl->classid);
> +		if (new == NULL)
> +			new = &noop_qdisc;
> +	}
> +
> +	sch_tree_lock(sch);
> +	*old = xchg(&cl->qdisc, new);
> +	sch->q.qlen -= (*old)->q.qlen;

Needs qdisc_tree_decrease_qlen

> +	qdisc_reset(*old);
> +	sch_tree_unlock(sch);
> +	return 0;
> +}
> +
> +static struct Qdisc *psp_leaf(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct psp_class *cl = (struct psp_class *)arg;
> +	return (cl != NULL && is_leaf_class(cl)) ? cl->qdisc : NULL;
> +}
> +
> +static unsigned long psp_get(struct Qdisc *sch, u32 classid)
> +{
> +	struct psp_class *cl = psp_find(classid, sch);
> +	if (cl)
> +		cl->refcnt++;
> +	return (unsigned long)cl;
> +}
> +
> +static void psp_put(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct psp_class *cl = (struct psp_class *)arg;
> +
> +	if (--cl->refcnt == 0)
> +		psp_destroy_class(sch, cl);
> +}
> +
> +static int psp_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
> +			    struct rtattr **tca, unsigned long *arg)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl = (struct psp_class *)*arg, *parent;
> +	struct rtattr *opt = tca[TCA_OPTIONS-1];
> +	struct rtattr *tb[TCA_PSP_QOPT];
> +	struct tc_psp_copt *copt;
> +	unsigned int limit;
> +
> +	if (opt == NULL
> +	    || rtattr_parse(tb, TCA_PSP_QOPT, RTA_DATA(opt), RTA_PAYLOAD(opt)))
> +		return -EINVAL;
> +
> +	copt = RTA_DATA(tb[TCA_PSP_COPT - 1]);
> +
> +	parent = (parentid == TC_H_ROOT ? NULL : psp_find(parentid, sch));
> +
> +	if (cl == NULL) { /* create new class */
> +		struct Qdisc *new_q;
> +
> +		cl = kmalloc(sizeof(struct psp_class), GFP_KERNEL);
> +		if (cl == NULL)
> +			return -ENOBUFS;
> +		memset(cl, 0, sizeof(struct psp_class));
> +		cl->refcnt = 1;
> +		INIT_LIST_HEAD(&cl->sibling);
> +		INIT_LIST_HEAD(&cl->children);
> +		INIT_LIST_HEAD(&cl->hlist);
> +		INIT_LIST_HEAD(&cl->dlist);
> +		INIT_LIST_HEAD(&cl->plist);
> +
> +		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
> +
> +		sch_tree_lock(sch);
> +		while (parent && !is_leaf_class(parent)) {
> +			/* turn parent into inner node */
> +			sch->q.qlen -= parent->qdisc->q.qlen;
> +			qdisc_destroy(parent->qdisc);
> +			psp_deactivate(q, cl);
> +			list_del(&parent->plist);
> +
> +			parent->level = (parent->parent
> +					 ? parent->parent->level
> +					 : TC_PSP_MAXDEPTH) - 1;
> +		}
> +		cl->qdisc = new_q ? new_q : &noop_qdisc;
> +		cl->classid = classid;
> +		cl->parent = parent;
> +
> +		list_add_tail(&cl->hlist, q->hash + psp_hash(classid));
> +		list_add_tail(&cl->sibling, (parent
> +					     ? &parent->children : &q->root));
> +	} else {
> +		if (cl->mode == MODE_STATIC) {
> +			q->allocated_rate -= cl->rate;
> +		}
> +		sch_tree_lock(sch);
> +	}
> +
> +	/* setup mode and target rate */
> +	cl->mode = copt->mode;
> +	if (copt->rate < MIN_TARGET_RATE)
> +		copt->rate = MIN_TARGET_RATE;
> +	cl->max_rate = copt->rate;
> +	switch (cl->mode) {
> +	case MODE_STATIC:
> +		limit = (parent ? parent->allocated_rate : q->allocated_rate) 
> +			+ cl->max_rate;
> +		if (limit > q->max_rate) {
> +			printk(KERN_ERR "psp: target rate is oversubscribed!");
> +			list_del_init(&cl->hlist);
> +			psp_deactivate(q, cl);
> +			if (--cl->refcnt == 0)
> +				psp_destroy_class(sch, cl);
> +			sch_tree_unlock(sch);
> +			return -EINVAL;
> +		}
> +		cl->rate = cl->max_rate;
> +		if (parent) {
> +			parent->allocated_rate += cl->rate;
> +		} else {
> +			q->allocated_rate += cl->rate;
> +		}
> +		break;
> +	}
> +
> +	if (is_leaf_class(cl)) {
> +		if (!list_empty(&cl->plist))
> +			list_del(&cl->plist);
> +		add_leaf_class(q, cl);
> +	}
> +	sch_tree_unlock(sch);
> +	*arg = (unsigned long)cl;
> +	return 0;
> +}
> +
> +static struct tcf_proto **psp_find_tcf(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct psp_sched_data *q = qdisc_priv(sch);
> +	struct psp_class *cl = (struct psp_class *)arg;
> +	struct tcf_proto **fl = cl ? &cl->filter_list : & q->filter_list;

newline after declarations please

> +	return fl;
> +}

> +
> +static struct Qdisc_class_ops psp_class_ops = {

__read_mostly

> +	.graft		=	psp_graft,
> +	.leaf		=	psp_leaf,
> +	.get		=	psp_get,
> +	.put		=	psp_put,
> +	.change		=	psp_change_class,
> +	.delete		=	psp_delete,
> +	.walk		=	psp_walk,
> +	.tcf_chain	=	psp_find_tcf,
> +	.bind_tcf	=	psp_bind_filter,
> +	.unbind_tcf	=	psp_unbind_filter,
> +	.dump		=	psp_dump_class,
> +	.dump_stats	=	psp_dump_class_stats,
> +};
> +
> +static struct Qdisc_ops psp_qdisc_ops = {

__read_mostly

> +	.next		=	NULL,

NULL initialization is unnecessary

> +	.cl_ops		=	&psp_class_ops,
> +	.id		=	"psp",
> +	.priv_size	=	sizeof(struct psp_sched_data),
> +	.enqueue	=	psp_enqueue,
> +	.dequeue	=	psp_dequeue,
> +	.requeue	=	psp_requeue,
> +	.drop		=	psp_drop,
> +	.init		=	psp_init,
> +	.reset		=	psp_reset,
> +	.destroy	=	psp_destroy,
> +	.change		=	psp_change_qdisc,
> +	.dump		=	psp_dump_qdisc,
> +	.dump_stats	=	psp_dump_qdisc_stats,
> +	.owner		=	THIS_MODULE,
> +};
