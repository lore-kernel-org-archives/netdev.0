From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [patch]switch kaweth driver to netdevops
Date: Thu, 8 Jan 2009 14:22:54 +0100
Message-ID: <200901081422.55536.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This converts the kaweth ethernet USB driver to netdevops.

Signed-off-by: Oliver Neukum<oneukum-l3A5Bk7waGM@public.gmane.org>

	Regards
		Oliver

commit f439f3ec3c68586f92dd692f220e44fd898a50bb
Author: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Date:   Wed Jan 7 14:31:21 2009 +0100

    convert kaweth to new netdev ops

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 2ee034f..e166b87 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -251,7 +251,6 @@ struct kaweth_device
 	struct net_device_stats stats;
 };
 
-
 /****************************************************************
  *     kaweth_control
  ****************************************************************/
@@ -975,6 +974,17 @@ static int kaweth_resume(struct usb_interface *intf)
 /****************************************************************
  *     kaweth_probe
  ****************************************************************/
+
+
+static const struct net_device_ops kaweth_netdev_ops = {
+	.ndo_open =			kaweth_open,
+	.ndo_stop =			kaweth_close,
+	.ndo_start_xmit =		kaweth_start_xmit,
+	.ndo_tx_timeout =		kaweth_tx_timeout,
+	.ndo_set_multicast_list =	kaweth_set_rx_mode,
+	.ndo_get_stats =		kaweth_netdev_stats,
+};
+
 static int kaweth_probe(
 		struct usb_interface *intf,
 		const struct usb_device_id *id      /* from id_table */
@@ -1147,22 +1157,13 @@ err_fw:
 	memcpy(netdev->dev_addr, &kaweth->configuration.hw_addr,
                sizeof(kaweth->configuration.hw_addr));
 
-	netdev->open = kaweth_open;
-	netdev->stop = kaweth_close;
-
+	netdev->netdev_ops = &kaweth_netdev_ops;
 	netdev->watchdog_timeo = KAWETH_TX_TIMEOUT;
-	netdev->tx_timeout = kaweth_tx_timeout;
-
-	netdev->hard_start_xmit = kaweth_start_xmit;
-	netdev->set_multicast_list = kaweth_set_rx_mode;
-	netdev->get_stats = kaweth_netdev_stats;
 	netdev->mtu = le16_to_cpu(kaweth->configuration.segment_size);
 	SET_ETHTOOL_OPS(netdev, &ops);
 
 	/* kaweth is zeroed as part of alloc_netdev */
-
 	INIT_DELAYED_WORK(&kaweth->lowmem_work, kaweth_resubmit_tl);
