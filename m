From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/2] net: ipv4: add check for l3slave for index returned in IP_PKTINFO
Date: Fri, 11 Aug 2017 17:11:15 -0700
Message-ID: <1502496675-13349-3-git-send-email-dsahern@gmail.com>
References: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35214 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdHLALX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 20:11:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id j68so4656998pfc.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 17:11:23 -0700 (PDT)
In-Reply-To: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the loopback device, for packets sent through a VRF device
the index returned in ipi_ifindex needs to be the saved index in
rt_iif.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/ip_sockglue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index dd68a9ed5e40..e558e4f9597b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1207,6 +1207,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
+	bool l3slave = ipv4_l3mdev_skb(IPCB(skb)->flags);
 	bool prepare = (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) ||
 		       ipv6_sk_rxinfo(sk);
 
@@ -1220,7 +1221,7 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		 * (e.g., process binds socket to eth0 for Tx which is
 		 * redirected to loopback in the rtable/dst).
 		 */
-		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX)
+		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX || l3slave)
 			pktinfo->ipi_ifindex = inet_iif(skb);
 
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
-- 
2.1.4
