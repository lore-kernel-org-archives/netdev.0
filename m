From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 4/7] inet: split syncookie keys for ipv4 and ipv6 and initialize with net_get_random_once
Date: Fri, 27 Sep 2013 01:32:20 +0200
Message-ID: <1380238343-4318-5-git-send-email-hannes@stressinduktion.org>
References: <1380238343-4318-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54007 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3IZXcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 19:32:35 -0400
In-Reply-To: <1380238343-4318-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the secret key for syncookies for ipv4 and ipv6 and
initializes them with net_get_random_once. This change was the reason I
did this series. I think the initialization of the syncookie_secret is
way to early.

Cc: Florian Westphal <fw@strlen.de>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/tcp.h     |  1 -
 net/ipv4/syncookies.c | 15 +++++----------
 net/ipv6/syncookies.c | 12 +++++++++---
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index de870ee..9299560 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -475,7 +475,6 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 15e0241..22f5409 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -25,15 +25,7 @@
 
 extern int sysctl_tcp_syncookies;
 
-__u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
-EXPORT_SYMBOL(syncookie_secret);
-
-static __init int init_syncookies(void)
-{
-	get_random_bytes(syncookie_secret, sizeof(syncookie_secret));
-	return 0;
-}
-__initcall(init_syncookies);
+static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
@@ -44,8 +36,11 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
+	__u32 *tmp;
+
+	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));
 
+	tmp  = __get_cpu_var(ipv4_cookie_scratch);
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d703218..413eb7c 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -24,6 +24,8 @@
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
+static u32 syncookie6_secret[2][16-4+SHA_DIGEST_WORDS];
+
 /* RFC 2460, Section 8.3:
  * [ipv6 tcp] MSS must be computed as the maximum packet size minus 60 [..]
  *
@@ -61,14 +63,18 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
+	__u32 *tmp;
+
+	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));
+
+	tmp  = __get_cpu_var(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
-	 * 192 bits required for sha_transform, from the syncookie_secret
+	 * 192 bits required for sha_transform, from the syncookie6_secret
 	 * and overwrite the digest with the secret
 	 */
-	memcpy(tmp + 10, syncookie_secret[c], 44);
+	memcpy(tmp + 10, syncookie6_secret[c], 44);
 	memcpy(tmp, saddr, 16);
 	memcpy(tmp + 4, daddr, 16);
 	tmp[8] = ((__force u32)sport << 16) + (__force u32)dport;
-- 
1.8.3.1
