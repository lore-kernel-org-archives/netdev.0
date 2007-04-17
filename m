From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 4/6] [IPV4] SNMP: Support InMcastPkts and InBcastPkts
Date: Tue, 17 Apr 2007 20:13:56 +0900
Message-ID: <20070417201356.024b764d.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:53475 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698AbXDQLOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:14:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HADDSc015819
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 06:13:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBE6cm543184
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBDxvU027883
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:00 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A received IP multicast datagram should be counted as InMcastPkts.
By the same token, a received IP broadcast datagram should be
counted as InBcastPkts.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/ip_input.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index c8c455d..9706939 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -329,6 +329,7 @@ drop:
 static inline int ip_rcv_finish(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt;
 
 	/*
 	 *	Initialise the virtual path cache for the packet. It describes
@@ -360,6 +361,12 @@ static inline int ip_rcv_finish(struct s
 	if (iph->ihl > 5 && ip_rcv_options(skb))
 		goto drop;
 
+	rt = (struct rtable*)skb->dst;
+	if (rt->rt_type == RTN_MULTICAST)
+		IP_INC_STATS_BH(IPSTATS_MIB_INMCASTPKTS);
+	else if (rt->rt_type == RTN_BROADCAST)
+		IP_INC_STATS_BH(IPSTATS_MIB_INBCASTPKTS);
+
 	return dst_input(skb);
 
 drop:
-- 
1.4.3.4

