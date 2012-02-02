From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 02 Feb 2012 22:57:08 +0100
Message-ID: <1328219828.2480.32.camel@edumazet-laptop>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38765 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932596Ab2BBV5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 16:57:13 -0500
Received: by werb13 with SMTP id b13so2227398wer.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 13:57:11 -0800 (PST)
In-Reply-To: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 14:36 -0700, Erich E. Hoover a =C3=
=A9crit :
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch =
implements the feature by setting the outgoing interface in a similar f=
ashion to that of IP_PKTINFO.
>=20
> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
> ---
>  include/linux/in.h      |    1 +
>  include/net/inet_sock.h |    2 +
>  include/net/ip.h        |    1 +
>  net/ipv4/af_inet.c      |    2 +
>  net/ipv4/ip_sockglue.c  |   68 +++++++++++++++++++++++++++++++++++++=
++++++++++
>  net/ipv4/ping.c         |    2 +-
>  net/ipv4/raw.c          |    2 +-
>  net/ipv4/udp.c          |    2 +-
>  8 files changed, 77 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/in.h b/include/linux/in.h
> index 01129c0..89f6682 100644
> --- a/include/linux/in.h
> +++ b/include/linux/in.h
> @@ -86,6 +86,7 @@ struct in_addr {
> =20
>  #define IP_MINTTL       21
>  #define IP_NODEFRAG     22
> +#define IP_UNICAST_IF   23
> =20
>  /* IP_MTU_DISCOVER values */
>  #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index e3e4051..ad517f5 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -132,6 +132,7 @@ struct rtable;
>   * @tos - TOS
>   * @mc_ttl - Multicasting TTL
>   * @is_icsk - is this an inet_connection_sock?
> + * @outif_index - Outgoing device index
>   * @mc_index - Multicast device index
>   * @mc_list - Group array
>   * @cork - info to build ip hdr on each ip frag while socket is cork=
ed
> @@ -167,6 +168,7 @@ struct inet_sock {
>  				transparent:1,
>  				mc_all:1,
>  				nodefrag:1;
> +	int			outif_index;
>  	int			mc_index;
>  	__be32			mc_addr;
>  	struct ip_mc_socklist __rcu	*mc_list;
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 775009f..2c1a261 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -452,6 +452,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb=
);
> =20
>  extern void	ipv4_pktinfo_prepare(struct sk_buff *skb);
>  extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
> +extern int	ip_default_ifindex(struct sock *sk);
>  extern int	ip_cmsg_send(struct net *net,
>  			     struct msghdr *msg, struct ipcm_cookie *ipc);
>  extern int	ip_setsockopt(struct sock *sk, int level, int optname, ch=
ar __user *optval, unsigned int optlen);
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index f7b5670..a5855cd 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -375,6 +375,8 @@ lookup_protocol:
>  	sk->sk_protocol	   =3D protocol;
>  	sk->sk_backlog_rcv =3D sk->sk_prot->backlog_rcv;
> =20
> +	inet->outif_index  =3D 0;
> +
>  	inet->uc_ttl	=3D -1;
>  	inet->mc_loop	=3D 1;
>  	inet->mc_ttl	=3D 1;
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 8aa87c1..d7b507d 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -186,6 +186,18 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_=
buff *skb)
>  }
>  EXPORT_SYMBOL(ip_cmsg_recv);
> =20
> +int ip_default_ifindex(struct sock *sk)

const struct sock *sk

