From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH iproute2 net-next-for-3.13] iplink_bond: fix parameter
 value matching
Date: Fri, 7 Feb 2014 10:45:03 +0800
Message-ID: <52F448AF.3060604@huawei.com>
References: <20140206125901.A95E2E5A97@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:11868 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaBGCpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 21:45:24 -0500
In-Reply-To: <20140206125901.A95E2E5A97@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/6 20:59, Michal Kubecek wrote:
> Lookup function get_index() compares argument with table entries
> only up to the length of the table entry so that if an entry
> with lower index is a substring of a later one, earlier entry is
> used even if the argument is equal to the other. For example,
> 
>   ip link set bond0 type bond xmit_hash_policy layer2+3
> 
> sets xmit_hash_policy to 0 (layer2) as this is found before
> "layer2+3" can be checked.
> 
> I believe the reason for using strncmp() rather than simple
> strcmp() was to allow abbreviations which means maximum length
> for comparison should be length of the string looked up.
> However, this would cause a problem if shorter value follows
> longer one and shorter one is entered (there is no such case now
> but it might happen in the future). So let's try to find an
> exact match first and only if none is found, do a second pass
> with checking for abbreviated values.
> 
> Fixes: 63d127b0 ("iproute2: finish support for bonding attributes")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  ip/iplink_bond.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
> index f22151e..4cd6843 100644
> --- a/ip/iplink_bond.c
> +++ b/ip/iplink_bond.c
> @@ -105,8 +105,14 @@ static int get_index(const char **tbl, char *name)
>  			if (i == index)
>  				return i;
>  
> +	/* first check for an exact match */
>  	for (i = 0; tbl[i]; i++)
> -		if (strncmp(tbl[i], name, strlen(tbl[i])) == 0)
> +		if (strcmp(tbl[i], name) == 0)
> +			return i;
> +

Yes, I think strcmp is more better here.

> +	/* no exact match, try to interpret as an abbreviation */
> +	for (i = 0; tbl[i]; i++)
> +		if (strncmp(tbl[i], name, strlen(name)) == 0)
>  			return i;
>  
I don't think it is needed here, if no match, just return the result.
>  	return -1;
> 
