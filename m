From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] ethernet: add sanity check before memory dereferencing
Date: Tue,  4 May 2010 11:33:48 +0800
Message-ID: <1272944028-23410-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:34100 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab0EDEBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 00:01:04 -0400
Received: by iwn40 with SMTP id 40so4330323iwn.1
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 21:01:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add sanity check before memory dereferencing

Some callers of eth_type_trans() only can assure the length of the packets
passed to it is not less than ETH_HLEN. We'd better check the packets length
before dereferencing skb->data.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ethernet/eth.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 61ec032..215c839 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -158,7 +158,6 @@ EXPORT_SYMBOL(eth_rebuild_header);
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ethhdr *eth;
-	unsigned char *rawp;
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
@@ -199,15 +198,13 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
 
-	rawp = skb->data;
-
 	/*
 	 *      This is a magic hack to spot IPX packets. Older Novell breaks
 	 *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
 	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
 	 *      won't work for fault tolerant netware but does for the rest.
 	 */
-	if (*(unsigned short *)rawp == 0xFFFF)
+	if (skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF)
 		return htons(ETH_P_802_3);
 
 	/*
