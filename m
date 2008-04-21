From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [RFC 3/4] ipv4: efficient SOCK_TIMESTAMP support for TCP, UDP, and raw sockets
Date: Sun, 20 Apr 2008 22:35:50 -0700
Message-ID: <20080421053550.GC31778@48M1231.sanmateo.corp.akamai.com>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay03.akamai.com ([72.247.150.167]:57126 "EHLO
	prod-mail-xrelay03.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbYDUFkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:40:01 -0400
Content-Disposition: inline
In-Reply-To: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement SOCK_TIMESTAMP support for TCP, UDP, and raw sockets by
calling sock_timestamp() on each received skb, after we've figured out
which socket(s) it belongs to.

By implementing SOCK_TIMESTAMP at this layer, we make it possible for
timestamps to be enabled on a per-socket basis for these types of
sockets; we avoid the performance penalty of enabling timestamps
globally in the net core.

Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>


---
 net/ipv4/raw.c      |    3 +++
 net/ipv4/tcp_ipv4.c |    3 +++
 net/ipv4/udp.c      |    4 ++++
 3 files changed, 10 insertions(+)

Index: linux/net/ipv4/tcp_ipv4.c
===================================================================
--- linux.orig/net/ipv4/tcp_ipv4.c	2008-04-20 21:03:53.000000000 -0700
+++ linux/net/ipv4/tcp_ipv4.c	2008-04-20 21:04:05.000000000 -0700
@@ -1663,6 +1663,8 @@
 
 	skb->dev = NULL;
 
+	sock_timestamp(sk, skb);
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
@@ -2440,6 +2442,7 @@
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
+	.flags			= (1 << PROTO_HAS_SOCK_TIMESTAMP),
 	REF_PROTO_INUSE(tcp)
 };
 
Index: linux/net/ipv4/udp.c
===================================================================
--- linux.orig/net/ipv4/udp.c	2008-04-20 21:03:53.000000000 -0700
+++ linux/net/ipv4/udp.c	2008-04-20 21:04:05.000000000 -0700
@@ -1085,6 +1085,8 @@
 		do {
 			struct sk_buff *skb1 = skb;
 
+			sock_timestamp(sk, skb);
+
 			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
 						   uh->source, saddr, dif);
 			if (sknext)
@@ -1193,6 +1195,7 @@
 
 	if (sk != NULL) {
 		int ret = 0;
+		sock_timestamp(sk, skb);
 		bh_lock_sock_nested(sk);
 		if (!sock_owned_by_user(sk))
 			ret = udp_queue_rcv_skb(sk, skb);
@@ -1502,6 +1505,7 @@
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
+	.flags		   = (1 << PROTO_HAS_SOCK_TIMESTAMP),
 	REF_PROTO_INUSE(udp)
 };
 
Index: linux/net/ipv4/raw.c
===================================================================
--- linux.orig/net/ipv4/raw.c	2008-04-20 21:03:53.000000000 -0700
+++ linux/net/ipv4/raw.c	2008-04-20 21:04:05.000000000 -0700
@@ -320,6 +320,8 @@
 
 	skb_push(skb, skb->data - skb_network_header(skb));
 
+	sock_timestamp(sk, skb);
+
 	raw_rcv_skb(sk, skb);
 	return 0;
 }
@@ -848,6 +850,7 @@
 	.compat_setsockopt = compat_raw_setsockopt,
 	.compat_getsockopt = compat_raw_getsockopt,
 #endif
+	.flags		   = (1 << PROTO_HAS_SOCK_TIMESTAMP),
 	REF_PROTO_INUSE(raw)
 };
 
