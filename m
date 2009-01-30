From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 5/6] netfilter: use sequence number synchronization for
 counters
Date: Fri, 30 Jan 2009 09:03:50 +0100
Message-ID: <4982B466.5000700@cosmosbay.com>
References: <20090129191239.483204605@vyatta.com> <20090129191520.531815152@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43578 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbZA3ID4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 03:03:56 -0500
In-Reply-To: <20090129191520.531815152@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Change how synchronization is done on the iptables counters. Use seqc=
ount
> wrapper instead of depending on reader/writer lock.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

> --- a/net/netfilter/x_tables.c	2009-01-29 11:08:38.747070716 -0800
> +++ b/net/netfilter/x_tables.c	2009-01-29 11:10:03.595571234 -0800
> @@ -577,6 +577,34 @@ int xt_compat_target_to_user(struct xt_e
>  EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
>  #endif
> =20
> +static DEFINE_PER_CPU(seqcount_t, xt_counter_sequence);
> +
> +void xt_fetch_counter(struct xt_counters *v, int cpu,
> +		      const struct xt_counters *c)
> +{
> +	seqcount_t *seq =3D &per_cpu(xt_counter_sequence, cpu);
> +	unsigned start;
> +
> +	do {
> +		start =3D read_seqcount_begin(seq);
> +		*v =3D *c;
> +	} while (read_seqcount_retry(seq, start));
> +}
> +EXPORT_SYMBOL_GPL(xt_fetch_counter);
> +
> +void xt_incr_counter(struct xt_counters *c, unsigned b, unsigned p)

You really want an inline xt_incr_counter() function here to speedup ip=
t_do_table()

I agree xt_fetch_counter() is not time critical and can be outlined.



> +{
> +	seqcount_t *seq =3D &__get_cpu_var(xt_counter_sequence);
> +
> +	write_seqcount_begin(seq);
> +	c->pcnt +=3D p;
> +	c->bcnt +=3D b;
> +	write_seqcount_end(seq);
> +
> +}
> +EXPORT_SYMBOL_GPL(xt_incr_counter);
> +
> +

