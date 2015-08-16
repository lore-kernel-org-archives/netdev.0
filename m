From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Move VRF change to udp_sendmsg to inlined function
Date: Sat, 15 Aug 2015 18:11:59 -0600
Message-ID: <1439683919-3066-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34661 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbHPAMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 20:12:06 -0400
Received: by iodb91 with SMTP id b91so117567359iod.1
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 17:12:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functionally equivalent, but as an inlined function with VRF config
check it completely compiles out if VRF is not enabled.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/udp.c | 44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7f359f..384f8d918033 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -873,6 +873,27 @@ int udp_push_pending_frames(struct sock *sk)
 }
 EXPORT_SYMBOL(udp_push_pending_frames);
 
+/* unconnected socket. If output device is enslaved to a VRF
+ * device lookup source address from VRF table. This mimics
+ * behavior of ip_route_connect{_init}.
+ */
+static inline void udp_sendmsg_vrf_saddr(struct net *net, struct flowi4 *fl4,
+					 int oif, struct sock *sk)
+{
+#if IS_ENABLED(CONFIG_NET_VRF)
+	if (netif_index_is_vrf(net, oif)) {
+		__u8 flow_flags = fl4->flowi4_flags;
+		struct rtable *rt;
+
+		fl4->flowi4_flags = flow_flags | FLOWI_FLAG_VRFSRC;
+		rt = ip_route_output_flow(net, fl4, sk);
+		if (!IS_ERR(rt))
+			ip_rt_put(rt);
+		fl4->flowi4_flags = flow_flags;
+	}
+#endif
+}
+
 int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1013,33 +1034,16 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	if (!rt) {
 		struct net *net = sock_net(sk);
-		__u8 flow_flags = inet_sk_flowi_flags(sk);
 
 		fl4 = &fl4_stack;
 
-		/* unconnected socket. If output device is enslaved to a VRF
-		 * device lookup source address from VRF table. This mimics
-		 * behavior of ip_route_connect{_init}.
-		 */
-		if (netif_index_is_vrf(net, ipc.oif)) {
-			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
-					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_VRFSRC),
-					   faddr, saddr, dport,
-					   inet->inet_sport);
-
-			rt = ip_route_output_flow(net, fl4, sk);
-			if (!IS_ERR(rt)) {
-				saddr = fl4->saddr;
-				ip_rt_put(rt);
-			}
-		}
-
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-				   flow_flags,
+				   inet_sk_flowi_flags(sk),
 				   faddr, saddr, dport, inet->inet_sport);
 
+		udp_sendmsg_vrf_saddr(net, fl4, ipc.oif, sk);
+
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
 		if (IS_ERR(rt)) {
-- 
2.3.2 (Apple Git-55)
