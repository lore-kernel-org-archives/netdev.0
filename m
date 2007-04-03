From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPv6] Exclude truncated packets from InHdrErrors
 statistics
Date: Tue, 3 Apr 2007 15:55:51 +0900
Message-ID: <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33576 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282AbXDCHdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 03:33:02 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l337X1aT026300
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2007 03:33:01 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l337X1mR155712
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2007 01:33:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l337X1xa029939
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2007 01:33:01 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Incoming trancated packets are counted as not only InTruncatedPkts but
also InHdrErrors. They should be counted as InTruncatedPkts only.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv6/ip6_input.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f225fa1..be0ee8a 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -108,8 +108,10 @@ int ipv6_rcv(struct sk_buff *skb, struct
 
 	/* pkt_len may be zero if Jumbo payload option is present */
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
-		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
-			goto truncated;
+		if (pkt_len + sizeof(struct ipv6hdr) > skb->len) {
+			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INTRUNCATEDPKTS);
+			goto drop;
+		}
 		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr))) {
 			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
 			goto drop;
@@ -128,8 +130,6 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	rcu_read_unlock();
 
 	return NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
-truncated:
-	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INTRUNCATEDPKTS);
 err:
 	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
 drop:
-- 
1.4.3.4

