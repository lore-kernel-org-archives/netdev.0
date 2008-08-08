From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: possible recursive locking in udp4_lib_rcv
Date: Fri, 8 Aug 2008 23:01:08 +0800
Message-ID: <20080808150108.GA21048@gondor.apana.org.au>
References: <20080807234613.GA9598@google.com> <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au> <20080808143741.GA20777@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, haoki@redhat.com
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34523 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751694AbYHHPBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 11:01:16 -0400
Content-Disposition: inline
In-Reply-To: <20080808143741.GA20777@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 10:37:41PM +0800, Herbert Xu wrote:
>
> Never mind, I see the reason why it's there.  What we should do
> is drop the lock when we hit an encapsulated socket since they
> don't need it at all.

Here is the patch:

udp: Drop socket lock for encapsulated packets

The socket lock is there to protect the normal UDP receive path.
Encapsulation UDP sockets don't need that protection.  In fact
the locking is deadly for them as they may contain another UDP
packet within, possibly with the same addresses.

Also the nested bit was copied from TCP.  TCP needs it because
of accept(2) spawning sockets.  This simply doesn't apply to UDP
so I've removed it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 383d173..8e42fbb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -989,7 +989,9 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		    up->encap_rcv != NULL) {
 			int ret;
 
+			bh_unlock_sock(sk);
 			ret = (*up->encap_rcv)(sk, skb);
+			bh_lock_sock(sk);
 			if (ret <= 0) {
 				UDP_INC_STATS_BH(sock_net(sk),
 						 UDP_MIB_INDATAGRAMS,
@@ -1092,7 +1094,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			if (skb1) {
 				int ret = 0;
 
-				bh_lock_sock_nested(sk);
+				bh_lock_sock(sk);
 				if (!sock_owned_by_user(sk))
 					ret = udp_queue_rcv_skb(sk, skb1);
 				else
@@ -1194,7 +1196,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 
 	if (sk != NULL) {
 		int ret = 0;
-		bh_lock_sock_nested(sk);
+		bh_lock_sock(sk);
 		if (!sock_owned_by_user(sk))
 			ret = udp_queue_rcv_skb(sk, skb);
 		else
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d1477b3..a6aecf7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -379,7 +379,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 					uh->source, saddr, dif))) {
 		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
 		if (buff) {
-			bh_lock_sock_nested(sk2);
+			bh_lock_sock(sk2);
 			if (!sock_owned_by_user(sk2))
 				udpv6_queue_rcv_skb(sk2, buff);
 			else
@@ -387,7 +387,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			bh_unlock_sock(sk2);
 		}
 	}
-	bh_lock_sock_nested(sk);
+	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
 	else
@@ -508,7 +508,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 
 	/* deliver */
 
-	bh_lock_sock_nested(sk);
+	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
 	else

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
