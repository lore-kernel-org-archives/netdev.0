From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH] drivers/net: enic: release rtnl_lock on error-path
Date: Mon, 08 Jul 2013 11:22:51 +0400
Message-ID: <20130708072251.20540.50413.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

enic_change_mtu_work() must call rtnl_unlock() on all exiting paths.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Roopa Prabhu <roprabhu@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
Cc: Nishank Trivedi <nistrive@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 635f559..992ec2e 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1761,6 +1761,7 @@ static void enic_change_mtu_work(struct work_struct *work)
 	enic_synchronize_irqs(enic);
 	err = vnic_rq_disable(&enic->rq[0]);
 	if (err) {
+		rtnl_unlock();
 		netdev_err(netdev, "Unable to disable RQ.\n");
 		return;
 	}
@@ -1773,6 +1774,7 @@ static void enic_change_mtu_work(struct work_struct *work)
 	vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
 	/* Need at least one buffer on ring to get going */
 	if (vnic_rq_desc_used(&enic->rq[0]) == 0) {
+		rtnl_unlock();
 		netdev_err(netdev, "Unable to alloc receive buffers.\n");
 		return;
 	}
