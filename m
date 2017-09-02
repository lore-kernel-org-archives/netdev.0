From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: Correctly set TSB endian for host
Date: Fri,  1 Sep 2017 17:32:34 -0700
Message-ID: <1504312354-62020-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:37873 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752264AbdIBAic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:38:32 -0400
Received: by mail-qk0-f193.google.com with SMTP id c6so499044qkh.4
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 17:38:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to how we configure the RSB (Receive Status Block) we also
need to set the TSB (Transmit Status Block) based on the host endian.
This was missing from the commit indicated below.

Fixes: 389a06bc534e ("net: systemport: Set correct RSB endian bits based on host")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 13 +++++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h |  3 ++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 931751e4f369..ef13b6041ef1 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1390,6 +1390,19 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	tdma_writel(priv, RING_IGNORE_STATUS, TDMA_DESC_RING_MAPPING(index));
 	tdma_writel(priv, 0, TDMA_DESC_RING_PCP_DEI_VID(index));
 
+	/* Do not use tdma_control_bit() here because TSB_SWAP1 collides
+	 * with the original definition of ACB_ALGO
+	 */
+	reg = tdma_readl(priv, TDMA_CONTROL);
+	if (priv->is_lite)
+		reg &= ~BIT(TSB_SWAP1);
+	/* Set a correct TSB format based on host endian */
+	if (!IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
+		reg |= tdma_control_bit(priv, TSB_SWAP0);
+	else
+		reg &= ~tdma_control_bit(priv, TSB_SWAP0);
+	tdma_writel(priv, reg, TDMA_CONTROL);
+
 	/* Program the number of descriptors as MAX_THRESHOLD and half of
 	 * its size for the hysteresis trigger
 	 */
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 80b4ffff63b7..82e401df199e 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -449,7 +449,8 @@ struct bcm_rsb {
 /* Uses 2 bits on SYSTEMPORT Lite and shifts everything by 1 bit, we
  * keep the SYSTEMPORT layout here and adjust with tdma_control_bit()
  */
-#define  TSB_SWAP			2
+#define  TSB_SWAP0			2
+#define  TSB_SWAP1			3
 #define  ACB_ALGO			3
 #define  BUF_DATA_OFFSET_SHIFT		4
 #define  BUF_DATA_OFFSET_MASK		0x3ff
-- 
1.9.1
