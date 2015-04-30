From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 02:15:20 +0200
Message-ID: <20150430001519.GD7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233600.GA7025@acer.localdomain>
 <55417095.9030202@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbD3APX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 20:15:23 -0400
Content-Disposition: inline
In-Reply-To: <55417095.9030202@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.04, Daniel Borkmann wrote:
> On 04/30/2015 01:36 AM, Patrick McHardy wrote:
> ...
> >You obviously realize this callchain is fully made up by yourself
> 
> Hence, I wrote path, not call chain, I guess that should have been
> clear.
> 
> [...]
> >The difference is very simple: where we had an indirect call to
> >q->enqueue before (and a lot of crap that didn't belong there),
> >we now have a call to nf_hook_slow, followed by the hook invocation.
> 
> Sure, but what I wanted to express is that from an architectural
> point of view down to invoking a classifier, we now have a list of
> hooks, one element of those can be ingress qdisc and that one can
> have lists of classifier/actions by itself, etc. That doesn't seem
> sound wrt 'where it really belongs'.
> 
> Personally, I have no objections if you want to use netfilter on
> ingress, don't get me wrong, but that ingress qdisc part doesn't
> really fit in there, and moving it behind netfilter facilities does
> have additional cost for a packet.

It does, and Pablo made up for this cost by moving the TTL tracking
to ingress where it actually belongs. This would obviously also be
possible without his patchset, but the fact is, nobody seemed to
have cared for the past ten years, we have from today a basically
zero cost feature and people can decide what the want for themselves,
there is no added cost for people not using it, there is no added
cost for people using ingress.

As for "really fit", ingress started off as living on a netfilter
hook and only moved to a direct invocation somewhere around 2.6.12
IIRC. As I was mentioning earlier, ingress *qdisc* is a hack in
itself since there is no freaking queuing, its a hack to invoke
classifier chains, so actually netfilter is *the better* abstraction
to do this. And it's not netfilter, its packet hooks for classification
purposes.

To me all these arguments have to very negative sounds. It has always
been like this - and it hasn't. And we want ingress queueing to be
the exclusive way to do this. And this quite frankly sucks for all
the reasons stated before. Its a hack, its not queueing, it doesn't
cost anything, let the people decide what they actually want to use.
