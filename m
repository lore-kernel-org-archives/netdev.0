From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 1/3] tg3: Don't modify ip header fields when doing GSO
Date: Sun, 11 May 2014 20:22:53 -0700
Message-ID: <1399864975-29070-2-git-send-email-mchan@broadcom.com>
References: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <prashant@broadcom.com>,
	<ivecera@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:6585 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbaELCCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 22:02:17 -0400
In-Reply-To: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3 uses GSO as workaround if the hardware cannot perform TSO on certain
packets.  We should not modify the ip header fields if we do GSO on the
packet.  It happens to work by accident because GSO recalculates the IP
checksum and IP total length.

Also fix the tg3_start_xmit comment to reflect that this is the only
xmit function for all devices.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e5d95c5..bdfd08b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7871,9 +7871,7 @@ tg3_tso_bug_end:
 	return NETDEV_TX_OK;
 }
 
-/* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
- * support TG3_FLAG_HW_TSO_1 or firmware TSO only.
- */
+/* hard_start_xmit for all devices */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -7927,14 +7925,14 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb) - ETH_HLEN;
 
 		if (!skb_is_gso_v6(skb)) {
+			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
+			    tg3_flag(tp, TSO_BUG))
+				return tg3_tso_bug(tp, skb);
+
 			iph->check = 0;
 			iph->tot_len = htons(mss + hdr_len);
 		}
 
-		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-		    tg3_flag(tp, TSO_BUG))
-			return tg3_tso_bug(tp, skb);
-
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-- 
1.7.1
