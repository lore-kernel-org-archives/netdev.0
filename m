From: akpm@osdl.org
Subject: [patch 3/7] forcedeth: power management support
Date: Tue, 10 Oct 2006 14:33:27 -0700
Message-ID: <200610102133.k9ALXR2b024968@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, romieu@fr.zoreil.com,
	aabdulla@nvidia.com, manfred@colorfullife.com, ranma@tdiedrich.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58265 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030452AbWJJVdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:33:45 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>

Tobias Diedrich <ranma@tdiedrich.de> sayeth:

Vanilla forcedeth doesn't seem to support suspend and an ifdown/up-cycle is
needed to get it working again after suspend.  Francois Romieu's "Awfully
experimental" patch is working just fine for me (with message signalled
interrupts disabled) and has survived quite a few suspend/resume cycles.

So I'd very much like to see (at least partial, with msi disabled)
suspend support for forcedeth in mainline.

(Addresses http://bugzilla.kernel.org/show_bug.cgi?id=6398)

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc; Jeff Garzik <jeff@garzik.org>
Cc: Manfred Spraul <manfred@colorfullife.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/forcedeth.c |   47 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 46 insertions(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-power-management-support drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-power-management-support
+++ a/drivers/net/forcedeth.c
@@ -4603,6 +4603,50 @@ static void __devexit nv_remove(struct p
 	pci_set_drvdata(pci_dev, NULL);
 }
 
+#ifdef CONFIG_PM
+static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		goto out;
+
+	netif_device_detach(dev);
+
+	// Gross.
+	nv_close(dev);
+
+	pci_save_state(pdev);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+out:
+	return 0;
+}
+
+static int nv_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	int rc = 0;
+
+	if (!netif_running(dev))
+		goto out;
+
+	netif_device_attach(dev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	pci_enable_wake(pdev, PCI_D0, 0);
+
+	rc = nv_open(dev);
+out:
+	return rc;
+}
+#else
+#define nv_suspend NULL
+#define nv_resume NULL
+#endif /* CONFIG_PM */
+
 static struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_1),
@@ -4704,9 +4748,10 @@ static struct pci_driver driver = {
 	.id_table = pci_tbl,
 	.probe = nv_probe,
 	.remove = __devexit_p(nv_remove),
+	.suspend = nv_suspend,
+	.resume	= nv_resume,
 };
 
-
 static int __init init_nic(void)
 {
 	printk(KERN_INFO "forcedeth.c: Reverse Engineered nForce ethernet driver. Version %s.\n", FORCEDETH_VERSION);
_
