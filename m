From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/7] net: dsa: bcm_sf2: Simplify bcm_sf2_cfp_rule_get_all()
Date: Fri, 20 Oct 2017 14:39:46 -0700
Message-ID: <20171020213949.16485-5-f.fainelli@gmail.com>
References: <20171020213949.16485-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:43024 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752915AbdJTVkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:40:02 -0400
Received: by mail-qk0-f195.google.com with SMTP id w134so16003031qkb.0
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:40:02 -0700 (PDT)
In-Reply-To: <20171020213949.16485-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to do a HW search of the TCAMs which is something slow
and expensive. Since we already maintain a bitmask of active CFP rules,
just iterate over those, starting from bit 1 (after the reserved entry)
to get a count and index position to store the rule later on.

As a result we can remove the code in bcm_sf2_cfp_rule_get() which acted
on the "search" argument, and remove that argument.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_cfp.c | 68 +++++++++----------------------------------
 1 file changed, 14 insertions(+), 54 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index d033fc6440c4..9c8299580795 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -491,28 +491,24 @@ static int bcm_sf2_cfp_ipv4_rule_get(struct bcm_sf2_priv *priv, int port,
 }
 
 static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
-				struct ethtool_rxnfc *nfc, bool search)
+				struct ethtool_rxnfc *nfc)
 {
 	struct ethtool_tcpip4_spec *v4_spec = NULL, *v4_m_spec;
 	unsigned int queue_num;
 	u32 reg;
 	int ret;
 
-	if (!search) {
-		bcm_sf2_cfp_rule_addr_set(priv, nfc->fs.location);
+	bcm_sf2_cfp_rule_addr_set(priv, nfc->fs.location);
 
-		ret = bcm_sf2_cfp_op(priv, OP_SEL_READ | ACT_POL_RAM);
-		if (ret)
-			return ret;
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_READ | ACT_POL_RAM);
+	if (ret)
+		return ret;
 
-		reg = core_readl(priv, CORE_ACT_POL_DATA0);
+	reg = core_readl(priv, CORE_ACT_POL_DATA0);
 
-		ret = bcm_sf2_cfp_op(priv, OP_SEL_READ | TCAM_SEL);
-		if (ret)
-			return ret;
-	} else {
-		reg = core_readl(priv, CORE_ACT_POL_DATA0);
-	}
+	ret = bcm_sf2_cfp_op(priv, OP_SEL_READ | TCAM_SEL);
+	if (ret)
+		return ret;
 
 	/* Extract the destination port */
 	nfc->fs.ring_cookie = fls((reg >> DST_MAP_IB_SHIFT) &
@@ -541,9 +537,6 @@ static int bcm_sf2_cfp_rule_get(struct bcm_sf2_priv *priv, int port,
 		v4_m_spec = &nfc->fs.m_u.udp_ip4_spec;
 		break;
 	default:
-		/* Clear to exit the search process */
-		if (search)
-			core_readl(priv, CORE_CFP_DATA_PORT(7));
 		return -EINVAL;
 	}
 
@@ -577,44 +570,11 @@ static int bcm_sf2_cfp_rule_get_all(struct bcm_sf2_priv *priv,
 				    u32 *rule_locs)
 {
 	unsigned int index = 1, rules_cnt = 0;
-	int ret;
-	u32 reg;
 
-	/* Do not poll on OP_STR_DONE to be self-clearing for search
-	 * operations, we cannot use bcm_sf2_cfp_op here because it completes
-	 * on clearing OP_STR_DONE which won't clear until the entire search
-	 * operation is over.
-	 */
-	reg = core_readl(priv, CORE_CFP_ACC);
-	reg &= ~(XCESS_ADDR_MASK << XCESS_ADDR_SHIFT);
-	reg |= index << XCESS_ADDR_SHIFT;
-	reg &= ~(OP_SEL_MASK | RAM_SEL_MASK);
-	reg |= OP_SEL_SEARCH | TCAM_SEL | OP_STR_DONE;
-	core_writel(priv, reg, CORE_CFP_ACC);
-
-	do {
-		/* Wait for results to be ready */
-		reg = core_readl(priv, CORE_CFP_ACC);
-
-		/* Extract the address we are searching */
-		index = reg >> XCESS_ADDR_SHIFT;
-		index &= XCESS_ADDR_MASK;
-
-		/* We have a valid search result, so flag it accordingly */
-		if (reg & SEARCH_STS) {
-			ret = bcm_sf2_cfp_rule_get(priv, port, nfc, true);
-			if (ret)
-				continue;
-
-			rule_locs[rules_cnt] = index;
-			rules_cnt++;
-		}
-
-		/* Search is over break out */
-		if (!(reg & OP_STR_DONE))
-			break;
-
-	} while (index < priv->num_cfp_rules);
+	for_each_set_bit_from(index, priv->cfp.used, priv->num_cfp_rules) {
+		rule_locs[rules_cnt] = index;
+		rules_cnt++;
+	}
 
 	/* Put the TCAM size here */
 	nfc->data = bcm_sf2_cfp_rule_size(priv);
@@ -640,7 +600,7 @@ int bcm_sf2_get_rxnfc(struct dsa_switch *ds, int port,
 		nfc->data |= RX_CLS_LOC_SPECIAL;
 		break;
 	case ETHTOOL_GRXCLSRULE:
-		ret = bcm_sf2_cfp_rule_get(priv, port, nfc, false);
+		ret = bcm_sf2_cfp_rule_get(priv, port, nfc);
 		break;
 	case ETHTOOL_GRXCLSRLALL:
 		ret = bcm_sf2_cfp_rule_get_all(priv, port, nfc, rule_locs);
-- 
2.14.1
