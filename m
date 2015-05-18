From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 22:06:37 +0200
Message-ID: <20150518200637.GB20709@breakpoint.cc>
References: <1431032664-6478-1-git-send-email-fw@strlen.de>
 <20150518.153922.1873846748456446294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54559 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754939AbbERUGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:06:39 -0400
Content-Disposition: inline
In-Reply-To: <20150518.153922.1873846748456446294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> > There was interest in keeping geometry of original fragments on forward.
> > 
> > This (re)enables this feature.
> > 
> > on router with mtu 1500 on all interfaces and netfilter conntrack enabled:
>  ...
> > Caveat:
> > This disables the optimization made in commit
> > 3cc4949269e01f39443d0 ("ipv4: use skb coalescing in defragmentation") for
> > everyone as soon as nf_defrag_ipv4 modules are loaded (conntrack defrag
> > hooks earlier than ipv4 stacks own defragmentation for local delivery),
> > and there is no way to easily determine if we will forward the skb at that
> > stage.
> > 
> > ip_fragment checks the size of the frag skbs vs. the outgoing device mtu
> > before using them so if device mtu is smaller than the frag skb length
> > the device mtu will be used instead for refragmentation.
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Indeed, I agree that we should only modify the packet's geomtry if we
> know it's to be locally delivered.
> 
> But paying the cost just because a netfilter module is loaded, that's
> really heavy handed and shows really bad engineering on our part.
> 
> When I hear "happens when netfilter modules are loaded", it translates
> into my head as "all the time".  And for you it should too, because
> effectively that's how the world operates.

Yes.  This is why I don't like this patch either.

But, where do I go from here?

I'd like to get rid of the bridge netfilter specific hacks in
ip_fragment.  But all my previous attempts were NAKed.

solution #1: add mtu argument (most simple solution):
http://patchwork.ozlabs.org/patch/457420/

NAK: "Anything that adds
an 'mtu' argument to ip_fragment() I am not even going to look
at"

#2: store largest frag size in IPCB and use that:
http://patchwork.ozlabs.org/patch/467837/
("not enough, must preserve geometry of all fragments")

... and this patch was my attempt to do that.

I could even tolerate the br nf legacy crap in ip_fragment and
just pretend its not there.

BUT: ipv6 conntrack on top of bridge is completely broken
(bridge tosses all reassembled packets).

And I absolutely under no circumstances will send patches
to add the same br nf crap that we have in ipv4 to ipv6 stack.
[ First patches to do this were sent to nf-devel a while back,
  so this problem does hurt users ].

To find something that works for ipv4 will hopefully also allow
re-using that approach for ipv6 and fix this mess once and for all.

I've even entertainted copy-pasting all of ip_fragment into
bridge netfilter & make needed changes but thats insane too.

So, please please re-evaluate your stance on any of the previous
attempts or tell me how you would provide bridge netfilter with
the means to transparently forward (refrag) reassembled skbs, without
breaking PMTUD, in ipv4 and ipv6.

Thank you.
