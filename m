From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 20:51:59 +1100
Message-ID: <20071205095159.GA16860@gondor.apana.org.au>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au> <47567128.2060008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1271 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751296AbXLEJwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:52:13 -0500
Content-Disposition: inline
In-Reply-To: <47567128.2060008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 10:36:40AM +0100, Eric Dumazet wrote:
> 
> Hum, what happens if I have in my .config file :
> 
> CONFIG_IPV6=n

Thanks.  Obviously I shouldn't have touched this stuff at all :)
Let's hope this is the last problem.

[UDP]: Restore missing inDatagrams increments

The previous move of the the UDP inDatagrams counter caused the
counting of encapsulated packets, SUNRPC data (as opposed to call)
packets and RXRPC packets to go missing.

This patch restores all of these.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e90f962..a84f3f6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -164,15 +164,6 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #define ICMP6MSGIN_INC_STATS_USER(idev, field) \
 	_DEVINC(icmpv6msg, _USER, idev, field)
 
-DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
-DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
-#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
-	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
-	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
-#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
-	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
-	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
-
 struct ip6_ra_chain
 {
 	struct ip6_ra_chain	*next;
diff --git a/include/net/udp.h b/include/net/udp.h
index 98755eb..98cb09c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -139,6 +139,12 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   int (*push_pending_frames)(struct sock *));
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
+DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
+
+/* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
+DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
+DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
+
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
@@ -149,6 +155,25 @@ DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
 
+#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
+	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
+	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
+#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
+	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
+	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#define UDPX_INC_STATS_BH(sk, field) \
+	do { \
+		if ((sk)->sk_family == AF_INET) \
+			UDP_INC_STATS_BH(field, 0); \
+		else \
+			UDP6_INC_STATS_BH(field, 0); \
+	} while (0);
+#else
+#define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(field, 0)
+#endif
+
 /* /proc */
 struct udp_seq_afinfo {
 	struct module		*owner;
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 635b0ea..b76b2e3 100644
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
index f50de5d..78cfcb4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -110,6 +110,7 @@
  */
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
+EXPORT_SYMBOL(udp_statistics);
 
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
@@ -969,8 +970,11 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
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
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 8631ed7..9fc2428 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -27,6 +27,7 @@
 #include <net/ip.h>
 #include <net/sock.h>
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 87bccec..36bdcd2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -34,6 +34,7 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/skbuff.h>
 #include <asm/uaccess.h>
 
@@ -51,6 +52,7 @@
 #include "udp_impl.h"
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
+EXPORT_SYMBOL(udp_stats_in6);
 
 static inline int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 91b5bbb..f446d9b 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -20,6 +20,7 @@
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
+#include <net/udp.h>
 #include "ar-internal.h"
 
 unsigned long rxrpc_ack_timeout = 1;
@@ -707,10 +708,13 @@ void rxrpc_data_ready(struct sock *sk, int count)
 	if (skb_checksum_complete(skb)) {
 		rxrpc_free_skb(skb);
 		rxrpc_put_local(local);
+		UDP_INC_STATS_BH(UDP_MIB_INERRORS, 0);
 		_leave(" [CSUM failed]");
 		return;
 	}
 
+	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, 0);
+
 	/* the socket buffer we have is owned by UDP, with UDP's data all over
 	 * it, but we really want our own */
 	skb_orphan(skb);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2f630a5..6fa52f4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -838,8 +838,12 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 		copied = repsize;
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
-	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb))
+	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
+		UDPX_INC_STATS_BH(sk, UDP_MIB_INERRORS);
 		goto out_unlock;
+	}
+
+	UDPX_INC_STATS_BH(sk, UDP_MIB_INDATAGRAMS);
 
 	/* Something worked... */
 	dst_confirm(skb->dst);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
