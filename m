From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Sun, 14 Sep 2008 18:17:14 -0500
Message-ID: <20080914181714.34935d9c@osprey.hogchain.net>
References: <20080821115849.GA2126@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:53745 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbYINXRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 19:17:16 -0400
In-Reply-To: <20080821115849.GA2126@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2008 15:58:49 +0400
adobriyan@gmail.com wrote:

> This message happens more or less every reboot, sometimes cable
> unplug/plug is needed to restore connectivity, otherwise card is
> working fine.
> 
> 
> [   22.570010] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> [   26.570011] NET: Registered protocol family 10
> [   37.551934] eth0: no IPv6 routers present
> 
> 	[rebooted box which is directly connected to a box with atl1]
> 
> [ 2078.740004] atl1 0000:03:00.0: eth0 link is down
> [ 2080.790004] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full
> duplex [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> [ 2086.050004] ------------[ cut here ]------------
> [ 2086.050004] WARNING: at net/sched/sch_generic.c:221
[...]

Alexey,

Can you please try this patch?

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
