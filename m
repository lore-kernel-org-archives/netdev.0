From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] simplify skge /proc interface.
Date: Thu, 4 Sep 2003 16:06:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904160658.5ae22c0d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <mlindner@syskonnect.de>,
   Ralph Roesler <rroesler@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is against 2.6.0-test4 and simplifys the /proc interface for
the skge driver.  

* Use seq_file single_open interface to avoid possible buffer over
  run and formatting issues.
* Put pointer to device in the proc dir private data to avoid having
  to search through devices to find the info.
* Use %lld rather than special formatting code
* use proc_mkdir
* Don't die if proc fs is not configured or creating entries fails.

New code is written in kernel style.

Builds and loads but don't have real hardware. Could someone
please test this with a real board?

Somewhere in this 8K line driver is a 1000 line driver waiting to get out...

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	Thu Sep  4 15:53:18 2003
+++ b/drivers/net/sk98lin/skge.c	Thu Sep  4 15:53:18 2003
@@ -526,13 +526,11 @@
  ******************************************************************************/
 
 static const char 	SK_Root_Dir_entry[] = "sk98lin";
+
+#ifdef CONFIG_PROC_FS
 static struct		proc_dir_entry *pSkRootDir;
-extern int 		sk_proc_read(	char   *buffer,
-					char	**buffer_location,
-					off_t	offset,
-					int	buffer_length,
-					int	*eof,
-					void	*data);
+extern struct file_operations sk_proc_fops;
+#endif
 
 extern void SkDimEnableModerationIfNeeded(SK_AC *pAC);	
 extern void SkDimDisplayModerationSettings(SK_AC *pAC);
