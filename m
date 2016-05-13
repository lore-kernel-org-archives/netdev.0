From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH] ixgbe: take online CPU number as MQ max limit when  alloc_etherdev_mq()
Date: Fri, 13 May 2016 14:56:35 +0900
Message-ID: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
Cc: linux-kernel@vger.kernel.org, ethan.kernel@gmail.com,
	ethan.zhao@oracle.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocating 64 Tx/Rx as default doesn't benefit perfomrnace when less
CPUs were assigned. especially when DCB is enabled, so we should take
num_online_cpus() as top limit, and aslo to make sure every TC has
at least one queue, take the MAX_TRAFFIC_CLASS as bottom limit of queues
number.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7df3fe2..1f9769c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9105,6 +9105,10 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		indices = IXGBE_MAX_RSS_INDICES;
 #endif
 	}
+	/* Don't allocate too more queues than online cpus number */
+	indices = min_t(int, indices, num_online_cpus());
+	/* To make sure TC works, allocate at least 1 queue per TC */
+	indices = max_t(int, indices, MAX_TRAFFIC_CLASS);
 
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indices);
 	if (!netdev) {
-- 
1.8.3.1
