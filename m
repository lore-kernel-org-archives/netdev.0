From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 7 Jan 2014 11:52:37 -0800
Message-ID: <CA+mtBx-g2H8dgBSNnKPg1aZQtUg97sTysTuPMPazCquRV_E0Qg@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-fUe_VbUUnjEVXeJO=87yypoDuMfoctO0Q3nMx+6UZFA@mail.gmail.com>
	<CAJZOPZLsMvmHwmMjhsuKb__2HncMXMm=p6UFnT4XX5d8hZnGxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:40055 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaAGTwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:52:37 -0500
Received: by mail-ig0-f180.google.com with SMTP id m12so2575981iga.1
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 11:52:37 -0800 (PST)
In-Reply-To: <CAJZOPZLsMvmHwmMjhsuKb__2HncMXMm=p6UFnT4XX5d8hZnGxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 11:37 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jan 7, 2014 at 8:08 PM, Tom Herbert <therbert@google.com> wrote:
>>
>> On Tue, Jan 7, 2014 at 7:29 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> > +static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct
>> > sk_buff *skb)
>> > +{
>> > +       struct sk_buff *p, **pp = NULL;
>> > +       struct vxlanhdr *vh, *vh2;
>> > +       struct ethhdr *eh;
>> > +       unsigned int hlen, off, off_eth;
>> > +       const struct packet_offload *ptype;
>> > +       __be16 type;
>> > +       int flush = 1;
>> > +
>> > +       off  = skb_gro_offset(skb);
>> > +       hlen = off + sizeof(*vh);
>> > +       vh   = skb_gro_header_fast(skb, off);
>> > +       if (skb_gro_header_hard(skb, hlen)) {
>> > +               vh = skb_gro_header_slow(skb, hlen, off);
>> > +               if (unlikely(!vh))
>> > +                       goto out;
>> > +       }
>> > +
>> > +       flush = 0;
>> > +
>> > +       for (p = *head; p; p = p->next) {
>> > +               if (!NAPI_GRO_CB(p)->same_flow)
>> > +                       continue;
>> > +
>> > +               vh2 = (struct vxlanhdr   *)(p->data + off);
>> > +               if (vh->vx_vni ^ vh2->vx_vni) {
>>
>> Why ^ instead of != ?
>
>
> The XOR approach is very popular in the GRO stack, e.g see the IPv4 chain of
> inet_gro_receive() && tcp_gro_receive(), I guess this might relates to more
> efficient assembly code for ^ vs. != and/or the fast/elegant transitive
> nature of that operator
>
These arguments may have applied twenty years ago, but I seriously
doubt this is going to outwit any modern compiler into producing more
efficient code. To me, it's just making code less readable.

>>
>> > +                       NAPI_GRO_CB(p)->same_flow = 0;
>> > +                       continue;
>> > +               }
>> > +               goto found;
>> > +       }
>
>