@@ -573,7 +571,6 @@
  */
 static int __init skge_probe (void)
 {
-	int			proc_root_initialized = 0;
 	int			boards_found = 0;
 	int			vendor_flag = SK_FALSE;
 	SK_AC			*pAC;
@@ -724,30 +721,31 @@
 			SK_MEMCPY(&SK_Root_Dir_entry, BootString,
 				sizeof(SK_Root_Dir_entry) - 1);
 
+#ifdef CONFIG_PROC_FS
 			/*Create proc (directory)*/
-			if(!proc_root_initialized) {
-				pSkRootDir = create_proc_entry(SK_Root_Dir_entry,
-					S_IFDIR | S_IWUSR | S_IRUGO | S_IXUGO, proc_net);
-				pSkRootDir->owner = THIS_MODULE;
-				proc_root_initialized = 1;
+			if(!pSkRootDir) {
+				pSkRootDir = proc_mkdir(SK_Root_Dir_entry,
+							proc_net);
+				if (!pSkRootDir) {
+					printk(KERN_WARNING "%s: Unable to create /proc/net/%s",
+					       dev->name, SK_Root_Dir_entry);
+					/* not fatal */
+				} else
+					pSkRootDir->owner = THIS_MODULE;
 			}
-
+#endif
 		}
 
 
-
+#ifdef CONFIG_PROC_FS
 		/* Create proc file */
-		pProcFile = create_proc_entry(dev->name,
-			S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
-			pSkRootDir);
-
-		
-		pProcFile->read_proc = sk_proc_read;
-		pProcFile->write_proc = NULL;
-		pProcFile->nlink = 1;
-		pProcFile->size = sizeof(dev->name + 1);
-		pProcFile->data = (void *)pProcFile;
-		pProcFile->owner = THIS_MODULE;
+		if (pSkRootDir) {
+			pProcFile = create_proc_entry(dev->name, S_IRUGO,
+						      pSkRootDir);
+			pProcFile->proc_fops = &sk_proc_fops;
+			pProcFile->data = dev;
+		}			
+#endif
 
 		pNet->PortNr = 0;
 		pNet->NetNr = 0;
@@ -798,17 +796,14 @@
 #endif
 #endif
 
-			pProcFile = create_proc_entry(dev->name,
-				S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
-				pSkRootDir);
-
-		
-			pProcFile->read_proc = sk_proc_read;
-			pProcFile->write_proc = NULL;
-			pProcFile->nlink = 1;
-			pProcFile->size = sizeof(dev->name + 1);
-			pProcFile->data = (void *)pProcFile;
-			pProcFile->owner = THIS_MODULE;
+#ifdef CONFIG_PROC_FS
+		if (pSkRootDir) {
+			pProcFile = create_proc_entry(dev->name, S_IRUGO,
+						      pSkRootDir);
+			pProcFile->proc_fops = &sk_proc_fops;
+			pProcFile->data = dev;
+		}			
+#endif
 
 			memcpy((caddr_t) &dev->dev_addr,
 			(caddr_t) &pAC->Addr.Net[1].CurrentMacAddress, 6);
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	Thu Sep  4 15:53:18 2003
+++ b/drivers/net/sk98lin/skproc.c	Thu Sep  4 15:53:18 2003
@@ -83,452 +83,219 @@
  ******************************************************************************/
 
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include "h/skdrv1st.h"
 #include "h/skdrv2nd.h"
-#define ZEROPAD		1		/* pad with zero */
-#define SIGN		2		/* unsigned/signed long */
-#define PLUS		4		/* show plus */
-#define SPACE		8		/* space if plus */
-#define LEFT		16		/* left justified */
-#define SPECIALX	32		/* 0x */
-#define LARGE		64
-
-	extern struct net_device	*SkGeRootDev;
-
-extern char * SkNumber(
-				char * str,
-				long long num,
-				int base,
-				int size,
-				int precision,
-				int type);
-
-int sk_proc_read(char *buffer,
-				char **buffer_location,
-				off_t offset,
-				int buffer_length,
-				int *eof,
-				void *data);
 
+#ifdef CONFIG_PROC_FS
 
-
-/*****************************************************************************
- *
- * 	sk_proc_read - print "summaries" entry 
- *
- * Description:
- *  This function fills the proc entry with statistic data about 
- *  the ethernet device.
- *  
- *
- * Returns: buffer with statistic data
- *	
- */
-int sk_proc_read(char *buffer,
-char **buffer_location,
-off_t offset,
-int buffer_length,
-int *eof,
-void *data)
+static int sk_seq_show(struct seq_file *seq, void *v)
 {
-	int len = 0;
-	int t;
+	const struct net_device *dev = v;
+	const struct s_DevNet *pNet = dev->priv;
+	const struct s_AC *pAC = pNet->pAC;
+	const struct s_PnmiStrucData *pPnmiStruct = &pAC->PnmiStruct;
+	const struct s_PnmiStat *pPnmiStat = &pPnmiStruct->Stat[0];
 	int i;
-	DEV_NET					*pNet;
-	SK_AC					*pAC;
-	char 					test_buf[100];
-	char					sens_msg[50];
-	unsigned long			Flags;	
-	unsigned int			Size;
-	struct SK_NET_DEVICE 		*next;
-	struct SK_NET_DEVICE 		*SkgeProcDev = SkGeRootDev;
-
-	SK_PNMI_STRUCT_DATA 	*pPnmiStruct;
-	SK_PNMI_STAT		*pPnmiStat;
-	struct proc_dir_entry *file = (struct proc_dir_entry*) data;
-
-	while (SkgeProcDev) {
-		pNet = (DEV_NET*) SkgeProcDev->priv;
-		pAC = pNet->pAC;
-		next = pAC->Next;
-		pPnmiStruct = &pAC->PnmiStruct;
-		/* NetIndex in GetStruct is now required, zero is only dummy */
-
-		for (t=pAC->GIni.GIMacsFound; t > 0; t--) {
-			if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 1)
-				t--;
-
-			spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-			Size = SK_PNMI_STRUCT_SIZE;
-			SkPnmiGetStruct(pAC, pAC->IoBase, 
-				pPnmiStruct, &Size, t-1);
-			spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-	
-			if (strcmp(pAC->dev[t-1]->name, file->name) == 0) {
-				pPnmiStat = &pPnmiStruct->Stat[0];
-				len = sprintf(buffer, 
-					"\nDetailed statistic for device %s\n",
-					pAC->dev[t-1]->name);
-				len += sprintf(buffer + len,
-					"=======================================\n");
+	int unit = !(pAC->dev[0] == dev);
+	char		sens_msg[50];
+
+	seq_printf(seq, 
+		   "\nDetailed statistic for device %s\n",
+		   dev->name);
+	seq_puts(seq, 
+		 "=======================================\n");
+
+	/* Board statistics */	
+	seq_puts(seq, "\nBoard statistics\n\n");
 	
-				/* Board statistics */
-				len += sprintf(buffer + len, 
-					"\nBoard statistics\n\n");
-				len += sprintf(buffer + len,
-					"Active Port                    %c\n",
-					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
-					Net[t-1].PrefPort]->PortNumber);
-				len += sprintf(buffer + len,
-					"Preferred Port                 %c\n",
-					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
-					Net[t-1].PrefPort]->PortNumber);
-
-				len += sprintf(buffer + len,
-					"Bus speed (MHz)                %d\n",
-					pPnmiStruct->BusSpeed);
-
-				len += sprintf(buffer + len,
-					"Bus width (Bit)                %d\n",
-					pPnmiStruct->BusWidth);
-				len += sprintf(buffer + len,
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
-						len += sprintf(buffer + len,
-							"%-25s      %d.%02d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue / 10,
-							pAC->I2c.SenTable[i].SenValue % 10);
-
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (F)");
-						len += sprintf(buffer + len,
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
-						len += sprintf(buffer + len,
-							"%-25s      %d.%03d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue / 1000,
-							pAC->I2c.SenTable[i].SenValue % 1000);
-						break;
-					case 3:
-						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
-						strcat(sens_msg, " (rpm)");
-						len += sprintf(buffer + len,
-							"%-25s      %d\n",
-							sens_msg,
-							pAC->I2c.SenTable[i].SenValue);
-						break;
-					default:
-						break;
-					}
-				}
+	seq_printf(seq, "Active Port                    %c\n",
+		   'A' + pAC->Rlmt.Net[unit].Port[pAC->Rlmt.
+						  Net[unit].PrefPort]->PortNumber);
+
+	seq_printf(seq, "Preferred Port                 %c\n",
+		   'A' + pAC->Rlmt.Net[unit].Port[pAC->Rlmt.
+						  Net[unit].PrefPort]->PortNumber);
+
+	seq_printf(seq, "Bus speed (MHz)                %d\n",
+		   pPnmiStruct->BusSpeed);
+
+	seq_printf(seq,
+		   "Bus width (Bit)                %d\n",
+		   pPnmiStruct->BusWidth);
+	seq_printf(seq,
+		   "Hardware revision              v%d.%d\n",
+		   (pAC->GIni.GIPciHwRev >> 4) & 0x0F,
+		   pAC->GIni.GIPciHwRev & 0x0F);
+
+	/* Print sensor informations */
+	for (i=0; i < pAC->I2c.MaxSens; i ++) {
+		/* Check type */
+		switch (pAC->I2c.SenTable[i].SenType) {
+		case 1:
+			strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+			strcat(sens_msg, " (C)");
+			seq_printf(seq,
+				   "%-25s      %d.%02d\n",
+				   sens_msg,
+				   pAC->I2c.SenTable[i].SenValue / 10,
+				   pAC->I2c.SenTable[i].SenValue % 10);
+
+			strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+			strcat(sens_msg, " (F)");
+			seq_printf(seq,
+				   "%-25s      %d.%02d\n",
+				   sens_msg,
+				   ((((pAC->I2c.SenTable[i].SenValue)
+				      *10)*9)/5 + 3200)/100,
+				   ((((pAC->I2c.SenTable[i].SenValue)
+				      *10)*9)/5 + 3200) % 10);
+			break;
+		case 2:
+			strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+			strcat(sens_msg, " (V)");
+			seq_printf(seq,
+				   "%-25s      %d.%03d\n",
+				   sens_msg,
+				   pAC->I2c.SenTable[i].SenValue / 1000,
+				   pAC->I2c.SenTable[i].SenValue % 1000);
+			break;
+		case 3:
+			strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
+			strcat(sens_msg, " (rpm)");
+			seq_printf(seq,
+				   "%-25s      %d\n",
+				   sens_msg,
+				   pAC->I2c.SenTable[i].SenValue);
+			break;
+		default:
+			break;
+		}
+	}
 				
-				/*Receive statistics */
-				len += sprintf(buffer + len, 
-				"\nReceive statistics\n\n");
-
-				len += sprintf(buffer + len,
-					"Received bytes                 %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxOctetsOkCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Received packets               %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxOkCts,
-					10,0,-1,0));
+	/*Receive statistics */
+	seq_printf(seq, 
+		   "\nReceive statistics\n\n");
+
+	seq_printf(seq,
+		   "Received bytes                 %lld\n",
+		   pPnmiStat->StatRxOctetsOkCts);
+	seq_printf(seq,
+		   "Received packets               %lld\n",
+		   pPnmiStat->StatRxOkCts);
 #if 0
-				if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && 
-					pAC->HWRevision < 12) {
-					pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts - 
-						pPnmiStat->StatRxShortsCts;
-					pPnmiStat->StatRxShortsCts = 0;
-				}
+	if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && 
+	    pAC->HWRevision < 12) {
+		pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts - 
+			pPnmiStat->StatRxShortsCts;
+		pPnmiStat->StatRxShortsCts = 0;
+	}
 #endif
