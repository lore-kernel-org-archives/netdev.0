From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.12.1 6/12] S2io: Support for runtime MTU change
Date: Thu,  7 Jul 2005 15:30:02 -0700 (PDT)
Message-ID: <20050707223002.E452789826@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Patch below supports MTU change on-the-fly(without bringing interface
down)

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_kernel/drivers/net/s2io.c linux-2.6.12-rc6/drivers/net/s2io.c
--- vanilla_kernel/drivers/net/s2io.c	2005-06-28 02:04:52.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.c	2005-06-28 02:07:26.000000000 -0700
@@ -2850,6 +2850,7 @@ int s2io_xmit(struct sk_buff *skb, struc
 	}
 
 	txdp->Control_2 |= config->tx_intr_type;
+
 	txdp->Control_1 |= (TXD_BUFFER0_SIZE(frg_len) |
 			    TXD_GATHER_CODE_FIRST);
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
@@ -4247,14 +4248,6 @@ int s2io_ioctl(struct net_device *dev, s
 int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t __iomem *bar0 = sp->bar0;
-	register u64 val64;
-
-	if (netif_running(dev)) {
-		DBG_PRINT(ERR_DBG, "%s: Must be stopped to ", dev->name);
-		DBG_PRINT(ERR_DBG, "change its MTU\n");
-		return -EBUSY;
-	}
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
 		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
@@ -4262,11 +4255,22 @@ int s2io_change_mtu(struct net_device *d
 		return -EPERM;
 	}
 
-	/* Set the new MTU into the PYLD register of the NIC */
-	val64 = new_mtu;
-	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
-
 	dev->mtu = new_mtu;
+	if (netif_running(dev)) {
+		s2io_card_down(sp);
+		netif_stop_queue(dev);
+		if (s2io_card_up(sp)) {
+			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
+				  __FUNCTION__);
+		}
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
+	} else { /* Device is down */
+		XENA_dev_config_t __iomem *bar0 = sp->bar0;
+		u64 val64 = new_mtu;
+
+		writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
+	}
 
 	return 0;
 }
