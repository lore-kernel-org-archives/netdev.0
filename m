From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH net v3] ipv4: ipv6: better estimate tunnel header cut for correct ufo handling
Date: Fri, 07 Mar 2014 15:13:34 +0100
Message-ID: <1706818.o0xKyWJ5le@h2o.as.studentenwerk.mhn.de>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <20140223212427.GD6598@order.stressinduktion.org> <20140223234805.GE6598@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:58361 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752854AbaCGONg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 09:13:36 -0500
In-Reply-To: <20140223234805.GE6598@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hannes,

my reply is a little bit late. I use the patch with 3.13.5 and 3.13.6 a=
nd it=20
works fine with ISATAP. Thanks a lot.

Am Montag, 24. Februar 2014, 00:48:05 schrieb Hannes Frederic Sowa:
> Currently the UFO fragmentation process does not correctly handle inn=
er
> UDP frames.
>=20
> (The following tcpdumps are captured on the parent interface with ufo
> disabled while tunnel has ufo enabled, 2000 bytes payload, mtu 1280,
> both sit device):
>=20
> IPv6:
> 16:39:10.031613 IP (tos 0x0, ttl 64, id 3208, offset 0, flags [DF], p=
roto
> IPv6 (41), length 1300) 192.168.122.151 > 1.1.1.1: IP6 (hlim 64,
> next-header Fragment (44) payload length: 1240) 2001::1 > 2001::8: fr=
ag
> (0x00000001:0|1232) 44883 > distinct: UDP, length 2000 16:39:10.03170=
9 IP
> (tos 0x0, ttl 64, id 3209, offset 0, flags [DF], proto IPv6 (41), len=
gth
> 844) 192.168.122.151 > 1.1.1.1: IP6 (hlim 64, next-header Fragment (4=
4)
> payload length: 784) 2001::1 > 2001::8: frag (0x00000001:0|776) 58979=
 >
