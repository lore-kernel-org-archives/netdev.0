From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management (v2)
Date: Sat, 21 Mar 2009 00:43:40 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0903210038290.19176@ppwaskie-MOBL2.amr.corp.intel.com>
References: <Pine.WNT.4.64.0903202033090.16644@ppwaskie-MOBL2.amr.corp.intel.com>
 <20090320214515.5af3a6f4@nehalam> <Pine.WNT.4.64.0903202319050.12360@ppwaskie-MOBL2.amr.corp.intel.com>
 <20090321.003338.103826980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34663 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758245AbZCUHno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 03:43:44 -0400
In-Reply-To: <20090321.003338.103826980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Mar 2009, David Miller wrote:

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Fri, 20 Mar 2009 23:21:38 -0700 (Pacific Daylight Time)
> 
> > I see your point, but it is a hack in my opinion.  The device will have 8 
> > real Tx queues, not 1.  I'd much rather go with the original proposal, 
> > since if the code in dev_pick_tx() changed, it could silently break ixgbe.
> 
> It can't, if you only advertise one transmit queue the kernel
> can never ever choose anything other than queue zero.  It's
> impossible.
> 
> Stephen's right, you guys don't need your select queue override.
> 
> And if you recall I suspected this from the very beginning.
> 
> You guys never ever think out of the box, ever...  if it's
> not straightforward, you guys won't got for it.  That makes
> it very frustrating to get anything done.

This patch will break DCB in ixgbe.  We need all 8 queues, because the 
user will be assigning tc filters to the sch_multiq qdisc to get traffic 
into priority queues.  If we take Stephen's patch and tell the stack we 
have 1 real_num_tx_queues, then we get 1 band in sch_multiq, which makes 
it impossible to assign traffic to priorities 1 through 8:

static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
{
        struct multiq_sched_data *q = qdisc_priv(sch);
        struct tc_multiq_qopt *qopt;
        int i;

        if (!netif_is_multiqueue(qdisc_dev(sch)))
                return -EOPNOTSUPP;
        if (nla_len(opt) < sizeof(*qopt))
                return -EINVAL;

        qopt = nla_data(opt);

        qopt->bands = qdisc_dev(sch)->real_num_tx_queues;

This is not what we want, rather, we want all 8 Tx queues that we expose.  
The only reason we override the select_queue is to catch the unfiltered 
traffic and send it to queue 0.

Cheers,
-PJ Waskiewicz
