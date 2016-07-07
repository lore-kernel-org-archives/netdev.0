From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: sched: convert qdisc linked list to hashtable
 (was Re: Deleting child qdisc doesn't reset parent to default qdisc?)
Date: Thu, 07 Jul 2016 18:53:12 +0200
Message-ID: <1467910392.1273.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	   <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	   <20160414151813.GE3715@orbyte.nwl.cc>
	   <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
	   <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	   <5710E1C1.2090209@mojatatu.com>
	  <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
	  <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
	 <1467899463.1273.37.camel@edumazet-glaptop3.roam.corp.google.com>
	 <alpine.LNX.2.00.1607071823290.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Craig Gallek <kraigatgoog@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32899 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcGGQxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:53:17 -0400
In-Reply-To: <alpine.LNX.2.00.1607071823290.24757@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 18:32 +0200, Jiri Kosina wrote:
> On Thu, 7 Jul 2016, Eric Dumazet wrote:
> 
> > > @@ -1440,6 +1441,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
> > >  {
> > >  	int ret = 0, q_idx = *q_idx_p;
> > >  	struct Qdisc *q;
> > > +	int b;
> > >  
> > >  	if (!root)
> > >  		return 0;
> > > @@ -1454,7 +1456,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
> > >  			goto done;
> > >  		q_idx++;
> > >  	}
> > > -	list_for_each_entry(q, &root->list, list) {
> > > +	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
> > >  		if (q_idx < s_q_idx) {
> > >  			q_idx++;
> > >  			continue;
> > > @@ -1771,6 +1773,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
> > >  			       int *t_p, int s_t)
> > >  {
> > >  	struct Qdisc *q;
> > > +	int b;
> > >  
> > >  	if (!root)
> > >  		return 0;
> > > @@ -1778,7 +1781,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
> > >  	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
> > >  		return -1;
> > >  
> > > -	list_for_each_entry(q, &root->list, list) {
> > > +	hash_for_each_rcu(qdisc_dev(root)->qdisc_hash, b, q, hash) {
> > >  		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
> > >  			return -1;
> > >  	}
> > 
> > 
> > Not sure why you used the rcu version here, but the non rcu version in
> > tc_dump_qdisc_root()
> 
> Good catch.
> 
> Actually even the current code is odd in this regard -- 
> qdisc_match_from_root() uses RCU iterator,

Because it can be run from qdisc enqueue() dequeue(), not holding RTNL.

>  while tc_dump_*() use the 
> non-RCU one; addition and deletion is performed using RCU primitives.

It really is protected by RTNL (qdiscs can not change during the dump)

> 
> I haven't got my head around this yet; if it's correct at all, it'd at 
> least deserve a comment somewhere.
> 
> I'll respin v2 of the patch (there is also a conflict on HASH_SIZE 
> definition in ip6_tunnel.c, ip6_gre.c and sit.c due to hashtable.h include 
> in netdevice.h that needs to be resolved as well) that'd make RCU usage 
> consistent.
> 
> Any other objections/comments? I was namely curious about any opinions 
> regarding the hashtable size.

Well, this is the tricky part, but rhashtable would mean way more
changes...
