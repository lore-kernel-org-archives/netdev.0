From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: systemport: Use correct I/O accessors
Date: Tue, 29 Aug 2017 13:35:15 -0700
Message-ID: <1504038918-49254-2-git-send-email-f.fainelli@gmail.com>
References: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:37593 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751249AbdH2UlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:41:16 -0400
Received: by mail-qk0-f196.google.com with SMTP id m4so3847437qke.4
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:41:15 -0700 (PDT)
In-Reply-To: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SYSTEMPORT driver currently uses __raw_{read,write}l which means
native I/O endian. This works correctly for an ARM LE kernel (default)
but fails miserably on an ARM BE (BE8) kernel where registers are kept
little endian, so replace uses with {read,write}l_relaxed here which is
what we want because this is all performance sensitive code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index b3a21418f511..a7e84292af50 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -32,13 +32,13 @@
 #define BCM_SYSPORT_IO_MACRO(name, offset) \
 static inline u32 name##_readl(struct bcm_sysport_priv *priv, u32 off)	\
 {									\
-	u32 reg = __raw_readl(priv->base + offset + off);		\
+	u32 reg = readl_relaxed(priv->base + offset + off);		\
 	return reg;							\
 }									\
 static inline void name##_writel(struct bcm_sysport_priv *priv,		\
 				  u32 val, u32 off)			\
 {									\
-	__raw_writel(val, priv->base + offset + off);			\
+	writel_relaxed(val, priv->base + offset + off);			\
 }									\
 
 BCM_SYSPORT_IO_MACRO(intrl2_0, SYS_PORT_INTRL2_0_OFFSET);
@@ -59,14 +59,14 @@ static inline u32 rdma_readl(struct bcm_sysport_priv *priv, u32 off)
 {
 	if (priv->is_lite && off >= RDMA_STATUS)
 		off += 4;
-	return __raw_readl(priv->base + SYS_PORT_RDMA_OFFSET + off);
+	return readl_relaxed(priv->base + SYS_PORT_RDMA_OFFSET + off);
 }
 
 static inline void rdma_writel(struct bcm_sysport_priv *priv, u32 val, u32 off)
 {
 	if (priv->is_lite && off >= RDMA_STATUS)
 		off += 4;
-	__raw_writel(val, priv->base + SYS_PORT_RDMA_OFFSET + off);
+	writel_relaxed(val, priv->base + SYS_PORT_RDMA_OFFSET + off);
 }
 
 static inline u32 tdma_control_bit(struct bcm_sysport_priv *priv, u32 bit)
@@ -110,10 +110,10 @@ static inline void dma_desc_set_addr(struct bcm_sysport_priv *priv,
 				     dma_addr_t addr)
 {
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
-	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
+	writel_relaxed(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
 		     d + DESC_ADDR_HI_STATUS_LEN);
 #endif
-	__raw_writel(lower_32_bits(addr), d + DESC_ADDR_LO);
+	writel_relaxed(lower_32_bits(addr), d + DESC_ADDR_LO);
 }
 
 static inline void tdma_port_write_desc_addr(struct bcm_sysport_priv *priv,
-- 
1.9.1
