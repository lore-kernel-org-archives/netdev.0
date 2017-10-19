From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v2 2/2] ipv6: remove from fib tree aged out
 RTF_CACHE dst
Date: Wed, 18 Oct 2017 18:11:54 -0700
Message-ID: <20171019011154.jhiknygqm2xcf644@kafai-mbp.dhcp.thefacebook.com>
References: <cover.1508358132.git.pabeni@redhat.com>
 <12138554b307c66d0de7afd582ba83e027c383a2.1508358132.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        "Wei Wang" <weiwan@google.com>, Eric Dumazet <edumazet@google.com>,
        "Hannes Frederic Sowa" <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47876 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751589AbdJSBMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 21:12:03 -0400
Content-Disposition: inline
In-Reply-To: <12138554b307c66d0de7afd582ba83e027c383a2.1508358132.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 08:23:32PM +0000, Paolo Abeni wrote:
> The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
> dst cache") partially reverted 1e2ea8ad37be ("ipv6: set
> dst.obsolete when a cached route has expired").
> 
> As a result, RTF_CACHE dst referenced outside the fib tree will
> not be removed until the next sernum change; dst_check() does not
> fail on aged-out dst, and dst->__refcnt can't decrease: the aged
> out dst will stay valid for a potentially unlimited time after the
> timeout expiration.
> 
> This change explicitly removes RTF_CACHE dst from the fib tree when
> aged out. The rt6_remove_exception() logic will then obsolete the
> dst and other entities will drop the related reference on next
> dst_check().
> 
> v1 -> v2:
>   - do not touch dst.obsolete in rt6_remove_exception(), not needed
> 
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv6/route.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 5c27313803d2..a4a7f199120e 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1575,8 +1575,11 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
>  {
>  	struct rt6_info *rt = rt6_ex->rt6i;
>  
> -	if (atomic_read(&rt->dst.__refcnt) == 1 &&
Wei and I have discussed a few cases:

1) For PMTU rt, the dst.expires should have been set (to ip6_rt_mtu_expires)
   and the next dst_check() should have returned NULL.  The
   ip6_pol_route() should not have returned this expired pmtu rt also.

   The ip6_rt_mtu_expires should be used to decide if the rt is no
   longer useful instead of gc_args->timeout.
   
   We should not ignore __refcnt in this case.  Otherwise, we are
   punishing sk that is caching the rt since lastuse
   is only updated during the route lookup.

2) The cases that we can ignore __refcnt are:
   a) RTF_CACHE rt that has no expire set.  I believe only redirect rt falls
      into this bucket.  In this case, we can use gc_args->timeout.
   b) If there is an urgency to cleanup (like reaching ip6_rt_max_size)
      or user force a flush.


> -	    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
> +	/* we are pruning and obsoleting the exception route even if others
> +	 * have still reference to it, so that on next dst_check() such
> +	 * reference can be dropped
> +	 */
> +	if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
>  		RT6_TRACE("aging clone %p\n", rt);
>  		rt6_remove_exception(bucket, rt6_ex);
>  		return;
> -- 
> 2.13.6
> 
