From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net: heap overflow in __audit_sockaddr()
Date: Thu, 3 Oct 2013 00:26:04 +0300
Message-ID: <20131002212603.GQ6247@mwanda>
References: <20131002185811.GA23438@elgon.mountain>
 <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org,
	=?iso-8859-1?Q?J=FCri?= Aedla <juri.aedla@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20512 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab3JBV0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:26:18 -0400
Content-Disposition: inline
In-Reply-To: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 10:11:46PM +0100, Ben Hutchings wrote:
> On Wed, 2013-10-02 at 21:58 +0300, Dan Carpenter wrote:
> > We need to cap ->msg_namelen or it leads to a buffer overflow when =
we
> > to the memcpy() in __audit_sockaddr().  It requires CAP_AUDIT_CONTR=
OL to
> > exploit this bug.
> >=20
> > The call tree is:
> > ___sys_recvmsg()
> >   move_addr_to_user()
> >     audit_sockaddr()
> >       __audit_sockaddr()
> >=20
> > Reported-by: J=FCri Aedla <juri.aedla@gmail.com>
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> >
> > diff --git a/net/socket.c b/net/socket.c
> > index ebed4b6..c226ace 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -1964,6 +1964,16 @@ struct used_address {
> >  	unsigned int name_len;
> >  };
> > =20
> > +static int copy_msghdr_from_user(struct msghdr *kmsg,
> > +				 struct msghdr __user *umsg)
> > +{
> > +	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
> > +		return -EFAULT;
> > +	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> > +		return -EINVAL;
> > +	return 0;
> > +}
> > +
> >  static int ___sys_sendmsg(struct socket *sock, struct msghdr __use=
r *msg,
> >  			 struct msghdr *msg_sys, unsigned int flags,
> >  			 struct used_address *used_address)
> > @@ -1982,8 +1992,11 @@ static int ___sys_sendmsg(struct socket *soc=
k, struct msghdr __user *msg,
> >  	if (MSG_CMSG_COMPAT & flags) {
> >  		if (get_compat_msghdr(msg_sys, msg_compat))
> >  			return -EFAULT;
> > -	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
> > -		return -EFAULT;
> > +	} else {
> > +		err =3D copy_msghdr_from_user(msg_sys, msg);
> > +		if (err)
> > +			return err;
> > +	}
> [...]
>=20
> This doesn't cover compat tasks, since get_compat_msghdr() has no suc=
h
> check.
>=20

Oops.  Gar...  Thanks for catching that.  I forgot to add that chunk to
the commit.

regards,
dan carpenter
