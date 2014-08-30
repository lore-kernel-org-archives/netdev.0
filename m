From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net_ns cleanup / RCU overhead
Date: Sat, 30 Aug 2014 11:20:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408300907130.1671@ja.home.ssi.bg>
References: <20140820055855.GB5579@hostway.ca> <20140828192431.GF5001@linux.vnet.ibm.com> <20140828194422.GB8867@hostway.ca> <87oav4l5g9.fsf@x220.int.ebiederm.org> <20140828204658.GL5001@linux.vnet.ibm.com> <20140829004029.GA18300@hostway.ca>
 <alpine.LFD.2.11.1408290635530.1520@ja.home.ssi.bg> <87ppfjj6x6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Kirby <sim@hostway.ca>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ppfjj6x6.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 29 Aug 2014, Eric W. Biederman wrote:

> > 	I guess the problem is in nf_nat_net_exit,
> > may be other nf exit handlers too. pernet-exit handlers
> > should avoid synchronize_rcu and rcu_barrier.
> > A RCU callback and rcu_barrier in module-exit is the way
> > to go. cleanup_net includes rcu_barrier, so pernet-exit
> > does not need such calls.
> 
> In principle I agree, however in this particular case it looks a bit
> tricky because a separate hash table to track nat state per network
> namespace.

	It is still possible module's pernet-init handler to
attach in net->ct... special structure with all pointers that
should be freed by RCU callback for the module, like the hash table.

For example:

struct netns_ct_nat_rcu_allocs {
	struct rcu_head		rcu_head;
	struct hlist_head	*nat_bysource;
	unsigned int		nat_htable_size;
};

- pernet-init:
	- allocate structure, attach it to net->ct.nat_rcu_allocs
	- the original nat_bysource place remains because
	we want to avoid net->ct.nat_rcu_allocs dereference.

- pernet-exit:
	- copy nat_bysource and nat_htable_size to net->ct.nat_rcu_allocs,
	this can be done even in above pernet-init function
	- call_rcu(&net->ct.nat_rcu_allocs->rcu_head, nat_rcu_free);

- cleanup_net:
	- rcu_barrier()

- RCU callback (nat_rcu_free):
	- call nf_ct_free_hashtable
	- kfree the structure

- cleanup_net:
	- drop netns after rcu_barrier

	Due to the rcu_barrier in cleanup_net it is even
possible to provide per-module rcu_head instead of using
allocated structure, for example:

	call_rcu(&net->ct.nat_rcu_head, nat_rcu_free);

	Then the nat_rcu_free function will just call
nf_ct_free_hashtable before cleanup_net drops the netns struct.
In this case the memory price is just one rcu_head for every module
that uses RCU callback.

> At the same time all of the packets should be drained before
> we get to nf_nat_net_exit so it doesn't look the synchronize_rcu
> in nf_nat_exit is actually protecting anything.

	It is true for cleanup_net. I don't remember, can we
see packets while the particular module-exit calls
unregister_pernet_subsys(), may be yes?

Regards

--
Julian Anastasov <ja@ssi.bg>
