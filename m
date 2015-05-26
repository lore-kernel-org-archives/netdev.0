From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] mpls: fix mpls route deletes to not check for route scope and type
Date: Tue, 26 May 2015 16:48:07 -0500
Message-ID: <87bnh7yprc.fsf@x220.int.ebiederm.org>
References: <1432674867-63142-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35160 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbbEZVxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 17:53:07 -0400
In-Reply-To: <1432674867-63142-1-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Tue, 26 May 2015 14:14:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch fixes incorrect -EINVAL error due to invalid
> scope and type for mpls route deletes.

Well this is embarrassing apparently I did not exercise this code path
in iproute.

Looking through my tests the closest I came was:
ip -M route flush table all

> iproute2 route modify code does not set protocol/scope/type
> for RTM_DELROUTE msgs. mpls code can skip checking for
> these too.

I am really not certain that is the case.  I expect if you check
you will find that rtm_scope is set to 0  aka RT_SCOPE_UNIVERSE.

For scope I don't much care.  The mpls concepts and the ip concepts
don't match.  With mpls packets can be sent from anywhere in the
universe to an address that is valid only on one link.

For rtm_type I think we do care.  IPv4 and IPv6 are a disaster when it
comes to interfaces for setting up multicast routes, and I don't see any
reason why we would need to replicate that disaster for mpls.

As such I would like rtm_type to actually mean something, as for mpls
the lookup for multicast packets and the lookup for unicast packets is
completely different.  Unicast packet addresses are defined by the
receiver, and multicast packet addresses are defined by the sender.

So can we instead fix iproute to set rtm_type == RTN_UNICAST?
At least for mpls.

Eric

> $ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev swp1
>
> $ip -f mpls route show
> 100 as to 200 via inet 10.1.1.2 dev swp1
>
> $ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1
> RTNETLINK answers: Invalid argument
>
> $ip -f mpls route del 100
> RTNETLINK answers: Invalid argument
>
> After patch:
>
> $ip -f mpls route show
> 100 as to 200 via inet 10.1.1.2 dev swp1
>
> $ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1
>
> $ip -f mpls route show
>
> Reported-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Suggested-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/mpls/af_mpls.c |   11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 7b3f732..18ab7bf 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -693,10 +693,13 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  	 * (or source specific address in the case of multicast)
>  	 * all addresses have universal scope.
>  	 */
> -	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> -		goto errout;
> -	if (rtm->rtm_type != RTN_UNICAST)
> -		goto errout;
> +	if (nlh->nlmsg_type != RTM_DELROUTE) {
> +		if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
> +			goto errout;
> +		if (rtm->rtm_type != RTN_UNICAST)
> +			goto errout;
> +	}
> +
>  	if (rtm->rtm_flags != 0)
>  		goto errout;
