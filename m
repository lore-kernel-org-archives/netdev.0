From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 1/4] atl1: fix transmit timeout bug
Date: Sat, 27 Sep 2008 09:17:20 -0500
Message-ID: <1222525043-4648-2-git-send-email-jacliburn@bellsouth.net>
References: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:64424 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbYI0O1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2008 10:27:18 -0400
In-Reply-To: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See http://marc.info/?l=linux-netdev&m=121931988219314&w=2

Stop the queue and turn off carrier to prevent transmit timeouts
when the cable is unplugged/replugged.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
---
 drivers/net/atlx/atl1.c |    4 +++-
 drivers/net/atlx/atlx.c |    1 -
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e23ce77..e00a986 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2642,6 +2642,7 @@ static void atl1_down(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	netif_stop_queue(netdev);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_config_timer);
 	adapter->phy_timer_pending = false;
@@ -2655,7 +2656,6 @@ static void atl1_down(struct atl1_adapter *adapter)
 	adapter->link_speed = SPEED_0;
 	adapter->link_duplex = -1;
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	atl1_clean_tx_ring(adapter);
 	atl1_clean_rx_ring(adapter);
@@ -2724,6 +2724,8 @@ static int atl1_open(struct net_device *netdev)
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	int err;
 
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = atl1_setup_ring_resources(adapter);
 	if (err)
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index b3e7fcf..3cc9d10 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -105,7 +105,6 @@ static void atlx_check_for_link(struct atlx_adapter *adapter)
 				netdev->name);
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
 		}
 	}
 	schedule_work(&adapter->link_chg_task);
-- 
1.5.5.1

