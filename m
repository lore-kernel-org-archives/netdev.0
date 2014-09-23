From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Tue, 23 Sep 2014 11:11:05 +0200
Message-ID: <20140923091105.GB13394@breakpoint.cc>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
 <1411248562-26581-3-git-send-email-fw@strlen.de>
 <20140922.163357.553905454314637491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, hagen@jauu.net, lars@netapp.com,
	eric.dumazet@gmail.com, fontana@sharpeleven.org,
	hannes@stressinduktion.org, glenn.judd@morganstanley.com,
	dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44042 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753479AbaIWJLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 05:11:18 -0400
Content-Disposition: inline
In-Reply-To: <20140922.163357.553905454314637491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 20 Sep 2014 23:29:19 +0200
> 
> > From: Daniel Borkmann <dborkman@redhat.com>
> > 
> > This patch adds a flag to TCP congestion algorithms that allows
> > for requesting to mark IPv4/IPv6 sockets with transport as ECN
> > capable, that is, ECT(0), when required by a congestion algorithm.
> > 
> > It is currently used and needed in DataCenter TCP (DCTCP), as it
> > requires both peers to assert ECT on all IP packets sent - it
> > uses ECN feedback (i.e. CE, Congestion Encountered information)
> > from switches inside the data center to derive feedback to the
> > end hosts.
> > 
> > Therefore, simply add a new flag to icsk_ca_ops. Note that DCTCP's
> > algorithm/behaviour slightly diverges from RFC3168, therefore this
> > is only (!) enabled iff the assigned congestion control ops module
> > has requested this. By that, we can tightly couple this logic really
> > only to the provided congestion control ops.
> > 
> > Joint work with Florian Westphal and Glenn Judd.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
> 
> I don't think any administrator is going to be happy with this behavior.
> 
> If he explicitly sets the tcp_ecn sysctl to zero, and then an
> unprivileged user can just start emitting ECN bits by selecting a
> different congestion control algorithm, that is unexpected.
> 
> Please instead make datacenter TCP require ECN to be enabled.

Thanks for your feedback! We have actually thought about that for
quite a while before starting on the implementation, and concluded
that the behaviour is actually fine as is for three reasons:

1) DCTCP is very tighly coupled to the ECN machinery as described
   in the paper. Not having ECN enabled and nevertheless allowing
   DCTCP (if we would implement above feedback) would just make it
   fallback to Reno, which would not be useful in the first place.
   So an administrator would rather not load DCTCP to the available
   congestion control modules in the first place in this case.

2) Right now an administrator can choose to use DCTCP only for a
   particular process, and still avoid exposing ECN to the outside
   world for every other process.

3) An unpriviledged user would not be able to use DCTCP *unless*
   an administrator has explicitly allowed to use it. This is being
   reflected since Stephen's commit ce7bc3bf15cb ("[TCP]: Restrict
   congestion control choices.") where only Reno or the currently
   compiled-in default choice is non-restricted.

If you nevertheless think that it is useful to include above feedback
to overcome your objection, we could just add a check for tcp_ecn
sysctl being set to 1 for the initialization of the congestion control
ops of the socket and otherwise fall back to Reno.

Thanks!

Daniel and Florian
