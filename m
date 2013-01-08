From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v5 2/4] ipv6: move csum_ipv6_magic() and udp6_csum_init() into static library
Date: Tue,  8 Jan 2013 14:52:40 +0800
Message-ID: <1357627962-28683-3-git-send-email-amwang@redhat.com>
References: <1357627962-28683-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab3AHGxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 01:53:00 -0500
In-Reply-To: <1357627962-28683-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As suggested by David, udp6_csum_init() is too big to be inlined,
move it to ipv6 static library, net/ipv6/ip6_checksum.c.

And the generic csum_ipv6_magic() too.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ip6_checksum.h |   62 ++--------------------------
 net/ipv6/Makefile          |    2 +-
 net/ipv6/ip6_checksum.c    |   97 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udp.c             |   34 ---------------
 4 files changed, 103 insertions(+), 92 deletions(-)
 create mode 100644 net/ipv6/ip6_checksum.c

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 652d3d3..7686e3f 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -35,63 +35,10 @@
 #include <linux/ipv6.h>
 
 #ifndef _HAVE_ARCH_IPV6_CSUM
-
-static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
-					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
-					  __wsum csum)
-{
-
-	int carry;
-	__u32 ulen;
-	__u32 uproto;
-	__u32 sum = (__force u32)csum;
-
-	sum += (__force u32)saddr->s6_addr32[0];
-	carry = (sum < (__force u32)saddr->s6_addr32[0]);
-	sum += carry;
-
-	sum += (__force u32)saddr->s6_addr32[1];
-	carry = (sum < (__force u32)saddr->s6_addr32[1]);
-	sum += carry;
-
-	sum += (__force u32)saddr->s6_addr32[2];
-	carry = (sum < (__force u32)saddr->s6_addr32[2]);
-	sum += carry;
-
-	sum += (__force u32)saddr->s6_addr32[3];
-	carry = (sum < (__force u32)saddr->s6_addr32[3]);
-	sum += carry;
-
-	sum += (__force u32)daddr->s6_addr32[0];
-	carry = (sum < (__force u32)daddr->s6_addr32[0]);
-	sum += carry;
-
-	sum += (__force u32)daddr->s6_addr32[1];
-	carry = (sum < (__force u32)daddr->s6_addr32[1]);
-	sum += carry;
-
-	sum += (__force u32)daddr->s6_addr32[2];
-	carry = (sum < (__force u32)daddr->s6_addr32[2]);
-	sum += carry;
-
-	sum += (__force u32)daddr->s6_addr32[3];
-	carry = (sum < (__force u32)daddr->s6_addr32[3]);
-	sum += carry;
-
-	ulen = (__force u32)htonl((__u32) len);
-	sum += ulen;
-	carry = (sum < ulen);
-	sum += carry;
-
-	uproto = (__force u32)htonl(proto);
-	sum += uproto;
-	carry = (sum < uproto);
-	sum += carry;
-
-	return csum_fold((__force __wsum)sum);
-}
-
+__sum16 csum_ipv6_magic(const struct in6_addr *saddr,
+			const struct in6_addr *daddr,
+			__u32 len, unsigned short proto,
+			__wsum csum);
 #endif
 
 static __inline__ __sum16 tcp_v6_check(int len,
@@ -126,4 +73,5 @@ static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 	__tcp_v6_send_check(skb, &np->saddr, &np->daddr);
 }
 
+int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
 #endif
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 4ea2448..309af19 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -40,7 +40,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
-obj-y += addrconf_core.o exthdrs_core.o
+obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
new file mode 100644
index 0000000..72d198b
--- /dev/null
+++ b/net/ipv6/ip6_checksum.c
@@ -0,0 +1,97 @@
+#include <net/ip.h>
+#include <net/udp.h>
+#include <net/udplite.h>
+#include <asm/checksum.h>
+
+#ifndef _HAVE_ARCH_IPV6_CSUM
+__sum16 csum_ipv6_magic(const struct in6_addr *saddr,
+			const struct in6_addr *daddr,
+			__u32 len, unsigned short proto,
+			__wsum csum)
+{
+
+	int carry;
+	__u32 ulen;
+	__u32 uproto;
+	__u32 sum = (__force u32)csum;
+
+	sum += (__force u32)saddr->s6_addr32[0];
+	carry = (sum < (__force u32)saddr->s6_addr32[0]);
+	sum += carry;
+
+	sum += (__force u32)saddr->s6_addr32[1];
+	carry = (sum < (__force u32)saddr->s6_addr32[1]);
+	sum += carry;
+
+	sum += (__force u32)saddr->s6_addr32[2];
+	carry = (sum < (__force u32)saddr->s6_addr32[2]);
+	sum += carry;
+
+	sum += (__force u32)saddr->s6_addr32[3];
+	carry = (sum < (__force u32)saddr->s6_addr32[3]);
+	sum += carry;
+
+	sum += (__force u32)daddr->s6_addr32[0];
+	carry = (sum < (__force u32)daddr->s6_addr32[0]);
+	sum += carry;
+
+	sum += (__force u32)daddr->s6_addr32[1];
+	carry = (sum < (__force u32)daddr->s6_addr32[1]);
+	sum += carry;
+
+	sum += (__force u32)daddr->s6_addr32[2];
+	carry = (sum < (__force u32)daddr->s6_addr32[2]);
+	sum += carry;
+
+	sum += (__force u32)daddr->s6_addr32[3];
+	carry = (sum < (__force u32)daddr->s6_addr32[3]);
+	sum += carry;
+
+	ulen = (__force u32)htonl((__u32) len);
+	sum += ulen;
+	carry = (sum < ulen);
+	sum += carry;
+
+	uproto = (__force u32)htonl(proto);
+	sum += uproto;
+	carry = (sum < uproto);
+	sum += carry;
+
+	return csum_fold((__force __wsum)sum);
+}
+EXPORT_SYMBOL(csum_ipv6_magic);
+#endif
+
+int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
+{
+	int err;
+
+	UDP_SKB_CB(skb)->partial_cov = 0;
+	UDP_SKB_CB(skb)->cscov = skb->len;
+
+	if (proto == IPPROTO_UDPLITE) {
+		err = udplite_checksum_init(skb, uh);
+		if (err)
+			return err;
+	}
+
+	if (uh->check == 0) {
+		/* RFC 2460 section 8.1 says that we SHOULD log
+		   this error. Well, it is reasonable.
+		 */
+		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
+		return 1;
+	}
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
+	    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+			     skb->len, proto, skb->csum))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (!skb_csum_unnecessary(skb))
+		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+							 &ipv6_hdr(skb)->daddr,
+							 skb->len, proto, 0));
+
+	return 0;
+}
+EXPORT_SYMBOL(udp6_csum_init);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index dfaa29b..1afb635 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -752,40 +752,6 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	return 0;
 }
 
-static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
-				 int proto)
-{
-	int err;
-
-	UDP_SKB_CB(skb)->partial_cov = 0;
-	UDP_SKB_CB(skb)->cscov = skb->len;
-
-	if (proto == IPPROTO_UDPLITE) {
-		err = udplite_checksum_init(skb, uh);
-		if (err)
-			return err;
-	}
-
-	if (uh->check == 0) {
-		/* RFC 2460 section 8.1 says that we SHOULD log
-		   this error. Well, it is reasonable.
-		 */
-		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
-		return 1;
-	}
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
-			     skb->len, proto, skb->csum))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-	if (!skb_csum_unnecessary(skb))
-		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							 &ipv6_hdr(skb)->daddr,
-							 skb->len, proto, 0));
-
-	return 0;
-}
-
 int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
-- 
1.7.7.6
