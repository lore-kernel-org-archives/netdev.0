From: roy.qing.li@gmail.com
Subject: [PATCH] openvswitch: fix a use after free
Date: Fri, 17 Oct 2014 14:03:08 +0800
Message-ID: <1413525788-2272-1-git-send-email-roy.qing.li@gmail.com>
Cc: edumazet@google.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40868 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbaJQGDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 02:03:14 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so192216pac.21
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 23:03:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() called by arphdr_ok can change skb->data, so put the arp
setting after arphdr_ok to avoid the use the freed memory

Fixes: 0714812134d7d ("openvswitch: Eliminate memset() from flow_extract.")
Cc: Jesse Gross <jesse@nicira.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/openvswitch/flow.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 62db02b..c5cfc72 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -557,10 +557,11 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	} else if (key->eth.type == htons(ETH_P_ARP) ||
 		   key->eth.type == htons(ETH_P_RARP)) {
 		struct arp_eth_header *arp;
+		bool arp_available = arphdr_ok(skb);
 
 		arp = (struct arp_eth_header *)skb_network_header(skb);
 
-		if (arphdr_ok(skb) &&
+		if (arp_available &&
 		    arp->ar_hrd == htons(ARPHRD_ETHER) &&
 		    arp->ar_pro == htons(ETH_P_IP) &&
 		    arp->ar_hln == ETH_ALEN &&
-- 
1.7.10.4
