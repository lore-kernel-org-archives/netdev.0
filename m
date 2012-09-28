From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH] scsi: move scsi_netlink code out of SCSI core
Date: Fri, 28 Sep 2012 20:47:57 +0200
Message-ID: <1348858077-17935-1-git-send-email-jengelh@inai.de>
Cc: linux-scsi@vger.kernel.org, James.Smart@emulex.com,
	James.Bottomley@parallels.com, ebiederm@xmission.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only scsi_transport_fc needs scsi_netlink, so recombine the logic such
that scsi_netlink is bundled with scsi_transport_fc instead of scsi_mod.

Cc: James Smart <James.Smart@emulex.com>
Cc: James Bottomley <James.Bottomley@parallels.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---

(What's with the 2001-09-17 date git is emitting in the From line?!
 "From be20b2... Mon Sep 17 00:00:00 2001" while git send-email --annotate)


Roughly two years ago, I had a patch which turned scsi_netlink.c into
its own .ko module (this was not applied). The recent submission of
8289bab1daf9768c20114051a99c1bd5f48d4420 has made me look into
scsi_netlinkage again. scsi_netlink.c is too small to warrant a
separate module, so instead I thought it could be moved into fc.c.
And that's what I am loosely proposing here...



 drivers/scsi/Kconfig             |    6 ------
 drivers/scsi/Makefile            |    4 ++--
 drivers/scsi/scsi.c              |    3 ---
 drivers/scsi/scsi_netlink.c      |   12 +++++-------
 drivers/scsi/scsi_priv.h         |    7 ++-----
 drivers/scsi/scsi_transport_fc.c |    8 +++++++-
 6 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 74bf1aa..52993ae 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -47,11 +47,6 @@ config SCSI_TGT
 	  If you want to use SCSI target mode drivers enable this option.
 	  If you choose M, the module will be called scsi_tgt.
 
-config SCSI_NETLINK
-	bool
-	default	n
-	select NET
-
 config SCSI_PROC_FS
 	bool "legacy /proc/scsi/ support"
 	depends on SCSI && PROC_FS
@@ -276,7 +271,6 @@ config SCSI_SPI_ATTRS
 config SCSI_FC_ATTRS
 	tristate "FiberChannel Transport Attributes"
 	depends on SCSI
-	select SCSI_NETLINK
 	help
 	  If you wish to export transport-specific information about
 	  each attached FiberChannel device to sysfs, say Y.
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 888f73a..32bcb3d 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -29,7 +29,8 @@ obj-$(CONFIG_RAID_ATTRS)	+= raid_class.o
 # be initialised before drivers
 # --------------------------
 obj-$(CONFIG_SCSI_SPI_ATTRS)	+= scsi_transport_spi.o
-obj-$(CONFIG_SCSI_FC_ATTRS) 	+= scsi_transport_fc.o
+obj-$(CONFIG_SCSI_FC_ATTRS) 	+= scsi_transport_fcattr.o
+scsi_transport_fcattr-y		:= scsi_transport_fc.o scsi_netlink.o
 obj-$(CONFIG_SCSI_ISCSI_ATTRS)	+= scsi_transport_iscsi.o
 obj-$(CONFIG_SCSI_SAS_ATTRS)	+= scsi_transport_sas.o
 obj-$(CONFIG_SCSI_SAS_LIBSAS)	+= libsas/
@@ -163,7 +164,6 @@ scsi_mod-y			+= scsi.o hosts.o scsi_ioctl.o constants.o \
 				   scsicam.o scsi_error.o scsi_lib.o
 scsi_mod-$(CONFIG_SCSI_DMA)	+= scsi_lib_dma.o
 scsi_mod-y			+= scsi_scan.o scsi_sysfs.o scsi_devinfo.o
-scsi_mod-$(CONFIG_SCSI_NETLINK)	+= scsi_netlink.o
 scsi_mod-$(CONFIG_SYSCTL)	+= scsi_sysctl.o
 scsi_mod-$(CONFIG_SCSI_PROC_FS)	+= scsi_proc.o
 scsi_mod-y			+= scsi_trace.o
