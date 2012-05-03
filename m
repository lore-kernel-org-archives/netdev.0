From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH 4/4] ixgbe: Fix use after free on module remove
Date: Thu, 03 May 2012 00:19:14 -0700
Message-ID: <20120503071914.13636.31157.stgit@gitlad.jf.intel.com>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7905 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020Ab2ECHTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 03:19:01 -0400
In-Reply-To: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing the TCP changes I had to fix an issue in order to be able to
load and unload the module.

The recent patch that added thermal sensor support added a use after free
bug on module unload with an 82598 adapter in the system.  To resolve the
issue I have updated the code so that when we free the info_kobj we set it
back to NULL.

I suspect there are likely other bugs present, but I will leave that for
another patch that can undergo more testing.

I am submitting this directly to net-next since this fixes a fairly serious
bug that will lock up the ixgbe module until the system is rebooted.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index aa41fb7..f81c166 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -185,8 +185,10 @@ static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
 #endif /* CONFIG_IXGBE_HWMON */
 
-	if (adapter->info_kobj != NULL)
+	if (adapter->info_kobj != NULL) {
 		kobject_put(adapter->info_kobj);
+		adapter->info_kobj = NULL;
+	}
 }
 
 /* called from ixgbe_main.c */
