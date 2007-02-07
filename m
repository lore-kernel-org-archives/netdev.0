From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Wed, 7 Feb 2007 09:07:22 +0100
Message-ID: <20070207080722.GC2434@elte.hu>
References: <20070206123401.GA8052@elte.hu> <20070206.114325.98862918.davem@davemloft.net> <20070206210250.GB25430@elte.hu> <20070206.132357.58458400.davem@davemloft.net> <20070206215806.GA5109@elte.hu> <45C974FD.5070404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, dipankar@in.ibm.com, paulmck@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:42978 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965541AbXBGIHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 03:07:55 -0500
Content-Disposition: inline
In-Reply-To: <45C974FD.5070404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Patrick McHardy <kaber@trash.net> wrote:

> > this means that this particular use could be fixed by converting the 
> > preempt_disable()/enable() pair in nf_ct_l4proto_find_get() to 
> > rcu_read_lock()/unlock(), correct?
> 
> That is another bug (all uses of preempt_disable in netfilter 
> actually), but calling __nf_ct_l[34]proto_find without rcu_read_lock 
> is broken as well.
> 
> > Furthermore, every user of synchronize_net() [and synchronize_rcu() 
> > in general] needs to be reviewed.
> 
> I'll take care of netfilter.

great! Netfilter is one of the main users of synchronize_net() (about 
90% of the synchronize_net() callsites are in netfilter), and one of the 
main (well, in fact pretty much only) users of preempt_disable().

Dave, Patrick, can we lift the nack on PREEMPT_RCU, as far as networking 
goes? We really need some progress regarding it, and i think Paul is way 
too modest about pushing it. His patchset been in beta testing for like 
2 years meanwhile. PREEMPT_RCU has already found a nice set of 
bugs/uncleanlinesses elsewhere too, so even if you never actually enable 
PREEMPT_RCU (it's off by default), it's a nice generalization of the RCU 
framework that also tightens up its semantics. I think we need that, 
before existing code learns to depend on non-generic details of 
'classic' RCU too much. [my other interest in it, as you might have 
guessed, is that PREEMPT_RT depends on PREEMPT_RCU architecturally, but 
that shouldnt worry you - i think the upstream arguments alone are 
strong enough.]

	Ingo
