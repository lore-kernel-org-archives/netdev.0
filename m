From: cliff white <cliffw@osdl.org>
Subject: Re: gcc confused about static inline. - route.c
Date: Mon, 28 Mar 2005 14:59:08 -0800
Message-ID: <20050328145908.6f2cd38a@es175>
References: <20050328132314.480b8b1d@es175>
	<20050328214103.GA3609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20050328214103.GA3609@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005 16:41:03 -0500
Dave Jones <davej@redhat.com> wrote:

> On Mon, Mar 28, 2005 at 01:23:14PM -0800, cliff white wrote:
>  > 
>  > Building the gkernel bits, have this error:
>  > 
>  > net/ipv4/route.c: In function `rt_remove_balanced_route':
>  > net/ipv4/route.c:151: sorry, unimplemented: inlining failed in call to 'compare_keys': function body not available
>  > net/ipv4/route.c:540: sorry, unimplemented: called from here
>  > 
>  > route.c has this define at line 151
>  > :
>  > static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);
>  > 
>  > function body is defined starting at line 861. 
>  > 
>  > We are using gcc 3.4.2 right now, is there a way to fix this?
>  > thanks
>  > cliffw
> 
> 
> Shuffling the order of the functions fixed this for me.
> 
Thanks, that looked like the answer, but i wanted to ask anyway...
cliffw

> 		Dave
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> diff -urNp --exclude-from=/home/davej/.exclude linux-10001/init/Makefile linux-10002/init/Makefile
> --- linux-2.6.11/net/ipv4/route.c~	2005-03-24 19:18:24.000000000 -0500
> +++ linux-2.6.11/net/ipv4/route.c	2005-03-24 19:19:39.000000000 -0500
> @@ -520,6 +520,13 @@ static inline u32 rt_score(struct rtable
>  	return score;
>  }
>  
> +static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
> +{
> +	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
> +	       fl1->oif     == fl2->oif &&
> +	       fl1->iif     == fl2->iif;
> +}
> +
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
>  static struct rtable **rt_remove_balanced_route(struct rtable **chain_head,
>  						struct rtable *expentry,
> @@ -858,13 +865,6 @@ work_done:
>  out:	return 0;
>  }
>  
> -static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
> -{
> -	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
> -	       fl1->oif     == fl2->oif &&
> -	       fl1->iif     == fl2->iif;
> -}
> -
>  static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
>  {
>  	struct rtable	*rth, **rthp;
> 


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
