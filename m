From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 11/12] l2tp: Add support for static unmanaged L2TPv3
 tunnels
Date: Mon, 29 Mar 2010 12:40:31 +0200
Message-ID: <1269859231.2164.16.camel@edumazet-laptop>
References: <20100329095639.30460.30496.stgit@bert.katalix.com>
	 <20100329095737.30460.74520.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:51848 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab0C2Kkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 06:40:37 -0400
Received: by bwz1 with SMTP id 1so3433287bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 03:40:35 -0700 (PDT)
In-Reply-To: <20100329095737.30460.74520.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 10:57 +0100, James Chapman a =C3=A9crit :
> This patch adds support for static (unmanaged) L2TPv3 tunnels, where
> the tunnel socket is created by the kernel rather than being created
> by userspace. This means L2TP tunnels and sessions can be created
> manually, without needing an L2TP control protocol implemented in
> userspace. This might be useful where the user wants a simple etherne=
t
> over IP tunnel.
>=20
> A patch to iproute2 adds a new command set under "ip l2tp" to make us=
e
> of this feature. This will be submitted separately.
>=20
> Signed-off-by: James Chapman <jchapman@katalix.com>
> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  net/l2tp/l2tp_core.c    |  111 +++++++++++++++++++++++++++++++++++++=
++++++----
>  net/l2tp/l2tp_core.h    |    7 +++
>  net/l2tp/l2tp_netlink.c |   18 ++++++--
>  3 files changed, 122 insertions(+), 14 deletions(-)
>=20
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index c08c859..1431b39 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1259,6 +1259,78 @@ void l2tp_tunnel_free(struct l2tp_tunnel *tunn=
el)
>  }
>  EXPORT_SYMBOL_GPL(l2tp_tunnel_free);
> =20
> +/* Create a socket for the tunnel, if one isn't set up by
> + * userspace. This is used for static tunnels where there is no
> + * managing L2TP daemon.
> + */
> +static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id=
, struct l2tp_tunnel_cfg *cfg, struct socket **sockp)
> +{
> +	int err =3D -EINVAL;
> +	struct sockaddr_in udp_addr;
> +	struct sockaddr_l2tpip ip_addr;
> +	struct socket *sock;
> +
> +	switch (cfg->encap) {
> +	case L2TP_ENCAPTYPE_UDP:
> +		err =3D sock_create(AF_INET, SOCK_DGRAM, 0, sockp);
> +		if (err < 0)
> +			goto out;
> +
> +		sock =3D *sockp;
> +
> +		memset(&udp_addr, 0, sizeof(udp_addr));
> +		udp_addr.sin_family =3D AF_INET;
> +		udp_addr.sin_addr =3D cfg->local_ip;
> +		udp_addr.sin_port =3D htons(cfg->local_udp_port);
> +		err =3D kernel_bind(sock, (struct sockaddr *) &udp_addr, sizeof(ud=
p_addr));
> +		if (err < 0)
> +			goto out;
> +

I cant see how you use cfg->use_udp_checksums, something like : ?

	if (!cfg->use_udp_checksums)
		sk->sk_no_check =3D UDP_CSUM_NOXMIT;

> +		udp_addr.sin_family =3D AF_INET;
> +		udp_addr.sin_addr =3D cfg->peer_ip;
> +		udp_addr.sin_port =3D htons(cfg->peer_udp_port);
> +		err =3D kernel_connect(sock, (struct sockaddr *) &udp_addr, sizeof=
(udp_addr), 0);
> +		if (err < 0)
> +			goto out;
> +
> +		break;
> +	case L2TP_ENCAPTYPE_IP:
> +		err =3D sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP, sockp);
> +		if (err < 0)
> +			goto out;
> +
> +		sock =3D *sockp;
> +
> +		memset(&ip_addr, 0, sizeof(ip_addr));
> +		ip_addr.l2tp_family =3D AF_INET;
> +		ip_addr.l2tp_addr =3D cfg->local_ip;
> +		ip_addr.l2tp_conn_id =3D tunnel_id;
> +		err =3D kernel_bind(sock, (struct sockaddr *) &ip_addr, sizeof(ip_=
addr));
> +		if (err < 0)
> +			goto out;
> +
> +		ip_addr.l2tp_family =3D AF_INET;
> +		ip_addr.l2tp_addr =3D cfg->peer_ip;
> +		ip_addr.l2tp_conn_id =3D peer_tunnel_id;
> +		err =3D kernel_connect(sock, (struct sockaddr *) &ip_addr, sizeof(=
ip_addr), 0);
> +		if (err < 0)
> +			goto out;
> +
> +		break;
> +
> +	default:
> +		goto out;
> +	}
> +
> +out:
> +	if ((err < 0) && sock) {
> +		sock_release(sock);
> +		*sockp =3D NULL;
> +	}
> +
> +	return err;
> +}
> +
>  int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tun=
nel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct l2tp_tu=
nnel **tunnelp)
>  {
>  	struct l2tp_tunnel *tunnel =3D NULL;
> @@ -1269,14 +1341,21 @@ int l2tp_tunnel_create(struct net *net, int f=
d, int version, u32 tunnel_id, u32
>  	enum l2tp_encap_type encap =3D L2TP_ENCAPTYPE_UDP;
> =20
>  	/* Get the tunnel socket from the fd, which was opened by
> -	 * the userspace L2TP daemon.
> +	 * the userspace L2TP daemon. If not specified, create a
> +	 * kernel socket.
>  	 */
> -	err =3D -EBADF;
> -	sock =3D sockfd_lookup(fd, &err);
> -	if (!sock) {
> -		printk(KERN_ERR "tunl %hu: sockfd_lookup(fd=3D%d) returned %d\n",
> -		       tunnel_id, fd, err);
> -		goto err;
> +	if (fd < 0) {
> +		err =3D l2tp_tunnel_sock_create(tunnel_id, peer_tunnel_id, cfg, &s=
ock);
> +		if (err < 0)
> +			goto err;
> +	} else {
> +		err =3D -EBADF;
> +		sock =3D sockfd_lookup(fd, &err);
> +		if (!sock) {
> +			printk(KERN_ERR "tunl %hu: sockfd_lookup(fd=3D%d) returned %d\n",
> +			       tunnel_id, fd, err);
> +			goto err;
> +		}
>  	}
> =20
>  	sk =3D sock->sk;
> @@ -1369,7 +1448,10 @@ err:
>  	if (tunnelp)
>  		*tunnelp =3D tunnel;
> =20
> -	if (sock)
> +	/* If tunnel's socket was created by the kernel, it doesn't
> +	 *  have a file.
> +	 */
> +	if (sock && sock->file)
>  		sockfd_put(sock);
> =20
>  	return err;
> @@ -1381,13 +1463,22 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
>  int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
>  {
>  	int err =3D 0;
> +	struct socket *sock =3D tunnel->sock ? tunnel->sock->sk_socket : NU=
LL;
> =20
>  	/* Force the tunnel socket to close. This will eventually
>  	 * cause the tunnel to be deleted via the normal socket close
>  	 * mechanisms when userspace closes the tunnel socket.
>  	 */
> -	if ((tunnel->sock !=3D NULL) && (tunnel->sock->sk_socket !=3D NULL)=
)
> -		err =3D inet_shutdown(tunnel->sock->sk_socket, 2);
> +	if (sock !=3D NULL) {
> +		err =3D inet_shutdown(sock, 2);
> +
> +		/* If the tunnel's socket was created by the kernel,
> +		 * close the socket here since the socket was not
> +		 * created by userspace.
> +		 */
> +		if (sock->file =3D=3D NULL)
> +			err =3D inet_release(sock);
> +	}
> =20
>  	return err;
>  }
> diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
> index c5f2cc9..7e3387b 100644
> --- a/net/l2tp/l2tp_core.h
> +++ b/net/l2tp/l2tp_core.h
> @@ -146,6 +146,13 @@ struct l2tp_tunnel_cfg {
>  	int			debug;		/* bitmask of debug message
>  						 * categories */
>  	enum l2tp_encap_type	encap;
> +
> +	/* Used only for kernel-created sockets */
> +	struct in_addr		local_ip;
> +	struct in_addr		peer_ip;
> +	u16			local_udp_port;
> +	u16			peer_udp_port;
> +	int			use_udp_checksums:1;
>  };
> =20
>  struct l2tp_tunnel {
> diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
> index e051c13..115ea01 100644
> --- a/net/l2tp/l2tp_netlink.c
> +++ b/net/l2tp/l2tp_netlink.c
> @@ -129,11 +129,21 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_=
buff *skb, struct genl_info *info
>  	}
>  	cfg.encap =3D nla_get_u16(info->attrs[L2TP_ATTR_ENCAP_TYPE]);
> =20
> -	if (!info->attrs[L2TP_ATTR_FD]) {
> -		ret =3D -EINVAL;
> -		goto out;
> +	fd =3D -1;
> +	if (info->attrs[L2TP_ATTR_FD]) {
> +		fd =3D nla_get_u32(info->attrs[L2TP_ATTR_FD]);
> +	} else {
> +		if (info->attrs[L2TP_ATTR_IP_SADDR])
> +			cfg.local_ip.s_addr =3D nla_get_be32(info->attrs[L2TP_ATTR_IP_SAD=
DR]);
> +		if (info->attrs[L2TP_ATTR_IP_DADDR])
> +			cfg.peer_ip.s_addr =3D nla_get_be32(info->attrs[L2TP_ATTR_IP_DADD=
R]);
> +		if (info->attrs[L2TP_ATTR_UDP_SPORT])
> +			cfg.local_udp_port =3D nla_get_u16(info->attrs[L2TP_ATTR_UDP_SPOR=
T]);
> +		if (info->attrs[L2TP_ATTR_UDP_DPORT])
> +			cfg.peer_udp_port =3D nla_get_u16(info->attrs[L2TP_ATTR_UDP_DPORT=
]);
> +		if (info->attrs[L2TP_ATTR_UDP_CSUM])
> +			cfg.use_udp_checksums =3D nla_get_flag(info->attrs[L2TP_ATTR_UDP_=
CSUM]);
>  	}
> -	fd =3D nla_get_u32(info->attrs[L2TP_ATTR_FD]);
> =20
>  	if (info->attrs[L2TP_ATTR_DEBUG])
>  		cfg.debug =3D nla_get_u32(info->attrs[L2TP_ATTR_DEBUG]);
>=20


