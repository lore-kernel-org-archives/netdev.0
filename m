From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v5 2/2] net_sched: implement a root container
 qdisc sch_mqprio
Date: Wed, 05 Jan 2011 09:38:44 -0800
Message-ID: <4D24ACA4.3000301@intel.com>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab> <20110104185646.13692.68146.stgit@jf-dev1-dcblab> <20110104225936.GA2030@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1548 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab1AERip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 12:38:45 -0500
In-Reply-To: <20110104225936.GA2030@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/4/2011 2:59 PM, Jarek Poplawski wrote:
> On Tue, Jan 04, 2011 at 10:56:46AM -0800, John Fastabend wrote:
>> This implements a mqprio queueing discipline that by default creates
>> a pfifo_fast qdisc per tx queue and provides the needed configuration
>> interface.
>>
>> Using the mqprio qdisc the number of tcs currently in use along
>> with the range of queues alloted to each class can be configured. By
>> default skbs are mapped to traffic classes using the skb priority.
>> This mapping is configurable.
>>
>> Configurable parameters,
>>
>> struct tc_mqprio_qopt {
>>         __u8    num_tc;
>>         __u8    prio_tc_map[TC_BITMASK + 1];
>>         __u8    hw;
>>         __u16   count[TC_MAX_QUEUE];
>>         __u16   offset[TC_MAX_QUEUE];
>> };
>>
>> Here the count/offset pairing give the queue alignment and the
>> prio_tc_map gives the mapping from skb->priority to tc.
>>
>> The hw bit determines if the hardware should configure the count
>> and offset values. If the hardware bit is set then the operation
>> will fail if the hardware does not implement the ndo_setup_tc
>> operation. This is to avoid undetermined states where the hardware
>> may or may not control the queue mapping. Also minimal bounds
>> checking is done on the count/offset to verify a queue does not
>> exceed num_tx_queues and that queue ranges do not overlap. Otherwise
>> it is left to user policy or hardware configuration to create
>> useful mappings.
>>
>> It is expected that hardware QOS schemes can be implemented by
>> creating appropriate mappings of queues in ndo_tc_setup().
>>
>> One expected use case is drivers will use the ndo_setup_tc to map
>> queue ranges onto 802.1Q traffic classes. This provides a generic
>> mechanism to map network traffic onto these traffic classes and
>> removes the need for lower layer drivers to know specifics about
>> traffic types.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  include/linux/netdevice.h |    3
>>  include/linux/pkt_sched.h |   10 +
>>  net/sched/Kconfig         |   12 +
>>  net/sched/Makefile        |    1
>>  net/sched/sch_generic.c   |    4
>>  net/sched/sch_mqprio.c    |  413 +++++++++++++++++++++++++++++++++++++++++++++
>>  6 files changed, 443 insertions(+), 0 deletions(-)
>>  create mode 100644 net/sched/sch_mqprio.c
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index ae51323..19a855b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -764,6 +764,8 @@ struct netdev_tc_txq {
>>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
>>   *                     struct nlattr *port[]);
>>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
>> + *
>> + * int (*ndo_setup_tc)(struct net_device *dev, int tc);
>
>  * int (*ndo_setup_tc)(struct net_device *dev, u8 tc);
>
>>   */
>>  #define HAVE_NET_DEVICE_OPS
>>  struct net_device_ops {
>> @@ -822,6 +824,7 @@ struct net_device_ops {
>>                                                  struct nlattr *port[]);
>>       int                     (*ndo_get_vf_port)(struct net_device *dev,
>>                                                  int vf, struct sk_buff *skb);
>> +     int                     (*ndo_setup_tc)(struct net_device *dev, u8 tc);
>>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>>       int                     (*ndo_fcoe_enable)(struct net_device *dev);
>>       int                     (*ndo_fcoe_disable)(struct net_device *dev);
>> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
>> index 2cfa4bc..1c5310a 100644
>> --- a/include/linux/pkt_sched.h
>> +++ b/include/linux/pkt_sched.h
>> @@ -2,6 +2,7 @@
>>  #define __LINUX_PKT_SCHED_H
>>
>>  #include <linux/types.h>
>> +#include <linux/netdevice.h>
>
> This should better be consulted with Stephen wrt. iproute patch.

OK. Stephen is there a better way to do this? Possibly push the TC_xxx defines into a linux/if_* header? But that doesn't seem right either. I'll poke around some to see if this can be avoided.

>
>>
>>  /* Logical priority bands not depending on specific packet scheduler.
>>     Every scheduler will map them to real traffic classes, if it has
>> @@ -481,4 +482,13 @@ struct tc_drr_stats {
>>       __u32   deficit;
>>  };
>>
>> +/* MQPRIO */
>> +struct tc_mqprio_qopt {
>> +     __u8    num_tc;
>> +     __u8    prio_tc_map[TC_BITMASK + 1];
>> +     __u8    hw;
>> +     __u16   count[TC_MAX_QUEUE];
>> +     __u16   offset[TC_MAX_QUEUE];
>> +};
>> +
>>  #endif
>> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
>> index a36270a..f52f5eb 100644
>> --- a/net/sched/Kconfig
>> +++ b/net/sched/Kconfig
>> @@ -205,6 +205,18 @@ config NET_SCH_DRR
>>
>>         If unsure, say N.
>>
>> +config NET_SCH_MQPRIO
>> +     tristate "Multi-queue priority scheduler (MQPRIO)"
>> +     help
>> +       Say Y here if you want to use the Multi-queue Priority scheduler.
>> +       This scheduler allows QOS to be offloaded on NICs that have support
>> +       for offloading QOS schedulers.
>> +
>> +       To compile this driver as a module, choose M here: the module will
>> +       be called sch_mqprio.
>> +
>> +       If unsure, say N.
>> +
>>  config NET_SCH_INGRESS
>>       tristate "Ingress Qdisc"
>>       depends on NET_CLS_ACT
>> diff --git a/net/sched/Makefile b/net/sched/Makefile
>> index 960f5db..26ce681 100644
>> --- a/net/sched/Makefile
>> +++ b/net/sched/Makefile
>> @@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)        += sch_multiq.o
>>  obj-$(CONFIG_NET_SCH_ATM)    += sch_atm.o
>>  obj-$(CONFIG_NET_SCH_NETEM)  += sch_netem.o
>>  obj-$(CONFIG_NET_SCH_DRR)    += sch_drr.o
>> +obj-$(CONFIG_NET_SCH_MQPRIO) += sch_mqprio.o
>>  obj-$(CONFIG_NET_CLS_U32)    += cls_u32.o
>>  obj-$(CONFIG_NET_CLS_ROUTE4) += cls_route.o
>>  obj-$(CONFIG_NET_CLS_FW)     += cls_fw.o
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 34dc598..723b278 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -540,6 +540,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
>>       .dump           =       pfifo_fast_dump,
>>       .owner          =       THIS_MODULE,
>>  };
>> +EXPORT_SYMBOL(pfifo_fast_ops);
>>
>>  struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
>>                         struct Qdisc_ops *ops)
>> @@ -674,6 +675,7 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
>>
>>       return oqdisc;
>>  }
>> +EXPORT_SYMBOL(dev_graft_qdisc);
>>
>>  static void attach_one_default_qdisc(struct net_device *dev,
>>                                    struct netdev_queue *dev_queue,
>> @@ -761,6 +763,7 @@ void dev_activate(struct net_device *dev)
>>               dev_watchdog_up(dev);
>>       }
>>  }
>> +EXPORT_SYMBOL(dev_activate);
>>
>>  static void dev_deactivate_queue(struct net_device *dev,
>>                                struct netdev_queue *dev_queue,
>> @@ -840,6 +843,7 @@ void dev_deactivate(struct net_device *dev)
>>       list_add(&dev->unreg_list, &single);
>>       dev_deactivate_many(&single);
>>  }
>> +EXPORT_SYMBOL(dev_deactivate);
>>
>>  static void dev_init_scheduler_queue(struct net_device *dev,
>>                                    struct netdev_queue *dev_queue,
>> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
>> new file mode 100644
>> index 0000000..b16dc2c
>> --- /dev/null
>> +++ b/net/sched/sch_mqprio.c
>> @@ -0,0 +1,413 @@
>> +/*
>> + * net/sched/sch_mqprio.c
>> + *
>> + * Copyright (c) 2010 John Fastabend <john.r.fastabend@intel.com>
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License
>> + * version 2 as published by the Free Software Foundation.
>> + */
>> +
>> +#include <linux/types.h>
>> +#include <linux/slab.h>
>> +#include <linux/kernel.h>
>> +#include <linux/string.h>
>> +#include <linux/errno.h>
>> +#include <linux/skbuff.h>
>> +#include <net/netlink.h>
>> +#include <net/pkt_sched.h>
>> +#include <net/sch_generic.h>
>> +
>> +struct mqprio_sched {
>> +     struct Qdisc            **qdiscs;
>> +     int hw_owned;
>> +};
>> +
>> +static void mqprio_destroy(struct Qdisc *sch)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     struct mqprio_sched *priv = qdisc_priv(sch);
>> +     unsigned int ntx;
>> +
>> +     if (!priv->qdiscs)
>> +             return;
>> +
>> +     for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
>> +             qdisc_destroy(priv->qdiscs[ntx]);
>> +
>> +     if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
>> +             dev->netdev_ops->ndo_setup_tc(dev, 0);
>> +     else
>> +             netdev_set_num_tc(dev, 0);
>> +
>> +     kfree(priv->qdiscs);
>> +}
>> +
>> +static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
>> +{
>> +     int i, j;
>> +
>> +     /* Verify num_tc is not out of max range */
>> +     if (qopt->num_tc > TC_MAX_QUEUE)
>> +             return -EINVAL;
>> +
>> +     for (i = 0; i < qopt->num_tc; i++) {
>> +             unsigned int last = qopt->offset[i] + qopt->count[i];
>
> (empty line after declarations)
>

fixed

>> +             /* Verify the queue offset is in the num tx range */
>> +             if (qopt->offset[i] >= dev->num_tx_queues)
>> +                     return -EINVAL;
>> +             /* Verify the queue count is in tx range being equal to the
>> +              * num_tx_queues indicates the last queue is in use.
>> +              */
>> +             else if (last > dev->num_tx_queues)
>> +                     return -EINVAL;
>> +
>> +             /* Verify that the offset and counts do not overlap */
>> +             for (j = i + 1; j < qopt->num_tc; j++) {
>> +                     if (last > qopt->offset[j])
>> +                             return -EINVAL;
>> +             }
>> +     }
>> +
>> +     return 0;
>> +}
>> +
>> +static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     struct mqprio_sched *priv = qdisc_priv(sch);
>> +     struct netdev_queue *dev_queue;
>> +     struct Qdisc *qdisc;
>> +     int i, err = -EOPNOTSUPP;
>> +     struct tc_mqprio_qopt *qopt = NULL;
>> +
>> +     /* Unwind attributes on failure */
>> +     u8 unwnd_tc = dev->num_tc;
>> +     u8 unwnd_map[TC_BITMASK + 1];
>> +     struct netdev_tc_txq unwnd_txq[TC_MAX_QUEUE];
>> +
>> +     if (sch->parent != TC_H_ROOT)
>> +             return -EOPNOTSUPP;
>> +
>> +     if (!netif_is_multiqueue(dev))
>> +             return -EOPNOTSUPP;
>> +
>> +     if (nla_len(opt) < sizeof(*qopt))
>> +             return -EINVAL;
>> +     qopt = nla_data(opt);
>> +
>> +     memcpy(unwnd_map, dev->prio_tc_map, sizeof(unwnd_map));
>> +     memcpy(unwnd_txq, dev->tc_to_txq, sizeof(unwnd_txq));
>> +
>> +     /* If the mqprio options indicate that hardware should own
>> +      * the queue mapping then run ndo_setup_tc if this can not
>> +      * be done fail immediately.
>> +      */
>> +     if (qopt->hw && dev->netdev_ops->ndo_setup_tc) {
>> +             priv->hw_owned = 1;
>> +             err = dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc);
>> +             if (err)
>> +                     return err;
>> +     } else if (!qopt->hw) {
>> +             if (mqprio_parse_opt(dev, qopt))
>> +                     return -EINVAL;
>> +
>> +             if (netdev_set_num_tc(dev, qopt->num_tc))
>> +                     return -EINVAL;
>> +
>> +             for (i = 0; i < qopt->num_tc; i++)
>> +                     netdev_set_tc_queue(dev, i,
>> +                                         qopt->count[i], qopt->offset[i]);
>> +     } else {
>> +             return -EINVAL;
>> +     }
>> +
>> +     /* Always use supplied priority mappings */
>> +     for (i = 0; i < TC_BITMASK + 1; i++) {
>> +             if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
>> +                     err = -EINVAL;
>
> This would probably trigger if we try qopt->num_tc == 0. Is it expected?

netdev_set_prio_tc_map() returns 0 on sucess. This if(..) is a bit strange though.

        err = netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])
        if (err)
                ...

