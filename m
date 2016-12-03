From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 07/10] rocker: Register FIB notifier before creating ports
Date: Sat,  3 Dec 2016 16:45:04 +0100
Message-ID: <1480779907-32535-8-git-send-email-jiri@resnulli.us>
References: <1480779907-32535-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34869 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbcLCPpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 10:45:18 -0500
Received: by mail-wj0-f196.google.com with SMTP id he10so19506687wjc.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 07:45:18 -0800 (PST)
In-Reply-To: <1480779907-32535-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We can miss FIB notifications sent between the time the ports were
created and the FIB notification block registered.

Instead of receiving these notifications only when they are replayed for
the FIB notification block during registration, just register the
notification block before the ports are created.

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
