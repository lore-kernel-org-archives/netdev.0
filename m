From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH] Remove atomic context inside vortex_{set|get}_wol
Date: Tue, 14 Sep 2010 20:35:23 +0000
Message-ID: <20100914203209.GA22498@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@beldisplaytech.com, ben@decadent.org.uk,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:52963 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751931Ab0INUfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 16:35:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to use spinlocks in vortex_{set|get}_wol.
This also fixes a bug:
[  254.214993] 3c59x 0000:00:0d.0: PME# enabled
[  254.215021] BUG: sleeping function called from invalid context at kernel/mutex.c:94
[  254.215030] in_atomic(): 0, irqs_disabled(): 1, pid: 4875, name: ethtool
[  254.215042] Pid: 4875, comm: ethtool Tainted: G        W   2.6.36-rc3+ #7
[  254.215049] Call Trace:
[  254.215050]  [] __might_sleep+0xb1/0xb6
[  254.215050]  [] mutex_lock+0x17/0x30
[  254.215050]  [] acpi_enable_wakeup_device_power+0x2b/0xb1
[  254.215050]  [] acpi_pm_device_sleep_wake+0x42/0x7f
[  254.215050]  [] acpi_pci_sleep_wake+0x5d/0x63
[  254.215050]  [] platform_pci_sleep_wake+0x1d/0x20
[  254.215050]  [] __pci_enable_wake+0x90/0xd0
[  254.215050]  [] acpi_set_WOL+0x8e/0xf5 [3c59x]
[  254.215050]  [] vortex_set_wol+0x4e/0x5e [3c59x]
[  254.215050]  [] dev_ethtool+0x1cf/0xb61
[  254.215050]  [] ? debug_mutex_free_waiter+0x45/0x4a
[  254.215050]  [] ? __mutex_lock_common+0x204/0x20e
[  254.215050]  [] ? __mutex_lock_slowpath+0x12/0x15
[  254.215050]  [] ? mutex_lock+0x23/0x30
[  254.215050]  [] dev_ioctl+0x42c/0x533
[  254.215050]  [] ? _cond_resched+0x8/0x1c
[  254.215050]  [] ? lock_page+0x1c/0x30
[  254.215050]  [] ? page_address+0x15/0x7c
[  254.215050]  [] ? filemap_fault+0x187/0x2c4
[  254.215050]  [] sock_ioctl+0x1d4/0x1e0
[  254.215050]  [] ? sock_ioctl+0x0/0x1e0
[  254.215050]  [] vfs_ioctl+0x19/0x33
[  254.215050]  [] do_vfs_ioctl+0x424/0x46f
[  254.215050]  [] ? selinux_file_ioctl+0x3c/0x40
[  254.215050]  [] sys_ioctl+0x40/0x5a
[  254.215050]  [] sysenter_do_call+0x12/0x22

vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL acquires a mutex inside atomic context.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/3c59x.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 7a01588..da6df86 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2922,13 +2922,11 @@ static void vortex_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 
-	spin_lock_irq(&vp->lock);
 	wol->supported = WAKE_MAGIC;
 
 	wol->wolopts = 0;
 	if (vp->enable_wol)
 		wol->wolopts |= WAKE_MAGIC;
-	spin_unlock_irq(&vp->lock);
 }
 
 static int vortex_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -2937,13 +2935,11 @@ static int vortex_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 
-	spin_lock_irq(&vp->lock);
 	if (wol->wolopts & WAKE_MAGIC)
 		vp->enable_wol = 1;
 	else
 		vp->enable_wol = 0;
 	acpi_set_WOL(dev);
-	spin_unlock_irq(&vp->lock);
 
 	return 0;
 }
-- 
1.6.4.4

