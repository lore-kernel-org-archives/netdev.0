From: "Bahadir Balban" <bahadir.balban@gmail.com>
Subject: smsc911x changes for new NAPI
Date: Wed, 28 Nov 2007 17:51:24 +0000
Message-ID: <7ac1e90c0711280951k8a5a50eg13cb7435f1eca402@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:65010 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbXK1RvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 12:51:25 -0500
Received: by an-out-0708.google.com with SMTP id d31so317971and
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2007 09:51:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have made the following changes to our off-tree 2.6.22 smsc911x
driver, to make it run on 2.6.24-rc2. However the NAPI poll function
does not get called after an rx irq. Can you comment on what's wrong?

Thanks,
Bahadir


diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b7fe2f3..e5c6c4a 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -98,7 +98,6 @@ struct smsc911x_data {
 	spinlock_t phy_lock;
 	spinlock_t dev_lock;

-	struct net_device_stats stats;
 	struct mii_if_info mii;
 	unsigned int using_extphy;
 	u32 msg_enable;
@@ -106,6 +105,8 @@ struct smsc911x_data {
 	unsigned int gpio_setting;
 	unsigned int gpio_orig_setting;
 #endif
+	struct net_device *netdev;
+	struct napi_struct napi;
 	struct timer_list link_poll_timer;
 	unsigned int stop_link_poll;

@@ -903,6 +904,7 @@ static unsigned int
smsc911x_tx_get_txstatcount(struct smsc911x_data *pdata)
 /* Reads tx statuses and increments counters where necessary */
 static void smsc911x_tx_update_txcounters(struct smsc911x_data *pdata)
 {
+	struct net_device *netdev = pdata->netdev;
 	unsigned int tx_stat;

 	while ((tx_stat = smsc911x_tx_get_txstatus(pdata)) != 0) {
@@ -917,24 +919,24 @@ static void smsc911x_tx_update_txcounters(struct
smsc911x_data *pdata)
 			SMSC_WARNING("Packet tag reserved bit is high");
 		} else {
 			if (unlikely(tx_stat & 0x00008000)) {
-				pdata->stats.tx_errors++;
+				netdev->stats.tx_errors++;
 			} else {
-				pdata->stats.tx_packets++;
-				pdata->stats.tx_bytes += (tx_stat >> 16);
+				netdev->stats.tx_packets++;
+				netdev->stats.tx_bytes += (tx_stat >> 16);
 			}
 			if (unlikely(tx_stat & 0x00000100)) {
-				pdata->stats.collisions += 16;
-				pdata->stats.tx_aborted_errors += 1;
+				netdev->stats.collisions += 16;
+				netdev->stats.tx_aborted_errors += 1;
 			} else {
-				pdata->stats.collisions +=
+				netdev->stats.collisions +=
 				    ((tx_stat >> 3) & 0xF);
 			}
 			if (unlikely(tx_stat & 0x00000800)) {
-				pdata->stats.tx_carrier_errors += 1;
+				netdev->stats.tx_carrier_errors += 1;
 			}
 			if (unlikely(tx_stat & 0x00000200)) {
-				pdata->stats.collisions++;
-				pdata->stats.tx_aborted_errors++;
+				netdev->stats.collisions++;
+				netdev->stats.tx_aborted_errors++;
 			}
 		}
 	}
@@ -944,12 +946,13 @@ static void smsc911x_tx_update_txcounters(struct
smsc911x_data *pdata)
 static void
 smsc911x_rx_counterrors(struct smsc911x_data *pdata, unsigned int rxstat)
 {
+	struct net_device *netdev = pdata->netdev;
 	int crc_err = 0;

 	if (unlikely(rxstat & 0x00008000)) {
-		pdata->stats.rx_errors++;
+		netdev->stats.rx_errors++;
 		if (unlikely(rxstat & 0x00000002)) {
-			pdata->stats.rx_crc_errors++;
+			netdev->stats.rx_crc_errors++;
 			crc_err = 1;
 		}
 	}
@@ -957,10 +960,10 @@ smsc911x_rx_counterrors(struct smsc911x_data
*pdata, unsigned int rxstat)
 		if (unlikely((rxstat & 0x00001020) == 0x00001020)) {
 			/* Frame type indicates length,
 			 * and length error is set */
-			pdata->stats.rx_length_errors++;
+			netdev->stats.rx_length_errors++;
 		}
 		if (rxstat & RX_STS_MCAST_)
-			pdata->stats.multicast++;
+			netdev->stats.multicast++;
 	}
 }

@@ -990,13 +993,13 @@ smsc911x_rx_fastforward(struct smsc911x_data
*pdata, unsigned int pktbytes)
 }

 /* NAPI poll function */
