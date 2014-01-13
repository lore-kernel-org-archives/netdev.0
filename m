From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sh_eth: fix garbled TX error message
Date: Sun, 12 Jan 2014 17:24:01 -0800
Message-ID: <1389576241.24849.10.camel@joe-AO722>
References: <201401110241.49471.sergei.shtylyov@cogentembedded.com>
	 <20140113004532.GJ15296@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:44213 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751019AbaAMBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 20:24:06 -0500
In-Reply-To: <20140113004532.GJ15296@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 09:45 +0900, Simon Horman wrote:
> On Sat, Jan 11, 2014 at 02:41:49AM +0300, Sergei Shtylyov wrote:
> > sh_eth_error() in case of a TX error tries to print a message using 2 dev_err()
> > calls with the first string not finished by '\n', so that the resulting message
> > would inevitably come out garbled, with something like "3net eth0: " inserted
> > in the middle.  Avoid that by merging 2 calls into one.

I believe this interleaving should not happen since
commit e28d713704117bca0820c732210df6075b09f13b
(2.6.31 days)

Perhaps it'd be better to use netdev_<level> and
netif_<level> instead of dev_<level> and pr_<level>.

uncompiled/untested...
---

 drivers/net/ethernet/renesas/sh_eth.c | 63 ++++++++++++++++-------------------
 1 file changed, 28 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8884107..6baad48 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -334,7 +334,7 @@ static void sh_eth_select_mii(struct net_device *ndev)
 		value = 0x0;
 		break;
 	default:
-		pr_warn("PHY interface mode was not setup. Set to MII.\n");
+		netdev_warn(ndev, "PHY interface mode was not setup. Set to MII.\n");
 		value = 0x1;
 		break;
 	}
@@ -756,7 +756,7 @@ static int sh_eth_check_reset(struct net_device *ndev)
 		cnt--;
 	}
 	if (cnt <= 0) {
-		pr_err("Device reset failed\n");
+		netdev_err(ndev, "Device reset failed\n");
 		ret = -ETIMEDOUT;
 	}
 	return ret;
@@ -1456,8 +1456,7 @@ ignore_link:
 		/* Unused write back interrupt */
 		if (intr_status & EESR_TABT) {	/* Transmit Abort int */
 			ndev->stats.tx_aborted_errors++;
-			if (netif_msg_tx_err(mdp))
-				dev_err(&ndev->dev, "Transmit Abort\n");
+			netif_err(mdp, tx_err, ndev, "Transmit Abort\n");
 		}
 	}
 
@@ -1466,45 +1465,38 @@ ignore_link:
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
 			ndev->stats.rx_frame_errors++;
-			if (netif_msg_rx_err(mdp))
-				dev_err(&ndev->dev, "Receive Abort\n");
+			netif_err(mdp, rx_err, ndev, "Receive Abort\n");
 		}
 	}
 
 	if (intr_status & EESR_TDE) {
 		/* Transmit Descriptor Empty int */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Transmit Descriptor Empty\n");
+		netif_err(mdp, tx_err, ndev, "Transmit Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_TFE) {
 		/* FIFO under flow */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Transmit FIFO Under flow\n");
+		netif_err(mdp, tx_err, ndev, "Transmit FIFO Under flow\n");
 	}
 
 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
 		ndev->stats.rx_over_errors++;
-
-		if (netif_msg_rx_err(mdp))
-			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
+		netif_err(mdp, rx_err, ndev, "Receive Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		ndev->stats.rx_fifo_errors++;
-		if (netif_msg_rx_err(mdp))
-			dev_err(&ndev->dev, "Receive FIFO Overflow\n");
+		netif_err(mdp, rx_err, ndev, "Receive FIFO Overflow\n");
 	}
 
 	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
 		/* Address Error */
 		ndev->stats.tx_fifo_errors++;
-		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Address Error\n");
+		netif_err(mdp, tx_err, ndev, "Address Error\n");
 	}
 
 	mask = EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE;
@@ -1514,10 +1506,9 @@ ignore_link:
 		/* Tx error */
 		u32 edtrr = sh_eth_read(ndev, EDTRR);
 		/* dmesg */
