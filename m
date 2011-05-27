From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 v2] af-packet:  Use existing netdev reference for
 bound sockets.
Date: Fri, 27 May 2011 05:42:25 +0200
Message-ID: <1306467745.2543.60.camel@edumazet-laptop>
References: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36688 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab1E0Dma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 23:42:30 -0400
Received: by wya21 with SMTP id 21so951642wya.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 20:42:29 -0700 (PDT)
In-Reply-To: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 16:55 -0700, greearb@candelatech.com a =C3=A9=
crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> This saves a network device lookup on each packet transmitted,
> for sockets that are bound to a network device.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
>=20
> v2:  Remove un-used ifindex, lookup dev in else branch.
>=20
> :100644 100644 4005b24... f9b807d... M	net/packet/af_packet.c
>  net/packet/af_packet.c |   27 +++++++++++++++------------
>  1 files changed, 15 insertions(+), 12 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 4005b24..f9b807d 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -989,7 +989,8 @@ static int tpacket_snd(struct packet_sock *po, st=
ruct msghdr *msg)
>  	struct sk_buff *skb;
>  	struct net_device *dev;
>  	__be16 proto;
> -	int ifindex, err, reserve =3D 0;
> +	bool need_rls_dev =3D false;
> +	int err, reserve =3D 0;
>  	void *ph;
>  	struct sockaddr_ll *saddr =3D (struct sockaddr_ll *)msg->msg_name;
>  	int tp_len, size_max;
> @@ -1001,7 +1002,7 @@ static int tpacket_snd(struct packet_sock *po, =
struct msghdr *msg)
> =20
>  	err =3D -EBUSY;
>  	if (saddr =3D=3D NULL) {
> -		ifindex	=3D po->ifindex;
> +		dev =3D po->prot_hook.dev;
>  		proto	=3D po->num;
>  		addr	=3D NULL;
>  	} else {
> @@ -1012,12 +1013,12 @@ static int tpacket_snd(struct packet_sock *po=
, struct msghdr *msg)
>  					+ offsetof(struct sockaddr_ll,
>  						sll_addr)))
>  			goto out;
> -		ifindex	=3D saddr->sll_ifindex;
>  		proto	=3D saddr->sll_protocol;
>  		addr	=3D saddr->sll_addr;
> +		dev =3D dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
> +		need_rls_dev =3D true;
>  	}
> =20
> -	dev =3D dev_get_by_index(sock_net(&po->sk), ifindex);
>  	err =3D -ENXIO;
>  	if (unlikely(dev =3D=3D NULL))
>  		goto out;
> @@ -1103,7 +1104,8 @@ out_status:
>  	__packet_set_status(po, ph, status);
>  	kfree_skb(skb);
>  out_put:
> -	dev_put(dev);
> +	if (need_rls_dev)
> +		dev_put(dev);
>  out:
>  	mutex_unlock(&po->pg_vec_lock);
>  	return err;
> @@ -1141,8 +1143,9 @@ static int packet_snd(struct socket *sock,
>  	struct sk_buff *skb;
>  	struct net_device *dev;
>  	__be16 proto;
> +	bool need_rls_dev =3D false;
>  	unsigned char *addr;
> -	int ifindex, err, reserve =3D 0;
> +	int err, reserve =3D 0;
>  	struct virtio_net_hdr vnet_hdr =3D { 0 };
>  	int offset =3D 0;
>  	int vnet_hdr_len;
> @@ -1160,7 +1163,7 @@ static int packet_snd(struct socket *sock,
>  	 */
> =20
>  	if (saddr =3D=3D NULL) {
> -		ifindex	=3D po->ifindex;
> +		dev =3D po->prot_hook.dev;
>  		proto	=3D po->num;
>  		addr	=3D NULL;
>  	} else {
> @@ -1169,13 +1172,12 @@ static int packet_snd(struct socket *sock,
>  			goto out;
>  		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockadd=
r_ll, sll_addr)))
>  			goto out;
> -		ifindex	=3D saddr->sll_ifindex;
>  		proto	=3D saddr->sll_protocol;
>  		addr	=3D saddr->sll_addr;
> +		dev =3D dev_get_by_index(sock_net(sk), saddr->sll_ifindex);
> +		need_rls_dev =3D true;
>  	}
> =20
> -
> -	dev =3D dev_get_by_index(sock_net(sk), ifindex);
>  	err =3D -ENXIO;
>  	if (dev =3D=3D NULL)
>  		goto out_unlock;
> @@ -1315,14 +1317,15 @@ static int packet_snd(struct socket *sock,
>  	if (err > 0 && (err =3D net_xmit_errno(err)) !=3D 0)
>  		goto out_unlock;
> =20
> -	dev_put(dev);
> +	if (need_rls_dev)
> +		dev_put(dev);
> =20
>  	return len;
> =20
>  out_free:
>  	kfree_skb(skb);
>  out_unlock:
> -	if (dev)
> +	if (dev && need_rls_dev)
>  		dev_put(dev);
>  out:
>  	return err;

Hmmm, I wonder why you want this Ben.

IMHO this is buggy, because we can sleep in this function.

We must take a ref on device (its really cheap these days, now we have =
a
percpu device refcnt)



