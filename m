From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] e1000e: don't inadvertently re-set
	INTX_DISABLE
Date: Tue, 29 Jun 2010 21:12:05 -0700
Message-ID: <20100630040959.8652.31147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Dean Nelson <dnelson@redhat.com>, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:45003 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725Ab0F3EM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:12:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Nelson <dnelson@redhat.com>

Should e1000_test_msi() fail to see an msi interrupt, it attempts to
fallback to legacy INTx interrupts. But an error in the code may prevent
this from happening correctly.

Before calling e1000_test_msi_interrupt(), e1000_test_msi() disables SERR
by clearing the SERR bit from the just read PCI_COMMAND bits as it writes
them back out.

Upon return from calling e1000_test_msi_interrupt(), it re-enables SERR
by writing out the version of PCI_COMMAND it had previously read.

The problem with this is that e1000_test_msi_interrupt() calls
pci_disable_msi(), which eventually ends up in pci_intx(). And because
pci_intx() was called with enable set to 1, the INTX_DISABLE bit gets
cleared from PCI_COMMAND, which is what we want. But when we get back to
e1000_test_msi(), the INTX_DISABLE bit gets inadvertently re-set because
of the attempt by e1000_test_msi() to re-enable SERR.

The solution is to have e1000_test_msi() re-read the PCI_COMMAND bits as
part of its attempt to re-enable SERR.

During debugging/testing of this issue I found that not all the systems
I ran on had the SERR bit set to begin with. And on some of the systems
the same could be said for the INTX_DISABLE bit. Needless to say these
latter systems didn't have a problem falling back to legacy INTx
interrupts with the code as is.

Signed-off-by: Dean Nelson <dnelson@redhat.com>
CC: stable@kernel.org
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 71592ed..3e53ca7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3439,13 +3439,18 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
 
 	/* disable SERR in case the MSI write causes a master abort */
 	pci_read_config_word(adapter->pdev, PCI_COMMAND, &pci_cmd);
-	pci_write_config_word(adapter->pdev, PCI_COMMAND,
-			      pci_cmd & ~PCI_COMMAND_SERR);
+	if (pci_cmd & PCI_COMMAND_SERR)
+		pci_write_config_word(adapter->pdev, PCI_COMMAND,
+				      pci_cmd & ~PCI_COMMAND_SERR);
 
 	err = e1000_test_msi_interrupt(adapter);
 
-	/* restore previous setting of command word */
-	pci_write_config_word(adapter->pdev, PCI_COMMAND, pci_cmd);
+	/* re-enable SERR */
+	if (pci_cmd & PCI_COMMAND_SERR) {
+		pci_read_config_word(adapter->pdev, PCI_COMMAND, &pci_cmd);
+		pci_cmd |= PCI_COMMAND_SERR;
+		pci_write_config_word(adapter->pdev, PCI_COMMAND, pci_cmd);
+	}
 
 	/* success ! */
 	if (!err)

