From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Fri, 2 Jun 2017 11:53:42 +0200
Message-ID: <20170602095342.GC13569@breakpoint.cc>
References: <20170530093812.10712-1-fw@strlen.de>
 <063D6719AE5E284EB5DD2968C1650D6DD000799C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Florian Westphal' <fw@strlen.de>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:52724 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750910AbdFBJyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 05:54:04 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD000799C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Florian Westphal
> > Sent: 30 May 2017 10:38
> > 
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
> ...
> >  void
> >  nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
> > @@ -1734,6 +1736,13 @@ nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
> >  	}
> >  	rtnl_unlock();
> > 
> > +	/* Need to wait for netns cleanup worker to finish, if its
> > +	 * running -- it might have deleted a net namespace from
> > +	 * the global list, so our __nf_ct_unconfirmed_destroy() might
> > +	 * not have affected all namespaces.
> > +	 */
> > +	net_ns_barrier();
> > +
> 
> A problem I see is that nothing obvious guarantees that the cleanup worker
> has actually started.

If it hasn't even started, the earlier for_each_net() has seen all
net namespaces and we managed to clear helper extensions of all conntracks.

Same in case it has finished already: netns cleanup work queue has
free'd all the affected conntracks we might have missed.

We only are in trouble if netns work queue is running concurrently:
netns cleanup first removes net namespaces from the global list,
so nf_ct_iterate_destroy might have missed these.
