From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Mon, 31 Jul 2006 19:39:48 +0400
Message-ID: <20060731153948.GB17540@ms2.inr.ac.ru>
References: <m3zmevqhgn.fsf@defiant.localdomain> <20060727164334.GA2779@ms2.inr.ac.ru> <m3fygjkpwb.fsf@defiant.localdomain> <20060730.153004.45876935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:58327 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030190AbWGaPkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 11:40:45 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060730.153004.45876935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> It does seem weird that IP output won't pay attention to

Not so weird, actually.

The logic was:

Only initial skb allocation tries to reserve all the space
to avoid copies in the future.

All the rest of places just check, that there is enough space
for their immediate needs. If dev->hard_header() is NULL, it means that
stack does not need any space at all, so that it does not need to worry.

Right logic for reallocation would be:

	if (skb_headroom(skb) < space_which_I_need_now) {
		skb2 = skb_realloc_headroom(skb, space_for_future);
	}

That logic was not followed exactly only because of laziness,
each time some device is found which forgets to check for space,
so reallocation is made in absolutely inappropriate places.
F.e. ip_forward() does not need to reallocate skb when
skb_headroom() < dev->hard_header_len. It does and it is not good.

Good example is ipip tunnel. It sets:

	dev->hard_header_len = sizeof(iphdr) + LL_MAX_HEADER

because it does not know, what device will be used.
It is lots of space and most likely it will not use it.
So, initial allocation reserves lots of space, but all the rest
of stack should not reallocate, tunnel will take care of this itself.

Alexey


