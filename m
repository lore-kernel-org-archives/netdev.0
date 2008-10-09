From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix early spinlock use
Date: Thu, 9 Oct 2008 23:35:13 +0200
Message-ID: <20081009213513.GB19429@electric-eye.fr.zoreil.com>
References: <20081008.154131.141753610.davem@davemloft.net> <20081009201607.GA20030@electric-eye.fr.zoreil.com> <20081009.142807.229045310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50397 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755594AbYJIVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:35:36 -0400
Content-Disposition: inline
In-Reply-To: <20081009.142807.229045310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8169_init_one
-> rtl_init_mac_address
   -> rtl_rar_set
      -> spin_lock_irq(&tp->lock);
[...]
-> spin_lock_init(&tp->lock);

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 108aaff..59fbc64 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1952,7 +1952,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->do_ioctl = rtl8169_ioctl;
 	}
 
-	/* Read MAC address from EEPROM */
+	spin_lock_init(&tp->lock);
+
 	rtl_init_mac_address(tp, ioaddr);
 
 	/* Get MAC address */
@@ -1995,8 +1996,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
-	spin_lock_init(&tp->lock);
-
 	rc = register_netdev(dev);
 	if (rc < 0)
 		goto err_out_msi_5;
-- 
1.5.3.3

