From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/3] [SNMP]: Defer InDataGrams increment until recvmsg() does
 checksum
Date: Fri, 30 Nov 2007 11:09:28 +0800
Message-ID: <474F7EE8.2040009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andi@firstfloor.org,
	Wang Chen <wangchen@cn.fujitsu.com>, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:51546 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1761711AbXK3DMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 22:12:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From:  Wang Chen <wangchen@cn.fujitsu.com>

Thanks dave, herbert, gerrit, andi and other people for your
discussion about this problem.

UdpInDatagrams can be confusing because it counts packets that 
might be dropped later.
Move UdpInDatagrams into recvmsg() as allowed by the RFC.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 Documentation/networking/udplite.txt |    2 +-
 net/ipv4/udp.c                       |    7 +++----
 net/ipv6/udp.c                       |    4 +++-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff -Nurp linux-2.6.24.rc3.org/Documentation/networking/udplite.txt linux-2.6.24.rc3/Documentation/networking/udplite.txt
--- linux-2.6.24.rc3.org/Documentation/networking/udplite.txt	2007-11-19 12:37:40.000000000 +0800
+++ linux-2.6.24.rc3/Documentation/networking/udplite.txt	2007-11-30 09:43:08.000000000 +0800
@@ -236,7 +236,7 @@
 
   This displays UDP-Lite statistics variables, whose meaning is as follows.
 
-   InDatagrams:     Total number of received datagrams.
+   InDatagrams:     The total number of datagrams delivered to users.
 
    NoPorts:         Number of packets received to an unknown port.
                     These cases are counted separately (not as InErrors).
diff -Nurp linux-2.6.24.rc3.org/net/ipv4/udp.c linux-2.6.24.rc3/net/ipv4/udp.c
--- linux-2.6.24.rc3.org/net/ipv4/udp.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv4/udp.c	2007-11-30 09:48:21.000000000 +0800
@@ -873,6 +873,8 @@ try_again:
 	if (err)
 		goto out_free;
 
+	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
@@ -966,10 +968,8 @@ int udp_queue_rcv_skb(struct sock * sk, 
 			int ret;
 
 			ret = (*up->encap_rcv)(sk, skb);
-			if (ret <= 0) {
-				UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+			if (ret <= 0)
 				return -ret;
-			}
 		}
 
 		/* FALLTHROUGH -- it's a UDP Packet */
@@ -1023,7 +1023,6 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
 
 drop:
diff -Nurp linux-2.6.24.rc3.org/net/ipv6/udp.c linux-2.6.24.rc3/net/ipv6/udp.c
--- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-11-30 09:52:52.000000000 +0800
@@ -164,6 +164,8 @@ try_again:
 	if (err)
 		goto out_free;
 
+	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
@@ -292,7 +294,7 @@ int udpv6_queue_rcv_skb(struct sock * sk
 			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
 		goto drop;
 	}
-	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+
 	return 0;
 drop:
 	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);

