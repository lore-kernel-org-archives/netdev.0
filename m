From: Andy King <acking@vmware.com>
Subject: [PATCH] vsock: Make transport the proto owner
Date: Thu,  1 May 2014 15:09:13 -0700
Message-ID: <1398982153-31436-1-git-send-email-acking@vmware.com>
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	pv-drivers@vmware.com, Andy King <acking@vmware.com>,
	stable@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now the core vsock module is the owner of the proto family. This
means there's nothing preventing the transport module from unloading if
there are open sockets, which results in a panic. Fix that by allowing
the transport to be the owner, which will refcount it properly.

Includes version bump to 1.0.1.0-k

Cc: stable@vger.kernel.org
Acked-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 include/net/af_vsock.h   |    6 +++++-
 net/vmw_vsock/af_vsock.c |   46 +++++++++++++++++++++-------------------------
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 7d64d36..8f02e5c 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -155,7 +155,11 @@ struct vsock_transport {
 
 /**** CORE ****/
 
-int vsock_core_init(const struct vsock_transport *t);
+int __vsock_core_init(const struct vsock_transport *t, struct module *owner);
+static inline int vsock_core_init(const struct vsock_transport *t)
+{
+   return __vsock_core_init(t, THIS_MODULE);
+}
 void vsock_core_exit(void);
 
 /**** UTILS ****/
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 5adfd94..5743553 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1925,9 +1925,22 @@ static struct miscdevice vsock_device = {
 	.fops		= &vsock_device_ops,
 };
 
-static int __vsock_core_init(void)
+int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 {
-	int err;
+	int err = mutex_lock_interruptible(&vsock_register_mutex);
+	if (err)
+		return err;
+
+	if (transport) {
+		err = -EBUSY;
+		goto err_busy;
+	}
+
+	/* Transport must be the owner of the protocol so that it can't
+	 * unload while there are open sockets.
+	 */
+	vsock_proto.owner = owner;
+	transport = t;
 
 	vsock_init_tables();
 
@@ -1951,36 +1964,19 @@ static int __vsock_core_init(void)
 		goto err_unregister_proto;
 	}
 
+	mutex_unlock(&vsock_register_mutex);
 	return 0;
 
 err_unregister_proto:
 	proto_unregister(&vsock_proto);
 err_misc_deregister:
 	misc_deregister(&vsock_device);
-	return err;
-}
-
-int vsock_core_init(const struct vsock_transport *t)
-{
-	int retval = mutex_lock_interruptible(&vsock_register_mutex);
-	if (retval)
-		return retval;
-
-	if (transport) {
-		retval = -EBUSY;
-		goto out;
-	}
-
-	transport = t;
-	retval = __vsock_core_init();
-	if (retval)
-		transport = NULL;
-
-out:
+	transport = NULL;
+err_busy:
 	mutex_unlock(&vsock_register_mutex);
-	return retval;
+	return err;
 }
-EXPORT_SYMBOL_GPL(vsock_core_init);
+EXPORT_SYMBOL_GPL(__vsock_core_init);
 
 void vsock_core_exit(void)
 {
@@ -2000,5 +1996,5 @@ EXPORT_SYMBOL_GPL(vsock_core_exit);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
-MODULE_VERSION("1.0.0.0-k");
+MODULE_VERSION("1.0.1.0-k");
 MODULE_LICENSE("GPL v2");
-- 
1.7.4.1
