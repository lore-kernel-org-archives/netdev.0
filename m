From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Tue, 17 Aug 2010 07:19:53 +0200
Message-ID: <1282022393.2487.618.camel@edumazet-laptop>
References: <20100816211542.GA21083@n7mm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50112 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab0HQFT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 01:19:58 -0400
Received: by wwi17 with SMTP id 17so569532wwi.1
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 22:19:57 -0700 (PDT)
In-Reply-To: <20100816211542.GA21083@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 23:15 +0200, Gr=C3=A9goire Baron a =C3=
=A9crit :
> net/sched: add ACT_CSUM action to update packets checksums
>=20
> ACT_CSUM can be called just after ACT_PEDIT in order to re-compute so=
me
> altered checksums in IPv4 and IPv6 packets. The following checksums a=
re
> supported by this patch:
>  - IPv4: IPv4 header, ICMP, IGMP, TCP, UDP & UDPLite
>  - IPv6: ICMPv6, TCP, UDP & UDPLite
> It's possible to request in the same action to update different kind =
of
> checksums, if the packets flow mix TCP, UDP and UDPLite, ...
>=20
> An example of usage is done in the associated iproute2 patch.
>=20
> Signed-off-by: Gregoire Baron <baronchon@n7mm.org>

Impressive :)

One style note :

> +
> +	switch (iph->frag_off & htons(IP_OFFSET) ? 0 : iph->protocol) {
> +	case IPPROTO_ICMP:
> +	{
> +		if (update_flags & TCA_CSUM_UPDATE_FLAG_ICMP)
> +			if (!tcf_csum_ipv4_icmp(skb, iph,
> +						iph->ihl * 4, ntohs(iph->tot_len)))
> +				goto fail;
> +		break;
> +	}
> +	case IPPROTO_IGMP:
> +	{
> +		if (update_flags & TCA_CSUM_UPDATE_FLAG_IGMP)
> +			if (!tcf_csum_ipv4_igmp(skb, iph,
> +						iph->ihl * 4, ntohs(iph->tot_len)))
> +				goto fail;
> +		break;
> +	}

You add extra block delimiters (thus two lines) per switch cases, while
not necessary. Please remove them.

And one note about tcf_csum_dump()

static int tcf_csum_dump(struct sk_buff *skb,
                        struct tc_action *a, int bind, int ref)
{
       unsigned char *b =3D skb_tail_pointer(skb);
       struct tcf_csum *p =3D a->priv;
       struct tc_csum *opt;
       struct tcf_t t;
       int s;

       s =3D sizeof(*opt);

       /* netlink spinlocks held above us - must use ATOMIC */
       opt =3D kzalloc(s, GFP_ATOMIC);
       if (unlikely(!opt))
               return -ENOBUFS;

Please dont use kzalloc() here for such a small variable (24 bytes), us=
e
an automatic one (on stack)

struct tc_csum parms =3D {
	.update_flags =3D p->update_flags,
	.index =3D p->tcf_index,
	.action =3D p->tcf_action,
	.refcnt =3D p->tcf_refcnt - ref,
	.bindcnt =3D p->tcf_bindcnt - bind,
};

(Using such a construct make sure holes are zero filled, thus we dont
leak kernel memory to user)

NLA_PUT(skb, TCA_CSUM_PARMS, sizeof(parms), &parms);


Hmm, I can see existing code have some leaks, I'll post a separate
patch...



