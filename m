From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH] [IPV4]: Remove warning in node_set_parent.
Date: Tue, 12 Feb 2008 11:11:58 +0300
Message-ID: <1202803918.13118.24.camel@iris.sw.ru>
References: <1202719637-4925-1-git-send-email-den@openvz.org>
	 <20080211114849.042a3da2@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43965 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbYBLIL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 03:11:59 -0500
In-Reply-To: <20080211114849.042a3da2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ugly :), but

Acked-by: Denis V. Lunev <den@openvz.org>

On Mon, 2008-02-11 at 11:48 -0800, Stephen Hemminger wrote:
> On Mon, 11 Feb 2008 11:47:17 +0300
> "Denis V. Lunev" <den@openvz.org> wrote:
> 
> > net/ipv4/fib_trie.c: In function 'node_set_parent':
> > net/ipv4/fib_trie.c:184: warning: assignment makes integer from pointer
> > without a cast
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> > ---
> >  net/ipv4/fib_trie.c |    7 ++++---
> >  1 files changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> > index f5fba3f..1753cd4 100644
> > --- a/net/ipv4/fib_trie.c
> > +++ b/net/ipv4/fib_trie.c
> > @@ -177,10 +177,11 @@ static inline struct tnode *node_parent_rcu(struct node *node)
> >  	return rcu_dereference(ret);
> >  }
> >  
> > -static inline void node_set_parent(struct node *node, struct tnode *ptr)
> > +static inline void node_set_parent(struct node *node, struct tnode *__ptr)
> >  {
> > -	rcu_assign_pointer(node->parent,
> > -			   (unsigned long)ptr | NODE_TYPE(node));
> > +	struct node *ptr;
> > +	ptr = (struct node *)((unsigned long)__ptr | NODE_TYPE(node));
> > +	rcu_assign_pointer(node->parent, ptr);
> >  }
> >  
> >  static inline struct node *tnode_get_child(struct tnode *tn, unsigned int i)
> 
> No, this causes new warning from assigning pointer (ptr) to integer node->parent.
> 
> Why not just change rcupdate.h to do the right thing.
> 
> >From a00f7cbf1c2f2282eced236e1e8b99b0fecd213a Mon Sep 17 00:00:00 2001
> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Mon, 11 Feb 2008 11:28:13 -0800
> Subject: [PATCH] eliminate warnings when rcu_assign_pointer is used with unsigned long
> 
> It is reasonable to use RCU with non-pointer values, and describe
> the optimization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
>  include/linux/rcupdate.h |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 37a642c..c44ac87 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -172,14 +172,15 @@ struct rcu_head {
>   * structure after the pointer assignment.  More importantly, this
>   * call documents which pointers will be dereferenced by RCU read-side
>   * code.
> + *
> + * If value is the NULL (constant 0), then no barrier is needed.
>   */
>  
> -#define rcu_assign_pointer(p, v) \
> -	({ \
> -		if (!__builtin_constant_p(v) || \
> -		    ((v) != NULL)) \
> -			smp_wmb(); \
> -		(p) = (v); \
> +#define rcu_assign_pointer(p, v)			\
> +	({						\
> +		if (!(__builtin_constant_p(v) && v))	\
> +			smp_wmb();			\
> +		(p) = (v);				\
>  	})
>  
>  /**
> -- 
> 1.5.3.8
> 
> 
> 
> 

