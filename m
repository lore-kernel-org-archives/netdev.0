From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: reallocate addrconf router for ipv6 address when lo device up
Date: Thu, 23 Jan 2014 22:03:24 +0100
Message-ID: <20140123210324.GL7269@order.stressinduktion.org>
References: <1390460277-23451-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sabrina Dubroca <sd@queasysnail.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33232 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbaAWVD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:03:26 -0500
Content-Disposition: inline
In-Reply-To: <1390460277-23451-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 02:57:57PM +0800, Gao feng wrote:
> commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> allocates addrconf router for ipv6 address when lo device up.
> but commit a881ae1f625c599b460cc8f8a7fcb1c438f699ad
> "ipv6:don't call addrconf_dst_alloc again when enable lo" breaks
> this behavior.
> 
> Since the addrconf router is moved to the garbage list when
> lo device down, we should delete this router and rellocate
> a new one for ipv6 address when lo device up.
> 
> This patch solves bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=67951
> 
> CC: Sabrina Dubroca <sd@queasysnail.net>
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reported-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv6/addrconf.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4b6b720..6eecd9d 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2611,8 +2611,17 @@ static void init_loopback(struct net_device *dev)
>  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>  				continue;
>  
> -			if (sp_ifa->rt)
> -				continue;
> +			if (sp_ifa->rt) {
> +				/* This dst has been added to garbage list when
> +				 * lo device down, delete this obsolete dst and
> +				 * reallocate a new router for ifa.
> +				 */
> +				if (sp_ifa->rt->dst.obsolete > 0) {
> +					ip6_del_rt(sp_ifa->rt);

We should not delete dst.obsolete > 0 routes. I think a ip6_put_rt is just
fine here, no?

Greetings,

  Hannes
