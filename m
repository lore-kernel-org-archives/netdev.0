From: Eli Cohen <eli@mellanox.co.il>
Subject: [PATCHv6 05/10] ib/cm: Enable CM support for RDMAoE
Date: Mon, 16 Nov 2009 17:53:43 +0200
Message-ID: <20091116155343.GF2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, ewg <ewg@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51577 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753230AbZKPPwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 10:52:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CM messages can be transported on RDMAoE protocol ports so they are enabled
here.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/infiniband/core/cm.c  |    5 +++--
 drivers/infiniband/core/ucm.c |   12 +++++++++---
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index d082f59..c9f9122 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3680,7 +3680,8 @@ static void cm_add_one(struct ib_device *ib_device)
 	u8 i;
 	enum rdma_transport_type tt;
 
-	if (!rdma_is_transport_supported(ib_device, RDMA_TRANSPORT_IB))
+	if (!rdma_is_transport_supported(ib_device, RDMA_TRANSPORT_IB) &&
+	    !rdma_is_transport_supported(ib_device, RDMA_TRANSPORT_RDMAOE))
 		return;
 
 	cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
@@ -3702,7 +3703,7 @@ static void cm_add_one(struct ib_device *ib_device)
 	set_bit(IB_MGMT_METHOD_SEND, reg_req.method_mask);
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
 		tt = rdma_port_get_transport(ib_device, i);
-		if (tt != RDMA_TRANSPORT_IB)
+		if (tt != RDMA_TRANSPORT_IB && tt != RDMA_TRANSPORT_RDMAOE)
 			continue;
 
 		port = kzalloc(sizeof *port, GFP_KERNEL);
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index 43700b4..dce2cbb 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -1241,13 +1241,19 @@ static void ib_ucm_add_one(struct ib_device *device)
 {
 	struct ib_ucm_device *ucm_dev;
 	int i;
+	enum rdma_transport_type tt;
 
 	if (!device->alloc_ucontext)
 		return;
 
-	for (i = 1; i <= device->phys_port_cnt; ++i)
-		if (rdma_port_get_transport(device, i) != RDMA_TRANSPORT_IB)
-			return;
+	for (i = 1; i <= device->phys_port_cnt; ++i) {
+		tt = rdma_port_get_transport(device, i);
+		if (tt == RDMA_TRANSPORT_IB || tt == RDMA_TRANSPORT_RDMAOE)
+			break;
+	}
+
+	if (i > device->phys_port_cnt)
+		return;
 
 	ucm_dev = kzalloc(sizeof *ucm_dev, GFP_KERNEL);
 	if (!ucm_dev)
-- 
1.6.5.2

