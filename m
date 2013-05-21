From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 05:09:07 -0700
Message-ID: <20130521120906.GD3578@linux.vnet.ibm.com>
References: <519B38EC.90401@yandex-team.ru>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519B38EC.90401@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 01:05:48PM +0400, Roman Gushchin wrote:
> Hi, all!
> 
> This is a fix for a problem described here:
> https://lkml.org/lkml/2013/4/16/371 .
> ---
> 
> Some network functions (udp4_lib_lookup2(), for instance) use the
> hlist_nulls_for_each_entry_rcu macro in a way that assumes restarting
> of a loop. In this case, it is strictly necessary to reread the head->first
> value from the memory before each scan.
> Without additional hints, gcc caches this value in a register. In this case,
> if a cached node is moved to another chain during the scan, we can loop
> forever getting wrong nulls values and restarting the loop uninterruptedly.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> Reported-by: Boris Zhmurov <zhmurov@yandex-team.ru>
> ---
>  include/linux/rculist_nulls.h | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
> index 2ae1371..efd51bf 100644
> --- a/include/linux/rculist_nulls.h
> +++ b/include/linux/rculist_nulls.h
> @@ -37,8 +37,9 @@ static inline void hlist_nulls_del_init_rcu(struct
> hlist_nulls_node *n)
>  	}
>  }
> 
> -#define hlist_nulls_first_rcu(head) \
> -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> +#define hlist_nulls_first_rcu(head)			\
> +	(*((struct hlist_nulls_node __rcu __force **)	\
> +	   &((volatile typeof(*head) *)head)->first))

Why not use ACCESS_ONCE() or (better) rcu_dereference_raw() here?

							Thanx, Paul

>  #define hlist_nulls_next_rcu(node) \
>  	(*((struct hlist_nulls_node __rcu __force **)&(node)->next))
> -- 
> 1.8.1.2
> 