-				if (pNet->Mtu > 1500) 
-					pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts -
-						pPnmiStat->StatRxTooLongCts;
-
-				len += sprintf(buffer + len,
-					"Receive errors                 %s\n",
-					SkNumber(test_buf, pPnmiStruct->InErrorsCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Receive dropped                %s\n",
-					SkNumber(test_buf, pPnmiStruct->RxNoBufCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Received multicast             %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxMulticastOkCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Receive error types\n");
-				len += sprintf(buffer + len,
-					"   length                      %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxRuntCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   buffer overflow             %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxFifoOverflowCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   bad crc                     %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxFcsCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   framing                     %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxFramingCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   missed frames               %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxMissedCts,
-					10, 0, -1, 0));
-
-				if (pNet->Mtu > 1500)
-					pPnmiStat->StatRxTooLongCts = 0;
-
-				len += sprintf(buffer + len,
-					"   too long                    %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxTooLongCts,
-					10, 0, -1, 0));					
-				len += sprintf(buffer + len,
-					"   carrier extension           %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxCextCts,
-					10, 0, -1, 0));				
-				len += sprintf(buffer + len,
-					"   too short                   %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxShortsCts,
-					10, 0, -1, 0));				
-				len += sprintf(buffer + len,
-					"   symbol                      %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxSymbolCts,
-					10, 0, -1, 0));				
-				len += sprintf(buffer + len,
-					"   LLC MAC size                %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxIRLengthCts,
-					10, 0, -1, 0));				
-				len += sprintf(buffer + len,
-					"   carrier event               %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxCarrierCts,
-					10, 0, -1, 0));				
-				len += sprintf(buffer + len,
-					"   jabber                      %s\n",
-					SkNumber(test_buf, pPnmiStat->StatRxJabberCts,
-					10, 0, -1, 0));				
-
-
-				/*Transmit statistics */
-				len += sprintf(buffer + len, 
-				"\nTransmit statistics\n\n");
-				
-				len += sprintf(buffer + len,
-					"Transmited bytes               %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxOctetsOkCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Transmited packets             %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxOkCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Transmit errors                %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxSingleCollisionCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Transmit dropped               %s\n",
-					SkNumber(test_buf, pPnmiStruct->TxNoBufCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Transmit collisions            %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxSingleCollisionCts,
-					10,0,-1,0));
-				len += sprintf(buffer + len,
-					"Transmit error types\n");
-				len += sprintf(buffer + len,
-					"   excessive collision         %ld\n",
-					pAC->stats.tx_aborted_errors);
-				len += sprintf(buffer + len,
-					"   carrier                     %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxCarrierCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   fifo underrun               %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxFifoUnderrunCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   heartbeat                   %s\n",
-					SkNumber(test_buf, pPnmiStat->StatTxCarrierCts,
-					10, 0, -1, 0));
-				len += sprintf(buffer + len,
-					"   window                      %ld\n",
-					pAC->stats.tx_window_errors);
+	seq_printf(seq,"Receive errors                 %lld\n",
+		   (pNet->Mtu > 1500)  
+		   ? pPnmiStruct->InErrorsCts - pPnmiStat->StatRxTooLongCts
+		   : pPnmiStruct->InErrorsCts);
+
+	seq_printf(seq,
+		   "Receive dropped                %lld\n",
+		   pPnmiStruct->RxNoBufCts);
+	seq_printf(seq,
+		   "Received multicast             %lld\n",
+		   pPnmiStat->StatRxMulticastOkCts);
+	seq_printf(seq,
+		   "Receive error types\n");
+	seq_printf(seq,
+		   "   length                      %lld\n",
+		   pPnmiStat->StatRxRuntCts);
+	seq_printf(seq,
+		   "   buffer overflow             %lld\n",
+		   pPnmiStat->StatRxFifoOverflowCts);
+	seq_printf(seq,
+		   "   bad crc                     %lld\n",
+		   pPnmiStat->StatRxFcsCts);
+	seq_printf(seq,
+		   "   framing                     %lld\n",
+		   pPnmiStat->StatRxFramingCts);
+	seq_printf(seq,
+		   "   missed frames               %lld\n",
+		   pPnmiStat->StatRxMissedCts);
+
+	seq_printf(seq,
+		   "   too long                    %lld\n",
+		   pPnmiStat->StatRxTooLongCts);
+
+	seq_printf(seq,
+		   "   carrier extension           %lld\n",
+		   pPnmiStat->StatRxCextCts);				
+	seq_printf(seq,
+		   "   too short                   %lld\n",
+		   pPnmiStat->StatRxShortsCts);				
+	seq_printf(seq,
+		   "   symbol                      %lld\n",
+		   pPnmiStat->StatRxSymbolCts);				
+	seq_printf(seq,
+		   "   LLC MAC size                %lld\n",
+		   pPnmiStat->StatRxIRLengthCts);				
+	seq_printf(seq,
+		   "   carrier event               %lld\n",
+		   pPnmiStat->StatRxCarrierCts);				
+	seq_printf(seq,
+		   "   jabber                      %lld\n",
+		   pPnmiStat->StatRxJabberCts);				
+
+
+	/*Transmit statistics */
+	seq_printf(seq, 
+		   "\nTransmit statistics\n\n");
 				
