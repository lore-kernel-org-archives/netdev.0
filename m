From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: possible recursive locking in udp4_lib_rcv
Date: Fri, 08 Aug 2008 22:28:41 +0800
Message-ID: <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au>
References: <20080807234613.GA9598@google.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, haoki@redhat.com
To: m.s.tsirkin@gmail.com (Michael S. Tsirkin)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50733 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751299AbYHHO2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 10:28:48 -0400
In-Reply-To: <20080807234613.GA9598@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin <m.s.tsirkin@gmail.com> wrote:
> I noticed the following warnings when running on 2.6.27-rc2
> with lockdep checker enabled:
> 
> [ 2912.004106] Initializing XFRM netlink socket

Argh, this was added by

commit 95766fff6b9a78d11fc2d3812dd035381690b55d
Author: Hideo Aoki <haoki@redhat.com>
Date:   Mon Dec 31 00:29:24 2007 -0800

    [UDP]: Add memory accounting.

@@ -1165,7 +1189,13 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
                               inet_iif(skb), udptable);

        if (sk != NULL) {
-               int ret = udp_queue_rcv_skb(sk, skb);
+               int ret = 0;
+               bh_lock_sock_nested(sk);
+               if (!sock_owned_by_user(sk))
+                       ret = udp_queue_rcv_skb(sk, skb);
+               else
+                       sk_add_backlog(sk, skb);
+               bh_unlock_sock(sk);

Hmm, what was the reason for that lock?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
