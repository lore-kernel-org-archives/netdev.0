From: Peter Dawson <petedaws@gmail.com>
Subject: Re: [PATCH v2] ip6_tunnel: Correct tos value in collect_md mode
Date: Thu, 15 Jun 2017 13:54:32 +1000
Message-ID: <20170615135432.78442af5@gmail.com>
References: <1497493829-13050-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497493829-13050-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Jun 2017 10:30:29 +0800
Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:

> Same as ip_gre, geneve and vxlan, use key->tos as tos value.
>=20
> CC: Peter Dawson <petedaws@gmail.com>
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
> encapsulated packets=E2=80=9D)
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>=20
> ---
> Changes since v2:
>   * Add fixes information
>   * mask key->tos with RT_TOS() suggested by Daniel
> ---
>  net/ipv6/ip6_tunnel.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index ef99d59..6400726 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev, __u8 dsfield,
>  		fl6.flowi6_proto =3D IPPROTO_IPIP;
>  		fl6.daddr =3D key->u.ipv6.dst;
>  		fl6.flowlabel =3D key->label;
> -		dsfield =3D ip6_tclass(key->label);
> +		dsfield =3D  RT_TOS(key->tos);
>  	} else {
>  		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
>  			encap_limit =3D t->parms.encap_limit;
> @@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev, __u8 dsfield,
>  		fl6.flowi6_proto =3D IPPROTO_IPV6;
>  		fl6.daddr =3D key->u.ipv6.dst;
>  		fl6.flowlabel =3D key->label;
> -		dsfield =3D ip6_tclass(key->label);
> +		dsfield =3D RT_TOS(key->tos);
>  	} else {
>  		offset =3D ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
>  		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */

I don't think it is correct to apply RT_TOS

Here is my understanding based on the RFCs.

IPv4/6 Header:0 |0 1 2 3 |0 1 2 3 |0 1 2 3 |0 1 2 3 |
RFC2460(IPv6)   |Version | Traffic Class   |        |
RFC2474(IPv6)   |Version | DSCP        |ECN|        |
RFC2474(IPv4)   |Version |  IHL   |    DSCP     |ECN|
RFC1349(IPv4)   |Version |  IHL   | PREC |  TOS   |X|    =20
RFC791 (IPv4)   |Version |  IHL   |      TOS        |

u8 key->tos stores the full 8bits of Traffic class from an IPv6 header and;
u8 key->tos stores the full 8bits of TOS(RFC791) from an IPv4 header
u8 ip6_tclass will return the full 8bits of Traffic Class from an IPv6 flow=
label

RT_TOS will return the RFC1349 4bit TOS field.

Applying RT_TOS to a key->tos will result in lost information and the inclu=
sion of 1 bit of ECN if the original field was a DSCP+ECN.

Based on this understanding of the RFCs (but not years of experience) and s=
ince RFC1349 has been obsoleted by RFC2474 I think the use of RT_TOS should=
 be deprecated.

This being said, dsfield =3D ip6_tclass(key->label) =3D key->tos isn't full=
y correct either because the result will contain the ECN bits as well as th=
e DSCP.

I agree that code should be consistent, but not where there is a potential =
issue.
