From: Pablo Neira Ayuso <pablo@gnumonks.org>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Fri, 14 Sep 2012 14:07:50 +0200
Message-ID: <20120914120750.GA5764@1984>
References: <1347357081.3928.32.camel@localhost>
 <20120912213627.GJ14750@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn,
	kaber@trash.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120912213627.GJ14750@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2012 at 11:36:27PM +0200, Florian Westphal wrote:
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> [ CC'd Patrick ]
> 
> > I'm hitting this general protection fault, when unloading iptables_nat.
> > [  524.591067] Pid: 5842, comm: modprobe Not tainted 3.6.0-rc3-pablo-nf-next+ #1 Red Hat KVM
> > [  524.591067] RIP: 0010:[<ffffffffa002c2fd>]  [<ffffffffa002c2fd>] nf_nat_proto_clean+0x6d/0xc0 [nf_nat]
> > [  524.591067] RSP: 0018:ffff880073203e18  EFLAGS: 00010246
> > [  524.591067] RAX: 0000000000000000 RBX: ffff880077dff2c8 RCX: ffff8800797fab70
> > [  524.591067] RDX: dead000000200200 RSI: ffff880073203e88 RDI: ffffffffa002f208
> > [  524.591067] RBP: ffff880073203e28 R08: ffff880073202000 R09: 0000000000000000
> > [  524.591067] R10: dead000000200200 R11: dead000000100100 R12: ffffffff81c6dc00
> >  list corruption?   ^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^
> 
> Yep, looks like it.
> 
> > [  524.591067]  [<ffffffffa002c290>] ? nf_nat_net_exit+0x50/0x50 [nf_nat]
> > [  524.591067]  [<ffffffff815614e3>] nf_ct_iterate_cleanup+0xc3/0x170
> > [  524.591067]  [<ffffffffa002c54a>] nf_nat_l3proto_unregister+0x8a/0x100 [nf_nat]
> > [  524.591067]  [<ffffffff812a0303>] ? compat_prepare_timeout+0x13/0xb0
> > [  524.591067]  [<ffffffffa0035848>] nf_nat_l3proto_ipv4_exit+0x10/0x23 [nf_nat_ipv4]
> 
> On module removal nf_nat_ipv4 calls nf_iterate_cleanup which invokes
> nf_nat_proto_clean() for each conntrack.  That will then call
> hlist_del_rcu(&nat->bysource) using eachs conntracks nat ext area.
> 
> Problem is that nf_nat_proto_clean() is called multiple times for the same
> conntrack:
> a) nf_ct_iterate_cleanup() returns each ct twice (origin, reply)
> b) we call it both for l3 and for l4 protocol ids
> 
> We barf in hlist_del_rcu the 2nd time because ->pprev is poisoned.
> 
> This was introduced with the ipv6 nat patches.
> 
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -487,7 +487,7 @@ static int nf_nat_proto_clean(struct nf_conn *i, void *data)
>  
>         if (clean->hash) {
>                 spin_lock_bh(&nf_nat_lock);
> -               hlist_del_rcu(&nat->bysource);
> +               hlist_del_init_rcu(&nat->bysource);
>                 spin_unlock_bh(&nf_nat_lock);
>         } else {
> 
> Would probably avoid it.  I guess it would be nicer to only call this
> once for each ct.
> 
> Patrick, any other idea?

I already discussed this with Florian (I've been having problems with
two out of three of my email accounts this week... so I couldn't reply
to this email in the mailing list).

We can add nf_nat_iterate_cleanup that can iterate over the NAT
hashtable to replace current usage of nf_ct_iterate_cleanup.
