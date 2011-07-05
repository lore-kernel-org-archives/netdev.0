From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/4] packet: Add fanout support.
Date: Tue, 05 Jul 2011 18:04:00 +0200
Message-ID: <1309881840.2271.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110705.020419.1998951566353182397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62934 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab1GEQEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:04:15 -0400
Received: by wyg8 with SMTP id 8so4099023wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:04:14 -0700 (PDT)
In-Reply-To: <20110705.020419.1998951566353182397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 02:04 -0700, David Miller a =C3=A9crit =
:


> +static int fanout_add(struct sock *sk, u16 id, u8 type)
> +{
> +	struct packet_sock *po =3D pkt_sk(sk);
> +	struct packet_fanout *f, *match;
> +	int err;
> +
> +	switch (type) {
> +	case PACKET_FANOUT_HASH:
> +	case PACKET_FANOUT_LB:
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	if (!po->running)
> +		return -EINVAL;
> +
> +	if (po->fanout)
> +		return -EALREADY;
> +
> +	mutex_lock(&fanout_mutex);
> +	match =3D NULL;
> +	list_for_each_entry(f, &fanout_list, list) {
> +		if (f->id =3D=3D id &&
> +		    read_pnet(&f->net) =3D=3D sock_net(sk)) {
> +			match =3D f;
> +			break;
> +		}
> +	}
> +	if (!match) {
> +		match =3D kzalloc(sizeof(*match), GFP_KERNEL);
> +		if (match) {
> +			write_pnet(&match->net, sock_net(sk));
> +			match->id =3D id;
> +			match->type =3D type;
> +			atomic_set(&match->rr_cur, 0);
> +			INIT_LIST_HEAD(&match->list);
> +			spin_lock_init(&match->lock);
> +			atomic_set(&match->sk_ref, 0);
> +			match->prot_hook.type =3D po->prot_hook.type;
> +			match->prot_hook.dev =3D po->prot_hook.dev;
> +			switch (type) {
> +			case PACKET_FANOUT_HASH:
> +				match->prot_hook.func =3D packet_rcv_fanout_hash;
> +				break;
> +			case PACKET_FANOUT_LB:
> +				match->prot_hook.func =3D packet_rcv_fanout_lb;
> +				break;
> +			}
> +			match->prot_hook.af_packet_priv =3D match;
> +			dev_add_pack(&match->prot_hook);

There is a small window where __fanout_link(sk, po) is not yet called,
but packets can be received on other cpus since dev_add_pack() was
called.

There is no divide by 0, but fanout_demux_hash() can return a NULL sk,
thus we can crash...

> +			list_add(&match->list, &fanout_list);
> +		}
> +	}
> +	err =3D -ENOMEM;
> +	if (match) {
> +		err =3D -EINVAL;
> +		if (match->type =3D=3D type &&
> +		    match->prot_hook.type =3D=3D po->prot_hook.type &&
> +		    match->prot_hook.dev =3D=3D po->prot_hook.dev) {
> +			err =3D -ENOSPC;
> +			if (atomic_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
> +				__dev_remove_pack(&po->prot_hook);
> +				po->fanout =3D match;
> +				atomic_inc(&match->sk_ref);
> +				__fanout_link(sk, po);
> +				err =3D 0;
> +			}
> +		}
> +	}
> +	mutex_unlock(&fanout_mutex);
> +	return err;
> +}
> +


