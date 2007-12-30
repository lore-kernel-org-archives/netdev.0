From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 3/3] [UDP]: memory accounting in IPv6
Date: Sun, 30 Dec 2007 04:02:26 -0500
Message-ID: <47775EA2.6090105@redhat.com>
References: <47775D8C.5010104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbXL3JEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 04:04:54 -0500
In-Reply-To: <47775D8C.5010104@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds UDP memory usage accounting in IPv6. Currently,
receiving buffer accounting is only supported.

This patch is also introduced memory_allocated variable for UDP protocol.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 udp.c |   32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff -pruN net-2.6.25-t12t19m-p6/net/ipv6/udp.c net-2.6.25-t12t19m-p7/net/ipv6/udp.c
--- net-2.6.25-t12t19m-p6/net/ipv6/udp.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p7/net/ipv6/udp.c	2007-12-29 21:57:41.000000000 -0500
@@ -204,13 +204,17 @@ try_again:
 		err = ulen;

 out_free:
+	lock_sock(sk);
 	skb_free_datagram(sk, skb);
+	release_sock(sk);
 out:
 	return err;

 csum_copy_err:
+	lock_sock(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
 		UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+	release_sock(sk);

 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
@@ -366,10 +370,21 @@ static int __udp6_lib_mcast_deliver(stru
 	while ((sk2 = udp_v6_mcast_next(sk_next(sk2), uh->dest, daddr,
 					uh->source, saddr, dif))) {
 		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
-		if (buff)
-			udpv6_queue_rcv_skb(sk2, buff);
+		if (buff) {
+			bh_lock_sock_nested(sk2);
+			if (!sock_owned_by_user(sk2))
+				udpv6_queue_rcv_skb(sk2, buff);
+			else
+				sk_add_backlog(sk2, buff);
+			bh_unlock_sock(sk2);
+		}
 	}
-	udpv6_queue_rcv_skb(sk, skb);
+	bh_lock_sock_nested(sk);
+	if (!sock_owned_by_user(sk))
+		udpv6_queue_rcv_skb(sk, skb);
+	else
+		sk_add_backlog(sk, skb);
+	bh_unlock_sock(sk);
 out:
 	read_unlock(&udp_hash_lock);
 	return 0;
@@ -482,7 +497,12 @@ int __udp6_lib_rcv(struct sk_buff *skb,

 	/* deliver */

-	udpv6_queue_rcv_skb(sk, skb);
+	bh_lock_sock_nested(sk);
+	if (!sock_owned_by_user(sk))
+		udpv6_queue_rcv_skb(sk, skb);
+	else
+		sk_add_backlog(sk, skb);
+	bh_unlock_sock(sk);
 	sock_put(sk);
 	return 0;

@@ -994,6 +1014,10 @@ struct proto udpv6_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
+	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = sysctl_udp_mem,
+	.sysctl_wmem	   = &sysctl_udp_wmem_min,
+	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
-- 
Hitachi Computer Products (America) Inc.
