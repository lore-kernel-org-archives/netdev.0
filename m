From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Tue, 3 Mar 2009 14:21:07 -0500
Message-ID: <20090303192107.GJ1480@hmsreliant.think-freely.org>
References: <20090303170435.GE1480@hmsreliant.think-freely.org> <20090303181909.GA29236@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50683 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579AbZCCTVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 14:21:20 -0500
Content-Disposition: inline
In-Reply-To: <20090303181909.GA29236@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 09:19:09PM +0300, Evgeniy Polyakov wrote:
> Hi Neil.
> 
> On Tue, Mar 03, 2009 at 12:04:35PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
> > +typedef enum {
> > +	NET_DM_CFG_VERSION = 0,
> > +	NET_DM_CFG_ALERT_COUNT,
> > +	NET_DM_CFG_ALERT_DELAY,
> > +	NET_DM_CFG_MAX,
> > +} config_type_t;
> > +
> > +struct net_dm_config_entry {
> > +	config_type_t type;
> > +	uint64_t data;
> > +};
> > +
> 
> Ugh, please add either some comments about its alignment or some padding
> fields.
> 
Yeah, I probably should align that to 64 bit boundaries for performance, thanks!

> > +struct net_dm_config_msg {
> > +	size_t entries;
> > +	struct net_dm_config_entry options[0];
> > +};
> 
> Isn't size_t have different size on different platforms?
> 
Probably, but we're only sending this data over netlink sockets, so despite the
platform, I don't really see this as an issue.  About the only place for concern
I think are cases like x86_64 and ppc64, in the event you have a 64 bit kernel
and 32 bit user space, and in those the app can be adjusted to compensate for
this.  I suppose I can fixate the size if its a real concern, but I don't think
it really is.

> > +/*
> > + * Globals, our netlink socket pointer
> > + * and the work handle that will send up
> > + * netlink alerts
> > + */
> > +struct sock *dm_sock;
> > +
> > +struct per_cpu_dm_data {
> > +	struct work_struct dm_alert_work;
> > +	struct sk_buff *skb;
> > +	atomic_t dm_hit_count;
> > +	struct timer_list send_timer;
> > +};
> > +
> > +DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
> > +
> 
> Static dm data?
> 

Noted, I can make it static, but I don't think its a big deal, given that its
not exported anywhere, so its not accessible to anything else.

> > +static spinlock_t send_lock = SPIN_LOCK_UNLOCKED;
> 
> DEFINE_SPINLOCK
> 
will do, thanks.

> > +static int dm_hit_limit = 64;
> > +static int dm_delay = 1;
> > +
> 
> Configurable?
> 
Eventually, see implementation notes in part 0 of this series :)

