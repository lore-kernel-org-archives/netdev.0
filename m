From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH RESEND 1/2] in-kernel sockets API
Date: Mon, 07 Aug 2006 17:46:27 -0700
Message-ID: <1154997987.11916.32.camel@w-sridhar2.beaverton.ibm.com>
References: <1154991629.11916.5.camel@w-sridhar2.beaverton.ibm.com>
	 <20060807162033.3685924e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40423 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932199AbWHHAv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 20:51:29 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k780pSCg015228
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:51:28 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k780pS0P257158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:51:28 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k780pRFe005320
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:51:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060807162033.3685924e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-07 at 16:20 -0700, Stephen Hemminger wrote:
> On Mon, 07 Aug 2006 16:00:29 -0700
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> > Dave,
> > 
> > Could you consider this for inclusion into 2.6.19 tree?
> > 
> > Thanks
> > Sridhar
> > 
> > This patch implements wrapper functions that provide a convenient way to
> > access the sockets API for in-kernel users like sunrpc, cifs & ocfs2 etc
> > and any future users.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > Acked-by: James Morris <jmorris@namei.org>
> > 
> > ---
> > 
> >  include/linux/net.h |   19 +++++++++
> >  net/socket.c        |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 132 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/net.h b/include/linux/net.h
> > index b20c53c..19da2c0 100644
> > --- a/include/linux/net.h
> > +++ b/include/linux/net.h
> > @@ -208,6 +208,25 @@ extern int   	     kernel_recvmsg(struct
> >  				    struct kvec *vec, size_t num,
> >  				    size_t len, int flags);
> >  
> > +extern int kernel_bind(struct socket *sock, struct sockaddr *addr,
> > +		       int addrlen);
> > +extern int kernel_listen(struct socket *sock, int backlog);
> > +extern int kernel_accept(struct socket *sock, struct socket **newsock,
> > +			 int flags);
> > +extern int kernel_connect(struct socket *sock, struct sockaddr *addr,
> > +			  int addrlen, int flags);
> > +extern int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
> > +			      int *addrlen);
> > +extern int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
> > +			      int *addrlen);
> > +extern int kernel_getsockopt(struct socket *sock, int level, int optname,
> > +			     char *optval, int *optlen);
> > +extern int kernel_setsockopt(struct socket *sock, int level, int optname,
> > +			     char *optval, int optlen);
> > +extern int kernel_sendpage(struct socket *sock, struct page *page, int offset,
> > +			   size_t size, int flags);
> > +extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
> > +
> >  #ifndef CONFIG_SMP
> >  #define SOCKOPS_WRAPPED(name) name
> >  #define SOCKOPS_WRAP(name, fam)
> > diff --git a/net/socket.c b/net/socket.c
> > index b4848ce..0c9d01d 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -2160,6 +2160,109 @@ static long compat_sock_ioctl(struct fil
> >  }
> >  #endif
> >  
> > +int kernel_bind(struct socket *sock, struct sockaddr *addr, int addrlen)
> > +{
> > +	return sock->ops->bind(sock, addr, addrlen);
> > +}
> > +
> > +int kernel_listen(struct socket *sock, int backlog)
> > +{
> > +	return sock->ops->listen(sock, backlog);
> > +}
> > +
> > +int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
> > +{
> > +	struct sock *sk = sock->sk;
> > +	int err;
> > +
> > +	err = sock_create_lite(sk->sk_family, sk->sk_type, sk->sk_protocol,
> > +			       newsock);
> > +	if (err < 0)
> > +		goto done;
> > +
> > +	err = sock->ops->accept(sock, *newsock, flags);
> > +	if (err < 0) {
> > +		sock_release(*newsock);
> > +		goto done;
> > +	}
> > +
> > +	(*newsock)->ops = sock->ops;
> > +
> > +done:
> > +	return err;
> > +}
> > +
> > +int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
> > +                   int flags)
> > +{
> > +	return sock->ops->connect(sock, addr, addrlen, flags);
> > +}
> > +
> > +int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
> > +			 int *addrlen)
> > +{
> > +	return sock->ops->getname(sock, addr, addrlen, 0);
> > +}
> > +
> > +int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
> > +			 int *addrlen)
> > +{
> > +	return sock->ops->getname(sock, addr, addrlen, 1);
> > +}
> > +
> > +int kernel_getsockopt(struct socket *sock, int level, int optname,
> > +			char *optval, int *optlen)
> > +{
> > +	mm_segment_t oldfs = get_fs();
> > +	int err;
> > +
> > +	set_fs(KERNEL_DS);
> > +	if (level == SOL_SOCKET)
> > +		err = sock_getsockopt(sock, level, optname, optval, optlen);
> > +	else
> > +		err = sock->ops->getsockopt(sock, level, optname, optval,
> > +					    optlen);
> > +	set_fs(oldfs);
> > +	return err;
> > +}
> > +
> > +int kernel_setsockopt(struct socket *sock, int level, int optname,
> > +			char *optval, int optlen)
> > +{
> > +	mm_segment_t oldfs = get_fs();
> > +	int err;
> > +
> > +	set_fs(KERNEL_DS);
> > +	if (level == SOL_SOCKET)
> > +		err = sock_setsockopt(sock, level, optname, optval, optlen);
> > +	else
> > +		err = sock->ops->setsockopt(sock, level, optname, optval,
> > +					    optlen);
> > +	set_fs(oldfs);
> > +	return err;
> > +}
> > +
> > +int kernel_sendpage(struct socket *sock, struct page *page, int offset,
> > +		    size_t size, int flags)
> > +{
> > +	if (sock->ops->sendpage)
> > +		return sock->ops->sendpage(sock, page, offset, size, flags);
> > +
> > +	return sock_no_sendpage(sock, page, offset, size, flags);
> > +}
> > +
> > +int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
> > +{
> > +	mm_segment_t oldfs = get_fs();
> > +	int err;
> > +
> > +	set_fs(KERNEL_DS);
> > +	err = sock->ops->ioctl(sock, cmd, arg);
> > +	set_fs(oldfs);
> > +
> > +	return err;
> > +}
> > +
> >  /* ABI emulation layers need these two */
> >  EXPORT_SYMBOL(move_addr_to_kernel);
> >  EXPORT_SYMBOL(move_addr_to_user);
> > @@ -2176,3 +2279,13 @@ EXPORT_SYMBOL(sock_wake_async);
> >  EXPORT_SYMBOL(sockfd_lookup);
> >  EXPORT_SYMBOL(kernel_sendmsg);
> >  EXPORT_SYMBOL(kernel_recvmsg);
> > +EXPORT_SYMBOL(kernel_bind);
> > +EXPORT_SYMBOL(kernel_listen);
> > +EXPORT_SYMBOL(kernel_accept);
> > +EXPORT_SYMBOL(kernel_connect);
> > +EXPORT_SYMBOL(kernel_getsockname);
> > +EXPORT_SYMBOL(kernel_getpeername);
> > +EXPORT_SYMBOL(kernel_getsockopt);
> > +EXPORT_SYMBOL(kernel_setsockopt);
> > +EXPORT_SYMBOL(kernel_sendpage);
> > +EXPORT_SYMBOL(kernel_sock_ioctl);
> 
> Please consider EXPORT_SYMBOL_GPL because this interface would be a obvious
> target for binary modules writers to use.

I used EXPORT_SYMBOL() just to be consistent with the existing kernel_sendmsg()
and kernel_recvmsg(). I am OK with changing them to EXPORT_SYMBOL_GPL().

Dave, I will send an updated version if you are OK with it.

Thanks
Sridhar

