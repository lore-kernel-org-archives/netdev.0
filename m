From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 6 Aug 2009 14:20:20 -0400
Message-ID: <200908061420.20983.paul.moore@hp.com>
References: <20090803161242.12947.14620.stgit@flek.lan> <200908051738.43134.paul.moore@hp.com> <m1ws5hua4h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:48849 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbZHFSU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 14:20:27 -0400
In-Reply-To: <m1ws5hua4h.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 August 2009 07:14:06 pm Eric W. Biederman wrote:
> Paul Moore <paul.moore@hp.com> writes:
> > On Wednesday 05 August 2009 01:32:49 am Eric W. Biederman wrote:
> >> Paul Moore <paul.moore@hp.com> writes:
> >> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >> > index 4a0db7a..b6d06fd 100644
> >> > --- a/drivers/net/tun.c
> >> > +++ b/drivers/net/tun.c
> >> > @@ -976,10 +973,11 @@ static int tun_set_iff(struct net *net, struct
> >> > file *file, struct ifreq *ifr) tun->flags = flags;
> >> >  		tun->txflt.count = 0;
> >> >
> >> > -		err = -ENOMEM;
> >> >  		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
> >> > -		if (!sk)
> >> > +		if (!sk) {
> >> > +			err = -ENOMEM;
> >> >  			goto err_free_dev;
> >> > +		}
> >>
> >> Trivially correct but I would argue uglier.
> >
> > My reasoning behind the change was that code related to the error
> > handling should be moved outside the common path as much as possible
> > similar to what we do now with the gotos.
>
> I don't understand.  Generating less readable and less efficient code is
> preferable?

While we can probably debate the "readability" of code all day long and get no 
where (anyone care to argue about the color of the bikeshed?) the concept of 
code efficiency should be a bit easier to quantify.  I'll admit that I'm far 
from a performance expert but here is my reasoning ...

The code currently looks something like this:

	err = -ENOMEM;
	buf = alloc(...);
	if (!buf)
		goto label;

This means that in the common case where 'alloc()' completes without error we 
are doing an extra, unnecessary assignment where we set the value in 'err'.  
Now, if we change this slightly to match what I proposed in the patch:

	buf = alloc(...);
	if (!buf) {
		err = -ENOMEM;
		goto label;
	}

We eliminate that extra assignment in the case where 'alloc()' completes 
without error, which should result in more efficient code (less instructions 
in the common case).  Am I wrong?  If that is the case I would appreciate an 
explanation ...

-- 
paul moore
linux @ hp

