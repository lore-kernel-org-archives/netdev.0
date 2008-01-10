From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/niu: Support for Marvell PHY
Date: Thu, 10 Jan 2008 02:24:34 -0800 (PST)
Message-ID: <20080110.022434.152597697.davem@davemloft.net>
References: <1199957581.5290.21.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751157AbYAJKYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 05:24:35 -0500
In-Reply-To: <1199957581.5290.21.camel@mlindner-lin.skd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirko Lindner <mlindner@marvell.com>
Date: Thu, 10 Jan 2008 10:33:01 +0100

> This patch makes necessary changes in the Neptune driver to support 
> the new Marvell PHY. It also adds support for the LED blinking
> on Neptune cards with Marvell PHY. All registers are using defines
> in the niu.h header file as is already done for the BCM8704 registers.

Applied.  Please provide a proper "Signed-off-by: " line next
time as documented in linux/Documentation/SubmittingPatches

Also there were a lot of coding style and other errors.  I
fixed them up because I already put you through the ringer
to fix up the original patch.

I'll note most of them, but reading linux/CodingStyle would be a great
idea:

> -static int xcvr_init_10g(struct niu *np)
> +void mrvl88x2011_act_led(struct niu *np, int val)
 ...
> +void mrvl88x2011_led_blink_rate(struct niu *np, int rate)
> +{

Both of these functions should be marked "static", return an "int" and
check and return all errors indicated by mdio_read() and mdio_write().

> +static int xcvr_init_10g_mrvl88x2011(struct niu *np)
> +{
 ...
> +	/* Set LED functions */
> +	mrvl88x2011_led_blink_rate(np, MRVL88X2011_LED_BLKRATE_134MS);
> +	mrvl88x2011_act_led(np, MRVL88X2011_LED_CTL_OFF);	/* led activity */

Longer than 80-column lines, no error checking.

> +	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
> +		MRVL88X2011_GENERAL_CTL);
> +	if (err < 0) {
> +		return(err);
> +	}

Extraneous openning and closing braces wasting precious screen
real-estate.  "return" is not a function taking an argument, don't
surround simple values with parenthesis.

These happened a lot, I won't mention the other instances.

> +	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
> +		MRVL88X2011_GENERAL_CTL, err);

Bad indentation, the argument on the second line of the mdio_write()
call should line up with the initial "np" initial arg on the
previous line.

If necessary, use tools or editors that help do this automatically for
you.  Several folks (including me) use Emacs's C mode with coding
style set to "linux" for that purpose.

