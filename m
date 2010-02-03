From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 03 Feb 2010 13:38:09 -0500
Message-ID: <1265222289.2861.290.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant> <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant> <4B685756.8010107@trash.net>
	 <1265130426.2861.158.camel@tonnant>
	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
	 <4B6967BC.600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:51130 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588Ab0BCSiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 13:38:51 -0500
In-Reply-To: <4B6967BC.600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-03 at 13:10 +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Jon Masters wrote:
> >> On Tue, 2010-02-02 at 19:58 +0200, Alexey Dobriyan wrote:
> >>
> >>> Yes, moving to init_net-only function is fine.
> >> So moving the "setup up fake conntrack" bits to init_init_net from
> >> init_net still results in the panic, which means that the use count
> >> really is dropping to zero and we really are trying to free it when
> >> using multiple namespaces. Per ns is probably an easier way to go.
> > 
> > Agreed, that will also avoid problems in the future with the
> > ct_net pointer pointing to &init_net. I'll take care of this
> > tommorrow.
> 
> Unfortunately a per-namespace conntrack is not easily possible without
> larger changes (most of which are already queued in nf-next-2.6.git
> though). So for now I just moved the untrack handling to the init_net
> setup and cleanup functions and we can try to fix the remainder in
> 2.6.34.

Ok. I'd love to help out actually, given that I've been poking at this,
and it's quite fun. So please at least send me patches. The only other
thing I consider a priority issue at the moment for this is that writing
into /sys/module/nf_conntrack/parameters/hashsize on a running system
with multiple namespaces will cause the system to corrupt random memory
silently and fall over. That probably needs fixing until there is
per-namespace hashsize tracking, and this isn't a global tunable.

Also, some other things I think are required before 2.6.34:

*). Per namespace cacheing allocation (the cachep bits). We know it's
still possible for weirdness to happen in the SLAB cache here.
*). Per namespace hashsize tracking. Existing code corrupts hashtables
if the global size is changed when there is more than one netns
*). Per namespace expectations. This is for similar reasons to the need
for multiple hashtables, though I haven't poked at that.

I also think it is necessary to expose net namespace layout and
configuration via sysfs or some other interface, add a net->id parameter
(and may even an optional name), etc. Where does netns discussion
happen, on netdev I would presume?

> Jon, could you give this patch a try please?

Yup. Box is stable and boots multiple virtual machines as it did with
the quick hack from yesterday, so this has now fixed the problem.

Can you let me know if this is the final patch you want to post? If so,
we should get this into stable asap (and I have a couple of vendor
kernels that will need a version of this fix also).

Jon.


