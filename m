From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 00:01:10 +1100
Message-ID: <20071204130109.GA3098@gondor.apana.org.au>
References: <20071204125844.GA2750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1398 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752527AbXLDNBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 08:01:16 -0500
Content-Disposition: inline
In-Reply-To: <20071204125844.GA2750@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

You were right about the SUNRPC stuff being missing after all.  I'd
only looked in svcsock.c and missed the call in xprtsock.c.

[UDP]: Restore missing inDatagrams increments

The previous move of the the UDP inDatagrams counter caused the
counting of encapsulated packets, SUNRPC data (as opposed to call)
packets and RXRPC packets to go missing.

This patch restores all of these.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/udp.h     |    4 ++++
 include/net/udplite.h |    3 ---
 net/ipv4/udp.c        |    6 +++++-
 net/rxrpc/ar-input.c  |    4 ++++
 net/sunrpc/xprtsock.c |    6 +++++-
 5 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -139,6 +139,10 @@ extern int 	udp_lib_setsockopt(struct so
 				   int (*push_pending_frames)(struct sock *));
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
+
+/* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
+DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
+
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
diff --git a/include/net/udplite.h b/include/net/udplite.h
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -13,9 +13,6 @@
 extern struct proto 		udplite_prot;
 extern struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 
-/* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
-DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
-
 /*
  *	Checksum computation is all in software, hence simpler getfrag.
  */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -110,6 +110,7 @@
  */
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
+EXPORT_SYMBOL(udp_statistics);
 
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
@@ -969,8 +970,11 @@ int udp_queue_rcv_skb(struct sock * sk, 
 			int ret;
 
 			ret = (*up->encap_rcv)(sk, skb);
-			if (ret <= 0)
+			if (ret <= 0) {
+				UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS,
+						 is_udplite);
 				return -ret;
+			}
 		}
 
 		/* FALLTHROUGH -- it's a UDP Packet */
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -20,6 +20,7 @@
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
+#include <net/udp.h>
 #include "ar-internal.h"
 
 unsigned long rxrpc_ack_timeout = 1;
@@ -707,10 +708,13 @@ void rxrpc_data_ready(struct sock *sk, i
 	if (skb_checksum_complete(skb)) {
 		rxrpc_free_skb(skb);
 		rxrpc_put_local(local);
+		UDP_INC_STATS_USER(UDP_MIB_INERRORS, 0);
 		_leave(" [CSUM failed]");
 		return;
 	}
 
+	UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, 0);
+
 	/* the socket buffer we have is owned by UDP, with UDP's data all over
 	 * it, but we really want our own */
 	skb_orphan(skb);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -838,8 +838,12 @@ static void xs_udp_data_ready(struct soc
 		copied = repsize;
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
-	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb))
+	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
+		UDP_INC_STATS_USER(UDP_MIB_INERRORS, 0);
 		goto out_unlock;
+	}
+
+	UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, 0);
 
 	/* Something worked... */
 	dst_confirm(skb->dst);