-			}
-		}
-		SkgeProcDev = next;
-	}
-	if (offset >= len) {
-		*eof = 1;
-		return 0;
-	}
+	seq_printf(seq,
+		   "Transmited bytes               %lld\n",
+		   pPnmiStat->StatTxOctetsOkCts);
+	seq_printf(seq,
+		   "Transmited packets             %lld\n",
+		   pPnmiStat->StatTxOkCts);
+	seq_printf(seq,
+		   "Transmit errors                %lld\n",
+		   pPnmiStat->StatTxSingleCollisionCts);
+	seq_printf(seq,
+		   "Transmit dropped               %lld\n",
+		   pPnmiStruct->TxNoBufCts);
+	seq_printf(seq,
+		   "Transmit collisions            %lld\n",
+		   pPnmiStat->StatTxSingleCollisionCts);
+	seq_printf(seq,
+		   "Transmit error types\n");
+	seq_printf(seq,
+		   "   excessive collision         %ld\n",
+		   pAC->stats.tx_aborted_errors);
+	seq_printf(seq,
+		   "   carrier                     %lld\n",
+		   pPnmiStat->StatTxCarrierCts);
+	seq_printf(seq,
+		   "   fifo underrun               %lld\n",
+		   pPnmiStat->StatTxFifoUnderrunCts);
+	seq_printf(seq,
+		   "   heartbeat                   %lld\n",
+		   pPnmiStat->StatTxCarrierCts);
+	seq_printf(seq,
+		   "   window                      %ld\n",
+		   pAC->stats.tx_window_errors);
 
