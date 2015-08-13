From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/11] udp: Handle VRF device in sendmsg
Date: Thu, 13 Aug 2015 14:59:03 -0600
Message-ID: <1439499551-90231-5-git-send-email-dsa@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35228 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbbHMU76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 16:59:58 -0400
Received: by iodt126 with SMTP id t126so65746832iod.2
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 13:59:57 -0700 (PDT)
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For unconnected UDP sockets using a VRF device lookup source address
based on VRF table. This allows the UDP header to be properly setup
before showing up at the VRF device via the dst.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/udp.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604f9273..7af5052e3b1f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1013,11 +1013,31 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	if (!rt) {
 		struct net *net = sock_net(sk);
+		__u8 flow_flags = inet_sk_flowi_flags(sk);
 
 		fl4 = &fl4_stack;
+
+		/* unconnected socket. If output device is enslaved to a VRF
+		 * device lookup source address from VRF table. This mimics
+		 * behavior of ip_route_connect{_init}.
+		 */
+		if (netif_index_is_vrf(net, ipc.oif)) {
+			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
+					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+					   (flow_flags | FLOWI_FLAG_VRFSRC),
+					   faddr, saddr, dport,
+					   inet->inet_sport);
+
+			rt = ip_route_output_flow(net, fl4, sk);
+			if (!IS_ERR(rt)) {
+				saddr = fl4->saddr;
+				ip_rt_put(rt);
+			}
+		}
+
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-				   inet_sk_flowi_flags(sk),
+				   flow_flags,
 				   faddr, saddr, dport, inet->inet_sport);
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-- 
2.3.2 (Apple Git-55)