Is cleaner IMHO.

>
>> +                     goto tc_err;
>> +             }
>> +     }
>> +
>> +     /* pre-allocate qdisc, attachment can't fail */
>> +     priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
>> +                            GFP_KERNEL);
>> +     if (priv->qdiscs == NULL) {
>> +             err = -ENOMEM;
>> +             goto tc_err;
>> +     }
>> +
>> +     for (i = 0; i < dev->num_tx_queues; i++) {
>> +             dev_queue = netdev_get_tx_queue(dev, i);
>> +             qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
>> +                                       TC_H_MAKE(TC_H_MAJ(sch->handle),
>> +                                                 TC_H_MIN(i + 1)));
>> +             if (qdisc == NULL) {
>> +                     err = -ENOMEM;
>> +                     goto err;
>> +             }
>> +             qdisc->flags |= TCQ_F_CAN_BYPASS;
>> +             priv->qdiscs[i] = qdisc;
>> +     }
>> +
>> +     sch->flags |= TCQ_F_MQROOT;
>> +     return 0;
>> +
>> +err:
>> +     mqprio_destroy(sch);
>> +tc_err:
>> +     if (priv->hw_owned)
>> +             dev->netdev_ops->ndo_setup_tc(dev, unwnd_tc);
>
> Setting here (again) to unwind a bit later looks strange.
> Why not this 'else' only?

