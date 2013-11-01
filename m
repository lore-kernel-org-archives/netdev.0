From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 1/2] ipv6: select oif corresponding to source address
Date: Fri, 01 Nov 2013 22:42:12 +0300
Message-ID: <52740414.3000806@cogentembedded.com>
References: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:45341 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab3KASmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 14:42:16 -0400
Received: by mail-lb0-f173.google.com with SMTP id w7so3750468lbi.18
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 11:42:15 -0700 (PDT)
In-Reply-To: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/01/2013 08:17 PM, Emmanuel Thierry wrote:

> When selecting the next hop, prefer the interface to which the
> source address is associated. This preference fixes problems for
> IPv6 hosts in multi-interfaces setup.

> In the case where a host has:
> * multiple links, each providing internet connectivity
> * both links advertising prefix and default route via Router
> Advertisements

> The current route selection process completly ignores whether or
> not the next hop is consistent with the source address. This may
> lead to packets being sent with a specific source address on the
> wrong link, then dropped by a router enforcing reverse path
> filtering.

> This fix pre-selects the output interface corresponding to the
> source address bound to the socket. The fl6->flowi6_oif
> attribute gives to the route selection algorithm an hint about
> what interface to choose in case of a tie between several routes
> of equal preferences (equal netmask, equal metrics and equal
> RFC 4191 preference values).

> Signed-off-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
> ---
>   net/ipv6/ip6_output.c |    8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 91fb4e8..1a05395 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -848,8 +848,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>   #endif
>   	int err;
>
> -	if (*dst == NULL)
> +	if (*dst == NULL) {
> +		struct inet6_ifaddr *ifp;

    Empty line needed between declaration and other code.

> +		if (!ipv6_addr_any(&fl6->saddr)) {
> +			ifp = ipv6_get_ifaddr(net, &fl6->saddr, NULL, 1);
> +			fl6->flowi6_oif = ifp->idev->dev->ifindex;
> +		}
>   		*dst = ip6_route_output(net, sk, fl6);
> +	}
>
>   	if ((err = (*dst)->error))
>   		goto out_err_release;

WBR, Sergei
