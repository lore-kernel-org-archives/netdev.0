From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Wed, 5 Aug 2009 17:38:42 -0400
Message-ID: <200908051738.43134.paul.moore@hp.com>
References: <20090803161242.12947.14620.stgit@flek.lan> <m1ljlyvn9a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:47710 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbZHEViv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 17:38:51 -0400
In-Reply-To: <m1ljlyvn9a.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 August 2009 01:32:49 am Eric W. Biederman wrote:
> Paul Moore <paul.moore@hp.com> writes:
> > Convert some pointless gotos into returns and ensure tun_attach() errors
> > are handled correctly.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> This patch appears slightly wrong.  Comments inline.

Thanks for taking a look ...

> > I'm sending this as an RFC patch because I'm not entirely certain that
> > the changes to the tun_attach() error handling code are 100% correct,
> > although I strongly suspect that the current behavor of simply returning
> > an error code without any cleanup is broken.  Can anyone comment on this?
> > ---
> >
> >  drivers/net/tun.c |   19 ++++++++++---------
> >  1 files changed, 10 insertions(+), 9 deletions(-)
> >
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 4a0db7a..b6d06fd 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -976,10 +973,11 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr) tun->flags = flags;
> >  		tun->txflt.count = 0;
> >
> > -		err = -ENOMEM;
> >  		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
> > -		if (!sk)
> > +		if (!sk) {
> > +			err = -ENOMEM;
> >  			goto err_free_dev;
> > +		}
>
> Trivially correct but I would argue uglier.

My reasoning behind the change was that code related to the error handling 
should be moved outside the common path as much as possible similar to what we 
do now with the gotos.

> > @@ -1010,7 +1008,7 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr)
> >
> >  		err = tun_attach(tun, file);
> >  		if (err < 0)
> > -			goto failed;
> > +			goto err_unreg_dev;
> >  	}
>
> This is the interesting one.  And several problems with it.  When
> Herbert reworked the reference counting here he introduced the goto
> failed; Instead of err_free_dev.
>
> I think there were more possible races when I introduced the check
> of the return code of tun_attach, the only case I can see currently
> is if the file was attached to another tun device before we grabbed the
> rtnl_lock.

...

> > @@ -1039,11 +1037,14 @@ static int tun_set_iff(struct net *net, struct
> > file *file, struct ifreq *ifr) strcpy(ifr->ifr_name, tun->dev->name);
> >  	return 0;
> >
> > + err_unreg_dev:
> > +	rtnl_lock();
> > +	unregister_netdevice(tun->dev);
> > +	rtnl_unlock();
>
> This is a guaranteed deadlock.  We already hold the rtnl_lock here.
> Furthermore all I should need to do in this case is to call
> unregister_netdevice(...).    As all of the rest of the pieces should
> happen in the cleanup routines called from unregister_netdevice.

Okay, so at the very least the rtnl_[un]lock() calls need to be removed and we 
can safely return after calling unregister_netdevice() without having to 
free/release anything else.  The thing that concerns me the most are the 
potential races you talked about.

I'll admit there are many dark places here that I still don't understand but 
looking at the code it appears that the only way to get into tun_set_iff() is 
if the file is not currently attached to a TUN device which is further checked 
in tun_attach().  Also, I'm not sure what refcounting you are talking about - 
do you mean the tun_file->count refcount?  I think we should be okay in this 
regard as the only way we would end up changing tun_file->count is if 
tun_attach() completed successfully; if tun_attach() fails there is not change 
in the refcount.  I could be way off here but it _seems_ safe ... :)

> The current behavior of returning an error code is a little bit off
> as it creates a persistent tun device without setting tun->flags |
> TUN_PERSIST. And it leaves a tun device for someone else to clean up.
>
> At the same time it should be perfectly legitimate for someone else to
> come along and attach to the tun device and delete it or to call
> ip link del <tun>

My concern is that I believe that if the kernel fails at an operation it 
should do all it can to unwind any actions it took in the course of attempting 
to perform the requested operation.  Leaving a TUN device around in the case 
of a tun_attach() failure seems like the kernel is being lazy, sure a user can 
cleanup the device but why should they have to?

-- 
paul moore
linux @ hp

