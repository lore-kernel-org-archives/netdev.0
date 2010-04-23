From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH] e100: Fix the TX workqueue race
Date: Fri, 23 Apr 2010 15:34:43 +0100
Message-ID: <20100423143356.7092.45260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:34460 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753473Ab0DWPJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 11:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd assumed someone would have picked up on this and fixed it using rtnl_lock
as was suggested but it seems to have fallen through the cracks ?

Anyway this is I assume what was meant ?

---

Nothing stops the workqueue being left to run in parallel with close or a
few other operations. This causes double unmaps and the like.

See kerneloops.org #1041230 for an example

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/e100.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)


diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3e8d000..859e833 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2280,8 +2280,13 @@ static void e100_tx_timeout_task(struct work_struct *work)
 
 	netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
 		     "scb.status=0x%02X\n", ioread8(&nic->csr->scb.status));
-	e100_down(netdev_priv(netdev));
-	e100_up(netdev_priv(netdev));
+
+	rtnl_lock();
+	if (netif_running(dev)) {
+		e100_down(netdev_priv(netdev));
+		e100_up(netdev_priv(netdev));
+	}
+	rtnl_unlock();
 }
 
 static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)

