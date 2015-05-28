From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: systemport: Add a check for oversized packets
Date: Thu, 28 May 2015 15:24:44 -0700
Message-ID: <1432851884-12026-4-git-send-email-f.fainelli@gmail.com>
References: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34217 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754995AbbE1WZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 18:25:28 -0400
Received: by pdbki1 with SMTP id ki1so51367864pdb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 15:25:27 -0700 (PDT)
In-Reply-To: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Occasionnaly we may get oversized packets from the hardware which exceed
the nomimal 2KiB buffer size we allocate SKBs with. Add an early check
which drops the packet to avoid invoking skb_over_panic() and move on to
processing the next packet.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index d777b0db9e63..909ad7a0d480 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -638,6 +638,14 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
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
