From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/23) sk98: /proc interface related changes
Date: Thu, 11 Nov 2004 15:53:49 -0800
Message-ID: <20041111155349.4537044c@zqx3.pdx.osdl.net>
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

The /proc intereface can be cleaned up a lot:
+ Pass the device to through the proc data/seq_private hook.
+ No longer needs to have a list of network devices 
+ use seq_printf directly rather than indirection into a buffer
+ failure to create proc directory or interface should not
  be fatal.
+ if PROC_FS not configured, let the stubs cause the necessary
  code elimination rather than using #ifdef

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-05 16:25:13 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-05 16:25:13 -08:00
@@ -266,7 +266,6 @@
 typedef struct s_DevNet DEV_NET;
 
 struct s_DevNet {
-	struct			proc_dir_entry *proc;
 	int             PortNr;
 	int             NetNr;
 	int             Mtu;
@@ -395,7 +394,7 @@
 	SK_U32		PciDevId;	/* pci device id */
 	struct SK_NET_DEVICE	*dev[2];	/* pointer to device struct */
 	char		Name[30];	/* driver name */
-	struct SK_NET_DEVICE	*Next;		/* link all devices (for clearing) */
+
 	int		RxBufSize;	/* length of receive buffers */
         struct net_device_stats stats;	/* linux 'netstat -i' statistics */
 	int		Index;		/* internal board index number */
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-05 16:25:13 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-05 16:25:13 -08:00
@@ -233,12 +233,27 @@
  * Extern Function Prototypes
  *
  ******************************************************************************/
-
-#ifdef CONFIG_PROC_FS
-static const char 	SK_Root_Dir_entry[] = "sk98lin";
+static const char 	SKRootName[] = "sk98lin";
 static struct		proc_dir_entry *pSkRootDir;
 extern struct	file_operations sk_proc_fops;
-#endif
+
+static inline void SkGeProcCreate(struct net_device *dev)
+{
+	struct proc_dir_entry *pe;
+
+	if (pSkRootDir && 
+	    (pe = create_proc_entry(dev->name, S_IRUGO, pSkRootDir))) {
+		pe->proc_fops = &sk_proc_fops;
+		pe->data = dev;
+		pe->owner = THIS_MODULE;
+	}
+}
+ 
+static inline void SkGeProcRemove(struct net_device *dev)
+{
+	if (pSkRootDir)
+		remove_proc_entry(dev->name, pSkRootDir);
+}
 
 extern void SkDimEnableModerationIfNeeded(SK_AC *pAC);	
 extern void SkDimDisplayModerationSettings(SK_AC *pAC);
@@ -252,7 +267,6 @@
 #endif
 
 /* global variables *********************************************************/
-struct SK_NET_DEVICE *SkGeRootDev = NULL;
 static SK_BOOL DoPrintInterfaceChange = SK_TRUE;
 
 /* local variables **********************************************************/
@@ -601,12 +615,6 @@
 		return(-EAGAIN);
 	}
 
-	/*
-	 * Register the device here
-	 */
-	pAC->Next = SkGeRootDev;
-	SkGeRootDev = dev;
-
 	return (0);
 } /* SkGeBoardInit */
 
@@ -4876,9 +4884,6 @@
 	SK_AC			*pAC;
 	DEV_NET			*pNet = NULL;
 	struct net_device	*dev = NULL;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry	*pProcFile;
-#endif
 	static int boards_found = 0;
 	int error = -ENODEV;
 
@@ -4974,14 +4979,7 @@
 
 	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
 
-#ifdef CONFIG_PROC_FS
-	pProcFile = create_proc_entry(dev->name, S_IRUGO, pSkRootDir);
-	if (pProcFile) {
-		pProcFile->proc_fops = &sk_proc_fops;
-		pProcFile->data = dev;
-		pProcFile->owner = THIS_MODULE;
-	}
-#endif
+	SkGeProcCreate(dev);
 
 	pNet->PortNr = 0;
 	pNet->NetNr  = 0;