> +static int xcvr_init_10g(struct niu *np)
> +{
> +	int err;
> +	u64 val;
> +	int phy_id;

Multiple variables of the same type should be on one single line
unless it would make the line too long.

> +	/* handle different phy types */
> +	switch((phy_id & NIU_PHY_ID_MASK)) {

Space is needed between "switch" keyword and openning parenthesis.
Only one set of parenthesis is sufficient here.

> -static int link_status_10g(struct niu *np, int *link_up_p)
> +static int link_status_10g_mrvl(struct niu *np, int *link_up_p)
>  {
> -	unsigned long flags;
> -	int err, link_up;
> +	int 	err;
> +	int	link_up = 0;
> +	int	pma_status;
> +	int	pcs_status;

No tabs please between variable type and names, and again list
multiple variables of the same type on one single line in order to
save previous screen real-estate.

> +	pma_status = ((err & MRVL88X2011_LNK_STATUS_OK) ? 1:0);

Spaces are needed to make this easier to read "? 1 : 0".

> +	if (err == (
> +		PHYXS_XGXS_LANE_STAT_ALINGED | PHYXS_XGXS_LANE_STAT_LANE3 |
> +		PHYXS_XGXS_LANE_STAT_LANE2 | PHYXS_XGXS_LANE_STAT_LANE1 |
> +		PHYXS_XGXS_LANE_STAT_LANE0 | PHYXS_XGXS_LANE_STAT_MAGIC | 0x800)) {

This "err == (" line should hold the first line of bit values, again
to save lines.

> +	mrvl88x2011_act_led(np, link_up ? MRVL88X2011_LED_CTL_PCS_ACT:MRVL88X2011_LED_CTL_OFF);

Line excessively exceeds 80 columns.

>  	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
> -		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704)
> +		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
> +			((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011))

Not indented properly, the second line in the inner "if" statement
should have it's initial parenthesis match up with the second openning
parenthesis on the previous line.

> +/* MRVL88X2011 register control */
> +#define MRVL88X2011_ENA_XFPREFCLK	0x0001
> +#define MRVL88X2011_ENA_PMDTX		0x0000
> +#define MRVL88X2011_LOOPBACK            0x1
> +#define MRVL88X2011_LED_ACT             0x1
> +#define MRVL88X2011_LNK_STATUS_OK       0x4
> +#define MRVL88X2011_LED_BLKRATE_MASK	0x70
> +#define MRVL88X2011_LED_BLKRATE_034MS	0x0
> +#define MRVL88X2011_LED_BLKRATE_067MS	0x1
> +#define MRVL88X2011_LED_BLKRATE_134MS	0x2
> +#define MRVL88X2011_LED_BLKRATE_269MS	0x3
> +#define MRVL88X2011_LED_BLKRATE_538MS	0x4
> +#define MRVL88X2011_LED_CTL_OFF		0x0
> +#define MRVL88X2011_LED_CTL_PCS_ACT	0x5
> +#define MRVL88X2011_LED_CTL_MASK	0x7
> +#define MRVL88X2011_LED(n,v)            ((v)<<((n)*4))
> +#define MRVL88X2011_LED_STAT(n,v)       ((v)>>((n)*4))

These lines inconsistently use tabs vs. spaces to create the
indentation between the macro name and it's definition.

Anyways, after cleaning up all of that the patch I ended up checking
in looks like the following.

BTW, I just checked in several bug fixes to the Neptune driver
upstream, you might want to check them out.

Thanks.

[NIU]: Support for Marvell PHY

From: Mirko Lindner <mlindner@marvell.com>

This patch makes necessary changes in the Neptune driver to support
the new Marvell PHY. It also adds support for the LED blinking
on Neptune cards with Marvell PHY. All registers are using defines
in the niu.h header file as is already done for the BCM8704 registers.

[ Coding style, etc. cleanups -DaveM ]

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |  218 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/niu.h |   33 ++++++++
 2 files changed, 231 insertions(+), 20 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 9a0c6d3..3bbcea1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -801,22 +801,90 @@ static int bcm8704_init_user_dev3(struct niu *np)
 	return 0;
 }
 
-static int xcvr_init_10g(struct niu *np)
+static int mrvl88x2011_act_led(struct niu *np, int val)
+{
+	int	err;
+
+	err  = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+		MRVL88X2011_LED_8_TO_11_CTL);
+	if (err < 0)
+		return err;
+
+	err &= ~MRVL88X2011_LED(MRVL88X2011_LED_ACT,MRVL88X2011_LED_CTL_MASK);
+	err |=  MRVL88X2011_LED(MRVL88X2011_LED_ACT,val);
+
+	return mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+			  MRVL88X2011_LED_8_TO_11_CTL, err);
+}
+
+static int mrvl88x2011_led_blink_rate(struct niu *np, int rate)
+{
+	int	err;
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+			MRVL88X2011_LED_BLINK_CTL);
+	if (err >= 0) {
+		err &= ~MRVL88X2011_LED_BLKRATE_MASK;
+		err |= (rate << 4);
+
+		err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+				 MRVL88X2011_LED_BLINK_CTL, err);
+	}
+
+	return err;
+}
+
+static int xcvr_init_10g_mrvl88x2011(struct niu *np)
+{
+	int	err;
+
+	/* Set LED functions */
+	err = mrvl88x2011_led_blink_rate(np, MRVL88X2011_LED_BLKRATE_134MS);
+	if (err)
+		return err;
+
+	/* led activity */
+	err = mrvl88x2011_act_led(np, MRVL88X2011_LED_CTL_OFF);
+	if (err)
+		return err;
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+			MRVL88X2011_GENERAL_CTL);
+	if (err < 0)
+		return err;
+
+	err |= MRVL88X2011_ENA_XFPREFCLK;
+
+	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+			 MRVL88X2011_GENERAL_CTL, err);
+	if (err < 0)
+		return err;
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+			MRVL88X2011_PMA_PMD_CTL_1);
+	if (err < 0)
+		return err;
+
+	if (np->link_config.loopback_mode == LOOPBACK_MAC)
+		err |= MRVL88X2011_LOOPBACK;
+	else
+		err &= ~MRVL88X2011_LOOPBACK;
+
+	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+			 MRVL88X2011_PMA_PMD_CTL_1, err);
+	if (err < 0)
+		return err;
+
+	/* Enable PMD  */
+	return mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+			  MRVL88X2011_10G_PMD_TX_DIS, MRVL88X2011_ENA_PMDTX);
+}
+
+static int xcvr_init_10g_bcm8704(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
 	u16 analog_stat0, tx_alarm_status;
 	int err;
-	u64 val;
-
-	val = nr64_mac(XMAC_CONFIG);
-	val &= ~XMAC_CONFIG_LED_POLARITY;
-	val |= XMAC_CONFIG_FORCE_LED_ON;
-	nw64_mac(XMAC_CONFIG, val);
-
-	/* XXX shared resource, lock parent XXX */
-	val = nr64(MIF_CONFIG);
-	val |= MIF_CONFIG_INDIRECT_MODE;
-	nw64(MIF_CONFIG, val);
 
 	err = bcm8704_reset(np);
 	if (err)
@@ -896,6 +964,38 @@ static int xcvr_init_10g(struct niu *np)
 	return 0;
 }
 
