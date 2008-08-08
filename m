From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: possible recursive locking in udp4_lib_rcv
Date: Fri, 8 Aug 2008 22:37:42 +0800
Message-ID: <20080808143741.GA20777@gondor.apana.org.au>
References: <20080807234613.GA9598@google.com> <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, haoki@redhat.com
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43164 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751540AbYHHOhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 10:37:48 -0400
Content-Disposition: inline
In-Reply-To: <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 10:28:41PM +0800, Herbert Xu wrote:
>
> @@ -1165,7 +1189,13 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
>                                inet_iif(skb), udptable);
> 
>         if (sk != NULL) {
> -               int ret = udp_queue_rcv_skb(sk, skb);
> +               int ret = 0;
> +               bh_lock_sock_nested(sk);
> +               if (!sock_owned_by_user(sk))
> +                       ret = udp_queue_rcv_skb(sk, skb);
> +               else
> +                       sk_add_backlog(sk, skb);
> +               bh_unlock_sock(sk);
> 
> Hmm, what was the reason for that lock?

Never mind, I see the reason why it's there.  What we should do
is drop the lock when we hit an encapsulated socket since they
don't need it at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
