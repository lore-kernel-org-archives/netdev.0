From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (23/23) sk98: eliminate large controller scratch pad
 elements
Date: Thu, 11 Nov 2004 16:11:54 -0800
Message-ID: <20041111161154.2fc006b8@zqx3.pdx.osdl.net>
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

Get rid of 44K of space in the driver structure which was just
being used as a scratch pad when making the calls to read stats.
PnmiStruct can just be kmalloc'd/kfree in those cases.

PNMI initialization can be done in one place using existing
macro's for consistency

Don't need to cast and mask when converting u64 to u32.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-09 15:29:24 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-09 15:29:24 -08:00
@@ -385,9 +385,9 @@
 	spinlock_t	SlowPathLock;	/* Normal IRQ lock */
 	struct timer_list BlinkTimer;	/* for LED blinking */
 	int		LedsOn;
-	SK_PNMI_STRUCT_DATA PnmiStruct;	/* structure to get all Pnmi-Data */
-	int			RlmtMode;	/* link check mode to set */
-	int			RlmtNets;	/* Number of nets */
+
+	int		RlmtMode;	/* link check mode to set */
+	int		RlmtNets;	/* Number of nets */
 	
 	SK_IOC		IoBase;		/* register set of adapter */
 	int		BoardLevel;	/* level of active hw init (0-2) */
@@ -425,7 +425,6 @@
 #ifdef SK_DIAG_SUPPORT
 	SK_U32		DiagModeActive;		/* is diag active?	*/
 	SK_BOOL		DiagFlowCtrl;		/* for control purposes	*/
-	SK_PNMI_STRUCT_DATA PnmiBackup;		/* backup structure for all Pnmi-Data */
 	SK_BOOL         WasIfUp[SK_MAX_MACS];   /* for OpenClose while 
 						 * DIAG is busy with NIC 
 						 */
diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-09 15:29:24 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-09 15:29:24 -08:00
@@ -297,9 +297,26 @@
 static void getEthtoolStats(struct net_device *dev,
 			    struct ethtool_stats *stats, u64 *data)
 {
-	const DEV_NET	*pNet = netdev_priv(dev);
-	const SK_AC *pAC = pNet->pAC;
-	const SK_PNMI_STRUCT_DATA *pPnmiStruct = &pAC->PnmiStruct;
+	DEV_NET	*pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	unsigned long flags;
+	unsigned int size;
+	int err;
+	SK_PNMI_STRUCT_DATA *pPnmiStruct;
+
+
+	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
+	if (!pPnmiStruct)
+		return;
+
+	memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
+	size = sizeof(*pPnmiStruct);
+	spin_lock_irqsave(&pAC->SlowPathLock, flags);
+	err = SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &size, pNet->NetNr);
+	spin_unlock_irqrestore(&pAC->SlowPathLock, flags);
+
+	if (err)
+		return;
 
 	*data++ = pPnmiStruct->Stat[0].StatRxOkCts;
 	*data++ = pPnmiStruct->Stat[0].StatTxOkCts;
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-09 15:29:23 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-09 15:29:24 -08:00
@@ -214,7 +214,7 @@
 static void	ClearTxRing(SK_AC*, TX_PORT*);
 static int	SkGeChangeMtu(struct net_device *dev, int new_mtu);
 static void	PortReInitBmu(SK_AC*, int);
-static int	SkGeIocMib(DEV_NET*, unsigned int, int);
+static unsigned int SkGeIocMib(DEV_NET*, SK_PNMI_STRUCT_DATA *,unsigned int, int);
 static int	SkGeInitPCI(SK_AC *pAC);
 static void	StartDrvCleanupTimer(SK_AC *pAC);
 static void	StopDrvCleanupTimer(SK_AC *pAC);
@@ -457,13 +457,6 @@
 	pAC->HWRevision = (((pAC->GIni.GIPciHwRev >> 4) & 0x0F)*10) +
 		(pAC->GIni.GIPciHwRev & 0x0F);
 
-	/* Set driver globals */
-	pAC->Pnmi.pDriverFileName    = DRIVER_FILE_NAME;
-	pAC->Pnmi.pDriverReleaseDate = DRIVER_REL_DATE;
-
-#ifdef SK_DIAG_SUPPORT
-	pAC->PnmiBackup = pAC->PnmiStruct;
-#endif
 
 	pci_set_drvdata(pdev, dev);
 	return 0;
