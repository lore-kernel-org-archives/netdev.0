From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) sk98lin -- use seq_file for /proc
Date: Fri, 26 Sep 2003 11:17:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926111757.5a7e1109.shemminger@osdl.org>
References: <20030904160658.5ae22c0d.shemminger@osdl.org>
	<1220606764.18887.129.camel@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Ralph Roesler <rroesler@syskonnect.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <1220606764.18887.129.camel@mlindner-lin>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace proc_read with seq_file interface which is much cleaner.

Also, instead of searching the list of devices looking for the
name which is slow and would break if interface name changes;
store a pointer to device in the proc entry, and retrieve
it from the information saved by single_open.

Formatting and other behaviours are retained.

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	Fri Sep 26 11:10:48 2003
+++ b/drivers/net/sk98lin/skge.c	Fri Sep 26 11:10:48 2003
@@ -577,13 +577,7 @@
 #ifdef CONFIG_PROC_FS
 static const char 	SK_Root_Dir_entry[] = "sk98lin";
 static struct		proc_dir_entry *pSkRootDir;
-
-extern int 		sk_proc_read(	char   *buffer,
-					char	**buffer_location,
-					off_t	offset,
-					int	buffer_length,
-					int	*eof,
-					void	*data);
+extern struct		file_operations sk_proc_fops;
 #endif
 
 extern void SkDimEnableModerationIfNeeded(SK_AC *pAC);	
@@ -762,16 +756,11 @@
 		}
 		
 		/* Create proc file */