@@ -5028,16 +5026,7 @@
 			free_netdev(dev);
 			pAC->dev[1] = pAC->dev[0];
 		} else {
-#ifdef CONFIG_PROC_FS
-			pProcFile = create_proc_entry(dev->name, S_IRUGO,
-					pSkRootDir);
-			if (pProcFile) {
-				pProcFile->proc_fops = &sk_proc_fops;
-				pProcFile->data = dev;
-				pProcFile->owner = THIS_MODULE;
-			}
-#endif
-
+			SkGeProcCreate(dev);
 			memcpy(&dev->dev_addr,
 					&pAC->Addr.Net[1].CurrentMacAddress, 6);
 	
@@ -5075,17 +5064,12 @@
 	struct net_device *dev = pci_get_drvdata(pdev);
 	DEV_NET *pNet = (DEV_NET *) dev->priv;
 	SK_AC *pAC = pNet->pAC;
-	int have_second_mac = 0;
-
-	if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 2)
-		have_second_mac = 1;
+	struct net_device *otherdev = pAC->dev[1];
 
-	remove_proc_entry(dev->name, pSkRootDir);
+	SkGeProcRemove(dev);
 	unregister_netdev(dev);
-	if (have_second_mac) {
-		remove_proc_entry(pAC->dev[1]->name, pSkRootDir);
-		unregister_netdev(pAC->dev[1]);
-	}
+	if (otherdev != dev)
+		SkGeProcRemove(otherdev);
 
 	SkGeYellowLED(pAC, pAC->IoBase, 0);
 
@@ -5118,8 +5102,8 @@
 
 	FreeResources(dev);
 	free_netdev(dev);
-	if (have_second_mac)
-		free_netdev(pAC->dev[1]);
+	if (otherdev != dev)
+		free_netdev(otherdev);
 	kfree(pAC);
 }
 
@@ -5152,34 +5136,21 @@
 {
 	int error;
 
-#ifdef CONFIG_PROC_FS
-	memcpy(&SK_Root_Dir_entry, BOOT_STRING, sizeof(SK_Root_Dir_entry) - 1);
-
-	pSkRootDir = proc_mkdir(SK_Root_Dir_entry, proc_net);
-	if (!pSkRootDir) {
-		printk(KERN_WARNING "Unable to create /proc/net/%s",
-				SK_Root_Dir_entry);
-		return -ENOMEM;
-	}
-	pSkRootDir->owner = THIS_MODULE;
-#endif
-
-	error = pci_module_init(&skge_driver);
-	if (error) {
-#ifdef CONFIG_PROC_FS
-		remove_proc_entry(pSkRootDir->name, proc_net);
-#endif
-	}
-
+	pSkRootDir = proc_mkdir(SKRootName, proc_net);
+	if (pSkRootDir) 
+		pSkRootDir->owner = THIS_MODULE;
+	
+	error = pci_register_driver(&skge_driver);
+	if (error)
+		proc_net_remove(SKRootName);
 	return error;
 }
 
 static void __exit skge_exit(void)
 {
-	 pci_unregister_driver(&skge_driver);
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry(pSkRootDir->name, proc_net);
-#endif
+	pci_unregister_driver(&skge_driver);
+	proc_net_remove(SKRootName);
+
 }
 
 module_init(skge_init);
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-11-05 16:25:13 -08:00
+++ b/drivers/net/sk98lin/skproc.c	2004-11-05 16:25:13 -08:00
@@ -31,13 +31,9 @@
 #include "h/skdrv2nd.h"
 #include "h/skversion.h"
 
-extern struct SK_NET_DEVICE *SkGeRootDev;
-static int sk_proc_print(void *writePtr, char *format, ...);
-static void sk_gen_browse(void *buffer);
-int len;
-
 static int sk_seq_show(struct seq_file *seq, void *v);
 static int sk_proc_open(struct inode *inode, struct file *file);
+
 struct file_operations sk_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= sk_proc_open,
@@ -45,315 +41,206 @@
 	.llseek		= seq_lseek,
 	.release	= single_release,
 };
-struct net_device *currDev = NULL;
+
 
 /*****************************************************************************
  *
- * 	sk_gen_browse -generic  print "summaries" entry 
+ *      sk_seq_show - show proc information of a particular adapter
  *
  * Description:
  *  This function fills the proc entry with statistic data about 
- *  the ethernet device.
+ *  the ethernet device. It invokes the generic sk_gen_browse() to
+ *  print out all items one per one.
  *  
- * Returns: -
- *	
+ * Returns: 0
+ *      
  */
