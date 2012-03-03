From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] e100: Support sending custom Ethernet CRC
Date: Fri,  2 Mar 2012 18:24:18 -0800
Message-ID: <1330741468-23900-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47073 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab2CCCYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:33 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can aid with testing the RX logic for bad
CRCs.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 3ecbded..6f9f70a 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -412,6 +412,10 @@ enum cb_status {
 	cb_ok       = 0x2000,
 };
 
+/**
+ * cb_command - Command Block flags
+ * @cb_tx_nc:  0: controler does CRC (normal),  1: CRC from skb memory
+ */
 enum cb_command {
 	cb_nop    = 0x0000,
 	cb_iaaddr = 0x0001,
@@ -421,6 +425,7 @@ enum cb_command {
 	cb_ucode  = 0x0005,
 	cb_dump   = 0x0006,
 	cb_tx_sf  = 0x0008,
+	cb_tx_nc  = 0x0010,
 	cb_cid    = 0x1f00,
 	cb_i      = 0x2000,
 	cb_s      = 0x4000,
@@ -1724,6 +1729,16 @@ static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 	struct sk_buff *skb)
 {
 	cb->command = nic->tx_command;
+
+	/*
+	 * Use the last 4 bytes of the SKB payload packet as the CRC, used for
+	 * testing, ie sending frames with bad CRC.
+	 */
+	if (unlikely(skb->no_fcs))
+		cb->command |= __constant_cpu_to_le16(cb_tx_nc);
+	else
+		cb->command &= ~__constant_cpu_to_le16(cb_tx_nc);
+
 	/* interrupt every 16 packets regardless of delay */
 	if ((nic->cbs_avail & ~15) == nic->cbs_avail)
 		cb->command |= cpu_to_le16(cb_i);
@@ -2778,6 +2793,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 
 	netdev->hw_features |= NETIF_F_RXFCS;
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	netdev->netdev_ops = &e100_netdev_ops;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
-- 
1.7.7.6
