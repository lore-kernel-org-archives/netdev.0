From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] e1000e: Simplify MSI interrupt testing
Date: Mon, 13 Sep 2010 10:45:39 +0200
Message-ID: <201009131045.40018.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59555 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754723Ab0IMIpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 04:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is quite convoluted, simplify it. This also avoids calling
e1000_request_irq() without testing the value it returned, which was
bad.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
I understand that we need to request the IRQ again after testing, but
why doing it twice?

I sent this patch to the e1000-devel list on August 26th, 2010, but
didn't receive any answer:
http://sourceforge.net/mailarchive/forum.php?thread_name=201008261445.44334.jdelvare%40suse.de&forum_name=e1000-devel

 drivers/net/e1000e/netdev.c |   29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3385,22 +3385,16 @@ static int e1000_test_msi_interrupt(stru
 
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
-		err = -EIO;
-		e_info("MSI interrupt test failed!\n");
-	}
+		e_info("MSI interrupt test failed, using legacy interrupt.\n");
+	} else
+		e_dbg("MSI interrupt test succeeded!\n");
 
 	free_irq(adapter->pdev->irq, netdev);
 	pci_disable_msi(adapter->pdev);
 
-	if (err == -EIO)
-		goto msi_test_failed;
-
-	/* okay so the test worked, restore settings */
-	e_dbg("MSI interrupt test succeeded!\n");
 msi_test_failed:
 	e1000e_set_interrupt_capability(adapter);
-	e1000_request_irq(adapter);
-	return err;
+	return e1000_request_irq(adapter);
 }
 
 /**
@@ -3432,21 +3426,6 @@ static int e1000_test_msi(struct e1000_a
 		pci_write_config_word(adapter->pdev, PCI_COMMAND, pci_cmd);
 	}
 
-	/* success ! */
-	if (!err)
-		return 0;
-
-	/* EIO means MSI test failed */
-	if (err != -EIO)
-		return err;
-
-	/* back to INTx mode */
-	e_warn("MSI interrupt test failed, using legacy interrupt.\n");
-
-	e1000_free_irq(adapter);
-
-	err = e1000_request_irq(adapter);
-
 	return err;
 }
 

-- 
Jean Delvare
Suse L3
