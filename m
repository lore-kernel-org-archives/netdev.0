From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH resend] netfilter: place in source hash after SNAT is
 done
Date: Tue, 18 Jan 2011 15:17:22 +0100
Message-ID: <4D35A0F2.5010908@trash.net>
References: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56479 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab1ARORZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:17:25 -0500
In-Reply-To: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.01.2011 12:28, Changli Gao wrote:
> If SNAT isn't done, the wrong info maybe got by the other cts.
> 
> As the filter table is after DNAT table, the packets dropped in filter
> table also bother bysource hash table.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/ipv4/netfilter/nf_nat_core.c |   18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
> index c04787c..51ce55a 100644
> --- a/net/ipv4/netfilter/nf_nat_core.c
> +++ b/net/ipv4/netfilter/nf_nat_core.c
> @@ -221,7 +221,14 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
>  	   manips not an issue.  */
>  	if (maniptype == IP_NAT_MANIP_SRC &&
>  	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
> -		if (find_appropriate_src(net, zone, orig_tuple, tuple, range)) {
> +		/* try the original tuple first */

This doesn't seem to be related to the hashing change. Please describe
the intention behind this change.

> +		if (in_range(orig_tuple, range)) {
> +			if (!nf_nat_used_tuple(orig_tuple, ct)) {
> +				*tuple = *orig_tuple;
> +				return;
> +			}
> +		} else if (find_appropriate_src(net, zone, orig_tuple, tuple,
> +			   range)) {
>  			pr_debug("get_unique_tuple: Found current src map\n");
>  			if (!nf_nat_used_tuple(tuple, ct))
>  				return;


