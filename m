From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Tue, 16 Jun 2009 16:36:10 -0400
Message-ID: <200906161636.10522.paul.moore@hp.com>
References: <20090611034022.GC22424@ghostprotocols.net> <200906111409.23246.paul.moore@hp.com> <20090611215341.GF22424@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	" =?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:4086 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbZFPUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 16:36:12 -0400
In-Reply-To: <20090611215341.GF22424@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 June 2009 05:53:42 pm Arnaldo Carvalho de Melo wrote:
> Em Thu, Jun 11, 2009 at 02:09:22PM -0400, Paul Moore escreveu:
> > On Wednesday 10 June 2009 11:40:22 pm Arnaldo Carvalho de Melo wrote:
> > > diff --git a/net/socket.c b/net/socket.c
> > > index 791d71a..f9f1e20 100644
> > > --- a/net/socket.c
> > > +++ b/net/socket.c
> > > @@ -702,6 +702,28 @@ int sock_recvmsg(struct socket *sock, struct
> > > msghdr *msg, return ret;
> > >  }
> > >
> > > +static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
> > > +			      size_t size, int flags)
> > > +{
> > > +	struct kiocb iocb;
> > > +	struct sock_iocb siocb;
> > > +	int ret;
> > > +
> > > +	init_sync_kiocb(&iocb, NULL);
> > > +	iocb.private = &siocb;
> > > +
> > > +	siocb.sock = sock;
> > > +	siocb.scm = NULL;
> > > +	siocb.msg = msg;
> > > +	siocb.size = size;
> > > +	siocb.flags = flags;
> > > +
> > > +	ret = sock->ops->recvmsg(&iocb, sock, msg, size, flags);
> > > +	if (-EIOCBQUEUED == ret)
> > > +		ret = wait_on_sync_kiocb(&iocb);
> > > +	return ret;
> > > +}
> >
> > Hmmm, in an effort to reduce duplicated code how about updating
> > __sock_recvmsg() to something like the following:
> >
> > static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
> >                                  struct msghdr *msg, size_t size, int
> > flags) {
> >         int err;
> >
> >         err = security_socket_recvmsg(...);
> >         if (err)
> >                 return err;
> >
> >         return sock_recvmsg_nosec(...);
> > }
> >
> > The only real difference is that now the *_kiocb() functions get called
> > and I have no clue if that is good or bad but it is different :)
>
> Yeah, gets clearer, like this:
>
> static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket
> *sock, struct msghdr *msg, size_t size, int flags)
> {
> 	struct sock_iocb *si = kiocb_to_siocb(iocb);
>
> 	si->sock = sock;
> 	si->scm = NULL;
> 	si->msg = msg;
> 	si->size = size;
> 	si->flags = flags;
>
> 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
> }
>
> static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
> 				 struct msghdr *msg, size_t size, int flags)
> {
> 	int err = security_socket_recvmsg(sock, msg, size, flags);
>
> 	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
> }
>
> static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
> 			      size_t size, int flags)
> {
> 	struct kiocb iocb;
> 	struct sock_iocb siocb;
> 	int ret;
>
> 	init_sync_kiocb(&iocb, NULL);
> 	iocb.private = &siocb;
> 	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
> 	if (-EIOCBQUEUED == ret)
> 		ret = wait_on_sync_kiocb(&iocb);
> 	return ret;
> }
>
> Better now? :-)

Sorry for the delay, I was away for a few days and just got back to email this 
morning ... but yes, much better now, thanks :)

-- 
paul moore
linux @ hp

