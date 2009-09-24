From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Thu, 24 Sep 2009 22:31:52 +0400
Message-ID: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:56912 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751253AbZIXSbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 14:31:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following trace pops up if we try to suspend with 3c59x ethernet NIC
brought down:

  root@b1:~# ifconfig eth16 down
  root@b1:~# echo mem > /sys/power/state
  ...
  3c59x 0000:00:10.0: suspend
  3c59x 0000:00:10.0: PME# disabled
  Trying to free already-free IRQ 48
  ------------[ cut here ]------------
  Badness at c00554e4 [verbose debug info unavailable]
  NIP: c00554e4 LR: c00554e4 CTR: c019a098
  REGS: c7975c60 TRAP: 0700   Not tainted  (2.6.31-rc4)
  MSR: 00021032 <ME,CE,IR,DR>  CR: 28242422  XER: 20000000
  TASK = c79cb0c0[1746] 'bash' THREAD: c7974000
  ...
  NIP [c00554e4] __free_irq+0x108/0x1b0
  LR [c00554e4] __free_irq+0x108/0x1b0
  Call Trace:
  [c7975d10] [c00554e4] __free_irq+0x108/0x1b0 (unreliable)
  [c7975d30] [c005559c] free_irq+0x10/0x24
  [c7975d40] [c01e21ec] vortex_suspend+0x70/0xc4
  [c7975d60] [c017e584] pci_legacy_suspend+0x58/0x100

This is because the driver manages interrupts without checking for
netif_running().

Though, there are few other issues with suspend/resume in this driver.
The intention of calling free_irq() in suspend() was to avoid any
possible spurious interrupts (see commit 5b039e681b8c5f30aac9cc04385
"3c59x PM fixes"). But,

- On resume, the driver was requesting IRQ just after pci_set_master(),
  but before vortex_up() (which actually resets 3c59x chips).

- Issuing free_irq() on a shared IRQ doesn't guarantee that a buggy
  HW won't trigger spurious interrupts in another driver that
  requested the same interrupt. So, if we want to protect from
  unexpected interrupts, then on suspend we should issue disable_irq(),
  not free_irq().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/3c59x.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c34aee9..7cdd4b0 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -807,10 +807,10 @@ static int vortex_suspend(struct pci_dev *pdev, pm_message_t state)
 		if (netif_running(dev)) {
 			netif_device_detach(dev);
 			vortex_down(dev, 1);
+			disable_irq(dev->irq);
 		}
 		pci_save_state(pdev);
 		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
-		free_irq(dev->irq, dev);
 		pci_disable_device(pdev);
 		pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	}
@@ -833,18 +833,12 @@ static int vortex_resume(struct pci_dev *pdev)
 			return err;
 		}
 		pci_set_master(pdev);
-		if (request_irq(dev->irq, vp->full_bus_master_rx ?
-				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev)) {
-			pr_warning("%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
-			pci_disable_device(pdev);
-			return -EBUSY;
-		}
 		if (netif_running(dev)) {
 			err = vortex_up(dev);
 			if (err)
 				return err;
-			else
-				netif_device_attach(dev);
+			enable_irq(dev->irq);
+			netif_device_attach(dev);
 		}
 	}
 	return 0;
-- 
1.6.3.3
