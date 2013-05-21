From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 06:44:45 -0700
Message-ID: <1369143885.3301.221.camel@edumazet-glaptop>
References: <519B38EC.90401@yandex-team.ru>
	 <20130521120906.GD3578@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roman Gushchin <klamm@yandex-team.ru>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521120906.GD3578@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 05:09 -0700, Paul E. McKenney wrote:

> > 
> > -#define hlist_nulls_first_rcu(head) \
> > -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> > +#define hlist_nulls_first_rcu(head)			\
> > +	(*((struct hlist_nulls_node __rcu __force **)	\
> > +	   &((volatile typeof(*head) *)head)->first))
> 
> Why not use ACCESS_ONCE() or (better) rcu_dereference_raw() here?

More exactly we have :

#define list_entry_rcu(ptr, type, member) \
        ({typeof (*ptr) __rcu *__ptr = (typeof (*ptr) __rcu __force *)ptr; \
         container_of((typeof(ptr))rcu_dereference_raw(__ptr), type, member); \
        })

#define list_for_each_entry_rcu(pos, head, member) \
        for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
                &pos->member != (head); \
                pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
<< and >>

#define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                 \
        for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
                (!is_a_nulls(pos)) &&                                           \
                ({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
                pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))

We need to change hlist_nulls_for_each_entry_rcu() to use same construct,
so that the rcu_dereference_raw() is performed at the right place.