-		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
-			intr_status, mdp->cur_tx);
-		dev_err(&ndev->dev, "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
-			mdp->dirty_tx, (u32) ndev->state, edtrr);
+		netdev_err(ndev, "TX error. status=%08x cur_tx=%08x dirty_tx=%08x state=%08x EDTRR=%08x\n",
+			   intr_status, mdp->cur_tx, mdp->dirty_tx,
+			   (u32)ndev->state, edtrr);
 		/* dirty buffer free */
 		sh_eth_txfree(ndev);
 
@@ -1678,7 +1669,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
 			     mdp->phy_interface);
 	if (IS_ERR(phydev)) {
-		dev_err(&ndev->dev, "phy_connect failed\n");
+		netdev_err(ndev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -1864,12 +1855,12 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 
 	ret = sh_eth_ring_init(ndev);
 	if (ret < 0) {
-		dev_err(&ndev->dev, "%s: sh_eth_ring_init failed.\n", __func__);
+		netdev_err(ndev, "%s: sh_eth_ring_init failed\n", __func__);
 		return ret;
 	}
 	ret = sh_eth_dev_init(ndev, false);
 	if (ret < 0) {
-		dev_err(&ndev->dev, "%s: sh_eth_dev_init failed.\n", __func__);
+		netdev_err(ndev, "%s: sh_eth_dev_init failed\n", __func__);
 		return ret;
 	}
 
@@ -1910,7 +1901,7 @@ static int sh_eth_open(struct net_device *ndev)
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 			  mdp->cd->irq_flags, ndev->name, ndev);
 	if (ret) {
-		dev_err(&ndev->dev, "Can not assign IRQ number\n");
+		netdev_err(ndev, "Can not assign IRQ number\n");
 		goto out_napi_off;
 	}
 
@@ -1948,10 +1939,8 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 
 	netif_stop_queue(ndev);
 
-	if (netif_msg_timer(mdp)) {
-		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, resetting...\n",
-			ndev->name, (int)sh_eth_read(ndev, EESR));
-	}
+	netif_err(mdp, timer, ndev, "transmit timed out, status %08x, resetting...\n",
+		  (int)sh_eth_read(ndev, EESR));
 
 	/* tx_errors count up */
 	ndev->stats.tx_errors++;
@@ -2154,7 +2143,7 @@ static int sh_eth_tsu_busy(struct net_device *ndev)
 		udelay(10);
 		timeout--;
 		if (timeout <= 0) {
-			dev_err(&ndev->dev, "%s: timeout\n", __func__);
+			netdev_err(ndev, "%s: timeout\n", __func__);
 			return -ETIMEDOUT;
 		}
 	}
@@ -2571,7 +2560,6 @@ static const u16 *sh_eth_get_register_offset(int register_type)
 		reg_offset = sh_eth_offset_fast_sh3_sh2;
 		break;
 	default:
-		pr_err("Unknown register type (%d)\n", register_type);
 		break;
 	}
 
@@ -2675,6 +2663,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* set cpu data */
 	mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
 	mdp->reg_offset = sh_eth_get_register_offset(mdp->cd->register_type);
+	if (!mdp->reg_offset)
+		dev_err(&pdev->dev, "Unknown register type (%d)\n",
+			mdp->cd->register_type);
+
 	sh_eth_set_default_cpu_data(mdp->cd);
 
 	/* set function */
@@ -2691,9 +2683,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* read and set MAC address */
 	read_mac_address(ndev, pd->mac_addr);
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
-		dev_warn(&pdev->dev,
-			 "no valid MAC address supplied, using a random one.\n");
 		eth_hw_addr_random(ndev);
+		dev_warn(&pdev->dev,
+			 "no valid MAC address supplied, using random %pM\n",
+			 ndev->dev_addr);
 	}
 
 	/* ioremap the TSU registers */
@@ -2733,8 +2726,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_unregister;
 
 	/* print device information */
-	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
-		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
+	netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d\n",
+		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
 	platform_set_drvdata(pdev, ndev);
 
