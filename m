From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: eth_type_trans() should use
 skb_header_pointer()
Date: Thu, 16 Jan 2014 15:03:31 -0800
Message-ID: <1389913411.31367.430.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389743541.31367.279.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389745269.2025.228.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f181.google.com ([209.85.161.181]:54074 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaAPXDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:03:35 -0500
Received: by mail-gg0-f181.google.com with SMTP id 21so1078781ggh.40
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 15:03:34 -0800 (PST)
In-Reply-To: <1389745269.2025.228.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

eth_type_trans() can read uninitialized memory as drivers
do not necessarily pull more than 14 bytes in skb->head before
calling it.

As David suggested, we can use skb_header_pointer() to
fix this without breaking some drivers that might not expect
eth_type_trans() pulling 2 additional bytes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
Since this bug is very old, I cooked the patch on net-next

 net/ethernet/eth.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8f032bae60ad..5dc638cad2e1 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -156,7 +156,9 @@ EXPORT_SYMBOL(eth_rebuild_header);
  */
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ethhdr *eth;
+	unsigned short _service_access_point;
+	const unsigned short *sap;
+	const struct ethhdr *eth;
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
@@ -194,7 +196,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
 	 *      won't work for fault tolerant netware but does for the rest.
 	 */
-	if (unlikely(skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF))
+	sap = skb_header_pointer(skb, 0, sizeof(*sap), &_service_access_point);
+	if (sap && *sap == 0xFFFF)
 		return htons(ETH_P_802_3);
 
 	/*
