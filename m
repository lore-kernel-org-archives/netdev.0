From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/25) sk98: device description can be a stack variable
Date: Mon, 15 Nov 2004 15:34:08 -0800
Message-ID: <20041115153408.11c45ee9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Device name description is only used during the probe process so
it doesn't have to be stored in board structure.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 13:33:22 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 13:33:22 -08:00
@@ -398,8 +398,6 @@
 	
 	SK_IOC		IoBase;		/* register set of adapter */
 	int		BoardLevel;	/* level of active hw init (0-2) */
-	char		DeviceStr[80];	/* adapter string from vpd */
-	SK_U32		AllocFlag;	/* flag allocation of resources */
 	struct pci_dev	*PciDev;	/* for access to pci config space */
 	SK_U32		PciDevId;	/* pci device id */
 	struct net_device *dev[2];	/* pointer to device struct */
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:33:22 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:33:22 -08:00
@@ -204,7 +204,6 @@
 static struct	net_device_stats *SkGeStats(struct net_device *dev);
 static int	SkGeIoctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void	GetConfiguration(SK_AC*);
-static void	ProductStr(SK_AC*);
 static int	XmitFrame(SK_AC*, TX_PORT*, struct sk_buff*);
 static void	FreeTxDescriptors(SK_AC*pAC, TX_PORT*);
 static void	FillRxRing(SK_AC*, RX_PORT*);
@@ -3792,25 +3791,14 @@
  *
  * Returns: N/A
  */
-static void ProductStr(
-SK_AC	*pAC		/* pointer to adapter context */
-)
-{
-int	StrLen = 80;		/* length of the string, defined in SK_AC */
-char	Keyword[] = VPD_NAME;	/* vpd productname identifier */
-int	ReturnCode;		/* return code from vpd_read */
-unsigned long Flags;
+static inline void ProductStr(SK_AC *pAC, char *buf, int len)
+{
+	unsigned long flags;
 
-	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-	ReturnCode = VpdRead(pAC, pAC->IoBase, Keyword, pAC->DeviceStr,
-		&StrLen);
-	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-	if (ReturnCode != 0) {
-		/* there was an error reading the vpd data */
-		SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ERROR,
-			("Error reading VPD data: %d\n", ReturnCode));
-		pAC->DeviceStr[0] = '\0';
-	}
+	spin_lock_irqsave(&pAC->SlowPathLock, flags);
+	if (VpdRead(pAC, pAC->IoBase, VPD_NAME, buf, &len)) 
+		snprintf(buf, len, "Error reading VPD data\n");
+	spin_unlock_irqrestore(&pAC->SlowPathLock, flags);
 } /* ProductStr */
 
 /*****************************************************************************
@@ -4837,6 +4825,7 @@
 	struct net_device	*dev = NULL;
 	static int boards_found = 0;
 	int error = -ENODEV;
+	char DeviceStr[80];
 
 	if (pci_enable_device(pdev))
 		goto out;
@@ -4916,8 +4905,8 @@
 	}
 
 	/* Print adapter specific string from vpd */
-	ProductStr(pAC);
-	printk("%s: %s\n", dev->name, pAC->DeviceStr);
+	ProductStr(pAC, DeviceStr, sizeof(DeviceStr));
+	printk("%s: %s\n", dev->name, DeviceStr);
 
 	/* Print configuration settings */
 	printk("      PrefPort:%c  RlmtMode:%s\n",
@@ -4979,7 +4968,7 @@
 			memcpy(&dev->dev_addr,
 					&pAC->Addr.Net[1].CurrentMacAddress, 6);
 	
-			printk("%s: %s\n", dev->name, pAC->DeviceStr);
+			printk("%s: %s\n", dev->name, DeviceStr);
 			printk("      PrefPort:B  RlmtMode:Dual Check Link State\n");
 		}
 	}
