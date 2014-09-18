From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] tg3: Work around HW/FW limitations with vlan encapsulated frames
Date: Thu, 18 Sep 2014 10:31:17 -0400
Message-ID: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:62179 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755682AbaIROb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 10:31:27 -0400
Received: by mail-qg0-f51.google.com with SMTP id e89so1186387qgf.24
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 07:31:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TG3 appears to have an issue performing TSO and checksum offloading
correclty when the frame has been vlan encapsulated (non-accelrated).
In these cases, tcp checksum is not correctly updated.

This patch attempts to work around this issue.  After the patch,
802.1ad vlans start working correctly over tg3 devices.

CC: Prashant Sreedharan <prashant@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cb77ae9..e7d3a62 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7914,8 +7914,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	entry = tnapi->tx_prod;
 	base_flags = 0;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
@@ -7929,6 +7927,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb) - ETH_HLEN;
 
+		/* HW/FW can not correctly segment packets that have been
+		 * vlan encapsulated.
+		 */
+		if (skb->protocol == htons(ETH_P_8021Q) ||
+		    skb->protocol == htons(ETH_P_8021AD))
+			return tg3_tso_bug(tp, tnapi, txq, skb);
+
 		if (!skb_is_gso_v6(skb)) {
 			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			    tg3_flag(tp, TSO_BUG))
@@ -7979,6 +7984,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				base_flags |= tsflags << 12;
 			}
 		}
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		/* HW/FW can not correctly checksum packets that have been
+		 * vlan encapsulated.
+		 */
+		if (skb->protocol == htons(ETH_P_8021Q) ||
+		    skb->protocol == htons(ETH_P_8021AD)) {
+			if (skb_checksum_help(skb))
+				goto drop;
+		} else  {
+			base_flags |= TXD_FLAG_TCPUDP_CSUM;
+		}
 	}
 
 	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
-- 
1.9.3
