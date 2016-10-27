From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net] enic: fix rq disable
Date: Thu, 27 Oct 2016 16:01:03 -0700
Message-ID: <20161027230103.35242-1-gvaradar@cisco.com>
Cc: Govindarajulu Varadarajan <gvaradar@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-2.cisco.com ([173.37.142.89]:23319 "EHLO
        alln-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933978AbcJ0XKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 19:10:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When MTU is changed from 9000 to 1500 while there is burst of inbound 9000
bytes packets, adaptor sometimes delivers 9000 bytes packets to 1500 bytes
buffers. This causes memory corruption and sometimes crash.

This is because of a race condition in adaptor between "RQ disable"
clearing descriptor mini-cache and mini-cache valid bit being set by
completion of descriptor fetch. This can result in stale RQ desc being
cached and used when packets arrive. In this case, the stale descriptor
have old MTU value.

Solution is to write RQ->disable twice. The first write will stop any
further desc fetches, allowing the second disable to clear the mini-cache
valid bit without danger of a race.

Also, the check for rq->running becoming 0 after writing rq->enable to 0
is not done properly. When incoming packets are flooding the interface,
rq->running will pulse high for each dropped packet. Since the driver was
waiting for 10us between each poll, it is possible to see rq->running = 1
1000 times in a row, even though it is not actually stuck running.
This results in false failure of vnic_rq_disable(). Fix is to try more
than 1000 time without delay between polls to ensure we do not miss when
running goes low.

In old adaptors rq->enable needs to be re-written to 0 when posted_index
is reset in vnic_rq_clean() in order to keep rq->prefetch_index in sync.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_rq.c | 32 ++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index e572a52..36bc2c7 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -169,19 +169,28 @@ int vnic_rq_disable(struct vnic_rq *rq)
 {
 	unsigned int wait;
 	struct vnic_dev *vdev = rq->vdev;
+	int i;
 
-	iowrite32(0, &rq->ctrl->enable);
+	/* Due to a race condition with clearing RQ "mini-cache" in hw, we need
+	 * to disable the RQ twice to guarantee that stale descriptors are not
+	 * used when this RQ is re-enabled.
+	 */
+	for (i = 0; i < 2; i++) {
+		iowrite32(0, &rq->ctrl->enable);
 
-	/* Wait for HW to ACK disable request */
-	for (wait = 0; wait < 1000; wait++) {
-		if (!(ioread32(&rq->ctrl->running)))
-			return 0;
-		udelay(10);
-	}
+		/* Wait for HW to ACK disable request */
+		for (wait = 20000; wait > 0; wait--)
+			if (!ioread32(&rq->ctrl->running))
+				break;
+		if (!wait) {
+			vdev_neterr(vdev, "Failed to disable RQ[%d]\n",
+				    rq->index);
 
-	vdev_neterr(vdev, "Failed to disable RQ[%d]\n", rq->index);
+			return -ETIMEDOUT;
+		}
+	}
 
-	return -ETIMEDOUT;
+	return 0;
 }
 
 void vnic_rq_clean(struct vnic_rq *rq,
@@ -212,6 +221,11 @@ void vnic_rq_clean(struct vnic_rq *rq,
 			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES(count)];
 	iowrite32(fetch_index, &rq->ctrl->posted_index);
 
+	/* Anytime we write fetch_index, we need to re-write 0 to rq->enable
+	 * to re-sync internal VIC state.
+	 */
+	iowrite32(0, &rq->ctrl->enable);
+
 	vnic_dev_clear_desc_ring(&rq->ring);
 }
 
-- 
2.10.1
