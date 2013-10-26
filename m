From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Sat, 26 Oct 2013 22:11:58 +0200
Message-ID: <20131026201158.GI15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59229 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab3JZUMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 16:12:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sockets marked with IP_PMTUDISC_INTERFACE won't do path mtu discovery,
their sockets won't accept and install new path mtu information and they
will always use the interface mtu for outgoing packets. It is guaranteed
that the packet is not fragmented locally. But we won't set the DF-Flag
on the outgoing frames.

Florian Weimer had the idea to use this flag to ensure DNS servers are
never generating outgoing fragments. They may well be fragmented on the
path, but the server never stores or usees path mtu values, which could
well be forged in an attack.

(The root of the problem with path MTU discovery is that there is
no reliable way to authenticate ICMP Fragmentation Needed But DF Set
messages because they are sent from intermediate routers with their
source addresses, and the IMCP payload will not always contain sufficient
information to identify a flow.)

Recent research in the DNS community showed that it is possible to
implement an attack where DNS cache poisoning is feasible by spoofing
fragments. This work was done by Amir Herzberg and Haya Shulman:
<https://sites.google.com/site/hayashulman/files/fragmentation-poisoning.pdf>

This issue was previously discussed among the DNS community, e.g.
<http://www.ietf.org/mail-archive/web/dnsext/current/msg01204.html>,
without leading to fixes.

This patch depends on the patch "ipv4: fix DO and PROBE pmtu mode
regarding local fragmentation with UFO/CORK" for the enforcement of the
non-fragmentable checks. If other users than ip_append_page/data should
use this semantic too, we have to add a new flag to IPCB(skb)->flags to
suppress local fragmentation and check for this in ip_finish_output.

Many thanks to Florian Weimer for the idea and feedback while implementing
this patch.

Suggested-by: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/route.h     | 16 ++++++++++++----
 include/uapi/linux/in.h |  5 +++++
 net/dccp/ipv4.c         |  1 +
 net/ipv4/ip_output.c    |  8 ++++----
 net/ipv4/ip_sockglue.c  |  2 +-
 net/ipv4/route.c        |  4 ++++
 net/ipv4/tcp_ipv4.c     |  1 +
 7 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index dd4ae00..f68c167 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -313,12 +313,20 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
-static inline int ip_skb_dst_mtu(struct sk_buff *skb)
+static inline bool ip_sk_accept_pmtu(const struct sock *sk)
 {
-	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
+	return inet_sk(sk)->pmtudisc != IP_PMTUDISC_INTERFACE;
+}
 
-	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
-	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
+static inline bool ip_sk_use_pmtu(const struct sock *sk)
+{
+	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
+}
+
+static inline int ip_skb_dst_mtu(const struct sk_buff *skb)
+{
+	return (!skb->sk || ip_sk_use_pmtu(skb->sk)) ?
+	       dst_mtu(skb_dst(skb)) : skb_dst(skb)->dev->mtu;
 }
 
 #endif	/* _ROUTE_H */
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index f9e8e49..393c5de 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -115,6 +115,11 @@ struct in_addr {
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
 #define IP_PMTUDISC_DO			2	/* Always DF		*/
 #define IP_PMTUDISC_PROBE		3       /* Ignore dst pmtu      */
+/* Always use interface mtu (ignores dst pmtu) but don't set DF flag.
+ * Also incoming ICMP frag_needed notifications will be ignored on
+ * this socket to prevent accepting spoofed ones.
+ */
+#define IP_PMTUDISC_INTERFACE		4
 
 #define IP_MULTICAST_IF			32
 #define IP_MULTICAST_TTL 		33
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 720c362..d9f65fc 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -174,6 +174,7 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 	mtu = dst_mtu(dst);
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
+	    ip_sk_accept_pmtu(sk) &&
 	    inet_csk(sk)->icsk_pmtu_cookie > mtu) {
 		dccp_sync_mss(sk, mtu);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 27dc1b3..88c270a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1037,7 +1037,6 @@ error:
 static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 			 struct ipcm_cookie *ipc, struct rtable **rtp)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_rcu *opt;
 	struct rtable *rt;
 
@@ -1063,8 +1062,8 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	 * We steal reference to this route, caller should not release it
 	 */
 	*rtp = NULL;
-	cork->fragsize = inet->pmtudisc == IP_PMTUDISC_PROBE ?
-			 rt->dst.dev->mtu : dst_mtu(&rt->dst);
+	cork->fragsize = ip_sk_use_pmtu(sk) ?
+			 dst_mtu(&rt->dst) : rt->dst.dev->mtu;
 	cork->dst = &rt->dst;
 	cork->length = 0;
 	cork->ttl = ipc->ttl;
@@ -1315,7 +1314,8 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
 	 * locally. */
-	if (inet->pmtudisc >= IP_PMTUDISC_DO ||
+	if (inet->pmtudisc == IP_PMTUDISC_DO ||
+	    inet->pmtudisc == IP_PMTUDISC_PROBE ||
 	    (skb->len <= dst_mtu(&rt->dst) &&
 	     ip_dont_fragment(sk, &rt->dst)))
 		df = htons(IP_DF);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 0626f2c..3f85826 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -627,7 +627,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->nodefrag = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
+		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_INTERFACE)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d2d3253..f428935 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1036,6 +1036,10 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	bool new = false;
 
 	bh_lock_sock(sk);
+
+	if (!ip_sk_accept_pmtu(sk))
+		goto out;
+
 	rt = (struct rtable *) __sk_dst_get(sk);
 
 	if (sock_owned_by_user(sk) || !rt) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 300ab2c..14bba8a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -288,6 +288,7 @@ static void tcp_v4_mtu_reduced(struct sock *sk)
 	mtu = dst_mtu(dst);
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
+	    ip_sk_accept_pmtu(sk) &&
 	    inet_csk(sk)->icsk_pmtu_cookie > mtu) {
 		tcp_sync_mss(sk, mtu);
 
-- 
1.8.3.1