> > +static void send_dm_alert(struct work_struct *unused)
> > +{
> > +	size_t al, size;
> > +	struct net_dm_alert_msg *msg;
> > +	struct nlmsghdr *nlh;
> > +	struct sk_buff *skb, *nskb;
> > +	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> > +
> 
> Should it be plain get_cpu_var() or disabled preemption?
> 

I don't think I really need to worry about it.  The atomic_add_unless should
gate us from multiple contexts on the same cpu getting into the critical region
beyond.  e.g. preemption should be safe here.

> > +	al = sizeof(struct nlmsghdr);
> 
> Hmm, this worries a bit, shouldn't it use NLMSG_LENGTH() and friends?
> 
Hmm, perhaps, the padding does go between the end of the nlmsghdr and the start
of the data, doesn't it?  I think its ok right now, since I use NLMSG_DATA to
find the offset of the data (as long as we don't fill up the skbs).  I should
fix that, thank you!

> > +	al += sizeof(struct net_dm_alert_msg);
> > +	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
> > +
> > +
> > +	/*
> > +	 * Grab the skb we're about to send
> > +	 */
> > +	skb = data->skb;
> > +
> > +	/*
> > +	 * Replace it with a new one
> > +	 */
> > +	nskb = alloc_skb(al, GFP_KERNEL);
> > +	nlh = (struct nlmsghdr *)nskb->data;
> > +	memset(nlh, 0, sizeof(struct nlmsghdr));
> > +	nlh->nlmsg_type = NET_DM_ALERT;
> > +	msg = NLMSG_DATA(nlh);
> > +	memset(msg, 0, al);
> > +	skb_put(nskb, sizeof(struct net_dm_alert_msg));
> > +	skb_put(nskb, sizeof(struct nlmsghdr));
> > +
> > +	data->skb = nskb;
> > +
> > +	/*
> > +	 * Make sure to fix up the length field on the nlmsghdr
> > +	 */
> > +	nlh = (struct nlmsghdr *)skb->data;
> > +	msg = NLMSG_DATA(nlh);
> > +
> > +	size = sizeof(struct nlmsghdr) + sizeof (struct net_dm_alert_msg);
> > +	size += msg->entries * sizeof(struct net_dm_drop_point);
> > +	nlh->nlmsg_len = NLMSG_LENGTH(size);
> > +
> > +	/*
> > +	 * And adjust the skb if we need to
> > +	 */
> > +	if (nlh->nlmsg_len > size)
> > +		skb_put(skb, (nlh->nlmsg_len-size));
> > +
> > +	/*
> > +	 * Ship it!
> > +	 */
> > +	NETLINK_CB(skb).dst_group =  NET_DM_GRP_ALERTS;
> 
> Additional space                    sneaked in.
> 
I'll correct that, thanks!

> > +	spin_lock(&send_lock);
> > +        netlink_broadcast(dm_sock, skb, 0, NET_DM_GRP_ALERTS, 0);
> 
> Another 3. Also why do you use zero allocation instead of GFP_ATOMIC?
> Also why do you use global lock here?
> 

Not sure I understand your first question, why would I use GFP_ATOMIC?  I'd
rather keep the allocation of skb data out of the fast path entirely If at all
possible.

AS for the global lock, I was trying to avoid two processors sending on the
socket at once, but as I look at it, its completely unneeded, isn't it?  I'll
correct that shortly.  Thanks!

> > +	spin_unlock(&send_lock);
> > +
> > +	/*
> > +	 * Reset the per_cpu counter.  This unlocks the trace point
> > +	 * So that we can collect for subsequent drops
> > +	 */
> > +	atomic_set(&data->dm_hit_count, dm_hit_limit);
> > +	
> 
> Trailing tab and unneded new line.
> 
Will fix, thank you!

> > +}
> > +
> > +static void sched_send_work(unsigned long unused)
> > +{
> > +	struct per_cpu_dm_data *data =  &__get_cpu_var(dm_cpu_data);
> > +
> 
> Please add some comments that it is called from the timer interrupt and
> thus should not disable preemption around per-cpu variable.
> 
will do.  Thank you!

> > +	schedule_work(&data->dm_alert_work);
> > +}
> > +
> > +static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
> > +{
> > +	struct net_dm_alert_msg *msg;
> > +	struct nlmsghdr *nlh;
> > +	int i;
> > +	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> > +
> > +	
> > +	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
> > +		/*
> > +		 * we're already at zero, discard this hit
> > +		 */
> > +		goto out;
> > +	}
> > +
> > +	nlh = (struct nlmsghdr *)data->skb->data;
> > +	msg = NLMSG_DATA(nlh);
> > +	for (i=0; i < msg->entries; i++) {
> > +		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
> 
> Looks like a netlink message to/from userspace contains pointer. If this
> is the case, then it is not the way to go.
> 
It does, and that is exactly the idea.  The intent here is for the user space
application to be informed of where in the kernel a packet was dropped.  The
user space app then translates that into a symbol+offset so that the admin knows
where the drop occured (using /proc/kallsyms, kernel debuigging info, etc).

> > +			msg->points[i].count++;
> > +			goto out;
> > +		}
> > +	}
> > +
> > +	/*
> > +	 * We need to create a new entry
> > +	 */
> > +	skb_put(data->skb, sizeof(struct net_dm_drop_point));
> 
> What if there is no space?
> 
The skb is allocated so there will be exactly enough space.  We allocate the skb
so thata there is exactly enough room for the nlmsghdr the drop alert header and
the dm_hit_limit number of drop points.  Thats why each cpu has a
dm_hit_counter, and if we decrement that counter to zero, we drop subsequent
trace hits until the timer fires, the event thread sends the skb and allocates
us a new one.

> > +	memcpy(msg->points[msg->entries].pc, &location, sizeof(void *));
> 
> Please change the structures so that they never contain variable size
> members like pointers or longs.
> 
They don't, pc is an array of uint8_t's.

