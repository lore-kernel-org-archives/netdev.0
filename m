From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Fri, 10 Sep 2010 16:26:10 +0200
Message-ID: <1284128770.24675.41.camel@edumazet-laptop>
References: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58875 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab0IJO0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 10:26:16 -0400
Received: by fxm16 with SMTP id 16so1735658fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 07:26:15 -0700 (PDT)
In-Reply-To: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 septembre 2010 =C3=A0 21:22 +0800, Changli Gao a =C3=A9c=
rit :
> Since skb->destructor() is used to account socket memory, and maybe c=
alled
> before the skb is sent out, a corrupt skb maybe sent out finally.
>=20
> A new destructor is added into structure skb_shared_info(), and it wo=
n't
> be called until the last reference to the data of a skb is put. af_pa=
cket
> uses this destructor instead.
>=20

Hi Changli

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  include/linux/skbuff.h |    1 +
>  net/core/skbuff.c      |   19 ++++++++++++++-----
>  net/packet/af_packet.c |   38 +++++++++++++++++++++++++-------------
>  3 files changed, 40 insertions(+), 18 deletions(-)
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 9e8085a..f874c13 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -191,6 +191,7 @@ struct skb_shared_info {
>  	__u8		tx_flags;
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
> +	void		(*destructor)(struct sk_buff *skb);
> =20
>  	/*
>  	 * Warning : all fields before dataref are cleared in __alloc_skb()
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2d1bc76..ff37e54 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -332,10 +332,14 @@ static void skb_release_data(struct sk_buff *sk=
b)
>  	if (!skb->cloned ||
>  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : =
1,
>  			       &skb_shinfo(skb)->dataref)) {
> -		if (skb_shinfo(skb)->nr_frags) {
> +		struct skb_shared_info *shinfo =3D skb_shinfo(skb);
> +
> +		if (shinfo->destructor)
> +			shinfo->destructor(skb);
> +		if (shinfo->nr_frags) {
>  			int i;
> -			for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> -				put_page(skb_shinfo(skb)->frags[i].page);
> +			for (i =3D 0; i < shinfo->nr_frags; i++)
> +				put_page(shinfo->frags[i].page);
>  		}
> =20
>  		if (skb_has_frag_list(skb))
> @@ -497,9 +501,12 @@ bool skb_recycle_check(struct sk_buff *skb, int =
skb_size)
>  	if (skb_shared(skb) || skb_cloned(skb))
>  		return false;
> =20
> +	shinfo =3D skb_shinfo(skb);
> +	if (shinfo->destructor)
> +		return false;
> +
>  	skb_release_head_state(skb);
> =20
> -	shinfo =3D skb_shinfo(skb);
>  	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
>  	atomic_set(&shinfo->dataref, 1);
> =20
> @@ -799,7 +806,9 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
> =20
>  	memcpy((struct skb_shared_info *)(data + size),
>  	       skb_shinfo(skb),
> -	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_f=
rags]));
> +	       offsetof(struct skb_shared_info,
> +			frags[skb_shinfo(skb)->nr_frags]));
> +	skb_shinfo(skb)->destructor =3D NULL;
> =20
>  	/* Check if we can avoid taking references on fragments if we own
>  	 * the last reference on skb->head. (see skb_release_data())
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 3616f27..7e16b55 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -823,22 +823,27 @@ ring_is_full:
>  	goto drop_n_restore;
>  }
> =20
> +struct tpacket_destructor_arg {
> +	struct sock	*sk;
> +	void		*ph;
> +};
> +
>  static void tpacket_destruct_skb(struct sk_buff *skb)
>  {
> -	struct packet_sock *po =3D pkt_sk(skb->sk);
> -	void *ph;
> -
> -	BUG_ON(skb =3D=3D NULL);
> +	struct tpacket_destructor_arg *arg =3D skb_shinfo(skb)->destructor_=
arg;
> +	struct packet_sock *po =3D pkt_sk(arg->sk);
> +	void *ph =3D arg->ph;
> =20
>  	if (likely(po->tx_ring.pg_vec)) {
> -		ph =3D skb_shinfo(skb)->destructor_arg;
>  		BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDING);
>  		BUG_ON(atomic_read(&po->tx_ring.pending) =3D=3D 0);
>  		atomic_dec(&po->tx_ring.pending);
>  		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
>  	}
> =20
> +	skb->sk =3D arg->sk;
>  	sock_wfree(skb);

Are you sure sock_wfree(skb) is still needed ?


> +	kfree(arg);

this new kmalloc()/kfree() for each sent packet wont please the guys
using af_packet/mmap interface...

>  }
> =20
>  static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *=
skb,
> @@ -862,7 +867,6 @@ static int tpacket_fill_skb(struct packet_sock *p=
o, struct sk_buff *skb,
>  	skb->dev =3D dev;
>  	skb->priority =3D po->sk.sk_priority;
>  	skb->mark =3D po->sk.sk_mark;
> -	skb_shinfo(skb)->destructor_arg =3D ph.raw;
> =20
>  	switch (po->tp_version) {
>  	case TPACKET_V2:
> @@ -884,9 +888,8 @@ static int tpacket_fill_skb(struct packet_sock *p=
o, struct sk_buff *skb,
>  	to_write =3D tp_len;
> =20
>  	if (sock->type =3D=3D SOCK_DGRAM) {
> -		err =3D dev_hard_header(skb, dev, ntohs(proto), addr,
> -				NULL, tp_len);
> -		if (unlikely(err < 0))
> +		if (unlikely(dev_hard_header(skb, dev, ntohs(proto), addr,
> +					     NULL, tp_len) < 0))
>  			return -EINVAL;
>  	} else if (dev->hard_header_len) {
>  		/* net device doesn't like empty head */
> @@ -897,8 +900,7 @@ static int tpacket_fill_skb(struct packet_sock *p=
o, struct sk_buff *skb,
>  		}
> =20
>  		skb_push(skb, dev->hard_header_len);
> -		err =3D skb_store_bits(skb, 0, data,
> -				dev->hard_header_len);
> +		err =3D skb_store_bits(skb, 0, data, dev->hard_header_len);
>  		if (unlikely(err))
>  			return err;
> =20
> @@ -906,7 +908,6 @@ static int tpacket_fill_skb(struct packet_sock *p=
o, struct sk_buff *skb,
>  		to_write -=3D dev->hard_header_len;
>  	}
> =20
> -	err =3D -EFAULT;
>  	page =3D virt_to_page(data);
>  	offset =3D offset_in_page(data);
>  	len_max =3D PAGE_SIZE - offset;
> @@ -994,6 +995,8 @@ static int tpacket_snd(struct packet_sock *po, st=
ruct msghdr *msg)
>  		size_max =3D dev->mtu + reserve;
> =20
>  	do {
> +		struct tpacket_destructor_arg *arg;
> +
>  		ph =3D packet_current_frame(po, &po->tx_ring,
>  				TP_STATUS_SEND_REQUEST);
> =20
> @@ -1028,7 +1031,16 @@ static int tpacket_snd(struct packet_sock *po,=
 struct msghdr *msg)
>  			}
>  		}
> =20
> -		skb->destructor =3D tpacket_destruct_skb;
> +		arg =3D kmalloc(sizeof(*arg), GFP_KERNEL);
> +		if (unlikely(arg =3D=3D NULL)) {
> +			err =3D -ENOBUFS;
> +			goto out_status;
> +		}
> +		arg->sk =3D &po->sk;
> +		arg->ph =3D ph;
> +		skb_shinfo(skb)->destructor_arg =3D arg;
> +		skb->destructor =3D NULL;

why setting skb->destructor to NULL here ?

> +		skb_shinfo(skb)->destructor =3D tpacket_destruct_skb;
>  		__packet_set_status(po, ph, TP_STATUS_SENDING);
>  		atomic_inc(&po->tx_ring.pending);
> =20

I dont yet understand how this can prevent af_unix module being unloade=
d
while packets are in flight=20

I believe sock_wfree() should be avoided (since early orphaning occurs)=
,
to reduce number of atomic ops to the minimum.

af_packet/mmap users want fast operations, we should not use
sock_wfree() for them, because max number of in flight packets is known
(tx ring buffer)


