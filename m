From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 2/9] staging: slicoss: notifiy network stack about change in
 link state
Date: Fri, 22 Jul 2016 23:09:12 +0200
Message-ID: <1469221759-17652-3-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Notify the network stack about link states via netif_carrier_[off|on]().
Also set the link state off initially and when the interface is brought
down.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slicoss.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index dae07410..a9323a9 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1016,6 +1016,7 @@ static void slic_link_upr_complete(struct adapter *adapter, u32 isr)
 	/* link has gone from up to down */
 	if (linkup == LINK_DOWN) {
 		adapter->linkstate = LINK_DOWN;
+		netif_carrier_off(adapter->netdev);
 		return;
 	}
 
@@ -1028,6 +1029,7 @@ static void slic_link_upr_complete(struct adapter *adapter, u32 isr)
 		slic_config_set(adapter, true);
 		adapter->linkstate = LINK_UP;
 		netif_start_queue(adapter->netdev);
+		netif_carrier_on(adapter->netdev);
 	}
 }
 
@@ -2418,6 +2420,7 @@ static int slic_entry_open(struct net_device *dev)
 	int status;
 
 	netif_stop_queue(adapter->netdev);
+	netif_carrier_off(dev);
 
 	spin_lock_irqsave(&slic_global.driver_lock, flags);
 	if (!adapter->activated) {
@@ -2530,6 +2533,9 @@ static int slic_entry_halt(struct net_device *dev)
 #endif
 
 	spin_unlock_irqrestore(&slic_global.driver_lock, flags);
+
+	netif_carrier_off(dev);
+
 	return 0;
 }
 
@@ -3172,6 +3178,8 @@ static int slic_entry_probe(struct pci_dev *pcidev,
 	netdev->irq = adapter->irq;
 	netdev->netdev_ops = &slic_netdev_ops;
 
+	netif_carrier_off(netdev);
+
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err) {
-- 
1.9.1
