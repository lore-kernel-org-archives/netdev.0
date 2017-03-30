From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net-next v2] vxlan: fix ND proxy when skb doesn't have transport header offset
Date: Thu, 30 Mar 2017 16:56:18 +0200
Message-ID: <874lyaizjh.fsf@luffy.cx>
References: <20170329204704.26087-1-vincent@bernat.im>
        <m360irs1u8.fsf@luffy.cx>
        <CANn89i+Ms_vvuowjmgERsA3=rMdTm_Cux3XTVJ19ewTz-TtBOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:50659 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933852AbdC3O4b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 10:56:31 -0400
In-Reply-To: <CANn89i+Ms_vvuowjmgERsA3=rMdTm_Cux3XTVJ19ewTz-TtBOw@mail.gmail.com>
        (Eric Dumazet's message of "Thu, 30 Mar 2017 06:36:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mars 2017 06:36 -0700, Eric Dumazet <edumazet@google.com>=C2=
=A0:

>>> Parsing of neighbor discovery options is done earlier to ignore the
>>> whole packet in case of a malformed option. Moreover, the assumption the
>>> skb was linear is removed and options are extracted with
>>> skb_header_pointer() as well. The check on the source link-layer address
>>> option is also more strict (for Ethernet, we expect the length field to
>>> be 1).
>>
>> There is some parsing implemented in net/ipv6/ndisc.c, notably
>> ndisc_parse_options(). I don't know if this is a good idea to reuse
>> that: it may have the expectation that some IP processing has already
>> been done (for example, the IPv6 length has already been checked, the
>> SKB is expected to be linear).
>
> Forcing ICMP being linear is probably fine.
>
> Prior to 91269e390d062b52 ("vxlan: using pskb_may_pull as early as possib=
le")
> this was happening (at the wrong place) in neigh_reduce() doing a :
> if (!pskb_may_pull(skb, skb->len))
>      goto out;

OK, I'll simplify the patch then.

> So the following would be ok (while incomplete of course)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index bdb6ae16d4a85bf9539199e189011bce104ba51a..cd032819d4a36d5ca94739f20=
f947f3f5a31aba3
> 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2243,12 +2243,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
> *skb, struct net_device *dev)
>                         return arp_reduce(dev, skb, vni);
>  #if IS_ENABLED(CONFIG_IPV6)
>                 else if (ntohs(eth->h_proto) =3D=3D ETH_P_IPV6 &&
> -                        pskb_may_pull(skb, sizeof(struct ipv6hdr)
> -                                      + sizeof(struct nd_msg)) &&
> +                        skb->len >=3D sizeof(struct ipv6hdr) +
> +                                    sizeof(struct nd_msg) &&
> +                        pskb_may_pull(skb, skb->len) &&
>                          ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_ICMPV6) {
>                                 struct nd_msg *msg;
>
> -                               msg =3D (struct nd_msg
> *)skb_transport_header(skb);
> +                               msg =3D (struct nd_msg *)(ipv6_hdr(skb) +=
 1);
>                                 if (msg->icmph.icmp6_code =3D=3D 0 &&
>                                     msg->icmph.icmp6_type =3D=3D
> NDISC_NEIGHBOUR_SOLICITATION)
>                                         return neigh_reduce(dev, skb, vni=
);

pskb_may_pull() is called while we only know this is an IPv6 packet, not
an ICMPv6 one. I'll keep skb_header_pointer to handle IPv6 header, then
I'll pull the whole ICMP packet (unless I am mistaken, of course).
--=20
The devil can cite Scripture for his purpose.
		-- William Shakespeare, "The Merchant of Venice"