-static void sk_gen_browse(void *buffer)
+static int sk_seq_show(struct seq_file *seq, void *v)
 {
-	struct SK_NET_DEVICE	*SkgeProcDev = SkGeRootDev;
-	struct SK_NET_DEVICE	*next;
-	SK_PNMI_STRUCT_DATA 	*pPnmiStruct;
-	SK_PNMI_STAT		*pPnmiStat;
+	struct net_device *dev = seq->private;
+	DEV_NET			*pNet = netdev_priv(dev);
+	SK_AC			*pAC = pNet->pAC;
+	SK_PNMI_STRUCT_DATA 	*pPnmiStruct = &pAC->PnmiStruct;
 	unsigned long		Flags;	
 	unsigned int		Size;
-	DEV_NET			*pNet;
-	SK_AC			*pAC;
 	char			sens_msg[50];
-	int			MaxSecurityCount = 0;
 	int 			t;
 	int 			i;
 
-	while (SkgeProcDev) {
-		MaxSecurityCount++;
-		if (MaxSecurityCount > 100) {
-			printk("Max limit for sk_proc_read security counter!\n");
-			return;
-		}
-		pNet = (DEV_NET*) SkgeProcDev->priv;
-		pAC = pNet->pAC;
-		next = pAC->Next;
-		pPnmiStruct = &pAC->PnmiStruct;
-		/* NetIndex in GetStruct is now required, zero is only dummy */
-
-		for (t=pAC->GIni.GIMacsFound; t > 0; t--) {
-			if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 1)
-				t--;
+	/* NetIndex in GetStruct is now required, zero is only dummy */
+	for (t=pAC->GIni.GIMacsFound; t > 0; t--) {
+		if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 1)
+			t--;
 
-			spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-			Size = SK_PNMI_STRUCT_SIZE;
+		spin_lock_irqsave(&pAC->SlowPathLock, Flags);
+		Size = SK_PNMI_STRUCT_SIZE;
 #ifdef SK_DIAG_SUPPORT
-			if (pAC->BoardLevel == SK_INIT_DATA) {
-				SK_MEMCPY(&(pAC->PnmiStruct), &(pAC->PnmiBackup), sizeof(SK_PNMI_STRUCT_DATA));
-				if (pAC->DiagModeActive == DIAG_NOTACTIVE) {
-					pAC->Pnmi.DiagAttached = SK_DIAG_IDLE;
-				}
-			} else {
-				SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, t-1);
+		if (pAC->BoardLevel == SK_INIT_DATA) {
+			SK_MEMCPY(&(pAC->PnmiStruct), &(pAC->PnmiBackup), sizeof(SK_PNMI_STRUCT_DATA));
+			if (pAC->DiagModeActive == DIAG_NOTACTIVE) {
+				pAC->Pnmi.DiagAttached = SK_DIAG_IDLE;
 			}
+		} else {
+			SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, t-1);
+		}
 #else
-			SkPnmiGetStruct(pAC, pAC->IoBase, 
+		SkPnmiGetStruct(pAC, pAC->IoBase, 
 				pPnmiStruct, &Size, t-1);
 #endif
-			spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
+		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 	
-			if (strcmp(pAC->dev[t-1]->name, currDev->name) == 0) {
-				pPnmiStat = &pPnmiStruct->Stat[0];
-				len = sk_proc_print(buffer, 
-					"\nDetailed statistic for device %s\n",
-					pAC->dev[t-1]->name);
-				len += sk_proc_print(buffer,
-					"=======================================\n");
+		if (pAC->dev[t-1] == dev) {
+			SK_PNMI_STAT	*pPnmiStat = &pPnmiStruct->Stat[0];
+
+			seq_printf(seq, "\nDetailed statistic for device %s\n",
+				      pAC->dev[t-1]->name);
+			seq_printf(seq, "=======================================\n");
 	
-				/* Board statistics */
-				len += sk_proc_print(buffer, 
-					"\nBoard statistics\n\n");
-				len += sk_proc_print(buffer,
-					"Active Port                    %c\n",
-					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
-					Net[t-1].PrefPort]->PortNumber);
-				len += sk_proc_print(buffer,
-					"Preferred Port                 %c\n",
-					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
-					Net[t-1].PrefPort]->PortNumber);
-
-				len += sk_proc_print(buffer,
-					"Bus speed (MHz)                %d\n",
-					pPnmiStruct->BusSpeed);
-
-				len += sk_proc_print(buffer,
-					"Bus width (Bit)                %d\n",
-					pPnmiStruct->BusWidth);
-				len += sk_proc_print(buffer,
-					"Driver version                 %s\n",
-					VER_STRING);
-				len += sk_proc_print(buffer,
-					"Hardware revision              v%d.%d\n",
-					(pAC->GIni.GIPciHwRev >> 4) & 0x0F,
-					pAC->GIni.GIPciHwRev & 0x0F);
-
-				/* Print sensor informations */
-				for (i=0; i < pAC->I2c.MaxSens; i ++) {
-					/* Check type */
-					switch (pAC->I2c.SenTable[i].SenType) {
-					case 1:
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (C)");
-						len += sk_proc_print(buffer,
-							"%-25s      %d.%02d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue / 10,
-							pAC->I2c.SenTable[i].SenValue % 10);
-
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (F)");
-						len += sk_proc_print(buffer,
-							"%-25s      %d.%02d\n",
-							sens_msg,
-							((((pAC->I2c.SenTable[i].SenValue)
-							*10)*9)/5 + 3200)/100,
-							((((pAC->I2c.SenTable[i].SenValue)
-							*10)*9)/5 + 3200) % 10);
-						break;
-					case 2:
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (V)");
-						len += sk_proc_print(buffer,
-							"%-25s      %d.%03d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue / 1000,
-							pAC->I2c.SenTable[i].SenValue % 1000);
-						break;
-					case 3:
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (rpm)");
-						len += sk_proc_print(buffer,
-							"%-25s      %d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue);
-						break;
-					default:
-						break;
-					}
+			/* Board statistics */
+			seq_printf(seq, "\nBoard statistics\n\n");
+			seq_printf(seq, "Active Port                    %c\n",
+				      'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
+								    Net[t-1].PrefPort]->PortNumber);
+			seq_printf(seq, "Preferred Port                 %c\n",
+				      'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
+								    Net[t-1].PrefPort]->PortNumber);
+
+			seq_printf(seq, "Bus speed (MHz)                %d\n",
+				      pPnmiStruct->BusSpeed);
+
+			seq_printf(seq, "Bus width (Bit)                %d\n",
+				      pPnmiStruct->BusWidth);
+			seq_printf(seq, "Driver version                 %s\n",
+				      VER_STRING);
+			seq_printf(seq, "Hardware revision              v%d.%d\n",
+				      (pAC->GIni.GIPciHwRev >> 4) & 0x0F,
+				      pAC->GIni.GIPciHwRev & 0x0F);
+
+			/* Print sensor informations */
+			for (i=0; i < pAC->I2c.MaxSens; i ++) {
+				/* Check type */
+				switch (pAC->I2c.SenTable[i].SenType) {
+				case 1:
+					strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+					strcat(sens_msg, " (C)");
+					seq_printf(seq, "%-25s      %d.%02d\n",
+						      sens_msg,
+						      pAC->I2c.SenTable[i].SenValue / 10,
+						      pAC->I2c.SenTable[i].SenValue % 10);
+
+					strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+					strcat(sens_msg, " (F)");
+					seq_printf(seq, "%-25s      %d.%02d\n",
+						      sens_msg,
+						      ((((pAC->I2c.SenTable[i].SenValue)
+							 *10)*9)/5 + 3200)/100,
+						      ((((pAC->I2c.SenTable[i].SenValue)
+							 *10)*9)/5 + 3200) % 10);
+					break;
+				case 2:
+					strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+					strcat(sens_msg, " (V)");
+					seq_printf(seq, "%-25s      %d.%03d\n",
+						      sens_msg,
+						      pAC->I2c.SenTable[i].SenValue / 1000,
+						      pAC->I2c.SenTable[i].SenValue % 1000);
+					break;
+				case 3:
+					strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+					strcat(sens_msg, " (rpm)");
+					seq_printf(seq, "%-25s      %d\n",
+						      sens_msg,
+						      pAC->I2c.SenTable[i].SenValue);
+					break;
+				default:
+					break;
 				}
+			}
 				
-				/*Receive statistics */
-				len += sk_proc_print(buffer, 
-				"\nReceive statistics\n\n");
-
-				len += sk_proc_print(buffer,
-					"Received bytes                 %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxOctetsOkCts);
-				len += sk_proc_print(buffer,
-					"Received packets               %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxOkCts);
+			/*Receive statistics */
+			seq_printf(seq, "\nReceive statistics\n\n");
+
+			seq_printf(seq, "Received bytes                 %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxOctetsOkCts);
+			seq_printf(seq, "Received packets               %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxOkCts);
 #if 0
-				if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && 
-					pAC->HWRevision < 12) {
-					pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts - 
-						pPnmiStat->StatRxShortsCts;
-					pPnmiStat->StatRxShortsCts = 0;
-				}
+			if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && 
+			    pAC->HWRevision < 12) {
+				pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts - 
+					pPnmiStat->StatRxShortsCts;
+				pPnmiStat->StatRxShortsCts = 0;
+			}
 #endif
-				if (pNet->Mtu > 1500) 
-					pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts -
-						pPnmiStat->StatRxTooLongCts;
-
-				len += sk_proc_print(buffer,
-					"Receive errors                 %Lu\n",
-					(unsigned long long) pPnmiStruct->InErrorsCts);
-				len += sk_proc_print(buffer,
-					"Receive dropped                %Lu\n",
-					(unsigned long long) pPnmiStruct->RxNoBufCts);
-				len += sk_proc_print(buffer,
-					"Received multicast             %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxMulticastOkCts);
-				len += sk_proc_print(buffer,
-					"Receive error types\n");
-				len += sk_proc_print(buffer,
-					"   length                      %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxRuntCts);
-				len += sk_proc_print(buffer,
-					"   buffer overflow             %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxFifoOverflowCts);
-				len += sk_proc_print(buffer,
-					"   bad crc                     %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxFcsCts);
-				len += sk_proc_print(buffer,
-					"   framing                     %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxFramingCts);
-				len += sk_proc_print(buffer,
-					"   missed frames               %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxMissedCts);
-
-				if (pNet->Mtu > 1500)
-					pPnmiStat->StatRxTooLongCts = 0;
-
-				len += sk_proc_print(buffer,
-					"   too long                    %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxTooLongCts);					
-				len += sk_proc_print(buffer,
-					"   carrier extension           %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxCextCts);				
-				len += sk_proc_print(buffer,
-					"   too short                   %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxShortsCts);				
-				len += sk_proc_print(buffer,
-					"   symbol                      %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxSymbolCts);				
-				len += sk_proc_print(buffer,
-					"   LLC MAC size                %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxIRLengthCts);				
-				len += sk_proc_print(buffer,
-					"   carrier event               %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxCarrierCts);				
-				len += sk_proc_print(buffer,
-					"   jabber                      %Lu\n",
-					(unsigned long long) pPnmiStat->StatRxJabberCts);				
-
-
-				/*Transmit statistics */
-				len += sk_proc_print(buffer, 
-				"\nTransmit statistics\n\n");
+			if (dev->mtu > 1500)
+				pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts -
+					pPnmiStat->StatRxTooLongCts;
+
+			seq_printf(seq, "Receive errors                 %Lu\n",
+				      (unsigned long long) pPnmiStruct->InErrorsCts);
+			seq_printf(seq, "Receive dropped                %Lu\n",
+				      (unsigned long long) pPnmiStruct->RxNoBufCts);
+			seq_printf(seq, "Received multicast             %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxMulticastOkCts);
+			seq_printf(seq, "Receive error types\n");
+			seq_printf(seq, "   length                      %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxRuntCts);
+			seq_printf(seq, "   buffer overflow             %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxFifoOverflowCts);
+			seq_printf(seq, "   bad crc                     %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxFcsCts);
+			seq_printf(seq, "   framing                     %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxFramingCts);
+			seq_printf(seq, "   missed frames               %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxMissedCts);
+
+			if (dev->mtu > 1500)
+				pPnmiStat->StatRxTooLongCts = 0;
+
+			seq_printf(seq, "   too long                    %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxTooLongCts);					
+			seq_printf(seq, "   carrier extension           %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxCextCts);				
+			seq_printf(seq, "   too short                   %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxShortsCts);				
+			seq_printf(seq, "   symbol                      %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxSymbolCts);				
+			seq_printf(seq, "   LLC MAC size                %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxIRLengthCts);				
+			seq_printf(seq, "   carrier event               %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxCarrierCts);				
+			seq_printf(seq, "   jabber                      %Lu\n",
+				      (unsigned long long) pPnmiStat->StatRxJabberCts);				
+
+
+			/*Transmit statistics */
+			seq_printf(seq, "\nTransmit statistics\n\n");
 				
-				len += sk_proc_print(buffer,
-					"Transmited bytes               %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxOctetsOkCts);
-				len += sk_proc_print(buffer,
-					"Transmited packets             %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxOkCts);
-				len += sk_proc_print(buffer,
-					"Transmit errors                %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sk_proc_print(buffer,
-					"Transmit dropped               %Lu\n",
-					(unsigned long long) pPnmiStruct->TxNoBufCts);
-				len += sk_proc_print(buffer,
-					"Transmit collisions            %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sk_proc_print(buffer,
-					"Transmit error types\n");
-				len += sk_proc_print(buffer,
-					"   excessive collision         %ld\n",
-					pAC->stats.tx_aborted_errors);
-				len += sk_proc_print(buffer,
-					"   carrier                     %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sk_proc_print(buffer,
-					"   fifo underrun               %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxFifoUnderrunCts);
-				len += sk_proc_print(buffer,
-					"   heartbeat                   %Lu\n",
-					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sk_proc_print(buffer,
-					"   window                      %ld\n",
-					pAC->stats.tx_window_errors);
+			seq_printf(seq, "Transmited bytes               %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxOctetsOkCts);
+			seq_printf(seq, "Transmited packets             %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxOkCts);
+			seq_printf(seq, "Transmit errors                %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
+			seq_printf(seq, "Transmit dropped               %Lu\n",
+				      (unsigned long long) pPnmiStruct->TxNoBufCts);
+			seq_printf(seq, "Transmit collisions            %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
+			seq_printf(seq, "Transmit error types\n");
+			seq_printf(seq, "   excessive collision         %ld\n",
+				      pAC->stats.tx_aborted_errors);
+			seq_printf(seq, "   carrier                     %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxCarrierCts);
+			seq_printf(seq, "   fifo underrun               %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxFifoUnderrunCts);
+			seq_printf(seq, "   heartbeat                   %Lu\n",
+				      (unsigned long long) pPnmiStat->StatTxCarrierCts);
+			seq_printf(seq, "   window                      %ld\n",
+				      pAC->stats.tx_window_errors);
 				
-			} /* if (strcmp(pACname, currDeviceName) == 0) */
 		}
-		SkgeProcDev = next;
 	}
-}
-
-/*****************************************************************************
- *
- *      sk_proc_print -generic line print  
- *
- * Description:
- *  This function fills the proc entry with statistic data about 
- *  the ethernet device.
- *  
- * Returns: number of bytes written
- *      
- */ 
-static int sk_proc_print(void *writePtr, char *format, ...)
-{   
-#define MAX_LEN_SINGLE_LINE 256
-	char     str[MAX_LEN_SINGLE_LINE];
-	va_list  a_start;
-	int      lenght = 0;
-
-	struct seq_file *seq = (struct seq_file *) writePtr;
-
-	SK_MEMSET(str, 0, MAX_LEN_SINGLE_LINE);
-
-	va_start(a_start, format);
-	vsprintf(str, format, a_start);
-	va_end(a_start);
-
-	lenght = strlen(str);
-
-	seq_printf(seq, str);
-	return lenght;
-}
-
-/*****************************************************************************
- *
- *      sk_seq_show - show proc information of a particular adapter
- *
- * Description:
- *  This function fills the proc entry with statistic data about 
- *  the ethernet device. It invokes the generic sk_gen_browse() to
- *  print out all items one per one.
- *  
- * Returns: number of bytes written
- *      
- */
-static int sk_seq_show(struct seq_file *seq, void *v)
-{
-    void *castedBuffer = (void *) seq;
-    currDev = seq->private;
-    sk_gen_browse(castedBuffer);
-    return 0;
+	return 0;
 }
 
 /*****************************************************************************
