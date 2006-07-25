From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 08:55:28 -0700
Message-ID: <20060725085528.38b86319@localhost.localdomain>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
	<20060725162001.GA15058@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11487 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964790AbWGYQgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:36:36 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060725162001.GA15058@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Jul 2006 20:20:01 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > Code was reusing an skb which could lead to use after free or double free.
> 
> No, this does not help. The bug is not here.
> 
> I was so ashamed of this that could not touch the thing. :-)
> It startled me a lot, how is it possible that the thing was in production
> for several years and such bad bug never was noticed?
> 
> Now it is clear. skbs leaked sometimes before BK changeset 1.889.26.53,
> subj: [IPV4]: Fix skb leak in inet_rtm_getroute. But after this fix,
> which introduced new bug (goto out_free in the enclosed patch),
> the bug showed on surface.
> 
> Please, review this.
> 
> - ipmr_cache_unresolved() does not free skb. Caller does.
> - goto out_free in route.c in the case, when skb is enqueued
>   is returned to goto out.
> - some cosmetic cleanup in rt_fill_info() to make it more readable.

This looks correct, but it may lead to false reports from automated
checking tools because the skb lifetime depends on the return value.
Wouldn't it be better to have a consistent interface (skb always freed),
and clone the skb if needed for deferred processing?
