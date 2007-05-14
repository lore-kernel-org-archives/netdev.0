From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Mon, 14 May 2007 12:21:34 +0200
Message-ID: <4648382E.8030009@trash.net>
References: <200704271705.l3RH5Brw026873@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34683 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbXENKXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:23:53 -0400
In-Reply-To: <200704271705.l3RH5Brw026873@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=2d771cd86d4c3af26f34a7bcdc1b87696824cad9
> Commit:     2d771cd86d4c3af26f34a7bcdc1b87696824cad9
> 
>     [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers are removed
>     
>     this is a small patch by Janusz Krzysztofik to ip_route_output_slow()
>     that allows VIP-less LVS linux director to generate packets
>     originating >From VIP if sysctl_ip_nonlocal_bind is set.
>     
>     In a nutshell, the intention is for an LVS linux director to be able
>     to send ICMP unreachable responses to end-users when real-servers are
>     removed.
>     
>     http://archive.linuxvirtualserver.org/html/lvs-users/2007-01/msg00106.html
>     
>     Signed-off-by: Simon Horman <horms@verge.net.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index df9fe4f..cb76e3c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2396,7 +2396,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
>  
>  		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
>  		dev_out = ip_dev_find(oldflp->fl4_src);
> -		if (dev_out == NULL)
> +		if ((dev_out == NULL) && !(sysctl_ip_nonlocal_bind))
>  			goto out;


This allows any user to send spoofed packets when ip_nonlocal_bind
is set, which is a quite big change in behaviour of this option.
The TPROXY patches include a similar change, but use a flag in
struct flowi that requires CAP_NET_ADMIN to be set, which seems like
a better idea. Alternatively you could just use input routing for
non-local source addresses like ip_route_me_harder does.

BTW, there doesn't even seem to be a spot where IPVS calls
ip_route_output with the source address set. What exactly is this
needed for?

