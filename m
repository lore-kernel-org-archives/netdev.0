From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v4 5/6] virtio: add pci_down/pci_up configuration
Date: Sun, 15 Jan 2017 16:01:19 -0800
Message-ID: <20170116000119.28980.89712.stgit@john-Precision-Tower-5810>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35891 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751259AbdAPABj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 19:01:39 -0500
Received: by mail-pf0-f196.google.com with SMTP id 19so2166344pfo.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 16:01:39 -0800 (PST)
In-Reply-To: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In virtio_net we need to do a full reset of the device to support
queue reconfiguration and also we can trigger this via ethtool
commands. So instead of open coding this in net driver push this
into generic code in virtio. This also avoid exporting a handful
of internal virtio routines.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/virtio/virtio.c         |   14 ++++++++++++--
 drivers/virtio/virtio_balloon.c |    4 ----
 drivers/virtio/virtio_input.c   |    4 ----
 include/linux/virtio.h          |    5 +----
 4 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
index 7062bb0..681fcfb 100644
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -339,7 +339,6 @@ void unregister_virtio_device(struct virtio_device *dev)
 }
 EXPORT_SYMBOL_GPL(unregister_virtio_device);
 
-#ifdef CONFIG_PM_SLEEP
 int virtio_device_freeze(struct virtio_device *dev)
 {
 	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
@@ -400,7 +399,18 @@ int virtio_device_restore(struct virtio_device *dev)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(virtio_device_restore);
-#endif
+
+int virtio_device_reset(struct virtio_device *dev)
+{
+	int err;
+
+	err = virtio_device_freeze(dev);
+	if (err)
+		return err;
+
+	return virtio_device_restore(dev);
+}
+EXPORT_SYMBOL_GPL(virtio_device_reset);
 
 static int virtio_init(void)
 {
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 181793f..4ca6220 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -620,7 +620,6 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	kfree(vb);
 }
 
-#ifdef CONFIG_PM_SLEEP
 static int virtballoon_freeze(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
@@ -649,7 +648,6 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	update_balloon_size(vb);
 	return 0;
 }
-#endif
 
 static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
@@ -666,10 +664,8 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	.probe =	virtballoon_probe,
 	.remove =	virtballoon_remove,
 	.config_changed = virtballoon_changed,
-#ifdef CONFIG_PM_SLEEP
 	.freeze	=	virtballoon_freeze,
 	.restore =	virtballoon_restore,
-#endif
 };
 
 module_virtio_driver(virtio_balloon_driver);
diff --git a/drivers/virtio/virtio_input.c b/drivers/virtio/virtio_input.c
index 350a2a5..d3517e2 100644
--- a/drivers/virtio/virtio_input.c
+++ b/drivers/virtio/virtio_input.c
@@ -328,7 +328,6 @@ static void virtinput_remove(struct virtio_device *vdev)
 	kfree(vi);
 }
 
-#ifdef CONFIG_PM_SLEEP
 static int virtinput_freeze(struct virtio_device *vdev)
 {
 	struct virtio_input *vi = vdev->priv;
@@ -356,7 +355,6 @@ static int virtinput_restore(struct virtio_device *vdev)
 	virtinput_fill_evt(vi);
 	return 0;
 }
-#endif
 
 static unsigned int features[] = {
 	/* none */
@@ -374,10 +372,8 @@ static int virtinput_restore(struct virtio_device *vdev)
 	.id_table            = id_table,
 	.probe               = virtinput_probe,
 	.remove              = virtinput_remove,
-#ifdef CONFIG_PM_SLEEP
 	.freeze	             = virtinput_freeze,
 	.restore             = virtinput_restore,
-#endif
 };
 
 module_virtio_driver(virtio_input_driver);
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index d5eb547..ff69f9a 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -138,10 +138,9 @@ static inline struct virtio_device *dev_to_virtio(struct device *_dev)
 void virtio_break_device(struct virtio_device *dev);
 
 void virtio_config_changed(struct virtio_device *dev);
-#ifdef CONFIG_PM_SLEEP
 int virtio_device_freeze(struct virtio_device *dev);
 int virtio_device_restore(struct virtio_device *dev);
-#endif
+int virtio_device_reset(struct virtio_device *dev);
 
 /**
  * virtio_driver - operations for a virtio I/O driver
@@ -167,10 +166,8 @@ struct virtio_driver {
 	void (*scan)(struct virtio_device *dev);
 	void (*remove)(struct virtio_device *dev);
 	void (*config_changed)(struct virtio_device *dev);
-#ifdef CONFIG_PM
 	int (*freeze)(struct virtio_device *dev);
 	int (*restore)(struct virtio_device *dev);
-#endif
 };
 
 static inline struct virtio_driver *drv_to_virtio(struct device_driver *drv)
