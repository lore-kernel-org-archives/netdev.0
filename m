From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-2.6] cxgb4: fix reported state of interfaces without link
Date: Wed, 19 Jan 2011 17:29:05 -0800
Message-ID: <1295486945-22015-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26156 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab1ATB3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 20:29:07 -0500
Received: from tom.asicdesigners.com (tom.asicdesigners.com [10.192.167.168])
	by stargate.chelsio.com (8.13.1/8.13.1) with ESMTP id p0K1T78R017861
	for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 17:29:07 -0800
Received: from tom.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by tom.asicdesigners.com (8.14.4/8.14.3) with ESMTP id p0K1T59C022067
	for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 17:29:06 -0800
Received: (from dm@localhost)
	by tom.asicdesigners.com (8.14.4/8.14.4/Submit) id p0K1T54f022065
	for netdev@vger.kernel.org; Wed, 19 Jan 2011 17:29:05 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tools like ip and ifconfig report incorrect state for cxgb4
interfaces that are up but do not have link and do so until first link
establishment.  This is because the initial netif_carrier_off call is
before register_netdev and it needs to be after to be fully effective.
Fix this by moving netif_carrier_off into .ndo_open.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 059c1ee..ec35d45 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2710,6 +2710,8 @@ static int cxgb_open(struct net_device *dev)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
+	netif_carrier_off(dev);
+
 	if (!(adapter->flags & FULL_INIT_DONE)) {
 		err = cxgb_up(adapter);
 		if (err < 0)
@@ -3661,7 +3663,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		pi->xact_addr_filt = -1;
 		pi->rx_offload = RX_CSO;
 		pi->port_id = i;
-		netif_carrier_off(netdev);
 		netdev->irq = pdev->irq;
 
 		netdev->features |= NETIF_F_SG | TSO_FLAGS;
-- 
1.7.3.4

