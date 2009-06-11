From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Thu, 11 Jun 2009 18:53:42 -0300
Message-ID: <20090611215341.GF22424@ghostprotocols.net>
References: <20090611034022.GC22424@ghostprotocols.net> <200906111409.23246.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42156 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbZFKVyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:54:12 -0400
Content-Disposition: inline
In-Reply-To: <200906111409.23246.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jun 11, 2009 at 02:09:22PM -0400, Paul Moore escreveu:
> On Wednesday 10 June 2009 11:40:22 pm Arnaldo Carvalho de Melo wrote:
> > diff --git a/net/socket.c b/net/socket.c
> > index 791d71a..f9f1e20 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -702,6 +702,28 @@ int sock_recvmsg(struct socket *sock, struct msghdr
> > *msg, return ret;
> >  }
> >
> > +static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
> > +			      size_t size, int flags)
> > +{
> > +	struct kiocb iocb;
> > +	struct sock_iocb siocb;
> > +	int ret;
> > +
> > +	init_sync_kiocb(&iocb, NULL);
> > +	iocb.private = &siocb;
> > +
> > +	siocb.sock = sock;
> > +	siocb.scm = NULL;
> > +	siocb.msg = msg;
> > +	siocb.size = size;
> > +	siocb.flags = flags;
> > +
> > +	ret = sock->ops->recvmsg(&iocb, sock, msg, size, flags);
> > +	if (-EIOCBQUEUED == ret)
> > +		ret = wait_on_sync_kiocb(&iocb);
> > +	return ret;
> > +}
> 
> Hmmm, in an effort to reduce duplicated code how about updating 
> __sock_recvmsg() to something like the following:
> 
> static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
>                                  struct msghdr *msg, size_t size, int flags)
> {
>         int err;
> 
>         err = security_socket_recvmsg(...);
>         if (err)
>                 return err;
> 
>         return sock_recvmsg_nosec(...);
> }
> 
> The only real difference is that now the *_kiocb() functions get called and I 
> have no clue if that is good or bad but it is different :)

Yeah, gets clearer, like this:

static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
				       struct msghdr *msg, size_t size, int flags)
{
	struct sock_iocb *si = kiocb_to_siocb(iocb);

	si->sock = sock;
	si->scm = NULL;
	si->msg = msg;
	si->size = size;
	si->flags = flags;

	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
}

static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
				 struct msghdr *msg, size_t size, int flags)
{
	int err = security_socket_recvmsg(sock, msg, size, flags);

	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
}

static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
			      size_t size, int flags)
{
	struct kiocb iocb;
	struct sock_iocb siocb;
	int ret;

	init_sync_kiocb(&iocb, NULL);
	iocb.private = &siocb;
	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
	if (-EIOCBQUEUED == ret)
		ret = wait_on_sync_kiocb(&iocb);
	return ret;
}

Better now? :-)

> >  	/*
> > @@ -2018,46 +2029,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr
> > __user *, msg, *      kernel msghdr to use the kernel address space)
> >  	 */
> >
> > -	uaddr = (__force void __user *)msg_sys.msg_name;
> > +	uaddr = (__force void __user *)msg_sys->msg_name;
> >  	uaddr_len = COMPAT_NAMELEN(msg);
> >  	if (MSG_CMSG_COMPAT & flags) {
> > -		err = verify_compat_iovec(&msg_sys, iov,
> > +		err = verify_compat_iovec(msg_sys, iov,
> >  					  (struct sockaddr *)&addr,
> >  					  VERIFY_WRITE);
> >  	} else
> > -		err = verify_iovec(&msg_sys, iov,
> > +		err = verify_iovec(msg_sys, iov,
> >  				   (struct sockaddr *)&addr,
> >  				   VERIFY_WRITE);
> >  	if (err < 0)
> >  		goto out_freeiov;
> >  	total_len = err;
> >
> > -	cmsg_ptr = (unsigned long)msg_sys.msg_control;
> > -	msg_sys.msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
> > +	cmsg_ptr = (unsigned long)msg_sys->msg_control;
> > +	msg_sys->msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
> >
> >  	if (sock->file->f_flags & O_NONBLOCK)
> >  		flags |= MSG_DONTWAIT;
> > -	err = sock_recvmsg(sock, &msg_sys, total_len, flags);
> > +	err = (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
> > +							  total_len, flags);
> 
> Perhaps I'm just being nit-picky here but why not this (it is much easier on 
> my eyes at least <g>):
> 
> 	if (nosec)
> 		err = sock_recvmsg_nosec(...);
> 	else
> 		err = sock_recvmsg(...);

Well, its like "if (foo)" versus "if (foo != NULL)", I prefer to reduce
the number of source code lines and stress that the parameter list is
the same, anybody else feels confused by this?

- Arnaldo
