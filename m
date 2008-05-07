From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/2 2.6.26] cxgb3 - fix port up/down error path
Date: Tue, 06 May 2008 19:25:56 -0700
Message-ID: <20080507022556.3136.47044.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28306 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbYEGCjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 22:39:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Fix faiures path when ports are stopped and restarted
in EEH recovery.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    1 +
 drivers/net/cxgb3/cxgb3_main.c |   32 +++++++++++++++++---------------
 2 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 4fdb13f..acebe43 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -71,6 +71,7 @@ enum {				/* adapter flags */
 	USING_MSIX = (1 << 2),
 	QUEUES_BOUND = (1 << 3),
 	TP_PARITY_INIT = (1 << 4),
+	NAPI_INIT = (1 << 5),
 };
 
 struct fl_pg_chunk {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 05e5f59..7354d6a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -421,6 +421,13 @@ static void init_napi(struct adapter *adap)
 			netif_napi_add(qs->netdev, &qs->napi, qs->napi.poll,
 				       64);
 	}
+
+	/*
+	 * netif_napi_add() can be called only once per napi_struct because it
+	 * adds each new napi_struct to a list.  Be careful not to call it a
+	 * second time, e.g., during EEH recovery, by making a note of it.
+	 */
+	adap->flags |= NAPI_INIT;
 }
 
 /*
@@ -896,7 +903,8 @@ static int cxgb_up(struct adapter *adap)
 			goto out;
 
 		setup_rss(adap);
-		init_napi(adap);
+		if (!(adap->flags & NAPI_INIT))
+			init_napi(adap);
 		adap->flags |= FULL_INIT_DONE;
 	}
 
@@ -999,7 +1007,7 @@ static int offload_open(struct net_device *dev)
 		return 0;
 
 	if (!adap_up && (err = cxgb_up(adapter)) < 0)
-		return err;
+		goto out;
 
 	t3_tp_set_offload_mode(adapter, 1);
 	tdev->lldev = adapter->port[0];
@@ -1061,10 +1069,8 @@ static int cxgb_open(struct net_device *dev)
 	int other_ports = adapter->open_device_map & PORT_MASK;
 	int err;
 
-	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0) {
-		quiesce_rx(adapter);
+	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
 		return err;
-	}
 
 	set_bit(pi->port_id, &adapter->open_device_map);
 	if (is_offload(adapter) && !ofld_disable) {
@@ -2431,7 +2437,7 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 
 	pci_disable_device(pdev);
 
-	/* Request a slot slot reset. */
+	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
@@ -2448,13 +2454,16 @@ static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
-		return PCI_ERS_RESULT_DISCONNECT;
+		goto err;
 	}
 	pci_set_master(pdev);
 
-	t3_prep_adapter(adapter, adapter->params.info, 1);
+	if (t3_prep_adapter(adapter, adapter->params.info, 1))
+		goto err;
 
 	return PCI_ERS_RESULT_RECOVERED;
+err:
+	return PCI_ERS_RESULT_DISCONNECT;
 }
 
 /**
@@ -2483,13 +2492,6 @@ static void t3_io_resume(struct pci_dev *pdev)
 			netif_device_attach(netdev);
 		}
 	}
-
-	if (is_offload(adapter)) {
-		__set_bit(OFFLOAD_DEVMAP_BIT, &adapter->registered_device_map);
-		if (offload_open(adapter->port[0]))
-			printk(KERN_WARNING
-			       "Could not bring back offload capabilities\n");
-	}
 }
 
 static struct pci_error_handlers t3_err_handler = {
