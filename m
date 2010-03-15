From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [1/3] gigaset: avoid registering CAPI driver more than once
Date: Mon, 15 Mar 2010 14:48:05 -0000
Message-ID: <1268664986.25524@pingi>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Registering/unregistering the Gigaset CAPI driver when a device is
connected/disconnected causes an Oops when disconnecting two Gigaset
devices in a row, because the same capi_driver structure gets
unregistered twice. Fix by making driver registration/unregistration
a separate operation (empty in the ISDN4Linux case) called when the
main module is loaded/unloaded.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Acked-by: Karsten Keil <keil@b1-systems.de>

---
Note to -stable: applies correctly to 2.6.33 with fuzz 2 in capi.c.

 drivers/isdn/gigaset/capi.c    |   44 ++++++++++++++++++++++-----------------
 drivers/isdn/gigaset/common.c  |    6 +++-
 drivers/isdn/gigaset/gigaset.h |    6 +++-
 drivers/isdn/gigaset/i4l.c     |   28 ++++++++++++++++++-------
 4 files changed, 53 insertions(+), 31 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 6643d65..4a31962 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -2191,36 +2191,24 @@ static const struct file_operations gigaset_proc_fops = {
 	.release	= single_release,
 };
 
-static struct capi_driver capi_driver_gigaset = {
-	.name		= "gigaset",
-	.revision	= "1.0",
-};
-
 /**
- * gigaset_isdn_register() - register to LL
+ * gigaset_isdn_regdev() - register device to LL
  * @cs:		device descriptor structure.
  * @isdnid:	device name.
  *
- * Called by main module to register the device with the LL.
- *
  * Return value: 1 for success, 0 for failure
  */
-int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
+int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
 	struct gigaset_capi_ctr *iif;
 	int rc;
 
-	pr_info("Kernel CAPI interface\n");
-
 	iif = kmalloc(sizeof(*iif), GFP_KERNEL);
 	if (!iif) {
 		pr_err("%s: out of memory\n", __func__);
 		return 0;
 	}
 
-	/* register driver with CAPI (ToDo: what for?) */
-	register_capi_driver(&capi_driver_gigaset);
-
 	/* prepare controller structure */
 	iif->ctr.owner         = THIS_MODULE;
 	iif->ctr.driverdata    = cs;
@@ -2241,7 +2229,6 @@ int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
 	rc = attach_capi_ctr(&iif->ctr);
 	if (rc) {
 		pr_err("attach_capi_ctr failed (%d)\n", rc);
-		unregister_capi_driver(&capi_driver_gigaset);
 		kfree(iif);
 		return 0;
 	}
@@ -2252,17 +2239,36 @@ int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
 }
 
 /**
- * gigaset_isdn_unregister() - unregister from LL
+ * gigaset_isdn_unregdev() - unregister device from LL
  * @cs:		device descriptor structure.
- *
- * Called by main module to unregister the device from the LL.
  */
-void gigaset_isdn_unregister(struct cardstate *cs)
+void gigaset_isdn_unregdev(struct cardstate *cs)
 {
 	struct gigaset_capi_ctr *iif = cs->iif;
 
 	detach_capi_ctr(&iif->ctr);
 	kfree(iif);
 	cs->iif = NULL;
+}
+
+static struct capi_driver capi_driver_gigaset = {
+	.name		= "gigaset",
+	.revision	= "1.0",
+};
+
+/**
+ * gigaset_isdn_regdrv() - register driver to LL
+ */
+void gigaset_isdn_regdrv(void)
+{
+	pr_info("Kernel CAPI interface\n");
+	register_capi_driver(&capi_driver_gigaset);
+}
+
+/**
+ * gigaset_isdn_unregdrv() - unregister driver from LL
+ */
+void gigaset_isdn_unregdrv(void)
+{
 	unregister_capi_driver(&capi_driver_gigaset);
 }
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 85de339..bdc01cb 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -507,7 +507,7 @@ void gigaset_freecs(struct cardstate *cs)
 	case 2: /* error in initcshw */
 		/* Deregister from LL */
 		make_invalid(cs, VALID_ID);
-		gigaset_isdn_unregister(cs);
+		gigaset_isdn_unregdev(cs);
 
 		/* fall through */
 	case 1: /* error when registering to LL */
@@ -769,7 +769,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->cmdbytes = 0;
 
 	gig_dbg(DEBUG_INIT, "setting up iif");
-	if (!gigaset_isdn_register(cs, modulename)) {
+	if (!gigaset_isdn_regdev(cs, modulename)) {
 		pr_err("error registering ISDN device\n");
 		goto error;
 	}
@@ -1205,11 +1205,13 @@ static int __init gigaset_init_module(void)
 		gigaset_debuglevel = DEBUG_DEFAULT;
 
 	pr_info(DRIVER_DESC DRIVER_DESC_DEBUG "\n");
+	gigaset_isdn_regdrv();
 	return 0;
 }
 
 static void __exit gigaset_exit_module(void)
 {
+	gigaset_isdn_unregdrv();
 }
 
 module_init(gigaset_init_module);
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 1875ab8..cdd144e 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -675,8 +675,10 @@ int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size);
  */
 
 /* Called from common.c for setting up/shutting down with the ISDN subsystem */
-int gigaset_isdn_register(struct cardstate *cs, const char *isdnid);
-void gigaset_isdn_unregister(struct cardstate *cs);
+void gigaset_isdn_regdrv(void);
+void gigaset_isdn_unregdrv(void);
+int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid);
+void gigaset_isdn_unregdev(struct cardstate *cs);
 
 /* Called from hardware module to indicate completion of an skb */
 void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb);
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index f0acb9d..c22e5ac 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -592,15 +592,13 @@ void gigaset_isdn_stop(struct cardstate *cs)
 }
 
 /**
- * gigaset_isdn_register() - register to LL
+ * gigaset_isdn_regdev() - register to LL
  * @cs:		device descriptor structure.
  * @isdnid:	device name.
  *
- * Called by main module to register the device with the LL.
- *
  * Return value: 1 for success, 0 for failure
  */
-int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
+int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
 	isdn_if *iif;
 
@@ -650,15 +648,29 @@ int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
 }
 
 /**
- * gigaset_isdn_unregister() - unregister from LL
+ * gigaset_isdn_unregdev() - unregister device from LL
  * @cs:		device descriptor structure.
- *
- * Called by main module to unregister the device from the LL.
  */
-void gigaset_isdn_unregister(struct cardstate *cs)
+void gigaset_isdn_unregdev(struct cardstate *cs)
 {
 	gig_dbg(DEBUG_CMD, "sending UNLOAD");
 	gigaset_i4l_cmd(cs, ISDN_STAT_UNLOAD);
 	kfree(cs->iif);
 	cs->iif = NULL;
 }
+
+/**
+ * gigaset_isdn_regdrv() - register driver to LL
+ */
+void gigaset_isdn_regdrv(void)
+{
+	/* nothing to do */
+}
+
+/**
+ * gigaset_isdn_unregdrv() - unregister driver from LL
+ */
+void gigaset_isdn_unregdrv(void)
+{
+	/* nothing to do */
+}
