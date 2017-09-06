From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter: xt_hashlimit: avoid 64-bit division
Date: Wed, 6 Sep 2017 16:22:30 -0400
Message-ID: <7791dee1-64a9-dcaa-c5d9-0b04a44bc526@akamai.com>
References: <20170906195825.3715290-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Josh Hunt <johunt@akamai.com>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906195825.3715290-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/06/2017 03:57 PM, Arnd Bergmann wrote:
> 64-bit division is expensive on 32-bit architectures, and
> requires a special function call to avoid a link error like:
> 
> net/netfilter/xt_hashlimit.o: In function `hashlimit_mt_common':
> xt_hashlimit.c:(.text+0x1328): undefined reference to `__aeabi_uldivmod'
> 
> In the case of hashlimit_mt_common, we don't actually need a
> 64-bit operation, we can simply rewrite the function slightly
> to make that clear to the compiler.
> 
> Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  net/netfilter/xt_hashlimit.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index 10d48234f5f4..50b53d86eef5 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -531,7 +531,10 @@ static u64 user2rate_bytes(u64 user)
>  {
>  	u64 r;
>  
> -	r = user ? 0xFFFFFFFFULL / user : 0xFFFFFFFFULL;
> +	if (user > 0xFFFFFFFFULL)
> +		return 0;
> +
> +	r = user ? 0xFFFFFFFFULL / (u32)user : 0xFFFFFFFFULL;
>  	r = (r - 1) << 4;
>  	return r;
>  }
> 

I have submitted another patch to fix this:
https://patchwork.ozlabs.org/patch/809881/

We have seen this problem before, I was careful not to introduce this
again in the new patch but clearly I overlooked this particular line :(

In the other cases we fixed it by replacing division with div64_u64().

-Vishwanath
