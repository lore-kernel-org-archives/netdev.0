From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/23) sk98: ethtool pause param support
Date: Thu, 11 Nov 2004 15:55:38 -0800
Message-ID: <20041111155538.4d98d9b9@zqx3.pdx.osdl.net>
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

The basic stuff comes from the newer code from SysKonnect, but there
code had ugly way to find the PNMI instance. This driver seems full
of places where they do unnecessary board/port bookeeping (*sigh*)

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-03 14:39:56 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-03 14:39:56 -08:00
@@ -163,6 +163,15 @@
 	return 0;
 }
 
+/*
+ * MIB infrastructure uses instance value starting at 1
+ * based on board and port.
+ */
+static inline u32 pnmiInstance(const DEV_NET *pNet)
+{
+	return 1 + (pNet->pAC->RlmtNets == 2) + pNet->PortNr;
+}
+
 /*****************************************************************************
  *
  *	setSettings - configures the settings of a selected adapter
@@ -200,7 +209,7 @@
 		*buf = (ecmd->duplex == DUPLEX_FULL) 
 			? SK_LMODE_AUTOFULL : SK_LMODE_AUTOHALF;
 	
-	instance = 1 + (pAC->RlmtNets == 2) + pNet->PortNr;
+	instance = pnmiInstance(pNet);
 	if (SkPnmiSetVar(pAC, pAC->IoBase, OID_SKGE_LINK_MODE, 
 			   &buf, &len, instance, pNet->NetNr) != SK_PNMI_ERR_OK)
 		return -EINVAL;
@@ -437,6 +446,102 @@
 	return 0;
 }
 
+/*****************************************************************************
+ *
+ * 	getPauseParams - retrieves the pause parameters
+ *
+ * Description:
+ *	All current pause parameters of a selected adapter are placed 
+ *	in the passed ethtool_pauseparam structure and are returned.
+ *
+ * Returns:	N/A
+ *
+ */
+static void getPauseParams(struct net_device *dev, struct ethtool_pauseparam *epause) 
+{
+	DEV_NET	*pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	SK_GEPORT *pPort = &pAC->GIni.GP[pNet->PortNr];
+
+	epause->rx_pause = (pPort->PFlowCtrlMode == SK_FLOW_MODE_SYMMETRIC) ||
+		  (pPort->PFlowCtrlMode == SK_FLOW_MODE_SYM_OR_REM);
+
+	epause->tx_pause = epause->rx_pause || (pPort->PFlowCtrlMode == SK_FLOW_MODE_LOC_SEND);
+	epause->autoneg = epause->rx_pause || epause->tx_pause;
+}
+
+/*****************************************************************************
+ *
+ *	setPauseParams - configures the pause parameters of an adapter
+ *
+ * Description:
+ *	This function sets the Rx or Tx pause parameters 
+ *
+ * Returns:
+ *	==0:	everything fine, no error
+ *	!=0:	the return value is the error code of the failure 
+ */
+static int setPauseParams(struct net_device *dev , struct ethtool_pauseparam *epause)
+{
+	DEV_NET	*pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	SK_GEPORT *pPort = &pAC->GIni.GP[pNet->PortNr];
+	u32	instance = pnmiInstance(pNet);
+	struct ethtool_pauseparam old;
+	u8	oldspeed = pPort->PLinkSpeedUsed;
+	char	buf[4];
+	int	len = 1;
+	int ret;
+
+	/*
+	** we have to determine the current settings to see if 
+	** the operator requested any modification of the flow 
+	** control parameters...
+	*/
+	getPauseParams(dev, &old);
+
+	/*
+	** perform modifications regarding the changes 
+	** requested by the operator
+	*/
+	if (epause->autoneg != old.autoneg) 
+		*buf = epause->autoneg ? SK_FLOW_MODE_NONE : SK_FLOW_MODE_SYMMETRIC;
+	else {
+		if (epause->rx_pause && epause->tx_pause) 
+			*buf = SK_FLOW_MODE_SYMMETRIC;
+		else if (epause->rx_pause && !epause->tx_pause)
+			*buf =  SK_FLOW_MODE_SYM_OR_REM;
+		else if (!epause->rx_pause && epause->tx_pause)
+			*buf =  SK_FLOW_MODE_LOC_SEND;
+		else
+			*buf = SK_FLOW_MODE_NONE;
+	}
+
+	ret = SkPnmiSetVar(pAC, pAC->IoBase, OID_SKGE_FLOWCTRL_MODE,
+			 &buf, &len, instance, pNet->NetNr);
+
+	if (ret != SK_PNMI_ERR_OK) {
+		SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_CTRL,
+			   ("ethtool (sk98lin): error changing rx/tx pause (%i)\n", ret));
+		goto err;
+	}
+
+	/*
+	** It may be that autoneg has been disabled! Therefore
+	** set the speed to the previously used value...
+	*/
+	if (!epause->autoneg) {
+		len = 1;
+		ret = SkPnmiSetVar(pAC, pAC->IoBase, OID_SKGE_SPEED_MODE, 
+				   &oldspeed, &len, instance, pNet->NetNr);
+		if (ret != SK_PNMI_ERR_OK) 
+			SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_CTRL,
+				   ("ethtool (sk98lin): error setting speed (%i)\n", ret));
+	}
+ err:
+        return ret ? -EIO : 0;
+}
+
 struct ethtool_ops SkGeEthtoolOps = {
 	.get_settings		= getSettings,
 	.set_settings		= setSettings,
@@ -445,4 +550,6 @@
 	.get_stats_count	= getStatsCount,
 	.get_ethtool_stats	= getEthtoolStats,
 	.phys_id		= locateDevice,
+	.get_pauseparam		= getPauseParams,
+	.set_pauseparam		= setPauseParams,
 };
