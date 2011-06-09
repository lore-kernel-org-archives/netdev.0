From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 3/4] enic: Get/Set interrupt resource index for
	transmit and receive queues
Date: Thu, 09 Jun 2011 13:37:02 -0700
Message-ID: <20110609203702.31838.67304.stgit@savbu-pc100.cisco.com>
References: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:51759 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1FIUhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:37:03 -0400
In-Reply-To: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Instead of deriving the index of a transmit/receive interrupt resource
from the transmit/receive queue index, always save and retrieve it
using an additional variable.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    4 ++--
 drivers/net/enic/vnic_cq.c   |    2 ++
 drivers/net/enic/vnic_cq.h   |    1 +
 4 files changed, 6 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 23e2103..2dcf310 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.17"
+#define DRV_VERSION		"2.1.1.19"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index e990988..eee2526 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -153,12 +153,12 @@ static inline unsigned int enic_legacy_notify_intr(void)
 
 static inline unsigned int enic_msix_rq_intr(struct enic *enic, unsigned int rq)
 {
-	return rq;
+	return enic->cq[enic_cq_rq(enic, rq)].interrupt_offset;
 }
 
 static inline unsigned int enic_msix_wq_intr(struct enic *enic, unsigned int wq)
 {
-	return enic->rq_count + wq;
+	return enic->cq[enic_cq_wq(enic, wq)].interrupt_offset;
 }
 
 static inline unsigned int enic_msix_err_intr(struct enic *enic)
diff --git a/drivers/net/enic/vnic_cq.c b/drivers/net/enic/vnic_cq.c
index b86d6ef..0daa1c7 100644
--- a/drivers/net/enic/vnic_cq.c
+++ b/drivers/net/enic/vnic_cq.c
@@ -74,6 +74,8 @@ void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
 	iowrite32(cq_message_enable, &cq->ctrl->cq_message_enable);
 	iowrite32(interrupt_offset, &cq->ctrl->interrupt_offset);
 	writeq(cq_message_addr, &cq->ctrl->cq_message_addr);
+
+	cq->interrupt_offset = interrupt_offset;
 }
 
 void vnic_cq_clean(struct vnic_cq *cq)
diff --git a/drivers/net/enic/vnic_cq.h b/drivers/net/enic/vnic_cq.h
index 552d3da..579315c 100644
--- a/drivers/net/enic/vnic_cq.h
+++ b/drivers/net/enic/vnic_cq.h
@@ -57,6 +57,7 @@ struct vnic_cq {
 	struct vnic_dev_ring ring;
 	unsigned int to_clean;
 	unsigned int last_color;
+	unsigned int interrupt_offset;
 };
 
 static inline unsigned int vnic_cq_service(struct vnic_cq *cq,

