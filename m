From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000: fix lockdep splat in shutdown handler
Date: Wed,  4 Jan 2012 22:23:33 -0800
Message-ID: <1325744620-5067-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21235 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab2AEGXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 01:23:44 -0500
In-Reply-To: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As reported by Steven Rostedt, e1000 has a lockdep splat added
during the recent merge window.  The issue is that
cancel_delayed_work is called while holding our private mutex.

There is no reason that I can see to hold the mutex during pci
shutdown, it was more just paranoia that I put the mutex_lock
around the call to e1000_down.

In a quick survey lots of drivers handle locking differently when
being called by the pci layer.  The assumption here is that we
don't need the mutexes' protection in this function because
the driver could not be unloaded while in the shutdown handler
which is only called at reboot or poweroff.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Steven Rostedt <rostedt@goodmis.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 985d589..934d5aa 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4724,8 +4724,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	netif_device_detach(netdev);
 
-	mutex_lock(&adapter->mutex);
-
 	if (netif_running(netdev)) {
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
@@ -4733,10 +4731,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
-	if (retval) {
-		mutex_unlock(&adapter->mutex);
+	if (retval)
 		return retval;
-	}
 #endif
 
 	status = er32(STATUS);
@@ -4791,8 +4787,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
 
-	mutex_unlock(&adapter->mutex);
-
 	pci_disable_device(pdev);
 
 	return 0;
-- 
1.7.7.5
