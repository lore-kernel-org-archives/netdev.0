From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] netback: don't store invalid vif pointer
Date: Tue, 09 Dec 2014 11:47:04 +0000
Message-ID: <5486EF48020000780004E1B8@mail.emea.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel" <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>,
	"Ian Campbell" <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emea.novell.com ([130.57.118.101]:51209 "EHLO
	mail.emea.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617AbaLILrJ convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 9 Dec 2014 06:47:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xenvif_alloc() fails, it returns a non-NULL error indicator. To
avoid eventual races, we shouldn't store that into struct backend_info
as readers of it only check for NULL.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -404,6 +404,7 @@ static int backend_create_xenvif(struct 
 	int err;
 	long handle;
 	struct xenbus_device *dev = be->dev;
+	struct xenvif *vif;
 
 	if (be->vif != NULL)
 		return 0;
@@ -414,13 +415,13 @@ static int backend_create_xenvif(struct 
 		return (err < 0) ? err : -EINVAL;
 	}
 
-	be->vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
-	if (IS_ERR(be->vif)) {
-		err = PTR_ERR(be->vif);
-		be->vif = NULL;
+	vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
+	if (IS_ERR(vif)) {
+		err = PTR_ERR(vif);
 		xenbus_dev_fatal(dev, err, "creating interface");
 		return err;
 	}
+	be->vif = vif;
 
 	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
 	return 0;
