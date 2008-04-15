From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 21:29:24 +0200
Message-ID: <20080415192924.GA3755@ami.dom.local>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local> <4804A18C.2060200@trash.net> <20080415130045.GB4993@ff.dom.local> <4804A921.6050509@trash.net> <20080415174144.GA3444@ami.dom.local> <20080415182541.GA3708@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:55453 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbYDOTai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 15:30:38 -0400
Received: by nf-out-0910.google.com with SMTP id g13so609874nfb.21
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 12:30:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080415182541.GA3708@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 08:25:41PM +0200, Jarek Poplawski wrote:
> On Tue, Apr 15, 2008 at 07:41:44PM +0200, Jarek Poplawski wrote:
> > On Tue, Apr 15, 2008 at 03:09:53PM +0200, Patrick McHardy wrote:
...
> > > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > > index fc8708a..c486e9d 100644
> > > --- a/net/sched/sch_api.c
> > > +++ b/net/sched/sch_api.c
> > > @@ -386,7 +386,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
> > >  	if (n == 0)
> > >  		return;
> > >  	while ((parentid = sch->parent)) {
> > > -		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
> > > +		if (parentid == TC_H_INGRESS)
> > 
> > Maybe like this?:
> >  +		if (parentid == TC_H_ROOT || parentid == TC_H_INGRESS)
> 
> Still wrong! Rather this:
> 
>   	while ((parentid = sch->parent)) {
>   		if (parentid == TC_H_ROOT)
>   			return;

...Hmm... it seems to be enough?! (At least with current ingress
functionality.)

> 
>   		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
> 		if (!sch || sch->parentid == TC_H_INGRESS) {
> 			...

...and here WARN_ON() instead of if (): root is never looked up, so we
can't get NULL nor ingress here; if we have non-ingress ffff:0000
we'll get it (and ingress can't co-exist).

Jarek P.