-		if (pSkRootDir && 
-		    (pProcFile = create_proc_entry(dev->name,
-						  S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
-						   pSkRootDir))) {
-			pProcFile->read_proc = sk_proc_read;
-			pProcFile->write_proc = NULL;
-			pProcFile->nlink = 1;
-			pProcFile->size = sizeof(dev->name + 1);
-			pProcFile->data = (void *)pProcFile;
-			pProcFile->owner = THIS_MODULE;
+		if (pSkRootDir 
+		    && (pProcFile = create_proc_entry(dev->name, S_IRUGO,
+						      pSkRootDir))) {
+			pProcFile->proc_fops = &sk_proc_fops;
+			pProcFile->data = dev;
 		}
 #endif
 
@@ -827,16 +816,11 @@
 
 #ifdef CONFIG_PROC_FS
 			if (pSkRootDir 
-			    && (pProcFile = create_proc_entry(dev->name,
-							      S_IFREG | S_IXUSR | S_IWGRP | S_IROTH,
+			    && (pProcFile = create_proc_entry(dev->name, 
+							      S_IRUGO,
 							      pSkRootDir))) {
-		
-				pProcFile->read_proc = sk_proc_read;
-				pProcFile->write_proc = NULL;
-				pProcFile->nlink = 1;
-				pProcFile->size = sizeof(dev->name + 1);
-				pProcFile->data = (void *)pProcFile;
-				pProcFile->owner = THIS_MODULE;
+				pProcFile->proc_fops = &sk_proc_fops;
+				pProcFile->data = dev;
 			}
 #endif
 
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	Fri Sep 26 11:10:48 2003
+++ b/drivers/net/sk98lin/skproc.c	Fri Sep 26 11:10:48 2003
@@ -90,276 +90,227 @@
  ******************************************************************************/
 
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include "h/skdrv1st.h"
 #include "h/skdrv2nd.h"
 
-	extern struct net_device	*SkGeRootDev;
+#ifdef CONFIG_PROC_FS
 
+extern struct net_device	*SkGeRootDev;
 
-int sk_proc_read(char *buffer,
-				char **buffer_location,
-				off_t offset,
-				int buffer_length,
-				int *eof,
-				void *data);
-
-
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
+	struct net_device *dev = seq->private;
+	DEV_NET		*pNet = dev->priv;
+	SK_AC		*pAC = pNet->pAC;
+	SK_PNMI_STRUCT_DATA *pPnmiStruct = &pAC->PnmiStruct;
+	SK_PNMI_STAT	*pPnmiStat = &pPnmiStruct->Stat[0];
+	int unit = !(pAC->dev[0] == dev);
 	int i;
-	DEV_NET					*pNet;
-	SK_AC					*pAC;
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
+	char sens_msg[50];
+
+	seq_printf(seq,
+		   "\nDetailed statistic for device %s\n",
+		   dev->name);
+	seq_printf(seq,
+		   "=======================================\n");
 	
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
+	/* Board statistics */
+	seq_printf(seq, 
+		   "\nBoard statistics\n\n");
+	seq_printf(seq,
+		   "Active Port                    %c\n",
+		   'A' + pAC->Rlmt.Net[unit].Port[pAC->Rlmt.
+						 Net[unit].PrefPort]->PortNumber);
+	seq_printf(seq,
+		   "Preferred Port                 %c\n",
+		   'A' + pAC->Rlmt.Net[unit].Port[pAC->Rlmt.
+						 Net[unit].PrefPort]->PortNumber);
+
+	seq_printf(seq,
+		   "Bus speed (MHz)                %d\n",
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
-					"Received bytes                 %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxOctetsOkCts);
-				len += sprintf(buffer + len,
-					"Received packets               %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxOkCts);
+	/*Receive statistics */
+	seq_printf(seq, 
+		   "\nReceive statistics\n\n");
+
+	seq_printf(seq,
+		   "Received bytes                 %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxOctetsOkCts);
+	seq_printf(seq,
+		   "Received packets               %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxOkCts);
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
-					"Receive errors                 %Ld\n",
-					(unsigned long long) pPnmiStruct->InErrorsCts);
-				len += sprintf(buffer + len,
-					"Receive dropped                %Ld\n",
-					(unsigned long long) pPnmiStruct->RxNoBufCts);
-				len += sprintf(buffer + len,
-					"Received multicast             %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxMulticastOkCts);
-				len += sprintf(buffer + len,
-					"Receive error types\n");
-				len += sprintf(buffer + len,
-					"   length                      %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxRuntCts);
-				len += sprintf(buffer + len,
-					"   buffer overflow             %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxFifoOverflowCts);
-				len += sprintf(buffer + len,
-					"   bad crc                     %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxFcsCts);
-				len += sprintf(buffer + len,
-					"   framing                     %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxFramingCts);
-				len += sprintf(buffer + len,
-					"   missed frames               %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxMissedCts);
-
-				if (pNet->Mtu > 1500)
-					pPnmiStat->StatRxTooLongCts = 0;
-
-				len += sprintf(buffer + len,
-					"   too long                    %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxTooLongCts);					
-				len += sprintf(buffer + len,
-					"   carrier extension           %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxCextCts);				
-				len += sprintf(buffer + len,
-					"   too short                   %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxShortsCts);				
-				len += sprintf(buffer + len,
-					"   symbol                      %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxSymbolCts);				
-				len += sprintf(buffer + len,
-					"   LLC MAC size                %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxIRLengthCts);				
-				len += sprintf(buffer + len,
-					"   carrier event               %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxCarrierCts);				
-				len += sprintf(buffer + len,
-					"   jabber                      %Ld\n",
-					(unsigned long long) pPnmiStat->StatRxJabberCts);				
-
-
-				/*Transmit statistics */
-				len += sprintf(buffer + len, 
-				"\nTransmit statistics\n\n");
+	if (pNet->Mtu > 1500) 
+		pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts -
+			pPnmiStat->StatRxTooLongCts;
+
+	seq_printf(seq,
+		   "Receive errors                 %Ld\n",
+		   (unsigned long long) pPnmiStruct->InErrorsCts);
+	seq_printf(seq,
+		   "Receive dropped                %Ld\n",
+		   (unsigned long long) pPnmiStruct->RxNoBufCts);
+	seq_printf(seq,
+		   "Received multicast             %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxMulticastOkCts);
+	seq_printf(seq,
+		   "Receive error types\n");
+	seq_printf(seq,
+		   "   length                      %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxRuntCts);
+	seq_printf(seq,
+		   "   buffer overflow             %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxFifoOverflowCts);
+	seq_printf(seq,
+		   "   bad crc                     %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxFcsCts);
+	seq_printf(seq,
+		   "   framing                     %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxFramingCts);
+	seq_printf(seq,
+		   "   missed frames               %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxMissedCts);
+
+	if (pNet->Mtu > 1500)
+		pPnmiStat->StatRxTooLongCts = 0;
+
+	seq_printf(seq,
+		   "   too long                    %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxTooLongCts);					
+	seq_printf(seq,
+		   "   carrier extension           %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxCextCts);				
+	seq_printf(seq,
+		   "   too short                   %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxShortsCts);				
+	seq_printf(seq,
+		   "   symbol                      %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxSymbolCts);				
+	seq_printf(seq,
+		   "   LLC MAC size                %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxIRLengthCts);				
+	seq_printf(seq,
+		   "   carrier event               %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxCarrierCts);				
+	seq_printf(seq,
+		   "   jabber                      %Ld\n",
+		   (unsigned long long) pPnmiStat->StatRxJabberCts);				
+
+
+	/*Transmit statistics */
+	seq_printf(seq, 
+		   "\nTransmit statistics\n\n");
 				
-				len += sprintf(buffer + len,
-					"Transmited bytes               %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxOctetsOkCts);
-				len += sprintf(buffer + len,
-					"Transmited packets             %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxOkCts);
-				len += sprintf(buffer + len,
-					"Transmit errors                %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sprintf(buffer + len,
-					"Transmit dropped               %Ld\n",
-					(unsigned long long) pPnmiStruct->TxNoBufCts);
-				len += sprintf(buffer + len,
-					"Transmit collisions            %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sprintf(buffer + len,
-					"Transmit error types\n");
-				len += sprintf(buffer + len,
-					"   excessive collision         %ld\n",
-					pAC->stats.tx_aborted_errors);
-				len += sprintf(buffer + len,
-					"   carrier                     %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sprintf(buffer + len,
-					"   fifo underrun               %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxFifoUnderrunCts);
-				len += sprintf(buffer + len,
-					"   heartbeat                   %Ld\n",
-					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sprintf(buffer + len,
-					"   window                      %ld\n",
-					pAC->stats.tx_window_errors);
+	seq_printf(seq,
+		   "Transmited bytes               %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxOctetsOkCts);
+	seq_printf(seq,
+		   "Transmited packets             %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxOkCts);
+	seq_printf(seq,
+		   "Transmit errors                %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
+	seq_printf(seq,
+		   "Transmit dropped               %Ld\n",
+		   (unsigned long long) pPnmiStruct->TxNoBufCts);
+	seq_printf(seq,
+		   "Transmit collisions            %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
+	seq_printf(seq,
+		   "Transmit error types\n");
+	seq_printf(seq,
+		   "   excessive collision         %ld\n",
+		   pAC->stats.tx_aborted_errors);
+	seq_printf(seq,
+		   "   carrier                     %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxCarrierCts);
+	seq_printf(seq,
+		   "   fifo underrun               %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxFifoUnderrunCts);
+	seq_printf(seq,
+		   "   heartbeat                   %Ld\n",
+		   (unsigned long long) pPnmiStat->StatTxCarrierCts);
+	seq_printf(seq,
+		   "   window                      %ld\n",
+		   pAC->stats.tx_window_errors);
 				
-			}
-		}
-		SkgeProcDev = next;
-	}
-	if (offset >= len) {
-		*eof = 1;
-		return 0;
-	}
-
-	*buffer_location = buffer + offset;
-	if (buffer_length >= len - offset) {
-		*eof = 1;
-	}
-	return (min_t(int, buffer_length, len - offset));
+	return 0;
 }
 
 
+static int sk_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, sk_seq_show, PDE(inode)->data);
+}
+
+struct file_operations sk_proc_fops = {
+	.owner = THIS_MODULE,
+	.open  = sk_proc_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+#endif
