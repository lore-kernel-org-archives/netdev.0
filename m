From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 02:51:37 -0700 (PDT)
Message-ID: <20080501.025137.95203112.davem@davemloft.net>
References: <20080430214845.GC14219@solarflare.com>
	<20080430215125.GD14219@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kmansley@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757317AbYEAJvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 05:51:40 -0400
In-Reply-To: <20080430215125.GD14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Apr 2008 22:51:26 +0100

> Add skb_warn_if_lro() to test whether an skb was received with LRO and
> warn if so.
> 
> Change br_forward(), ip_forward() and ip6_forward() to call
> skb_warn_if_lro() and discard the skb if it returns true.

This skb_is_gso() test should be inline.

So, instead make this something like:

include/linux/skbuff.h:

extern bool __skb_warn_if_lro(const struct sk_buff *skb);

static inline bool skb_warn_if_lro(const struct sk_buff *skb)
{
	if (unlikely(skb_is_gso(skb)))
		return __skb_warn_if_lro(skb);
	return false;
}

net/core/skbuff.c:

bool skb_warn_if_lro(const struct sk_buff *skb)
{
	if (net_ratelimit())
		pr_warning("%s: received packets cannot be forwarded"
			   " while LRO is enabled\n", skb->dev->name);
	return true;
}

Can you make this correction and resubmit this patch?

The second one looks fine to me, you don't need to resubmit
that one.

Thanks!
