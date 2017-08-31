From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 5/8] net: dsa: bcm_sf2: Fix number of CFP entries for BCM7278
Date: Wed, 30 Aug 2017 17:18:49 -0700
Message-ID: <1504138732-65383-6-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38198 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:27:04 -0400
Received: by mail-wm0-f65.google.com with SMTP id u26so3334877wma.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:27:03 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM7278 has only 128 entries while BCM7445 has the full 256 entries set,
fix that.

Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c     | 4 ++++
 drivers/net/dsa/bcm_sf2.h     | 1 +
 drivers/net/dsa/bcm_sf2_cfp.c | 8 ++++----
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index fc9f9f171e55..af299fe343cc 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1043,6 +1043,7 @@ struct bcm_sf2_of_data {
 	u32 type;
 	const u16 *reg_offsets;
 	unsigned int core_reg_align;
+	unsigned int num_cfp_rules;
 };
 
 /* Register offsets for the SWITCH_REG_* block */
@@ -1066,6 +1067,7 @@ struct bcm_sf2_of_data {
 	.type		= BCM7445_DEVICE_ID,
 	.core_reg_align	= 0,
 	.reg_offsets	= bcm_sf2_7445_reg_offsets,
+	.num_cfp_rules	= 256,
 };
 
 static const u16 bcm_sf2_7278_reg_offsets[] = {
@@ -1088,6 +1090,7 @@ struct bcm_sf2_of_data {
 	.type		= BCM7278_DEVICE_ID,
 	.core_reg_align	= 1,
 	.reg_offsets	= bcm_sf2_7278_reg_offsets,
+	.num_cfp_rules	= 128,
 };
 
 static const struct of_device_id bcm_sf2_of_match[] = {
@@ -1144,6 +1147,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	priv->type = data->type;
 	priv->reg_offsets = data->reg_offsets;
 	priv->core_reg_align = data->core_reg_align;
+	priv->num_cfp_rules = data->num_cfp_rules;
 
 	/* Auto-detection using standard registers will not work, so
 	 * provide an indication of what kind of device we are for
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index d9c96b281fc0..02c499f9c56b 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -72,6 +72,7 @@ struct bcm_sf2_priv {
 	u32 				type;
 	const u16			*reg_offsets;
 	unsigned int			core_reg_align;
+	unsigned int			num_cfp_rules;
 
 	/* spinlock protecting access to the indirect registers */
 	spinlock_t			indir_lock;
diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 2fb32d67065f..8a1da7e67707 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -98,7 +98,7 @@ static inline void bcm_sf2_cfp_rule_addr_set(struct bcm_sf2_priv *priv,
 {
 	u32 reg;
 
-	WARN_ON(addr >= CFP_NUM_RULES);
+	WARN_ON(addr >= priv->num_cfp_rules);
 
 	reg = core_readl(priv, CORE_CFP_ACC);
 	reg &= ~(XCESS_ADDR_MASK << XCESS_ADDR_SHIFT);
@@ -109,7 +109,7 @@ static inline void bcm_sf2_cfp_rule_addr_set(struct bcm_sf2_priv *priv,
 static inline unsigned int bcm_sf2_cfp_rule_size(struct bcm_sf2_priv *priv)
 {
 	/* Entry #0 is reserved */
-	return CFP_NUM_RULES - 1;
+	return priv->num_cfp_rules - 1;
 }
 
 static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
@@ -523,7 +523,7 @@ static int bcm_sf2_cfp_rule_get_all(struct bcm_sf2_priv *priv,
 		if (!(reg & OP_STR_DONE))
 			break;
 
-	} while (index < CFP_NUM_RULES);
+	} while (index < priv->num_cfp_rules);
 
 	/* Put the TCAM size here */
 	nfc->data = bcm_sf2_cfp_rule_size(priv);
@@ -544,7 +544,7 @@ int bcm_sf2_get_rxnfc(struct dsa_switch *ds, int port,
 	case ETHTOOL_GRXCLSRLCNT:
 		/* Subtract the default, unusable rule */
 		nfc->rule_cnt = bitmap_weight(priv->cfp.used,
-					      CFP_NUM_RULES) - 1;
+					      priv->num_cfp_rules) - 1;
 		/* We support specifying rule locations */
 		nfc->data |= RX_CLS_LOC_SPECIAL;
 		break;
-- 
1.9.1
