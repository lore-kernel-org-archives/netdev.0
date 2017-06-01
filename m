From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Thu, 1 Jun 2017 10:52:59 +0200
Message-ID: <20170601085259.GA6067@breakpoint.cc>
References: <20170530093812.10712-1-fw@strlen.de>
 <87y3tcj3n7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46660 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751083AbdFAIxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 04:53:19 -0400
Content-Disposition: inline
In-Reply-To: <87y3tcj3n7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Florian Westphal <fw@strlen.de> writes:
> 
> > Quoting Joe Stringer:
> >   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
> >   namespace, destroys that namespace then unloads the FTP helper module,
> >   then the kernel will crash.
> >
> > Events that lead to the crash:
> > 1. conntrack is created with ftp helper in netns x
> > 2. This netns is destroyed
> > 3. netns destruction is scheduled
> > 4. netns destruction wq starts, removes netns from global list
> > 5. ftp helper is unloaded, which resets all helpers of the conntracks
> > via for_each_net()
> >
> > but because netns is already gone from list the for_each_net() loop
> > doesn't include it, therefore all of these conntracks are unaffected.
> >
> > 6. helper module unload finishes
> > 7. netns wq invokes destructor for rmmod'ed helper
> >
> > CC: "Eric W. Biederman" <ebiederm@xmission.com>
> > Reported-by: Joe Stringer <joe@ovn.org>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Eric, I'd like an explicit (n)ack from you for this one.
> 
> This doesn't look too scary but I have the impression we have addressed
> this elsewhere with a different solution.
> 
> Looking...
> 
> Ok.  unregister_pernet_operations takes the net_mutex and thus
> gives you this barrier automatically.
> 
> Hmm.  Why isn't this working for conntrack, looking...
> 
> nf_conntrack_ftp doesn't use unregister_pernet_operations...
> nf_conntract_ftp does use nf_conntrack_helpers_unregister
> 
> I think I almost see the problem.
> 
> What is the per net code that stops dealing with the nf_conntract_ftp?
> 
> I am trying to figure out if your netns_barrier is reasonable or if
> it treating the symptom.  I am having trouble seeing enough of what
> conntrack is doing to judge.
> 
> Am I correct in understanding that the root problem is there is
> something pointing to ftp_exp_policy at the time of module unload?

Joe described it nicely, problem is that after unload we may have
conntracks that still have a nf_conn_help extension attached that
has a pointer to a structure that resided in the (unloaded) module.

Normally these references should have been NULL'd out by
nf_ct_iterate_destroy(), however, there is a small chance that
its for_each_net() misses namespaces already removed-from-list by
concurrent netns workqueue cleanup.

I guess another solution to fix this would be to add dummy pernet
ops to all conntrack helpers so they block on unregister_pernet_subsys().

But thats rather ugly IMO since they don't have any notion of a net
namespace in first place.