-static int smsc911x_poll(struct net_device *dev, int *budget)
+static int smsc911x_poll(struct napi_struct *napi, int budget)
 {
-	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct smsc911x_data *pdata = container_of(napi, struct smsc911x_data, napi);
+	struct net_device *dev = pdata->netdev;
 	int npackets = 0;
-	int quota = min(dev->quota, *budget);

-	while (npackets < quota) {
+	while (npackets < budget) {
 		unsigned int pktlength;
 		unsigned int pktwords;
 		unsigned int rxstat = smsc911x_rx_get_rxstatus(pdata);
@@ -1027,15 +1030,15 @@ static int smsc911x_poll(struct net_device
*dev, int *budget)
 				netif_receive_skb(skb);

 				/* Update counters */
-				pdata->stats.rx_packets++;
-				pdata->stats.rx_bytes += (pktlength - 4);
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += (pktlength - 4);
 				dev->last_rx = jiffies;
 				npackets++;
 				continue;
 			} else {
 				SMSC_WARNING("Unable to allocate sk_buff "
 					     "for rx packet, in PIO path");
-				pdata->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		}
 		/* At this point, the packet is to be read out
@@ -1043,25 +1046,21 @@ static int smsc911x_poll(struct net_device
*dev, int *budget)
 		smsc911x_rx_fastforward(pdata, pktlength);
 	}

-	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
 	smsc911x_reg_write(INT_STS_RSFL_, pdata, INT_STS);

-	*budget -= npackets;
-	dev->quota -= npackets;
-
-	if (npackets < quota) {
+	if (npackets < budget) {
 		unsigned int temp;
 		/* We processed all packets available.  Tell NAPI it can
 		 * stop polling then re-enable rx interrupts */
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		temp = smsc911x_reg_read(pdata, INT_EN);
 		temp |= INT_EN_RSFL_EN_;
 		smsc911x_reg_write(temp, pdata, INT_EN);
-		return 0;
 	}

-	/* There are still packets waiting */
-	return 1;
+	/* Return total received packets */
+	return npackets;
 }

 /* Returns hash bit number for given MAC address
@@ -1294,6 +1293,7 @@ static int smsc911x_open(struct net_device *dev)
 	smsc911x_reg_write(TX_CFG_TX_ON_, pdata, TX_CFG);

 	netif_start_queue(dev);
+	napi_enable(&pdata->napi);
 	return 0;
 }

@@ -1302,6 +1302,8 @@ static int smsc911x_stop(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);

+	napi_disable(&pdata->napi);
+
 	pdata->stop_link_poll = 1;
 	del_timer_sync(&pdata->link_poll_timer);

@@ -1310,7 +1312,7 @@ static int smsc911x_stop(struct net_device *dev)
 	netif_stop_queue(dev);

 	/* At this point all Rx and Tx activity is stopped */
-	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
 	smsc911x_tx_update_txcounters(pdata);

 	SMSC_TRACE("Interface stopped");
@@ -1374,8 +1376,8 @@ static struct net_device_stats
*smsc911x_get_stats(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	smsc911x_tx_update_txcounters(pdata);
-	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
-	return &pdata->stats;
+	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	return &dev->stats;
 }

 /* Entry point for setting addressing modes */
@@ -1520,7 +1522,8 @@ static irqreturn_t smsc911x_irqhandler(int irq,
void *dev_id)
 		temp = smsc911x_reg_read(pdata, INT_EN);
 		temp &= (~INT_EN_RSFL_EN_);
 		smsc911x_reg_write(temp, pdata, INT_EN);
-		netif_rx_schedule(dev);
+		/* TODO: Can call netif_rx_schedule_prep here first */
+		netif_rx_schedule(dev, &pdata->napi);
 		serviced = IRQ_HANDLED;
 	}

@@ -2005,8 +2008,7 @@ static int smsc911x_init(struct net_device *dev)
 	dev->set_multicast_list = smsc911x_set_multicast_list;
 	dev->flags |= IFF_MULTICAST;
 	dev->do_ioctl = smsc911x_do_ioctl;
-	dev->poll = smsc911x_poll;
-	dev->weight = 64;
+	netif_napi_add(dev, &pdata->napi, smsc911x_poll, 64);
 	dev->ethtool_ops = &smsc911x_ethtool_ops;

 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2092,12 +2094,12 @@ static int smsc911x_drv_probe(struct
platform_device *pdev)
 		retval = -ENOMEM;
 		goto out_release_io_1;
 	}
-	
-	SET_MODULE_OWNER(dev);
+
 	SET_NETDEV_DEV(dev, &pdev->dev);

 	pdata = netdev_priv(dev);
-	
+	pdata->netdev = dev;
+
 	dev->irq = platform_get_irq(pdev, 0);
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
