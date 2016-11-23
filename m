From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/11] rocker: Create an ordered workqueue for FIB offload
Date: Wed, 23 Nov 2016 15:34:26 +0100
Message-ID: <1479911670-4525-6-git-send-email-jiri@resnulli.us>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34278 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938295AbcKWOej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:39 -0500
Received: by mail-wj0-f193.google.com with SMTP id xy5so1189347wjc.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:38 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As explained in the previous patches, we need to process FIB entries
addition / deletion events in FIFO order or otherwise we can have a
mismatch between the kernel's FIB table and the device's.

Create an ordered workqueue for rocker to which these work items will be
submitted to.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h      |  1 +
 drivers/net/ethernet/rocker/rocker_main.c | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 2eb9b49..ee9675d 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -72,6 +72,7 @@ struct rocker {
 	struct rocker_dma_ring_info event_ring;
 	struct notifier_block fib_nb;
 	struct rocker_world_ops *wops;
+	struct workqueue_struct *rocker_owq;
 	void *wpriv;
 };
 
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 67df4cf..424be96 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -28,6 +28,7 @@
 #include <linux/if_bridge.h>
 #include <linux/bitops.h>
 #include <linux/ctype.h>
+#include <linux/workqueue.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
 #include <net/netevent.h>
@@ -2754,6 +2755,13 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_request_event_irq;
 	}
 
+	rocker->rocker_owq = alloc_ordered_workqueue(rocker_driver_name,
+						     WQ_MEM_RECLAIM);
+	if (!rocker->rocker_owq) {
+		err = -ENOMEM;
+		goto err_alloc_ordered_workqueue;
+	}
+
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
 	err = rocker_probe_ports(rocker);
@@ -2771,6 +2779,8 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_probe_ports:
+	destroy_workqueue(rocker->rocker_owq);
+err_alloc_ordered_workqueue:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 err_request_event_irq:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
@@ -2799,6 +2809,7 @@ static void rocker_remove(struct pci_dev *pdev)
 	unregister_fib_notifier(&rocker->fib_nb);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
+	destroy_workqueue(rocker->rocker_owq);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
 	rocker_dma_rings_fini(rocker);
-- 
2.7.4
