From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RESEND nf] netfilter: avoid a race between
 nf_register_hook() and cleanup_net()
Date: Fri, 26 Aug 2016 19:31:04 +0200
Message-ID: <20160826173104.GA25040@salvia>
References: <20160729150033.E0250A0BD9@unicorn.suse.cz>
 <20160729161904.4F00BA0BD9@unicorn.suse.cz>
 <87shurb6ne.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87shurb6ne.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Sat, Jul 30, 2016 at 08:24:37AM -0500, Eric W. Biederman wrote:
> Michal Kubecek <mkubecek@suse.cz> writes:
> 
> > There is a race condition between nf_{,un}register_hook() and
> > cleanup_net() which can either trigger WARN check or cause a memory
> > leak. The scenario is like this (2a and 2b are alternatives):
> >
> > 1.  cleanup_net() removes one or more struct net from net_namespace_list
> > 2a. nf_register_hook() adds per-netns hooks to all netns (but not those
> >     removed in step 1) and adds the hook to global nf_hook_list
> > 2b. nf_unregister_hook() deletes per-netns hooks from all netns (but not
> >     those removed in step 1) and removes the hook from nf_hook_list
> > 3.  cleanup_net() calls pernet subsystem exit functions for netns being
> >     removed; one of them is netfilter_net_exit() which (among others)
> >     calls nf_unregister_net_hook() to unregister per-netns hooks for all
> >     hooks in nf_hook_list.
> >
> > In case (a), per-netns hooks are never added as the namespace was
> > already invisible to for_each_net() in step 2a but an attempt to remove
> > them in step 3 (the hook is already in nf_hook_list) triggers a WARN
> > check in nf_unregister_net_hook() (no real harm done, however). In case
> > (b), the per-netns hook is removed neither in step 2b (netns is already
> > invisible to for_each_net()) nor in step 3 (the hook is already removed
> > from nf_hook_list), causing a memory leak.
> >
> > Prevent the race by protecting the for_each_net() loop in
> > nf_{,un}register_hook() (also) by net_mutex. There is already a
> > precendens for this in rtnl_link_unregister() which addresses similar
> > race.
> 
> So this analysis of a problem appears to be spot on.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> I really really want there to be a better way to do this, but it is
> really not ok for a hook to continue it's life past
> nf_unregister_net_hook as after that point the code may be removed
> from the kernel (sigh).
> 
> Although keeping with the precedent and minimizing net_mutex
> we could remove the WARN and keep nf_register_hook as it is.
> But that sounds entirely too clever for a fix that will
> probably be backported.
> 
> But that sounds entirely too clever for a fix that likely needs to be
> backported.

OK... I'm going to place this in the nf.git tree... but this is very ugly.

So Eric, I'd really appreciate if you can follow up once this has hit
nf-next.git and we get rid of the rtnl_lock and net_lock mutex by
propagating up to the the caller the hook registration from init_net()
and unregistering this from exit_net(). So we don't need to loop on
the existing netns but we use the existing netns init and exit
callbacks.

Let me know, thanks.
