From: Patrick McHardy <kaber@trash.net>
Subject: Re: igb bandwidth allocation configuration
Date: Thu, 10 Sep 2009 13:55:37 +0200
Message-ID: <4AA8E939.6050208@trash.net>
References: <20090910081844.GA5421@verge.net.au> <4AA8E2CE.2080707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090605050707070809000807"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60020 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbZIJLzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 07:55:42 -0400
In-Reply-To: <4AA8E2CE.2080707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090605050707070809000807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Simon Horman wrote:
>>
>> I have been looking into adding support the 82586's per-PF/VF
>> bandwidth allocation to the igb driver. It seems that the trickiest
>> part is working out how to expose things to user-space.
>>
>> ...
>> Internally it seems that actually the limits are applied to HW Tx queues
>> rather than directly VMs. There are 16 such queues. Accordingly it might
>> be useful to design an interface to set limits per-queue using ethtool.
>> But this would seem to also require exposing which queues are associated
>> with which PF/VF.
> 
> Just an idea since I don't know much about this stuff:
> 
> Since we now have the mq packet scheduler, which exposes the device
> queues as qdisc classes, how about adding driver-specific configuration
> attributes that are passed to the driver by the mq scheduler? This
> would allow to configure per-queue bandwidth limits using regular TC
> commands and also use those limits without VFs for any kind of traffic.
> Drivers not supporting this would refuse unsupported options.

Attached patch demonstrates the idea. Compile-tested only.


--------------090605050707070809000807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a44118b..388841c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -178,6 +178,7 @@ enum {
 struct neighbour;
 struct neigh_parms;
 struct sk_buff;
+struct nlattr;
 
 struct netif_rx_stats
 {
@@ -636,6 +637,12 @@ struct net_device_ops {
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
 #endif
+	int			(*ndo_queue_config)(struct net_device *dev,
+						    unsigned int qnum,
+						    const struct nlattr *nla[]);
+	int			(*ndo_get_queue_config)(struct net_device *dev,
+							struct sk_buff *skb,
+							unsigned int qnum);
 };
 
 /*
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d51a2b3..742db43 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -518,4 +518,14 @@ struct tc_drr_stats
 	__u32	deficit;
 };
 
+/* MQ */
+
+enum
+{
+	TCA_MQ_UNSPEC,
+	__TCA_MQ_MAX
+};
+
+#define TCA_MQ_MAX	(__TCA_MQ_MAX - 1)
+
 #endif
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index dd5ee02..13132b9 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -171,15 +171,61 @@ static void mq_put(struct Qdisc *sch, unsigned long cl)
 	return;
 }
 
+static const struct nla_policy mq_policy[TCA_MQ_MAX + 1] = {
+	/* nothing so far */
+};
+
+static int mq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			   struct nlattr **tca, unsigned long *arg)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct nlattr *tb[TCA_MQ_MAX + 1];
+	unsigned long ntx;
+	int err;
+
+	if (*arg == 0)
+		return -EOPNOTSUPP;
+	if (mq_queue_get(sch, *arg))
+		return -ENOENT;
+	ntx = *arg - 1;
+
+	if (tca == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_MQ_MAX, tca[TCA_OPTIONS], mq_policy);
+	if (err < 0)
+		return err;
+
+	if (dev->netdev_ops->ndo_queue_config == NULL)
+		return -EOPNOTSUPP;
+	return dev->netdev_ops->ndo_queue_config(dev, ntx, (void *)tb);
+}
+
 static int mq_dump_class(struct Qdisc *sch, unsigned long cl,
 			 struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
+	struct net_device *dev = qdisc_dev(sch);
+	struct nlattr *nest;
 
 	tcm->tcm_parent = TC_H_ROOT;
 	tcm->tcm_handle |= TC_H_MIN(cl);
 	tcm->tcm_info = dev_queue->qdisc_sleeping->handle;
-	return 0;
+
+	if (dev->netdev_ops->ndo_get_queue_config) {
+		nest = nla_nest_start(skb, TCA_OPTIONS);
+		if (nest == NULL)
+			goto nla_put_failure;
+		if (dev->netdev_ops->ndo_get_queue_config(dev, skb, cl - 1) < 0)
+			goto nla_put_failure;
+		nla_nest_end(skb, nest);
+	}
+
+	return skb->len;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -EMSGSIZE;
 }
 
 static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
@@ -214,6 +260,7 @@ static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 
 static const struct Qdisc_class_ops mq_class_ops = {
 	.select_queue	= mq_select_queue,
+	.change		= mq_change_class,
 	.graft		= mq_graft,
 	.leaf		= mq_leaf,
 	.get		= mq_get,

--------------090605050707070809000807--
