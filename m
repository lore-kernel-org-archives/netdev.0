From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 19:40:09 -0700 (PDT)
Message-ID: <20071011.194009.48528774.davem@davemloft.net>
References: <20071011.171743.118962219.davem@davemloft.net>
	<20071011.181449.130846976.davem@davemloft.net>
	<1192159036.6889.6.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, takano@axe-inc.co.jp,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752737AbXJLCkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 22:40:06 -0400
In-Reply-To: <1192159036.6889.6.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 11 Oct 2007 20:17:16 -0700

> On Thu, 2007-10-11 at 18:14 -0700, David Miller wrote:
> > +       while (1) {
> > +               work_done = tg3_poll_work(tp, work_done, budget);
> > +
> > +               if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
> > +                       goto tx_recovery;
> > +
> > +               if (unlikely(work_done >= budget))
> > +                       break;
> > +
> > +               if (likely(!tg3_has_work(tp))) {
> > +                       struct tg3_hw_status *sblk = tp->hw_status;
> > +
> 
> --> new status block DMA
> 
> > +                       if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
> > +                               tp->last_tag = sblk->status_tag;
> > +                               rmb();
> > +                       } else
> > +                               sblk->status &= ~SD_STATUS_UPDATED;
> 
> We need to read the sblk->status_tag before calling tg3_has_work().  If
> a new status block DMA happens in between (shown above), tp->last_tag
> will get the new tag and we will end up acknowledging work that we
> haven't processed.

Hmmm, the old code didn't do that and seemingly has the same
problem.  Also, if you look at the before-patch code and think
about what it does if we ->poll() multiple times for a single
interrupt the side-effects are essentially the same.

What's the crucial difference?

> I'll go over this some more tonight and will send a patch to refine it.

Thanks Michael.
