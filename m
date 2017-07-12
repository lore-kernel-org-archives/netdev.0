From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH] igb: fix unused igb_deliver_wake_packet() warning when CONFIG_PM=n
Date: Wed, 12 Jul 2017 14:09:25 -0700
Message-ID: <20170712210925.4F647FAA@viggo.jf.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

I'm seeing warnings on kernel configurations where CONFIG_PM is
disabled.  It happens in 4.12, at least:

drivers/ethernet/intel/igb/igb_main.c:7988:13: warning: 'igb_deliver_wake_packet' defined but not used [-Wunused-function]

This is because igb_deliver_wake_packet() is defined outside of
the #ifdef", but is used only a single time within the #ifdef in
igb_resume().  Fix it by moving igb_deliver_wake_packet() next to
igb_resume() inside the #ifdef.

The diff ends up looking a bit funky here.  It *looks* like
igb_suspend() is getting moved, but that's an artifact of how
'diff' sees the changes.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: intel-wired-lan@lists.osuosl.org
Cc: netdev@vger.kernel.org
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/drivers/net/ethernet/intel/igb/igb_main.c |   46 ++++++++++++++--------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff -puN drivers/net/ethernet/intel/igb/igb_main.c~undef-igb_deliver_wake_packet drivers/net/ethernet/intel/igb/igb_main.c
--- a/drivers/net/ethernet/intel/igb/igb_main.c~undef-igb_deliver_wake_packet	2017-07-12 14:08:37.205721093 -0700
+++ b/drivers/net/ethernet/intel/igb/igb_main.c	2017-07-12 14:08:37.210721093 -0700
@@ -7985,6 +7985,29 @@ static int __igb_shutdown(struct pci_dev
 	return 0;
 }
 
+#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
+static int igb_suspend(struct device *dev)
+{
+	int retval;
+	bool wake;
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	retval = __igb_shutdown(pdev, &wake, 0);
+	if (retval)
+		return retval;
+
+	if (wake) {
+		pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+
+	return 0;
+}
+#endif /* CONFIG_PM_SLEEP */
+
 static void igb_deliver_wake_packet(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -8015,29 +8038,6 @@ static void igb_deliver_wake_packet(stru
 	netif_rx(skb);
 }
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_PM_SLEEP
-static int igb_suspend(struct device *dev)
-{
-	int retval;
-	bool wake;
-	struct pci_dev *pdev = to_pci_dev(dev);
-
-	retval = __igb_shutdown(pdev, &wake, 0);
-	if (retval)
-		return retval;
-
-	if (wake) {
-		pci_prepare_to_sleep(pdev);
-	} else {
-		pci_wake_from_d3(pdev, false);
-		pci_set_power_state(pdev, PCI_D3hot);
-	}
-
-	return 0;
-}
-#endif /* CONFIG_PM_SLEEP */
-
 static int igb_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
_
