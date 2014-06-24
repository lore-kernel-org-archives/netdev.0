From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 3/7] net-timestamp: tx timestamp without payload
Date: Tue, 24 Jun 2014 11:43:48 -0400
Message-ID: <1403624632-17327-4-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:38445 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbaFXPud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:50:33 -0400
Received: by mail-yh0-f74.google.com with SMTP id b6so43579yha.1
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:50:32 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications receive tx timestamps from the kernel by reading the
original packet from the socket error queue with sendmsg() and
processing an ancillary data item that holds the timestamps.

If the application is only interested in the timestamp, then looping
the whole packet back up to userspace wastes socket buffer space
(SO_RCVBUF). This is especially important when the same packet is
enqueued repeatedly with multiple timestamps.

This patch adds a socket option to loop the timestamp on top of an
empty packet instead of a clone of the original.

The option is only implemented for tx timestamps. Code that dequeues
from an sk_error_queue onto which skb_tstamp_tx enqueues has to be
able to handle zero-length packets.  Common implementations peek into
the packet headers, for instance to learn the address for msg_namelen.
When the queued skb has no payload, this data is unavailable and thus
not returned. skb_dequeue(sk->sk_error_queue) callers have been
audited to avoid accessing packet contents and fixed where needed
(IP, IPv6, RxRPC).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h              |  1 +
 include/uapi/linux/net_tstamp.h |  5 +++--
 net/core/skbuff.c               | 16 ++++++++++++----
 net/core/sock.c                 |  4 ++++
 net/ipv4/ip_sockglue.c          |  4 ++--
 net/ipv6/datagram.c             |  4 ++--
 net/rxrpc/ar-error.c            |  5 +++++
 7 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 32cd1be..df7bde0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -690,6 +690,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
 	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
+	SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD, /* %SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index f53879c..0b4a2b0 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -20,9 +20,10 @@ enum {
 	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
+	SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD = (1<<7),
 	SOF_TIMESTAMPING_MASK =
-	(SOF_TIMESTAMPING_RAW_HARDWARE - 1) |
-	SOF_TIMESTAMPING_RAW_HARDWARE
+	(SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD - 1) |
+	SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD
 };
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9cd5344..bc653c4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3501,6 +3501,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (!sk)
 		return;
 
+	if (sock_flag(sk, SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD))
+		skb = alloc_skb(0, GFP_ATOMIC);
+	else
+		skb = skb_clone(orig_skb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
 	if (hwtstamps) {
 		*skb_hwtstamps(orig_skb) =
 			*hwtstamps;
@@ -3510,12 +3517,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 		 * so keep the shared tx_flags and only
 		 * store software time stamp
 		 */
-		orig_skb->tstamp = ktime_get_real();
+		skb->tstamp = ktime_get_real();
 	}
 
-	skb = skb_clone(orig_skb, GFP_ATOMIC);
-	if (!skb)
-		return;
+	if (!skb->len) {
+		skb_shinfo(skb)->tx_flags = skb_shinfo(orig_skb)->tx_flags;
+		*skb_hwtstamps(skb) = *skb_hwtstamps(orig_skb);
+	}
 
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
diff --git a/net/core/sock.c b/net/core/sock.c
index 026e01f..0e8b518 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -866,6 +866,8 @@ set_rcvbuf:
 				  val & SOF_TIMESTAMPING_SYS_HARDWARE);
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE,
 				  val & SOF_TIMESTAMPING_RAW_HARDWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD,
+				  val & SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD);
 		break;
 
 	case SO_RCVLOWAT:
@@ -1106,6 +1108,8 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 			v.val |= SOF_TIMESTAMPING_SYS_HARDWARE;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE))
 			v.val |= SOF_TIMESTAMPING_RAW_HARDWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_OPT_TX_NO_PAYLOAD))
+			v.val |= SOF_TIMESTAMPING_OPT_TX_NO_PAYLOAD;
 		break;
 
 	case SO_RCVTIMEO:
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 64741b9..f17f34f 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -432,7 +432,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
 						   serr->addr_offset);
@@ -444,7 +444,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
 	sin->sin_family = AF_UNSPEC;
-	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP) {
+	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP && skb->len) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		sin->sin_family = AF_INET;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c3bf2d2..391e6e0 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -358,7 +358,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin) {
+	if (sin && skb->len) {
 		const unsigned char *nh = skb_network_header(skb);
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
@@ -383,7 +383,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
 	sin->sin6_family = AF_UNSPEC;
-	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
+	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL && skb->len) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = 0;
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index db57458..f9a65c0 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -42,6 +42,11 @@ void rxrpc_UDP_error_report(struct sock *sk)
 		_leave("UDP socket errqueue empty");
 		return;
 	}
+	if (!skb->len) {
+		_leave("UDP empty message");
+		kfree_skb(skb);
+		return;
+	}
 
 	rxrpc_new_skb(skb);
 
-- 
2.0.0.526.g5318336
