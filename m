From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2] net: Require exact match for TCP socket lookups if dif is l3mdev
Date: Thu, 13 Oct 2016 21:47:39 -0700
Message-ID: <1476420459-20966-1-git-send-email-dsa@cumulusnetworks.com>
Cc: eric.dumazet@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32878 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752245AbcJNEr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 00:47:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id vu5so44168546pab.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 21:47:47 -0700 (PDT)
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

skb's through an l3mdev interface are marked by setting a flag in the
inet{6}_skb_parm. The IPv6 variant is already set. This patch adds the
flag for IPv4. Marking the skb avoids a device lookup on the dif.

The inet_skb_parm struct currently has a 1-byte hold following the
flags, so the flags is expanded to u16 without increasing the size of
the struct. This is needed to add another flag.

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- reordered the checks in inet_exact_dif_match per Eric's comment
- changed the l3mdev determination from looking up the dif to using
  a flag set on the skb which is much faster

 drivers/net/vrf.c           |  2 ++
 include/linux/ipv6.h        | 10 ++++++++++
 include/net/ip.h            | 13 ++++++++++++-
 net/ipv4/inet_hashtables.c  |  7 ++++---
 net/ipv6/inet6_hashtables.c |  7 ++++---
 5 files changed, 32 insertions(+), 7 deletions(-)

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
index 7e9a789be5e0..dd3bb34aac8b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -144,6 +144,16 @@ static inline int inet6_iif(const struct sk_buff *skb)
 	return l3_slave ? skb->skb_iif : IP6CB(skb)->iif;
 }
 
+static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
+	    IP6CB(skb)->flags & IP6SKB_L3SLAVE)
+		return true;
+#endif
+	return false;
+}
+
 struct tcp6_request_sock {
 	struct tcp_request_sock	  tcp6rsk_tcp;
 };
diff --git a/include/net/ip.h b/include/net/ip.h
index bc43c0fcae12..adeb9a2c9c16 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -38,7 +38,7 @@ struct sock;
 struct inet_skb_parm {
 	int			iif;
 	struct ip_options	opt;		/* Compiled IP options		*/
-	unsigned char		flags;
+	__u16			flags;
 
 #define IPSKB_FORWARDED		BIT(0)
 #define IPSKB_XFRM_TUNNEL_SIZE	BIT(1)
@@ -48,6 +48,7 @@ struct inet_skb_parm {
 #define IPSKB_DOREDIRECT	BIT(5)
 #define IPSKB_FRAG_PMTU		BIT(6)
 #define IPSKB_FRAG_SEGS		BIT(7)
+#define IPSKB_L3SLAVE		BIT(8)
 
 	u16			frag_max_size;
 };
@@ -71,6 +72,16 @@ struct ipcm_cookie {
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
 #define PKTINFO_SKB_CB(skb) ((struct in_pktinfo *)((skb)->cb))
 
+static inline bool inet_exact_dif_match(struct net *net, struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_L3_MASTER_DEV
+	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
+	    IPCB(skb)->flags & IPSKB_L3SLAVE)
+		return true;
+#endif
+	return false;
+}
+
 struct ip_ra_chain {
 	struct ip_ra_chain __rcu *next;
 	struct sock		*sk;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 77c20a489218..0d6b996fd801 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -172,7 +172,7 @@ EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum, const __be32 daddr,
-				const int dif)
+				const int dif, bool exact_dif)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
@@ -186,7 +186,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
-		if (sk->sk_bound_dev_if) {
+		if (sk->sk_bound_dev_if || exact_dif) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
 			score += 4;
@@ -215,11 +215,12 @@ struct sock *__inet_lookup_listener(struct net *net,
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
