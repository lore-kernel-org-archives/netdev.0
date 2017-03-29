From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 1/7] NFC: fix broken device allocation
Date: Wed, 29 Mar 2017 18:21:06 +0200
Message-ID: <20170329162112.18121-2-johan@kernel.org>
References: <20170329162112.18121-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33264 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753144AbdC2QV4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:21:56 -0400
In-Reply-To: <20170329162112.18121-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7eda8b8e9677 ("NFC: Use IDR library to assing NFC devices IDs")
moved device-id allocation and struct-device initialisation from
nfc_allocate_device() to nfc_register_device().

This broke just about every nfc-device-registration error path, which
continue to call nfc_free_device() that tries to put the device
reference of the now uninitialised (but zeroed) struct device:

kobject: '(null)' (ce316420): is not initialized, yet kobject_put() is being called.

The late struct-device initialisation also meant that various work
queues whose names are derived from the nfc device name were also
misnamed:

  421 root         0 SW<  [(null)_nci_cmd_]
  422 root         0 SW<  [(null)_nci_rx_w]
  423 root         0 SW<  [(null)_nci_tx_w]

Move the id-allocation and struct-device initialisation back to
nfc_allocate_device() and fix up the single call site which did not use
nfc_free_device() in its registration error path.

Fixes: 7eda8b8e9677 ("NFC: Use IDR library to assing NFC devices IDs")
Cc: stable <stable@vger.kernel.org>     # 3.8
Cc: Samuel Ortiz <sameo@linux.intel.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 net/nfc/core.c     | 31 ++++++++++++++++++-------------
 net/nfc/nci/core.c |  3 +--
 2 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 122bb81da918..5cf33df888c3 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -982,6 +982,8 @@ static void nfc_release(struct device *d)
 			kfree(se);
 	}
 
+	ida_simple_remove(&nfc_index_ida, dev->idx);
+
 	kfree(dev);
 }
 
@@ -1056,6 +1058,7 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 				    int tx_headroom, int tx_tailroom)
 {
 	struct nfc_dev *dev;
+	int rc;
 
 	if (!ops->start_poll || !ops->stop_poll || !ops->activate_target ||
 	    !ops->deactivate_target || !ops->im_transceive)
@@ -1068,6 +1071,15 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 	if (!dev)
 		return NULL;
 
+	rc = ida_simple_get(&nfc_index_ida, 0, 0, GFP_KERNEL);
+	if (rc < 0)
+		goto err_free_dev;
+	dev->idx = rc;
+
+	dev->dev.class = &nfc_class;
+	dev_set_name(&dev->dev, "nfc%d", dev->idx);
+	device_initialize(&dev->dev);
+
 	dev->ops = ops;
 	dev->supported_protocols = supported_protocols;
 	dev->tx_headroom = tx_headroom;
@@ -1090,6 +1102,11 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 	}
 
 	return dev;
+
+err_free_dev:
+	kfree(dev);
+
+	return ERR_PTR(rc);
 }
 EXPORT_SYMBOL(nfc_allocate_device);
 
@@ -1104,14 +1121,6 @@ int nfc_register_device(struct nfc_dev *dev)
 
 	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
-	dev->idx = ida_simple_get(&nfc_index_ida, 0, 0, GFP_KERNEL);
-	if (dev->idx < 0)
-		return dev->idx;
-
-	dev->dev.class = &nfc_class;
-	dev_set_name(&dev->dev, "nfc%d", dev->idx);
-	device_initialize(&dev->dev);
-
 	mutex_lock(&nfc_devlist_mutex);
 	nfc_devlist_generation++;
 	rc = device_add(&dev->dev);
@@ -1149,12 +1158,10 @@ EXPORT_SYMBOL(nfc_register_device);
  */
 void nfc_unregister_device(struct nfc_dev *dev)
 {
-	int rc, id;
+	int rc;
 
 	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
-	id = dev->idx;
-
 	if (dev->rfkill) {
 		rfkill_unregister(dev->rfkill);
 		rfkill_destroy(dev->rfkill);
@@ -1179,8 +1186,6 @@ void nfc_unregister_device(struct nfc_dev *dev)
 	nfc_devlist_generation++;
 	device_del(&dev->dev);
 	mutex_unlock(&nfc_devlist_mutex);
-
-	ida_simple_remove(&nfc_index_ida, id);
 }
 EXPORT_SYMBOL(nfc_unregister_device);
 
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 61fff422424f..85a3d9ed4c29 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1173,8 +1173,7 @@ struct nci_dev *nci_allocate_device(struct nci_ops *ops,
 	return ndev;
 
 free_nfc:
-	kfree(ndev->nfc_dev);
-
+	nfc_free_device(ndev->nfc_dev);
 free_nci:
 	kfree(ndev);
 	return NULL;
-- 
2.12.2
