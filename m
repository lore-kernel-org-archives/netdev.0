From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/23) sk98: cleanout unnecessary controller elements
Date: Thu, 11 Nov 2004 15:55:58 -0800
Message-ID: <20041111155558.22c8860a@zqx3.pdx.osdl.net>
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

Catchall cleanup patch:
	* get rid of obfuscating #define's
	* eliminate structure elements in the controller structure
	  that are never used or only used in one context or available
	  in net_device

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-11 13:57:37 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-11 13:57:37 -08:00
@@ -96,9 +96,6 @@
 #define SK_BIG_ENDIAN
 #endif
 
-#define SK_NET_DEVICE	net_device
-
-
 /* we use gethrtime(), return unit: nanoseconds */
 #define SK_TICKS_PER_SEC	100
 
@@ -109,12 +106,11 @@
 #define SK_MAX_MACS		2
 #define SK_MAX_NETS		2
 
-#define SK_IOC			char __iomem *
-
+typedef char __iomem *SK_IOC;
 typedef struct s_DrvRlmtMbuf SK_MBUF;
 
-#define	SK_CONST64	INT64_C
-#define	SK_CONSTU64	UINT64_C
+#define	SK_CONST64(x)	(x##ll)
+#define	SK_CONSTU64(x)	(x##ull)
 
 #define SK_MEMCPY(dest,src,size)	memcpy(dest,src,size)
 #define SK_MEMCMP(s1,s2,size)		memcmp(s1,s2,size)
@@ -143,27 +139,21 @@
 #define t_uscalar_t	unsigned int
 #define uintptr_t	unsigned long
 
-#define __CONCAT__(A,B) A##B
+#ifdef DEBUG
 
-#define INT32_C(a)		__CONCAT__(a,L)
-#define INT64_C(a)		__CONCAT__(a,LL)
-#define UINT32_C(a)		__CONCAT__(a,UL)
-#define UINT64_C(a)		__CONCAT__(a,ULL)
+#define SK_DBG_PRINTF(fmt, arg...) printk(KERN_DEBUG fmt,##arg)
 
-#ifdef DEBUG
-#define SK_DBG_PRINTF		printk
 #ifndef SK_DEBUG_CHKMOD
 #define SK_DEBUG_CHKMOD		0
 #endif
 #ifndef SK_DEBUG_CHKCAT
 #define SK_DEBUG_CHKCAT		0
 #endif
+
 /* those come from the makefile */
 #define SK_DBG_CHKMOD(pAC)	(SK_DEBUG_CHKMOD)
 #define SK_DBG_CHKCAT(pAC)	(SK_DEBUG_CHKCAT)
 
-extern void SkDbgPrintf(const char *format,...);
-
 #define SK_DBGMOD_DRV			0x00010000
 
 /**** possible driver debug categories ********************************/
@@ -184,7 +174,7 @@
 
 #define SK_ERR_LOG		SkErrorLog
 
-extern void SkErrorLog(SK_AC*, int, int, char*);
+extern void SkErrorLog(const SK_AC*, int, int, const char*);
 
 #endif
 
diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-11 13:57:37 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-11 13:57:37 -08:00
@@ -266,11 +266,9 @@
 typedef struct s_DevNet DEV_NET;
 
 struct s_DevNet {
+	SK_AC   	*pAC;
 	int             PortNr;
 	int             NetNr;
-	int             Mtu;
-	int             Up;
-	SK_AC   *pAC;
 };  
 
 typedef struct s_TxPort		TX_PORT;
@@ -356,10 +354,6 @@
 	SK_TIMER        ModTimer; /* just some timer */
 };
 
-typedef struct s_PerStrm	PER_STRM;
-
-#define SK_ALLOC_IRQ	0x00000001
-
 #ifdef SK_DIAG_SUPPORT
 #define	DIAG_ACTIVE		1
 #define	DIAG_NOTACTIVE		0
