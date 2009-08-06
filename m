From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Fri, 7 Aug 2009 00:39:59 +1000
Message-ID: <20090806143959.GA29323@gondor.apana.org.au>
References: <20090803161242.12947.14620.stgit@flek.lan> <m1ljlyvn9a.fsf@fess.ebiederm.org> <200908051738.43134.paul.moore@hp.com> <20090806101044.GA26589@gondor.apana.org.au> <m1hbwlkzt6.fsf@fess.ebiederm.org> <20090806133746.GA28557@gondor.apana.org.au> <m1ljlxj9vi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42136 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751234AbZHFOkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 10:40:05 -0400
Content-Disposition: inline
In-Reply-To: <m1ljlxj9vi.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 07:27:13AM -0700, Eric W. Biederman wrote:
>
> Summarizing:
> 
> tun = __tun_get(tfile);
> if (!tun) { // No tun we are not attached.
> 	 < -------------------- race opportunity
> 	rtnl_lock();
>         tun_set_iff();
>         rtnl_unlock();
> }
> ...
> 
> We don't test if we are attached under the rtnl
> until we get to tun_attach();
> 
> So two threads can both do:
> 
> tun = __tun_get(tfile);
> if (!tun) {
> 	rtnl_lock();
>         tun_set_iff();
>             dev = __dev_get_by_name(net, "not_an_interface_name");
>             if (!dev) {
>                dev = alloc_netdev(....);
>                ...;
>                register_netdev(dev);
>                ...;
>                err = tun_attach(..);
>             }
> 
> 
> Only one thread is in tun_set_iff() at a time, but the other thread
> could have attached the file to a device before the one in tun_attach().

Right, I see what you mean.  However I don't think this is possible
because the ioctl runs under the big kernel lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
