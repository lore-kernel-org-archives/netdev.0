From: Eli Cohen <eli@mellanox.co.il>
Subject: [PATCHv6 04/10] IB/umad: Enable support only for IB ports
Date: Mon, 16 Nov 2009 17:53:36 +0200
Message-ID: <20091116155336.GE2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, ewg <ewg@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51566 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753234AbZKPPwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 10:52:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize umad context for devices that have any of their ports IB. Since
devices may have ports of two different protocols (for example,
RDMA_TRANSPORT_IB and RDMA_TRANSPORT_RDMAOE), ib_umad_add_one() needs to
succeed if any of the ports is IB but ib_umad_init_port() is called only for IB
ports.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/infiniband/core/user_mad.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 6d6795d..d069689 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1124,10 +1124,6 @@ static void ib_umad_add_one(struct ib_device *device)
 		e = device->phys_port_cnt;
 	}
 
-	for (i = s; i <= e; ++i)
-		if (rdma_port_get_transport(device, i) != RDMA_TRANSPORT_IB)
-			return;
-
 	umad_dev = kzalloc(sizeof *umad_dev +
 			   (e - s + 1) * sizeof (struct ib_umad_port),
 			   GFP_KERNEL);
@@ -1142,8 +1138,9 @@ static void ib_umad_add_one(struct ib_device *device)
 	for (i = s; i <= e; ++i) {
 		umad_dev->port[i - s].umad_dev = umad_dev;
 
-		if (ib_umad_init_port(device, i, &umad_dev->port[i - s]))
-			goto err;
+		if (rdma_port_get_transport(device, i) == RDMA_TRANSPORT_IB)
+			if (ib_umad_init_port(device, i, &umad_dev->port[i - s]))
+				goto err;
 	}
 
 	ib_set_client_data(device, &umad_client, umad_dev);
@@ -1152,7 +1149,8 @@ static void ib_umad_add_one(struct ib_device *device)
 
 err:
 	while (--i >= s)
-		ib_umad_kill_port(&umad_dev->port[i - s]);
+		if (rdma_port_get_transport(device, i) == RDMA_TRANSPORT_IB)
+			ib_umad_kill_port(&umad_dev->port[i - s]);
 
 	kref_put(&umad_dev->ref, ib_umad_release_dev);
 }
@@ -1166,7 +1164,8 @@ static void ib_umad_remove_one(struct ib_device *device)
 		return;
 
 	for (i = 0; i <= umad_dev->end_port - umad_dev->start_port; ++i)
-		ib_umad_kill_port(&umad_dev->port[i]);
+		if (rdma_port_get_transport(device, i + 1) == RDMA_TRANSPORT_IB)
+			ib_umad_kill_port(&umad_dev->port[i]);
 
 	kref_put(&umad_dev->ref, ib_umad_release_dev);
 }
-- 
1.6.5.2

