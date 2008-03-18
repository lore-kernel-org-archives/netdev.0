From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] fib_trie: fix warning from rcu_assign_poinger
Date: Tue, 18 Mar 2008 07:06:54 -0700
Message-ID: <20080318140654.GA8222@linux.vnet.ibm.com>
References: <20080317140236.6160fb4f@extreme> <20080317142706.235594c9@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from over.ny.us.ibm.com ([32.97.182.150]:38634 "EHLO
	over.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758043AbYCSTnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:43:05 -0400
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by pokfb.esmtp.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m2IFL4lJ030578
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 11:21:05 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2IF2Ija007548
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 11:02:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2IF3LmE259700
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 09:03:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2IF3FNs005284
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 09:03:16 -0600
Content-Disposition: inline
In-Reply-To: <20080317142706.235594c9@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 02:27:06PM -0700, Stephen Hemminger wrote:
> This gets rid of a warning caused by the test in rcu_assign_pointer.
> I tried to fix rcu_assign_pointer, but that devolved into a long
> set of discussions about doing it right that came to no real solution.
> Since the test in rcu_assign_pointer for constant NULL would never succeed in
> fib_trie, just open code instead.

Indeed -- fooling gcc is nontrivial.  :-/

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
>  net/ipv4/fib_trie.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index a7d089e..ce6cb34 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -177,10 +177,13 @@ static inline struct tnode *node_parent_rcu(struct node *node)
>  	return rcu_dereference(ret);
>  }
> 
> +/* Same as rcu_assign_pointer
> + * but that macro() assumes that value is a pointer.
> + */
>  static inline void node_set_parent(struct node *node, struct tnode *ptr)
>  {
> -	rcu_assign_pointer(node->parent,
> -			   (unsigned long)ptr | NODE_TYPE(node));
> +	smp_wmb();
> +	node->parent = (unsigned long)ptr | NODE_TYPE(node);
>  }
> 
>  static inline struct node *tnode_get_child(struct tnode *tn, unsigned int i)
> -- 
> 1.5.4.3
> 
