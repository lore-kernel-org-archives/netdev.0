From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 3/5] skge: proc code cleanup
Date: Mon, 18 Oct 2004 15:23:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018152308.4415a461@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Partial cleanup of skge proc code.
  * Use SK_ prefix for sk_proc_fops for naming consistency
  * Add printf attribute to sk_proc_print to force format checks
  * global "len" was set but never used.
  * return from sk_proc_print was then always ignored.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-10-18 15:08:29 -07:00
+++ b/drivers/net/sk98lin/skge.c	2004-10-18 15:08:29 -07:00
@@ -237,7 +237,7 @@
 #ifdef CONFIG_PROC_FS
 static const char 	SK_Root_Dir_entry[] = "sk98lin";
 static struct		proc_dir_entry *pSkRootDir;
-extern struct	file_operations sk_proc_fops;
+extern struct	file_operations SK_proc_fops;
 #endif
 
 extern void SkDimEnableModerationIfNeeded(SK_AC *pAC);	
@@ -4977,7 +4977,7 @@
 #ifdef CONFIG_PROC_FS
 	pProcFile = create_proc_entry(dev->name, S_IRUGO, pSkRootDir);
 	if (pProcFile) {
-		pProcFile->proc_fops = &sk_proc_fops;
+		pProcFile->proc_fops = &SK_proc_fops;
 		pProcFile->data = dev;
 		pProcFile->owner = THIS_MODULE;
 	}
@@ -5032,7 +5032,7 @@
 			pProcFile = create_proc_entry(dev->name, S_IRUGO,
 					pSkRootDir);
 			if (pProcFile) {
-				pProcFile->proc_fops = &sk_proc_fops;
+				pProcFile->proc_fops = &SK_proc_fops;
 				pProcFile->data = dev;
 				pProcFile->owner = THIS_MODULE;
 			}
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-10-18 15:08:29 -07:00
+++ b/drivers/net/sk98lin/skproc.c	2004-10-18 15:08:29 -07:00
@@ -32,13 +32,13 @@
 #include "h/skversion.h"
 
 extern struct SK_NET_DEVICE *SkGeRootDev;
-static int sk_proc_print(void *writePtr, char *format, ...);
+static void sk_proc_print(void *writePtr, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
 static void sk_gen_browse(void *buffer);
-int len;
 
 static int sk_seq_show(struct seq_file *seq, void *v);
 static int sk_proc_open(struct inode *inode, struct file *file);
-struct file_operations sk_proc_fops = {
+struct file_operations SK_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= sk_proc_open,
 	.read		= seq_read,
@@ -108,35 +108,35 @@
 	
 			if (strcmp(pAC->dev[t-1]->name, currDev->name) == 0) {
 				pPnmiStat = &pPnmiStruct->Stat[0];
-				len = sk_proc_print(buffer, 
+				sk_proc_print(buffer, 
 					"\nDetailed statistic for device %s\n",
 					pAC->dev[t-1]->name);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"=======================================\n");
 	
 				/* Board statistics */
-				len += sk_proc_print(buffer, 
+				sk_proc_print(buffer, 
 					"\nBoard statistics\n\n");
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Active Port                    %c\n",
 					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
 					Net[t-1].PrefPort]->PortNumber);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Preferred Port                 %c\n",
 					'A' + pAC->Rlmt.Net[t-1].Port[pAC->Rlmt.
 					Net[t-1].PrefPort]->PortNumber);
 
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Bus speed (MHz)                %d\n",
 					pPnmiStruct->BusSpeed);
 
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Bus width (Bit)                %d\n",
 					pPnmiStruct->BusWidth);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Driver version                 %s\n",
 					VER_STRING);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Hardware revision              v%d.%d\n",
 					(pAC->GIni.GIPciHwRev >> 4) & 0x0F,
 					pAC->GIni.GIPciHwRev & 0x0F);
@@ -148,7 +148,7 @@
 					case 1:
 						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
 						strcat(sens_msg, " (C)");
