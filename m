From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/7] net: dsa: bcm_sf2: Use existing shift/masks
Date: Fri, 20 Oct 2017 14:34:48 -0700
Message-ID: <20171020213454.14848-2-f.fainelli@gmail.com>
References: <20171020213454.14848-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net,
        Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:52101 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbdJTVfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:35:03 -0400
Received: by mail-qt0-f193.google.com with SMTP id h4so20113976qtk.8
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:35:03 -0700 (PDT)
In-Reply-To: <20171020213454.14848-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian.fainelli@broadcom.com>

Instead of open coding the shift for the IP protocol, IP fragment bit
etc. define and/or use existing constants to that end.

refs #SWLINUX-4608

Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c  | 7 ++++---
 drivers/net/dsa/bcm_sf2_regs.h | 5 ++++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 94649e1481ec..cef4b3d4df36 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -189,7 +189,8 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	 * Reserved		[1]
 	 * UDF_Valid[8]		[0]
 	 */
-	core_writel(priv, v4_spec->tos << 16 | ip_proto << 8 | ip_frag << 7,
+	core_writel(priv, v4_spec->tos << IPTOS_SHIFT |
+		    ip_proto << IPPROTO_SHIFT | ip_frag << IP_FRAG_SHIFT,
 		    CORE_CFP_DATA_PORT(6));
 
 	/* UDF_Valid[7:0]	[31:24]
@@ -425,8 +426,8 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 		return -EINVAL;
 	}
 
-	v4_spec->tos = (reg >> 16) & IPPROTO_MASK;
-	nfc->fs.m_ext.data[0] = cpu_to_be32((reg >> 7) & 1);
+	v4_spec->tos = (reg >> IPTOS_SHIFT) & IPTOS_MASK;
+	nfc->fs.m_ext.data[0] = cpu_to_be32((reg >> IP_FRAG_SHIFT) & 1);
 
 	reg = core_readl(priv, CORE_CFP_DATA_PORT(3));
 	/* src port [15:8] */
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index d1596dfca323..61bc9729383f 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -302,9 +302,12 @@ enum bcm_sf2_reg_offs {
 /* UDF_DATA7 */
 #define L3_FRAMING_SHIFT		24
 #define L3_FRAMING_MASK			(0x3 << L3_FRAMING_SHIFT)
+#define IPTOS_SHIFT			16
+#define IPTOS_MASK			0xff
 #define IPPROTO_SHIFT			8
 #define IPPROTO_MASK			(0xff << IPPROTO_SHIFT)
-#define IP_FRAG				(1 << 7)
+#define IP_FRAG_SHIFT			7
+#define IP_FRAG				(1 << IP_FRAG_SHIFT)
 
 /* UDF_DATA0 */
 #define  SLICE_VALID			3
-- 
2.14.1
