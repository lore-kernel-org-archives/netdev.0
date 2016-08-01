From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RESEND nf] netfilter: avoid a race between
 nf_register_hook() and cleanup_net()
Date: Mon, 1 Aug 2016 14:34:35 +0200
Message-ID: <20160801123435.GA14107@salvia>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55279 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753452AbcHAMqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 08:46:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 2BAAF1683AB
	for <netdev@vger.kernel.org>; Mon,  1 Aug 2016 14:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1BCE310079D
	for <netdev@vger.kernel.org>; Mon,  1 Aug 2016 14:34:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id CBF8CFC61C
	for <netdev@vger.kernel.org>; Mon,  1 Aug 2016 14:34:36 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <87shurb6ne.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Please, propagate up to the caller to register and unregister the
hooks from init_net and exit_net instead as I suggested time ago.

I understand that this is not as small as this patch, and that this
will require a bit more boiler plate code in iptable_*.c and nftables
itself, but we'll avoid the dependencies with both rtnl_lock and
net_lock.

Thanks.
