From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp6: fix jumbogram reception
Date: Mon, 31 Jul 2017 16:52:36 +0200
Message-ID: <70ca36ffa44fb8d6c369a1ab2866220916e2904a.1501512228.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        David Lebrun <david.lebrun@uclouvain.be>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60506 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750987AbdGaOxG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 10:53:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 67a51780aebb ("ipv6: udp: leverage scratch area
helpers") udp6_recvmsg() read the skb len from the scratch area,
to avoid a cache miss.
But the UDP6 rx path support RFC 2675 UDPv6 jumbograms, and their
length exceeds the 16 bits available in the scratch area. As a side
effect the length returned by recvmsg() is:
<ingress datagram len> % (1<<16)

This commit addresses the issue allocating one more bit in the
IP6CB flags field and setting it for incoming jumbograms.
Such field is still in the first cacheline, so at recvmsg()
time we can check it and fallback to access skb->len if
required, without a measurable overhead.

Fixes: 67a51780aebb ("ipv6: udp: leverage scratch area helpers")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
This is possibly a theoretical only issue: I've been unable to
find an in kernel driver suitable to trigger the issue -
e.g. supporting a max mtu larger than 64K, and I have to resort
using a patched veth driver allowing very large mtu.
Anyway I think this is worth fixing, since pre 67a51780aebb the
IPv6/UDP rx path was able to cope correctly with jumbograms.
---
 include/linux/ipv6.h |  6 ++++++
 net/ipv6/exthdrs.c   |  1 +
 net/ipv6/udp.c       | 11 ++++++++++-
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e1b442996f81..474d6bbc158c 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -128,6 +128,7 @@ struct inet6_skb_parm {
 #define IP6SKB_FRAGMENTED      16
 #define IP6SKB_HOPBYHOP        32
 #define IP6SKB_L3SLAVE         64
+#define IP6SKB_JUMBOGRAM      128
 };
 
 #if defined(CONFIG_NET_L3_MASTER_DEV)
@@ -152,6 +153,11 @@ static inline int inet6_iif(const struct sk_buff *skb)
 	return l3_slave ? skb->skb_iif : IP6CB(skb)->iif;
 }
 
+static inline bool inet6_is_jumbogram(const struct sk_buff *skb)
+{
+	return !!(IP6CB(skb)->flags & IP6SKB_JUMBOGRAM);
+}
+
 /* can not be used in TCP layer after tcp_v6_fill_cb */
 static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
 {
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 4996d734f1d2..3cec529c6113 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -756,6 +756,7 @@ static bool ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 	if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
 		goto drop;
 
+	IP6CB(skb)->flags |= IP6SKB_JUMBOGRAM;
 	return true;
 
 drop:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 98fe4560e24c..578142b7ca3e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -328,6 +328,15 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 #endif
 
+/* do not use the scratch area len for jumbogram: their length execeeds the
+ * scratch area space; note that the IP6CB flags is still in the first
+ * cacheline, so checking for jumbograms is cheap
+ */
+static int udp6_skb_len(struct sk_buff *skb)
+{
+	return unlikely(inet6_is_jumbogram(skb)) ? skb->len : udp_skb_len(skb);
+}
+
 /*
  *	This should be easy, if there is something there we
  *	return it, otherwise we block.
@@ -358,7 +367,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	if (!skb)
 		return err;
 
-	ulen = udp_skb_len(skb);
+	ulen = udp6_skb_len(skb);
 	copied = len;
 	if (copied > ulen - off)
 		copied = ulen - off;
-- 
2.13.3
