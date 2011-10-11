From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 10:33:48 -0400
Message-ID: <20111011143348.GA20605@gospo.rdu.redhat.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Yinglin Sun <Yinglin.Sun@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754089Ab1JKOd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 10:33:57 -0400
Content-Disposition: inline
In-Reply-To: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 10:36:45PM -0700, Yinglin Sun wrote:
> Add IPv6 support in L2L3 xmit policy.
> L3L4 doesn't support IPv6 either, and I'll try to fix that later.
> 
> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
> ---
>  drivers/net/bonding/bond_main.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6d79b78..d6fd282 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -41,8 +41,10 @@
>  #include <linux/ptrace.h>
>  #include <linux/ioport.h>
>  #include <linux/in.h>
> +#include <linux/in6.h>
>  #include <net/ip.h>
>  #include <linux/ip.h>
> +#include <linux/ipv6.h>
>  #include <linux/tcp.h>
>  #include <linux/udp.h>
>  #include <linux/slab.h>
> @@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
>  {
>  	struct ethhdr *data = (struct ethhdr *)skb->data;
>  	struct iphdr *iph = ip_hdr(skb);
> +	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>  
>  	if (skb->protocol == htons(ETH_P_IP)) {
>  		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>  			(data->h_dest[5] ^ data->h_source[5])) % count;
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +		return ((ntohl(ipv6h->saddr.s6_addr32[3] ^
> +			       ipv6h->daddr.s6_addr32[3]) & 0xffff) ^
> +			(data->h_dest[5] ^ data->h_source[5])) % count;
>  	}
>  

There have been some attempts to add support for ipv6 hashing this in
the past, but none have been committed.  The best one I had seen was one
that did some extensive testing one a wide variety of ipv6 traffic and
it showed nice traffic distribution.  I'm not sure if it was ever posted
upstream, so I will see if I can dig it up.

Can you quantify how traffic was distributed with this algorithm?