@@ -390,31 +384,17 @@
 	
 	SK_IOC		IoBase;		/* register set of adapter */
 	int		BoardLevel;	/* level of active hw init (0-2) */
-	char		DeviceStr[80];	/* adapter string from vpd */
-	SK_U32		AllocFlag;	/* flag allocation of resources */
 	struct pci_dev	*PciDev;	/* for access to pci config space */
-	SK_U32		PciDevId;	/* pci device id */
-	struct SK_NET_DEVICE	*dev[2];	/* pointer to device struct */
-	char		Name[30];	/* driver name */
+	struct net_device *dev[2];	/* pointer to device struct */
 
 	int		RxBufSize;	/* length of receive buffers */
         struct net_device_stats stats;	/* linux 'netstat -i' statistics */
 	int		Index;		/* internal board index number */
 
 	/* adapter RAM sizes for queues of active port */
-	int		RxQueueSize;	/* memory used for receive queue */
-	int		TxSQueueSize;	/* memory used for sync. tx queue */
-	int		TxAQueueSize;	/* memory used for async. tx queue */
-
-	int		PromiscCount;	/* promiscuous mode counter  */
-	int		AllMultiCount;  /* allmulticast mode counter */
-	int		MulticCount;	/* number of different MC    */
-					/*  addresses for this board */
-					/*  (may be more than HW can)*/
-
 	int		HWRevision;	/* Hardware revision */
 	int		ActivePort;	/* the active XMAC port */
-	int		MaxPorts;		/* number of activated ports */
+	int		MaxPorts;	/* number of activated ports */
 	int		TxDescrPerRing;	/* # of descriptors per tx ring */
 	int		RxDescrPerRing;	/* # of descriptors per rx ring */
 
@@ -434,7 +414,6 @@
 	DIM_INFO        DynIrqModInfo;  /* all data related to DIM */
 
 	/* Only for tests */
-	int		PortUp;
 	int		PortDown;
 	int		ChipsetType;	/*  Chipset family type 
 					 *  0 == Genesis family support
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-11 13:57:37 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-11 13:57:37 -08:00
@@ -189,23 +189,23 @@
  *
  ******************************************************************************/
 
-static void	FreeResources(struct SK_NET_DEVICE *dev);
-static int	SkGeBoardInit(struct SK_NET_DEVICE *dev, SK_AC *pAC);
+static void	FreeResources(struct net_device *dev);
+static int	SkGeBoardInit(struct net_device *dev, SK_AC *pAC);
 static SK_BOOL	BoardAllocMem(SK_AC *pAC);
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
 static void	SetupRing(SK_AC*, void*, uintptr_t, RXD**, RXD**, RXD**, int*, SK_BOOL);
 static SkIsrRetVar	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
 static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
-static int	SkGeOpen(struct SK_NET_DEVICE *dev);
-static int	SkGeClose(struct SK_NET_DEVICE *dev);
-static int	SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev);
-static int	SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p);
-static void	SkGeSetRxMode(struct SK_NET_DEVICE *dev);
-static struct	net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev);
-static int	SkGeIoctl(struct SK_NET_DEVICE *dev, struct ifreq *rq, int cmd);
+static int	SkGeOpen(struct net_device *dev);
+static int	SkGeClose(struct net_device *dev);
+static int	SkGeXmit(struct sk_buff *skb, struct net_device *dev);
+static int	SkGeSetMacAddr(struct net_device *dev, void *p);
+static void	SkGeSetRxMode(struct net_device *dev);
+static struct	net_device_stats *SkGeStats(struct net_device *dev);
+static int	SkGeIoctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void	GetConfiguration(SK_AC*);
-static void	ProductStr(SK_AC*);
+static void	PrintProductStr(const char *, SK_AC*);
 static int	XmitFrame(SK_AC*, TX_PORT*, struct sk_buff*);
 static void	FreeTxDescriptors(SK_AC*pAC, TX_PORT*);
 static void	FillRxRing(SK_AC*, RX_PORT*);
