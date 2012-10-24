From: Jonathan Nieder <jrnieder@gmail.com>
Subject: [3.2.y] e1000: fix vlan processing regression
Date: Tue, 23 Oct 2012 18:21:18 -0700
Message-ID: <20121024012118.GA6898@elie.Belkin>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1332917548-13102-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>, sassmann@redhat.com,
	"Andrey Jr. Melnikov" <temnota@kmv.ru>, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:39967 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933768Ab2JXBV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 21:21:27 -0400
Content-Disposition: inline
In-Reply-To: <1332917548-13102-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 20 Mar 2012 18:10:01 +0000

commit 52f5509fe8ccb607ff9b84ad618f244262336475 upstream.

This patch fixes a regression introduced by commit "e1000: do vlan
cleanup (799d531)".

Apparently some e1000 chips (not mine) are sensitive about the order of
setting vlan filter and vlan stripping/inserting functionality. So this
patch changes the order so it's the same as before vlan cleanup.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Tested-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
Tested-by: Andrey Jr. Melnikov <temnota@kmv.ru>
---
Hi Dave,

Would

 52f5509fe8cc e1000: fix vlan processing regression, 2012-03-20

be ok for 3.2.y?

It doesn't apply cleanly to kernels before v3.3-rc1~182^2~581 (net:
introduce and use netdev_features_t for device features sets) but a
backport is straightforward.  The patch is already in 3.3.y as
v3.3.6~52 (2012-05-12).  3.0.y doesn't need this because it doesn't
have 799d531.

Andrey (cc-ed) tested[1] this patch against a 3.2.23-based kernel and
found it to work ok.

Thoughts of all kinds welcome, as always.

Thanks,
Jonathan

[1] http://bugs.debian.org/690956

 drivers/net/ethernet/intel/e1000/e1000_main.c | 76 +++++++++++++++------------
 1 file changed, 42 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index c5f6b0e60c39..6546191a5951 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -168,6 +168,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
 
 static bool e1000_vlan_used(struct e1000_adapter *adapter);
 static void e1000_vlan_mode(struct net_device *netdev, u32 features);
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on);
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -1219,7 +1221,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	e1000_vlan_mode(netdev, netdev->features);
+	e1000_vlan_filter_on_off(adapter, false);
 
 	/* print bus type/speed/width info */
 	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
@@ -4553,43 +4555,11 @@ static bool e1000_vlan_used(struct e1000_adapter *adapter)
 	return false;
 }
 
-static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
-				     bool filter_on)
+static void __e1000_vlan_mode(struct e1000_adapter *adapter, u32 features)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl;
-
-	if (!test_bit(__E1000_DOWN, &adapter->flags))
-		e1000_irq_disable(adapter);
-
-	if (filter_on) {
-		/* enable VLAN receive filtering */
-		rctl = er32(RCTL);
-		rctl &= ~E1000_RCTL_CFIEN;
-		if (!(adapter->netdev->flags & IFF_PROMISC))
-			rctl |= E1000_RCTL_VFE;
-		ew32(RCTL, rctl);
-		e1000_update_mng_vlan(adapter);
-	} else {
-		/* disable VLAN receive filtering */
-		rctl = er32(RCTL);
-		rctl &= ~E1000_RCTL_VFE;
-		ew32(RCTL, rctl);
-	}
-
-	if (!test_bit(__E1000_DOWN, &adapter->flags))
-		e1000_irq_enable(adapter);
-}
-
-static void e1000_vlan_mode(struct net_device *netdev, u32 features)
-{
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl;
 
-	if (!test_bit(__E1000_DOWN, &adapter->flags))
-		e1000_irq_disable(adapter);
-
 	ctrl = er32(CTRL);
 	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
@@ -4599,6 +4569,44 @@ static void e1000_vlan_mode(struct net_device *netdev, u32 features)
 		ctrl &= ~E1000_CTRL_VME;
 	}
 	ew32(CTRL, ctrl);
+}
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rctl;
+
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
+
+	__e1000_vlan_mode(adapter, adapter->netdev->features);
+	if (filter_on) {
+		/* enable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl &= ~E1000_RCTL_CFIEN;
+		if (!(adapter->netdev->flags & IFF_PROMISC))
+			rctl |= E1000_RCTL_VFE;
+		ew32(RCTL, rctl);
+		e1000_update_mng_vlan(adapter);
+	} else {
+		/* disable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl &= ~E1000_RCTL_VFE;
+		ew32(RCTL, rctl);
+	}
+
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
+}
+
+static void e1000_vlan_mode(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
+
+	__e1000_vlan_mode(adapter, features);
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
-- 
1.8.0.rc2
