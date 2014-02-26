From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 2/3] ipv4: yet another new IP_MTU_DISCOVER option IP_PMTUDISC_OMIT
Date: Wed, 26 Feb 2014 01:20:42 +0100
Message-ID: <1393374043-796-3-git-send-email-hannes@stressinduktion.org>
References: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
Cc: Florian Weimer <fweimer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52922 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaBZAUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 19:20:50 -0500
In-Reply-To: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP_PMTUDISC_INTERFACE has a design error: because it does not allow the
generation of fragments if the interface mtu is exceeded, it is very
hard to make use of this option in already deployed name server software
for which I introduced this option.

This patch adds yet another new IP_MTU_DISCOVER option to not honor any
path mtu information and not accepting new icmp notifications destined for
the socket this option is enabled on. But we allow outgoing fragmentation
in case the packet size exceeds the outgoing interface mtu.

As such this new option can be used as a drop-in replacement for
IP_PMTUDISC_DONT, which is currently in use by most name server software
making the adoption of this option very smooth and easy.

The original advantage of IP_PMTUDISC_INTERFACE is still maintained:
ignoring incoming path MTU updates and not honoring discovered path MTUs
in the output path.

Fixes: 482fc6094afad5 ("ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE")
Cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip.h        | 9 ++++++++-
 include/uapi/linux/in.h | 4 ++++
 net/ipv4/ip_output.c    | 9 +++------
 net/ipv4/ip_sockglue.c  | 2 +-
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 23be0fd..c060efe 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -266,7 +266,8 @@ int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 
 static inline bool ip_sk_accept_pmtu(const struct sock *sk)
 {
-	return inet_sk(sk)->pmtudisc != IP_PMTUDISC_INTERFACE;
+	return inet_sk(sk)->pmtudisc != IP_PMTUDISC_INTERFACE &&
+	       inet_sk(sk)->pmtudisc != IP_PMTUDISC_OMIT;
 }
 
 static inline bool ip_sk_use_pmtu(const struct sock *sk)
@@ -274,6 +275,12 @@ static inline bool ip_sk_use_pmtu(const struct sock *sk)
 	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
 }
 
+static inline bool ip_sk_local_df(const struct sock *sk)
+{
+	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_DO ||
+	       inet_sk(sk)->pmtudisc == IP_PMTUDISC_OMIT;
+}
+
 static inline unsigned int ip_dst_mtu_maybe_forward(const struct dst_entry *dst,
 						    bool forwarding)
 {
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 393c5de..c33a65e 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -120,6 +120,10 @@ struct in_addr {
  * this socket to prevent accepting spoofed ones.
  */
 #define IP_PMTUDISC_INTERFACE		4
+/* weaker version of IP_PMTUDISC_INTERFACE, which allos packets to get
+ * fragmented if they exeed the interface mtu
+ */
+#define IP_PMTUDISC_OMIT		5
 
 #define IP_MULTICAST_IF			32
 #define IP_MULTICAST_TTL 		33
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7cf80d2..1a0755f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -821,8 +821,7 @@ static int __ip_append_data(struct sock *sk,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
-			 mtu : 0xFFFF;
+	maxnonfragsize = ip_sk_local_df(sk) ? 0xFFFF : mtu;
 
 	if (cork->length + length > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1145,8 +1144,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
-			 mtu : 0xFFFF;
+	maxnonfragsize = ip_sk_local_df(sk) ? 0xFFFF : mtu;
 
 	if (cork->length + size > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1307,8 +1305,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc < IP_PMTUDISC_DO)
-		skb->local_df = 1;
+	skb->local_df = ip_sk_local_df(sk);
 
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 580dd96..9b98f74 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -626,7 +626,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->nodefrag = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_INTERFACE)
+		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_OMIT)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
-- 
1.8.5.3