@@ -215,7 +215,7 @@
 static void	ClearTxIrq(SK_AC*, int, int);
 static void	ClearRxRing(SK_AC*, RX_PORT*);
 static void	ClearTxRing(SK_AC*, TX_PORT*);
-static int	SkGeChangeMtu(struct SK_NET_DEVICE *dev, int new_mtu);
+static int	SkGeChangeMtu(struct net_device *dev, int new_mtu);
 static void	PortReInitBmu(SK_AC*, int);
 static int	SkGeIocMib(DEV_NET*, unsigned int, int);
 static int	SkGeInitPCI(SK_AC *pAC);
@@ -288,7 +288,7 @@
  */
 int SkGeInitPCI(SK_AC *pAC)
 {
-	struct SK_NET_DEVICE *dev = pAC->dev[0];
+	struct net_device *dev = pAC->dev[0];
 	struct pci_dev *pdev = pAC->PciDev;
 	int retval;
 
@@ -299,7 +299,7 @@
 	dev->mem_start = pci_resource_start (pdev, 0);
 	pci_set_master(pdev);
 
-	if (pci_request_regions(pdev, pAC->Name) != 0) {
+	if (pci_request_regions(pdev, DRIVER_FILE_NAME) != 0) {
 		retval = 2;
 		goto out_disable;
 	}
@@ -348,27 +348,16 @@
  * Returns: N/A
  *	
  */
-static void FreeResources(struct SK_NET_DEVICE *dev)
+static void FreeResources(struct net_device *dev)
 {
-SK_U32 AllocFlag;
-DEV_NET		*pNet;
-SK_AC		*pAC;
+DEV_NET	*pNet = netdev_priv(dev);
+SK_AC	*pAC = pNet->pAC;
 
-	pNet = netdev_priv(dev);
-	pAC = pNet->pAC;
-	AllocFlag = pAC->AllocFlag;
-	if (pAC->PciDev) {
-		pci_release_regions(pAC->PciDev);
-	}
-	if (AllocFlag & SK_ALLOC_IRQ) {
-		free_irq(dev->irq, dev);
-	}
-	if (pAC->IoBase) {
-		iounmap(pAC->IoBase);
-	}
-	if (pAC->pDescrMem) {
-		BoardFreeMem(pAC);
-	}
+	free_irq(dev->irq, dev);
+	iounmap(pAC->IoBase);
+	pci_release_regions(pAC->PciDev);
+
+	BoardFreeMem(pAC);
 	
 } /* FreeResources */
 
@@ -493,14 +482,12 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int __init SkGeBoardInit(struct SK_NET_DEVICE *dev, SK_AC *pAC)
+static int SkGeBoardInit(struct net_device *dev, SK_AC *pAC)
 {
 short	i;
-unsigned long Flags;
 char	*DescrString = "sk98lin: Driver for Linux"; /* this is given to PNMI */
 char	*VerStr	= VER_STRING;
 int	Ret;			/* return code of request_irq */
-SK_BOOL	DualNet;
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("IoBase: %08lX\n", (unsigned long)pAC->IoBase));
@@ -524,12 +511,9 @@
 	init_timer(&pAC->BlinkTimer);
 
 	/* level 0 init common modules here */
-	
-	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
 	/* Does a RESET on board ...*/
 	if (SkGeInit(pAC, pAC->IoBase, SK_INIT_DATA) != 0) {
 		printk("HWInit (0) failed.\n");
-		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 		return(-EAGAIN);
 	}
 	SkI2cInit(  pAC, pAC->IoBase, SK_INIT_DATA);
@@ -545,13 +529,9 @@
 	SK_PNMI_SET_DRIVER_DESCR(pAC, DescrString);
 	SK_PNMI_SET_DRIVER_VER(pAC, VerStr);
 
-	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-
 	/* level 1 init common modules here (HW init) */
-	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
 	if (SkGeInit(pAC, pAC->IoBase, SK_INIT_IO) != 0) {
 		printk("sk98lin: HWInit (1) failed.\n");
-		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 		return(-EAGAIN);
 	}
 	SkI2cInit(  pAC, pAC->IoBase, SK_INIT_IO);
@@ -574,13 +554,12 @@
 	}
 
 	pAC->BoardLevel = SK_INIT_IO;
-	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-
 	if (pAC->GIni.GIMacsFound == 2) {
-		 Ret = request_irq(dev->irq, SkGeIsr, SA_SHIRQ, pAC->Name, dev);
+		Ret = request_irq(dev->irq, SkGeIsr, SA_SHIRQ, 
+				  DRIVER_FILE_NAME, dev);
 	} else if (pAC->GIni.GIMacsFound == 1) {
 		Ret = request_irq(dev->irq, SkGeIsrOnePort, SA_SHIRQ,
-			pAC->Name, dev);
+				  DRIVER_FILE_NAME, dev);
 	} else {
 		printk(KERN_WARNING "sk98lin: Illegal number of ports: %d\n",
 		       pAC->GIni.GIMacsFound);
@@ -592,12 +571,11 @@
 		       dev->irq);
 		return -EAGAIN;
 	}
