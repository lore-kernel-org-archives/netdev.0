From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Move VRF change to udp_sendmsg to function
Date: Tue, 18 Aug 2015 09:38:29 -0600
Message-ID: <1439912309-5726-1-git-send-email-dsa@cumulusnetworks.com>
Cc: tom@herbertland.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34474 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbbHRPjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 11:39:13 -0400
Received: by iodb91 with SMTP id b91so193121364iod.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 08:39:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functionally equivalent, but as a separate function with VRF config
check. After 2f52bdcf6ba ("net: Updates to netif_index_is_vrf") function
completely compiles out if VRF is not enabled; additional CONFIG
check is not needed.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- removed inline per Dave's comment
- removed IS_ENABLED(CONFIG_NET_VRF) check; no longer needed after 2f52bdcf6ba

 net/ipv4/udp.c | 43 +++++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7f359f..76c5e5e945f8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -873,6 +873,24 @@ int udp_push_pending_frames(struct sock *sk)
 }
 EXPORT_SYMBOL(udp_push_pending_frames);
 
+/* unconnected socket. If output device is enslaved to a VRF
+ * device lookup source address from VRF table.
+ */
+static void udp_sendmsg_vrf_saddr(struct net *net, struct flowi4 *fl4,
+				   int oif, struct sock *sk)
+{
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
+}
+
 int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1013,33 +1033,16 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
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
