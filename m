From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next-2.6 08/08] r8169: more 8168dp support.
Date: Tue, 4 Jan 2011 01:26:06 +0100
Message-ID: <20110104002606.GA5934@electric-eye.fr.zoreil.com>
References: <20110102233751.GI5780@electric-eye.fr.zoreil.com> <C4B63551EF6C4B57BB20D6922F78AA12@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"'Ben Hutchings'" <benh@debian.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51146 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab1ADA0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 19:26:21 -0500
Content-Disposition: inline
In-Reply-To: <C4B63551EF6C4B57BB20D6922F78AA12@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> > +static void rtl8169_hw_reset(struct rtl8169_private *tp)
> >  {
> > +	void __iomem *ioaddr = tp->mmio_addr;
> > +
> >  	/* Disable interrupts */
> >  	rtl8169_irq_mask_and_ack(ioaddr);
> >  
> > +	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
> 
> This check should include RTL_GIGA_MAC_VER_27.

Sure. I have a different (yet untested) patch for it. See below.

> > +		while (RTL_R8(TxPoll) & NPQ)
> > +			udelay(20);
> > +
> > +	}
> > +
> >  	/* Reset the chipset */
> >  	RTL_W8(ChipCmd, CmdReset);
> >  
> 
> After the reset, there are something to do for RTL_GIGA_MAC_VER_27. You may
> check the soure code of realtek. Find "rtl8168_nic_reset".

Ok. Any comment about the patch below ? I wish it was more expressive,
especially the "mutex" magic.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 27a7c20..d2c850d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -615,6 +615,58 @@ static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
 	}
 }
 
+#define OCP_REG_1	0x009c
+#define OCP_REG_2	0x0014
+
+static void ocp_lock_write(struct rtl8169_private *tp, u32 data)
+{
+	ocp_write(tp, 0x08, OCP_REG_2, data);
+}
+
+static u32 ocp_lock_read(struct rtl8169_private *tp, u16 reg)
+{
+	return ocp_read(tp, 0x0f, reg);
+}
+
+static void __ocp_lock_claim_everyting(struct rtl8169_private *tp)
+{
+	ocp_lock_write(tp, 0x01000000);
+}
+
+static void __ocp_lock_release_everything(struct rtl8169_private *tp)
+{
+	ocp_lock_write(tp, 0x00000000);
+}
+
+static bool __ocp_lock_got_everything(struct rtl8169_private *tp)
+{
+	return !(ocp_lock_read(tp, OCP_REG_2) & 0x00ff0000);
+}
+
+static bool __ocp_lock_got_something(struct rtl8169_private *tp)
+{
+	return !(ocp_lock_read(tp, OCP_REG_1) & 0x000000ff);
+}
+
+static void rtl8168_oob_mutex_lock(struct rtl8169_private *tp)
+{
+	__ocp_lock_claim_everyting(tp);
+	while (!__ocp_lock_got_everything(tp)) {
+		if (__ocp_lock_got_something(tp))
+			continue;
+
+		__ocp_lock_release_everything(tp);
+		while (!__ocp_lock_got_something(tp));
+		__ocp_lock_claim_everyting(tp);
+	}
+}
+
+static void rtl8168_oob_mutex_unlock(struct rtl8169_private *tp)
+{
+	ocp_write(tp, 0x01, OCP_REG_1, 0x00000001);
+	__ocp_lock_release_everything(tp);
+}
+
 static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
 {
 	int i;
@@ -3193,11 +3245,13 @@ err_pm_runtime_put:
 static void rtl8169_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
 
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_28)) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 
@@ -3206,8 +3260,40 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Reset the chipset */
 	RTL_W8(ChipCmd, CmdReset);
 
-	/* PCI commit */
-	RTL_R8(ChipCmd);
+	/*
+	 * PCI commit and wait for completion.
+	 * Max upper bound for 8169 and 810x is 10 times 8168's.
+	 */
+	for (i = 0; i < 1000; i++) {
+		udelay(100);
+		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
+			break;
+	}
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27) {
+		u32 rst;
+
+#define OCP_RST_REG	0x0010
+#define OCP_RST_BIT	0x00004000
+
+		rtl8168_oob_mutex_lock(tp);
+		rst = ocp_read(tp, 0xf, OCP_RST_REG) & ~OCP_RST_BIT;
+		ocp_write(tp, 0x03, OCP_RST_REG, rst);
+		rtl8168_oob_mutex_unlock(tp);
+
+		rtl8168_oob_notify(tp, OOB_CMD_RESET);
+
+		for (i = 0; i < 10; i++) {
+			mdelay(10);
+			if (ocp_read(tp, 0xf, 0x0010) & OCP_RST_BIT)
+				break;
+		}
+
+		for (i = 0; i < 5; i++) {
+			if ((ocp_read(tp, 0xf, 0x0034) & 0xffff) == 0)
+				break;
+		}
+	}
 }
 
 static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)