-	pAC->AllocFlag |= SK_ALLOC_IRQ;
 
 	/* Alloc memory for this board (Mem for RxD/TxD) : */
 	if(!BoardAllocMem(pAC)) {
 		printk("No memory for descriptor rings.\n");
-       		return(-EAGAIN);
+		goto out_free_irq;
 	}
 
 	SkCsSetReceiveFlags(pAC,
@@ -606,22 +584,21 @@
 	pAC->CsOfs = (pAC->CsOfs2 << 16) | pAC->CsOfs1;
 
 	BoardInitMem(pAC);
+
 	/* tschilling: New common function with minimum size check. */
-	DualNet = SK_FALSE;
-	if (pAC->RlmtNets == 2) {
-		DualNet = SK_TRUE;
-	}
-	
-	if (SkGeInitAssignRamToQueues(
-		pAC,
-		pAC->ActivePort,
-		DualNet)) {
-		BoardFreeMem(pAC);
+	if (SkGeInitAssignRamToQueues( pAC, pAC->ActivePort,
+				       (pAC->RlmtNets == 2))) {
 		printk("sk98lin: SkGeInitAssignRamToQueues failed.\n");
-		return(-EAGAIN);
+		goto out_free_mem;
 	}
 
 	return (0);
+
+ out_free_mem:
+	BoardFreeMem(pAC);
+ out_free_irq:
+	free_irq(dev->irq, dev);
+	return -EAGAIN;
 } /* SkGeBoardInit */
 
 
@@ -896,7 +873,7 @@
  */
 static SkIsrRetVar SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-struct SK_NET_DEVICE *dev = (struct SK_NET_DEVICE *)dev_id;
+struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
@@ -1045,7 +1022,7 @@
  */
 static SkIsrRetVar SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-struct SK_NET_DEVICE *dev = (struct SK_NET_DEVICE *)dev_id;
+struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
@@ -1176,7 +1153,7 @@
  *	!= 0 on error
  */
 static int SkGeOpen(
-struct SK_NET_DEVICE	*dev)
+struct net_device	*dev)
 {
 	DEV_NET			*pNet;
 	SK_AC			*pAC;
@@ -1269,8 +1246,6 @@
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 
 	pAC->MaxPorts++;
-	pNet->Up = 1;
-
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeOpen suceeded\n"));
@@ -1291,11 +1266,11 @@
  *	error code - on error
  */
 static int SkGeClose(
-struct SK_NET_DEVICE	*dev)
+struct net_device	*dev)
 {
-	DEV_NET		*pNet;
+	DEV_NET		*pNet = netdev_priv(dev);
 	DEV_NET		*newPtrNet;
-	SK_AC		*pAC;
+	SK_AC		*pAC = pNet->pAC;
 
 	unsigned long	Flags;		/* for spin lock */
 	int		i;
@@ -1305,9 +1280,6 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeClose: pAC=0x%lX ", (unsigned long)pAC));
 
-	pNet = netdev_priv(dev);
-	pAC = pNet->pAC;
-
 #ifdef SK_DIAG_SUPPORT
 	if (pAC->DiagModeActive == DIAG_ACTIVE) {
 		if (pAC->DiagFlowCtrl == SK_FALSE) {
@@ -1399,7 +1371,6 @@
 			sizeof(SK_PNMI_STRUCT_DATA));
 
 	pAC->MaxPorts--;
-	pNet->Up = 0;
 
 	return (0);
 } /* SkGeClose */
@@ -1420,7 +1391,7 @@
  * WARNING: returning 1 in 'tbusy' case caused system crashes (double
  *	allocated skb's) !!!
  */
-static int SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev)
+static int SkGeXmit(struct sk_buff *skb, struct net_device *dev)
 {
 DEV_NET		*pNet;
 SK_AC		*pAC;
@@ -2519,7 +2490,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p)
+static int SkGeSetMacAddr(struct net_device *dev, void *p)
 {
 
 DEV_NET *pNet = netdev_priv(dev);
@@ -2565,7 +2536,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static void SkGeSetRxMode(struct SK_NET_DEVICE *dev)
+static void SkGeSetRxMode(struct net_device *dev)
 {
 
 DEV_NET		*pNet;
@@ -2639,10 +2610,10 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeChangeMtu(struct SK_NET_DEVICE *dev, int NewMtu)
+static int SkGeChangeMtu(struct net_device *dev, int NewMtu)
 {
 DEV_NET		*pNet;
-DEV_NET		*pOtherNet;
+struct net_device *otherdev; 
 SK_AC		*pAC;
 unsigned long	Flags;
 int		i;
@@ -2672,11 +2643,10 @@
 	}
 #endif
 
-	pNet->Mtu = NewMtu;
-	pOtherNet = netdev_priv(pAC->dev[1 - pNet->NetNr]);
-	if ((pOtherNet->Mtu>1500) && (NewMtu<=1500) && (pOtherNet->Up==1)) {
-		return(0);
-	}
+	otherdev = pAC->dev[1 - pNet->NetNr];
+	if (NewMtu <= 1500 && otherdev != dev 
+  	    && netif_running(otherdev) && otherdev->mtu > 1500) 
+		return 0;
 
 	pAC->RxBufSize = NewMtu + 32;
 	dev->mtu = NewMtu;
@@ -2838,7 +2808,8 @@
 		EvPara.Para32[1] = -1;
 		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_START, EvPara);
 			
-		if (pOtherNet->Up) {
+		if (otherdev && netif_running(otherdev)) {
+			DEV_NET	*pOtherNet = netdev_priv(otherdev);
 			EvPara.Para32[0] = pOtherNet->PortNr;
 			SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_START, EvPara);
 		}
@@ -2848,21 +2819,8 @@
 
 	SkEventDispatcher(pAC, pAC->IoBase);
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-	
-	/*
-	** While testing this driver with latest kernel 2.5 (2.5.70), it 
-	** seems as if upper layers have a problem to handle a successful
-	** return value of '0'. If such a zero is returned, the complete 
-	** system hangs for several minutes (!), which is in acceptable.
-	**
-	** Currently it is not clear, what the exact reason for this problem
-	** is. The implemented workaround for 2.5 is to return the desired 
-	** new MTU size if all needed changes for the new MTU size where 
-	** performed. In kernels 2.2 and 2.4, a zero value is returned,
-	** which indicates the successful change of the mtu-size.
-	*/
-	return NewMtu;
 
+	return 0;
 } /* SkGeChangeMtu */
 
 
@@ -2877,7 +2835,7 @@
  * Returns:
  *	pointer to the statistic structure.
  */
-static struct net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev)
+static struct net_device_stats *SkGeStats(struct net_device *dev)
 {
 DEV_NET *pNet = netdev_priv(dev);
 SK_AC	*pAC = pNet->pAC;
@@ -2898,7 +2856,8 @@
         SK_MEMSET(pPnmiStruct, 0, sizeof(SK_PNMI_STRUCT_DATA));
         spin_lock_irqsave(&pAC->SlowPathLock, Flags);
         Size = SK_PNMI_STRUCT_SIZE;
-		SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
+	SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
+
         spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 #ifdef SK_DIAG_SUPPORT
 	}