-	*buffer_location = buffer + offset;
-	if (buffer_length >= len - offset) {
-		*eof = 1;
-	}
-	return (min_t(int, buffer_length, len - offset));
+	return 0;
 }
 
-
-
-
-
-/*****************************************************************************
- *
- * SkDoDiv - convert 64bit number
- *
- * Description:
- *	This function "converts" a long long number.
- *
- * Returns:
- *	remainder of division
- */
-static long SkDoDiv (long long Dividend, int Divisor, long long *pErg)
+static int sk_proc_open(struct inode *inode, struct file *file)
 {
- long   	Rest;
- long long 	Ergebnis;
- long   	Akku;
-
-
- Akku  = Dividend >> 32;
-
- Ergebnis = ((long long) (Akku / Divisor)) << 32;
- Rest = Akku % Divisor ;
-
- Akku = Rest << 16;
- Akku |= ((Dividend & 0xFFFF0000) >> 16);
-
-
- Ergebnis += ((long long) (Akku / Divisor)) << 16;
- Rest = Akku % Divisor ;
-
- Akku = Rest << 16;
- Akku |= (Dividend & 0xFFFF);
-
- Ergebnis += (Akku / Divisor);
- Rest = Akku % Divisor ;
-
- *pErg = Ergebnis;
- return (Rest);
+	return single_open(file, sk_seq_show, PDE(inode)->data);
 }
 
