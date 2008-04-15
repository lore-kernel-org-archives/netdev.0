From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 20:25:41 +0200
Message-ID: <20080415182541.GA3708@ami.dom.local>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local> <4804A18C.2060200@trash.net> <20080415130045.GB4993@ff.dom.local> <4804A921.6050509@trash.net> <20080415174144.GA3444@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:9689 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbYDOS1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 14:27:24 -0400
Received: by ug-out-1314.google.com with SMTP id z38so755780ugc.16
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 11:27:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080415174144.GA3444@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 07:41:44PM +0200, Jarek Poplawski wrote:
> On Tue, Apr 15, 2008 at 03:09:53PM +0200, Patrick McHardy wrote:
> ...
> > On second thought I agree with you, the behaviour is inconsistent
> > and FFFF: shouldn't be used as major, otherwise the major doesn't
> > uniquely identify a qdisc anymore.
> 
> Like ingress vs. root handle? I think it's more about additional
> checks (and good memory).

...That's why better discourage...

> 
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index fc8708a..c486e9d 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -386,7 +386,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
> >  	if (n == 0)
> >  		return;
> >  	while ((parentid = sch->parent)) {
> > -		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
> > +		if (parentid == TC_H_INGRESS)
> 
> Maybe like this?:
>  +		if (parentid == TC_H_ROOT || parentid == TC_H_INGRESS)

Still wrong! Rather this:

  	while ((parentid = sch->parent)) {
  		if (parentid == TC_H_ROOT)
  			return;

  		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
		if (!sch || sch->parentid == TC_H_INGRESS) {
			...

Jarek P.
