From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 3/6] [IPV4] SNMP: Support InTruncatedPkts
Date: Tue, 17 Apr 2007 20:13:37 +0900
Message-ID: <20070417201337.3d48b86a.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39331 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753686AbXDQLNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:13:47 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HBDk32007443
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:46 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBDk3I525310
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:46 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBDhcO027426
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:43 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An IP datagram which is being discarded because the datagram frame
didn't carry enough data should be counted as InTruncatedPkts.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/ip_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 63ab523..c8c455d 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -416,7 +416,10 @@ int ip_rcv(struct sk_buff *skb, struct n
 		goto inhdr_error;
 
 	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < (iph->ihl*4))
+	if (skb->len < len) {
+		IP_INC_STATS_BH(IPSTATS_MIB_INTRUNCATEDPKTS);
+		goto drop;
+	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
 
 	/* Our transport medium may have padded the buffer out. Now we know it
-- 
1.4.3.4

