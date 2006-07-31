From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 04:51:14 -0400
Message-ID: <1154335874.3194.3.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:50321 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1750863AbWGaICV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 04:02:21 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I send a UDP datagrams with checksum error to target, I found that:
Under IPv6, counter udpInErrors increased, but under IPv4 counter
udpInDatagrams increased. I lookup into the source code, and found that,
under IPv4 UDP datagrams with checksum error will be delivered to UDP
receive queue, but IPv6 does not. IPv4 delivered into UDP receive queue,
increased udpInDatagrams, then discard it before delivered to UDP user.
RFC said udpInDatagrams is the total number of UDP datagrams delivered
to UDP users, so udpInDatagrams should not be increased while UDP
datagrams with checksum error received.

Refer to RFC2013:
  udpInDatagrams OBJECT-TYPE
      SYNTAX      Counter32
      MAX-ACCESS  read-only
      STATUS      current
      DESCRIPTION
              "The total number of UDP datagrams delivered to UDP
users."
      ::= { udp 1 }

Following is my patch:

--- a/net/ipv4/udp.c	2006-07-31 09:33:45.392479344 -0400
+++ b/net/ipv4/udp.c	2006-07-31 09:34:26.430240656 -0400
@@ -1018,7 +1018,7 @@ static int udp_queue_rcv_skb(struct sock
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
 
-	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if (__udp_checksum_complete(skb)) {
 			UDP_INC_STATS_BH(UDP_MIB_INERRORS);
 			kfree_skb(skb);

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>


