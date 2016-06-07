From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv2 net 2/2] net: cls_u32: be more strict about skip-sw
 flag
Date: Tue, 7 Jun 2016 17:06:03 +0100
Message-ID: <20160607170603.1ab175a4@jkicinski-Precision-T1700>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
	<1465296416-21449-1-git-send-email-jakub.kicinski@netronome.com>
	<1465296416-21449-3-git-send-email-jakub.kicinski@netronome.com>
	<5756EDFF.2000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	sridhar.samudrala@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34862 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161590AbcFGQGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 12:06:23 -0400
Received: by mail-wm0-f48.google.com with SMTP id v199so26567999wmv.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 09:06:22 -0700 (PDT)
In-Reply-To: <5756EDFF.2000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Jun 2016 08:53:35 -0700, John Fastabend wrote:
> On 16-06-07 03:46 AM, Jakub Kicinski wrote:
> > Return an error if user requested skip-sw and the underlaying
> > hardware cannot handle tc offloads (or offloads are disabled).
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> > Reviewed-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > v2:
> >   - handle both knode and hnodes
> > ---
> >  net/sched/cls_u32.c | 58 +++++++++++++++++++++++++++--------------------------
> >  1 file changed, 30 insertions(+), 28 deletions(-)
> > 
> > diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> > index b17e090f2fe1..0fc1d47885f8 100644
> > --- a/net/sched/cls_u32.c
> > +++ b/net/sched/cls_u32.c
> > @@ -457,20 +457,21 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp,
> >  	struct tc_to_netdev offload;
> >  	int err;
> >  
> > +	if (!tc_should_offload(dev, flags))
> > +		return tc_skip_sw(flags) ? -EINVAL : 0;
> > +
> >  	offload.type = TC_SETUP_CLSU32;
> >  	offload.cls_u32 = &u32_offload;
> >  
> > -	if (tc_should_offload(dev, flags)) {
> > -		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> > -		offload.cls_u32->hnode.divisor = h->divisor;
> > -		offload.cls_u32->hnode.handle = h->handle;
> > -		offload.cls_u32->hnode.prio = h->prio;
> > +	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> > +	offload.cls_u32->hnode.divisor = h->divisor;
> > +	offload.cls_u32->hnode.handle = h->handle;
> > +	offload.cls_u32->hnode.prio = h->prio;
> >  
> > -		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> > -						    tp->protocol, &offload);
> > -		if (tc_skip_sw(flags))
> > -			return err;
> > -	}
> > +	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> > +					    tp->protocol, &offload);
> > +	if (tc_skip_sw(flags))
> > +		return err;
> >  
> >  	return 0;
> >  }  
> 
> Looks like we also need to catch the error at u32_replace_hw_hnode call
> sites?
> 
> 
>                 u32_replace_hw_hnode(tp, ht, flags);
>                 return 0;
>         }
> 
> should be
> 
> 		return replace_hw_hnode(tp, ht,flags)

Indeed. I'll add a third patch to the series, seems like a separate bug.
