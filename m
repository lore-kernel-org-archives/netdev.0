From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Tue, 12 Feb 2008 20:32:18 +0100
Message-ID: <20080212193218.GA2803@ami.dom.local>
References: <20080211.171645.74019568.davem@davemloft.net> <20080212085714.GB2582@ff.dom.local> <20080212160729.GA9157@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761032AbYBLT3S@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080212160729.GA9157@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 12, 2008 at 08:07:29AM -0800, Paul E. McKenney wrote:
...
> "All programmers are blind, especially me."

Hmm... I got it my way: you - superheroes - sometimes seem to be just
like us - common people... (Probably early in the morning, before
dressing your funny costumes?) 

> You are right, Jarek.  I ran this through gcc, and the following
> comes close:
> 
> #define rcu_assign_pointer(p, v) \
> 	({ \
> 		if (!__builtin_constant_p(v) || (v)) \
> 			smp_wmb(); \
> 		(p) = (v); \
> 	})
> 
> But I am concerned about the following case:
> 
> 	rcu_assign_pointer(global_index, 0);
> 
> 	. . .
> 
> 	x = global_array[rcu_dereference(global_index)];
> 
> Since arrays have a zero-th element, we would really want a memory
> barrier in this case.

It seems the above version of this macro uses the barrier for 0, but
if I miss something, or for these other: documenting reasons, then of
course you are right.

> 
> So how about leaving the index-unfriendly version of rcu_assign_pointer()
> and adding an rcu_assign_index() as follows?
> 
> 							Thanx, Paul
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  rcupdate.h |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h linux-2.6.24-rai/include/linux/rcupdate.h
> --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37.000000000 -0800
> +++ linux-2.6.24-rai/include/linux/rcupdate.h	2008-02-12 08:04:59.000000000 -0800
> @@ -278,6 +278,24 @@ extern struct lockdep_map rcu_lock_map;
>  					})
>  
>  /**
> + * rcu_assign_index - assign (publicize) a index of a newly
> + * initialized array elementg that will be dereferenced by RCU

---------------------------^
 + * initialized array element that will be dereferenced by RCU

Regards,
Jarek P.