+static int xcvr_init_10g(struct niu *np)
+{
+	int phy_id, err;
+	u64 val;
+
+	val = nr64_mac(XMAC_CONFIG);
+	val &= ~XMAC_CONFIG_LED_POLARITY;
+	val |= XMAC_CONFIG_FORCE_LED_ON;
+	nw64_mac(XMAC_CONFIG, val);
+
+	/* XXX shared resource, lock parent XXX */
+	val = nr64(MIF_CONFIG);
+	val |= MIF_CONFIG_INDIRECT_MODE;
+	nw64(MIF_CONFIG, val);
+
+	phy_id = phy_decode(np->parent->port_phy, np->port);
+	phy_id = np->parent->phy_probe_info.phy_id[phy_id][np->port];
+
+	/* handle different phy types */
+	switch (phy_id & NIU_PHY_ID_MASK) {
+	case NIU_PHY_ID_MRVL88X2011:
+		err = xcvr_init_10g_mrvl88x2011(np);
+		break;
+
+	default: /* bcom 8704 */
+		err = xcvr_init_10g_bcm8704(np);
+		break;
+	}
+
+	return 0;
+}
+
 static int mii_reset(struct niu *np)
 {
 	int limit, err;
@@ -1082,19 +1182,68 @@ static int niu_link_status_common(struct niu *np, int link_up)
 	return 0;
 }
 
-static int link_status_10g(struct niu *np, int *link_up_p)
+static int link_status_10g_mrvl(struct niu *np, int *link_up_p)
 {
-	unsigned long flags;
-	int err, link_up;
+	int err, link_up, pma_status, pcs_status;
 
 	link_up = 0;
 
-	spin_lock_irqsave(&np->lock, flags);
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+			MRVL88X2011_10G_PMD_STATUS_2);
+	if (err < 0)
+		goto out;
 
-	err = -EINVAL;
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
+	/* Check PMA/PMD Register: 1.0001.2 == 1 */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+			MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0)
+		goto out;
+
+	pma_status = ((err & MRVL88X2011_LNK_STATUS_OK) ? 1 : 0);
+
+        /* Check PMC Register : 3.0001.2 == 1: read twice */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+			MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0)
+		goto out;
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+			MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0)
+		goto out;
+
+	pcs_status = ((err & MRVL88X2011_LNK_STATUS_OK) ? 1 : 0);
+
+        /* Check XGXS Register : 4.0018.[0-3,12] */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV4_ADDR,
+			MRVL88X2011_10G_XGXS_LANE_STAT);
+	if (err < 0)
 		goto out;
 
+	if (err == (PHYXS_XGXS_LANE_STAT_ALINGED | PHYXS_XGXS_LANE_STAT_LANE3 |
+		    PHYXS_XGXS_LANE_STAT_LANE2 | PHYXS_XGXS_LANE_STAT_LANE1 |
+		    PHYXS_XGXS_LANE_STAT_LANE0 | PHYXS_XGXS_LANE_STAT_MAGIC |
+		    0x800))
+		link_up = (pma_status && pcs_status) ? 1 : 0;
+
+	np->link_config.active_speed = SPEED_10000;
+	np->link_config.active_duplex = DUPLEX_FULL;
+	err = 0;
+out:
+	mrvl88x2011_act_led(np, (link_up ?
+				 MRVL88X2011_LED_CTL_PCS_ACT :
+				 MRVL88X2011_LED_CTL_OFF));
+
+	*link_up_p = link_up;
+	return err;
+}
+
+static int link_status_10g_bcom(struct niu *np, int *link_up_p)
+{
+	int err, link_up;
+
+	link_up = 0;
+
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
 			BCM8704_PMD_RCV_SIGDET);
 	if (err < 0)
