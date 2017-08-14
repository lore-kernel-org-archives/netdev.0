From: Matthew Dawson <matthew@mjdsystems.ca>
Subject: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 01:52:59 -0400
Message-ID: <20170814055259.31078-1-matthew@mjdsystems.ca>
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        "Macieira, Thiago" <thiago.macieira@intel.com>,
        willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scadrial.mjdsystems.ca ([198.100.154.185]:50699 "EHLO
        scadrial.mjdsystems.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751491AbdHNGBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 02:01:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac ("udp: remove
headers from UDP packets before queueing"), when udp packets are being
peeked the requested extra offset is always 0 as there is no need to skip
the udp header.  However, when the offset is 0 and the next skb is
of length 0, it is only returned once.  The behaviour can be seen with
the following python script:

#!/usr/bin/env python3
from socket import *;
f=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
g=socket(AF_INET6, SOCK_DGRAM | SOCK_NONBLOCK, 0);
f.bind(('::', 0));
addr=('::1', f.getsockname()[1]);
g.sendto(b'', addr)
g.sendto(b'b', addr)
print(f.recvfrom(10, MSG_PEEK));
print(f.recvfrom(10, MSG_PEEK));

Where the expected output should be the empty string twice.

Instead, make sk_peek_offset return negative values, and pass those values
to __skb_try_recv_datagram/__skb_try_recv_from_queue.  If the passed offset
to __skb_try_recv_from_queue is negative, the checked skb is never skipped.
After the call, the offset is set to 0 if negative to ensure all further
calculations are correct.

Also simplify the if condition in __skb_try_recv_from_queue.  If _off is
greater then 0, and off is greater then or equal to skb->len, then (_off ||
skb->len) must always be true assuming skb->len >= 0 is always true.

Also remove a redundant check around a call to sk_peek_offset in af_unix.c,
as it double checked if MSG_PEEK was set in the flags.

Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>
---
 include/net/sock.h  | 4 +---
 net/core/datagram.c | 4 ++--
 net/ipv4/udp.c      | 4 ++++
 net/ipv6/udp.c      | 4 ++++
 net/unix/af_unix.c  | 8 +++++---
 5 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..aeeec62992ca 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -507,9 +507,7 @@ int sk_set_peek_off(struct sock *sk, int val);
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
 	if (unlikely(flags & MSG_PEEK)) {
-		s32 off = READ_ONCE(sk->sk_peek_off);
-		if (off >= 0)
-			return off;
+		return READ_ONCE(sk->sk_peek_off);
 	}
 
 	return 0;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647bd91b3..a91cd8aa244b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -175,8 +175,8 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 	*last = queue->prev;
 	skb_queue_walk(queue, skb) {
 		if (flags & MSG_PEEK) {
-			if (_off >= skb->len && (skb->len || _off ||
-						 skb->peeked)) {
+			if (_off >= 0 && _off >= skb->len &&
+			    (_off || skb->peeked)) {
 				_off -= skb->len;
 				continue;
 			}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a7c804f73990..a0d8d6d285f4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1576,6 +1576,10 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
+	if (off < 0) {
+		off = 0;
+		peeking = 0;
+	}
 	if (!skb)
 		return err;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 578142b7ca3e..34d8f9f8d87d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -364,6 +364,10 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
+	if (peeking < 0) {
+		off = 0;
+		peeking = 0;
+	}
 	if (!skb)
 		return err;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7b52a380d710..390e0627dc05 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2127,6 +2127,8 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		skip = sk_peek_offset(sk, flags);
 		skb = __skb_try_recv_datagram(sk, flags, NULL, &peeked, &skip,
 					      &err, &last);
+		if (skip < 0)
+			skip = 0;
 		if (skb)
 			break;
 
@@ -2304,10 +2306,10 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state,
 	 */
 	mutex_lock(&u->iolock);
 
-	if (flags & MSG_PEEK)
-		skip = sk_peek_offset(sk, flags);
-	else
+	skip = sk_peek_offset(sk, flags);
+	if (skip < 0) {
 		skip = 0;
+	}
 
 	do {
 		int chunk;
-- 
2.13.0
