From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: avoid the unnecessary kmalloc
Date: Tue, 30 Nov 2010 15:45:24 +0800
Message-ID: <AANLkTiny5bXgEMt6dciURNnF+v1X6AnVrbJNo0S9FJP5@mail.gmail.com>
References: <1291077629-6339-1-git-send-email-xiaosuo@gmail.com> <1291099921.2725.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62746 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab0K3Hpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 02:45:46 -0500
Received: by fxm8 with SMTP id 8so895309fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 23:45:45 -0800 (PST)
In-Reply-To: <1291099921.2725.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 2:52 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 30 novembre 2010 =E0 08:40 +0800, Changli Gao a =E9crit :
>> If the old memory allocated by kmalloc() is larger than the new requ=
ested,
>> pskb_expand_head() doesn't need to allocate a new one, unless the sk=
b->head
>> is shared.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Seems fine to me, but patch title and changelog are a bit uninformati=
ve.
>
>
> skb head being allocated by kmalloc(), it might be larger than what
> actually requested because of discrete kmem caches sizes. Before
> reallocating a new skb head, check if the current one has the needed
> extra size.
>
> Do this check only if skb head is not shared.
>
>

OK, I'll refine it with your comment. Thanks.

>
>> +
>> + =A0 =A0 if (fastpath &&
>> + =A0 =A0 =A0 =A0 size + sizeof(struct skb_shared_info) <=3D ksize(s=
kb->head)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->head + size, skb_shinfo(skb),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 offsetof(struct skb_shared=
_info,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0frags[s=
kb_shinfo(skb)->nr_frags]));
>> + =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->head + nhead, skb->head,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_tail_pointer(skb) - sk=
b->head);
>> + =A0 =A0 =A0 =A0 =A0 =A0 off =3D nhead;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto adjust_others;
>> + =A0 =A0 }
>> +
>
> I suggest doing the max possible resize at this stage ?
>
> Ie moving skb_shared_info at the edge of memory block.
>
> Maybe its not necessary, and a given skb is not expanded multiple tim=
es
> in our stack, I dont really know.
>

I don't think it is a good idea, If it is, why not use
ksize(skb->head) to set the tail pointer of skb when allocating a new
skb.

If we do sth. like this, more cache lines maybe involved.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
