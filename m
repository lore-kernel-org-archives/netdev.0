From: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Subject: Re: [Resend PATCH] RDS: fix race condition when sending a message on
 unbound socket
Date: Wed, 25 Nov 2015 13:52:00 +0100
Message-ID: <20151125125200.GC15735@chrystal.uk.oracle.com>
References: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBDC0B0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Santosh Shilimkar'" <santosh.shilimkar@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	Quentin Casasnovas <quentin.casasnovas@oracle.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBDC0B0@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 12:21:45PM +0000, David Laight wrote:
> From: Santosh Shilimkar
> > Sent: 24 November 2015 22:13
> ...
> > Sasha's found a NULL pointer dereference in the RDS connection code when
> > sending a message to an apparently unbound socket.  The problem is caused
> > by the code checking if the socket is bound in rds_sendmsg(), which checks
> > the rs_bound_addr field without taking a lock on the socket.  This opens a
> > race where rs_bound_addr is temporarily set but where the transport is not
> > in rds_bind(), leading to a NULL pointer dereference when trying to
> > dereference 'trans' in __rds_conn_create().
> > 
> > Vegard wrote a reproducer for this issue, so kindly ask him to share if
> > you're interested.
> ...
> > diff --git a/net/rds/send.c b/net/rds/send.c
> > index 827155c..c9cdb35 100644
> > --- a/net/rds/send.c
> > +++ b/net/rds/send.c
> > @@ -1013,11 +1013,13 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
> >  		release_sock(sk);
> 
> This is falling though into an unconditional lock_sock().
> No need to unlock and relock immediately.
> 
> >  	}
> > 
> > -	/* racing with another thread binding seems ok here */
> > +	lock_sock(sk);
> >  	if (daddr == 0 || rs->rs_bound_addr == 0) {
> > +		release_sock(sk);
> >  		ret = -ENOTCONN; /* XXX not a great errno */
> >  		goto out;
> >  	}
> > +	release_sock(sk);
> > 
> 
> On the face of it the above looks somewhat dubious.
> Locks usually tie together two action (eg a test and use of a value),
> In this case you only have a test inside the lock.
> That either means that the state can change after you release the lock
> (ie rs->rs_bound_addr = 0 is executed somewhere), or you don't
> really need the lock.
>

If you look at rds_bind(), you'll see that it does something like the
following:

    lock_sock(sk);
    ...
1:  rds_add_bound();  # This sets rs->rs_bound_addr
    ...
    if (!trans) {
            ...
2:          rds_remove_bound(rs);  # This unsets rs->rs_bound_addr
  ...
  release_sock(sk);

So any code checking rs_bound_addr without taking that lock could
potentially think the socket is bound, when in fact rds_bind() has failed.
This can happen if checking rs_bound_addr happens exactly between [1] and
[2] above.  So the usage of the lock in this particular case is to get a
consistent view of the sk.

The only other case where rs_bound_addr is cleared is on socket release, so
I didn't _think_ there was a problem here but maybe you can see another
race?

Thanks,
Quentin
