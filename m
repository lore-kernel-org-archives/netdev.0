From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] neighbour: always have struct net pointer in
 struct neigh_parms
Date: Tue, 10 Dec 2013 14:45:38 -0500 (EST)
Message-ID: <20131210.144538.1753921871836942715.davem@davemloft.net>
References: <1386661497-1688-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab3LJTpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:45:40 -0500
In-Reply-To: <1386661497-1688-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 10 Dec 2013 08:44:57 +0100

> This fixes compile error when CONFIG_NET_NS is not set.
> 
> Introduced by:
> commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
>     "neigh: restore old behaviour of default parms values"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Jiri please don't fix things this way.

When network name spaces are disabled, you're supposed to abstract
all of this stuff away behind accessor macros so that it is truly
zero cost.

For example, look at how "dev_net()" and related helpers works.

This means you need to do something like:

/*
 * Net namespace inlines
 */
static inline
struct net *neigh_parms_net(const struct neigh_parms *np)
{
	return read_pnet(&np->net);
}

static inline
void neigh_parms_net_set(struct neigh_parms *np, struct net *net)
{
#ifdef CONFIG_NET_NS
	release_net(np->net);
	np->net = hold_net(net);
#endif
}

And then use these helpers consistently in your new code.

Thanks.