@@ -780,8 +773,6 @@
 static int SkGeBoardInit(struct net_device *dev, SK_AC *pAC)
 {
 short	i;
-char	*DescrString = "sk98lin: Driver for Linux"; /* this is given to PNMI */
-char	*VerStr	= VER_STRING;
 int	Ret;			/* return code of request_irq */
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
@@ -821,8 +812,10 @@
 	pAC->BoardLevel = SK_INIT_DATA;
 	pAC->RxBufSize  = ETH_BUF_SIZE;
 
-	SK_PNMI_SET_DRIVER_DESCR(pAC, DescrString);
-	SK_PNMI_SET_DRIVER_VER(pAC, VerStr);
+	SK_PNMI_SET_DRIVER_DESCR(pAC, "sk98lin: Driver for Linux");
+	SK_PNMI_SET_DRIVER_VER(pAC, VER_STRING);
+	SK_PNMI_SET_DRIVER_FILENAME(pAC, DRIVER_FILE_NAME);
+	SK_PNMI_SET_DRIVER_RELDATE(pAC, DRIVER_REL_DATE);
 
 	/* level 1 init common modules here (HW init) */
 	if (SkGeInit(pAC, pAC->IoBase, SK_INIT_IO) != 0) {
@@ -1657,9 +1650,6 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeClose: done "));
 
-#ifdef SK_DIAG_SUPPORT
-	pAC->PnmiBackup = pAC->PnmiStruct;
-#endif
 	pAC->MaxPorts--;
 
 	return (0);
@@ -3034,69 +3024,60 @@
 SK_AC	*pAC = pNet->pAC;
 SK_PNMI_STRUCT_DATA *pPnmiStruct;       /* structure for all Pnmi-Data */
 SK_PNMI_STAT    *pPnmiStat;             /* pointer to virtual XMAC stat. data */
-SK_PNMI_CONF    *pPnmiConf;             /* pointer to virtual link config. */
 unsigned int    Size;                   /* size of pnmi struct */
 unsigned long	Flags;			/* for spin lock */
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeStats starts now...\n"));
-	pPnmiStruct = &pAC->PnmiStruct;
 
-#ifdef SK_DIAG_SUPPORT
-        if ((pAC->DiagModeActive == DIAG_NOTACTIVE) &&
-                (pAC->BoardLevel == SK_INIT_RUN)) {
-#endif
-        SK_MEMSET(pPnmiStruct, 0, sizeof(SK_PNMI_STRUCT_DATA));
+	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_ATOMIC);
+	if (!pPnmiStruct)
+		goto out;
+
+	memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
+        Size = sizeof(*pPnmiStruct);
+
         spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-        Size = SK_PNMI_STRUCT_SIZE;
 	SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
-
         spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-#ifdef SK_DIAG_SUPPORT
-	}
-#endif
 
         pPnmiStat = &pPnmiStruct->Stat[0];
-        pPnmiConf = &pPnmiStruct->Conf[0];
 
-	pAC->stats.rx_packets = (SK_U32) pPnmiStruct->RxDeliveredCts & 0xFFFFFFFF;
-	pAC->stats.tx_packets = (SK_U32) pPnmiStat->StatTxOkCts & 0xFFFFFFFF;
-	pAC->stats.rx_bytes = (SK_U32) pPnmiStruct->RxOctetsDeliveredCts;
-	pAC->stats.tx_bytes = (SK_U32) pPnmiStat->StatTxOctetsOkCts;
+	memset(&pAC->stats, 0, sizeof(struct net_device_stats));
+	pAC->stats.rx_packets = pPnmiStruct->RxDeliveredCts;
+	pAC->stats.tx_packets = pPnmiStat->StatTxOkCts;
+	pAC->stats.rx_bytes = pPnmiStruct->RxOctetsDeliveredCts;
+	pAC->stats.tx_bytes = pPnmiStat->StatTxOctetsOkCts;
 	
-        if (dev->mtu <= 1500) {
-                pAC->stats.rx_errors = (SK_U32) pPnmiStruct->InErrorsCts & 0xFFFFFFFF;
-        } else {
-                pAC->stats.rx_errors = (SK_U32) ((pPnmiStruct->InErrorsCts -
-                        pPnmiStat->StatRxTooLongCts) & 0xFFFFFFFF);
-	}
-
+	pAC->stats.rx_errors = pPnmiStruct->InErrorsCts;
+        if (dev->mtu > 1500)
+                pAC->stats.rx_errors -= pPnmiStat->StatRxTooLongCts;
 
 	if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && pAC->HWRevision < 12)
