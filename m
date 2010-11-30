From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Tue, 30 Nov 2010 15:12:21 +0100
Message-ID: <1291126341.2904.82.camel@edumazet-laptop>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:53457 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab0K3OM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:12:26 -0500
Received: by ewy5 with SMTP id 5so2710988ewy.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 06:12:25 -0800 (PST)
In-Reply-To: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 21:56 +0800, Changli Gao a =C3=A9crit =
:
> The following commit causes the pgv->buffer may point to the memory
> returned by vmalloc(). And we can't use virt_to_page() for the vmallo=
c
> address.
>=20
> This patch introduces a new inline function pgv_to_page(), which call=
s
> vmalloc_to_page() for the vmalloc address, and virt_to_page() for the
> __get_free_pages address.
>=20
>     commit 0e3125c755445664f00ad036e4fc2cd32fd52877
>     Author: Neil Horman <nhorman@tuxdriver.com>
>     Date:   Tue Nov 16 10:26:47 2010 -0800
>=20
>     packet: Enhance AF_PACKET implementation to not require high orde=
r contiguous memory allocation (v4)
>=20

nice catch.

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/packet/af_packet.c |   21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 422705d..0171b20 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -224,6 +224,13 @@ struct packet_skb_cb {
> =20
>  #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
> =20
> +static inline struct page *pgv_to_page(void *addr)
> +{
> +	if (is_vmalloc_addr(addr))
> +		return vmalloc_to_page(addr);

Hmm, I am wondering if calling vmalloc_to_page(addr) several times for
each packet is not too expensive ? I believe it is.

What about caching "struct page *" pointer somewhere ?

Then later we have :

> -		p_start =3D virt_to_page(h.raw);
> -		p_end =3D virt_to_page(h_end);
> +		p_start =3D pgv_to_page(h.raw);
> +		p_end =3D pgv_to_page(h_end);
>  		while (p_start <=3D p_end) {
>  			flush_dcache_page(p_start);
>  			p_start++;

This was OK before Neil patch... after vmalloc(), assumption that
p_start can be incremented is completely wrong.

To fix this, we need something else than your patch.




