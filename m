From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/6] ixgbe: reinit_locked() should be called with rtnl_lock
Date: Thu, 16 Jan 2014 02:30:05 -0800
Message-ID: <1389868210-24035-2-git-send-email-aaron.f.brown@intel.com>
References: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34053 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379AbaAPKaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:35 -0500
In-Reply-To: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

ixgbe_service_task() is calling ixgbe_reinit_locked() without
the rtnl_lock being held. This is because it is being called
from a worker thread and not a rtnl netlink or dcbnl path.

Add rtnl_{un}lock() semantics. I found this during code review.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3ca59d2..b445ad1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6392,7 +6392,9 @@ static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
 	netdev_err(adapter->netdev, "Reset adapter\n");
 	adapter->tx_timeout_count++;
 
+	rtnl_lock();
 	ixgbe_reinit_locked(adapter);
+	rtnl_unlock();
 }
 
 /**
-- 
1.8.5.GIT
