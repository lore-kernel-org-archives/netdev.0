From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/23) sk98: ethtool phy support
Date: Thu, 11 Nov 2004 15:55:22 -0800
Message-ID: <20041111155522.0a55335a@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The basic stuff comes from the newer code from SysKonnect, but I redid
it using a per board timer rather than a global timer.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-03 14:31:05 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-03 14:31:05 -08:00
@@ -383,6 +383,8 @@
 	SK_CSUM		Csum;		/* for checksum module */
 	SK_RLMT		Rlmt;		/* for rlmt module */
 	spinlock_t	SlowPathLock;	/* Normal IRQ lock */
+	struct timer_list BlinkTimer;	/* for LED blinking */
+	int		LedsOn;
 	SK_PNMI_STRUCT_DATA PnmiStruct;	/* structure to get all Pnmi-Data */
 	int			RlmtMode;	/* link check mode to set */
 	int			RlmtNets;	/* Number of nets */
diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-03 14:31:05 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-03 14:31:05 -08:00
@@ -39,6 +39,7 @@
 
 #include <linux/ethtool.h>
 #include <linux/timer.h>
+#include <linux/delay.h>
 
 /******************************************************************************
  *
@@ -320,6 +321,122 @@
 	*data++ = pAC->stats.tx_window_errors;
 }
 
+
+/*****************************************************************************
+ *
+ * 	toggleLeds - Changes the LED state of an adapter
+ *
+ * Description:
+ *	This function changes the current state of all LEDs of an adapter so
+ *	that it can be located by a user. 
+ *
+ * Returns:	N/A
+ *
+ */
+static void toggleLeds(DEV_NET *pNet, int on)
+{
+	SK_AC *pAC = pNet->pAC;
+	int port = pNet->PortNr;
+	void __iomem *io = pAC->IoBase;
+
+	if (pAC->GIni.GIGenesis) {
+		SK_OUT8(io, MR_ADDR(port,LNK_LED_REG), 
+			on ? SK_LNK_ON : SK_LNK_OFF);
+		SkGeYellowLED(pAC, io, 
+			      on ? (LED_ON >> 1) : (LED_OFF >> 1));
+		SkGeXmitLED(pAC, io, MR_ADDR(port,RX_LED_INI),
+			    on ? SK_LED_TST : SK_LED_DIS);
+
+		if (pAC->GIni.GP[port].PhyType == SK_PHY_BCOM)
+			SkXmPhyWrite(pAC, io, port, PHY_BCOM_P_EXT_CTRL, 
+				     on ? PHY_B_PEC_LED_ON : PHY_B_PEC_LED_OFF);
+		else if (pAC->GIni.GP[port].PhyType == SK_PHY_LONE)
+			SkXmPhyWrite(pAC, io, port, PHY_LONE_LED_CFG,
+				     on ? 0x0800 : PHY_L_LC_LEDT);
+		else
+			SkGeXmitLED(pAC, io, MR_ADDR(port,TX_LED_INI),
+				    on ? SK_LED_TST : SK_LED_DIS);
+	} else {
+		const u16 YukLedOn = (PHY_M_LED_MO_DUP(MO_LED_ON)  |
+				      PHY_M_LED_MO_10(MO_LED_ON)   |
+				      PHY_M_LED_MO_100(MO_LED_ON)  |
+				      PHY_M_LED_MO_1000(MO_LED_ON) | 
+				      PHY_M_LED_MO_RX(MO_LED_ON));
+		const u16  YukLedOff = (PHY_M_LED_MO_DUP(MO_LED_OFF)  |
+					PHY_M_LED_MO_10(MO_LED_OFF)   |
+					PHY_M_LED_MO_100(MO_LED_OFF)  |
+					PHY_M_LED_MO_1000(MO_LED_OFF) | 
+					PHY_M_LED_MO_RX(MO_LED_OFF));
+	
+
+		SkGmPhyWrite(pAC,io,port,PHY_MARV_LED_CTRL,0);
+		SkGmPhyWrite(pAC,io,port,PHY_MARV_LED_OVER, 
+			     on ? YukLedOn : YukLedOff);
+	}
+}
+
+/*****************************************************************************
+ *
+ * 	skGeBlinkTimer - Changes the LED state of an adapter
+ *
+ * Description:
+ *	This function changes the current state of all LEDs of an adapter so
+ *	that it can be located by a user. If the requested time interval for
+ *	this test has elapsed, this function cleans up everything that was 
+ *	temporarily setup during the locate NIC test. This involves of course
+ *	also closing or opening any adapter so that the initial board state 
+ *	is recovered.
+ *
+ * Returns:	N/A
+ *
+ */
+void SkGeBlinkTimer(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+
+	toggleLeds(pNet, pAC->LedsOn);
+
+	pAC->LedsOn = !pAC->LedsOn;
+	mod_timer(&pAC->BlinkTimer, jiffies + HZ/4);
+}
+
+/*****************************************************************************
+ *
+ * 	locateDevice - start the locate NIC feature of the elected adapter 
+ *
+ * Description:
+ *	This function is used if the user want to locate a particular NIC.
+ *	All LEDs are regularly switched on and off, so the NIC can easily
+ *	be identified.
+ *
+ * Returns:	
+ *	==0:	everything fine, no error, locateNIC test was started
+ *	!=0:	one locateNIC test runs already
+ *
+ */
+static int locateDevice(struct net_device *dev, u32 data)
+{
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+
+	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
+		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
+
+	/* start blinking */
+	pAC->LedsOn = 0;
+	mod_timer(&pAC->BlinkTimer, jiffies);
+	msleep_interruptible(data * 1000);
+
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(data * HZ);
+	del_timer_sync(&pAC->BlinkTimer);
+	toggleLeds(pNet, 0);
+
+	return 0;
+}
+
 struct ethtool_ops SkGeEthtoolOps = {
 	.get_settings		= getSettings,
 	.set_settings		= setSettings,
@@ -327,4 +444,5 @@
 	.get_strings		= getStrings,
 	.get_stats_count	= getStatsCount,
 	.get_ethtool_stats	= getEthtoolStats,
+	.phys_id		= locateDevice,
 };
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 14:31:05 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 14:31:05 -08:00
@@ -245,6 +245,7 @@
 extern void SkDimDisplayModerationSettings(SK_AC *pAC);
 extern void SkDimStartModerationTimer(SK_AC *pAC);
 extern void SkDimModerate(SK_AC *pAC);
+extern void SkGeBlinkTimer(unsigned long data);
 
 #ifdef DEBUG
 static void	DumpMsg(struct sk_buff*, char*);
@@ -502,6 +503,11 @@
 		spin_lock_init(&pAC->RxPort[i].RxDesRingLock);
 	}
 	spin_lock_init(&pAC->SlowPathLock);
+
+	/* setup phy_id blink timer */
+	pAC->BlinkTimer.function = SkGeBlinkTimer;
+	pAC->BlinkTimer.data = (unsigned long) dev;
+	init_timer(&pAC->BlinkTimer);
 
 	/* level 0 init common modules here */
 	
