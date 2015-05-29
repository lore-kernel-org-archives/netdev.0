From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/3] net: systemport: Add a check for oversized packets
Date: Fri, 29 May 2015 09:42:17 -0700
Message-ID: <1432917737-16793-4-git-send-email-f.fainelli@gmail.com>
References: <1432917737-16793-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36595 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948AbbE2QuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:50:13 -0400
Received: by pacux9 with SMTP id ux9so22757105pac.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 09:50:12 -0700 (PDT)
In-Reply-To: <1432917737-16793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Occasionnaly we may get oversized packets from the hardware which exceed
the nomimal 2KiB buffer size we allocate SKBs with. Add an early check
which drops the packet to avoid invoking skb_over_panic() and move on to
processing the next packet.

Reviewed-by: Petri Gynther <pgynther@google.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 62ea403e15b8..bbd8676a9675 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -632,6 +632,14 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 			  p_index, priv->rx_c_index, priv->rx_read_ptr,
 			  len, status);
 
+		if (unlikely(len > RX_BUF_LENGTH)) {
+			netif_err(priv, rx_status, ndev, "oversized packet\n");
+			ndev->stats.rx_length_errors++;
+			ndev->stats.rx_errors++;
+			dev_kfree_skb_any(skb);
+			goto next;
+		}
+
 		if (unlikely(!(status & DESC_EOP) || !(status & DESC_SOP))) {
 			netif_err(priv, rx_status, ndev, "fragmented packet!\n");
 			ndev->stats.rx_dropped++;
-- 
2.1.0