-		pAC->stats.rx_errors = pAC->stats.rx_errors - pPnmiStat->StatRxShortsCts;
+		pAC->stats.rx_errors -= pPnmiStat->StatRxShortsCts;
 
-	pAC->stats.tx_errors = (SK_U32) pPnmiStat->StatTxSingleCollisionCts & 0xFFFFFFFF;
-	pAC->stats.rx_dropped = (SK_U32) pPnmiStruct->RxNoBufCts & 0xFFFFFFFF;
-	pAC->stats.tx_dropped = (SK_U32) pPnmiStruct->TxNoBufCts & 0xFFFFFFFF;
-	pAC->stats.multicast = (SK_U32) pPnmiStat->StatRxMulticastOkCts & 0xFFFFFFFF;
-	pAC->stats.collisions = (SK_U32) pPnmiStat->StatTxSingleCollisionCts & 0xFFFFFFFF;
+	pAC->stats.tx_errors = pPnmiStat->StatTxSingleCollisionCts;
+	pAC->stats.rx_dropped = pPnmiStruct->RxNoBufCts;
+	pAC->stats.tx_dropped = pPnmiStruct->TxNoBufCts;
+	pAC->stats.multicast = pPnmiStat->StatRxMulticastOkCts;
+	pAC->stats.collisions = pPnmiStat->StatTxSingleCollisionCts;
 
 	/* detailed rx_errors: */
-	pAC->stats.rx_length_errors = (SK_U32) pPnmiStat->StatRxRuntCts & 0xFFFFFFFF;
-	pAC->stats.rx_over_errors = (SK_U32) pPnmiStat->StatRxFifoOverflowCts & 0xFFFFFFFF;
-	pAC->stats.rx_crc_errors = (SK_U32) pPnmiStat->StatRxFcsCts & 0xFFFFFFFF;
-	pAC->stats.rx_frame_errors = (SK_U32) pPnmiStat->StatRxFramingCts & 0xFFFFFFFF;
-	pAC->stats.rx_fifo_errors = (SK_U32) pPnmiStat->StatRxFifoOverflowCts & 0xFFFFFFFF;
-	pAC->stats.rx_missed_errors = (SK_U32) pPnmiStat->StatRxMissedCts & 0xFFFFFFFF;
+	pAC->stats.rx_length_errors = pPnmiStat->StatRxRuntCts;
+	pAC->stats.rx_over_errors = pPnmiStat->StatRxFifoOverflowCts;
+	pAC->stats.rx_crc_errors = pPnmiStat->StatRxFcsCts;
+	pAC->stats.rx_frame_errors = pPnmiStat->StatRxFramingCts;
+	pAC->stats.rx_fifo_errors = pPnmiStat->StatRxFifoOverflowCts;
+	pAC->stats.rx_missed_errors = pPnmiStat->StatRxMissedCts;
 
 	/* detailed tx_errors */
-	pAC->stats.tx_aborted_errors = (SK_U32) 0;
-	pAC->stats.tx_carrier_errors = (SK_U32) pPnmiStat->StatTxCarrierCts & 0xFFFFFFFF;
-	pAC->stats.tx_fifo_errors = (SK_U32) pPnmiStat->StatTxFifoUnderrunCts & 0xFFFFFFFF;
-	pAC->stats.tx_heartbeat_errors = (SK_U32) pPnmiStat->StatTxCarrierCts & 0xFFFFFFFF;
-	pAC->stats.tx_window_errors = (SK_U32) 0;
+	pAC->stats.tx_carrier_errors = pPnmiStat->StatTxCarrierCts;
+	pAC->stats.tx_fifo_errors = pPnmiStat->StatTxFifoUnderrunCts;
+	pAC->stats.tx_heartbeat_errors = pPnmiStat->StatTxCarrierCts;
 
-	return(&pAC->stats);
+	kfree(pPnmiStruct);
+ out:
+	return &pAC->stats;
 } /* SkGeStats */
 
 
@@ -3119,9 +3100,7 @@
 SK_AC		*pAC;
 void		*pMemBuf;
 SK_GE_IOCTL	Ioctl;
