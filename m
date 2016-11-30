From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 12/12] rocker: Register FIB notifier before creating ports
Date: Wed, 30 Nov 2016 11:09:06 +0100
Message-ID: <1480500546-2544-13-git-send-email-jiri@resnulli.us>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34488 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933172AbcK3KJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:23 -0500
Received: by mail-wj0-f193.google.com with SMTP id xy5so21506959wjc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:23 -0800 (PST)
In-Reply-To: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Unlike mlxsw, rocker only supports the reflection of routes pointing to
its own netdevs. Therefore, instead of requesting a FIB dump during
init, simply register the FIB notifier before creating the ports.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 914e9e1..8c9c90a 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2804,6 +2804,9 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_alloc_ordered_workqueue;
 	}
 
+	rocker->fib_nb.notifier_call = rocker_router_fib_event;
+	register_fib_notifier(&rocker->fib_nb);
+
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
 	err = rocker_probe_ports(rocker);
@@ -2812,15 +2815,13 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_probe_ports;
 	}
 
-	rocker->fib_nb.notifier_call = rocker_router_fib_event;
-	register_fib_notifier(&rocker->fib_nb);
-
 	dev_info(&pdev->dev, "Rocker switch with id %*phN\n",
 		 (int)sizeof(rocker->hw.id), &rocker->hw.id);
 
 	return 0;
 
 err_probe_ports:
+	unregister_fib_notifier(&rocker->fib_nb);
 	destroy_workqueue(rocker->rocker_owq);
 err_alloc_ordered_workqueue:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
@@ -2848,9 +2849,9 @@ static void rocker_remove(struct pci_dev *pdev)
 {
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
+	rocker_remove_ports(rocker);
 	unregister_fib_notifier(&rocker->fib_nb);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
-	rocker_remove_ports(rocker);
 	destroy_workqueue(rocker->rocker_owq);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
-- 
2.7.4
