From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] ll_temac: fix mac address setting
Date: Tue,  1 Jan 2013 14:30:19 +0100
Message-ID: <1357047019-1037-8-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:62564 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358Ab3AANas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:48 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so6639744eek.37
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:47 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, when invalid address was passed to ndo_set_mac_address,
random mac was generated and set. Fix this by returning -EADDRNOTAVAIL
in this situation.

Also polish the code around a bit.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c | 31 ++++++++++++++++-------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index aad909d..5022093 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -319,18 +319,10 @@ out:
  * net_device_ops
  */
 
-static int temac_set_mac_address(struct net_device *ndev, void *address)
+static void temac_do_set_mac_address(struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
 
-	if (address)
-		memcpy(ndev->dev_addr, address, ETH_ALEN);
-
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		eth_hw_addr_random(ndev);
-	else
-		ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
-
 	/* set up unicast MAC address filter set its mac address */
 	mutex_lock(&lp->indirect_mutex);
 	temac_indirect_out32(lp, XTE_UAW0_OFFSET,
@@ -344,15 +336,26 @@ static int temac_set_mac_address(struct net_device *ndev, void *address)
 			     (ndev->dev_addr[4] & 0x000000ff) |
 			     (ndev->dev_addr[5] << 8));
 	mutex_unlock(&lp->indirect_mutex);
+}
 
+static int temac_init_mac_address(struct net_device *ndev, void *address)
+{
+	memcpy(ndev->dev_addr, address, ETH_ALEN);
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		eth_hw_addr_random(ndev);
+	temac_do_set_mac_address(ndev);
 	return 0;
 }
 
-static int netdev_set_mac_address(struct net_device *ndev, void *p)
+static int temac_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	return temac_set_mac_address(ndev, addr->sa_data);
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(ndev->dev_addr, addr->sa_data, ETH_ALEN);
+	temac_do_set_mac_address(ndev);
+	return 0;
 }
 
 static void temac_set_multicast_list(struct net_device *ndev)
@@ -579,7 +582,7 @@ static void temac_device_reset(struct net_device *ndev)
 	temac_setoptions(ndev,
 			 lp->options & ~(XTE_OPTION_TXEN | XTE_OPTION_RXEN));
 
-	temac_set_mac_address(ndev, NULL);
+	temac_do_set_mac_address(ndev);
 
 	/* Set address filter table */
 	temac_set_multicast_list(ndev);
@@ -938,7 +941,7 @@ static const struct net_device_ops temac_netdev_ops = {
 	.ndo_open = temac_open,
 	.ndo_stop = temac_stop,
 	.ndo_start_xmit = temac_start_xmit,
-	.ndo_set_mac_address = netdev_set_mac_address,
+	.ndo_set_mac_address = temac_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_do_ioctl = temac_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1106,7 +1109,7 @@ static int temac_of_probe(struct platform_device *op)
 		rc = -ENODEV;
 		goto err_iounmap_2;
 	}
-	temac_set_mac_address(ndev, (void *)addr);
+	temac_init_mac_address(ndev, (void *)addr);
 
 	rc = temac_mdio_setup(lp, op->dev.of_node);
 	if (rc)
-- 
1.8.0