> +{
> +	struct inet_sock *inet =3D inet_sk(sk);
> +	int ifindex =3D sk->sk_bound_dev_if;
> +
> +	/* Set the outgoing interface from the value set by IP_UNICAST_IF *=
/
> +	if (inet->outif_index)
> +		ifindex =3D inet->outif_index;
> +
> +	return ifindex;
> +}
> +
>  int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_co=
okie *ipc)
>  {
>  	int err;
> @@ -628,6 +640,48 @@ static int do_ip_setsockopt(struct sock *sk, int=
 level,
>  			goto e_inval;
>  		inet->mc_loop =3D !!val;
>  		break;
> +
> +	case IP_UNICAST_IF:
> +	{
> +		struct net_device *dev =3D NULL;
> +		__be32 iface;
> +		int ifindex;
> +
> +		/*
> +		 *	Check the arguments are allowable
> +		 */
> +
> +		if (optlen !=3D sizeof(__be32))
> +			goto e_inval;
> +
> +		err =3D -EFAULT;
> +		if (copy_from_user(&iface, optval, sizeof(__be32)))
> +			break;
> +
> +		ifindex =3D ntohl(iface);
> +		if (ifindex & ntohl(0xFF)) /* first octet must be zero */


This looks wrong.

Maybe you wanted : if (ifindex & 0xFF000000)=20

> +			goto e_inval;
> +
> +		if (ifindex =3D=3D 0) {
> +			inet->outif_index =3D 0;
> +			err =3D 0;
> +			break;
> +		} else

you can avoid the else (because of the break;)

> +			dev =3D dev_get_by_index(sock_net(sk), ifindex);
> +
> +		err =3D -EADDRNOTAVAIL;
> +		if (!dev)
> +			break;
> +		dev_put(dev);
> +
> +		err =3D -EINVAL;
> +		if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_bound_dev_if)
> +			break;
> +
> +		inet->outif_index =3D ifindex;

what happens if later sk_bound_dev_if is changed ? Should we redo the
above tests ?

> +		err =3D 0;
> +		break;
> +	}
>  	case IP_MULTICAST_IF:
>  	{
>  		struct ip_mreqn mreq;
> @@ -1178,6 +1232,20 @@ static int do_ip_getsockopt(struct sock *sk, i=
nt level, int optname,
>  	case IP_MULTICAST_LOOP:
>  		val =3D inet->mc_loop;
>  		break;
> +	case IP_UNICAST_IF:
> +	{
> +		__be32 iface;
> +
> +		len =3D sizeof(__be32);
> +		iface =3D htonl(inet->outif_index);
> +		release_sock(sk);
> +
> +		if (put_user(len, optlen))
> +			return -EFAULT;
> +		if (copy_to_user(optval, &iface, len))
> +			return -EFAULT;
> +		return 0;

wow.... thats not pretty...

	what about :

	case IP_UNICASE_IF:
		val =3D htonl(inet->outif_index);
		break;

> +	}
>  	case IP_MULTICAST_IF:
>  	{
>  		struct in_addr addr;
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index aea5a19..abeb454 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -510,7 +510,7 @@ static int ping_sendmsg(struct kiocb *iocb, struc=
t sock *sk, struct msghdr *msg,
> =20
>  	ipc.addr =3D inet->inet_saddr;
>  	ipc.opt =3D NULL;
> -	ipc.oif =3D sk->sk_bound_dev_if;
> +	ipc.oif =3D ip_default_ifindex(sk);
>  	ipc.tx_flags =3D 0;
>  	err =3D sock_tx_timestamp(sk, &ipc.tx_flags);
>  	if (err)
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index 3ccda5a..000d9fb 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -515,7 +515,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct=
 sock *sk, struct msghdr *msg,
>  	ipc.addr =3D inet->inet_saddr;
>  	ipc.opt =3D NULL;
>  	ipc.tx_flags =3D 0;
> -	ipc.oif =3D sk->sk_bound_dev_if;
> +	ipc.oif =3D ip_default_ifindex(sk);
> =20
>  	if (msg->msg_controllen) {
>  		err =3D ip_cmsg_send(sock_net(sk), msg, &ipc);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 5d075b5..651eb62 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -869,7 +869,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
>  	}
>  	ipc.addr =3D inet->inet_saddr;
> =20
> -	ipc.oif =3D sk->sk_bound_dev_if;
> +	ipc.oif =3D ip_default_ifindex(sk);
>  	err =3D sock_tx_timestamp(sk, &ipc.tx_flags);
>  	if (err)
>  		return err;


IPv6 not supported ?