diff --git a/drivers/scsi/scsi.c b/drivers/scsi/scsi.c
index 2936b44..f5dedc7 100644
--- a/drivers/scsi/scsi.c
+++ b/drivers/scsi/scsi.c
@@ -1326,8 +1326,6 @@ static int __init init_scsi(void)
 	if (error)
 		goto cleanup_sysctl;
 
-	scsi_netlink_init();
-
 	printk(KERN_NOTICE "SCSI subsystem initialized\n");
 	return 0;
 
@@ -1348,7 +1346,6 @@ cleanup_queue:
 
 static void __exit exit_scsi(void)
 {
-	scsi_netlink_exit();
 	scsi_sysfs_unregister();
 	scsi_exit_sysctl();
 	scsi_exit_hosts();
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 65123a2..20ca4b8 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -18,6 +18,7 @@
  *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  *
  */
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/jiffies.h>
 #include <linux/security.h>
@@ -122,8 +123,7 @@ next_msg:
  * 	the SCSI transport netlink interface
  *
  **/
-void
-scsi_netlink_init(void)
+int __init scsi_netlink_init(void)
 {
 	struct netlink_kernel_cfg cfg = {
 		.input	= scsi_nl_rcv_msg,
@@ -135,10 +135,10 @@ scsi_netlink_init(void)
 	if (!scsi_nl_sock) {
 		printk(KERN_ERR "%s: register of receive handler failed\n",
 				__func__);
-		return;
+		return -ENOMEM;
 	}
 
-	return;
+	return 0;
 }
 
 
@@ -146,8 +146,7 @@ scsi_netlink_init(void)
  * scsi_netlink_exit - Called by SCSI subsystem to disable the SCSI transport netlink interface
  *
  **/
-void
-scsi_netlink_exit(void)
+void scsi_netlink_exit(void)
 {
 	if (scsi_nl_sock) {
 		netlink_kernel_release(scsi_nl_sock);
@@ -155,4 +154,3 @@ scsi_netlink_exit(void)
 
 	return;
 }
-
diff --git a/drivers/scsi/scsi_priv.h b/drivers/scsi/scsi_priv.h
index 8f9a0ca..f875844 100644
--- a/drivers/scsi/scsi_priv.h
+++ b/drivers/scsi/scsi_priv.h
@@ -139,13 +139,10 @@ extern struct bus_type scsi_bus_type;
 extern const struct attribute_group *scsi_sysfs_shost_attr_groups[];
 
 /* scsi_netlink.c */
-#ifdef CONFIG_SCSI_NETLINK
-extern void scsi_netlink_init(void);
+#if IS_ENABLED(CONFIG_SCSI_FC_ATTRS)
+extern int scsi_netlink_init(void);
 extern void scsi_netlink_exit(void);
 extern struct sock *scsi_nl_sock;
-#else
-static inline void scsi_netlink_init(void) {}
-static inline void scsi_netlink_exit(void) {}
 #endif
 
 /* scsi_pm.c */
diff --git a/drivers/scsi/scsi_transport_fc.c b/drivers/scsi/scsi_transport_fc.c
index e894ca7..3716ce2 100644
--- a/drivers/scsi/scsi_transport_fc.c
+++ b/drivers/scsi/scsi_transport_fc.c
@@ -661,9 +661,12 @@ static __init int fc_transport_init(void)
 
 	atomic_set(&fc_event_seq, 0);
 
+	error = scsi_netlink_init();
+	if (error < 0)
+		return error;
 	error = transport_class_register(&fc_host_class);
 	if (error)
-		return error;
+		goto unreg_netlink;
 	error = transport_class_register(&fc_vport_class);
 	if (error)
 		goto unreg_host_class;
@@ -681,6 +684,8 @@ unreg_vport_class:
 	transport_class_unregister(&fc_vport_class);
 unreg_host_class:
 	transport_class_unregister(&fc_host_class);
+unreg_netlink:
+	scsi_netlink_exit();
 	return error;
 }
 
@@ -690,6 +695,7 @@ static void __exit fc_transport_exit(void)
 	transport_class_unregister(&fc_rport_class);
 	transport_class_unregister(&fc_host_class);
 	transport_class_unregister(&fc_vport_class);
+	scsi_netlink_exit();
 }
 
 /*
-- 
1.7.10.4

