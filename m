From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] net: heap overflow in __audit_sockaddr()
Date: Wed, 2 Oct 2013 22:11:46 +0100
Message-ID: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
References: <20131002185811.GA23438@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<security@kernel.org>,
	=?ISO-8859-1?Q?J=FCri?= Aedla <juri.aedla@gmail.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30489 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3JBVLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:11:50 -0400
In-Reply-To: <20131002185811.GA23438@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 21:58 +0300, Dan Carpenter wrote:
> We need to cap ->msg_namelen or it leads to a buffer overflow when we
> to the memcpy() in __audit_sockaddr().  It requires CAP_AUDIT_CONTROL=
 to
> exploit this bug.
>=20
> The call tree is:
> ___sys_recvmsg()
>   move_addr_to_user()
>     audit_sockaddr()
>       __audit_sockaddr()
>=20
> Reported-by: J=C3=BCri Aedla <juri.aedla@gmail.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/socket.c b/net/socket.c
> index ebed4b6..c226ace 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1964,6 +1964,16 @@ struct used_address {
>  	unsigned int name_len;
>  };
> =20
> +static int copy_msghdr_from_user(struct msghdr *kmsg,
> +				 struct msghdr __user *umsg)
> +{
> +	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
> +		return -EFAULT;
> +	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> +		return -EINVAL;
> +	return 0;
> +}
> +
>  static int ___sys_sendmsg(struct socket *sock, struct msghdr __user =
*msg,
>  			 struct msghdr *msg_sys, unsigned int flags,
>  			 struct used_address *used_address)
> @@ -1982,8 +1992,11 @@ static int ___sys_sendmsg(struct socket *sock,=
 struct msghdr __user *msg,
>  	if (MSG_CMSG_COMPAT & flags) {
>  		if (get_compat_msghdr(msg_sys, msg_compat))
>  			return -EFAULT;
> -	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
> -		return -EFAULT;
> +	} else {
> +		err =3D copy_msghdr_from_user(msg_sys, msg);
> +		if (err)
> +			return err;
> +	}
[...]

This doesn't cover compat tasks, since get_compat_msghdr() has no such
check.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
