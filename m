From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] atheros/atlx: Simplify bit manipulations
Date: Fri, 23 Jan 2015 12:06:52 +0100
Message-ID: <1422011212-30095-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code 'if (foo & X) foo &= ~X;' is semantically equivalent to
simply 'foo &= ~X;', but gcc generates about four instructions for the
former, one for the latter. Similarly, if X consists of a single bit,
'if (!(foo & X)) X |= X;' can be replaced by 'foo |= X;'.

In the atl2 case, gcc does know how to merge the new adjacent
operations, so altogether this gives a nice little code size
reduction of about 80 bytes.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |  3 +--
 drivers/net/ethernet/atheros/atlx/atl2.c | 12 ++++--------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 2c8f398aeda9..d9d61d6e8386 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1667,8 +1667,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
 	unsigned long value;
 
 	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
-	if (value & PCI_COMMAND_INTX_DISABLE)
-		value &= ~PCI_COMMAND_INTX_DISABLE;
+	value &= ~PCI_COMMAND_INTX_DISABLE;
 	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
 }
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 84a09e8ddd9c..46d1b959daa8 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1278,14 +1278,10 @@ static void atl2_setup_pcicmd(struct pci_dev *pdev)
 
 	pci_read_config_word(pdev, PCI_COMMAND, &cmd);
 
-	if (cmd & PCI_COMMAND_INTX_DISABLE)
-		cmd &= ~PCI_COMMAND_INTX_DISABLE;
-	if (cmd & PCI_COMMAND_IO)
-		cmd &= ~PCI_COMMAND_IO;
-	if (0 == (cmd & PCI_COMMAND_MEMORY))
-		cmd |= PCI_COMMAND_MEMORY;
-	if (0 == (cmd & PCI_COMMAND_MASTER))
-		cmd |= PCI_COMMAND_MASTER;
+	cmd &= ~PCI_COMMAND_INTX_DISABLE;
+	cmd &= ~PCI_COMMAND_IO;
+	cmd |= PCI_COMMAND_MEMORY;
+	cmd |= PCI_COMMAND_MASTER;
 	pci_write_config_word(pdev, PCI_COMMAND, cmd);
 
 	/*
-- 
2.1.3
