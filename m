From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 20:07:33 +0200
Message-ID: <1302113253.3209.126.camel@edumazet-laptop>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35069 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550Ab1DFSHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:07:38 -0400
Received: by wya21 with SMTP id 21so1540731wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 11:07:36 -0700 (PDT)
In-Reply-To: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 13:54 -0400, Neil Horman a =C3=A9crit =
:

> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index d7037c0..aa3e327 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -505,6 +505,8 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct =
sk_buff *skb)
>  	int rc;
>  	int is_udplite =3D IS_UDPLITE(sk);
> =20
> +	sock_rps_save_rxhash(sk, skb->rxhash);
> +
>  	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
>  		goto drop;
> =20

Problem is every packet received might have a different rxhash if
multiple senders are active.=20

This can hurt performance (cache misses on RFS table) on a DNS server
workload for example.

This is why we used on ipv4 :

if (inet_sk(sk)->inet_daddr)
	sock_rps_save_rxhash(sk, skb->rxhash);


Only arm RFS on UDP if socket is bound to a given remote peer.

BTW you forgot Tom Herbert. (I added him in CC)



