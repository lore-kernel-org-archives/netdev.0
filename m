From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] NET/atm: handle sysfs errors
Date: Wed, 11 Oct 2006 21:51:53 -0400
Message-ID: <20061012015153.GA13204@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:16864 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1422689AbWJLBvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 21:51:54 -0400
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Jeff Garzik <jeff@garzik.org>

---

 net/atm/atm_sysfs.c         |   15 ++++++++++++---

diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index c0a4ae2..62f6ed1 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -141,7 +141,7 @@ static struct class atm_class = {
 int atm_register_sysfs(struct atm_dev *adev)
 {
 	struct class_device *cdev = &adev->class_dev;
-	int i, err;
+	int i, j, err;
 
 	cdev->class = &atm_class;
 	class_set_devdata(cdev, adev);
@@ -151,10 +151,19 @@ int atm_register_sysfs(struct atm_dev *a
 	if (err < 0)
 		return err;
 
-	for (i = 0; atm_attrs[i]; i++)
-		class_device_create_file(cdev, atm_attrs[i]);
+	for (i = 0; atm_attrs[i]; i++) {
+		err = class_device_create_file(cdev, atm_attrs[i]);
+		if (err)
+			goto err_out;
+	}
 
 	return 0;
+
+err_out:
+	for (j = 0; j < i; j++)
+		class_device_remove_file(cdev, atm_attrs[j]);
+	class_device_del(cdev);
+	return err;
 }
 
 void atm_unregister_sysfs(struct atm_dev *adev)
