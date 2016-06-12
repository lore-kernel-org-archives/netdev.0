From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Sun, 12 Jun 2016 08:32:51 -0700
Message-ID: <1465745571.7945.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465735407-8345-1-git-send-email-suxm@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Su Xuemin <suxm@chinanetcenter.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33556 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbcFLPc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 11:32:56 -0400
In-Reply-To: <1465735407-8345-1-git-send-email-suxm@chinanetcenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-12 at 20:43 +0800, Su Xuemin wrote:
> From: "Su, Xuemin" <suxm@chinanetcenter.com>
...

> Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

First, I want to thank you for this very high quality submission,
especially if this is your first linux kernel patch.

I have one additional comment to make :



>  		if (score > badness) {
>  			reuseport = sk->sk_reuseport;
> @@ -556,14 +510,20 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  					  daddr, hnum, dif,
>  					  hslot2, slot2, skb);
>  		if (!result) {
> +			unsigned int old = hash2;
>  			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
> +
> +			/* avoid search the same slot again. */
> +			if (unlikely(old == hash2))
> +				return result;
> +

Technically speaking, what matters is the slot, not the hash value
(32bit)

So I would save in old, slot2

>  			slot2 = hash2 & udptable->mask;

And here perform the check
			if (unlikely(slot2 != old_slot))
				return result;

>  			hslot2 = &udptable->hash2[slot2];
>  			if (hslot->count < hslot2->count)
>  				goto begin;


(Same remark applies in IPv6)

Thanks !
