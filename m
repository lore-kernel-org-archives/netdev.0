From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] ixgbe: Initialize q_vector cpu and affinity masks correctly
Date: Fri, 19 Oct 2012 04:45:01 -0700
Message-ID: <1350647114-6768-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758628Ab2JSLpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:42 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When enabling DCB the rings belonging to a q_vector on CPU 0 were not
reinitializing their DCA registers.  Upon closer inspection the issue was
that the q_vector CPU variable was left at 0 resulting in the driver not
updating the DCA registers.

In order to guarantee the DCA registers will be updated I am adding a
couple line change so that we initialize the CPU variable to -1 which will
force a DCA update the first time an interrupt fires on that q_vector.

In addition we were setting the CPU affinity hint to all CPUs when we were
not specifying a CPU.  Instead we should leave it as all zeros to avoid any
possible confusion about the fact that we shouldn't be giving a hint.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 17ecbce..5e508b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -802,10 +802,13 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	/* setup affinity mask and node */
 	if (cpu != -1)
 		cpumask_set_cpu(cpu, &q_vector->affinity_mask);
-	else
-		cpumask_copy(&q_vector->affinity_mask, cpu_online_mask);
 	q_vector->numa_node = node;
 
+#ifdef CONFIG_IXGBE_DCA
+	/* initialize CPU for DCA */
+	q_vector->cpu = -1;
+
+#endif
 	/* initialize NAPI */
 	netif_napi_add(adapter->netdev, &q_vector->napi,
 		       ixgbe_poll, 64);
-- 
1.7.11.7
