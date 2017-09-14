From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: ipv4: fix l3slave check for index returned in IP_PKTINFO
Date: Wed, 13 Sep 2017 17:11:37 -0700
Message-ID: <1505347897-27422-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37010 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdINALq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 20:11:46 -0400
Received: by mail-pg0-f66.google.com with SMTP id v5so807230pgn.4
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 17:11:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_iif is only set to the actual egress device for the output path. The
recent change to consider the l3slave flag when returning IP_PKTINFO
works for local traffic (the correct device index is returned), but it
broke the more typical use case of packets received from a remote host
always returning the VRF index rather than the original ingress device.
Update the fixup to consider l3slave and rt_iif actually getting set.

Fixes: 1dfa76390bf05 ("net: ipv4: add check for l3slave for index returned in IP_PKTINFO")
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/ip_sockglue.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e558e4f9597b..a599aa83fdad 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1207,7 +1207,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
-	bool l3slave = ipv4_l3mdev_skb(IPCB(skb)->flags);
 	bool prepare = (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) ||
 		       ipv6_sk_rxinfo(sk);
 
@@ -1221,8 +1220,13 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		 * (e.g., process binds socket to eth0 for Tx which is
 		 * redirected to loopback in the rtable/dst).
 		 */
-		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX || l3slave)
+		struct rtable *rt = skb_rtable(skb);
+		bool l3slave = ipv4_l3mdev_skb(IPCB(skb)->flags);
+
+		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX)
 			pktinfo->ipi_ifindex = inet_iif(skb);
+		else if (l3slave && rt && rt->rt_iif)
+			pktinfo->ipi_ifindex = rt->rt_iif;
 
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
-- 
2.1.4