> > +	msg->points[msg->entries].count = 1;
> > +	msg->entries++;
> > +
> > +	if (!timer_pending(&data->send_timer)) {
> > +		data->send_timer.expires = jiffies + dm_delay * HZ;
> > +		add_timer_on(&data->send_timer, smp_processor_id());
> > +	}
> > +
> > +out:
> > +	return;
> > +}
> 
> 
> > +static void drpmon_rcv(struct sk_buff *skb)
> > +{
> > +	int status, type, pid, flags, nlmsglen, skblen;
> > +	struct nlmsghdr *nlh;
> > +
> > +	skblen = skb->len;
> > +	if (skblen < sizeof(*nlh))
> > +		return;
> > +
> > +	nlh = nlmsg_hdr(skb);
> > +	nlmsglen = nlh->nlmsg_len;
> > +	if (nlmsglen < sizeof(*nlh) || skblen < nlmsglen)
> > +		return;
> > +
> > +	pid = nlh->nlmsg_pid;
> > +	flags = nlh->nlmsg_flags;
> > +	type = nlh->nlmsg_type;
> > +
> > +	if (pid != 0)
> > +		return;
> > +
> > +	if (!(flags & NLM_F_REQUEST))
> > +		RCV_SKB_FAIL(-ECOMM);
> > +
> > +
> 
> Additional newline.
> 
Will fix, thanks

> > +	if (type <= NET_DM_BASE)
> > +		return;
> > +
> > +	if (type >= NET_DM_MAX)
> > +		RCV_SKB_FAIL(-EINVAL);
> > +
> > +
> 
> And another one.
> 
Ditto

> > +	status = dropmon_handle_msg(skb, type,
> > +				  nlmsglen - NLMSG_LENGTH(0));
> > +	if (status < 0)
> > +		RCV_SKB_FAIL(status);
> > +
> > +	if (flags & NLM_F_ACK)
> > +		netlink_ack(skb, nlh, 0);
> > +	return;
> > +}
> > +
> > +static int __init init_net_drop_monitor(void)
> > +{
> > +	int cpu;
> > +	size_t al;
> > +	struct net_dm_alert_msg *msg;
> > +	struct nlmsghdr *nlh;
> > +	struct per_cpu_dm_data *data;
> > +	printk(KERN_INFO "Initalizing network drop monitor service\n");
> > +
> > +	if (sizeof(void *) > 8) {
> > +		printk(KERN_ERR "Unable to store program counters on this arch, Drop monitor failed\n");
> 
> Why? :)
> 
For the reason you pointed out above :)

> > +		return -ENOSPC;
> > +	}
> > +
> > +	dm_sock = netlink_kernel_create(&init_net, NETLINK_DRPMON, NET_DM_GRP_ALERTS,
> > +					drpmon_rcv, NULL, THIS_MODULE);
> > +
> > +	if (dm_sock == NULL) {
> > +		printk(KERN_ERR "Could not create drop monitor socket\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	al = sizeof(struct nlmsghdr);
> > +	al += sizeof(struct net_dm_alert_msg);
> > +	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
> > +
> 
> Please use NLMSG helpers here.
> 
As noted earlier, I'll fix that up.

> > +	for_each_present_cpu(cpu) {
> > +		data = &per_cpu(dm_cpu_data, cpu);
> > +		data->skb = alloc_skb(al, GFP_KERNEL);	
> > +		skb_put(data->skb, sizeof(struct nlmsghdr));
> > +		skb_put(data->skb, sizeof(struct net_dm_alert_msg));
> > +		nlh = (struct nlmsghdr *)data->skb->data;
> > +		memset(nlh, 0, sizeof(struct nlmsghdr));
> > +		nlh->nlmsg_type = NET_DM_ALERT;
> > +		msg = NLMSG_DATA(nlh);
> > +		memset(msg, 0, al);
> > +		INIT_WORK(&data->dm_alert_work, send_dm_alert);
> > +		atomic_set(&data->dm_hit_count, dm_hit_limit);
> > +		init_timer(&data->send_timer);
> > +		data->send_timer.data = cpu;
> > +		data->send_timer.function = sched_send_work;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +subsys_initcall(init_net_drop_monitor);
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> 	Evgeniy Polyakov
> 


Ok, thank you for the through review, I've noted all of these.  I'll wait a few
days to see if anyone else has comments, and will repost a new version of this
part of the series when I think all the comments are in.

Regards
Neil
