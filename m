From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH v2 net-next 3/4] ipv6: Add gro functions to sit_offloads
Date: Tue, 20 Oct 2015 11:21:06 +0200
Message-ID: <6053941.09g013ZNxx@stwm.de>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com> <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, Jerry Chu <hkchu@google.com>,
	Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:37845 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbbJTJVJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 05:21:09 -0400
In-Reply-To: <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric!

Am Freitag, 16. Oktober 2015, 08:23:49 schrieb Eric Dumazet:
> On Thu, 2015-08-06 at 17:15 -0700, Jesse Gross wrote:
> > On Mon, Aug 3, 2015 at 10:11 AM, Tom Herbert <tom@herbertland.com> =
wrote:
> > > For GRO to work with sit we need gro_receive and gro_complete pop=
ulated
> > > in the sit_offload structure.
> > >=20
> > > Signed-off-by: Tom Herbert <tom@herbertland.com>
> >=20
> > You might want to checkout the recent history on this file unless
> > there's something that's changed in the last couple of weeks:
> >=20
> > commit fdbf5b097bbd9693a86c0b8bfdd071a9a2117cfc
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Mon Jul 20 17:55:38 2015 +0800
> >=20
> >     Revert "sit: Add gro callbacks to sit_offload"
> >    =20
> >     This patch reverts 19424e052fb44da2f00d1a868cbb51f3e9f4bbb5 ("s=
it:
> >     Add gro callbacks to sit_offload") because it generates packets
> >     that cannot be handled even by our own GSO.
> >    =20
> >     Reported-by: Wolfgang Walter <linux@stwm.de>
> >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >=20
> > --
>=20
> What about the following more complete patch ?
>=20
> We properly set skb->encapsulation and inner network header as some N=
IC
> drivers depend on it. Our GSO should also work properly I think.
>=20
> Wolfgang, could you please test it ? (this is a patch on top of David
> Miller net-next tree)
>=20
> Both Google and Facebook are eager to get proper GRO/SIT support ;)
>=20
> Thanks !

In the moment I can't test it, sorry.

Will test it next week. But as I see you already did that yourself.

>=20
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 08b62047c67f..eeca943f12dc 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -264,6 +264,9 @@ static int ipv6_gro_complete(struct sk_buff *skb,=
 int
> nhoff) struct ipv6hdr *iph =3D (struct ipv6hdr *)(skb->data + nhoff);
>  	int err =3D -ENOSYS;
>=20
> +	if (skb->encapsulation)
> +		skb_set_inner_network_header(skb, nhoff);
> +
>  	iph->payload_len =3D htons(skb->len - nhoff - sizeof(*iph));
>=20
>  	rcu_read_lock();
> @@ -280,6 +283,13 @@ out_unlock:
>  	return err;
>  }
>=20
> +static int sit_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +	skb->encapsulation =3D 1;
> +	skb_shinfo(skb)->gso_type |=3D SKB_GSO_SIT;
> +	return ipv6_gro_complete(skb, nhoff);
> +}
> +
>  static struct packet_offload ipv6_packet_offload __read_mostly =3D {
>  	.type =3D cpu_to_be16(ETH_P_IPV6),
>  	.callbacks =3D {
> @@ -292,6 +302,8 @@ static struct packet_offload ipv6_packet_offload
> __read_mostly =3D { static const struct net_offload sit_offload =3D {
>  	.callbacks =3D {
>  		.gso_segment	=3D ipv6_gso_segment,
> +		.gro_receive    =3D ipv6_gro_receive,
> +		.gro_complete   =3D sit_gro_complete,
>  	},
>  };

Thank you very much,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