-unsigned int	Err = 0;
-int		Size = 0;
-int             Ret = 0;
+int		Err = 0;
 unsigned int	Length = 0;
 int		HeaderLength = sizeof(SK_U32) + sizeof(SK_U32);
 
@@ -3140,27 +3119,35 @@
 	case SK_IOCTL_PRESETMIB:
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
  	case SK_IOCTL_GETMIB:
-		if(copy_from_user(&pAC->PnmiStruct, Ioctl.pData,
-			Ioctl.Len<sizeof(pAC->PnmiStruct)?
-			Ioctl.Len : sizeof(pAC->PnmiStruct))) {
-			return -EFAULT;
-		}
-		Size = SkGeIocMib(pNet, Ioctl.Len, cmd);
-		if(copy_to_user(Ioctl.pData, &pAC->PnmiStruct,
-			Ioctl.Len<Size? Ioctl.Len : Size)) {
-			return -EFAULT;
-		}
-		Ioctl.Len = Size;
-		if(copy_to_user(rq->ifr_data, &Ioctl, sizeof(SK_GE_IOCTL))) {
+	{
+		SK_PNMI_STRUCT_DATA *pPnmiStruct;
+
+		pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
+		if (!pPnmiStruct)
+			return -ENOMEM;
+
+		memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
+
+		if (copy_from_user(pPnmiStruct, Ioctl.pData, 
+				   min(sizeof(*pPnmiStruct), Ioctl.Len)))
 			return -EFAULT;
+
+		Length = SkGeIocMib(pNet, pPnmiStruct, Ioctl.Len, cmd);
+		if (copy_to_user(Ioctl.pData, pPnmiStruct, 
+				 min(Length, Ioctl.Len)))
+			Err = -EFAULT;
+		else {
+			Ioctl.Len = Length;
+			if (copy_to_user(rq->ifr_data, &Ioctl, 
+					 sizeof(SK_GE_IOCTL))) 
+				Err = -EFAULT;
 		}
+		kfree(pPnmiStruct);
 		break;
+	}
 	case SK_IOCTL_GEN:
-		if (Ioctl.Len < (sizeof(pAC->PnmiStruct) + HeaderLength)) {
-			Length = Ioctl.Len;
-		} else {
-			Length = sizeof(pAC->PnmiStruct) + HeaderLength;
-		}
+		Length = min(Ioctl.Len, SK_PNMI_STRUCT_SIZE + HeaderLength);
+
 		if (NULL == (pMemBuf = kmalloc(Length, GFP_KERNEL))) {
 			return -ENOMEM;
 		}
@@ -3168,16 +3155,16 @@
 			Err = -EFAULT;
 			goto fault_gen;
 		}