-						len += sk_proc_print(buffer,
+						sk_proc_print(buffer,
 							"%-25s      %d.%02d\n",
 							sens_msg,
 							pAC->I2c.SenTable[i].SenValue / 10,
@@ -156,7 +156,7 @@
 
 						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
 						strcat(sens_msg, " (F)");
-						len += sk_proc_print(buffer,
+						sk_proc_print(buffer,
 							"%-25s      %d.%02d\n",
 							sens_msg,
 							((((pAC->I2c.SenTable[i].SenValue)
@@ -167,7 +167,7 @@
 					case 2:
 						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
 						strcat(sens_msg, " (V)");
-						len += sk_proc_print(buffer,
+						sk_proc_print(buffer,
 							"%-25s      %d.%03d\n",
 							sens_msg,
 							pAC->I2c.SenTable[i].SenValue / 1000,
@@ -176,7 +176,7 @@
 					case 3:
 						strcpy(sens_msg, pAC->I2c.SenTable[i].SenDesc);
 						strcat(sens_msg, " (rpm)");
-						len += sk_proc_print(buffer,
+						sk_proc_print(buffer,
 							"%-25s      %d\n",
 							sens_msg,
 							pAC->I2c.SenTable[i].SenValue);
@@ -187,13 +187,13 @@
 				}
 				
 				/*Receive statistics */
-				len += sk_proc_print(buffer, 
+				sk_proc_print(buffer, 
 				"\nReceive statistics\n\n");
 
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Received bytes                 %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxOctetsOkCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Received packets               %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxOkCts);
 #if 0
@@ -208,93 +208,93 @@
 					pPnmiStruct->InErrorsCts = pPnmiStruct->InErrorsCts -
 						pPnmiStat->StatRxTooLongCts;
 
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Receive errors                 %Lu\n",
 					(unsigned long long) pPnmiStruct->InErrorsCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Receive dropped                %Lu\n",
 					(unsigned long long) pPnmiStruct->RxNoBufCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Received multicast             %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxMulticastOkCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Receive error types\n");
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   length                      %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxRuntCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   buffer overflow             %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxFifoOverflowCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   bad crc                     %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxFcsCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   framing                     %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxFramingCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   missed frames               %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxMissedCts);
 
 				if (pNet->Mtu > 1500)
 					pPnmiStat->StatRxTooLongCts = 0;
 
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   too long                    %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxTooLongCts);					
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   carrier extension           %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxCextCts);				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   too short                   %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxShortsCts);				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   symbol                      %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxSymbolCts);				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   LLC MAC size                %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxIRLengthCts);				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   carrier event               %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxCarrierCts);				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   jabber                      %Lu\n",
 					(unsigned long long) pPnmiStat->StatRxJabberCts);				
 
 
 				/*Transmit statistics */
-				len += sk_proc_print(buffer, 
+				sk_proc_print(buffer, 
 				"\nTransmit statistics\n\n");
 				
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmited bytes               %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxOctetsOkCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmited packets             %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxOkCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmit errors                %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmit dropped               %Lu\n",
 					(unsigned long long) pPnmiStruct->TxNoBufCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmit collisions            %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxSingleCollisionCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"Transmit error types\n");
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   excessive collision         %ld\n",
 					pAC->stats.tx_aborted_errors);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   carrier                     %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   fifo underrun               %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxFifoUnderrunCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   heartbeat                   %Lu\n",
 					(unsigned long long) pPnmiStat->StatTxCarrierCts);
-				len += sk_proc_print(buffer,
+				sk_proc_print(buffer,
 					"   window                      %ld\n",
 					pAC->stats.tx_window_errors);
 				
@@ -315,12 +315,11 @@
  * Returns: number of bytes written
  *      
  */ 
-static int sk_proc_print(void *writePtr, char *format, ...)
+static void sk_proc_print(void *writePtr, const char *format, ...)
 {   
 #define MAX_LEN_SINGLE_LINE 256
 	char     str[MAX_LEN_SINGLE_LINE];
 	va_list  a_start;
-	int      lenght = 0;
 
 	struct seq_file *seq = (struct seq_file *) writePtr;
 
@@ -330,10 +329,7 @@
 	vsprintf(str, format, a_start);
 	va_end(a_start);
 
-	lenght = strlen(str);
-
-	seq_printf(seq, str);
-	return lenght;
+	seq_printf(seq, "%s", str);
 }
 
 /*****************************************************************************
