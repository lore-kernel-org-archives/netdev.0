From: roy.qing.li@gmail.com
Subject: [PATCH] openvswitch: fix a use after free
Date: Thu, 16 Oct 2014 17:01:15 +0800
Message-ID: <1413450075-5044-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36400 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaJPJBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 05:01:21 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so3061244pad.31
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 02:01:21 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id zn2sm19133454pbb.41.2014.10.16.02.01.19
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 02:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() called by arphdr_ok can change skb->data, so put the arp
setting after arphdr_ok to avoid the use the freed memory

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/openvswitch/flow.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 62db02b..b13ba5e 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -557,10 +557,11 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	} else if (key->eth.type == htons(ETH_P_ARP) ||
 		   key->eth.type == htons(ETH_P_RARP)) {
 		struct arp_eth_header *arp;
+		bool arp_t = arphdr_ok(skb);
 
 		arp = (struct arp_eth_header *)skb_network_header(skb);
 
-		if (arphdr_ok(skb) &&
+		if (arp_t &&
 		    arp->ar_hrd == htons(ARPHRD_ETHER) &&
 		    arp->ar_pro == htons(ETH_P_IP) &&
 		    arp->ar_hln == ETH_ALEN &&
-- 
1.7.10.4
