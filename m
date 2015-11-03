From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Tue, 03 Nov 2015 13:57:06 +0100
Message-ID: <19837690.PaPkekjCr9@stwm.de>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com> <1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:50023 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbbKCM5J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 07:57:09 -0500
In-Reply-To: <1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 19. Oktober 2015, 20:40:17 schrieb Eric Dumazet:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Tom Herbert added SIT support to GRO with commit
> 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
> later reverted by Herbert Xu.
>=20
> The problem came because Tom patch was building GRO
> packets without proper meta data : If packets were locally
> delivered, we would not care.
>=20
> But if packets needed to be forwarded, GSO engine was not
> able to segment individual segments.
>=20
> With the following patch, we correctly set skb->encapsulation
> and inner network header. We also update gso_type.
>=20

I'm running 4.1.11 / 4.1.12 with this patch on top now since over a wee=
k.=20
ISATAP works fine.
=20

> Tested:
>=20
> Server :
> netserver
> modprobe dummy
> ifconfig dummy0 8.0.0.1 netmask 255.255.255.0 up
> arp -s 8.0.0.100 4e:32:51:04:47:e5
> iptables -I INPUT -s 10.246.7.151 -j TEE --gateway 8.0.0.100
> ifconfig sixtofour0
> sixtofour0 Link encap:IPv6-in-IPv4
>           inet6 addr: 2002:af6:798::1/128 Scope:Global
>           inet6 addr: 2002:af6:798::/128 Scope:Global
>           UP RUNNING NOARP  MTU:1480  Metric:1
>           RX packets:411169 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:409414 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:20319631739 (20.3 GB)  TX bytes:29529556 (29.5 MB)
>=20
> Client :
> netperf -H 2002:af6:798::1 -l 1000 &
>=20
> Checked on server traffic copied on dummy0 and verify segments were
> properly rebuilt, with proper IP headers, TCP checksums...
>=20
> tcpdump on eth0 shows proper GRO aggregation takes place.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/ip6_offload.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
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

Thanks,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
