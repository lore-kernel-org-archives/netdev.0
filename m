From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement: kernel
Date: Fri, 28 Dec 2007 22:02:08 +0100
Message-ID: <47756450.4030300@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com> <476EBD00.2060905@ee.ethz.ch> <47751F86.1030205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:37460 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbXL1VCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 16:02:21 -0500
In-Reply-To: <47751F86.1030205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your comments!

Patrick McHardy wrote:
> Ariane Keller wrote:

>> +/* must be divisible by 4 (=#pkts)*/
>> +#define DATA_PACKAGE 4000
> 
> Its not obvious that this refers to a size, please rename
> to something more approriate. And why is it hardcoded
> to 4000? Shouldn't it be related to NLMSG_GOODSIZE?

Ok, I can rename it to TRACE_DATA_PACKET_SIZE

> 
>> +#define DATA_PACKAGE_ID 4008
> 
> Its even less obvious that this is the netlink attribute
> size. Its obfuscation anyway, just open-code
> RTA_SPACE(new name of DATA_PACKAGE).

DATA_PACKAGE_ID corresponds to DATA_PACKAGE + 2 * sizeof(int).
The two ints are a small header in front of each packet.
I agree the name is really bad and I have to think
about the whole thing with this header.

>> +
>> +int qdisc_notify_pid(int pid, struct nlmsghdr *n,
>> +            u32 clid, struct Qdisc *old, struct Qdisc *new)
>> +{
>> +    struct sk_buff *skb;
>> +    skb = alloc_skb(NLMSG_GOODSIZE, gfp_any());
>> +    if (!skb)
>> +        return -ENOBUFS;
>> +
>> +    if (old && old->handle) {
>> +        if (tc_fill(skb, old, clid, pid, n->nlmsg_seq,
>> +                0, RTM_DELQDISC) < 0)
>> +            goto err_out;
>> +    }
>> +    if (new) {
>> +        if (tc_fill(skb, new, clid, pid, n->nlmsg_seq,
>> +                old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
>> +            goto err_out;
>> +    }
>> +    if (skb->len)
>> +        return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags);
> 
> And why do you need a new notification function? qdisc_notify
> seems perfectly fine for this.

qdisc_notify results in acquiring a lock (q->stats_lock) which we 
already hold in this situation
(qdisc_notify->tc_fill_qdisc->gnet_stats_start_copy_compat).
Writing a new notification function may be wrong,
but I do not know a better way.


>> diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
>> linux-2.6.23.8/net/sched/sch_netem.c 
>> linux-2.6.23.8_mod/net/sched/sch_netem.c
>> --- linux-2.6.23.8/net/sched/sch_netem.c    2007-11-16 
>> 19:14:27.000000000 +0100
>> +++ linux-2.6.23.8_mod/net/sched/sch_netem.c    2007-12-21 
>> 19:42:49.000000000 +0100
> 
>> +/* don't call this function directly. It is called after
>> + * a packet has been taken out of a buffer and it was the last.
>> + */
>> +static int reload_flowbuffer(struct netem_sched_data *q, struct Qdisc 
>> *sch)
>> +{
>> +    struct tcn_control *flow = q->flowbuffer;
>> +    struct nlmsghdr n;
>> +    struct buflist *element = list_entry(flow->full_buffer_list.next,
>> +                         struct buflist, list);
>> +    /* the current buffer is empty */
>> +    list_add_tail(&flow->buffer_in_use->list, &flow->empty_buffer_list);
>> +
>> +    if (list_empty(&q->flowbuffer->full_buffer_list)) {
>> +        printk(KERN_ERR "netem: reload_flowbuffer, no full buffer\n");
>> +        return -EFAULT;
>> +    }
>> +
>> +    list_del_init(&element->list);
>> +    flow->buffer_in_use = element;
>> +    flow->offsetpos = (int *)element->buf;
>> +    memset(&n, 0, sizeof(struct nlmsghdr));
>> +    n.nlmsg_seq = 1;
>> +    n.nlmsg_flags = NLM_F_REQUEST;
> 
> This netlink header faking is horrible, please just change qdisc_notify
> to deal with absent netlink headers appropriately. The sequence number
> used for kernel notifications not related to userspace requests is 0.
> 
>> +    if (qdisc_notify_pid(q->flowid, &n, sch->parent, NULL, sch) < 0)
>> +        printk(KERN_ERR "netem: unable to request for more data\n");
> 
> netlink_set_err() causing userspace to request all current information
> seems like better error handling. The remaining netem part also looks
> like it could use a lot of improvement, you shouldn't need manual
> notifications on destruction, change, etc., all this is already
> handled by sch_api. There should be a single new notification in
> netem_enqueue(), calling qdisc_notify(), which dumps the current
> state to userspace.

I can summarize the notifications which request for more data.
But I do not (yet) know how I get rid of those which deal
with the notification of the deletion of a qdisc.
"tc qdisc add/change ... trace ..." start a new process (flowseed)
which waits for kernel requests to send trace data packets
to the netem module.
If "tc qdisc change/del ..." is called the previously generated
flowseed process needs to be terminated. I did this by sending a
notification to the corresponding flowseed process.
Upon receiving this notification the flowseed process terminates itself.
Is there already an event generated by sch_api on which the flowseed
process could listen in order to be notified when a given qdisc is deleted?

Thanks a lot!
Ariane



> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

