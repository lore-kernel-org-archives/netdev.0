From: Ralf Baechle <ralf@linux-mips.org>
Subject: [IOC3] Fix link autonegotiation timer.
Date: Sat, 17 Feb 2007 02:51:15 +0000
Message-ID: <20070217025115.GA20247@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:52795 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946248AbXBQCwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 21:52:03 -0500
Received: from localhost.localdomain ([127.0.0.1]:48311 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28573812AbXBQCwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 02:52:00 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Start link negotiation in the open method.  Previously it was started
on driver initialialization and shutdown on close so an ifdown would
have results in closing negotiation for good.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index ee6bca0..f5d277c 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -831,13 +831,17 @@ static int ioc3_mii_init(struct ioc3_private *ip)
 	}
 
 	ip->mii.phy_id = i;
+
+out:
+	return res;
+}
+
+static void ioc3_mii_start(struct ioc3_private *ip)
+{
 	ip->ioc3_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
 	ip->ioc3_timer.data = (unsigned long) ip;
 	ip->ioc3_timer.function = &ioc3_timer;
 	add_timer(&ip->ioc3_timer);
-
-out:
-	return res;
 }
 
 static inline void ioc3_clean_rx_ring(struct ioc3_private *ip)
@@ -1066,6 +1070,7 @@ static int ioc3_open(struct net_device *dev)
 	ip->ehar_h = 0;
 	ip->ehar_l = 0;
 	ioc3_init(dev);
+	ioc3_mii_start(ip);
 
 	netif_start_queue(dev);
 	return 0;
@@ -1269,6 +1274,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_stop;
 	}
 
+	ioc3_mii_start(ip);
 	ioc3_ssram_disc(ip);
 	ioc3_get_eaddr(ip);
 
@@ -1307,6 +1313,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 out_stop:
 	ioc3_stop(ip);
+	del_timer_sync(&ip->ioc3_timer);
 	ioc3_free_rings(ip);
 out_res:
 	pci_release_regions(pdev);
@@ -1328,6 +1335,8 @@ static void __devexit ioc3_remove_one (struct pci_dev *pdev)
 	struct ioc3 *ioc3 = ip->regs;
 
 	unregister_netdev(dev);
+	del_timer_sync(&ip->ioc3_timer);
+
 	iounmap(ioc3);
 	pci_release_regions(pdev);
 	free_netdev(dev);
@@ -1483,6 +1492,7 @@ static void ioc3_timeout(struct net_device *dev)
 	ioc3_stop(ip);
 	ioc3_init(dev);
 	ioc3_mii_init(ip);
+	ioc3_mii_start(ip);
 
 	spin_unlock_irq(&ip->ioc3_lock);
 
