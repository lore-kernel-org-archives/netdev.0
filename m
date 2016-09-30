From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] netfilter: xt_hashlimit: uses div_u64 for division
Date: Fri, 30 Sep 2016 09:38:42 -0700
Message-ID: <1475253522.28155.195.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160930160559.4102745-1-arnd@arndb.de>
         <20160930160559.4102745-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Joshua Hunt <johunt@akamai.com>,
        Vishwanath Pai <vpai@akamai.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160930160559.4102745-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-09-30 at 18:05 +0200, Arnd Bergmann wrote:
> The newly added support for high-resolution pps rates introduced multiple 64-bit
> division operations in one function, which fails on all 32-bit architectures:
> 
> net/netfilter/xt_hashlimit.o: In function `user2credits':
> xt_hashlimit.c:(.text.user2credits+0x3c): undefined reference to `__aeabi_uldivmod'
> xt_hashlimit.c:(.text.user2credits+0x68): undefined reference to `__aeabi_uldivmod'
> xt_hashlimit.c:(.text.user2credits+0x88): undefined reference to `__aeabi_uldivmod'
> 
> This replaces the division with an explicit call to div_u64 for version 2
> to documents that this is a slow operation, and reverts back to 32-bit arguments
> for the version 1 data to restore the original faster 32-bit division.
> 
> With both changes combined, we no longer get a link error.
> 
> Fixes: 11d5f15723c9 ("netfilter: xt_hashlimit: Create revision 2 to support higher pps rates")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Vishwanath Pai already sent a patch for this, and I did my version independently.
> The difference is that his version also the more expensive division for the
> version 1 variant that doesn't need it.
> 
> See also http://patchwork.ozlabs.org/patch/676713/
> ---
>  net/netfilter/xt_hashlimit.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index 44a095ecc7b7..3d5525df6eb3 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -464,20 +464,23 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
>  static u64 user2credits(u64 user, int revision)
>  {
>  	if (revision == 1) {
> +		u32 user32 = user; /* use 32-bit division */
> +

This looks dangerous to me. Have you really tried all possible cases ?

Caller (even if using revision == 1) does
user2credits(cfg->avg * cfg->burst, revision);

Since this is not a fast path, I would prefer to keep the 64bit divide.

Vishwanath version looks safer.
