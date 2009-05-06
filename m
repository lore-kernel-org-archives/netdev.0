From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/5] ixgbe: Proposed PARCH PCIE legacy I/O port
	free intel 10Gb NIC driver
Date: Wed, 06 May 2009 13:44:45 -0700
Message-ID: <20090506204444.18071.48678.stgit@localhost.localdomain>
References: <20090506204317.18071.96421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Masayuki Gouji <gouji.masayuki@jp.fujitsu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:41748
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932323AbZEFUpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:45:05 -0400
In-Reply-To: <20090506204317.18071.96421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gouji-new <gouji.masayuki@jp.fujitsu.com>

Traditionally Intel based NIC drivers request I/O port even though it
doesn't need that really.

Intel PCIE 10Gb driver (ixgbe) also requests I/O port but it doesn't
need it either.

This is a little inconvenient situation because sometimes we have to
handle those cards on the slots where any I/O space is not attached.

So we made pach which makes ixgbe driver legacy I/O port free.

Signed-off-by: Masayuki Gouji <gouji.masayuki@jp.fujitsu.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dd56adb..08f4a13 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3773,7 +3773,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
+
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		printk(KERN_ERR "ixgbe: Cannot enable PCI device from "
 				"suspend\n");
@@ -4778,7 +4779,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	u32 part_num, eec;
 
-	err = pci_enable_device(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
 
@@ -4798,9 +4799,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}
 
-	err = pci_request_regions(pdev, ixgbe_driver_name);
+	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
+	                                   IORESOURCE_MEM), ixgbe_driver_name);
 	if (err) {
-		dev_err(&pdev->dev, "pci_request_regions failed 0x%x\n", err);
+		dev_err(&pdev->dev,
+		        "pci_request_selected_regions failed 0x%x\n", err);
 		goto err_pci_reg;
 	}
 
@@ -5063,7 +5066,8 @@ err_eeprom:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, pci_select_bars(pdev,
+	                             IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -5115,7 +5119,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	ixgbe_release_hw_control(adapter);
 
 	iounmap(adapter->hw.hw_addr);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, pci_select_bars(pdev,
+	                             IORESOURCE_MEM));
 
 	DPRINTK(PROBE, INFO, "complete\n");
 
@@ -5169,7 +5174,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 	pci_ers_result_t result;
 	int err;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_enable_device_mem(pdev)) {
 		DPRINTK(PROBE, ERR,
 		        "Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;

