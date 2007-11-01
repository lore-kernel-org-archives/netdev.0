From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv6] SNMP: Restore Udp6InErrors incrementation
Date: Thu, 1 Nov 2007 22:46:38 +0900
Message-ID: <20071101224638.b954a697.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38148 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbXKANqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 09:46:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1DkhVQ010012
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:46:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1DkhOp133644
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:46:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1Dkhsv006988
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:46:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the checksum verification is postponed till user calls recv or poll,
the inrementation of Udp6InErrors counter should be also postponed.
Currently, it is postponed in non-blocking operation case. However it
should be postponed in all case like the IPv4 code.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv6/udp.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index caebad6..8344d8c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -205,12 +205,11 @@ out:
 	return err;
 
 csum_copy_err:
+	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
 	skb_kill_datagram(sk, skb, flags);
 
-	if (flags & MSG_DONTWAIT) {
-		UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
-	}
 	goto try_again;
 }
 
-- 
1.5.3.4

