From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 6 Aug 2009 14:09:19 -0400
Message-ID: <200908061409.19924.paul.moore@hp.com>
References: <20090803161242.12947.14620.stgit@flek.lan> <20090806143959.GA29323@gondor.apana.org.au> <m1zladhtoh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:15123 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbZHFSJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 14:09:21 -0400
In-Reply-To: <m1zladhtoh.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 August 2009 11:02:22 am Eric W. Biederman wrote:
> Herbert Xu <herbert@gondor.apana.org.au> writes:
> > On Thu, Aug 06, 2009 at 07:27:13AM -0700, Eric W. Biederman wrote:
> >> Summarizing:
> >>
> >> tun = __tun_get(tfile);
> >> if (!tun) { // No tun we are not attached.
> >> 	 < -------------------- race opportunity
> >> 	rtnl_lock();
> >>         tun_set_iff();
> >>         rtnl_unlock();
> >> }
> >> ...
> >>
> >> We don't test if we are attached under the rtnl
> >> until we get to tun_attach();
> >>
> >> So two threads can both do:
> >>
> >> tun = __tun_get(tfile);
> >> if (!tun) {
> >> 	rtnl_lock();
> >>         tun_set_iff();
> >>             dev = __dev_get_by_name(net, "not_an_interface_name");
> >>             if (!dev) {
> >>                dev = alloc_netdev(....);
> >>                ...;
> >>                register_netdev(dev);
> >>                ...;
> >>                err = tun_attach(..);
> >>             }
> >>
> >>
> >> Only one thread is in tun_set_iff() at a time, but the other thread
> >> could have attached the file to a device before the one in tun_attach().
> >
> > Right, I see what you mean.  However I don't think this is possible
> > because the ioctl runs under the big kernel lock.
>
> Why not?  We can sleep on that code path.
> Although now that you mention it we should use unlocked_ioctl unless
> we actually need the BKL.

Dave, if you haven't already, it is probably a good idea to just forget about 
this patch.  Prior to this discussion I suspected that the TUN driver could 
use a closer look, after reading the comments from Eric and Herbert there 
isn't much suspicion left.  I'll put this on my rainy day todo list to try and 
tackle but I won't be upset if somebody beats me to it.

-- 
paul moore
linux @ hp

