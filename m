From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net] netfilter: nf_qeueue: Drop queue entries on
 nf_unregister_hook
Date: Sat, 20 Jun 2015 13:32:48 +0200
Message-ID: <20150620113248.GA6915@acer.localdomain>
References: <878ubffron.fsf@x220.int.ebiederm.org>
 <871th7frlg.fsf@x220.int.ebiederm.org>
 <20150620105738.GA3439@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150620105738.GA3439@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.06, Pablo Neira Ayuso wrote:
> On Fri, Jun 19, 2015 at 02:03:39PM -0500, Eric W. Biederman wrote:
> > 
> > Add code to nf_unregister_hook to flush the nf_queue when a hook is
> > unregistered.  This guarantees that the pointer that the nf_queue code
> > retains into the nf_hook list will remain valid while a packet is
> > queued.
> 
> I think the real problem is that struct nf_queue_entry holds a pointer
> to struct nf_hook_ops, which will be gone after removal. So you
> uncovered a long standing problem that will amplify by when pernet
> hooks are in place.
> 
> Regarding the pointer to nf_hook_list, now that new netdevice variant
> doesn't support nf_queue yet, so that nf_hook_list will be always
> valid since it will point to the global nf_hooks in the core.

I think Eric's patch is the right thing to do. I'm not sure I get
your netdev comment, but we certainly do want to drop packets once
a hook is gone.

> > +{
> > +	const struct nf_queue_handler *qh;
> > +	struct net *net;
> > +
> > +	rtnl_lock();
> 
> Why rtnl_lock() here?

for_each_net(). Would actually be nice to have a variant that doesn't
need the rtnl since it makes locking order analysis a lot harder.

> > +	rcu_read_lock();
> > +	qh = rcu_dereference(queue_handler);
> > +	if (qh) {
> > +		for_each_net(net) {
> > +			qh->nf_hook_drop(net, ops);
> > +		}
> > +	}
> > +	rcu_read_unlock();
> > +	rtnl_unlock();
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
