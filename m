From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (23/25) sk98: eliminate Pnmi scratchpad
Date: Fri, 19 Nov 2004 10:43:31 -0800
Message-ID: <20041119104331.70a45312@zqx3.pdx.osdl.net>
References: <20041115155832.264aa86f@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041115155832.264aa86f@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(Resend to deal with line wrap and other issues)
Get rid of 44K of space in the driver structure which was just
being used as a scratch pad when making the calls to read stats.
PnmiStruct can just be kmalloc'd/kfree in those cases.

PNMI initialization can be done in one place using existing
macro's for consitency

Don't need to cast and mask when converting u64 to u32.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-19 10:38:39 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-19 10:38:39 -08:00
@@ -404,9 +404,9 @@
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
@@ -445,7 +445,6 @@
 #ifdef SK_DIAG_SUPPORT
 	SK_U32		DiagModeActive;		/* is diag active?	*/
 	SK_BOOL		DiagFlowCtrl;		/* for control purposes	*/
-	SK_PNMI_STRUCT_DATA PnmiBackup;		/* backup structure for all Pnmi-Data */
 	SK_BOOL         WasIfUp[SK_MAX_MACS];   /* for OpenClose while 
 						 * DIAG is busy with NIC 
 						 */
diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-19 10:38:39 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-19 10:38:39 -08:00
@@ -261,9 +261,26 @@
 static void sk98_get_ethstats(struct net_device *dev,
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
--- a/drivers/net/sk98lin/skge.c	2004-11-19 10:38:39 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-19 10:38:39 -08:00
@@ -205,7 +205,7 @@
 static void	ClearTxRing(SK_AC*, TX_PORT*);
 static int	SkGeChangeMtu(struct net_device *dev, int new_mtu);
 static void	PortReInitBmu(SK_AC*, int);
-static int	SkGeIocMib(DEV_NET*, unsigned int, int);
+static unsigned int SkGeIocMib(DEV_NET*, SK_PNMI_STRUCT_DATA *,unsigned int, int);
 static int	SkGeInitPCI(SK_AC *pAC);
 static void	StartDrvCleanupTimer(SK_AC *pAC);
 static void	StopDrvCleanupTimer(SK_AC *pAC);
@@ -1356,10 +1356,6 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeClose: done "));
 
-	SK_MEMSET(&(pAC->PnmiBackup), 0, sizeof(SK_PNMI_STRUCT_DATA));
-	SK_MEMCPY(&(pAC->PnmiBackup), &(pAC->PnmiStruct), 
-			sizeof(SK_PNMI_STRUCT_DATA));
-
 	pAC->MaxPorts--;
 
 	return (0);
@@ -2736,13 +2732,18 @@
 SK_AC	*pAC = pNet->pAC;
 SK_PNMI_STRUCT_DATA *pPnmiStruct;       /* structure for all Pnmi-Data */
 SK_PNMI_STAT    *pPnmiStat;             /* pointer to virtual XMAC stat. data */
-SK_PNMI_CONF    *pPnmiConf;             /* pointer to virtual link config. */
 unsigned int    Size;                   /* size of pnmi struct */
 unsigned long	Flags;			/* for spin lock */
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeStats starts now...\n"));
-	pPnmiStruct = &pAC->PnmiStruct;
+
+ 	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_ATOMIC);
+ 	if (!pPnmiStruct)
+ 		goto out;
+ 
+ 	memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
+	Size = sizeof(*pPnmiStruct);
 
 #ifdef SK_DIAG_SUPPORT
         if ((pAC->DiagModeActive == DIAG_NOTACTIVE) &&
@@ -2758,7 +2759,6 @@
 #endif
 
         pPnmiStat = &pPnmiStruct->Stat[0];
-        pPnmiConf = &pPnmiStruct->Conf[0];
 
 	pAC->stats.rx_packets = (SK_U32) pPnmiStruct->RxDeliveredCts & 0xFFFFFFFF;
 	pAC->stats.tx_packets = (SK_U32) pPnmiStat->StatTxOkCts & 0xFFFFFFFF;
@@ -2797,7 +2797,9 @@
 	pAC->stats.tx_heartbeat_errors = (SK_U32) pPnmiStat->StatTxCarrierCts & 0xFFFFFFFF;
 	pAC->stats.tx_window_errors = (SK_U32) 0;
 
-	return(&pAC->stats);
+	kfree(pPnmiStruct);
+  out:
+	return &pAC->stats;
 } /* SkGeStats */
 
 
@@ -2821,9 +2823,7 @@
 void		*pMemBuf;
 struct pci_dev  *pdev = NULL;
 SK_GE_IOCTL	Ioctl;
-unsigned int	Err = 0;
-int		Size = 0;
-int             Ret = 0;
+int		Err = 0;
 unsigned int	Length = 0;
 int		HeaderLength = sizeof(SK_U32) + sizeof(SK_U32);
 
@@ -2842,27 +2842,35 @@
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
@@ -2870,16 +2878,16 @@
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
@@ -2889,15 +2897,14 @@
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
@@ -2933,7 +2940,6 @@
 
 } /* SkGeIoctl */
 
-
 /*****************************************************************************
  *
  * 	SkGeIocMib - handle a GetMib, SetMib- or PresetMib-ioctl message
@@ -2951,8 +2957,9 @@
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
@@ -2966,16 +2973,13 @@
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
@@ -4386,9 +4390,6 @@
 	DEV_NET *pNet = netdev_priv(pAc->dev[0]);
 	SK_AC   *pAC  = pNet->pAC;
 
-	SK_MEMCPY(&(pAc->PnmiBackup), &(pAc->PnmiStruct), 
-			sizeof(SK_PNMI_STRUCT_DATA));
-
 	pAC->DiagModeActive = DIAG_ACTIVE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
 		if (netif_running(pAC->dev[0])) {
@@ -4430,8 +4431,6 @@
 int SkDrvLeaveDiagMode(
 SK_AC   *pAc)   /* pointer to adapter control context */
 { 
-	SK_MEMCPY(&(pAc->PnmiStruct), &(pAc->PnmiBackup), 
-			sizeof(SK_PNMI_STRUCT_DATA));
 	pAc->DiagModeActive    = DIAG_NOTACTIVE;
 	pAc->Pnmi.DiagAttached = SK_DIAG_IDLE;
         if (pAc->WasIfUp[0] == SK_TRUE) {
@@ -4823,9 +4822,6 @@
 	/* Set driver globals */
 	pAC->Pnmi.pDriverFileName    = DRIVER_FILE_NAME;
 	pAC->Pnmi.pDriverReleaseDate = DRIVER_REL_DATE;
-
-	memset(&pAC->PnmiBackup, 0, sizeof(SK_PNMI_STRUCT_DATA));
-	memcpy(&pAC->PnmiBackup, &pAC->PnmiStruct, sizeof(SK_PNMI_STRUCT_DATA));
 
 #ifdef USE_SK_RX_CHECKSUM
 	pAC->RxPort[0].UseRxCsum = SK_TRUE;
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-11-19 10:38:39 -08:00
+++ b/drivers/net/sk98lin/skproc.c	2004-11-19 10:38:39 -08:00
@@ -63,33 +63,26 @@
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
-			SK_MEMCPY(&(pAC->PnmiStruct), &(pAC->PnmiBackup), sizeof(SK_PNMI_STRUCT_DATA));
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
@@ -243,6 +236,7 @@
 				
 		}
 	}
+	kfree(pPnmiStruct);
 	return 0;
 }
 
