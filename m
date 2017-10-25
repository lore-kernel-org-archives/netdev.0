From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: update use count on dst_check()
Date: Tue, 24 Oct 2017 18:00:19 -0700
Message-ID: <20171025010019.vj6sicf6dfvf7n66@kafai-mbp.dhcp.thefacebook.com>
References: <f9c3808ba0aa553eaaa47c1507ba417366f015de.1508841703.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45992 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751682AbdJYBAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:00:32 -0400
Content-Disposition: inline
In-Reply-To: <f9c3808ba0aa553eaaa47c1507ba417366f015de.1508841703.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 10:42:57AM +0000, Paolo Abeni wrote:
> Currently, the dst 'lastuse' field is not updated in a reliable way
> for dst entries only accessed via socket cache.
> 
> This may fool the ipv6 dst gc, especially since we really age out unused
> entries, either via the commit 1859bac04fb6 ("ipv6: remove from fib tree
> aged out RTF_CACHE dst") or via the commit 1e2ea8ad37be ("ipv6: set
> dst.obsolete when a cached route has expired").
There is already an exception table and it already has a different way
of purging which is more inline with IPv4.  It purges based on
'When was the last time the ICMPv6 too-big/redirect received' and
we purge the one that will expire sooner.

As we are moving away from the IPv6's gc,
I don't think we need to further depend on lastuse to purge/age
the RTF_CACHE on top of the purging being done in the exception
table.

Beside, lastuse is only useful for RTF_CACHE route (redirect
route in particular since it has no expire which we should give
it one imo).  However, rt6_check() is called for everything,
e.g. non RTF_CACHE route which is the common case.  Even though
dst_use_noref() is cheap to do now, it is still unnecessary for
the common fast path.

> 
> Updating such field is now very cheap, thanks to commit 0da4af00b2ed
> ("ipv6: only update __use and lastusetime once per jiffy at most"),
> so we can address the issue updating 'lastuse' in ip6_dst_check(),
> if successful.
> 
> Fixes: 1859bac04fb6 ("ipv6: remove from fib tree aged out RTF_CACHE dst")
> Fixes: 1e2ea8ad37be ("ipv6: set dst.obsolete when a cached route has expired")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv6/route.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 87a15cbd0e8b..8f8c7fb83b9b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1952,6 +1952,7 @@ static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
>  	if (rt6_check_expired(rt))
>  		return NULL;
>  
> +	dst_use_noref(&rt->dst, jiffies);
>  	return &rt->dst;
>  }
>  
> -- 
> 2.13.6
> 
