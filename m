From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: avoid the unnecessary kmalloc
Date: Tue, 30 Nov 2010 07:52:01 +0100
Message-ID: <1291099921.2725.28.camel@edumazet-laptop>
References: <1291077629-6339-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:45949 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab0K3GwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 01:52:07 -0500
Received: by wwf26 with SMTP id 26so992570wwf.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 22:52:05 -0800 (PST)
In-Reply-To: <1291077629-6339-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 08:40 +0800, Changli Gao a =C3=A9crit =
:
> If the old memory allocated by kmalloc() is larger than the new reque=
sted,
> pskb_expand_head() doesn't need to allocate a new one, unless the skb=
->head
> is shared.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Seems fine to me, but patch title and changelog are a bit uninformative=
=2E


skb head being allocated by kmalloc(), it might be larger than what
actually requested because of discrete kmem caches sizes. Before
reallocating a new skb head, check if the current one has the needed
extra size.

Do this check only if skb head is not shared.



> +
> +	if (fastpath &&
> +	    size + sizeof(struct skb_shared_info) <=3D ksize(skb->head)) {
> +		memmove(skb->head + size, skb_shinfo(skb),
> +			offsetof(struct skb_shared_info,
> +				 frags[skb_shinfo(skb)->nr_frags]));
> +		memmove(skb->head + nhead, skb->head,
> +			skb_tail_pointer(skb) - skb->head);
> +		off =3D nhead;
> +		goto adjust_others;
> +	}
> +

I suggest doing the max possible resize at this stage ?

Ie moving skb_shared_info at the edge of memory block.

Maybe its not necessary, and a given skb is not expanded multiple times
in our stack, I dont really know.



