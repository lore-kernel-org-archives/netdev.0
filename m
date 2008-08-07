From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] net: trap attempts to modify noop qdisc
Date: Thu, 7 Aug 2008 10:22:42 -0700
Message-ID: <20080807102242.7d365eff@extreme>
References: <20080806230850.41435290@extreme>
	<20080806.231159.55957179.davem@davemloft.net>
	<20080806231516.659f82c5@extreme>
	<20080806.233703.193701199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36241 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbYHGRWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 13:22:45 -0400
In-Reply-To: <20080806.233703.193701199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Aug 2008 23:37:03 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Wed, 6 Aug 2008 23:15:16 -0700
> 
> > On Wed, 06 Aug 2008 23:11:59 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> > > Date: Wed, 6 Aug 2008 23:08:50 -0700
> > > 
> > > > Since noop qdisc is a singleton, it shouldn't end up with any other
> > > > qdisc's on it's list, and it shouldn't be deleted.
> > > > 
> > > > Dave, this should help you find the bug.
> > > 
> > > Thanks.
> > 
> > I think the root of your problem (bad pun) is that the new code
> > is assuming that changes to the root are done with parent handle of 0,
> > but the API is for the parent handle to be TC_H_ROOT (0xFFFFFFFFU).
> 
> This is what I just committed to net-2.6, please give it a whirl.
> 
> pkt_sched: Fix "parent is root" test in qdisc_create().
> 
> As noticed by Stephen Hemminger, the root qdisc is denoted by
> TC_H_ROOT, not zero.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/sched/sch_api.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 4840aff..83b23b5 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -792,7 +792,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
>  				goto err_out3;
>  			}
>  		}
> -		if (parent && !(sch->flags & TCQ_F_INGRESS))
> +		if ((parent != TC_H_ROOT) && !(sch->flags & TCQ_F_INGRESS))
>  			list_add_tail(&sch->list, &dev_queue->qdisc->list);
>  
>  		return sch;

Thanks, that fixes it.

You still might want to add a BUG_ON there for anything that is internal qdisc.
