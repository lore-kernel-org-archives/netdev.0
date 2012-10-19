From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vxlan nits
Date: Fri, 19 Oct 2012 13:28:15 -0700
Message-ID: <20121019132815.547a5bb8@nehalam.linuxnetplumber.net>
References: <201210191148.q9JBkm0v018443@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46125 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932743Ab2JSU3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:29:01 -0400
In-Reply-To: <201210191148.q9JBkm0v018443@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Oct 2012 07:46:48 -0400
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> This patch fixes a couple problems with vxlan.
> 
> 1) Improper check of NUD_PERMANENT makes permanent forwarding table
> 	entries timeout too.
> 
> 2) Check for "0.0.0.0" as gaddr and allow to mean "no group". The
> 	iproute2 patch sends gaddr even if not specified, which
> 	fails the IN_MULTICAST() test. This patch allows static-only
> 	forwarding and dropping everything else.
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 607976c..3fac9f3 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -816,7 +816,7 @@ static void vxlan_cleanup(unsigned long arg)
>  				= container_of(p, struct vxlan_fdb, hlist);
>  			unsigned long timeout;
>  
> -			if (f->state == NUD_PERMANENT)
> +			if (f->state & NUD_PERMANENT)
>  				continue;
>  
>  			timeout = f->used + vxlan->age_interval * HZ;
> @@ -1047,7 +1047,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  
>  	if (data[IFLA_VXLAN_GROUP]) {
>  		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
> -		if (!IN_MULTICAST(ntohl(gaddr))) {
> +		if (gaddr && !IN_MULTICAST(ntohl(gaddr))) {
>  			pr_debug("group address is not IPv4 multicast\n");
>  			return -EADDRNOTAVAIL;
>  		}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The first is a bug, the second doesn't need to be fixed in the kernel.
I change iproute to not sent group address unless it is defined.

The plan is to add IPV6 support, in which case group address could
be IPV6.
