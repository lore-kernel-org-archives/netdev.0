From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] sk98lin: MII ioctl support
Date: Thu, 5 Oct 2006 10:21:26 -0700
Message-ID: <20061005102126.0be5e6c5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46533 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751734AbWJER1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 13:27:46 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add MII ioctl support to the deprecated sk98lin driver.
This allows comparison with skge driver's PHY settings.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/sk98lin/skge.c
+++ linux-2.6/drivers/net/sk98lin/skge.c
@@ -113,6 +113,7 @@
 #include	<linux/init.h>
 #include	<linux/dma-mapping.h>
 #include	<linux/ip.h>
+#include	<linux/mii.h>
 
 #include	"h/skdrv1st.h"
 #include	"h/skdrv2nd.h"
@@ -2843,6 +2844,56 @@ unsigned long	Flags;			/* for spin lock 
 	return(&pAC->stats);
 } /* SkGeStats */
 
+/*
+ * Basic MII register access
+ */
+static int SkGeMiiIoctl(struct net_device *dev,
+			struct mii_ioctl_data *data, int cmd)
+{
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	SK_IOC IoC = pAC->IoBase;
+	int Port = pNet->PortNr;
+	SK_GEPORT *pPrt = &pAC->GIni.GP[Port];
+	unsigned long Flags;
+	int err = 0;
+	int reg = data->reg_num & 0x1f;
+	SK_U16 val = data->val_in;
+
+	if (!netif_running(dev))
+		return -ENODEV;	/* Phy still in reset */
+
+	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
+	switch(cmd) {
+	case SIOCGMIIPHY:
+		data->phy_id = pPrt->PhyAddr;
+
+		/* fallthru */
+	case SIOCGMIIREG:
+		if (pAC->GIni.GIGenesis)
+			SkXmPhyRead(pAC, IoC, Port, reg, &val);
+		else
+			SkGmPhyRead(pAC, IoC, Port, reg, &val);
+
+		data->val_out = val;
+		break;
+
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			err = -EPERM;
+
+		else if (pAC->GIni.GIGenesis)
+			SkXmPhyWrite(pAC, IoC, Port, reg, val);
+		else
+			SkGmPhyWrite(pAC, IoC, Port, reg, val);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+	}
+        spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
+	return err;
+}
+
 
 /*****************************************************************************
  *
@@ -2876,6 +2927,9 @@ int		HeaderLength = sizeof(SK_U32) + siz
 	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	
+	if (cmd == SIOCGMIIPHY || cmd == SIOCSMIIREG || cmd == SIOCGMIIREG)
+	    return SkGeMiiIoctl(dev, if_mii(rq), cmd);
+
 	if(copy_from_user(&Ioctl, rq->ifr_data, sizeof(SK_GE_IOCTL))) {
 		return -EFAULT;
 	}
