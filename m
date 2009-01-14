From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] ax88796: start_xmit fix using net_device_ops
Date: Wed, 14 Jan 2009 16:38:27 +0900
Message-ID: <20090114073827.26909.56261.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	shemminger@vyatta.com, ben-linux@fluff.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:64689 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758763AbZANHkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 02:40:21 -0500
Received: by rv-out-0506.google.com with SMTP id k40so409124rvb.1
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 23:40:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

This patch hooks up the start_xmit/tx_timeout/get_stats callbacks
in the ax88796 driver since they no longer are installed by the
lib8390 code. Without this patch the function dev_hard_start_xmit()
crashes due to a start_xmit callback with the value NULL.

While at it, update the ax88796 driver to make use of use of struct
net_device_ops.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 This patch fixes the backplane ethernet crash on SuperH Highlander.

 drivers/net/ax88796.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

--- 0001/drivers/net/ax88796.c
+++ work/drivers/net/ax88796.c	2009-01-14 15:06:13.000000000 +0900
@@ -37,7 +37,10 @@ static int phy_debug = 0;
 #define __ei_open       ax_ei_open
 #define __ei_close      ax_ei_close
 #define __ei_poll	ax_ei_poll
+#define __ei_start_xmit ax_ei_start_xmit
 #define __ei_tx_timeout ax_ei_tx_timeout
+#define __ei_get_stats  ax_ei_get_stats
+#define __ei_set_multicast_list ax_ei_set_multicast_list
 #define __ei_interrupt  ax_ei_interrupt
 #define ____alloc_ei_netdev ax__alloc_ei_netdev
 #define __NS8390_init   ax_NS8390_init
@@ -623,6 +626,23 @@ static void ax_eeprom_register_write(str
 }
 #endif
 
+static const struct net_device_ops ax_netdev_ops = {
+	.ndo_open		= ax_open,
+	.ndo_stop		= ax_close,
+	.ndo_do_ioctl		= ax_ioctl,
+
+	.ndo_start_xmit		= ax_ei_start_xmit,
+	.ndo_tx_timeout		= ax_ei_tx_timeout,
+	.ndo_get_stats		= ax_ei_get_stats,
+	.ndo_set_multicast_list = ax_ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ax_ei_poll,
+#endif
+};
+
 /* setup code */
 
 static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
@@ -738,9 +758,7 @@ static int ax_init_dev(struct net_device
 	ei_status.get_8390_hdr	= &ax_get_8390_hdr;
 	ei_status.priv = 0;
 
-	dev->open		= ax_open;
-	dev->stop		= ax_close;
-	dev->do_ioctl		= ax_ioctl;
+	dev->netdev_ops		= &ax_netdev_ops;
 	dev->ethtool_ops	= &ax_ethtool_ops;
 
 	ax->msg_enable		= NETIF_MSG_LINK;
@@ -753,9 +771,6 @@ static int ax_init_dev(struct net_device
 	ax->mii.mdio_write	= ax_phy_write;
 	ax->mii.dev		= dev;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ax_ei_poll;
-#endif
 	ax_NS8390_init(dev, 0);
 
 	if (first_init)
