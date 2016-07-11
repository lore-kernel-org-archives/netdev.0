From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 3/3] netfilter: replace list_head with single
 linked list
Date: Mon, 11 Jul 2016 12:29:31 +0200
Message-ID: <20160711102931.GA18199@salvia>
References: <1467321575-6107-1-git-send-email-aconole@bytheb.org>
 <1467321575-6107-4-git-send-email-aconole@bytheb.org>
 <20160708233038.GA2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Conole <aconole@bytheb.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160708233038.GA2067@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 09, 2016 at 01:30:38AM +0200, Florian Westphal wrote:
> Aaron Conole <aconole@bytheb.org> wrote:
> > --- a/net/netfilter/core.c
> > +++ b/net/netfilter/core
> [..]
> > +#define nf_entry_dereference(e) \
> > +	rcu_dereference_protected(e, lockdep_is_held(&nf_hook_mutex))
> >  
> > -static struct list_head *nf_find_hook_list(struct net *net,
> > -					   const struct nf_hook_ops *reg)
> > +static struct nf_hook_entry *nf_find_hook_list(struct net *net,
> > +					       const struct nf_hook_ops *reg)
> >  {
> > -	struct list_head *hook_list = NULL;
> > +	struct nf_hook_entry *hook_list = NULL;
> >  
> >  	if (reg->pf != NFPROTO_NETDEV)
> > -		hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
> > +		hook_list = rcu_dereference(net->nf.hooks[reg->pf]
> > +					    [reg->hooknum]);
> >  	else if (reg->hooknum == NF_NETDEV_INGRESS) {
> >  #ifdef CONFIG_NETFILTER_INGRESS
> >  		if (reg->dev && dev_net(reg->dev) == net)
> > -			hook_list = &reg->dev->nf_hooks_ingress;
> > +			hook_list =
> > +				rcu_dereference(reg->dev->nf_hooks_ingress);
> 
> Both of these should use nf_entry_dereference() to avoid the lockdep
> splat reported by kbuild robot:
> 
> net/netfilter/core.c:75 suspicious rcu_dereference_check() usage!
> 2 locks held by swapper/1:
> #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81c2e567>] rtnl_lock+0x17/0x20
> #1:  (nf_hook_mutex){+.+...}, at: [<ffffffff81c58fcb>] nf_register_net_hook+0xcb/0x240

Aaron, please, send a v2.

I have a patchset that changes the footprint of the hook function as
it was discussed during the last Netfilter Workshop that clashes with
this.

Thanks!
