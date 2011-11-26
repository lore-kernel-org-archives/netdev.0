From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] l2tp: ensure sk->dst is still valid
Date: Sat, 26 Nov 2011 05:30:01 +0100
Message-ID: <1322281801.10212.7.camel@edumazet-laptop>
References: <1322239636-1839-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:40937 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab1KZEaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 23:30:06 -0500
Received: by wwo28 with SMTP id 28so3498342wwo.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 20:30:04 -0800 (PST)
In-Reply-To: <1322239636-1839-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 17:47 +0100, Florian Westphal a =C3=
=A9crit :
> When using l2tp over ipsec, the tunnel will hang when rekeying
> occurs. Reason is that the transformer bundle attached to the dst ent=
ry
> is now in STATE_DEAD and thus xfrm_output_one() drops all packets
> (XfrmOutStateExpired increases).
>=20
> Fix this by calling __sk_dst_check (which drops the stale dst
> if xfrm dst->check callback finds that the bundle is no longer valid)=
=2E
>=20
> Cc: James Chapman <jchapman@katalix.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/l2tp/l2tp_core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index cf0f308..89ff8c6 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1072,7 +1072,7 @@ int l2tp_xmit_skb(struct l2tp_session *session,=
 struct sk_buff *skb, int hdr_len
> =20
>  	/* Get routing info from the tunnel socket */
>  	skb_dst_drop(skb);
> -	skb_dst_set(skb, dst_clone(__sk_dst_get(sk)));
> +	skb_dst_set(skb, dst_clone(__sk_dst_check(sk, 0)));
> =20
>  	inet =3D inet_sk(sk);
>  	fl =3D &inet->cork.fl;

Seems good to me, although we could use RCU and skb_dst_set_noref() to
avoid dirtying dst refcount. I'll send a patch for net-next later.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
