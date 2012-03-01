From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size
 parametre.
Date: Thu, 1 Mar 2012 11:18:09 +0100
Message-ID: <20120301101809.GA6488@1984>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2012 at 02:46:30PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> While copying to userspace, the size of source is 29byte where as
> size parametre is 32 byte.  Its leaking extra-information from
> kernel space to user space.
> Replace EBT_FUNCTION_MAXNAMELEN by XT_EXTENSION_MAXNAMELEN.

There's no information leak.

Let me clarify this. Have a look at /linux/netfilter/x_tables.h, then
you find:

#define XT_FUNCTION_MAXNAMELEN 30
#define XT_EXTENSION_MAXNAMELEN 29
#define XT_TABLE_MAXNAMELEN 32

For iptables, everything has been 30 bytes, but we stole one
byte to store the revision field for matches/targets.

For ebtables, there's no revision field and the length of the
table name is different.

But linux/netfilter/in ebtables.h, you'll find:

#define EBT_TABLE_MAXNAMELEN 32
#define EBT_CHAIN_MAXNAMELEN EBT_TABLE_MAXNAMELEN
#define EBT_FUNCTION_MAXNAMELEN EBT_TABLE_MAXNAMELEN

Note that someone decided to use 32 bytes for the ebtables
tables/match/target name instead of 30 bytes in iptables.

Yes, it sucks a bit we have to live with these interfaces until
we have some netlink interface for all these things.

> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  net/bridge/netfilter/ebtables.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 5864cc4..f3fcbd9 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1335,7 +1335,7 @@ static inline int ebt_make_matchname(const struct ebt_entry_match *m,
>      const char *base, char __user *ubase)
>  {
>  	char __user *hlp = ubase + ((char *)m - base);
> -	if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNAMELEN))
> +	if (copy_to_user(hlp, m->u.match->name, XT_EXTENSION_MAXNAMELEN))
>  		return -EFAULT;
>  	return 0;
>  }
> @@ -1344,7 +1344,7 @@ static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
>      const char *base, char __user *ubase)
>  {
>  	char __user *hlp = ubase + ((char *)w - base);
> -	if (copy_to_user(hlp , w->u.watcher->name, EBT_FUNCTION_MAXNAMELEN))
> +	if (copy_to_user(hlp , w->u.watcher->name, XT_EXTENSION_MAXNAMELEN))
>  		return -EFAULT;
>  	return 0;
>  }
> @@ -1368,7 +1368,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
>  	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
>  	if (ret != 0)
>  		return ret;
> -	if (copy_to_user(hlp, t->u.target->name, EBT_FUNCTION_MAXNAMELEN))
> +	if (copy_to_user(hlp, t->u.target->name, XT_EXTENSION_MAXNAMELEN))
>  		return -EFAULT;
>  	return 0;
>  }
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
