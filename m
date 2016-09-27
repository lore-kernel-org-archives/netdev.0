From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix link error in 32bit arch because of 64bit division
Date: Tue, 27 Sep 2016 06:32:21 -0700
Message-ID: <1474983141.28155.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160927074203.GA3968@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        johunt@akamai.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        pai.vishwain@gmail.com, zlpnobody@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160927074203.GA3968@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-27 at 03:42 -0400, Vishwanath Pai wrote:
> Fix link error in 32bit arch because of 64bit division
> 
> Division of 64bit integers will cause linker error undefined reference
> to `__udivdi3'. Fix this by replacing divisions with div64_64
> 
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> 
> ---
>  net/netfilter/xt_hashlimit.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index 44a095e..7fc694e 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -465,19 +465,20 @@ static u64 user2credits(u64 user, int revision)
>  {
>  	if (revision == 1) {
>  		/* If multiplying would overflow... */
> -		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
> +		if (user > div64_u64(0xFFFFFFFF, (HZ*CREDITS_PER_JIFFY_v1)))

How can this be needed ? 0xFFFFFFFF is 32bits, compiler knows how to
compute 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1) itself, without using a
64 bit divide !

Please be selective.

>  			/* Divide first. */
> -			return (user / XT_HASHLIMIT_SCALE) *\
> +			return div64_u64(user, XT_HASHLIMIT_SCALE) *\
>  						HZ * CREDITS_PER_JIFFY_v1;
>  
> -		return (user * HZ * CREDITS_PER_JIFFY_v1) \
> -						/ XT_HASHLIMIT_SCALE;
> +		return div64_u64((user * HZ * CREDITS_PER_JIFFY_v1),
> +				  XT_HASHLIMIT_SCALE);
>  	} else {
> -		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
> -			return (user / XT_HASHLIMIT_SCALE_v2) *\

Probably same remark here.

> +		if (user > div64_u64(0xFFFFFFFFFFFFFFFF, (HZ*CREDITS_PER_JIFFY)))
> +			return div64_u64(user, XT_HASHLIMIT_SCALE_v2) *\
>  						HZ * CREDITS_PER_JIFFY;
>  
> -		return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE_v2;
> +		return div64_u64((user * HZ * CREDITS_PER_JIFFY),
> +				 XT_HASHLIMIT_SCALE_v2);
>  	}
>  }
>  


