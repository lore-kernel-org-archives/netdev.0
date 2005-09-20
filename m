From: Pavel Machek <pavel@ucw.cz>
Subject: [patch] fix suspend/resume on b44
Date: Tue, 20 Sep 2005 15:28:11 +0200
Message-ID: <20050920132811.GA4563@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev list <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix suspend/resume on b44 by freeing/reacquiring irq. Otherwise it
hangs on resume.

Signed-off-by: Pavel Machek <pavel@suse.cz>

---
commit 7bdc8fc378f053bd4eb4210beb1d494485318512
tree 6e5679697b11eb70b73ff5275aafe7c34a90ffef
parent 17cd36a6d0fc36b61fa558cade6a98a3e99a6992
author <pavel@amd.(none)> Tue, 20 Sep 2005 15:26:37 +0200
committer <pavel@amd.(none)> Tue, 20 Sep 2005 15:26:37 +0200

 drivers/net/b44.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1930,6 +1930,8 @@ static int b44_suspend(struct pci_dev *p
 	b44_free_rings(bp);
 
 	spin_unlock_irq(&bp->lock);
+
+	free_irq(dev->irq, dev);
 	pci_disable_device(pdev);
 	return 0;
 }
@@ -1946,6 +1948,9 @@ static int b44_resume(struct pci_dev *pd
 	if (!netif_running(dev))
 		return 0;
 
+	if (request_irq(dev->irq, b44_interrupt, SA_SHIRQ, dev->name, dev))
+		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
+
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);

-- 
if you have sharp zaurus hardware you don't need... you know my address
