From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net] netfilter: nf_qeueue: Drop queue entries on
 nf_unregister_hook
Date: Sat, 20 Jun 2015 18:35:21 +0200
Message-ID: <20150620163521.GC6915@acer.localdomain>
References: <878ubffron.fsf@x220.int.ebiederm.org>
 <871th7frlg.fsf@x220.int.ebiederm.org>
 <20150620105738.GA3439@salvia>
 <20150620113248.GA6915@acer.localdomain>
 <87616i8nyv.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87616i8nyv.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.06, Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> > On 20.06, Pablo Neira Ayuso wrote:
> >> On Fri, Jun 19, 2015 at 02:03:39PM -0500, Eric W. Biederman wrote:
> >> > 
> >> > Add code to nf_unregister_hook to flush the nf_queue when a hook is
> >> > unregistered.  This guarantees that the pointer that the nf_queue code
> >> > retains into the nf_hook list will remain valid while a packet is
> >> > queued.
> >> 
> >> I think the real problem is that struct nf_queue_entry holds a pointer
> >> to struct nf_hook_ops, which will be gone after removal. So you
> >> uncovered a long standing problem that will amplify by when pernet
> >> hooks are in place.
> >> 
> >> Regarding the pointer to nf_hook_list, now that new netdevice variant
> >> doesn't support nf_queue yet, so that nf_hook_list will be always
> >> valid since it will point to the global nf_hooks in the core.
> >
> > I think Eric's patch is the right thing to do. I'm not sure I get
> > your netdev comment, but we certainly do want to drop packets once
> > a hook is gone.
> >
> >> > +{
> >> > +	const struct nf_queue_handler *qh;
> >> > +	struct net *net;
> >> > +
> >> > +	rtnl_lock();
> >> 
> >> Why rtnl_lock() here?
> >
> > for_each_net(). Would actually be nice to have a variant that doesn't
> > need the rtnl since it makes locking order analysis a lot harder.
> 
> Someone added a for_each_net_rcu.  But right now I am not at all certain
> I trust an rcu variant not to miss something, in a weird corner case.
> When missing something translates to an unprivileged user triggerable
> kernel oops I am not ready to play games.
> 
> As for the lock analysis.  Except for nf_tables nf_unregister_hook is
> called by module removal routines where rtnl_lock() is safe.
> 
> With nftables we seem to do everything under some version of the
> nfnl_lock.  Does the nfnl_lock have any problems with taking the
> rtnl_lock to nest underneath it?

No, its fine, we have almost none interactions except for network
namespaces and device lookups.

Main reason why I'd prefer a non-RTNL version is because your
callbacks introduce bigger chunks of code under the RTNL, so
it might complicate things in the future. But your reasoning is
sound and for now this is perfectly fine.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
