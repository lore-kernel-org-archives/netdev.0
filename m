From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 14:13:14 -0800
Message-ID: <20091210141314.7be114d9.akpm@linux-foundation.org>
References: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com
To: chavey@google.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Dec 2009 13:44:50 -0800
chavey@google.com wrote:

> Fix compiler warning "discards qualifiers from pointer target type",
> by allowing explicit discard of const qualifier thru type casting.
> The const_cast() macro is taken from a patch from Kaveh R. Ghazi
> [PATCH]: Fix problematic -Wcast-qual cases using new CONST_CAST macro
> posted on 
> http://old.nabble.com/-PATCH-:-Fix-problematic--Wcast-qual-cases-using-new-CONST_CAST--macro-td11824676.html
> The proposed __nowarn__ keyword has not yet been implemented, 
> (see http://gcc.gnu.org/ml/gcc-patches/2009-11/msg01261.html).
> 
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>
> ---
>  include/linux/kernel.h        |   12 ++++++++++++
>  net/ipv4/netfilter/ipt_ULOG.c |    2 +-
>  net/netfilter/xt_time.c       |    2 +-
>  3 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 3fa4c59..0246771 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -710,4 +710,16 @@ struct sysinfo {
>  # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
>  #endif
>  
> +/* Cast away const-ness to pass -Wcast-qual */

This comment simply doesn't make sense.

I don't think it adequately explains why the macro exists, how and when
one should use it, etc.

> +#ifdef __GNUC__
> +union gcc_constcast
> +{

union gcc_constcast {

> +	const void *cv;
> +	void *v;
> +};
> +#define const_cast(X) ((__extension__(union gcc_constcast)(const void *)(X)).v)
> +#else
> +#define const_cast(X) ((void *)(X))
> +#endif

Why don't we just use the simple version on all compilers?  What's the
advantage in using the gcc-specific extension?

And I was wrong - this should be implemented in linux/compiler.h.  We
have infrastructure there to separate gcc-specific and non-gcc
implementations of the same interface.

Finally, are we sure that __extension__(union gcc_constcast) is
available on all gcc versions mentioned in Documentation/Changes?  If
not, this patch should use include/linux/compiler-gcc4.h, etc.


