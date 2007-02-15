From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/4] sis190: RTNL and flush_scheduled_work deadlock
Date: Thu, 15 Feb 2007 23:37:29 +0100
Message-ID: <20070215223729.GB19840@electric-eye.fr.zoreil.com>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39343 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161581AbXBOWkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 17:40:13 -0500
Content-Disposition: inline
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 45d91b1..b08508b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -909,6 +909,9 @@ static void sis190_phy_task(struct work_struct *work)
 
 	rtnl_lock();
 
+	if (!netif_running(dev))
+		goto out_unlock;
+
 	val = mdio_read(ioaddr, phy_id, MII_BMCR);
 	if (val & BMCR_RESET) {
 		// FIXME: needlessly high ?  -- FR 02/07/2005
@@ -981,6 +984,7 @@ static void sis190_phy_task(struct work_struct *work)
 		netif_carrier_on(dev);
 	}
 
+out_unlock:
 	rtnl_unlock();
 }
 
@@ -1102,8 +1106,6 @@ static void sis190_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	flush_scheduled_work();
-
 	do {
 		spin_lock_irq(&tp->lock);
 
@@ -1857,6 +1859,7 @@ static void __devexit sis190_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	sis190_mii_remove(dev);
+	flush_scheduled_work();
 	unregister_netdev(dev);
 	sis190_release_board(pdev);
 	pci_set_drvdata(pdev, NULL);
-- 
1.4.4.4

