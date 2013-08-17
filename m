From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] ipv6: remove max_addresses check from ipv6_create_tempaddr
Date: Sat, 17 Aug 2013 10:23:26 +0800
Message-ID: <520EDE9E.1070109@huawei.com>
References: <20130816110226.GB2112@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <kargig@void.gr>, <ppandit@redhat.com>,
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:30815 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab3HQCXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 22:23:39 -0400
In-Reply-To: <20130816110226.GB2112@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/16 19:02, Hannes Frederic Sowa wrote:
> Because of the max_addresses check attackers were able to disable privacy
> extensions on an interface by creating enough autoconfigured addresses:
> 
> <http://seclists.org/oss-sec/2012/q4/292>
> 
> But the check is not actually needed: max_addresses protects the
> kernel to install too many ipv6 addresses on an interface and guards
> addrconf_prefix_rcv to install further addresses as soon as this limit
> is reached. We only generate temporary addresses in direct response of
> a new address showing up. As soon as we filled up the maximum number of
> addresses of an interface, we stop installing more addresses and thus
> also stop generating more temp addresses.
> 
> Even if the attacker tries to generate a lot of temporary addresses
> by announcing a prefix and removing it again (lifetime == 0) we won't
> install more temp addresses, because the temporary addresses do count
> to the maximum number of addresses, thus we would stop installing new
> autoconfigured addresses when the limit is reached.
> 
> This patch fixes CVE-2013-0343 (but other layer-2 attacks are still
> possible).
> 
> Thanks to Ding Tianhong to bring this topic up again.
> 
> Cc: Ding Tianhong <dingtianhong@huawei.com>
> Cc: George Kargiotakis <kargig@void.gr>
> Cc: P J P <ppandit@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/addrconf.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index ad12f7c..6926b56 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1131,12 +1131,10 @@ retry:
>  	if (ifp->flags & IFA_F_OPTIMISTIC)
>  		addr_flags |= IFA_F_OPTIMISTIC;
>  
> -	ift = !max_addresses ||
> -	      ipv6_count_addresses(idev) < max_addresses ?
> -		ipv6_add_addr(idev, &addr, NULL, tmp_plen,
> -			      ipv6_addr_scope(&addr), addr_flags,
> -			      tmp_valid_lft, tmp_prefered_lft) : NULL;
> -	if (IS_ERR_OR_NULL(ift)) {
> +	ift = ipv6_add_addr(idev, &addr, NULL, tmp_plen,
> +			    ipv6_addr_scope(&addr), addr_flags,
> +			    tmp_valid_lft, tmp_prefered_lft);
> +	if (IS_ERR(ift)) {
>  		in6_ifa_put(ifp);
>  		in6_dev_put(idev);
>  		pr_info("%s: retry temporary address regeneration\n", __func__);
> 

Acked-by: Ding Tianhong <dingtianhong@huawei.com>
