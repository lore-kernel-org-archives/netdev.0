From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] tc: policing requires a rate estimator
Date: Tue, 25 Nov 2008 10:33:19 -0800
Message-ID: <20081125103319.19de15c3@extreme>
References: <20081125101656.52348bdd@extreme>
	<20081125102113.371db7b1@extreme>
	<492C44AD.1010007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYKYSdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:33:22 -0500
In-Reply-To: <492C44AD.1010007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008 19:32:13 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Found that while trying average rate policing, it was possible to
> > request average rate policing without a rate estimator. This results
> > in no policing which is harmless but incorrect.
> > 
> > Since policing could be setup in two steps, need to check
> > in the kernel.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > 
> > ---
> >  include/net/gen_stats.h  |    1 +
> >  net/core/gen_estimator.c |   30 +++++++++++++++++++++++++++---
> >  net/sched/act_police.c   |   16 ++++++++++++----
> >  3 files changed, 40 insertions(+), 7 deletions(-)
> > 
> > --- a/net/sched/act_police.c	2008-11-25 10:15:50.000000000 -0800
> > +++ b/net/sched/act_police.c	2008-11-25 10:17:54.000000000 -0800
> > @@ -182,6 +182,12 @@ override:
> >  		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
> >  		if (R_tab == NULL)
> >  			goto failure;
> > +
> > +		if (!est && !gen_estimator_active(&police->tcf_rate_est)) {
> > +			err = -EINVAL;
> > +			goto failure;
> 
> This leaks the R_tab reference.

The previous patch added a put at the failure: tag.
