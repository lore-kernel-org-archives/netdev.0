From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement: kernel
Date: Fri, 28 Dec 2007 17:08:38 +0100
Message-ID: <47751F86.1030205@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com> <476EBD00.2060905@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33540 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbXL1QI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 11:08:56 -0500
In-Reply-To: <476EBD00.2060905@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
> +struct tc_netem_stats
> +{
> +    int packetcount;
> +    int packetok;
> +    int normaldelay;
> +    int drops;
> +    int dupl;
> +    int corrupt;
> +    int novaliddata;
> +    int reloadbuffer;

These should be unsigned int or __u32.

>
> diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
> linux-2.6.23.8/include/net/flowseed.h 
> linux-2.6.23.8_mod/include/net/flowseed.h
> --- linux-2.6.23.8/include/net/flowseed.h    1970-01-01 
> 01:00:00.000000000 +0100
> +++ linux-2.6.23.8_mod/include/net/flowseed.h    2007-12-21 
> 19:43:24.000000000 +0100
> @@ -0,0 +1,34 @@
> +/* flowseed.h     header file for the netem trace enhancement
> + */
> +
> +#ifndef _FLOWSEED_H
> +#define _FLOWSEED_H
> +#include <net/sch_generic.h>
> +
> +/* must be divisible by 4 (=#pkts)*/
> +#define DATA_PACKAGE 4000

Its not obvious that this refers to a size, please rename
to something more approriate. And why is it hardcoded
to 4000? Shouldn't it be related to NLMSG_GOODSIZE?

> +#define DATA_PACKAGE_ID 4008

Its even less obvious that this is the netlink attribute
size. Its obfuscation anyway, just open-code
RTA_SPACE(new name of DATA_PACKAGE).

> +
> +/* struct per flow - kernel */
> +struct tcn_control
> +{
> +    struct list_head full_buffer_list;
> +    struct list_head empty_buffer_list;
> +    struct buflist * buffer_in_use;       
> +    int *offsetpos;       /* pointer to actual pos in the buffer in 
> use */
> +    int flowid;
> +};
> +
> +struct tcn_statistic
> +{
> +    int packetcount;
> +    int packetok;
> +    int normaldelay;
> +    int drops;
> +    int dupl;
> +    int corrupt;
> +    int novaliddata;
> +    int reloadbuffer;

Also unsigned please.


>
> diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
> linux-2.6.23.8/net/sched/sch_api.c linux-2.6.23.8_mod/net/sched/sch_api.c
> --- linux-2.6.23.8/net/sched/sch_api.c    2007-11-16 
> 19:14:27.000000000 +0100
> +++ linux-2.6.23.8_mod/net/sched/sch_api.c    2007-12-21 
> 19:42:49.000000000 +0100
> @@ -28,6 +28,7 @@
>  #include <linux/list.h>
>  #include <linux/hrtimer.h>
>
> +#include <net/sock.h>
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
>
> @@ -841,6 +842,62 @@ rtattr_failure:
>      nlmsg_trim(skb, b);
>      return -1;
>  }
> +static int tc_fill(struct sk_buff *skb, struct Qdisc *q, u32 clid,
> +             u32 pid, u32 seq, u16 flags, int event)
> +{
> +    struct tcmsg *tcm;
> +    struct nlmsghdr  *nlh;
> +    unsigned char *b = skb_tail_pointer(skb);
> +
> +    nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
> +    tcm = NLMSG_DATA(nlh);
> +    tcm->tcm_family = AF_UNSPEC;
> +    tcm->tcm__pad1 = 0;
> +    tcm->tcm__pad2 = 0;
> +    tcm->tcm_ifindex = q->dev->ifindex;
> +    tcm->tcm_parent = clid;
> +    tcm->tcm_handle = q->handle;
> +    tcm->tcm_info = atomic_read(&q->refcnt);
> +    RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
> +    if (q->ops->dump && q->ops->dump(q, skb) < 0)
> +        goto rtattr_failure;
> +
> +    nlh->nlmsg_len = skb_tail_pointer(skb) - b;
> +
> +    return skb->len;

Why is this function not used by tc_fill_qdisc?

> +
> +nlmsg_failure:
> +rtattr_failure:
> +    nlmsg_trim(skb, b);
> +    return -1;
> +}
> +
> +int qdisc_notify_pid(int pid, struct nlmsghdr *n,
> +            u32 clid, struct Qdisc *old, struct Qdisc *new)
> +{
> +    struct sk_buff *skb;
> +    skb = alloc_skb(NLMSG_GOODSIZE, gfp_any());
> +    if (!skb)
> +        return -ENOBUFS;
> +
> +    if (old && old->handle) {
> +        if (tc_fill(skb, old, clid, pid, n->nlmsg_seq,
> +                0, RTM_DELQDISC) < 0)
> +            goto err_out;
> +    }
> +    if (new) {
> +        if (tc_fill(skb, new, clid, pid, n->nlmsg_seq,
> +                old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
> +            goto err_out;
> +    }
> +    if (skb->len)
> +        return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags);

And why do you need a new notification function? qdisc_notify
seems perfectly fine for this.

> +
> +err_out:
> +    kfree_skb(skb);
> +    return -EINVAL;
> +}
> +EXPORT_SYMBOL(qdisc_notify_pid);
>
>  static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n,
>              u32 clid, struct Qdisc *old, struct Qdisc *new)
> @@ -848,7 +905,7 @@ static int qdisc_notify(struct sk_buff *
>      struct sk_buff *skb;
>      u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
>
> -    skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
> +    skb = alloc_skb(NLMSG_GOODSIZE, gfp_any());

You don't even use qdisc_notify anywhere in your patch, why
this change?

>      if (!skb)
>          return -ENOBUFS;
>
> diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
> linux-2.6.23.8/net/sched/sch_netem.c 
> linux-2.6.23.8_mod/net/sched/sch_netem.c
> --- linux-2.6.23.8/net/sched/sch_netem.c    2007-11-16 
> 19:14:27.000000000 +0100
> +++ linux-2.6.23.8_mod/net/sched/sch_netem.c    2007-12-21 
> 19:42:49.000000000 +0100

> +/* don't call this function directly. It is called after
> + * a packet has been taken out of a buffer and it was the last.
> + */
> +static int reload_flowbuffer(struct netem_sched_data *q, struct Qdisc 
> *sch)
> +{
> +    struct tcn_control *flow = q->flowbuffer;
> +    struct nlmsghdr n;
> +    struct buflist *element = list_entry(flow->full_buffer_list.next,
> +                         struct buflist, list);
> +    /* the current buffer is empty */
> +    list_add_tail(&flow->buffer_in_use->list, &flow->empty_buffer_list);
> +
> +    if (list_empty(&q->flowbuffer->full_buffer_list)) {
> +        printk(KERN_ERR "netem: reload_flowbuffer, no full buffer\n");
> +        return -EFAULT;
> +    }
> +
> +    list_del_init(&element->list);
> +    flow->buffer_in_use = element;
> +    flow->offsetpos = (int *)element->buf;
> +    memset(&n, 0, sizeof(struct nlmsghdr));
> +    n.nlmsg_seq = 1;
> +    n.nlmsg_flags = NLM_F_REQUEST;

This netlink header faking is horrible, please just change qdisc_notify
to deal with absent netlink headers appropriately. The sequence number
used for kernel notifications not related to userspace requests is 0.

> +    if (qdisc_notify_pid(q->flowid, &n, sch->parent, NULL, sch) < 0)
> +        printk(KERN_ERR "netem: unable to request for more data\n");

netlink_set_err() causing userspace to request all current information
seems like better error handling. The remaining netem part also looks
like it could use a lot of improvement, you shouldn't need manual
notifications on destruction, change, etc., all this is already
handled by sch_api. There should be a single new notification in
netem_enqueue(), calling qdisc_notify(), which dumps the current
state to userspace.


