From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: DNS (?) not working on G5 (64-bit powerpc) (was [net-next,v3,3/3]
 udp: try to avoid 2 cache miss on dequeue)
Date: Thu, 22 Jun 2017 23:18:17 +0200
Message-ID: <1498166297.111795.1018373424.5E414246@webmail.messagingengine.com>
References: <87shisqihz.fsf@concordia.ellerman.id.au>
 <1498165026.2503.21.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: Paolo Abeni <pabeni@redhat.com>,
        Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50407 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752227AbdFVVSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 17:18:18 -0400
In-Reply-To: <1498165026.2503.21.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017, at 22:57, Paolo Abeni wrote:
>=20
> Can you please check if the following patch fixes the issue? Only
> compiled tested here.
>=20
> Thanks!!!
> ---
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 067a607..80d89fe 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1446,16 +1446,19 @@ static struct sk_buff
> *__first_packet_length(struct sock *sk,
> =C2=A0{
> =C2=A0	struct sk_buff *skb;
> =C2=A0
> -       while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
> -       =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0udp_lib_checksum_comple=
te(skb)) {
> -               __UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
> -                               IS_UDPLITE(sk));
> -               __UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
> -                               IS_UDPLITE(sk));
> -               atomic_inc(&sk->sk_drops);
> -               __skb_unlink(skb, rcvq);
> -               *total +=3D skb->truesize;
> -               kfree_skb(skb);
> +       while ((skb =3D skb_peek(rcvq)) !=3D NULL) {
> +               if (udp_lib_checksum_complete(skb)) {
> +                       __UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
> +                                       IS_UDPLITE(sk));
> +                       __UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
> +                                       IS_UDPLITE(sk));
> +                       atomic_inc(&sk->sk_drops);
> +                       __skb_unlink(skb, rcvq);
> +                       *total +=3D skb->truesize;
> +                       kfree_skb(skb);
> +               } else {
> +                       udp_set_dev_scratch(skb);

It needs a "break;" here.

> +               }
> =C2=A0	}
> =C2=A0	return skb;
> =C2=A0}

Bye,
Hannes
