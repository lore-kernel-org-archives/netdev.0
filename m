From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 05:29:23 +0200
Message-ID: <20150430032921.GB8950@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <20150430003740.GF7025@acer.localdomain>
 <55417F80.4000506@iogearbox.net>
 <20150430014316.GB7956@acer.localdomain>
 <554194E9.5040002@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49231 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbD3D31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 23:29:27 -0400
Content-Disposition: inline
In-Reply-To: <554194E9.5040002@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.04, Jamal Hadi Salim wrote:
> On 04/29/15 21:43, Patrick McHardy wrote:
> >On 30.04, Daniel Borkmann wrote:
> >>On 04/30/2015 02:37 AM, Patrick McHardy wrote:
> >>>On 30.04, Pablo Neira Ayuso wrote:
> 
> >>Totally agree with you that the situation is quite a mess. From tc ingress/
> >>egress side, at least my use case is to have an as minimal as possible entry
> >>point for cls_bpf/act_bpf, which is what we were working on recently. That
> >>is rather ``fresh'' compared to the remaining history of cls/act in tc.
> >
> >It's more than a mess. Leaving aside the fully broken code at ingress,
> >just look at the TC action APIs. Its "a failed state".
> 
> Since youve repeated about 100 that tc api being broken, maybe
> you can explain more rationally? By that i mean dont use words
> like words like "crap" or "failed state" or no chest-thumping.
> Lets say we totally stopped trying to reuse netfilter code, what are
> you talking about?
> 
> I think there is confusion about usability vs merits of performance.

I noticed tons of semantical holes when actually working on this, but
let me just give a single example which is still on the top of my head:

tcf_action_init:

        for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {                      
	        act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);

So the API allows up to *magic number* (32) actions in one list, but not
more. So many will be atomic at least from a rtnetlink perspective, but
certainly not from a packet processing perspecting, from that one, they
will simply be processed as they are instantiated. So, we simulate
atomicity (what netlink is about) for a magic number of elements, but
do not even provide it at runtime.

Even ignoring the harder problem of having transactional semantics for
multiple actions, why even support *magic number* of elements in one
message and pretend atomicity? Smells a lot like premature optimization,
ignoring sementical expectations.

And yes, I do think it breaks with every concept of rtnetlink (messages
are atomic) for no reason at all. I remember TC actions where full of
these "special" interpretations. If you insist, I can do a review again,
but I did all that and stated it years ago.

Regarding TC as a whole, I think the problem is shared between userspace
and the kernel. iproute TC is certainly completely failed, its unusable
without looking at the kernel and iproute code, it hasn't even made the
slightest infrastructrual progess in the past 15 years (*(u16)RTN_DATA(bla))?)
and that is telling for itself. I don't extend that to ip, even though it
suffers from the same coding problems, but let's be honest, do you really
expect some magic is going to happen and TC userspace will suddenly become
usable?

I don't. And we intend to provide an alternative.
