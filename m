From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3] net: Require exact match for TCP socket lookups if dif is l3mdev
Date: Fri, 14 Oct 2016 12:29:19 -0700
Message-ID: <1476473359-15422-1-git-send-email-dsa@cumulusnetworks.com>
Cc: eric.dumazet@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34690 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbcJNT30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 15:29:26 -0400
Received: by mail-pf0-f170.google.com with SMTP id r16so30016084pfg.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 12:29:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, socket lookups for l3mdev (vrf) use cases can match a socket
that is bound to a port but not a device (ie., a global socket). If the
sysctl tcp_l3mdev_accept is not set this leads to ack packets going out
based on the main table even though the packet came in from an L3 domain.
The end result is that the connection does not establish creating
confusion for users since the service is running and a socket shows in
ss output. Fix by requiring an exact dif to sk_bound_dev_if match if the
skb came through an interface enslaved to an l3mdev device and the
tcp_l3mdev_accept is not set.

skb's through an l3mdev interface are marked by setting a flag in
inet{6}_skb_parm. The IPv6 variant is already set; this patch adds the
flag for IPv4. Using an skb flag avoids a device lookup on the dif. The
flag is set in the VRF driver using the IP{6}CB macros. For IPv4, the
inet_skb_parm struct is moved in the cb per commit 971f10eca186, so the
match function in the TCP stack needs to use TCP_SKB_CB. For IPv6, the
move is done after the socket lookup, so IP6CB is used.

The flags field in inet_skb_parm struct needs to be increased to add
another flag. There is currently a 1-byte hole following the flags,
so it can be expanded to u16 without increasing the size of the struct.

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- changed the match functions to pull the skb flag from TCP_SKB_CB
  rather than IPCB for IPv4 per changes from 971f10eca186. match
  function is moved to tcp.h as a consequence.
- made flags a u16 versus __u16 for consistency with frag_max_size
- updated commit message

v2
- reordered the checks in inet_exact_dif_match per Eric's comment
- changed the l3mdev determination from looking up the dif to using
  a flag set on the skb which is much faster

 drivers/net/vrf.c           |  2 ++
 include/linux/ipv6.h        | 11 +++++++++++
 include/net/ip.h            |  8 +++++++-
 include/net/tcp.h           | 11 +++++++++++
 net/ipv4/inet_hashtables.c  |  8 +++++---
 net/ipv6/inet6_hashtables.c |  7 ++++---
 6 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 85c271c70d42..820de6a9ddde 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -956,6 +956,7 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 	if (skb->pkt_type == PACKET_LOOPBACK) {
 		skb->dev = vrf_dev;
 		skb->skb_iif = vrf_dev->ifindex;
+		IP6CB(skb)->flags |= IP6SKB_L3SLAVE;
 		skb->pkt_type = PACKET_HOST;
 		goto out;
 	}
@@ -996,6 +997,7 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 {
 	skb->dev = vrf_dev;
 	skb->skb_iif = vrf_dev->ifindex;
+	IPCB(skb)->flags |= IPSKB_L3SLAVE;
 
 	/* loopback traffic; do not push through packet taps again.
 	 * Reset pkt_type for upper layers to process skb
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7e9a789be5e0..c0644e5f603a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -144,6 +144,17 @@ static inline int inet6_iif(const struct sk_buff *skb)
 	return l3_slave ? skb->skb_iif : IP6CB(skb)->iif;
 }
 
+/* can not be used in TCP layer after tcp_v6_fill_cb */
+static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
+{
+#if defined(CONFIG_NET_L3_MASTER_DEV)
+	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
+	    skb_l3mdev_slave(IP6CB(skb)->flags))
+		return true;
+#endif
+	return false;
+}
+
 struct tcp6_request_sock {
 	struct tcp_request_sock	  tcp6rsk_tcp;
 };
diff --git a/include/net/ip.h b/include/net/ip.h
index bc43c0fcae12..64d05d976b22 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -38,7 +38,7 @@ struct sock;
 struct inet_skb_parm {
 	int			iif;
 	struct ip_options	opt;		/* Compiled IP options		*/
-	unsigned char		flags;
+	u16			flags;
 
 #define IPSKB_FORWARDED		BIT(0)
 #define IPSKB_XFRM_TUNNEL_SIZE	BIT(1)
@@ -48,10 +48,16 @@ struct inet_skb_parm {
 #define IPSKB_DOREDIRECT	BIT(5)
 #define IPSKB_FRAG_PMTU		BIT(6)
 #define IPSKB_FRAG_SEGS		BIT(7)
+#define IPSKB_L3SLAVE		BIT(8)
 
 	u16			frag_max_size;
 };
 
+static inline bool skb_l3mdev_slave4(u16 flags)
+{
+	return !!(flags & IPSKB_L3SLAVE);
+}
+
 static inline unsigned int ip_hdrlen(const struct sk_buff *skb)
 {
 	return ip_hdr(skb)->ihl * 4;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f83b7f220a65..5c7bb59dc331 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -800,6 +800,17 @@ static inline int tcp_v6_iif(const struct sk_buff *skb)
 }
 #endif
 
+/* TCP_SKB_CB reference means this can not be used from early demux */
+static inline bool inet_exact_dif_match(struct net *net, struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
+	    skb_l3mdev_slave4(TCP_SKB_CB(skb)->header.h4.flags))
+		return true;
+#endif
+	return false;
+}
+
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 77c20a489218..ca97835bfec4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -25,6 +25,7 @@
 #include <net/inet_hashtables.h>
 #include <net/secure_seq.h>
 #include <net/ip.h>
+#include <net/tcp.h>
 #include <net/sock_reuseport.h>
 
 static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
@@ -172,7 +173,7 @@ EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum, const __be32 daddr,
-				const int dif)
+				const int dif, bool exact_dif)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
@@ -186,7 +187,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
-		if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if || exact_dif) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
 			score += 4;
@@ -215,11 +216,12 @@ struct sock *__inet_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
+	bool exact_dif = inet_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
 	sk_for_each_rcu(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif);
+		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 00cf28ad4565..2fd0374a35b1 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -96,7 +96,7 @@ EXPORT_SYMBOL(__inet6_lookup_established);
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum,
 				const struct in6_addr *daddr,
-				const int dif)
+				const int dif, bool exact_dif)
 {
 	int score = -1;
 
@@ -109,7 +109,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
-		if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if || exact_dif) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
 			score++;
@@ -131,11 +131,12 @@ struct sock *inet6_lookup_listener(struct net *net,
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
+	bool exact_dif = inet6_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
 	sk_for_each(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif);
+		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-- 
2.1.4