@@ -2912,7 +2871,7 @@
 	pAC->stats.rx_bytes = (SK_U32) pPnmiStruct->RxOctetsDeliveredCts;
 	pAC->stats.tx_bytes = (SK_U32) pPnmiStat->StatTxOctetsOkCts;
 	
-        if (pNet->Mtu <= 1500) {
+        if (dev->mtu <= 1500) {
                 pAC->stats.rx_errors = (SK_U32) pPnmiStruct->InErrorsCts & 0xFFFFFFFF;
         } else {
                 pAC->stats.rx_errors = (SK_U32) ((pPnmiStruct->InErrorsCts -
@@ -2961,7 +2920,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeIoctl(struct SK_NET_DEVICE *dev, struct ifreq *rq, int cmd)
+static int SkGeIoctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 DEV_NET		*pNet;
 SK_AC		*pAC;
@@ -3855,7 +3814,7 @@
 
 /*****************************************************************************
  *
- * 	ProductStr - return a adapter identification string from vpd
+ * 	PrintProductStr - show adapter identification string from vpd
  *
  * Description:
  *	This function reads the product name string from the vpd area
@@ -3863,25 +3822,22 @@
  *
  * Returns: N/A
  */
-static void ProductStr(
-SK_AC	*pAC		/* pointer to adapter context */
-)
+static void PrintProductStr(const char *name, SK_AC *pAC)
 {
-int	StrLen = 80;		/* length of the string, defined in SK_AC */
-char	Keyword[] = VPD_NAME;	/* vpd productname identifier */
+char	Buf[80];
+int	Len = sizeof(Buf);
 int	ReturnCode;		/* return code from vpd_read */
 unsigned long Flags;
 
 	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-	ReturnCode = VpdRead(pAC, pAC->IoBase, Keyword, pAC->DeviceStr,
-		&StrLen);
+	ReturnCode = VpdRead(pAC, pAC->IoBase, VPD_NAME, Buf, &Len);
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 	if (ReturnCode != 0) {
 		/* there was an error reading the vpd data */
-		SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ERROR,
-			("Error reading VPD data: %d\n", ReturnCode));
-		pAC->DeviceStr[0] = '\0';
+		sprintf(Buf, "Error reading VPD data: %d\n", ReturnCode);
 	}
+
+	printk(KERN_INFO "%s: %s\n", name, Buf);
 } /* ProductStr */
 
 /*****************************************************************************
@@ -4510,35 +4466,34 @@
  *	< 0  on error
  *	
  */
-void SkErrorLog(
-SK_AC	*pAC,
-int	ErrClass,
-int	ErrNum,
-char	*pErrorMsg)
+void SkErrorLog(const SK_AC *pAC,
+		int	ErrClass,
+		int	ErrNum,
+		const char	*pErrorMsg)
 {
-char	ClassStr[80];
+	const char *ClassStr = "";
 
 	switch (ErrClass) {
 	case SK_ERRCL_OTHER:
-		strcpy(ClassStr, "Other error");
+		ClassStr = "Other error";
 		break;
 	case SK_ERRCL_CONFIG:
-		strcpy(ClassStr, "Configuration error");
+		ClassStr = "Configuration error";
 		break;
 	case SK_ERRCL_INIT:
-		strcpy(ClassStr, "Initialization error");
+		ClassStr = "Initialization error";
 		break;
 	case SK_ERRCL_NORES:
-		strcpy(ClassStr, "Out of resources error");
+		ClassStr = "Out of resources error";
 		break;
 	case SK_ERRCL_SW:
-		strcpy(ClassStr, "internal Software error");
+		ClassStr = "internal Software error";
 		break;
 	case SK_ERRCL_HW:
-		strcpy(ClassStr, "Hardware failure");
+		ClassStr = "Hardware failure";
 		break;
 	case SK_ERRCL_COMM:
-		strcpy(ClassStr, "Communication error");
+		ClassStr = "Communication error";
 		break;
 	}
 	printk(KERN_INFO "%s: -- ERROR --\n        Class:  %s\n"
@@ -4571,7 +4526,7 @@
 
 	pAC->DiagModeActive = DIAG_ACTIVE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
-		if (pNet->Up) {
+		if (netif_running(pAC->dev[0])) {
 			pAC->WasIfUp[0] = SK_TRUE;
 			pAC->DiagFlowCtrl = SK_TRUE; /* for SkGeClose      */
 			DoPrintInterfaceChange = SK_FALSE;
@@ -4580,8 +4535,7 @@
 			pAC->WasIfUp[0] = SK_FALSE;
 		}
 		if (pNet != netdev_priv(pAC->dev[1])) {
-			pNet = netdev_priv(pAC->dev[1]);
-			if (pNet->Up) {
+			if (netif_running(pAC->dev[1])) {
 				pAC->WasIfUp[1] = SK_TRUE;
 				pAC->DiagFlowCtrl = SK_TRUE; /* for SkGeClose */
 				DoPrintInterfaceChange = SK_FALSE;
@@ -4698,7 +4652,7 @@
 SK_AC   *pAC,		/* pointer to adapter context   */
 int      devNbr)	/* what device is to be handled */
 {
-	struct SK_NET_DEVICE *dev;
+	struct net_device *dev;
 
 	dev = pAC->dev[devNbr];
 
@@ -4729,7 +4683,7 @@
 SK_AC   *pAC,		/* pointer to adapter context   */
 int      devNbr)	/* what device is to be handled */
 {
-	struct SK_NET_DEVICE *dev;
+	struct net_device *dev;
 
 	dev = pAC->dev[devNbr];
 
@@ -4934,14 +4888,10 @@
 	memset(pNet->pAC, 0, sizeof(SK_AC));
 	pAC = pNet->pAC;
 	pAC->PciDev = pdev;
-	pAC->PciDevId = pdev->device;
 	pAC->dev[0] = dev;
 	pAC->dev[1] = dev;
-	sprintf(pAC->Name, "SysKonnect SK-98xx");
 	pAC->CheckQueue = SK_FALSE;
 
-	pNet->Mtu = 1500;
-	pNet->Up = 0;
 	dev->irq = pdev->irq;
 	error = SkGeInitPCI(pAC);
 	if (error) {
@@ -4987,8 +4937,7 @@
 	}
 
 	/* Print adapter specific string from vpd */
-	ProductStr(pAC);
-	printk("%s: %s\n", dev->name, pAC->DeviceStr);
+	PrintProductStr(dev->name, pAC);
 
 	/* Print configuration settings */
 	printk("      PrefPort:%c  RlmtMode:%s\n",
@@ -5024,8 +4973,6 @@
 		pNet->PortNr  = 1;
 		pNet->NetNr   = 1;
 		pNet->pAC     = pAC;
-		pNet->Mtu     = 1500;
-		pNet->Up      = 0;
 
 		dev->open               = &SkGeOpen;
 		dev->stop               = &SkGeClose;
@@ -5057,7 +5004,7 @@
 			memcpy(&dev->dev_addr,
 					&pAC->Addr.Net[1].CurrentMacAddress, 6);
 	
-			printk("%s: %s\n", dev->name, pAC->DeviceStr);
+			PrintProductStr(dev->name, pAC);
 			printk("      PrefPort:B  RlmtMode:Dual Check Link State\n");
 		}
 	}
