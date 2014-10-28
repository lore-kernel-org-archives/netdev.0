From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Tue, 28 Oct 2014 16:57:37 -0400 (EDT)
Message-ID: <20141028.165737.2009356944765978630.davem@davemloft.net>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbaJ1U5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 16:57:40 -0400
In-Reply-To: <1414276729-17871-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 26 Oct 2014 00:38:47 +0200

> These two patches allow turing on explicit congestion notification
> based on the destination network.
> 
> For example, assuming the default tcp_ecn sysctl '2', the following will
> enable ecn (tcp_ecn=1 behaviour, i.e. request ecn to be enabled for a
> tcp connection) for all connections to hosts inside the 192.168.2/24 network:
> 
> ip route change 192.168.2.0/24 dev eth0 features ecn
> 
> Having a more fine-grained per-route setting can be beneficial for
> various reasons, for example 1) within data centers, or 2) local ISPs
> may deploy ECN support for their own video/streaming services [1], etc.
> 
> Joint work with Daniel Borkmann, feature suggested by Hannes Frederic Sowa.
> 
> The patch to enable this in iproute2 will be posted shortly, it is currently
> also available here:
> http://git.breakpoint.cc/cgit/fw/iproute2.git/commit/?h=iproute_features&id=8843d2d8973fb81c78a7efe6d42e3a17d739003e
> 
> [1] http://www.ietf.org/proceedings/89/slides/slides-89-tsvarea-1.pdf, p.15

I don't like how the route metric gives less control than the sysctl.

If the tcp_ecn cases of '1' and '2' make sense for the sysctl, I do not
see why they wouldn't make sense for the per-route knob to.

Implement the following policy, if per-route metric is non-zero use it
instead of the sysctl setting.

Then you have a helper:

static int tcp_ecn_enabled(struct net *net, struct dst_entry *dst)
{
	u32 val = dst_metric(dst, RTAX_ECN);

	if (val)
		return val;
	return net->ipv4.sysctl_tcp_ecn;
}

Then there is no other change to make other than an absolute
strict substitution of sysctl_tcp_ecn with tcp_ecn_enabled().