The entire unwind stuff is a bit awkward. With a bit more work up front parsing the parameters the unwinding can be avoided all together.

>
>> +     else
>> +             netdev_set_num_tc(dev, unwnd_tc);
>> +
>> +     memcpy(dev->prio_tc_map, unwnd_map, sizeof(unwnd_map));
>> +     memcpy(dev->tc_to_txq, unwnd_txq, sizeof(unwnd_txq));
>> +
>> +     return err;
>> +}
>> +
>> +static void mqprio_attach(struct Qdisc *sch)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     struct mqprio_sched *priv = qdisc_priv(sch);
>> +     struct Qdisc *qdisc;
>> +     unsigned int ntx;
>> +
>> +     /* Attach underlying qdisc */
>> +     for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
>> +             qdisc = priv->qdiscs[ntx];
>> +             qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
>> +             if (qdisc)
>> +                     qdisc_destroy(qdisc);
>> +     }
>> +     kfree(priv->qdiscs);
>> +     priv->qdiscs = NULL;
>> +}
>> +
>> +static struct netdev_queue *mqprio_queue_get(struct Qdisc *sch,
>> +                                          unsigned long cl)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     unsigned long ntx = cl - 1 - netdev_get_num_tc(dev);
>> +
>> +     if (ntx >= dev->num_tx_queues)
>> +             return NULL;
>> +     return netdev_get_tx_queue(dev, ntx);
>> +}
>> +
>> +static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
>> +                 struct Qdisc **old)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
>> +
>> +     if (dev->flags & IFF_UP)
>> +             dev_deactivate(dev);
>> +
>> +     *old = dev_graft_qdisc(dev_queue, new);
>> +
>> +     if (dev->flags & IFF_UP)
>> +             dev_activate(dev);
>> +
>> +     return 0;
>> +}
>> +
>> +static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     struct mqprio_sched *priv = qdisc_priv(sch);
>> +     unsigned char *b = skb_tail_pointer(skb);
>> +     struct tc_mqprio_qopt opt;
>> +     struct Qdisc *qdisc;
>> +     unsigned int i;
>> +
>> +     sch->q.qlen = 0;
>> +     memset(&sch->bstats, 0, sizeof(sch->bstats));
>> +     memset(&sch->qstats, 0, sizeof(sch->qstats));
>> +
>> +     for (i = 0; i < dev->num_tx_queues; i++) {
>> +             qdisc = netdev_get_tx_queue(dev, i)->qdisc;
>> +             spin_lock_bh(qdisc_lock(qdisc));
>> +             sch->q.qlen             += qdisc->q.qlen;
>> +             sch->bstats.bytes       += qdisc->bstats.bytes;
>> +             sch->bstats.packets     += qdisc->bstats.packets;
>> +             sch->qstats.qlen        += qdisc->qstats.qlen;
>> +             sch->qstats.backlog     += qdisc->qstats.backlog;
>> +             sch->qstats.drops       += qdisc->qstats.drops;
>> +             sch->qstats.requeues    += qdisc->qstats.requeues;
>> +             sch->qstats.overlimits  += qdisc->qstats.overlimits;
>> +             spin_unlock_bh(qdisc_lock(qdisc));
>> +     }
>> +
>> +     opt.num_tc = dev->num_tc;
>> +     memcpy(opt.prio_tc_map, dev->prio_tc_map, sizeof(opt.prio_tc_map));
>> +     opt.hw = priv->hw_owned;
>> +
>> +     for (i = 0; i < dev->num_tc; i++) {
>> +             opt.count[i] = dev->tc_to_txq[i].count;
>> +             opt.offset[i] = dev->tc_to_txq[i].offset;
>> +     }
>> +
>> +     NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>> +
>> +     return skb->len;
>> +nla_put_failure:
>> +     nlmsg_trim(skb, b);
>> +     return -1;
>> +}
>> +
>> +static struct Qdisc *mqprio_leaf(struct Qdisc *sch, unsigned long cl)
>> +{
>> +     struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
>> +
>> +     return dev_queue->qdisc_sleeping;
>> +}
>> +
>> +static unsigned long mqprio_get(struct Qdisc *sch, u32 classid)
>> +{
>> +     unsigned int ntx = TC_H_MIN(classid);
>
> We need to 'get' tc classes too, eg for individual dumps. Then we
> should omit them in .leaf, .graft etc.
>

OK missed this. Looks like iproute2 always sets NLM_F_DUMP which works because it uses cl_ops->walk

# tc -s class show dev eth3 classid 800b:1
class mqprio 800b:1 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0


>> +
>> +     if (!mqprio_queue_get(sch, ntx))
>> +             return 0;
>> +     return ntx;
>> +}
>> +
>> +static void mqprio_put(struct Qdisc *sch, unsigned long cl)
>> +{
>> +}
>> +
>> +static int mqprio_dump_class(struct Qdisc *sch, unsigned long cl,
>> +                      struct sk_buff *skb, struct tcmsg *tcm)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +
>> +     if (cl <= dev->num_tc) {
>> +             tcm->tcm_parent = TC_H_ROOT;
>> +             tcm->tcm_info = 0;
>> +     } else {
>> +             int i;
>> +             struct netdev_queue *dev_queue;
>> +             dev_queue = mqprio_queue_get(sch, cl);
>> +
>> +             tcm->tcm_parent = 0;
>> +             for (i = 0; i < netdev_get_num_tc(dev); i++) {
>
>
> Why dev->num_tc above, netdev_get_num_tc(dev) here, and dev->num_tc
> below?

No reason just inconsistant I will use dev->num_tc.

>
>> +                     struct netdev_tc_txq tc = dev->tc_to_txq[i];
>> +                     int q_idx = cl - dev->num_tc;
>
> (empty line after declarations)
>

fixed

>> +                     if (q_idx >= tc.offset &&
>> +                         q_idx < tc.offset + tc.count) {
>
> cl == 17, tc.offset == 0, tc.count == 1, num_tc = 16, q_idx = 1,
> !(1 < 0 + 1), doesn't belong to the parent #1?
>

Should be

	if (q_idx > tc.offset &&
	    q_idx <= tc.offset + tc.count) 

Now for cl == 17, tc.offset == , tc.count == 1, num_tc = 16, q_idx = 1,
(1 <= 0 + 1) belongs to the parent #1.

>> +                             tcm->tcm_parent =
>> +                                     TC_H_MAKE(TC_H_MAJ(sch->handle),
>> +                                               TC_H_MIN(i + 1));
>> +                             break;
>> +                     }
>> +             }
>> +             tcm->tcm_info = dev_queue->qdisc_sleeping->handle;
>> +     }
>> +     tcm->tcm_handle |= TC_H_MIN(cl);
>> +     return 0;
>> +}
>> +
>> +static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
>> +                            struct gnet_dump *d)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +
>> +     if (cl <= netdev_get_num_tc(dev)) {
>> +             int i;
>> +             struct Qdisc *qdisc;
>> +             struct gnet_stats_queue qstats = {0};
>> +             struct gnet_stats_basic_packed bstats = {0};
>> +             struct netdev_tc_txq tc = dev->tc_to_txq[cl - 1];
>> +
>> +             /* Drop lock here it will be reclaimed before touching
>> +              * statistics this is required because the d->lock we
>> +              * hold here is the look on dev_queue->qdisc_sleeping
>> +              * also acquired below.
>> +              */
>> +             spin_unlock_bh(d->lock);
>> +
>> +             for (i = tc.offset; i < tc.offset + tc.count; i++) {
>> +                     qdisc = netdev_get_tx_queue(dev, i)->qdisc;
>> +                     spin_lock_bh(qdisc_lock(qdisc));
>> +                     bstats.bytes      += qdisc->bstats.bytes;
>> +                     bstats.packets    += qdisc->bstats.packets;
>> +                     qstats.qlen       += qdisc->qstats.qlen;
>> +                     qstats.backlog    += qdisc->qstats.backlog;
>> +                     qstats.drops      += qdisc->qstats.drops;
>> +                     qstats.requeues   += qdisc->qstats.requeues;
>> +                     qstats.overlimits += qdisc->qstats.overlimits;
>> +                     spin_unlock_bh(qdisc_lock(qdisc));
>> +             }
>> +             /* Reclaim root sleeping lock before completing stats */
>> +             spin_lock_bh(d->lock);
>> +             if (gnet_stats_copy_basic(d, &bstats) < 0 ||
>> +                 gnet_stats_copy_queue(d, &qstats) < 0)
>> +                     return -1;
>> +     } else {
>> +             struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
>
> (empty line after declarations)
>

fixed.

>> +             sch = dev_queue->qdisc_sleeping;
>> +             sch->qstats.qlen = sch->q.qlen;
>> +             if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
>> +                 gnet_stats_copy_queue(d, &sch->qstats) < 0)
>> +                     return -1;
>> +     }
>> +     return 0;
>> +}
>> +
>> +static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
>> +{
>> +     struct net_device *dev = qdisc_dev(sch);
>> +     unsigned long ntx;
>> +     u8 num_tc = netdev_get_num_tc(dev);
>> +
>> +     if (arg->stop)
>> +             return;
>> +
>> +     /* Walk hierarchy with a virtual class per tc */
>> +     arg->count = arg->skip;
>> +     for (ntx = arg->skip; ntx < dev->num_tx_queues + num_tc; ntx++) {
>
> Should we report possibly unused/unconfigured tx_queues?

I think it may be OK select_queue() could push skbs onto these queues and we may still want to see the statistics in this case. Although (real_num_tx_queues + num_tc) may make sense I see no reason to show queues above real_num_tx_queues.

Thanks,
John.
