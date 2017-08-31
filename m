From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] netvsc: cleanup datapath switch
Date: Thu, 31 Aug 2017 16:16:12 -0700
Message-ID: <20170831231613.15805-2-sthemmin@microsoft.com>
References: <20170831231613.15805-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:38659 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdHaXQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:16:17 -0400
Received: by mail-pg0-f46.google.com with SMTP id b8so2991708pgn.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:16:16 -0700 (PDT)
In-Reply-To: <20170831231613.15805-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use one routine for datapath up/down. Don't need to reopen
the rndis layer.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 38 +++++++-------------------------------
 1 file changed, 7 insertions(+), 31 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index fac44c5c8d0d..128165e49c9a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1842,11 +1842,13 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 	return NOTIFY_OK;
 }
 
-static int netvsc_vf_up(struct net_device *vf_netdev)
+/* VF up/down change detected, schedule to change data path */
+static int netvsc_vf_changed(struct net_device *vf_netdev)
 {
 	struct net_device_context *net_device_ctx;
 	struct netvsc_device *netvsc_dev;
 	struct net_device *ndev;
+	bool vf_is_up = netif_running(vf_netdev);
 
 	ndev = get_netvsc_byref(vf_netdev);
 	if (!ndev)
@@ -1857,34 +1859,9 @@ static int netvsc_vf_up(struct net_device *vf_netdev)
 	if (!netvsc_dev)
 		return NOTIFY_DONE;
 
-	/* Bump refcount when datapath is acvive - Why? */
-	rndis_filter_open(netvsc_dev);
-
-	/* notify the host to switch the data path. */
-	netvsc_switch_datapath(ndev, true);
-	netdev_info(ndev, "Data path switched to VF: %s\n", vf_netdev->name);
-
-	return NOTIFY_OK;
-}
-
-static int netvsc_vf_down(struct net_device *vf_netdev)
-{
-	struct net_device_context *net_device_ctx;
-	struct netvsc_device *netvsc_dev;
-	struct net_device *ndev;
-
-	ndev = get_netvsc_byref(vf_netdev);
-	if (!ndev)
-		return NOTIFY_DONE;
-
-	net_device_ctx = netdev_priv(ndev);
-	netvsc_dev = rtnl_dereference(net_device_ctx->nvdev);
-	if (!netvsc_dev)
-		return NOTIFY_DONE;
-
-	netvsc_switch_datapath(ndev, false);
-	netdev_info(ndev, "Data path switched from VF: %s\n", vf_netdev->name);
-	rndis_filter_close(netvsc_dev);
+	netvsc_switch_datapath(ndev, vf_is_up);
+	netdev_info(ndev, "Data path switched %s VF: %s\n",
+		    vf_is_up ? "to" : "from", vf_netdev->name);
 
 	return NOTIFY_OK;
 }
@@ -2094,9 +2071,8 @@ static int netvsc_netdev_event(struct notifier_block *this,
 	case NETDEV_UNREGISTER:
 		return netvsc_unregister_vf(event_dev);
 	case NETDEV_UP:
-		return netvsc_vf_up(event_dev);
 	case NETDEV_DOWN:
-		return netvsc_vf_down(event_dev);
+		return netvsc_vf_changed(event_dev);
 	default:
 		return NOTIFY_DONE;
 	}
-- 
2.11.0
