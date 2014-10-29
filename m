From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Wed, 29 Oct 2014 13:23:07 +0100
Message-ID: <20141029122307.GA29253@breakpoint.cc>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
 <20141028.165737.2009356944765978630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34039 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932585AbaJ2MXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 08:23:10 -0400
Content-Disposition: inline
In-Reply-To: <20141028.165737.2009356944765978630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 26 Oct 2014 00:38:47 +0200
> 
> > These two patches allow turing on explicit congestion notification
> > based on the destination network.
> > 
> > For example, assuming the default tcp_ecn sysctl '2', the following will
> > enable ecn (tcp_ecn=1 behaviour, i.e. request ecn to be enabled for a
> > tcp connection) for all connections to hosts inside the 192.168.2/24 network:
> > 
> > ip route change 192.168.2.0/24 dev eth0 features ecn
> > 
> > Having a more fine-grained per-route setting can be beneficial for
> > various reasons, for example 1) within data centers, or 2) local ISPs
> > may deploy ECN support for their own video/streaming services [1], etc.
> > 
> > Joint work with Daniel Borkmann, feature suggested by Hannes Frederic Sowa.
> > 
> > The patch to enable this in iproute2 will be posted shortly, it is currently
> > also available here:
> > http://git.breakpoint.cc/cgit/fw/iproute2.git/commit/?h=iproute_features&id=8843d2d8973fb81c78a7efe6d42e3a17d739003e
> > 
> > [1] http://www.ietf.org/proceedings/89/slides/slides-89-tsvarea-1.pdf, p.15
> 
> I don't like how the route metric gives less control than the sysctl.
> 
> If the tcp_ecn cases of '1' and '2' make sense for the sysctl, I do not
> see why they wouldn't make sense for the per-route knob to.
>
> Implement the following policy, if per-route metric is non-zero use it
> instead of the sysctl setting.

I think that if we add a u32 route attr for a new ecn switch we might as well
support full override of the sysctl.

I had a discussion with Daniel Borkmann, and we came up with this
proposal:

- add RTAX_ECN
- if RTAX_ECN attribute present, set RTAX_FEATURE_ECN in RTAX_FEATURES
- in kernel, when RTAX_FEATURE_ECN set, use dst_metric(dst, RTAX_ECN).
- else, if RTAX_FEATURE_ECN unset, use the sysctl as fallback.

It would allow things like sysctl_tcp_ecn=1 and
ip route change some_blackhole dev eth0 ecn 0
ip route change some_network dev eth0 ecn 2
ip route change other dev eth0 ecn 1

We could do that, if you prefer.

I tried to come up with a scenario though, where sysctl_tcp_ecn=0, and
then we want to enable 'passive' ecn for incoming connections only on
a particular route without announcing ecn to the peer. I haven't been
able to find any -- I think if you deem 'route to x' safe for ecn it
might as well be enabled for both initiator and responder.  The original
patch would be sufficient for that.

IOW, is 'ecn from a to b but not b to a' a sensible requirement?

sysctl_tcp_ecn=2 seems just to be a convenience solution/intermediate
step to make the stack ecn-aware by default without too much breakage
risk for users (i.e. instead of having sysctl_tcp_ecn=1 as default).

Unrelated to this patch, but I'd like to see sysctl_tcp_ecn=1 as a
default at one point (almost no routers set CE bit at this time, perhaps
that would change if ecn usage is more widespread).

Thanks!
