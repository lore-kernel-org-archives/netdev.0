From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [Resent] [PATCH 1/2] udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
Date: Mon, 03 Nov 2008 10:11:01 +0800
Message-ID: <490E5DB5.4020407@cn.fujitsu.com>
References: <490C1CA7.3070201@cn.fujitsu.com> <20081101.213529.60503932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54905 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754124AbYKCCPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 21:15:15 -0500
In-Reply-To: <20081101.213529.60503932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If UDP echo is sent to xinetd/echo-dgram, the UDP reply will be received
at the sender. But the SNMP counter of UDP_MIB_INDATAGRAMS will be not
increased, UDP6_MIB_INDATAGRAMS will be increased instead.

  Endpoint A                      Endpoint B
  UDP Echo request ----------->
  (IPv4, Dst port=7)
                   <----------    UDP Echo Reply
                                  (IPv4, Src port=7)

This bug is come from this patch cb75994ec311b2cd50e5205efdcc0696abd6675d.

It do counter UDP[6]_MIB_INDATAGRAMS until udp[v6]_recvmsg. Because
xinetd used IPv6 socket to receive UDP messages, thus, when received
UDP packet, the UDP6_MIB_INDATAGRAMS will be increased in function
udpv6_recvmsg() even if the packet is a IPv4 UDP packet.

This patch fixed the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/udp.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e51da8c..1a63809 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -138,6 +138,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
+	int is_udp4;
 
 	if (addr_len)
 		*addr_len=sizeof(struct sockaddr_in6);
@@ -158,6 +159,8 @@ try_again:
 	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
+	is_udp4 = (skb->protocol == htons(ETH_P_IP));
+
 	/*
 	 * If checksum is needed at all, try to do it while copying the
 	 * data.  If the data is truncated, or if we only want a partial
@@ -180,9 +183,14 @@ try_again:
 	if (err)
 		goto out_free;
 
-	if (!peeked)
-		UDP6_INC_STATS_USER(sock_net(sk),
-				UDP_MIB_INDATAGRAMS, is_udplite);
+	if (!peeked) {
+		if (is_udp4)
+			UDP_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_INDATAGRAMS, is_udplite);
+		else
+			UDP6_INC_STATS_USER(sock_net(sk),
+					UDP_MIB_INDATAGRAMS, is_udplite);
+	}
 
 	sock_recv_timestamp(msg, sk, skb);
 
@@ -196,7 +204,7 @@ try_again:
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = 0;
 
-		if (skb->protocol == htons(ETH_P_IP))
+		if (is_udp4)
 			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
 				      htonl(0xffff), ip_hdr(skb)->saddr);
 		else {
@@ -207,7 +215,7 @@ try_again:
 		}
 
 	}
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (is_udp4) {
 		if (inet->cmsg_flags)
 			ip_cmsg_recv(msg, skb);
 	} else {
-- 
1.5.3.8



