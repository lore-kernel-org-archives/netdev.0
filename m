From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 02:58:39 -0700
Message-ID: <20130522095839.GC3578@linux.vnet.ibm.com>
References: <519B38EC.90401@yandex-team.ru>
 <20130521120906.GD3578@linux.vnet.ibm.com>
 <1369143885.3301.221.camel@edumazet-glaptop>
 <519B8908.9080007@yandex-team.ru>
 <1369150693.3301.233.camel@edumazet-glaptop>
 <519BB90B.6080706@yandex-team.ru>
 <1369188080.3301.268.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Gushchin <klamm@yandex-team.ru>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369188080.3301.268.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 07:01:20PM -0700, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 22:12 +0400, Roman Gushchin wrote:
> > > If other rcu accessors have the same problem, a more complete patch is
> > > needed.
> > 
> > [PATCH] rcu: fix a race in rcu lists traverse macros
> > 
> > Some network functions (udp4_lib_lookup2(), for instance) use the
> > rcu lists traverse macros (hlist_nulls_for_each_entry_rcu, for instance)
> > in a way that assumes restarting of a loop. In this case, it is strictly
> > necessary to reread the head->first value from the memory before each scan.
> > Without additional hints, gcc caches this value in a register. In this case,
> > if a cached node is moved to another chain during the scan, we can loop
> > forever getting wrong nulls values and restarting the loop uninterruptedly.
> > 
> > Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> > Reported-by: Boris Zhmurov <zhmurov@yandex-team.ru>
> > ---
> >   include/linux/compiler.h      | 6 ++++++
> >   include/linux/rculist.h       | 6 ++++--
> >   include/linux/rculist_nulls.h | 3 ++-
> >   3 files changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/compiler.h b/include/linux/compiler.h
> > index 92669cd..0e05d7c 100644
> > --- a/include/linux/compiler.h
> > +++ b/include/linux/compiler.h
> > @@ -351,6 +351,12 @@ void ftrace_likely_update(struct ftrace_branch_data *f, int val, int expect);
> >    */
> >   #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
> > 
> > +/*
> > + * Prevent the compiler from optimizing accesses to structure member.
> > + */
> > +#define GET_STRUCT_FIELD_VOLATILE(struct_ptr, field)		\
> > +	(((volatile typeof(*struct_ptr) *)struct_ptr)->field)
> > +
> >   /* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
> >   #ifdef CONFIG_KPROBES
> >   # define __kprobes	__attribute__((__section__(".kprobes.text")))
> > diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> > index 8089e35..6c3eea7 100644
> > --- a/include/linux/rculist.h
> > +++ b/include/linux/rculist.h
> > @@ -282,7 +282,8 @@ static inline void list_splice_init_rcu(struct list_head *list,
> >    * as long as the traversal is guarded by rcu_read_lock().
> >    */
> >   #define list_for_each_entry_rcu(pos, head, member) \
> > -	for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
> > +	for (pos = list_entry_rcu(GET_STRUCT_FIELD_VOLATILE(head, next), \
> > +				  typeof(*pos), member); \
> >   		&pos->member != (head); \
> >   		pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
> > 
> > @@ -348,7 +349,8 @@ static inline void hlist_replace_rcu(struct hlist_node *old,
> >   /*
> >    * return the first or the next element in an RCU protected hlist
> >    */
> > -#define hlist_first_rcu(head)	(*((struct hlist_node __rcu **)(&(head)->first)))
> > +#define hlist_first_rcu(head)	(*((struct hlist_node __rcu **)		\
> > +				   (&GET_STRUCT_FIELD_VOLATILE(head, first))))
> >   #define hlist_next_rcu(node)	(*((struct hlist_node __rcu **)(&(node)->next)))
> >   #define hlist_pprev_rcu(node)	(*((struct hlist_node __rcu **)((node)->pprev)))
> > 
> > diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
> > index 2ae1371..b04fd0a 100644
> > --- a/include/linux/rculist_nulls.h
> > +++ b/include/linux/rculist_nulls.h
> > @@ -38,7 +38,8 @@ static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_node *n)
> >   }
> > 
> >   #define hlist_nulls_first_rcu(head) \
> > -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> > +	(*((struct hlist_nulls_node __rcu __force **)	\
> > +	   &(GET_STRUCT_FIELD_VOLATILE(head, first))))
> > 
> >   #define hlist_nulls_next_rcu(node) \
> >   	(*((struct hlist_nulls_node __rcu __force **)&(node)->next))

Now that I am more awake...

The RCU list macros assume that the list header is either statically
allocated (in which case no ACCESS_ONCE() or whatever is needed) or
that the caller did whatever was necessary to protect the list header,
whether that be holding the right lock, using rcu_dereference() when
traversing the pointer to the list header, or whatever.

Maybe I need to document this assumption...

						Thanx, Paul

> Please use ACCESS_ONCE(), which is the standard way to deal with this,
> and remove the rcu_dereference_raw() in 
> hlist_nulls_for_each_entry_rcu()
> 
> something like : (for the nulls part only)
> 
> diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
> index 2ae1371..1d485d3 100644
> --- a/include/linux/rculist_nulls.h
> +++ b/include/linux/rculist_nulls.h
> @@ -40,6 +40,9 @@ static inline void hlist_nulls_del_init_rcu(struct hlist_nulls_node *n)
>  #define hlist_nulls_first_rcu(head) \
>  	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> 
> +#define hlist_nulls_first_rcu_once(head) \
> +	ACCESS_ONCE(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> +
>  #define hlist_nulls_next_rcu(node) \
>  	(*((struct hlist_nulls_node __rcu __force **)&(node)->next))
> 
> @@ -107,7 +110,7 @@ static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
>   *
>   */
>  #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                        \
> -	for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
> +	for (pos = hlist_nulls_first_rcu_once(head);                            \
>  		(!is_a_nulls(pos)) &&                                           \
>  		({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
>                 pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
> 
> 
> 
