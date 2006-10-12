From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] NET/bluetooth: handle sysfs errors
Date: Wed, 11 Oct 2006 21:53:16 -0400
Message-ID: <20061012015316.GA13305@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:23264 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1422693AbWJLBxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 21:53:22 -0400
To: marcel@holtmann.org, maxk@qualcomm.com,
	Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Jeff Garzik <jeff@garzik.org>

---

 net/bluetooth/l2cap.c       |   19 ++++++++++++++-----
 net/bluetooth/rfcomm/core.c |   21 ++++++++++++++++++---
 net/bluetooth/rfcomm/sock.c |    7 ++++++-
 net/bluetooth/sco.c         |   17 ++++++++++++-----
 4 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index d56f60b..7dda7ce 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2206,24 +2206,33 @@ static int __init l2cap_init(void)
 	err = bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops);
 	if (err < 0) {
 		BT_ERR("L2CAP socket registration failed");
-		goto error;
+		goto err_proto;
 	}
 
 	err = hci_register_proto(&l2cap_hci_proto);
 	if (err < 0) {
 		BT_ERR("L2CAP protocol registration failed");
-		bt_sock_unregister(BTPROTO_L2CAP);
-		goto error;
+		goto err_sock;
 	}
 
-	class_create_file(bt_class, &class_attr_l2cap);
+	err = class_create_file(bt_class, &class_attr_l2cap);
+	if (err) {
+		BT_ERR("L2CAP class registration failed");
+		goto err_proto2;
+	}
 
 	BT_INFO("L2CAP ver %s", VERSION);
 	BT_INFO("L2CAP socket layer initialized");
 
 	return 0;
 
-error:
+err_proto2:
+	if (hci_unregister_proto(&l2cap_hci_proto) < 0)
+		BT_ERR("L2CAP protocol unregistration failed");
+err_sock:
+	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
+		BT_ERR("L2CAP socket unregistration failed");
+err_proto:
 	proto_unregister(&l2cap_proto);
 	return err;
 }
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 468df3b..102d668 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -2052,13 +2052,21 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
 {
+	int rc;
+
 	l2cap_load();
 
-	hci_register_cb(&rfcomm_cb);
+	rc = hci_register_cb(&rfcomm_cb);
+	if (rc)
+		goto err;
 
-	kernel_thread(rfcomm_run, NULL, CLONE_KERNEL);
+	rc = class_create_file(bt_class, &class_attr_rfcomm_dlc);
+	if (rc)
+		goto err_hcireg;
 
-	class_create_file(bt_class, &class_attr_rfcomm_dlc);
+	rc = kernel_thread(rfcomm_run, NULL, CLONE_KERNEL);
+	if (rc < 0)
+		goto err_file;
 
 	rfcomm_init_sockets();
 
@@ -2069,6 +2077,13 @@ #endif
 	BT_INFO("RFCOMM ver %s", VERSION);
 
 	return 0;
+
+err_file:
+	class_remove_file(bt_class, &class_attr_rfcomm_dlc);
+err_hcireg:
+	hci_unregister_cb(&rfcomm_cb);
+err:
+	return rc;
 }
 
 static void __exit rfcomm_exit(void)
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 220fee0..ff9b3f1 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -944,12 +944,17 @@ int __init rfcomm_init_sockets(void)
 	if (err < 0)
 		goto error;
 
-	class_create_file(bt_class, &class_attr_rfcomm);
+	err = class_create_file(bt_class, &class_attr_rfcomm);
+	if (err)
+		goto error_sock;
 
 	BT_INFO("RFCOMM socket layer initialized");
 
 	return 0;
 
+error_sock:
+	if (bt_sock_unregister(BTPROTO_RFCOMM) < 0)
+		BT_ERR("RFCOMM socket layer unregistration failed");
 error:
 	BT_ERR("RFCOMM socket layer registration failed");
 	proto_unregister(&rfcomm_proto);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 7714a2e..f28392a 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -957,24 +957,31 @@ static int __init sco_init(void)
 	err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops);
 	if (err < 0) {
 		BT_ERR("SCO socket registration failed");
-		goto error;
+		goto err_proto;
 	}
 
 	err = hci_register_proto(&sco_hci_proto);
 	if (err < 0) {
 		BT_ERR("SCO protocol registration failed");
-		bt_sock_unregister(BTPROTO_SCO);
-		goto error;
+		goto err_sock;
 	}
 
-	class_create_file(bt_class, &class_attr_sco);
+	err = class_create_file(bt_class, &class_attr_sco);
+	if (err)
+		goto err_proto2;
 
 	BT_INFO("SCO (Voice Link) ver %s", VERSION);
 	BT_INFO("SCO socket layer initialized");
 
 	return 0;
 
-error:
+err_proto2:
+	if (hci_unregister_proto(&sco_hci_proto) < 0)
+		BT_ERR("SCO protocol unregistration failed");
+err_sock:
+	if (bt_sock_unregister(BTPROTO_SCO) < 0)
+		BT_ERR("SCO socket unregistration failed");
+err_proto:
 	proto_unregister(&sco_proto);
 	return err;
 }