@@ -1134,9 +1283,37 @@ static int link_status_10g(struct niu *np, int *link_up_p)
 	err = 0;
 
 out:
+	*link_up_p = link_up;
+	return err;
+}
+
+static int link_status_10g(struct niu *np, int *link_up_p)
+{
+	unsigned long flags;
+	int err = -EINVAL;
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	if (np->link_config.loopback_mode == LOOPBACK_DISABLED) {
+		int phy_id;
+
+		phy_id = phy_decode(np->parent->port_phy, np->port);
+		phy_id = np->parent->phy_probe_info.phy_id[phy_id][np->port];
+
+		/* handle different phy types */
+		switch (phy_id & NIU_PHY_ID_MASK) {
+		case NIU_PHY_ID_MRVL88X2011:
+			err = link_status_10g_mrvl(np, link_up_p);
+			break;
+
+		default: /* bcom 8704 */
+			err = link_status_10g_bcom(np, link_up_p);
+			break;
+		}
+	}
+
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	*link_up_p = link_up;
 	return err;
 }
 
@@ -6297,7 +6474,8 @@ static int __devinit phy_record(struct niu_parent *parent,
 	if (dev_id_1 < 0 || dev_id_2 < 0)
 		return 0;
 	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
-		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704)
+		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
+		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011))
 			return 0;
 	} else {
 		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM5464R)
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 10e3f11..0e8626a 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2538,6 +2538,39 @@ struct fcram_hash_ipv6 {
 #define NIU_PHY_ID_MASK			0xfffff0f0
 #define NIU_PHY_ID_BCM8704		0x00206030
 #define NIU_PHY_ID_BCM5464R		0x002060b0
+#define NIU_PHY_ID_MRVL88X2011		0x01410020
+
+/* MRVL88X2011 register addresses */
+#define MRVL88X2011_USER_DEV1_ADDR	1
+#define MRVL88X2011_USER_DEV2_ADDR	2
+#define MRVL88X2011_USER_DEV3_ADDR	3
+#define MRVL88X2011_USER_DEV4_ADDR	4
+#define MRVL88X2011_PMA_PMD_CTL_1	0x0000
+#define MRVL88X2011_PMA_PMD_STATUS_1	0x0001
+#define MRVL88X2011_10G_PMD_STATUS_2	0x0008
+#define MRVL88X2011_10G_PMD_TX_DIS	0x0009
+#define MRVL88X2011_10G_XGXS_LANE_STAT	0x0018
+#define MRVL88X2011_GENERAL_CTL		0x8300
+#define MRVL88X2011_LED_BLINK_CTL	0x8303
+#define MRVL88X2011_LED_8_TO_11_CTL	0x8306
+
+/* MRVL88X2011 register control */
+#define MRVL88X2011_ENA_XFPREFCLK	0x0001
+#define MRVL88X2011_ENA_PMDTX		0x0000
+#define MRVL88X2011_LOOPBACK            0x1
+#define MRVL88X2011_LED_ACT		0x1
+#define MRVL88X2011_LNK_STATUS_OK	0x4
+#define MRVL88X2011_LED_BLKRATE_MASK	0x70
+#define MRVL88X2011_LED_BLKRATE_034MS	0x0
+#define MRVL88X2011_LED_BLKRATE_067MS	0x1
+#define MRVL88X2011_LED_BLKRATE_134MS	0x2
+#define MRVL88X2011_LED_BLKRATE_269MS	0x3
+#define MRVL88X2011_LED_BLKRATE_538MS	0x4
+#define MRVL88X2011_LED_CTL_OFF		0x0
+#define MRVL88X2011_LED_CTL_PCS_ACT	0x5
+#define MRVL88X2011_LED_CTL_MASK	0x7
+#define MRVL88X2011_LED(n,v)		((v)<<((n)*4))
+#define MRVL88X2011_LED_STAT(n,v)	((v)>>((n)*4))
 
 #define BCM8704_PMA_PMD_DEV_ADDR	1
 #define BCM8704_PCS_DEV_ADDR		2
-- 
1.5.4.rc2.84.gf85fd

