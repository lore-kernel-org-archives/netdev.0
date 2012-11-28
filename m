From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Re: RTL 8169  linux driver question
Date: Thu, 29 Nov 2012 00:18:22 +0100
Message-ID: <20121128231822.GA10158@electric-eye.fr.zoreil.com>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr> <AE90C24D6B3A694183C094C60CF0A2F6026B70BD@saturn3.aculab.com> <20121127224605.GA10228@electric-eye.fr.zoreil.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70CA@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?U3TDqXBoYW5l?= ANCELOT <sancelot@free.fr>,
	netdev@vger.kernel.org, sancelot@numalliance.com,
	Hayes Wang <hayeswang@realtek.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57382 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab2K1Xm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 18:42:56 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70CA@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> :
[David's life]


The version below fixes several bugs and refuses the frame or timing
values it can't set. Hayes's Tx parameters still need to be pluged
into rtl_coalesce_scale.

Rx delays seem lower than what I had expected when testing with a 8168b
(XID 18000000).

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 248f883..d2594b1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -349,6 +349,12 @@ enum rtl_registers {
 	RxMaxSize	= 0xda,
 	CPlusCmd	= 0xe0,
 	IntrMitigate	= 0xe2,
+
+#define RTL_COALESCE_MASK	0x0f
+#define RTL_COALESCE_SHIFT	4
+#define RTL_COALESCE_T_MAX	(RTL_COALESCE_MASK)
+#define RTL_COALESCE_FRAME_MAX	(RTL_COALESCE_MASK << 2)
+
 	RxDescAddrLow	= 0xe4,
 	RxDescAddrHigh	= 0xe8,
 	EarlyTxThres	= 0xec,	/* 8169. Unit of 32 bytes. */
@@ -1997,10 +2003,121 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static struct rtl_coalesce_scale {
+	u32 speed;
+	/* Rx / Tx */
+	u16 usecs[2];
+} rtl_coalesce_info[] = {
+	{ .speed = SPEED_10,	.usecs = { 8000, 10000 } },
+	{ .speed = SPEED_100,	.usecs = { 1000,  1000 } },
+	{ .speed = SPEED_1000,	.usecs = {  125,   125 } }
+};
+
+static struct rtl_coalesce_scale *rtl_coalesce_scale(struct net_device *dev)
+{
+	struct ethtool_cmd ecmd;
+	int rc, i;
+
+	rc = rtl8169_get_settings(dev, &ecmd);
+	if (rc < 0)
+		return ERR_PTR(rc);
+
+	for (i = 0; i < ARRAY_SIZE(rtl_coalesce_info); i++) {
+		if (ethtool_cmd_speed(&ecmd) == rtl_coalesce_info[i].speed)
+			return rtl_coalesce_info + i;
+	}
+
+	return ERR_PTR(-EINVAL);
+}
+
+static int rtl_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct rtl_coalesce_scale *scale;
+	struct {
+		u32 *max_frames;
+		u32 *usecs;
+	} coal_settings [] = {
+		{ &ec->rx_max_coalesced_frames, &ec->rx_coalesce_usecs },
+		{ &ec->tx_max_coalesced_frames, &ec->tx_coalesce_usecs }
+	}, *p = coal_settings;
+	int i;
+	u16 w;
+
+	memset(ec, 0, sizeof(*ec));
+
+	for (w = RTL_R16(IntrMitigate); w; w >>= RTL_COALESCE_SHIFT, p++) {
+		*p->max_frames = (w & RTL_COALESCE_MASK) << 2;
+		w >>= RTL_COALESCE_SHIFT;
+		*p->usecs = w & RTL_COALESCE_MASK;
+	}
+
+	/* Except for null parameeters, the meaning of coalescing parameters
+	 * depends on the link speed.
+	 */
+	scale = rtl_coalesce_scale(dev);
+	if (IS_ERR(scale) && (p != coal_settings))
+		return PTR_ERR(scale);
+
+	for (i = 0; i < 2; i++) {
+		p = coal_settings + i;
+		*p->usecs *= scale->usecs[i];
+		if (!*p->usecs && !*p->max_frames)
+			*p->max_frames = 1;
+	}
+
+	return 0;
+}
+
+static int rtl_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct rtl_coalesce_scale *scale;
+	struct {
+		u32 frames;
+		u32 usecs;
+	} coal_settings [] = {
+		{ ec->rx_max_coalesced_frames, ec->rx_coalesce_usecs },
+		{ ec->tx_max_coalesced_frames, ec->tx_coalesce_usecs }
+	}, *p = coal_settings;
+	u16 w = 0;
+	int i;
+
+	scale = rtl_coalesce_scale(dev);
+
+	for (i = 0; i < 2; i++, p++) {
+		u32 units;
+
+		if (p->usecs || p->frames != 1) {
+			if (IS_ERR(scale))
+				return PTR_ERR(scale);
+		} else
+			p->frames = 0;
+
+		units = p->usecs / scale->usecs[i];
+		if (units > RTL_COALESCE_T_MAX || p->usecs % scale->usecs[i] ||
+		    p->frames > RTL_COALESCE_FRAME_MAX || p->frames % 4)
+			return -EINVAL;
+
+		w <<= RTL_COALESCE_SHIFT;
+		w |= units;
+		w <<= RTL_COALESCE_SHIFT;
+		w |= p->frames >> 2;
+	}
+
+	RTL_W16(IntrMitigate, swab16(w));
+
+	return 0;
+}
+
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
+	.get_coalesce		= rtl_get_coalesce,
+	.set_coalesce		= rtl_set_coalesce,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 	.get_msglevel		= rtl8169_get_msglevel,
