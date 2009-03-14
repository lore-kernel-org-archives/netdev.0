From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 05/11] ixgbe: fix bug with napi add before request_irq
Date: Sat, 14 Mar 2009 01:13:49 -0700
Message-ID: <20090314081349.4687.65356.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:37979
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511AbZCNIT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:19:59 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Occasionally if the driver was loaded in a system that
didn't support MSI-X or MSI and was on a shared interrupt,
the driver would then panic in NAPI on the first shared
interrupt because we hadn't called napi_add yet.

Solution: call napi_add before calling request_irq

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 78cc517..4a2a769 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2339,8 +2339,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	else
 		ixgbe_configure_msi_and_legacy(adapter);
 
-	ixgbe_napi_add_all(adapter);
-
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
@@ -2397,6 +2395,8 @@ int ixgbe_up(struct ixgbe_adapter *adapter)
 	/* hardware has been reset, we need to reload some things */
 	ixgbe_configure(adapter);
 
+	ixgbe_napi_add_all(adapter);
+
 	return ixgbe_up_complete(adapter);
 }
 
@@ -3426,6 +3426,8 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_configure(adapter);
 
+	ixgbe_napi_add_all(adapter);
+
 	err = ixgbe_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -3480,6 +3482,7 @@ static int ixgbe_close(struct net_device *netdev)
 /**
  * ixgbe_napi_add_all - prep napi structs for use
  * @adapter: private struct
+ *
  * helper function to napi_add each possible q_vector->napi
  */
 void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
@@ -3552,7 +3555,6 @@ static int ixgbe_resume(struct pci_dev *pdev)
 		return err;
 	}
 
-	ixgbe_napi_add_all(adapter);
 	ixgbe_reset(adapter);
 
 	if (netif_running(netdev)) {

