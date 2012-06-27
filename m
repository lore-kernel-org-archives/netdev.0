From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_free_datagram_locked() doesnt drop all
 packets
Date: Wed, 27 Jun 2012 12:23:44 +0200
Message-ID: <1340792624.26242.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63077 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723Ab2F0KXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:23:49 -0400
Received: by eeit10 with SMTP id t10so274997eei.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 03:23:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dropwatch wrongly diagnose all received UDP packets as drops.

This patch removes trace_kfree_skb() done in skb_free_datagram_locked().

Locations calling skb_free_datagram_locked() should do it on their own.

As a result, drops are accounted on the right function.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/datagram.c  |    1 -
 net/ipv4/udp.c       |    5 ++++-
 net/ipv6/udp.c       |    8 +++++---
 net/sunrpc/svcsock.c |   12 ++++++------
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index ae6acf6..0337e2b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -248,7 +248,6 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 	unlock_sock_fast(sk, slow);
 
 	/* skb is now orphaned, can be freed outside of locked section */
-	trace_kfree_skb(skb, skb_free_datagram_locked);
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(skb_free_datagram_locked);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index db017ef..ee37d47 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -108,6 +108,7 @@
 #include <net/xfrm.h>
 #include <trace/events/udp.h>
 #include <linux/static_key.h>
+#include <trace/events/skb.h>
 #include "udp_impl.h"
 
 struct udp_table udp_table __read_mostly;
@@ -1220,8 +1221,10 @@ try_again:
 			goto csum_copy_err;
 	}
 
-	if (err)
+	if (unlikely(err)) {
+		trace_kfree_skb(skb, udp_recvmsg);
 		goto out_free;
+	}
 
 	if (!peeked)
 		UDP_INC_STATS_USER(sock_net(sk),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 051ad48..1ecd102 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -48,6 +48,7 @@
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <trace/events/skb.h>
 #include "udp_impl.h"
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
@@ -385,15 +386,16 @@ try_again:
 
 	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied       );
+					      msg->msg_iov, copied);
 	else {
 		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
-	if (err)
+	if (unlikely(err)) {
+		trace_kfree_skb(skb, udpv6_recvmsg);
 		goto out_free;
-
+	}
 	if (!peeked) {
 		if (is_udp4)
 			UDP_INC_STATS_USER(sock_net(sk),
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a6de09d..18bc130 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -43,6 +43,7 @@
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <trace/events/skb.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/clnt.h>
@@ -619,6 +620,8 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	if (!svc_udp_get_dest_address(rqstp, cmh)) {
 		net_warn_ratelimited("svc: received unknown control message %d/%d; dropping RPC reply datagram\n",
 				     cmh->cmsg_level, cmh->cmsg_type);
+out_free:
+		trace_kfree_skb(skb, svc_udp_recvfrom);
 		skb_free_datagram_locked(svsk->sk_sk, skb);
 		return 0;
 	}
@@ -630,8 +633,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
 			local_bh_enable();
 			/* checksum error */
-			skb_free_datagram_locked(svsk->sk_sk, skb);
-			return 0;
+			goto out_free;
 		}
 		local_bh_enable();
 		skb_free_datagram_locked(svsk->sk_sk, skb);
@@ -640,10 +642,8 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.head[0].iov_base = skb->data +
 			sizeof(struct udphdr);
 		rqstp->rq_arg.head[0].iov_len = len;
-		if (skb_checksum_complete(skb)) {
-			skb_free_datagram_locked(svsk->sk_sk, skb);
-			return 0;
-		}
+		if (skb_checksum_complete(skb))
+			goto out_free;
 		rqstp->rq_xprt_ctxt = skb;
 	}
 
