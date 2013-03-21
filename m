From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 02:59:49 -0700
Message-ID: <CANP3RGfWh1PVavxd-5gy1KvocgRiTNcm-bYZ=aMG6N6vPgyWnw@mail.gmail.com>
References: <1363841553.3333.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33999 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab3CUJ7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 05:59:50 -0400
Received: by mail-ob0-f181.google.com with SMTP id ni5so2631533obc.26
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 02:59:50 -0700 (PDT)
In-Reply-To: <1363841553.3333.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack.

I've never understood the usefulness of the 'IP ID increments by one'
check in the GRO TCP path anyway.

TCP packets are DF.
AFAICT, the IP identifier field does not really serve a useful purpose
for non-fragment-ed/able packets.

The only possible exception I can think of has to do with
broken/non-spec-compliant stuff which fragments DF packets, or removes
the DF flag.
But that stuff shouldn't really work (and often doesn't) anyway.

Maciej =C5=BBenczykowski, Kernel Networking Developer @ Google

On Wed, Mar 20, 2013 at 9:52 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> GRE TSO support doesn't increment the ID in the inner IP header.
>
> Remove the ID check in inet_gro_receive() so that GRO can properly
> aggregate GRE encapsulated TCP packets, instead of forcing
> a flush for every packet.
>
> Testing the IP ID is not really needed anyway for proper GRO operatio=
n.
>
> We can use more readable (and faster) code to access tot_len and
> frag_off fields.
>
> Tested on a bnx2x setup after commit a848ade408b6b
> (bnx2x: add CSUM and TSO support for encapsulation protocols)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dmitry Kravkov <dmitry@broadcom.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/ipv4/af_inet.c |   11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 9e5882c..302a47e 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1355,7 +1355,6 @@ static struct sk_buff **inet_gro_receive(struct=
 sk_buff **head,
>         const struct iphdr *iph;
>         unsigned int hlen;
>         unsigned int off;
> -       unsigned int id;
>         int flush =3D 1;
>         int proto;
>
> @@ -1381,9 +1380,9 @@ static struct sk_buff **inet_gro_receive(struct=
 sk_buff **head,
>         if (unlikely(ip_fast_csum((u8 *)iph, 5)))
>                 goto out_unlock;
>
> -       id =3D ntohl(*(__be32 *)&iph->id);
> -       flush =3D (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | =
(id ^ IP_DF));
> -       id >>=3D 16;
> +       flush =3D ntohs(iph->tot_len) ^ skb_gro_len(skb);
> +
> +       flush |=3D (__force u16)iph->frag_off ^ htons(IP_DF);
>
>         for (p =3D *head; p; p =3D p->next) {
>                 struct iphdr *iph2;
> @@ -1400,11 +1399,9 @@ static struct sk_buff **inet_gro_receive(struc=
t sk_buff **head,
>                         continue;
>                 }
>
> -               /* All fields must match except length and checksum. =
*/
>                 NAPI_GRO_CB(p)->flush |=3D
>                         (iph->ttl ^ iph2->ttl) |
> -                       (iph->tos ^ iph2->tos) |
> -                       ((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->coun=
t) ^ id);
> +                       (iph->tos ^ iph2->tos);
>
>                 NAPI_GRO_CB(p)->flush |=3D flush;
>         }
>
>
