From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
Subject: [PATCH] enic: Store permanent MAC address during probe()
Date: Mon, 20 Mar 2017 15:41:20 -0700
Message-ID: <20170320224120.24484-1-pjw@netapp.com>
Cc: PJ Waskiewicz <pjwaskiewicz@gmail.com>
To: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
        Sujith Sankar <ssujith@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Neel Patel <neepatel@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34888 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbdCTWl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 18:41:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id n11so7916081pfg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 15:41:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <pjwaskiewicz@gmail.com>

The permanent MAC address is useful to store for things like ethtool,
and when bonding with modes such as active/passive or LACP.  This
follows the model of other Ethernet drivers, such as ixgbe.

This was verified on a C220 chassis with the Cisco VNIC Ethernet device.

Signed-off-by: PJ Waskiewicz <pjwaskiewicz@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 4b87bee..8bb2114 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -964,6 +964,16 @@ void enic_reset_addr_lists(struct enic *enic)
 	enic->flags = 0;
 }
 
+static int enic_set_perm_mac_addr(struct net_device *netdev, char *addr)
+{
+	if (!is_valid_ether_addr(addr) && !is_zero_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->perm_addr, addr, netdev->addr_len);
+
+	return 0;
+}
+
 static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 {
 	struct enic *enic = netdev_priv(netdev);
@@ -2872,6 +2882,14 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_dev_deinit;
 	}
 
+	/* Store off permanent MAC address
+	 */
+	err = enic_set_perm_mac_addr(netdev, enic->mac_addr);
+	if (err) {
+		dev_err(dev, "Invalid MAC address, aborting\n");
+		goto err_out_dev_deinit;
+	}
+
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
 	/* rx coalesce time already got initialized. This gets used
 	 * if adaptive coal is turned off
-- 
2.10.2
