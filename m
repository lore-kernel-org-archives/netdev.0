From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 2/2] net_sched: implement a root
 container qdisc sch_mqprio
Date: Thu, 6 Jan 2011 01:32:08 +0100
Message-ID: <20110106003208.GA2166@del.dom.local>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
 <20110104185646.13692.68146.stgit@jf-dev1-dcblab>
 <20110104225936.GA2030@del.dom.local>
 <4D24ACA4.3000301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63592 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab1AFAcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 19:32:15 -0500
Received: by bwz15 with SMTP id 15so16002117bwz.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 16:32:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D24ACA4.3000301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 05, 2011 at 09:38:44AM -0800, John Fastabend wrote:
> On 1/4/2011 2:59 PM, Jarek Poplawski wrote:
> > On Tue, Jan 04, 2011 at 10:56:46AM -0800, John Fastabend wrote:
...
> >> +
> >> +     /* Always use supplied priority mappings */
> >> +     for (i = 0; i < TC_BITMASK + 1; i++) {
> >> +             if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
> >> +                     err = -EINVAL;
> >
> > This would probably trigger if we try qopt->num_tc == 0. Is it expected?
> 
> netdev_set_prio_tc_map() returns 0 on sucess. This if(..) is a bit strange though.
> 
>         err = netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])
>         if (err)
>                 ...
> 
> Is cleaner IMHO.

Maybe. But I still wonder if qopt->num_tc == 0 is valid (by design)?
(netdev_set_prio_tc_map() returns -EINVAL if dev->num_tc == 0)

> >> +static unsigned long mqprio_get(struct Qdisc *sch, u32 classid)
> >> +{
> >> +     unsigned int ntx = TC_H_MIN(classid);
> >
> > We need to 'get' tc classes too, eg for individual dumps. Then we
> > should omit them in .leaf, .graft etc.
> >
> 
> OK missed this. Looks like iproute2 always sets NLM_F_DUMP which works because it uses cl_ops->walk
> 
> # tc -s class show dev eth3 classid 800b:1
> class mqprio 800b:1 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0

OK, then it might be only of theoretical value (for some other tools).

> > Why dev->num_tc above, netdev_get_num_tc(dev) here, and dev->num_tc
> > below?
> 
> No reason just inconsistant I will use dev->num_tc.

Well, this would suggest netdev_get_num_tc() is redundant.

> >> +static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
> >> +{
> >> +     struct net_device *dev = qdisc_dev(sch);
> >> +     unsigned long ntx;
> >> +     u8 num_tc = netdev_get_num_tc(dev);
> >> +
> >> +     if (arg->stop)
> >> +             return;
> >> +
> >> +     /* Walk hierarchy with a virtual class per tc */
> >> +     arg->count = arg->skip;
> >> +     for (ntx = arg->skip; ntx < dev->num_tx_queues + num_tc; ntx++) {
> >
> > Should we report possibly unused/unconfigured tx_queues?
> 
> I think it may be OK select_queue() could push skbs onto these queues and we may still want to see the statistics in this case. Although (real_num_tx_queues + num_tc) may make sense I see no reason to show queues above real_num_tx_queues.

IMHO, pushing skbs to unconfigured/unwanted/disabled queues is a bug,
and select should handle this, but probably it's a matter of taste.
Btw, I wonder how dev->real_num_tx_queues is obeyed here.

Thanks,
Jarek P.

PS: No offense, but could you try cutting lines ~70c. It's strongly
recommended on kernel lists.