-
-#if 0
-#define do_div(n,base) ({ \
-long long __res; \
-__res = ((unsigned long long) n) % (unsigned) base; \
-n = ((unsigned long long) n) / (unsigned) base; \
-__res; })
+struct file_operations sk_proc_fops = {
+	.owner = THIS_MODULE,
+	.open  = sk_proc_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
 
 #endif
-
-
-/*****************************************************************************
- *
- * SkNumber - Print results
- *
- * Description:
- *	This function converts a long long number into a string.
- *
- * Returns:
- *	number as string
- */
-char * SkNumber(char * str, long long num, int base, int size, int precision
-	,int type)
-{
-	char c,sign,tmp[66], *strorg = str;
-	const char *digits="0123456789abcdefghijklmnopqrstuvwxyz";
-	int i;
-
-	if (type & LARGE)
-		digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
-	if (type & LEFT)
-		type &= ~ZEROPAD;
-	if (base < 2 || base > 36)
-		return 0;
-	c = (type & ZEROPAD) ? '0' : ' ';
-	sign = 0;
-	if (type & SIGN) {
-		if (num < 0) {
-			sign = '-';
-			num = -num;
-			size--;
-		} else if (type & PLUS) {
-			sign = '+';
-			size--;
-		} else if (type & SPACE) {
-			sign = ' ';
-			size--;
-		}
-	}
-	if (type & SPECIALX) {
-		if (base == 16)
-			size -= 2;
-		else if (base == 8)
-			size--;
-	}
-	i = 0;
-	if (num == 0)
-		tmp[i++]='0';
-	else while (num != 0)
-		tmp[i++] = digits[SkDoDiv(num,base, &num)];
-
-	if (i > precision)
-		precision = i;
-	size -= precision;
-	if (!(type&(ZEROPAD+LEFT)))
-		while(size-->0)
-			*str++ = ' ';
-	if (sign)
-		*str++ = sign;
-	if (type & SPECIALX) {
-		if (base==8)
-			*str++ = '0';
-		else if (base==16) {
-			*str++ = '0';
-			*str++ = digits[33];
-		}
-	}
-	if (!(type & LEFT))
-		while (size-- > 0)
-			*str++ = c;
-	while (i < precision--)
-		*str++ = '0';
-	while (i-- > 0)
-		*str++ = tmp[i];
-	while (size-- > 0)
-		*str++ = ' ';
-	
-	str[0] = '\0';
-	
-	return strorg;
-}
-
-
-