-		if ((Ret = SkPnmiGenIoctl(pAC, pAC->IoBase, pMemBuf, &Length, 0)) < 0) {
+		if ((Err = SkPnmiGenIoctl(pAC, pAC->IoBase, pMemBuf, &Length, 0)) < 0) {
 			Err = -EFAULT;
 			goto fault_gen;
 		}
-		if(copy_to_user(Ioctl.pData, pMemBuf, Length) ) {
+		if (copy_to_user(Ioctl.pData, pMemBuf, Length) ) {
 			Err = -EFAULT;
 			goto fault_gen;
 		}
 		Ioctl.Len = Length;
-		if(copy_to_user(rq->ifr_data, &Ioctl, sizeof(SK_GE_IOCTL))) {
+		if (copy_to_user(rq->ifr_data, &Ioctl, sizeof(SK_GE_IOCTL))) {
 			Err = -EFAULT;
 			goto fault_gen;
 		}
@@ -3187,15 +3174,14 @@
 #ifdef SK_DIAG_SUPPORT
        case SK_IOCTL_DIAG:
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
-		if (Ioctl.Len < (sizeof(pAC->PnmiStruct) + HeaderLength)) {
-			Length = Ioctl.Len;
-		} else {
-			Length = sizeof(pAC->PnmiStruct) + HeaderLength;
-		}
+
+		Length = min(Ioctl.Len, SK_PNMI_STRUCT_SIZE + HeaderLength);
+
 		if (NULL == (pMemBuf = kmalloc(Length, GFP_KERNEL))) {
 			return -ENOMEM;
 		}
-		if(copy_from_user(pMemBuf, Ioctl.pData, Length)) {
+
+		if (copy_from_user(pMemBuf, Ioctl.pData, Length)) {
 			Err = -EFAULT;
 			goto fault_diag;
 		}
@@ -3230,7 +3216,6 @@
 
 } /* SkGeIoctl */
 
-
 /*****************************************************************************
  *
  * 	SkGeIocMib - handle a GetMib, SetMib- or PresetMib-ioctl message
@@ -3248,8 +3233,9 @@
  * Returns:
  *	returned size from PNMI call
  */
-static int SkGeIocMib(
+static unsigned int SkGeIocMib(
 DEV_NET		*pNet,	/* pointer to the adapter context */
+SK_PNMI_STRUCT_DATA *pPnmiStruct,       /* structure for all Pnmi-Data */
 unsigned int	Size,	/* length of ioctl data */
 int		mode)	/* flag for set/preset */
 {
@@ -3263,16 +3249,13 @@
 	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
 	switch(mode) {
 	case SK_IOCTL_GETMIB:
-		SkPnmiGetStruct(pAC, pAC->IoBase, &pAC->PnmiStruct, &Size,
-			pNet->NetNr);
+		SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
 		break;
 	case SK_IOCTL_PRESETMIB:
-		SkPnmiPreSetStruct(pAC, pAC->IoBase, &pAC->PnmiStruct, &Size,
-			pNet->NetNr);
+		SkPnmiPreSetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
 		break;
 	case SK_IOCTL_SETMIB:
-		SkPnmiSetStruct(pAC, pAC->IoBase, &pAC->PnmiStruct, &Size,
-			pNet->NetNr);
+		SkPnmiSetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
 		break;
 	default:
 		break;
@@ -4689,8 +4672,6 @@
 	DEV_NET *pNet = netdev_priv(pAc->dev[0]);
 	SK_AC   *pAC  = pNet->pAC;
 
-	pAc->PnmiBackup = pAC->PnmiStruct;
-
 	pAC->DiagModeActive = DIAG_ACTIVE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
 		if (netif_running(pAC->dev[0])) {
@@ -4730,7 +4711,6 @@
 int SkDrvLeaveDiagMode(
 SK_AC   *pAc)   /* pointer to adapter control context */
 { 
-	pAc->PnmiStruct = pAc->PnmiBackup;
 	pAc->DiagModeActive    = DIAG_NOTACTIVE;
 	pAc->Pnmi.DiagAttached = SK_DIAG_IDLE;
         if (pAc->WasIfUp[0] == SK_TRUE) {
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-11-09 15:29:23 -08:00
+++ b/drivers/net/sk98lin/skproc.c	2004-11-09 15:29:23 -08:00
@@ -60,33 +60,26 @@
 	struct net_device *dev = seq->private;
 	DEV_NET			*pNet = netdev_priv(dev);
 	SK_AC			*pAC = pNet->pAC;
-	SK_PNMI_STRUCT_DATA 	*pPnmiStruct = &pAC->PnmiStruct;
+	SK_PNMI_STRUCT_DATA 	*pPnmiStruct;
 	unsigned long		Flags;	
 	unsigned int		Size;
 	char			sens_msg[50];
 	int 			t;
 	int 			i;
 
+	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
+	if (!pPnmiStruct)
+		return -ENOMEM;
+
 	/* NetIndex in GetStruct is now required, zero is only dummy */
 	for (t=pAC->GIni.GIMacsFound; t > 0; t--) {
 		if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 1)
 			t--;
 
+		memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
 		spin_lock_irqsave(&pAC->SlowPathLock, Flags);
 		Size = SK_PNMI_STRUCT_SIZE;
-#ifdef SK_DIAG_SUPPORT
-		if (pAC->BoardLevel == SK_INIT_DATA) {
-			pAC->PnmiStruct = pAC->PnmiBackup;
-			if (pAC->DiagModeActive == DIAG_NOTACTIVE) {
-				pAC->Pnmi.DiagAttached = SK_DIAG_IDLE;
-			}
-		} else {
-			SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, t-1);
-		}
-#else
-		SkPnmiGetStruct(pAC, pAC->IoBase, 
-				pPnmiStruct, &Size, t-1);
-#endif
+		SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, t-1);
 		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 	
 		if (pAC->dev[t-1] == dev) {
@@ -240,6 +233,7 @@
 				
 		}
 	}
+	kfree(pPnmiStruct);
 	return 0;
 }
 
