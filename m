From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'jg-20061009-00' tag
Date: Mon, 9 Oct 2006 22:21:33 +0200
Message-ID: <20061009202133.GA18466@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, dragoran@feuerpokemon.de,
	ranma+kernel@tdiedrich.de, hchacha@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:31680 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964821AbWJIUXe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 16:23:34 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'jg-20061009-00' in repository
 
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git jg-20061009-00

to get the changes below.

Distance from 'upstream-fixes'
-----------------------------

$ git rev-list 2f614fe04f4463ff22234133319067d7361f54e5..jg-20061009-00
91a6ba7162852092080b0e710dc0ba0f35496308
73f5e28b336772c4b08ee82e5bf28ab872898ee1

Diffstat
--------

 drivers/net/forcedeth.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/r8169.c     |    1 +
 2 files changed, 44 insertions(+), 0 deletions(-)

Shortlog
--------
 
Andrew Morton:
      r8169: PCI ID for Corega Gigabit network card

Francois Romieu:
      forcedeth: restore network after swsup/resume or ACPI S3

Patch
-----

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 35467e0..c41a886 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4603,6 +4603,47 @@ static void __devexit nv_remove(struct p
 	pci_set_drvdata(pci_dev, NULL);
 }
 
+
+static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
+	int rc = 0;
+
+	if (!netif_running(dev))
+		goto out;
+
+	netif_device_detach(dev);
+
+	/* Gross. */
+	rc = nv_close(dev);
+
+	pci_save_state(pdev);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+out:
+	return rc;
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
+
 static struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_1),
@@ -4704,6 +4745,8 @@ static struct pci_driver driver = {
 	.id_table = pci_tbl,
 	.probe = nv_probe,
 	.remove = __devexit_p(nv_remove),
+	.suspend = nv_suspend,
+	.resume = nv_resume,
 };
 
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4c47c5b..c7309e9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -214,6 +214,7 @@ static struct pci_device_id rtl8169_pci_
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
-- 
Ueimor
