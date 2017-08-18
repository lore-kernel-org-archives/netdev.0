From: Matthew Dawson <matthew@mjdsystems.ca>
Subject: [PATCH net v3] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Fri, 18 Aug 2017 15:04:54 -0400
Message-ID: <20170818190454.7214-1-matthew@mjdsystems.ca>
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        "Macieira, Thiago" <thiago.macieira@intel.com>,
        willemdebruijn.kernel@gmail.com, Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scadrial.mjdsystems.ca ([198.100.154.185]:40904 "EHLO
        scadrial.mjdsystems.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdHRTFC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 15:05:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac ("udp: remove
headers from UDP packets before queueing"), when udp packets are being
peeked the requested extra offset is always 0 as there is no need to skip
the udp header.  However, when the offset is 0 and the next skb is
of length 0, it is only returned once.  The behaviour can be seen with
the following python script:

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
__skb_try_recv_from_queue will then ensure the offset is reset back to 0
if a peek is requested without an offset, unless no packets are found.

Also simplify the if condition in __skb_try_recv_from_queue.  If _off is
greater then 0, and off is greater then or equal to skb->len, then
(_off || skb->len) must always be true assuming skb->len >= 0 is always
true.

Also remove a redundant check around a call to sk_peek_offset in af_unix.c,
as it double checked if MSG_PEEK was set in the flags.

V2:
 - Moved the negative fixup into __skb_try_recv_from_queue, and remove now
redundant checks
 - Fix peeking in udp{,v6}_recvmsg to report the right value when the
offset is 0

V3:
 - Marked new branch in __skb_try_recv_from_queue as unlikely.

Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>
Acked-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h  |  4 +---
 net/core/datagram.c | 12 +++++++++---
 net/ipv4/udp.c      |  3 ++-
 net/ipv6/udp.c      |  3 ++-
 net/unix/af_unix.c  |  5 +----
 5 files changed, 15 insertions(+), 12 deletions(-)

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
index ee5647bd91b3..a21ca8dee5ea 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -169,14 +169,20 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 					  int *peeked, int *off, int *err,
 					  struct sk_buff **last)
 {
+	bool peek_at_off = false;
 	struct sk_buff *skb;
-	int _off = *off;
+	int _off = 0;
+
+	if (unlikely(flags & MSG_PEEK && *off >= 0)) {
+		peek_at_off = true;
+		_off = *off;
+	}
 
 	*last = queue->prev;
 	skb_queue_walk(queue, skb) {
 		if (flags & MSG_PEEK) {
-			if (_off >= skb->len && (skb->len || _off ||
-						 skb->peeked)) {
+			if (peek_at_off && _off >= skb->len &&
+			    (_off || skb->peeked)) {
 				_off -= skb->len;
 				continue;
 			}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a7c804f73990..cd1d044a7fa5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1574,7 +1574,8 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		return ip_recv_error(sk, msg, len, addr_len);
 
 try_again:
-	peeking = off = sk_peek_offset(sk, flags);
+	peeking = flags & MSG_PEEK;
+	off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 578142b7ca3e..20039c8501eb 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -362,7 +362,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
 try_again:
-	peeking = off = sk_peek_offset(sk, flags);
+	peeking = flags & MSG_PEEK;
+	off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7b52a380d710..be8982b4f8c0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2304,10 +2304,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state,
 	 */
 	mutex_lock(&u->iolock);
 
-	if (flags & MSG_PEEK)
-		skip = sk_peek_offset(sk, flags);
-	else
-		skip = 0;
+	skip = max(sk_peek_offset(sk, flags), 0);
 
 	do {
 		int chunk;
-- 
2.13.0