> 46366: UDP, length 5471
>=20
> We can see that fragmentation header offset is not correctly updated.
> (fragmentation id handling is corrected by 916e4cf46d0204 ("ipv6: reu=
se
> ip6_frag_id from ip6_ufo_append_data")).
>=20
> IPv4:
> 16:39:57.737761 IP (tos 0x0, ttl 64, id 3209, offset 0, flags [DF], p=
roto
> IPIP (4), length 1296) 192.168.122.151 > 1.1.1.1: IP (tos 0x0, ttl 64=
, id
> 57034, offset 0, flags [none], proto UDP (17), length 1276)
> 192.168.99.1.35961 > 192.168.99.2.distinct: UDP, length 2000
> 16:39:57.738028 IP (tos 0x0, ttl 64, id 3210, offset 0, flags [DF], p=
roto
> IPIP (4), length 792) 192.168.122.151 > 1.1.1.1: IP (tos 0x0, ttl 64,=
 id
> 57035, offset 0, flags [none], proto UDP (17), length 772)
> 192.168.99.1.13531 > 192.168.99.2.20653: UDP, length 51109
>=20
> In this case fragmentation id is incremented and offset is not update=
d.
>=20
> First, I aligned inet_gso_segment and ipv6_gso_segment:
> * align naming of flags
> * ipv6_gso_segment: setting skb->encapsulation is unnecessary, as we
>   always ensure that the state of this flag is left untouched when
>   returning from upper gso segmenation function
> * ipv6_gso_segment: move skb_reset_inner_headers below updating the
>   fragmentation header data, we don't care for updating fragmentation
>   header data
> * remove currently unneeded comment indicating skb->encapsulation mig=
ht
>   get changed by upper gso_segment callback (gre and udp-tunnel reset
>   encapsulation after segmentation on each fragment)
>=20
> If we encounter an IPIP or SIT gso skb we now check for the protocol =
=3D=3D
> IPPROTO_UDP and that we at least have already traversed another ip(6)
> protocol header.
>=20
> The reason why we have to special case GSO_IPIP and GSO_SIT is that
> we reset skb->encapsulation to 0 while skb_mac_gso_segment the inner
> protocol of GSO_UDP_TUNNEL or GSO_GRE packets.
>=20
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Changelog v2:
>=20
> * Instead of removing the comment "/* Note : following gso_segment() =
might
>   change skb->encapsulation */" I just moved it to the ip6_offload.c =
file by
> accident.
>=20
> Changelog v3 (only esthetic surgery):
>=20
> * Added skb->encapsulation test to the condition where we test for GR=
E or
>   UDP_TUNNEL gso packet, to be in line with udp_offload test for GSO_=
TUNNEL.
> Sorry for the noise, hopefully the last revision.
>=20
>  net/ipv4/af_inet.c     |  7 +++++--
>  net/ipv6/ip6_offload.c | 20 ++++++++++++--------
>  2 files changed, 17 insertions(+), 10 deletions(-)
>=20
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index ecd2c3f..19ab78a 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1296,8 +1296,11 @@ static struct sk_buff *inet_gso_segment(struct
> sk_buff *skb,
>=20
>  	segs =3D ERR_PTR(-EPROTONOSUPPORT);
>=20
> -	/* Note : following gso_segment() might change skb->encapsulation *=
/
> -	udpfrag =3D !skb->encapsulation && proto =3D=3D IPPROTO_UDP;
> +	if (skb->encapsulation &&
> +	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
> +		udpfrag =3D proto =3D=3D IPPROTO_UDP && encap;
> +	else
> +		udpfrag =3D proto =3D=3D IPPROTO_UDP && !skb->encapsulation;
>=20
>  	ops =3D rcu_dereference(inet_offloads[proto]);
>  	if (likely(ops && ops->callbacks.gso_segment))
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 1e8683b..59f95af 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -89,7 +89,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_b=
uff
> *skb, unsigned int unfrag_ip6hlen;
>  	u8 *prevhdr;
>  	int offset =3D 0;
> -	bool tunnel;
> +	bool encap, udpfrag;
>  	int nhoff;
>=20
>  	if (unlikely(skb_shinfo(skb)->gso_type &
> @@ -110,8 +110,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk=
_buff
> *skb, if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
>  		goto out;
>=20
> -	tunnel =3D SKB_GSO_CB(skb)->encap_level > 0;
> -	if (tunnel)
> +	encap =3D SKB_GSO_CB(skb)->encap_level > 0;
> +	if (encap)
>  		features =3D skb->dev->hw_enc_features & netif_skb_features(skb);
>  	SKB_GSO_CB(skb)->encap_level +=3D sizeof(*ipv6h);
>=20
> @@ -121,6 +121,12 @@ static struct sk_buff *ipv6_gso_segment(struct s=
k_buff
> *skb,
>=20
>  	proto =3D ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
>=20
> +	if (skb->encapsulation &&
> +	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
> +		udpfrag =3D proto =3D=3D IPPROTO_UDP && encap;
> +	else
> +		udpfrag =3D proto =3D=3D IPPROTO_UDP && !skb->encapsulation;
> +
>  	ops =3D rcu_dereference(inet6_offloads[proto]);
>  	if (likely(ops && ops->callbacks.gso_segment)) {
>  		skb_reset_transport_header(skb);
> @@ -133,13 +139,9 @@ static struct sk_buff *ipv6_gso_segment(struct s=
k_buff
> *skb, for (skb =3D segs; skb; skb =3D skb->next) {
>  		ipv6h =3D (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
>  		ipv6h->payload_len =3D htons(skb->len - nhoff - sizeof(*ipv6h));
> -		if (tunnel) {
> -			skb_reset_inner_headers(skb);
> -			skb->encapsulation =3D 1;
> -		}
>  		skb->network_header =3D (u8 *)ipv6h - skb->head;
>=20
> -		if (!tunnel && proto =3D=3D IPPROTO_UDP) {
> +		if (udpfrag) {
>  			unfrag_ip6hlen =3D ip6_find_1stfragopt(skb, &prevhdr);
>  			fptr =3D (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
>  			fptr->frag_off =3D htons(offset);
> @@ -148,6 +150,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk=
_buff
> *skb, offset +=3D (ntohs(ipv6h->payload_len) -
>  				   sizeof(struct frag_hdr));
>  		}
> +		if (encap)
> +			skb_reset_inner_headers(skb);
>  	}
>=20
>  out:

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
