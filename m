From: "Karen Xie" <kxie@chelsio.com>
Subject: [PATCH 3/3 2.6.27] cxgb3i - add cxgb3i iscsi driver
Date: Wed, 18 Jun 2008 22:10:30 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334D71287@maui.asicdesigners.com>
References: <200806190256.m5J2u6On021011@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<open-iscsi@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<security@kernel.org>
To: <michaelc@cs.wisc.edu>, "Divy Le Ray" <divy@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karen Xie <kxie@chelsio.com>

New cxgb3i iscsi driver. The driver interfaces with cxgb3 driver to access the hardware.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---

 drivers/scsi/Kconfig                 |    2 
 drivers/scsi/Makefile                |    1 
 drivers/scsi/cxgb3i/Kconfig          |    6 
 drivers/scsi/cxgb3i/Makefile         |    5 
 drivers/scsi/cxgb3i/cxgb3i.h         |  190 ++
 drivers/scsi/cxgb3i/cxgb3i_init.c    |  107 +
 drivers/scsi/cxgb3i/cxgb3i_iscsi.c   |  797 ++++++++++
 drivers/scsi/cxgb3i/cxgb3i_offload.c | 2808 ++++++++++++++++++++++++++++++++++
 drivers/scsi/cxgb3i/cxgb3i_offload.h |  259 +++
 drivers/scsi/cxgb3i/cxgb3i_ulp2.c    |  722 +++++++++
 drivers/scsi/cxgb3i/cxgb3i_ulp2.h    |  102 +
 security/security.c                  |    1 
 12 files changed, 5000 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/cxgb3i/Kconfig
 create mode 100644 drivers/scsi/cxgb3i/Makefile
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i.h
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_init.c
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_iscsi.c
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.c
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.h
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.c
 create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.h


diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 22070e9..5ae06a8 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -1759,6 +1759,8 @@ config ZFCP
 
 source "drivers/scsi/bnx2i/Kconfig"
 
+source "drivers/scsi/cxgb3i/Kconfig"
+
 config SCSI_SRP
 	tristate "SCSI RDMA Protocol helper library"
 	depends on SCSI && PCI
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index a3f6866..b830af3 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -123,6 +123,7 @@ obj-$(CONFIG_SCSI_STEX)		+= stex.o
 obj-$(CONFIG_SCSI_MVSAS)	+= mvsas.o
 obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
 obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= bnx2i/
+obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= cxgb3i/
 
 obj-$(CONFIG_ARM)		+= arm/
 
diff --git a/drivers/scsi/cxgb3i/Kconfig b/drivers/scsi/cxgb3i/Kconfig
new file mode 100644
index 0000000..2762814
--- /dev/null
+++ b/drivers/scsi/cxgb3i/Kconfig
@@ -0,0 +1,6 @@
+config SCSI_CXGB3_ISCSI
+	tristate "Chelsio S3xx iSCSI support"
+	select CHELSIO_T3
+	select SCSI_ISCSI_ATTRS
+	---help---
+	This driver supports iSCSI offload for the Chelsio S3 series devices.
diff --git a/drivers/scsi/cxgb3i/Makefile b/drivers/scsi/cxgb3i/Makefile
new file mode 100644
index 0000000..8c8a894
--- /dev/null
+++ b/drivers/scsi/cxgb3i/Makefile
@@ -0,0 +1,5 @@
+EXTRA_CFLAGS += -I$(TOPDIR)/drivers/net/cxgb3
+
+cxgb3i-y := cxgb3i_init.o cxgb3i_iscsi.o cxgb3i_ulp2.o cxgb3i_offload.o
+
+obj-$(CONFIG_SCSI_CXGB3_ISCSI) += cxgb3i.o
diff --git a/drivers/scsi/cxgb3i/cxgb3i.h b/drivers/scsi/cxgb3i/cxgb3i.h
new file mode 100644
index 0000000..39a3b94
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i.h
@@ -0,0 +1,190 @@
+/*
+ * cxgb3i.h: Chelsio S3xx iSCSI driver.
+ *
+ * Copyright (c) 2008 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#ifndef __CXGB3I_H__
+#define __CXGB3I_H__
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/interrupt.h>
+#include <linux/sched.h>
+#include <linux/in.h>
+#include <linux/kfifo.h>
+#include <linux/netdevice.h>
+#include <linux/completion.h>
+#include <linux/scatterlist.h>
+
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_eh.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi.h>
+#include <scsi/iscsi_proto.h>
+#include <scsi/libiscsi.h>
+#include <scsi/scsi_transport_iscsi.h>
+#include <linux/crypto.h>
+#include "../iscsi_tcp.h"
+
+/* from cxgb3 LLD */
+#include "common.h"
+#include "t3_cpl.h"
+#include "t3cdev.h"
+#include "cxgb3_ctl_defs.h"
+#include "cxgb3_offload.h"
+#include "firmware_exports.h"
+#include "cxgb3i_offload.h"
+
+/**
+ * message
+ */
+#define cxgb3i_log_error(fmt...) printk(KERN_ERR "cxgb3i: ERR! " fmt)
+#define cxgb3i_log_warn(fmt...)  printk(KERN_WARNING "cxgb3i: WARN! " fmt)
+#define cxgb3i_log_info(fmt...)  printk(KERN_INFO "cxgb3i: " fmt)
+
+#ifdef __DEBUG_CXGB3I__
+#define cxgb3i_log_debug(fmt, args...) \
+	printk(KERN_ERR "cxgb3i: %s - " fmt, __func__ , ## args)
+#else
+#define cxgb3i_log_debug(fmt...)
+#endif
+
+#define CXGB3I_SCSI_QDEPTH_DFLT	128
+
+struct cxgb3i_adapter;
+struct cxgb3i_hba;
+struct cxgb3i_endpoint;
+
+/**
+ * struct cxgb3i_tag_format - cxgb3i ulp tag for steering pdu payload
+ *
+ * @rsvd_bits:	# of bits used by h/w
+ * @rsvd_shift:	shift left
+ * @rsvd_mask:  bit mask
+ *
+ */
+struct cxgb3i_tag_format {
+	unsigned char idx_bits;
+	unsigned char age_bits;
+	unsigned char rsvd_bits;
+	unsigned char rsvd_shift;
+	u32 rsvd_mask;
+};
+
+/**
+ * struct cxgb3i_ddp_info - cxgb3i direct data placement for pdu payload
+ *
+ * @llimit:	lower bound of the page pod memory
+ * @ulimit:	upper bound of the page pod memory
+ * @nppods:	# of page pod entries
+ * @idx_last:	page pod entry last used
+ * @map_lock:	lock to synchonize access to the page pod map
+ * @map:	page pod map
+ */
+struct cxgb3i_ddp_info {
+	unsigned int llimit;
+	unsigned int ulimit;
+	unsigned int nppods;
+	unsigned int idx_last;
+	spinlock_t map_lock;
+	u8 *map;
+};
+
+struct cxgb3i_hba {
+	struct cxgb3i_adapter *snic;
+	struct net_device *ndev;
+	struct Scsi_Host *shost;
+
+	rwlock_t cconn_rwlock;
+	struct list_head cconn_list;
+};
+
+struct cxgb3i_adapter {
+	struct list_head list_head;
+	spinlock_t lock;
+	struct t3cdev *tdev;
+	struct pci_dev *pdev;
+	unsigned char hba_cnt;
+	struct cxgb3i_hba *hba[MAX_NPORTS];
+
+	unsigned int tx_max_size;
+	unsigned int rx_max_size;
+
+	struct cxgb3i_tag_format tag_format;
+	struct cxgb3i_ddp_info ddp;
+};
+
+struct cxgb3i_conn {
+	struct list_head list_head;
+
+	struct cxgb3i_endpoint *cep;
+	struct iscsi_conn *conn;
+	struct cxgb3i_hba *hba;
+};
+
+struct cxgb3i_endpoint {
+	struct socket *sock;
+	struct cxgb3i_hba *hba;
+	struct cxgb3i_conn *cconn;
+};
+
+int cxgb3i_iscsi_init(void);
+void cxgb3i_iscsi_cleanup(void);
+
+struct cxgb3i_adapter *cxgb3i_adapter_find_by_tdev(struct t3cdev *);
+struct cxgb3i_adapter *cxgb3i_adapter_add(struct t3cdev *);
+void cxgb3i_adapter_remove(struct cxgb3i_adapter *);
+int cxgb3i_adapter_ulp_init(struct cxgb3i_adapter *);
+void cxgb3i_adapter_ulp_cleanup(struct cxgb3i_adapter *);
+
+struct cxgb3i_hba *cxgb3i_hba_find_by_netdev(struct net_device *);
+struct cxgb3i_hba *cxgb3i_hba_host_add(struct cxgb3i_adapter *,
+				       struct net_device *);
+void cxgb3i_hba_host_remove(struct cxgb3i_hba *);
+
+void cxgb3i_hba_conn_add(struct cxgb3i_conn *, struct cxgb3i_hba *);
+void cxgb3i_hba_conn_remove(struct cxgb3i_conn *);
+
+int cxgb3i_ulp2_init(void);
+void cxgb3i_ulp2_cleanup(void);
+int cxgb3i_conn_ulp_setup(struct cxgb3i_conn *, int, int);
+
+void cxgb3i_ddp_tag_release(struct cxgb3i_adapter *, u32,
+			    struct scatterlist *, unsigned int);
+u32 cxgb3i_ddp_tag_reserve(struct cxgb3i_adapter *, unsigned int,
+			   u32, unsigned int, struct scatterlist *,
+			   unsigned int);
+static inline void cxgb3i_parse_tag(struct cxgb3i_tag_format *format,
+				    u32 tag, u32 *rsvd_bits, u32 *sw_bits)
+{
+	if (rsvd_bits)
+		*rsvd_bits = (tag >> format->rsvd_shift) & format->rsvd_mask;
+	if (sw_bits) {
+		*sw_bits = (tag >> (format->rsvd_shift + format->rsvd_bits))
+		    << format->rsvd_shift;
+		*sw_bits |= tag & ((1 << format->rsvd_shift) - 1);
+	}
+}
+
+void cxgb3i_sk_set_callbacks(struct sock *, struct iscsi_conn *);
+void cxgb3i_sk_restore_callbacks(struct sock *, struct iscsi_conn *);
+
+int cxgb3i_conn_ulp2_xmit(struct iscsi_conn *);
+
+void cxgb3i_display_byte_string(char *, unsigned char *, int, int);
+
+#endif
diff --git a/drivers/scsi/cxgb3i/cxgb3i_init.c b/drivers/scsi/cxgb3i/cxgb3i_init.c
new file mode 100644
index 0000000..b848e4c
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_init.c
@@ -0,0 +1,107 @@
+/* cxgb3i_init.c: Chelsio S3xx iSCSI driver.
+ *
+ * Copyright (c) 2008 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#include "cxgb3i.h"
+
+#define DRV_MODULE_NAME         "cxgb3i"
+#define DRV_MODULE_VERSION      "1.0.0"
+#define DRV_MODULE_RELDATE      "May 1, 2008"
+
+static char version[] __devinitdata =
+    "Chelsio S3xx iSCSI Driver " DRV_MODULE_NAME
+    " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+
+MODULE_AUTHOR("Karen Xie <kxie@chelsio.com>");
+MODULE_DESCRIPTION("Chelsio S3xx iSCSI Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_MODULE_VERSION);
+
+static void open_s3_dev(struct t3cdev *);
+static void close_s3_dev(struct t3cdev *);
+cxgb3_cpl_handler_func cxgb3i_cpl_handlers[NUM_CPL_CMDS];
+struct cxgb3_client t3c_client = {
+	.name = "iscsi_cxgb3",
+	.handlers = cxgb3i_cpl_handlers,
+	.add = open_s3_dev,
+	.remove = close_s3_dev,
+};
+
+/**
+ * open_s3_dev - register with cxgb3 LLD
+ * @t3dev	cxgb3 adapter instance
+ */
+static void open_s3_dev(struct t3cdev *t3dev)
+{
+	static int vers_printed;
+
+	if (!vers_printed)
+		printk(KERN_INFO "%s", version);
+
+	cxgb3i_log_debug("open cxgb3 %s.\n", t3dev->name);
+
+	cxgb3i_tcp_add(t3dev, &t3c_client);
+	cxgb3i_adapter_add(t3dev);
+}
+
+/**
+ * close_s3_dev - de-register with cxgb3 LLD
+ * @t3dev	cxgb3 adapter instance
+ */
+static void close_s3_dev(struct t3cdev *t3dev)
+{
+	struct cxgb3i_adapter *snic = cxgb3i_adapter_find_by_tdev(t3dev);
+	cxgb3i_log_debug("close cxgb3 %s.\n", t3dev->name);
+	if (snic)
+		cxgb3i_adapter_remove(snic);
+	cxgb3i_tcp_remove(t3dev);
+}
+
+/**
+ * cxgb3i_init_module - module init entry point
+ *
+ * initialize any driver wide global data structures and register itself
+ *	with the cxgb3 module
+ */
+static int __init cxgb3i_init_module(void)
+{
+	int err;
+
+	err = cxgb3i_tcp_init(cxgb3i_cpl_handlers);
+	if (err < 0)
+		return err;
+
+	err = cxgb3i_iscsi_init();
+	if (err < 0)
+		return err;
+
+	err = cxgb3i_ulp2_init();
+	if (err < 0)
+		return err;
+
+	cxgb3_register_client(&t3c_client);
+	return 0;
+}
+
+/**
+ * cxgb3i_exit_module - module cleanup/exit entry point
+ *
+ * go through the driver hba list and for each hba, release any resource held.
+ *	and unregisters iscsi transport and the cxgb3 module
+ */
+static void __exit cxgb3i_exit_module(void)
+{
+	cxgb3_unregister_client(&t3c_client);
+	cxgb3i_ulp2_cleanup();
+	cxgb3i_iscsi_cleanup();
+}
+
+module_init(cxgb3i_init_module);
+module_exit(cxgb3i_exit_module);
diff --git a/drivers/scsi/cxgb3i/cxgb3i_iscsi.c b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
new file mode 100644
index 0000000..ea7e21f
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
@@ -0,0 +1,797 @@
+/* cxgb3i_iscsi.c: Chelsio S3xx iSCSI driver.
+ *
+ * Copyright (c) 2008 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#include <net/tcp.h>
+#include "cxgb3i.h"
+
+static struct scsi_transport_template *cxgb3i_scsi_transport;
+static struct scsi_host_template cxgb3i_host_template;
+static struct iscsi_transport cxgb3i_iscsi_transport;
+
+static LIST_HEAD(cxgb3i_snic_list);
+static DEFINE_RWLOCK(cxgb3i_snic_rwlock);
+
+/**
+ * cxgb3i_adapter_add - initialize a s3 adapter structure and any h/w settings
+ *	necessary
+ * @snic:	pointer to adapter instance
+ */
+struct cxgb3i_adapter *cxgb3i_adapter_add(struct t3cdev *t3dev)
+{
+	struct cxgb3i_adapter *snic;
+	struct adapter *adapter = tdev2adap(t3dev);
+	int i;
+
+	snic = kzalloc(sizeof(*snic), GFP_KERNEL);
+	if (!snic) {
+		cxgb3i_log_debug("cxgb3 %s, OOM.\n", t3dev->name);
+		return NULL;
+	}
+
+	spin_lock_init(&snic->lock);
+	snic->tdev = t3dev;
+	snic->pdev = adapter->pdev;
+
+	if (cxgb3i_adapter_ulp_init(snic))
+		goto free_snic;
+
+	for_each_port(adapter, i) {
+		snic->hba[i] = cxgb3i_hba_host_add(snic, adapter->port[i]);
+		if (!snic->hba[i])
+			goto ulp_cleanup;
+	}
+	snic->hba_cnt = adapter->params.nports;
+
+	/* add to the list */
+	write_lock(&cxgb3i_snic_rwlock);
+	list_add_tail(&snic->list_head, &cxgb3i_snic_list);
+	write_unlock(&cxgb3i_snic_rwlock);
+
+	return snic;
+
+ulp_cleanup:
+	cxgb3i_adapter_ulp_cleanup(snic);
+free_snic:
+	kfree(snic);
+	return NULL;
+}
+
+/**
+ * cxgb3i_snic_cleanup - release all the resources held and cleanup any h/w
+ *	settings necessary
+ * @snic:	pointer to adapter instance
+ */
+void cxgb3i_adapter_remove(struct cxgb3i_adapter *snic)
+{
+	int i;
+
+	/* remove from the list */
+	write_lock(&cxgb3i_snic_rwlock);
+	list_del(&snic->list_head);
+	write_unlock(&cxgb3i_snic_rwlock);
+
+	for (i = 0; i < snic->hba_cnt; i++) {
+		if (snic->hba[i]) {
+			cxgb3i_hba_host_remove(snic->hba[i]);
+			snic->hba[i] = NULL;
+		}
+	}
+
+	/* release ddp resources */
+	cxgb3i_adapter_ulp_cleanup(snic);
+	kfree(snic);
+}
+
+struct cxgb3i_adapter *cxgb3i_adapter_find_by_tdev(struct t3cdev *t3dev)
+{
+	struct cxgb3i_adapter *snic;
+
+	read_lock(&cxgb3i_snic_rwlock);
+	list_for_each_entry(snic, &cxgb3i_snic_list, list_head) {
+		if (snic->tdev == t3dev) {
+			read_unlock(&cxgb3i_snic_rwlock);
+			return snic;
+		}
+	}
+	read_unlock(&cxgb3i_snic_rwlock);
+
+	return NULL;
+}
+
+struct cxgb3i_hba *cxgb3i_hba_find_by_netdev(struct net_device *ndev)
+{
+	struct cxgb3i_adapter *snic;
+	int i;
+
+	read_lock(&cxgb3i_snic_rwlock);
+	list_for_each_entry(snic, &cxgb3i_snic_list, list_head) {
+		for (i = 0; i < snic->hba_cnt; i++) {
+			if (snic->hba[i]->ndev == ndev) {
+				read_unlock(&cxgb3i_snic_rwlock);
+				return (snic->hba[i]);
+			}
+		}
+	}
+	read_unlock(&cxgb3i_snic_rwlock);
+	return NULL;
+}
+
+void cxgb3i_hba_conn_add(struct cxgb3i_conn *cconn, struct cxgb3i_hba *hba)
+{
+	cconn->hba = hba;
+	write_lock(&hba->cconn_rwlock);
+	list_add_tail(&cconn->list_head, &hba->cconn_list);
+	write_unlock(&hba->cconn_rwlock);
+}
+
+void cxgb3i_hba_conn_remove(struct cxgb3i_conn *cconn)
+{
+	struct cxgb3i_hba *hba = cconn->hba;
+
+	if (hba) {
+		write_lock(&hba->cconn_rwlock);
+		list_del(&cconn->list_head);
+		write_unlock(&hba->cconn_rwlock);
+	}
+}
+
+struct cxgb3i_hba *cxgb3i_hba_host_add(struct cxgb3i_adapter *snic,
+				       struct net_device *ndev)
+{
+	struct cxgb3i_hba *hba;
+	struct Scsi_Host *shost;
+	int err;
+
+	shost = iscsi_host_alloc(&cxgb3i_host_template,
+				 sizeof(struct cxgb3i_hba),
+				 CXGB3I_SCSI_QDEPTH_DFLT);
+	if (!shost) {
+		cxgb3i_log_info("iscsi_host_alloc failed.\n");
+		return NULL;
+	}
+
+	shost->transportt = cxgb3i_scsi_transport;
+	shost->max_lun = 512;
+	shost->max_id = 0;
+	shost->max_channel = 0;
+	shost->max_cmd_len = 16;
+
+	hba = iscsi_host_priv(shost);
+	INIT_LIST_HEAD(&hba->cconn_list);
+	rwlock_init(&hba->cconn_rwlock);
+	hba->snic = snic;
+	hba->ndev = ndev;
+	hba->shost = shost;
+
+	pci_dev_get(snic->pdev);
+	err = iscsi_host_add(shost, &snic->pdev->dev);
+	if (err) {
+		cxgb3i_log_info("iscsi_host_add failed.\n");
+		goto pci_dev_put;
+	}
+
+	cxgb3i_log_debug("shost 0x%p, hba 0x%p, no %u.\n",
+			 shost, hba, shost->host_no);
+
+	return hba;
+
+pci_dev_put:
+	pci_dev_put(snic->pdev);
+	scsi_host_put(shost);
+	return NULL;
+}
+
+void cxgb3i_hba_host_remove(struct cxgb3i_hba *hba)
+{
+	if (hba->shost) {
+		cxgb3i_log_debug("shost 0x%p, hba 0x%p, no %u.\n",
+				 hba->shost, hba, hba->shost->host_no);
+		iscsi_host_remove(hba->shost);
+		pci_dev_put(hba->snic->pdev);
+		/* cleanup connections ? */
+		iscsi_host_free(hba->shost);
+	}
+}
+
+/**
+ * cxgb3i_ep_connect - establish TCP connection to target portal
+ * @dst_addr:		target IP address
+ * @non_blocking:	blocking or non-blocking call
+ *
+ * Initiates a TCP/IP connection to the dst_addr
+ */
+static struct iscsi_endpoint *cxgb3i_ep_connect(struct sockaddr *dst_addr,
+						int non_blocking)
+{
+	struct iscsi_endpoint *ep;
+	struct cxgb3i_endpoint *cep;
+	struct cxgb3i_hba *hba;
+	struct socket *sock;
+	struct sock *sk;
+	struct tcp_sock *tp;
+	int err;
+
+	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (err < 0)
+		return NULL;
+	sk = sock->sk;
+
+	sk->sk_allocation = GFP_ATOMIC;
+	sk->sk_reuse = 1;
+	tp = tcp_sk(sk);
+	tp->nonagle |= TCP_NAGLE_OFF;
+	err = cxgb3i_tcp_connect(sock, dst_addr, sizeof(struct sockaddr),
+				 ULP_MODE_ISCSI);
+	if (err < 0) {
+		cxgb3i_log_info("sock 0x%p, connect failed %d.\n", sock, err);
+		goto release_sock;
+	}
+	if (!c3cn_flag(sock->sk, C3CN_OFFLOADED)) {
+		cxgb3i_log_info("sock 0x%p, NOT offloaded.\n", sock);
+		goto release_sock;
+	}
+	if (C3CN_ULP_MODE(sk) != ULP_MODE_ISCSI) {
+		cxgb3i_log_info("sock 0x%p, mode 0x%x, NOT expected.\n",
+				sock, C3CN_ULP_MODE(sk));
+		goto release_sock;
+	}
+	hba = cxgb3i_hba_find_by_netdev(__sk_dst_get(sk)->dev);
+	if (!hba) {
+		cxgb3i_log_info("NOT going through cxgbi device.\n");
+		goto release_sock;
+	}
+
+	ep = iscsi_create_endpoint(sizeof(*cep));
+	if (!ep) {
+		cxgb3i_log_info("iscsi alloc ep, OOM.\n");
+		goto release_sock;
+	}
+	cep = ep->dd_data;
+	cep->sock = sock;
+	cep->hba = hba;
+
+	cxgb3i_log_debug("sock 0x%p, iscsi_ep 0x%p, cxgb_ep 0x%p, hba 0x%p.\n",
+			 sock, ep, cep, hba);
+	return ep;
+
+release_sock:
+	sock_release(sock);
+	return NULL;
+}
+
+/**
+ * cxgb3i_ep_poll - polls for TCP connection establishement
+ * @ep:		TCP connection (endpoint) handle
+ * @timeout_ms:	timeout value in milli secs
+ *
+ * polls for TCP connect request to complete
+ */
+static int cxgb3i_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
+{
+	return 1;
+}
+
+/**
+ * cxgb3i_ep_disconnect - teardown TCP connection
+ * @ep:		TCP connection (endpoint) handle
+ *
+ * teardown TCP connection
+ */
+static void cxgb3i_ep_disconnect(struct iscsi_endpoint *ep)
+{
+	struct cxgb3i_endpoint *cep = (struct cxgb3i_endpoint *)ep->dd_data;
+	struct cxgb3i_conn *cconn = cep->cconn;
+
+	cxgb3i_log_debug("ep 0x%p, cep 0x%p.\n", ep, cep);
+
+	if (cconn && cconn->conn) {
+		struct iscsi_conn *conn = cconn->conn;
+		struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+		cxgb3i_sk_restore_callbacks(cep->sock->sk, conn);
+		write_lock_bh(&cep->sock->sk->sk_callback_lock);
+		set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
+		cconn->cep = NULL;
+		tcp_conn->sock = NULL;
+		write_unlock_bh(&cep->sock->sk->sk_callback_lock);
+	}
+
+	sock_release(cep->sock);
+	iscsi_destroy_endpoint(ep);
+}
+
+/**
+ * cxgb3i_session_create - create a new iscsi session
+ * @cmds_max:		max # of commands
+ * @qdepth:		scsi queue depth
+ * @initial_cmdsn:	initial iscsi CMDSN for this session
+ * @host_no:		pointer to return host no
+ *
+ * Creates a new iSCSI session
+ */
+static struct iscsi_cls_session *cxgb3i_session_create(struct iscsi_endpoint
+						       *ep, uint16_t cmds_max,
+						       uint16_t qdepth,
+						       uint32_t initial_cmdsn,
+						       uint32_t *host_no)
+{
+	struct cxgb3i_endpoint *cep;
+	struct cxgb3i_hba *hba;
+	struct Scsi_Host *shost;
+	struct iscsi_cls_session *cls_session;
+	struct iscsi_session *session;
+	int i;
+
+	if (!ep) {
+		cxgb3i_log_error("%s, missing endpoint.\n", __func__);
+		return NULL;
+	}
+
+	cep = (struct cxgb3i_endpoint *)ep->dd_data;
+	hba = cep->hba;
+	shost = hba->shost;
+	cxgb3i_log_debug("ep 0x%p, cep 0x%p, hba 0x%p.\n", ep, cep, hba);
+	BUG_ON(hba != iscsi_host_priv(shost));
+
+	*host_no = shost->host_no;
+
+	cls_session = iscsi_session_setup(&cxgb3i_iscsi_transport, shost,
+					  cmds_max,
+					  sizeof(struct iscsi_tcp_task),
+					  initial_cmdsn, ISCSI_MAX_TARGET);
+	if (!cls_session)
+		return NULL;
+
+	session = cls_session->dd_data;
+
+	for (i = 0; i < session->cmds_max; i++) {
+		struct iscsi_task *task = session->cmds[i];
+		struct iscsi_tcp_task *tcp_task = task->dd_data;
+
+		task->hdr = &tcp_task->hdr.cmd_hdr;
+		task->hdr_max = sizeof(tcp_task->hdr) - ISCSI_DIGEST_SIZE;
+	}
+
+	if (iscsi_r2tpool_alloc(session))
+		goto remove_session;
+
+	return cls_session;
+
+remove_session:
+	iscsi_session_teardown(cls_session);
+	return NULL;
+}
+
+/**
+ * cxgb3i_session_destroy - destroys iscsi session
+ * @cls_session:	pointer to iscsi cls session
+ *
+ * Destroys an iSCSI session instance and releases its all resources held
+ */
+static void cxgb3i_session_destroy(struct iscsi_cls_session *cls_session)
+{
+	cxgb3i_log_debug("sess 0x%p.\n", cls_session);
+	iscsi_r2tpool_free(cls_session->dd_data);
+	iscsi_session_teardown(cls_session);
+}
+
+/**
+ * cxgb3i_conn_create - create iscsi connection instance
+ * @cls_session:	pointer to iscsi cls session
+ * @cid:		iscsi cid
+ *
+ * Creates a new iSCSI connection instance for a given session
+ */
+static struct iscsi_cls_conn *cxgb3i_conn_create(struct iscsi_cls_session
+						 *cls_session, uint32_t cid)
+{
+	struct iscsi_cls_conn *cls_conn;
+	struct iscsi_conn *conn;
+	struct iscsi_tcp_conn *tcp_conn;
+	struct cxgb3i_conn *cconn;
+
+	cxgb3i_log_debug("sess 0x%p, cid %u.\n", cls_session, cid);
+
+	cls_conn = iscsi_conn_setup(cls_session,
+				    sizeof(*tcp_conn) + sizeof(*cconn), cid);
+	if (!cls_conn)
+		return NULL;
+	conn = cls_conn->dd_data;
+
+	conn->max_recv_dlength = ISCSI_DEF_MAX_RECV_SEG_LEN;
+
+	tcp_conn = conn->dd_data;
+	tcp_conn->iscsi_conn = conn;
+
+	cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	cconn->conn = conn;
+
+	return cls_conn;
+}
+
+/**
+ * cxgb3i_conn_bind - binds iscsi sess, conn and endpoint together
+ * @cls_session:	pointer to iscsi cls session
+ * @cls_conn:		pointer to iscsi cls conn
+ * @transport_eph:	64-bit EP handle
+ * @is_leading:		leading connection on this session?
+ *
+ * Binds together an iSCSI session, an iSCSI connection and a
+ *	TCP connection. This routine returns error code if the TCP
+ *	connection does not belong on the device iSCSI sess/conn is bound
+ */
+
+static int cxgb3i_conn_bind(struct iscsi_cls_session *cls_session,
+			    struct iscsi_cls_conn *cls_conn,
+			    uint64_t transport_eph, int is_leading)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	struct iscsi_endpoint *ep;
+	struct cxgb3i_endpoint *cep;
+	struct socket *sock;
+	int err;
+
+	ep = iscsi_lookup_endpoint(transport_eph);
+	if (!ep)
+		return -EINVAL;
+
+	cxgb3i_log_debug("ep 0x%p, cls sess 0x%p, cls conn 0x%p.\n",
+			 ep, cls_session, cls_conn);
+
+	err = iscsi_conn_bind(cls_session, cls_conn, is_leading);
+	if (err)
+		return -EINVAL;
+
+	cep = (struct cxgb3i_endpoint *)ep->dd_data;
+	sock = cep->sock;
+
+	tcp_conn->sock = sock;
+	cconn->hba = cep->hba;
+	cconn->cep = cep;
+	cep->cconn = cconn;
+
+	spin_lock_bh(&conn->session->lock);
+	sprintf(conn->portal_address, NIPQUAD_FMT,
+		NIPQUAD(inet_sk(sock->sk)->daddr));
+	conn->portal_port = ntohs(inet_sk(sock->sk)->dport);
+	spin_unlock_bh(&conn->session->lock);
+
+	cxgb3i_sk_set_callbacks(sock->sk, conn);
+	iscsi_tcp_hdr_recv_prep(tcp_conn);
+
+	return 0;
+}
+
+/**
+ * cxgb3i_conn_flush - flush tx
+ * @conn:	pointer to iscsi conn
+ */
+static int cxgb3i_conn_flush(struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct iscsi_segment *segment = &tcp_conn->out.segment;
+
+	if (segment->total_copied < segment->total_size)
+		return cxgb3i_conn_ulp2_xmit(conn);
+	return 0;
+}
+
+/**
+ * cxgb3i_conn_get_param - return iscsi connection parameter to caller
+ * @cls_conn:	pointer to iscsi cls conn
+ * @param:	parameter type identifier
+ * @buf:	buffer pointer
+ *
+ * returns iSCSI connection parameters
+ */
+static int cxgb3i_conn_get_param(struct iscsi_cls_conn *cls_conn,
+				 enum iscsi_param param, char *buf)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	int len;
+
+	cxgb3i_log_debug("cls_conn 0x%p, param %d.\n", cls_conn, param);
+
+	switch (param) {
+	case ISCSI_PARAM_CONN_PORT:
+		spin_lock_bh(&conn->session->lock);
+		len = sprintf(buf, "%hu\n", conn->portal_port);
+		spin_unlock_bh(&conn->session->lock);
+		break;
+	case ISCSI_PARAM_CONN_ADDRESS:
+		spin_lock_bh(&conn->session->lock);
+		len = sprintf(buf, "%s\n", conn->portal_address);
+		spin_unlock_bh(&conn->session->lock);
+		break;
+	default:
+		return iscsi_conn_get_param(cls_conn, param, buf);
+	}
+
+	return len;
+}
+
+static int cxgb3i_conn_set_param(struct iscsi_cls_conn *cls_conn,
+				 enum iscsi_param param, char *buf, int buflen)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	int value, err = 0;
+
+	switch (param) {
+	case ISCSI_PARAM_HDRDGST_EN:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && conn->hdrdgst_en)
+			cxgb3i_conn_ulp_setup(cconn, conn->hdrdgst_en,
+					      conn->datadgst_en);
+		break;
+	case ISCSI_PARAM_DATADGST_EN:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && conn->datadgst_en)
+			cxgb3i_conn_ulp_setup(cconn, conn->hdrdgst_en,
+					      conn->datadgst_en);
+		break;
+	case ISCSI_PARAM_MAX_R2T:
+		sscanf(buf, "%d", &value);
+		if (value <= 0 || !is_power_of_2(value))
+			return -EINVAL;
+		if (session->max_r2t == value)
+			break;
+		iscsi_r2tpool_free(session);
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		if (!err && iscsi_r2tpool_alloc(session))
+			return -ENOMEM;
+	case ISCSI_PARAM_MAX_RECV_DLENGTH:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		cxgb3i_log_debug("MAX_RECV %u.\n", conn->max_recv_dlength);
+		break;
+	case ISCSI_PARAM_MAX_XMIT_DLENGTH:
+		err = iscsi_set_param(cls_conn, param, buf, buflen);
+		cxgb3i_log_debug("MAX_XMIT %u.\n", conn->max_xmit_dlength);
+		break;
+	default:
+		return iscsi_set_param(cls_conn, param, buf, buflen);
+	}
+	return err;
+}
+
+/**
+ * cxgb3i_host_get_param - returns host (adapter) related parameters
+ * @shost:	scsi host pointer
+ * @param:	parameter type identifier
+ * @buf:	buffer pointer
+ */
+static int cxgb3i_host_get_param(struct Scsi_Host *shost,
+				 enum iscsi_host_param param, char *buf)
+{
+	struct cxgb3i_hba *hba = iscsi_host_priv(shost);
+	int i;
+	int len = 0;
+
+	switch (param) {
+	case ISCSI_HOST_PARAM_HWADDRESS:
+		for (i = 0; i < 6; i++)
+			len +=
+			    sprintf(buf + len, "%02x.",
+				    hba->ndev->dev_addr[i]);
+		len--;
+		buf[len] = '\0';
+		break;
+	case ISCSI_HOST_PARAM_NETDEV_NAME:
+		len = sprintf(buf, "%s\n", hba->ndev->name);
+		break;
+	default:
+		return iscsi_host_get_param(shost, param, buf);
+	}
+	return len;
+}
+
+/**
+ * cxgb3i_conn_get_stats - returns iSCSI stats
+ * @cls_conn:	pointer to iscsi cls conn
+ * @stats:	pointer to iscsi statistic struct
+ */
+static void cxgb3i_conn_get_stats(struct iscsi_cls_conn *cls_conn,
+				  struct iscsi_stats *stats)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+
+	stats->txdata_octets = conn->txdata_octets;
+	stats->rxdata_octets = conn->rxdata_octets;
+	stats->scsicmd_pdus = conn->scsicmd_pdus_cnt;
+	stats->dataout_pdus = conn->dataout_pdus_cnt;
+	stats->scsirsp_pdus = conn->scsirsp_pdus_cnt;
+	stats->datain_pdus = conn->datain_pdus_cnt;
+	stats->r2t_pdus = conn->r2t_pdus_cnt;
+	stats->tmfcmd_pdus = conn->tmfcmd_pdus_cnt;
+	stats->tmfrsp_pdus = conn->tmfrsp_pdus_cnt;
+	stats->digest_err = 0;
+	stats->timeout_err = 0;
+	stats->custom_length = 1;
+	strcpy(stats->custom[0].desc, "eh_abort_cnt");
+	stats->custom[0].value = conn->eh_abort_cnt;
+}
+
+static inline u32 tag_base(struct cxgb3i_tag_format *format,
+			   unsigned int idx, unsigned int age)
+{
+	u32 sw_bits = idx | (age << format->idx_bits);
+	u32 tag = sw_bits >> format->rsvd_shift;
+	tag <<= format->rsvd_bits + format->rsvd_shift;
+	tag |= sw_bits & ((1 << format->rsvd_shift) - 1);
+	return tag;
+}
+
+static void cxgb3i_parse_itt(struct iscsi_conn *conn, itt_t itt,
+			     int *idx, int *age)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	struct cxgb3i_adapter *snic = cconn->hba->snic;
+	u32 sw_bits;
+
+	cxgb3i_parse_tag(&snic->tag_format, itt, NULL, &sw_bits);
+	if (idx)
+		*idx = sw_bits & ISCSI_ITT_MASK;
+	if (age)
+		*age = (sw_bits >> snic->tag_format.idx_bits) & ISCSI_AGE_MASK;
+}
+
+static int cxgb3i_reserve_itt(struct iscsi_task *task, itt_t *hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_session *sess = conn->session;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	struct cxgb3i_adapter *snic = cconn->hba->snic;
+	u32 sw_tag = tag_base(&snic->tag_format, task->itt, sess->age);
+	u32 tag = RESERVED_ITT;
+
+	if (sc && (sc->sc_data_direction == DMA_FROM_DEVICE)) {
+		struct cxgb3i_tcp_conn *c3cn =
+		    CXGB3_TCP_CONN(tcp_conn->sock->sk);
+		tag =
+		    cxgb3i_ddp_tag_reserve(snic, c3cn->tid, sw_tag,
+					   scsi_out(sc)->length,
+					   scsi_out(sc)->table.sgl,
+					   scsi_out(sc)->table.nents);
+	}
+	if (tag == RESERVED_ITT)
+		tag = sw_tag | (snic->tag_format.rsvd_mask <<
+				snic->tag_format.rsvd_shift);
+	*hdr_itt = htonl(tag);
+	return 0;
+}
+
+static void cxgb3i_release_itt(struct iscsi_task *task, itt_t hdr_itt)
+{
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);
+	struct cxgb3i_adapter *snic = cconn->hba->snic;
+
+	hdr_itt = ntohl(hdr_itt);
+	if (sc && (sc->sc_data_direction == DMA_FROM_DEVICE))
+		cxgb3i_ddp_tag_release(snic, hdr_itt,
+				       scsi_out(sc)->table.sgl,
+				       scsi_out(sc)->table.nents);
+}
+
+/**
+ * cxgb3i_host_template -- Scsi_Host_Template structure
+ *	used when registering with the scsi mid layer
+ */
+static struct scsi_host_template cxgb3i_host_template = {
+	.module = THIS_MODULE,
+	.name = "Chelsio S3xx iSCSI Initiator",
+	.proc_name = "cxgb3i",
+	.queuecommand = iscsi_queuecommand,
+	.change_queue_depth = iscsi_change_queue_depth,
+	.can_queue = 128 * (ISCSI_DEF_XMIT_CMDS_MAX - 1),
+	.sg_tablesize = SG_ALL,
+	.max_sectors = 0xFFFF,
+	.cmd_per_lun = ISCSI_DEF_CMD_PER_LUN,
+	.eh_abort_handler = iscsi_eh_abort,
+	.eh_device_reset_handler = iscsi_eh_device_reset,
+	.eh_target_reset_handler = iscsi_eh_target_reset,
+	.use_clustering = DISABLE_CLUSTERING,
+	.slave_alloc = iscsi_slave_alloc,
+	.this_id = -1,
+};
+
+static struct iscsi_transport cxgb3i_iscsi_transport = {
+	.owner = THIS_MODULE,
+	.name = "cxgb3i",
+	.caps = CAP_RECOVERY_L0 | CAP_MULTI_R2T | CAP_HDRDGST
+	    | CAP_DATADGST | CAP_DIGEST_OFFLOAD,
+	.param_mask = ISCSI_MAX_RECV_DLENGTH |
+	    ISCSI_MAX_XMIT_DLENGTH |
+	    ISCSI_HDRDGST_EN |
+	    ISCSI_DATADGST_EN |
+	    ISCSI_INITIAL_R2T_EN |
+	    ISCSI_MAX_R2T |
+	    ISCSI_IMM_DATA_EN |
+	    ISCSI_FIRST_BURST |
+	    ISCSI_MAX_BURST |
+	    ISCSI_PDU_INORDER_EN |
+	    ISCSI_DATASEQ_INORDER_EN |
+	    ISCSI_ERL |
+	    ISCSI_CONN_PORT |
+	    ISCSI_CONN_ADDRESS |
+	    ISCSI_EXP_STATSN |
+	    ISCSI_PERSISTENT_PORT |
+	    ISCSI_PERSISTENT_ADDRESS |
+	    ISCSI_TARGET_NAME | ISCSI_TPGT |
+	    ISCSI_USERNAME | ISCSI_PASSWORD |
+	    ISCSI_USERNAME_IN | ISCSI_PASSWORD_IN |
+	    ISCSI_FAST_ABORT | ISCSI_ABORT_TMO |
+	    ISCSI_LU_RESET_TMO |
+	    ISCSI_PING_TMO | ISCSI_RECV_TMO |
+	    ISCSI_IFACE_NAME | ISCSI_INITIATOR_NAME,
+	.host_param_mask = ISCSI_HOST_HWADDRESS | ISCSI_HOST_IPADDRESS |
+	    ISCSI_HOST_INITIATOR_NAME | ISCSI_HOST_NETDEV_NAME,
+	.get_host_param = cxgb3i_host_get_param,
+	/* session management */
+	.create_session = cxgb3i_session_create,
+	.destroy_session = cxgb3i_session_destroy,
+	.get_session_param = iscsi_session_get_param,
+	/* connection management */
+	.create_conn = cxgb3i_conn_create,
+	.bind_conn = cxgb3i_conn_bind,
+	.destroy_conn = iscsi_conn_teardown,
+	.start_conn = iscsi_conn_start,
+	.stop_conn = iscsi_conn_stop,
+	.flush_conn = cxgb3i_conn_flush,
+	.get_conn_param = cxgb3i_conn_get_param,
+	.set_param = cxgb3i_conn_set_param,
+	.get_stats = cxgb3i_conn_get_stats,
+	/* pdu xmit req. from user space */
+	.send_pdu = iscsi_conn_send_pdu,
+	/* task */
+	.init_task = iscsi_tcp_task_init,
+	.xmit_task = iscsi_tcp_task_xmit,
+	.cleanup_task = iscsi_tcp_cleanup_task,
+	.parse_itt = cxgb3i_parse_itt,
+	.reserve_itt = cxgb3i_reserve_itt,
+	.release_itt = cxgb3i_release_itt,
+	/* TCP connect/disconnect */
+	.ep_connect = cxgb3i_ep_connect,
+	.ep_poll = cxgb3i_ep_poll,
+	.ep_disconnect = cxgb3i_ep_disconnect,
+	/* Error recovery timeout call */
+	.session_recovery_timedout = iscsi_session_recovery_timedout,
+};
+
+int cxgb3i_iscsi_init(void)
+{
+	cxgb3i_scsi_transport =
+	    iscsi_register_transport(&cxgb3i_iscsi_transport);
+	if (!cxgb3i_scsi_transport) {
+		cxgb3i_log_error("Could not register cxgb3i transport.\n");
+		return -ENODEV;
+	}
+	cxgb3i_log_debug("cxgb3i transport 0x%p.\n", cxgb3i_scsi_transport);
+	return 0;
+}
+
+void cxgb3i_iscsi_cleanup(void)
+{
+	if (cxgb3i_scsi_transport) {
+		cxgb3i_log_debug("cxgb3i transport 0x%p.\n",
+				 cxgb3i_scsi_transport);
+		iscsi_unregister_transport(&cxgb3i_iscsi_transport);
+		cxgb3i_scsi_transport = NULL;
+	}
+}
diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.c b/drivers/scsi/cxgb3i/cxgb3i_offload.c
new file mode 100644
index 0000000..9e80311
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.c
@@ -0,0 +1,2808 @@
+/*
+ * Copyright (C) 2003-2008 Chelsio Communications.  All rights reserved.
+ *
+ * Written by Dimitris Michailidis (dm@chelsio.com)
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the LICENSE file included in this
+ * release for licensing terms and conditions.
+ */
+
+#include <linux/kallsyms.h>
+#include <linux/if_vlan.h>
+#include <linux/inet_diag.h>
+#include <linux/version.h>
+
+#ifdef CONFIG_SECURITY_NETWORK
+#include <linux/security.h>
+#endif
+
+#include "cxgb3_defs.h"
+#include "cxgb3_ctl_defs.h"
+#include "firmware_exports.h"
+#include "cxgb3i_offload.h"
+#include "cxgb3i_ulp2.h"
+
+#define VALIDATE_SEQ 1
+
+typedef int (cxgb3_cpl_handler_decl) (struct t3cdev *,
+				      struct sk_buff *, void *);
+
+static cxgb3_cpl_handler_decl do_bad_cpl;
+static cxgb3_cpl_handler_decl do_act_establish;
+static cxgb3_cpl_handler_decl do_act_open_rpl;
+static cxgb3_cpl_handler_decl do_wr_ack;
+static cxgb3_cpl_handler_decl do_peer_close;
+static cxgb3_cpl_handler_decl do_abort_req;
+static cxgb3_cpl_handler_decl do_abort_rpl;
+static cxgb3_cpl_handler_decl do_close_con_rpl;
+static cxgb3_cpl_handler_decl do_iscsi_hdr;
+
+static struct cxgb3i_tcp_tunables default_cxgb3i_tcp_tunables = {
+	.max_host_sndbuf = 32 * 1024,
+	.max_wrs = 15,
+	.rx_credit_thres = 10 * 1024,
+	.cong_alg = -1,
+	.delack = 1,
+	.tcp_window_scaling = 1,
+};
+
+/*
+ * Protocol structure and functions for our sockets.
+ */
+static struct proto t3_tcp_prot;
+static void chelsio_close(struct sock *, long);
+static int chelsio_disconnect(struct sock *, int);
+static int chelsio_destroy(struct sock *);
+static void process_deferq(struct work_struct *);
+
+static LIST_HEAD(cxgb3_list);
+static DECLARE_MUTEX(cxgb3_list_lock);
+
+/*
+ * For ULP connections HW may add headers, e.g., for digests, that aren't part
+ * of the messages sent by the host but that are part of the TCP payload and
+ * therefore consume TCP sequence space.  Tx connection parameters that
+ * operate in TCP sequence space are affected by the HW additions and need to
+ * compensate for them to accurately track TCP sequence numbers. This array
+ * contains the compensating extra lengths for ULP packets.  It is indexed by
+ * a packet's ULP submode.
+ */
+static const unsigned int cxgb3_ulp_extra_len[] = { 0, 4, 4, 8 };
+
+/*
+ * Return the length of any HW additions that will be made to a Tx packet.
+ * Such additions can happen for some types of ULP packets.
+ */
+static inline unsigned int ulp_extra_len(const struct sk_buff *skb)
+{
+	return cxgb3_ulp_extra_len[skb_ulp_mode(skb) & 3];
+}
+
+/*
+ * Size of WRs in bytes.  Note that we assume all devices we are handling have
+ * the same WR size.
+ */
+static unsigned int wrlen __read_mostly;
+
+/*
+ * The number of WRs needed for an skb depends on the number of page fragments
+ * in the skb and whether it has any payload in its main body.  This maps the
+ * length of the gather list represented by an skb into the # of necessary WRs.
+ */
+static unsigned int skb_wrs[MAX_SKB_FRAGS + 2] __read_mostly;
+
+static void t3_init_wr_tab(unsigned int wr_len)
+{
+	int i;
+
+	if (skb_wrs[1])		/* already initialized */
+		return;
+
+	for (i = 1; i < ARRAY_SIZE(skb_wrs); i++) {
+		int sgl_len = (3 * i) / 2 + (i & 1);
+
+		sgl_len += 3;
+		skb_wrs[i] = (sgl_len <= wr_len
+			      ? 1 : 1 + (sgl_len - 2) / (wr_len - 1));
+	}
+
+	wrlen = wr_len * 8;
+}
+
+/*
+ * TOE information returned through inet_diag for offloaded connections.
+ */
+struct t3_inet_diag_info {
+	u32 toe_id;
+	u32 tid;
+	u16 wrs;
+	u8 ulp_mode:4;
+	u8 sched_class:4;
+	u8 ddp_enabled;
+	char dev_name[T3CNAMSIZ];
+};
+
+/*
+ * Socket filter that drops everything by specifying a 0-length filter program.
+ */
+static struct sk_filter drop_all = {.refcnt = ATOMIC_INIT(1) };
+
+/*
+ * This sk_buff holds a fake header-only TCP segment that we use whenever we
+ * need to exploit SW TCP functionality that expects TCP headers, such as
+ * tcp_create_openreq_child().  It's a RO buffer that may be used by multiple
+ * CPUs without locking.
+ */
+static struct sk_buff *tcphdr_skb __read_mostly;
+
+/*
+ * Initialize state for cxgb3 API operations.
+ */
+int cxgb3i_tcp_init(cxgb3_cpl_handler_func *cpl_handlers)
+{
+	int i;
+
+	/*
+	 * Instialize protocol structure for our sockets.  We first copy
+	 * the standard TCP protocol structure so we end up with standard
+	 * values for things like pointers to counters, etc.
+	 */
+	t3_tcp_prot = tcp_prot;
+	t3_tcp_prot.close = chelsio_close;
+	t3_tcp_prot.disconnect = chelsio_disconnect;
+	t3_tcp_prot.destroy = chelsio_destroy;
+
+	tcphdr_skb = alloc_skb(sizeof(struct tcphdr), GFP_KERNEL);
+	if (!tcphdr_skb) {
+		printk(KERN_ERR
+		       "Chelsio TCP offload: can't allocate sk_buff\n");
+		return -1;
+	}
+	skb_put(tcphdr_skb, sizeof(struct tcphdr));
+	skb_reset_transport_header(tcphdr_skb);
+	memset(tcphdr_skb->data, 0, tcphdr_skb->len);
+	/* CIPSO_V4_OPTEXIST is false for tcphdr_skb without anything extra */
+
+	for (i = 0; i < NUM_CPL_CMDS; i++)
+		cpl_handlers[i] = do_bad_cpl;
+
+	cpl_handlers[CPL_ACT_ESTABLISH] = do_act_establish;
+	cpl_handlers[CPL_ACT_OPEN_RPL] = do_act_open_rpl;
+	cpl_handlers[CPL_PEER_CLOSE] = do_peer_close;
+	cpl_handlers[CPL_ABORT_REQ_RSS] = do_abort_req;
+	cpl_handlers[CPL_ABORT_RPL_RSS] = do_abort_rpl;
+	cpl_handlers[CPL_CLOSE_CON_RPL] = do_close_con_rpl;
+	cpl_handlers[CPL_TX_DMA_ACK] = do_wr_ack;
+	cpl_handlers[CPL_ISCSI_HDR] = do_iscsi_hdr;
+
+	return 0;
+}
+
+void cxgb3i_tcp_add(struct t3cdev *cdev, struct cxgb3_client *client)
+{
+	struct cxgb3i_tcp_data *cdata;
+	struct adap_ports *ports;
+	struct ofld_page_info rx_page_info;
+	unsigned int wr_len;
+	int i;
+
+	cdata = kzalloc(sizeof *cdata, GFP_KERNEL);
+	if (!cdata)
+		return;
+	ports = kzalloc(sizeof *ports, GFP_KERNEL);
+	if (!ports) {
+		kfree(cdata);
+		return;
+	}
+	cdata->ports = ports;
+
+	if (cdev->ctl(cdev, GET_WR_LEN, &wr_len) < 0 ||
+	    cdev->ctl(cdev, GET_PORTS, cdata->ports) < 0 ||
+	    cdev->ctl(cdev, GET_RX_PAGE_INFO, &rx_page_info) < 0) {
+		kfree(ports);
+		kfree(cdata);
+		return;
+	}
+
+	t3_init_wr_tab(wr_len);
+
+	INIT_LIST_HEAD(&cdata->list);
+	cdata->cdev = cdev;
+	cdata->client = client;
+	cdata->rx_page_size = rx_page_info.page_size;
+	cdata->conf = default_cxgb3i_tcp_tunables;
+	cdata->conf.max_wrs = T3C_DATA(cdev)->max_wrs;
+	skb_queue_head_init(&cdata->deferq);
+	INIT_WORK(&cdata->deferq_task, process_deferq);
+
+	for (i = 0; i < ports->nports; i++)
+		NDEV2CDATA(ports->lldevs[i]) = cdata;
+
+	down(&cxgb3_list_lock);
+	list_add_tail(&cdata->list, &cxgb3_list);
+	up(&cxgb3_list_lock);
+
+	return;
+}
+
+void cxgb3i_tcp_remove(struct t3cdev *cdev)
+{
+	struct cxgb3i_tcp_data *cdata = CXGB3_TCP_DATA(cdev);
+	struct adap_ports *ports = cdata->ports;
+	int i;
+
+	for (i = 0; i < ports->nports; i++)
+		NDEV2CDATA(ports->lldevs[i]) = NULL;
+
+	down(&cxgb3_list_lock);
+	list_del(&cdata->list);
+	up(&cxgb3_list_lock);
+
+	kfree(ports);
+	kfree(cdata);
+}
+
+/*
+ * Return TRUE if the specified net device is for a port on one of our
+ * registered adapters.
+ */
+static int is_cxgb3_dev(struct net_device *dev)
+{
+	struct cxgb3i_tcp_data *cdata;
+
+	down(&cxgb3_list_lock);
+	list_for_each_entry(cdata, &cxgb3_list, list) {
+		struct adap_ports *ports = cdata->ports;
+		int i;
+
+		for (i = 0; i < ports->nports; i++)
+			if (dev == ports->lldevs[i]) {
+				up(&cxgb3_list_lock);
+				return 1;
+			}
+	}
+	up(&cxgb3_list_lock);
+	return 0;
+}
+
+/*
+ * Primary cxgb3 API operations.
+ * =============================
+ */
+
+static int tcp_v4_connect_offload(struct sock *, struct sockaddr *, int);
+static void t3_cleanup_rbuf(struct sock *, int);
+static int t3_push_frames(struct sock *, int);
+static int t3_send_reset(struct sock *, int, struct sk_buff *);
+static int t3_sendskb(struct sock *, struct sk_buff *, int);
+
+/*
+ * Return connected socket to specified endpoint.
+ */
+int cxgb3i_tcp_connect(struct socket *sock, struct sockaddr *uaddr,
+		       int addr_len, int ulp_mode)
+{
+	struct sock *sk;
+	struct cxgb3i_tcp_conn *c3cn;
+	int ret;
+
+	c3cn = kzalloc(sizeof(*c3cn), GFP_KERNEL);
+	if (c3cn == NULL)
+		return -ENOMEM;
+	c3cn->flags = 0;
+	c3cn->ulp_mode = ulp_mode;
+
+	sk = sock->sk;
+	CXGB3_TCP_CONN(sk) = c3cn;
+
+	ret = tcp_v4_connect_offload(sk, uaddr, addr_len);
+	if (ret) {
+		CXGB3_TCP_CONN(sk) = NULL;
+		kfree(c3cn);
+	}
+	return ret;
+}
+
+void cxgb3i_tcp_cleanup_rbuf(struct sock *sk, int copied)
+{
+	t3_cleanup_rbuf(sk, copied);
+	return;
+}
+
+int cxgb3i_tcp_sendskb(struct sock *sk, struct sk_buff *skb, int flags)
+{
+	return t3_sendskb(sk, skb, flags);
+}
+
+/*
+ * Protocol operations.
+ * ====================
+ */
+
+static int make_close_transition(struct sock *);
+static void close_conn(struct sock *);
+static void t3_purge_write_queue(struct sock *);
+
+/*
+ * Release a socket's local TCP port if the socket is bound.  This is normally
+ * done by tcp_done() but because we need to wait for HW to release TIDs we
+ * usually call tcp_done at a later time than the SW stack would have.  This
+ * can be used to release the port earlier so the SW stack can reuse it before
+ * we are done with the connection.
+ */
+static inline void release_tcp_port(struct sock *sk)
+{
+	if (inet_csk(sk)->icsk_bind_hash)
+		inet_put_port(sk);
+}
+
+static void chelsio_close(struct sock *sk, long timeout)
+{
+	int data_lost, old_state;
+
+	lock_sock(sk);
+	sk->sk_shutdown |= SHUTDOWN_MASK;
+
+	/*
+	 * We need to flush the receive buffs.  We do this only on the
+	 * descriptor close, not protocol-sourced closes, because the
+	 * reader process may not have drained the data yet!  Make a note
+	 * of whether any received data will be lost so we can decide whether
+	 * to FIN or RST.
+	 */
+	data_lost = skb_queue_len(&sk->sk_receive_queue);
+	__skb_queue_purge(&sk->sk_receive_queue);
+
+	if (sk->sk_state == TCP_CLOSE)	/* Nothing if we are already closed */
+		;
+	else if (data_lost || sk->sk_state == TCP_SYN_SENT) {
+		/* Unread data was tossed, zap the connection. */
+		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONCLOSE);
+		t3_send_reset(sk, CPL_ABORT_SEND_RST, NULL);
+		release_tcp_port(sk);
+		goto unlock;
+	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+		/* Check zero linger _after_ checking for unread data. */
+		sk->sk_prot->disconnect(sk, 0);
+		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONDATA);
+	} else if (make_close_transition(sk)) {	/* Regular FIN-based close */
+		close_conn(sk);
+	}
+
+	if (timeout)
+		sk_stream_wait_close(sk, timeout);
+
+unlock:
+	old_state = sk->sk_state;
+	sock_hold(sk);	/* must last past the potential inet_csk_destroy_sock */
+	sock_orphan(sk);
+	atomic_inc(sk->sk_prot->orphan_count);
+
+	release_sock(sk); /* Final release_sock in connection's lifetime. */
+
+	/*
+	 * There are no more user references at this point.  Grab the socket
+	 * spinlock and finish the close.
+	 */
+	local_bh_disable();
+	bh_lock_sock(sk);
+
+	/*
+	 * Because the socket was orphaned before the bh_lock_sock
+	 * either the backlog or a BH may have already destroyed it.
+	 * Bail out if so.
+	 */
+	if (old_state != TCP_CLOSE && sk->sk_state == TCP_CLOSE)
+		goto out;
+
+	if (sk->sk_state == TCP_FIN_WAIT2 && tcp_sk(sk)->linger2 < 0 &&
+	    !c3cn_flag(sk, C3CN_ABORT_SHUTDOWN)) {
+		struct sk_buff *skb;
+
+		skb = alloc_skb(sizeof(struct cpl_abort_req), GFP_ATOMIC);
+		if (skb) {
+			t3_send_reset(sk, CPL_ABORT_SEND_RST, skb);
+			NET_INC_STATS_BH(LINUX_MIB_TCPABORTONLINGER);
+		}
+	}
+
+	if (sk->sk_state == TCP_CLOSE)
+		inet_csk_destroy_sock(sk);
+
+out:
+	bh_unlock_sock(sk);
+	local_bh_enable();
+	sock_put(sk);
+}
+
+static int chelsio_disconnect(struct sock *sk, int flags)
+{
+	printk(KERN_ERR "chelsio_disconnect not implemented\n");
+	return -ENOTSUPP;
+}
+
+/*
+ * Our version of tcp_v4_destroy_sock().  We need to do this because
+ * tcp_writequeue_purge() that is used in the original doesn't quite match
+ * our needs.  If we ever hook into the memory management of the SW stack we
+ * may be able to use tcp_v4_destroy_sock() directly.
+ */
+static int chelsio_destroy(struct sock *sk)
+{
+	struct cxgb3i_tcp_conn *c3cn;
+
+	C3CN_ULP_MODE(sk) = ULP_MODE_NONE;
+	t3_purge_write_queue(sk);
+	c3cn = CXGB3_TCP_CONN(sk);
+	CXGB3_TCP_CONN(sk) = NULL;
+	kfree(c3cn);
+	return tcp_prot.destroy(sk);
+}
+
+/*
+ * Local utility routines used to implement primary cxgb3 API operations.
+ * ======================================================================
+ */
+
+static int tcp_connect_offload(struct sock *);
+static u32 t3_send_rx_credits(struct sock *, u32, u32, int);
+static void mk_act_open_req(struct sock *, struct sk_buff *,
+			    unsigned int, const struct l2t_entry *);
+static int wait_for_mem(struct sock *, long *);
+static void skb_entail(struct sock *, struct sk_buff *, int);
+
+static inline int is_t3a(const struct t3cdev *cdev)
+{
+	return cdev->type == T3A;
+}
+
+/*
+ * Determine the value of a packet's ->priority field.  Bit 0 determines
+ * whether the packet should use a control Tx queue, bits 1..3 determine
+ * the queue set to use.
+ */
+static inline unsigned int mkprio(unsigned int cntrl, const struct sock *sk)
+{
+	return cntrl;
+}
+
+/*
+ * Returns true if an sk_buff carries urgent data.
+ */
+static inline int skb_urgent(struct sk_buff *skb)
+{
+	return (CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_URG) != 0;
+}
+
+static inline void reset_wr_list(struct tcp_sock *tp)
+{
+	tp->forward_skb_hint = NULL;
+}
+
+/*
+ * Add a WR to a socket's list of pending WRs.  This is a singly-linked list
+ * of sk_buffs operating as a FIFO.  We use the following sock and sk_buff
+ * fields to maintain it:
+ * - sock.forward_skb_hint, sock.retransmit_skb_hint as head and tail pointers
+ * - sk_buff.sp as packet next pointer
+ */
+static inline void enqueue_wr(struct tcp_sock *tp, struct sk_buff *skb)
+{
+	skb->sp = NULL;
+
+	/*
+	 * We want to take an extra reference since both us and the driver
+	 * need to free the packet before it's really freed.  We know there's
+	 * just one user currently so we use atomic_set rather than skb_get
+	 * to avoid the atomic op.
+	 */
+	atomic_set(&skb->users, 2);
+
+	if (!tp->forward_skb_hint)
+		tp->forward_skb_hint = skb;
+	else
+		tp->retransmit_skb_hint->sp = (void *)skb;
+	tp->retransmit_skb_hint = skb;
+}
+
+/* Returns bits 2:7 of a socket's TOS field */
+#define SK_TOS(sk) ((inet_sk(sk)->tos >> 2) & M_TOS)
+
+/*
+ * The next two functions calculate the option 0 value for a socket.
+ */
+static inline unsigned int calc_opt0h(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	return V_NAGLE((tp->nonagle & TCP_NAGLE_OFF) == 0) |
+	    V_KEEP_ALIVE(sock_flag(sk, SOCK_KEEPOPEN) != 0) | F_TCAM_BYPASS |
+	    V_WND_SCALE(tp->rx_opt.rcv_wscale) | V_MSS_IDX(C3CN_MSS_IDX(sk));
+}
+
+static inline unsigned int calc_opt0l(struct sock *sk)
+{
+	unsigned int tos;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tos = SK_TOS(sk);
+	if ((tos & 0x38) == 0x30)	/* suppress values in special range */
+		tos = 0;
+
+	return V_TOS(tos) | V_ULP_MODE(C3CN_ULP_MODE(sk)) |
+	    V_RCV_BUFSIZ(min(tp->rcv_wnd >> 10, (u32) M_RCV_BUFSIZ));
+}
+
+static inline unsigned int calc_opt2(const struct sock *sk)
+{
+	const struct t3cdev *cdev = C3CN_CDEV(sk);
+	int flv_valid = CXGB3_TCP_TUNABLE(cdev, cong_alg) != -1;
+
+	return V_FLAVORS_VALID(flv_valid) |
+	    V_CONG_CONTROL_FLAVOR(flv_valid ? CXGB3_TCP_TUNABLE(cdev, cong_alg)
+				  : 0);
+}
+
+static inline void make_tx_data_wr(struct sock *sk, struct sk_buff *skb,
+				   int len)
+{
+	struct tx_data_wr *req;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	skb_reset_transport_header(skb);
+	req = (struct tx_data_wr *)__skb_push(skb, sizeof(*req));
+	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA));
+	req->wr_lo = htonl(V_WR_TID(C3CN_TID(sk)));
+	req->sndseq = htonl(tp->snd_nxt);
+	/* len includes the length of any HW ULP additions */
+	req->len = htonl(len);
+	req->param = htonl(V_TX_PORT(C3CN_L2T(sk)->smt_idx));
+	/* V_TX_ULP_SUBMODE sets both the mode and submode */
+	req->flags = htonl(V_TX_ULP_SUBMODE(skb_ulp_mode(skb)) |
+			   V_TX_URG(skb_urgent(skb)) |
+			   V_TX_SHOVE((!c3cn_flag(sk, C3CN_TX_MORE_DATA)) &&
+				      (skb_peek(&sk->sk_write_queue) ? 0 : 1)));
+
+	if (!c3cn_flag(sk, C3CN_TX_DATA_SENT)) {
+
+		req->flags |= htonl(V_TX_ACK_PAGES(2) | F_TX_INIT |
+				    V_TX_CPU_IDX(C3CN_QSET(sk)));
+
+		/* Sendbuffer is in units of 32KB.
+		 */
+		req->param |= htonl(V_TX_SNDBUF(sk->sk_sndbuf >> 15));
+		c3cn_set_flag(sk, C3CN_TX_DATA_SENT);
+	}
+}
+
+static int tcp_v4_connect_offload(struct sock *sk,
+				  struct sockaddr *uaddr, int addr_len)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
+	struct rtable *rt;
+	__be32 daddr, nexthop;
+	int tmp;
+	int err;
+
+	if (addr_len < sizeof(struct sockaddr_in))
+		return -EINVAL;
+
+	if (usin->sin_family != AF_INET)
+		return -EAFNOSUPPORT;
+
+	nexthop = daddr = usin->sin_addr.s_addr;
+	if (inet->opt && inet->opt->srr) {
+		if (!daddr)
+			return -EINVAL;
+		nexthop = inet->opt->faddr;
+	}
+
+	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
+			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
+			       IPPROTO_TCP, inet->sport, usin->sin_port, sk, 1);
+	if (tmp < 0) {
+		if (tmp == -ENETUNREACH)
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+		return tmp;
+	}
+
+	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
+		ip_rt_put(rt);
+		return -ENETUNREACH;
+	}
+
+	if (!inet->opt || !inet->opt->srr)
+		daddr = rt->rt_dst;
+
+	if (!inet->saddr)
+		inet->saddr = rt->rt_src;
+	inet->rcv_saddr = inet->saddr;
+
+	if (tp->rx_opt.ts_recent_stamp && inet->daddr != daddr) {
+		/* Reset inherited state */
+		tp->rx_opt.ts_recent = 0;
+		tp->rx_opt.ts_recent_stamp = 0;
+		tp->write_seq = 0;
+	}
+
+	if (tcp_death_row.sysctl_tw_recycle &&
+	    !tp->rx_opt.ts_recent_stamp && rt->rt_dst == daddr) {
+		struct inet_peer *peer = rt->peer;
+		/*
+		 * VJ's idea. We save last timestamp seen from
+		 * the destination in peer table, when entering state
+		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
+		 * when trying new connection.
+		 */
+		if (peer != NULL &&
+		    peer->tcp_ts_stamp + TCP_PAWS_MSL >= get_seconds()) {
+			tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
+			tp->rx_opt.ts_recent = peer->tcp_ts;
+		}
+	}
+
+	inet->dport = usin->sin_port;
+	inet->daddr = daddr;
+
+	inet_csk(sk)->icsk_ext_hdr_len = 0;
+	if (inet->opt)
+		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
+
+	tp->rx_opt.mss_clamp = 536;
+
+	/* Socket identity is still unknown (sport may be zero).
+	 * However we set state to SYN-SENT and not releasing socket
+	 * lock select source port, enter ourselves into the hash tables and
+	 * complete initialization after this.
+	 */
+	tcp_set_state(sk, TCP_SYN_SENT);
+	err = inet_hash_connect(&tcp_death_row, sk);
+	if (err)
+		goto failure;
+
+	err = ip_route_newports(&rt, IPPROTO_TCP, inet->sport, inet->dport, sk);
+	if (err)
+		goto failure;
+
+	/* OK, now commit destination to socket.  */
+	sk->sk_gso_type = SKB_GSO_TCPV4;
+	sk_setup_caps(sk, &rt->u.dst);
+
+	if (tcp_connect_offload(sk))
+		return 0;
+	/*
+	 * If we get here, we don't have an offload connection so simply
+	 * return a failure.
+	 */
+	err = -ENOTSUPP;
+
+failure:
+	/*
+	 * This unhashes the socket and releases the local port,
+	 * if necessary.
+	 */
+	tcp_set_state(sk, TCP_CLOSE);
+	ip_rt_put(rt);
+	sk->sk_route_caps = 0;
+	inet->dport = 0;
+	return err;
+}
+
+static inline int is_delack_mode_valid(struct t3cdev *cdev, struct sock *sk)
+{
+	return (!C3CN_ULP_MODE(sk)
+		|| (C3CN_ULP_MODE(sk) == ULP_MODE_TCPDDP && cdev->type >= T3A));
+}
+
+/*
+ * Set of states for which we should return RX credits.
+ */
+#define CREDIT_RETURN_STATE (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_FIN_WAIT2)
+
+/*
+ * Called after some received data has been read.  It returns RX credits
+ * to the HW for the amount of data processed.
+ */
+static void t3_cleanup_rbuf(struct sock *sk, int copied)
+{
+	struct tcp_sock *tp;
+	struct t3cdev *cdev;
+	int dack_mode, must_send;
+	u32 thres, credits, dack = 0;
+
+	if (!sk_in_state(sk, CREDIT_RETURN_STATE))
+		return;
+
+	tp = tcp_sk(sk);
+	credits = tp->copied_seq - tp->rcv_wup;
+	if (unlikely(!credits))
+		return;
+
+	cdev = C3CN_CDEV(sk);
+	thres = CXGB3_TCP_TUNABLE(cdev, rx_credit_thres);
+
+	if (unlikely(thres == 0))
+		return;
+
+	if (is_delack_mode_valid(cdev, sk)) {
+		dack_mode = CXGB3_TCP_TUNABLE(cdev, delack);
+		if (unlikely(dack_mode != C3CN_DELAK_MODE(sk))) {
+			u32 r = tp->rcv_nxt - C3CN_DELAK_SEQ(sk);
+
+			if (r >= tp->rcv_wnd || r >= 16 * tp->rx_opt.mss_clamp)
+				dack = (F_RX_DACK_CHANGE |
+					V_RX_DACK_MODE(dack_mode));
+		}
+	} else
+		dack = F_RX_DACK_CHANGE | V_RX_DACK_MODE(1);
+
+	/*
+	 * For coalescing to work effectively ensure the receive window has
+	 * at least 16KB left.
+	 */
+	must_send = credits + 16384 >= tp->rcv_wnd;
+
+	if (must_send || credits >= thres)
+		tp->rcv_wup += t3_send_rx_credits(sk, credits, dack, must_send);
+}
+
+/*
+ * Generic ARP failure handler that discards the buffer.
+ */
+static void arp_failure_discard(struct t3cdev *cdev, struct sk_buff *skb)
+{
+	kfree_skb(skb);
+}
+
+/*
+ * Prepends TX_DATA_WR or CPL_CLOSE_CON_REQ headers to buffers waiting in a
+ * socket's send queue and sends them on to the TOE.  Must be called with the
+ * socket lock held.  Returns the amount of send buffer space that was freed
+ * as a result of sending queued data to the TOE.
+ */
+static int t3_push_frames(struct sock *sk, int req_completion)
+{
+	int total_size = 0;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	struct t3cdev *cdev;
+	struct cxgb3i_tcp_data *cdata;
+
+	if (unlikely(sk_in_state(sk, TCPF_SYN_SENT | TCPF_CLOSE)))
+		return 0;
+
+	/*
+	 * We shouldn't really be called at all after an abort but check just
+	 * in case.
+	 */
+	if (unlikely(c3cn_flag(sk, C3CN_ABORT_SHUTDOWN)))
+		return 0;
+
+	cdev = C3CN_CDEV(sk);
+	cdata = CXGB3_TCP_DATA(cdev);
+
+	while (C3CN_WR_AVAIL(sk)
+	       && (skb = skb_peek(&sk->sk_write_queue)) != NULL
+	       && !c3cn_flag(sk, C3CN_TX_WAIT_IDLE)
+	       && (!(CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_HOLD)
+		   || skb_queue_len(&sk->sk_write_queue) > 1)) {
+
+		int len = skb->len;	/* length before skb_push */
+		int frags = skb_shinfo(skb)->nr_frags + (len != skb->data_len);
+		int wrs_needed = skb_wrs[frags];
+
+		if (wrs_needed > 1 && len + sizeof(struct tx_data_wr) <= wrlen)
+			wrs_needed = 1;
+
+		WARN_ON(frags >= ARRAY_SIZE(skb_wrs) || wrs_needed < 1);
+		if (C3CN_WR_AVAIL(sk) < wrs_needed)
+			break;
+
+		__skb_unlink(skb, &sk->sk_write_queue);
+		skb->priority = mkprio(CPL_PRIORITY_DATA, sk);
+		skb->csum = wrs_needed;	/* remember this until the WR_ACK */
+		C3CN_WR_AVAIL(sk) -= wrs_needed;
+		C3CN_WR_UNACKED(sk) += wrs_needed;
+		enqueue_wr(tp, skb);
+
+		if (likely(CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_NEED_HDR)) {
+			len += ulp_extra_len(skb);
+			make_tx_data_wr(sk, skb, len);
+			tp->snd_nxt += len;
+			tp->lsndtime = tcp_time_stamp;
+			if ((req_completion
+			     && C3CN_WR_UNACKED(sk) == wrs_needed)
+			    || (CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_COMPL)
+			    || C3CN_WR_UNACKED(sk) >= C3CN_WR_MAX(sk) / 2) {
+				struct work_request_hdr *wr = cplhdr(skb);
+
+				wr->wr_hi |= htonl(F_WR_COMPL);
+				C3CN_WR_UNACKED(sk) = 0;
+			}
+			CXGB3_TCP_SKB_CB(skb)->flags &= ~C3CB_FLAG_NEED_HDR;
+		} else if (skb->data[0] == FW_WROPCODE_OFLD_CLOSE_CON)
+			c3cn_set_flag(sk, C3CN_CLOSE_CON_REQUESTED);
+
+		total_size += skb->truesize;
+		if (CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_BARRIER)
+			c3cn_set_flag(sk, C3CN_TX_WAIT_IDLE);
+		set_arp_failure_handler(skb, arp_failure_discard);
+		l2t_send(cdev, skb, C3CN_L2T(sk));
+	}
+	sk->sk_wmem_queued -= total_size;
+	return total_size;
+}
+
+/*
+ * Handle an ARP failure for a CPL_ABORT_REQ.  Change it into a no RST variant
+ * and send it along.
+ */
+static void abort_arp_failure(struct t3cdev *cdev, struct sk_buff *skb)
+{
+	struct cpl_abort_req *req = cplhdr(skb);
+
+	req->cmd = CPL_ABORT_NO_RST;
+	cxgb3_ofld_send(cdev, skb);
+}
+
+/*
+ * Send an ABORT_REQ message.  Cannot fail.  This routine makes sure we do
+ * not send multiple ABORT_REQs for the same connection and also that we do
+ * not try to send a message after the connection has closed.  Returns 1 if
+ * an ABORT_REQ wasn't generated after all, 0 otherwise.
+ */
+static int t3_send_reset(struct sock *sk, int mode, struct sk_buff *skb)
+{
+	struct cpl_abort_req *req;
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int tid = C3CN_TID(sk);
+
+	if (unlikely(c3cn_flag(sk, C3CN_ABORT_SHUTDOWN) || !C3CN_CDEV(sk))) {
+		if (skb)
+			__kfree_skb(skb);
+		return 1;
+	}
+
+	c3cn_set_flag(sk, C3CN_ABORT_RPL_PENDING);
+	c3cn_set_flag(sk, C3CN_ABORT_SHUTDOWN);
+
+	/* Purge the send queue so we don't send anything after an abort. */
+	t3_purge_write_queue(sk);
+
+	if (c3cn_flag(sk, C3CN_CLOSE_CON_REQUESTED) && is_t3a(C3CN_CDEV(sk)))
+		mode |= CPL_ABORT_POST_CLOSE_REQ;
+
+	if (!skb)
+		skb = alloc_skb(sizeof(*req), GFP_KERNEL | __GFP_NOFAIL);
+	skb->priority = mkprio(CPL_PRIORITY_DATA, sk);
+	set_arp_failure_handler(skb, abort_arp_failure);
+
+	req = (struct cpl_abort_req *)skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_REQ));
+	req->wr.wr_lo = htonl(V_WR_TID(tid));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ABORT_REQ, tid));
+	req->rsvd0 = htonl(tp->snd_nxt);
+	req->rsvd1 = !c3cn_flag(sk, C3CN_TX_DATA_SENT);
+	req->cmd = mode;
+	if (sk->sk_state == TCP_SYN_SENT)
+		__skb_queue_tail(&tp->out_of_order_queue, skb);
+	else
+		l2t_send(C3CN_CDEV(sk), skb, C3CN_L2T(sk));
+	return 0;
+}
+
+/*
+ * This must be called with the socket locked, otherwise dev may be NULL.
+ */
+static inline int chelsio_wspace(const struct sock *sk)
+{
+	struct t3cdev *dev = C3CN_CDEV(sk);
+
+	return (dev ? (CXGB3_TCP_TUNABLE(dev, max_host_sndbuf)
+		       - sk->sk_wmem_queued)
+		: 0);
+}
+
+static inline int tcp_memory_free(struct sock *sk)
+{
+	return chelsio_wspace(sk) > 0;
+}
+
+/*
+ * Add a list of skbs to a socket send queue.  This interface is intended for
+ * use by in-kernel ULPs.  The skbs must comply with the max size limit of the
+ * device and have a headroom of at least TX_HEADER_LEN bytes.
+ */
+static int t3_sendskb(struct sock *sk, struct sk_buff *skb, int flags)
+{
+	struct sk_buff *next;
+	struct tcp_sock *tp = tcp_sk(sk);
+	int err, copied = 0;
+	long timeo;
+
+	lock_sock(sk);
+	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+
+	if (!sk_in_state(sk, TCPF_ESTABLISHED | TCPF_CLOSE_WAIT) &&
+	    (err = sk_stream_wait_connect(sk, &timeo)) != 0)
+		goto out_err;
+
+	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	err = -EPIPE;
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		goto out_err;
+
+	/*
+	 * We check for send buffer space once for the whole skb list.  It
+	 * isn't critical if we end up overrunning the send buffer limit as we
+	 * do not allocate any new memory.  The benefit is we don't need to
+	 * perform intermediate packet pushes.
+	 */
+	while (!tcp_memory_free(sk)) {
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		err = wait_for_mem(sk, &timeo);
+		if (err)
+			goto out_err;
+	}
+
+	while (skb) {
+		if (unlikely(skb_headroom(skb) < TX_HEADER_LEN)) {
+			err = -EINVAL;
+			goto out_err;
+		}
+
+		next = skb->next;
+		skb->next = NULL;
+		skb_entail(sk, skb, C3CB_FLAG_NO_APPEND | C3CB_FLAG_NEED_HDR);
+		copied += skb->len;
+		tp->write_seq += skb->len + ulp_extra_len(skb);
+		skb = next;
+	}
+done:
+	if (likely(skb_queue_len(&sk->sk_write_queue)))
+		t3_push_frames(sk, 1);
+	release_sock(sk);
+	return copied;
+
+out_err:
+	if (copied == 0)
+		copied = sk_stream_error(sk, flags, err);
+	goto done;
+}
+
+/*
+ * Low-level utility routines for primary API functions.
+ * =====================================================
+ */
+/* routines to implement CPL message processing */
+static void sock_act_establish(struct sock *, struct sk_buff *);
+static void active_open_failed(struct sock *, struct sk_buff *);
+static void wr_ack(struct sock *, struct sk_buff *);
+static void do_peer_fin(struct sock *, struct sk_buff *);
+static void process_abort_req(struct sock *, struct sk_buff *);
+static void process_abort_rpl(struct sock *, struct sk_buff *);
+static void process_close_con_rpl(struct sock *, struct sk_buff *);
+static void process_rx_iscsi_hdr(struct sock *, struct sk_buff *);
+
+static struct sk_buff *__get_cpl_reply_skb(struct sk_buff *, size_t, gfp_t);
+
+static int t3_connect(struct sock *, struct net_device *);
+static void tcp_uncork(struct sock *);
+static void tcp_push(struct sock *, int);
+static void fail_act_open(struct sock *, int);
+static void init_offload_sk(struct sock *, struct t3cdev *, struct dst_entry *);
+static int t3_backlog_rcv(struct sock *, struct sk_buff *);
+static void t3_write_space(struct sock *);
+
+/*
+ * Insert a socket to the TID table and take an extra reference.
+ */
+static inline void sk_insert_tid(struct cxgb3i_tcp_data *cdata, struct sock *sk,
+				 unsigned int tid)
+{
+	sock_hold(sk);
+	cxgb3_insert_tid(cdata->cdev, cdata->client, sk, tid);
+}
+
+static inline void free_atid(struct t3cdev *cdev, unsigned int tid)
+{
+	struct sock *sk = cxgb3_free_atid(cdev, tid);
+	if (sk)
+		sock_put(sk);
+}
+
+/*
+ * This function is intended for allocations of small control messages.
+ * Such messages go as immediate data and usually the pakets are freed
+ * immediately.  We maintain a cache of one small sk_buff and use it whenever
+ * it is available (has a user count of 1).  Otherwise we get a fresh buffer.
+ */
+#define CTRL_SKB_LEN 120
+
+static struct sk_buff *alloc_ctrl_skb(const struct sock *sk, int len)
+{
+	struct sk_buff *skb = C3CN_CTRL_SKB_CACHE(sk);
+
+	if (likely(skb && !skb_shared(skb) && !skb_cloned(skb))) {
+		__skb_trim(skb, 0);
+		atomic_set(&skb->users, 2);
+	} else if (likely(!in_atomic()))
+		skb = alloc_skb(len, GFP_ATOMIC | __GFP_NOFAIL);
+	else
+		skb = alloc_skb(len, GFP_ATOMIC);
+	return skb;
+}
+
+/**
+ * cxgb3_egress_dev - return the cxgb3 egress device or NULL if the egress
+ *     device isn't one of our ports.
+ *
+ * @root_dev: the root device anchoring the search
+ * @sk: the socket used to determine egress port in bonding mode
+ * @context: in bonding mode, indicates a connection set up or failover
+ *
+ * Given a root network device it returns the physical egress device that is a
+ * descendant of the root device.  The root device may be either a physical
+ * device, in which case it is the device returned, or a virtual device, such
+ * as a VLAN or bonding device.  In case of a bonding device the search
+ * considers the decisions of the bonding device given its mode to locate the
+ * correct egress device.
+ */
+static struct net_device *cxgb3_egress_dev(struct net_device *root_dev,
+					   struct sock *sk, int context)
+{
+	while (root_dev) {
+		if (root_dev->priv_flags & IFF_802_1Q_VLAN)
+			root_dev = vlan_dev_info(root_dev)->real_dev;
+		else if (is_cxgb3_dev(root_dev))
+			return root_dev;
+		else
+			return NULL;
+	}
+	return NULL;
+}
+
+/*
+ * Return TRUE if we're able to establish an offload connection; otherwise
+ * return FALSE.
+ */
+static int tcp_connect_offload(struct sock *sk)
+{
+	struct net_device *dev = cxgb3_egress_dev(__sk_dst_get(sk)->dev,
+						  sk, 0);
+	if (dev == NULL)
+		return 0;
+	return t3_connect(sk, dev) == 0;
+}
+
+/*
+ * Handle an ARP failure for an active open.
+ */
+static void act_open_req_arp_failure(struct t3cdev *dev, struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	sock_hold(sk);
+	bh_lock_sock(sk);
+	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV) {
+		if (!sock_owned_by_user(sk)) {
+			fail_act_open(sk, EHOSTUNREACH);
+			__kfree_skb(skb);
+		} else {
+			/*
+			 * Smart solution: Synthesize an ACTIVE_OPEN_RPL in the
+			 * existing sk_buff and queue it to the backlog.  We
+			 * are certain the sk_buff is not shared.  We also
+			 * don't bother trimming the buffer.
+			 */
+			struct cpl_act_open_rpl *rpl = cplhdr(skb);
+
+			rpl->ot.opcode = CPL_ACT_OPEN_RPL;
+			rpl->status = CPL_ERR_ARP_MISS;
+			SET_BLOG_CPL_HANDLER(skb, active_open_failed);
+			sk_add_backlog(sk, skb);
+		}
+	}
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+/*
+ * Switch a socket to the offload protocol operations.  Note that the offload
+ * operations do not contain the offload backlog handler, we install that
+ * directly to the socket.
+ */
+static inline void install_offload_ops(struct sock *sk)
+{
+	sk->sk_prot = &t3_tcp_prot;
+	sk->sk_backlog_rcv = t3_backlog_rcv;
+	sk->sk_write_space = t3_write_space;
+
+	if (sk->sk_filter)
+		sk_filter_uncharge(sk, sk->sk_filter);
+	sk->sk_filter = &drop_all;
+	sk_filter_charge(sk, sk->sk_filter);
+
+	c3cn_set_flag(sk, C3CN_OFFLOADED);
+}
+
+/*
+ * Max receive window supported by HW in bytes.  Only a small part of it can
+ * be set through option0, the rest needs to be set through RX_DATA_ACK.
+ */
+#define MAX_RCV_WND ((1U << 27) - 1)
+
+/*
+ * Min receive window.  We want it to be large enough to accommodate receive
+ * coalescing, handle jumbo frames, and not trigger sender SWS avoidance.
+ */
+#define MIN_RCV_WND (24 * 1024U)
+
+/*
+ * Determine the receive window scaling factor given a target max
+ * receive window.
+ */
+static inline int select_rcv_wscale(int space, int wscale_ok, int window_clamp)
+{
+	int wscale = 0;
+
+	if (space > MAX_RCV_WND)
+		space = MAX_RCV_WND;
+	if (window_clamp && window_clamp < space)
+		space = window_clamp;
+
+	if (wscale_ok)
+		for (; space > 65535 && wscale < 14; space >>= 1, ++wscale) ;
+	return wscale;
+}
+
+/*
+ * Send an active open request.
+ */
+static int t3_connect(struct sock *sk, struct net_device *dev)
+{
+	struct cxgb3i_tcp_data *cdata = NDEV2CDATA(dev);
+	struct t3cdev *cdev = cdata->cdev;
+	struct cxgb3i_tcp_conn *c3cn = CXGB3_TCP_CONN(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
+	struct sk_buff *skb;
+
+	/*
+	 * Initialize connection data.  Note that the flags and ULP mode are
+	 * initialized higher up ...
+	 */
+	c3cn->dev = dev;
+	c3cn->cdev = cdev;
+	c3cn->tid = cxgb3_alloc_atid(cdev, cdata->client, sk);
+	if (c3cn->tid < 0)
+		goto out_err;
+	c3cn->qset = 0;
+	c3cn->l2t = t3_l2t_get(cdev, dst->neighbour, dev);
+	if (!c3cn->l2t)
+		goto free_tid;
+
+	skb = alloc_skb(sizeof(struct cpl_act_open_req),
+			GFP_KERNEL | __GFP_NOFAIL);
+	skb->sk = sk;
+	set_arp_failure_handler(skb, act_open_req_arp_failure);
+
+	sock_hold(sk);
+
+	install_offload_ops(sk);
+
+	init_offload_sk(sk, cdev, dst);
+	tp->rx_opt.rcv_wscale = select_rcv_wscale(tcp_full_space(sk),
+				CXGB3_TCP_TUNABLE(cdev, tcp_window_scaling),
+				tp->window_clamp);
+	sk->sk_err = 0;
+	sock_reset_flag(sk, SOCK_DONE);
+	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
+
+	mk_act_open_req(sk, skb, c3cn->tid, c3cn->l2t);
+	l2t_send(cdev, skb, c3cn->l2t);
+	return 0;
+
+free_tid:
+	free_atid(cdev, c3cn->tid);
+	c3cn->tid = 0;
+out_err:
+	return -1;
+}
+
+/*
+ * State transitions and actions for close.  Note that if we are in SYN_SENT
+ * we remain in that state as we cannot control a connection while it's in
+ * SYN_SENT; such connections are allowed to establish and are then aborted.
+ */
+static unsigned char new_state[16] = {
+	/* current state:     new state:      action: */
+	/* (Invalid)       */ TCP_CLOSE,
+	/* TCP_ESTABLISHED */ TCP_FIN_WAIT1 | TCP_ACTION_FIN,
+	/* TCP_SYN_SENT    */ TCP_SYN_SENT,
+	/* TCP_SYN_RECV    */ TCP_FIN_WAIT1 | TCP_ACTION_FIN,
+	/* TCP_FIN_WAIT1   */ TCP_FIN_WAIT1,
+	/* TCP_FIN_WAIT2   */ TCP_FIN_WAIT2,
+	/* TCP_TIME_WAIT   */ TCP_CLOSE,
+	/* TCP_CLOSE       */ TCP_CLOSE,
+	/* TCP_CLOSE_WAIT  */ TCP_LAST_ACK | TCP_ACTION_FIN,
+	/* TCP_LAST_ACK    */ TCP_LAST_ACK,
+	/* TCP_LISTEN      */ TCP_CLOSE,
+	/* TCP_CLOSING     */ TCP_CLOSING,
+};
+
+/*
+ * Perform a state transition during close and return the actions indicated
+ * for the transition.  Do not make this function inline, the main reason
+ * it exists at all is to avoid multiple inlining of tcp_set_state.
+ */
+static int make_close_transition(struct sock *sk)
+{
+	int next = (int)new_state[sk->sk_state];
+
+	tcp_set_state(sk, next & TCP_STATE_MASK);
+	return next & TCP_ACTION_FIN;
+}
+
+/*
+ * Close a connection by sending a CPL_CLOSE_CON_REQ message.  Cannot fail
+ * under any circumstances.  We take the easy way out and always queue the
+ * message to the write_queue.  We can optimize the case where the queue is
+ * already empty though the optimization is probably not worth it.
+ */
+static void close_conn(struct sock *sk)
+{
+	struct sk_buff *skb;
+	struct cpl_close_con_req *req;
+	unsigned int tid = C3CN_TID(sk);
+
+	skb = alloc_skb(sizeof(struct cpl_close_con_req),
+			GFP_KERNEL | __GFP_NOFAIL);
+	req = (struct cpl_close_con_req *)__skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_CLOSE_CON));
+	req->wr.wr_lo = htonl(V_WR_TID(tid));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, tid));
+	req->rsvd = htonl(tcp_sk(sk)->write_seq);
+
+	tcp_uncork(sk);
+	skb_entail(sk, skb, C3CB_FLAG_NO_APPEND);
+	if (sk->sk_state != TCP_SYN_SENT)
+		t3_push_frames(sk, 1);
+}
+
+static void tcp_uncork(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (tp->nonagle & TCP_NAGLE_CORK) {
+		tp->nonagle &= ~TCP_NAGLE_CORK;
+		tcp_push(sk, 0);
+	}
+}
+
+static inline void mark_urg(struct tcp_sock *tp, int flags, struct sk_buff *skb)
+{
+	if (unlikely(flags & MSG_OOB)) {
+		tp->snd_up = tp->write_seq;
+		CXGB3_TCP_SKB_CB(skb)->flags =
+		    C3CB_FLAG_URG | C3CB_FLAG_BARRIER | C3CB_FLAG_NO_APPEND |
+		    C3CB_FLAG_NEED_HDR;
+	}
+}
+
+/*
+ * Returns true if a TCP socket is corked.
+ */
+static inline int corked(const struct tcp_sock *tp, int flags)
+{
+	return (flags & MSG_MORE) | (tp->nonagle & TCP_NAGLE_CORK);
+}
+
+/*
+ * Returns true if a connection should send more data to the TOE ASAP.
+ */
+static inline int should_push(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	return (!(C3CN_WR_MAX(sk) - C3CN_WR_AVAIL(sk)) ||
+		(tp->nonagle & TCP_NAGLE_OFF));
+}
+
+/*
+ * Decide if the last frame on the send queue needs any special annotations
+ * (e.g., marked URG) and whether it should be transmitted immediately or
+ * held for additional data.  This is the only routine that performs the full
+ * suite of tests for a Tx packet and therefore must be called for the last
+ * packet added by the various send*() APIs.
+ */
+static void tcp_push(struct sock *sk, int flags)
+{
+	int qlen = skb_queue_len(&sk->sk_write_queue);
+
+	if (likely(qlen)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		struct sk_buff *skb = sk->sk_write_queue.prev;
+
+		mark_urg(tp, flags, skb);
+
+		if (!(CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_NO_APPEND) &&
+		    corked(tp, flags)) {
+			CXGB3_TCP_SKB_CB(skb)->flags |= C3CB_FLAG_HOLD;
+			return;
+		}
+
+		CXGB3_TCP_SKB_CB(skb)->flags &= ~C3CB_FLAG_HOLD;
+		if (qlen == 1 &&
+		    ((CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_NO_APPEND) ||
+		     should_push(sk)))
+			t3_push_frames(sk, 1);
+	}
+}
+
+/*
+ * Wait for memory to become available, either space in a socket's send buffer
+ * or system memory.
+ */
+static int wait_for_mem(struct sock *sk, long *timeout)
+{
+	int sndbuf, err = 0;
+	long vm_wait = 0;
+	long current_timeo = *timeout;
+	DEFINE_WAIT(wait);
+
+	/*
+	 * We open code tcp_memory_free() because we need it outside the
+	 * socket lock and chelsio_wspace() isn't safe there.
+	 */
+	sndbuf = CXGB3_TCP_TUNABLE(C3CN_CDEV(sk), max_host_sndbuf);
+
+	if (sndbuf > sk->sk_wmem_queued)
+		current_timeo = vm_wait = (net_random() % (HZ / 5)) + 2;
+
+	for (;;) {
+		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN)) {
+			err = -EPIPE;
+			break;
+		}
+		if (!*timeout) {
+			err = -EAGAIN;
+			break;
+		}
+		if (signal_pending(current)) {
+			err = sock_intr_errno(*timeout);
+			break;
+		}
+		clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		if (sndbuf > sk->sk_wmem_queued && !vm_wait)
+			break;
+
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		sk->sk_write_pending++;
+		release_sock(sk);
+
+		if (!sk->sk_err && !(sk->sk_shutdown & SEND_SHUTDOWN) &&
+		    (sndbuf <= sk->sk_wmem_queued || vm_wait))
+			current_timeo = schedule_timeout(current_timeo);
+
+		lock_sock(sk);
+		sk->sk_write_pending--;
+
+		if (vm_wait) {
+			vm_wait -= current_timeo;
+			current_timeo = *timeout;
+			if (current_timeo != MAX_SCHEDULE_TIMEOUT &&
+			    (current_timeo -= vm_wait) < 0)
+				current_timeo = 0;
+			vm_wait = 0;
+		}
+		*timeout = current_timeo;
+	}
+
+	finish_wait(sk->sk_sleep, &wait);
+	return err;
+}
+
+static void skb_entail(struct sock *sk, struct sk_buff *skb, int flags)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	CXGB3_TCP_SKB_CB(skb)->seq = tp->write_seq;
+	CXGB3_TCP_SKB_CB(skb)->flags = flags;
+	__skb_queue_tail(&sk->sk_write_queue, skb);
+	sk->sk_wmem_queued += skb->truesize;
+
+	/* Do not share pages across sk_buffs */
+	if (sk->sk_sndmsg_page && sk->sk_sndmsg_off) {
+		put_page(sk->sk_sndmsg_page);
+		sk->sk_sndmsg_page = NULL;
+	}
+}
+
+/*
+ * Send RX credits through an RX_DATA_ACK CPL message.  If nofail is 0 we are
+ * permitted to return without sending the message in case we cannot allocate
+ * an sk_buff.  Returns the number of credits sent.
+ */
+static u32 t3_send_rx_credits(struct sock *sk, u32 credits, u32 dack,
+			      int nofail)
+{
+	struct sk_buff *skb;
+	struct cpl_rx_data_ack *req;
+
+	skb = (nofail ? alloc_ctrl_skb(sk, sizeof(*req))
+	       : alloc_skb(sizeof(*req), GFP_ATOMIC));
+	if (!skb)
+		return 0;
+
+	req = (struct cpl_rx_data_ack *)__skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RX_DATA_ACK, C3CN_TID(sk)));
+	req->credit_dack = htonl(dack | V_RX_CREDITS(credits));
+	skb->priority = mkprio(CPL_PRIORITY_ACK, sk);
+	cxgb3_ofld_send(C3CN_CDEV(sk), skb);
+	return credits;
+}
+
+static void mk_act_open_req(struct sock *sk, struct sk_buff *skb,
+			    unsigned int atid, const struct l2t_entry *e)
+{
+	struct cpl_act_open_req *req;
+
+	skb->priority = mkprio(CPL_PRIORITY_SETUP, sk);
+	req = (struct cpl_act_open_req *)__skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ACT_OPEN_REQ, atid));
+	req->local_port = inet_sk(sk)->sport;
+	req->peer_port = inet_sk(sk)->dport;
+	req->local_ip = inet_sk(sk)->saddr;
+	req->peer_ip = inet_sk(sk)->daddr;
+	req->opt0h = htonl(calc_opt0h(sk) | V_L2T_IDX(e->idx) |
+			   V_TX_CHANNEL(e->smt_idx));
+	req->opt0l = htonl(calc_opt0l(sk));
+	req->params = 0;
+	req->opt2 = htonl(calc_opt2(sk));
+}
+
+/*
+ * Our analog of tcp_free_skb().
+ */
+static inline void chelsio_tcp_free_skb(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_wmem_queued -= skb->truesize;
+	__kfree_skb(skb);
+}
+
+static void t3_purge_write_queue(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&sk->sk_write_queue)))
+		chelsio_tcp_free_skb(sk, skb);
+}
+
+/*
+ * Definitions and declarations for CPL handler functions.
+ * =======================================================
+ */
+
+#ifdef VALIDATE_TID
+#define VALIDATE_SOCK(sk) \
+	do { \
+		if (unlikely(!(sk))) \
+			return CPL_RET_UNKNOWN_TID | CPL_RET_BUF_DONE; \
+	} while (0)
+#else
+#define VALIDATE_SOCK(sk) do {} while (0)
+#endif
+
+static void t3_idiag_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
+{
+	if (ext & (1 << INET_DIAG_CONG)) {
+		struct rtattr *rta;
+		struct t3_inet_diag_info *info;
+
+		rta = __RTA_PUT(skb, INET_DIAG_CONG + 1, sizeof(*info));
+		info = RTA_DATA(rta);
+		info->toe_id = TOE_ID_CHELSIO_T3;
+		info->tid = C3CN_TID(sk);
+		info->wrs = C3CN_WR_MAX(sk) - C3CN_WR_AVAIL(sk);
+		info->ulp_mode = C3CN_ULP_MODE(sk);
+		strncpy(info->dev_name, C3CN_CDEV(sk)->name,
+			sizeof info->dev_name);
+rtattr_failure:
+		;
+	}
+}
+
+#define T3_CONG_OPS(s) \
+	{ .name = s, .owner = THIS_MODULE, .get_info = t3_idiag_get_info }
+
+static struct tcp_congestion_ops t3_cong_ops[] = {
+	T3_CONG_OPS("reno"), T3_CONG_OPS("tahoe"),
+	T3_CONG_OPS("newreno"), T3_CONG_OPS("highspeed")
+};
+
+/*
+ * Similar to process_cpl_msg() but takes an extra socket reference around the
+ * call to the handler.  Should be used if the handler may drop a socket
+ * reference.
+ */
+static inline void process_cpl_msg_ref(void (*fn) (struct sock *,
+						   struct sk_buff *),
+				       struct sock *sk, struct sk_buff *skb)
+{
+	sock_hold(sk);
+	process_cpl_msg(fn, sk, skb);
+	sock_put(sk);
+}
+
+/*
+ * Return whether a failed active open has allocated a TID
+ */
+static inline int act_open_has_tid(int status)
+{
+	return status != CPL_ERR_TCAM_FULL && status != CPL_ERR_CONN_EXIST &&
+	    status != CPL_ERR_ARP_MISS;
+}
+
+static inline void t3_set_ca_ops(struct sock *sk,
+				 struct tcp_congestion_ops *t_ops)
+{
+	inet_csk(sk)->icsk_ca_ops = t_ops;
+}
+
+/*
+ * Returns true if a socket cannot accept new Rx data.
+ */
+static inline int sk_no_receive(const struct sock *sk)
+{
+	return (sk->sk_shutdown & RCV_SHUTDOWN);
+}
+
+/*
+ * Returns true if we need to explicitly request RST when we receive new data
+ * on an RX-closed connection.
+ */
+static inline int need_rst_on_excess_rx(const struct sock *sk)
+{
+	return 1;
+}
+
+/*
+ * A helper function that aborts a connection and increments the given MIB
+ * counter.  The supplied skb is used to generate the ABORT_REQ message if
+ * possible.  Must be called with softirqs disabled.
+ */
+static inline void abort_conn(struct sock *sk, struct sk_buff *skb, int mib)
+{
+	struct sk_buff *abort_skb;
+
+	abort_skb = __get_cpl_reply_skb(skb, sizeof(struct cpl_abort_req),
+					GFP_ATOMIC);
+	if (abort_skb) {
+		NET_INC_STATS_BH(mib);
+		t3_send_reset(sk, CPL_ABORT_SEND_RST, abort_skb);
+	}
+}
+
+/*
+ * Returns whether an ABORT_REQ_RSS message is a negative advice.
+ */
+static inline int is_neg_adv_abort(unsigned int status)
+{
+	return (status == CPL_ERR_RTX_NEG_ADVICE
+		|| status == CPL_ERR_PERSIST_NEG_ADVICE);
+}
+
+/*
+ * Process a received packet with an unknown/unexpected CPL opcode.
+ */
+static int do_bad_cpl(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	printk(KERN_ERR "%s: received bad CPL command %u\n", cdev->name,
+	       *skb->data);
+	return CPL_RET_BUF_DONE | CPL_RET_BAD_MSG;
+}
+
+/*
+ * CPL handler functions.
+ * ======================
+ */
+
+/*
+ * Process a CPL_ACT_ESTABLISH message.
+ */
+static int do_act_establish(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct cpl_act_establish *req = cplhdr(skb);
+	unsigned int tid = GET_TID(req);
+	unsigned int atid = G_PASS_OPEN_TID(ntohl(req->tos_tid));
+	struct sock *sk = (struct sock *)ctx;
+	struct cxgb3i_tcp_data *cdata = CXGB3_TCP_DATA(cdev);
+
+	/*
+	 * It's OK if the TID is currently in use, the owning socket may have
+	 * backlogged its last CPL message(s).  Just take it away.
+	 */
+	C3CN_TID(sk) = tid;
+	sk_insert_tid(cdata, sk, tid);
+	free_atid(cdev, atid);
+
+	C3CN_QSET(sk) = G_QNUM(ntohl(skb->csum));
+
+	process_cpl_msg(sock_act_establish, sk, skb);
+	return 0;
+}
+
+/*
+ * Process an ACT_OPEN_RPL CPL message.
+ */
+static int do_act_open_rpl(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk = (struct sock *)ctx;
+	struct cpl_act_open_rpl *rpl = cplhdr(skb);
+
+	VALIDATE_SOCK(sk);
+
+	if (cdev->type != T3A && act_open_has_tid(rpl->status))
+		cxgb3_queue_tid_release(cdev, GET_TID(rpl));
+
+	process_cpl_msg_ref(active_open_failed, sk, skb);
+	return 0;
+}
+
+/*
+ * Handler RX_ISCSI_HDR CPL messages.
+ */
+static int do_iscsi_hdr(struct t3cdev *t3dev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk = (struct sock *)ctx;
+	VALIDATE_SOCK(sk);
+	process_cpl_msg(process_rx_iscsi_hdr, sk, skb);
+	return 0;
+}
+
+/*
+ * Handler for TX_DATA_ACK CPL messages.
+ */
+static int do_wr_ack(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk = (struct sock *)ctx;
+
+	VALIDATE_SOCK(sk);
+
+	process_cpl_msg(wr_ack, sk, skb);
+	return 0;
+}
+
+/*
+ * Handler for PEER_CLOSE CPL messages.
+ */
+static int do_peer_close(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk = (struct sock *)ctx;
+
+	VALIDATE_SOCK(sk);
+
+	process_cpl_msg_ref(do_peer_fin, sk, skb);
+	return 0;
+}
+
+/*
+ * Handle an ABORT_REQ_RSS CPL message.
+ */
+static int do_abort_req(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	const struct cpl_abort_req_rss *req = cplhdr(skb);
+	struct sock *sk = (struct sock *)ctx;
+
+	if (is_neg_adv_abort(req->status)) {
+		__kfree_skb(skb);
+		return 0;
+	}
+
+	VALIDATE_SOCK(sk);
+
+	/*
+	 * Save the offload device in the skb, we may process this message
+	 * after the socket has closed.
+	 */
+	BLOG_SKB_CB(skb)->cdev = C3CN_CDEV(sk);
+
+	process_cpl_msg_ref(process_abort_req, sk, skb);
+	return 0;
+}
+
+/*
+ * Handle an ABORT_RPL_RSS CPL message.
+ */
+static int do_abort_rpl(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk;
+	struct cpl_abort_rpl_rss *rpl = cplhdr(skb);
+
+	/*
+	 * Ignore replies to post-close aborts indicating that the abort was
+	 * requested too late.  These connections are terminated when we get
+	 * PEER_CLOSE or CLOSE_CON_RPL and by the time the abort_rpl_rss
+	 * arrives the TID is either no longer used or it has been recycled.
+	 */
+	if (rpl->status == CPL_ERR_ABORT_FAILED) {
+discard:
+		__kfree_skb(skb);
+		return 0;
+	}
+
+	sk = (struct sock *)ctx;
+
+	/*
+	 * Sometimes we've already closed the socket, e.g., a post-close
+	 * abort races with ABORT_REQ_RSS, the latter frees the socket
+	 * expecting the ABORT_REQ will fail with CPL_ERR_ABORT_FAILED,
+	 * but FW turns the ABORT_REQ into a regular one and so we get
+	 * ABORT_RPL_RSS with status 0 and no socket.  Only on T3A.
+	 */
+	if (!sk)
+		goto discard;
+
+	process_cpl_msg_ref(process_abort_rpl, sk, skb);
+	return 0;
+}
+
+/*
+ * Handler for CLOSE_CON_RPL CPL messages.
+ */
+static int do_close_con_rpl(struct t3cdev *cdev, struct sk_buff *skb, void *ctx)
+{
+	struct sock *sk = (struct sock *)ctx;
+
+	VALIDATE_SOCK(sk);
+
+	process_cpl_msg_ref(process_close_con_rpl, sk, skb);
+	return 0;
+}
+
+/*
+ * Definitions and declarations for CPL message processing.
+ * ========================================================
+ */
+
+static void make_established(struct sock *, u32, unsigned int);
+static void fixup_and_send_ofo(struct sock *);
+static void fixup_pending_writeq_buffers(struct sock *);
+static void assign_rxopt(struct sock *, unsigned int);
+static void t3_release_offload_resources(struct sock *);
+static void act_open_retry_timer(unsigned long);
+static void connection_done(struct sock *);
+static void mk_act_open_req(struct sock *, struct sk_buff *,
+			    unsigned int, const struct l2t_entry *);
+static int act_open_rpl_status_to_errno(int);
+static void handle_excess_rx(struct sock *, struct sk_buff *);
+static void enter_timewait(struct sock *);
+static int abort_status_to_errno(struct sock *, int, int *);
+static void send_abort_rpl(struct sk_buff *, struct t3cdev *, int);
+static struct sk_buff *get_cpl_reply_skb(struct sk_buff *, size_t, gfp_t);
+static void t3_defer_reply(struct sk_buff *, struct t3cdev *, defer_handler_t);
+static void send_deferred_abort_rpl(struct t3cdev *, struct sk_buff *);
+
+/*
+ * Dequeue and return the first unacknowledged's WR on a socket's pending list.
+ */
+static inline struct sk_buff *dequeue_wr(struct tcp_sock *tp)
+{
+	struct sk_buff *skb = tp->forward_skb_hint;
+
+	if (likely(skb)) {
+		/* Don't bother clearing the tail */
+		tp->forward_skb_hint = (struct sk_buff *)skb->sp;
+		skb->sp = NULL;
+	}
+	return skb;
+}
+
+/*
+ * Return the first pending WR without removing it from the list.
+ */
+static inline struct sk_buff *peek_wr(const struct tcp_sock *tp)
+{
+	return tp->forward_skb_hint;
+}
+
+static inline void free_wr_skb(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+}
+
+static void purge_wr_queue(struct tcp_sock *tp)
+{
+	struct sk_buff *skb;
+	while ((skb = dequeue_wr(tp)) != NULL)
+		free_wr_skb(skb);
+}
+
+static inline void set_abort_rpl_wr(struct sk_buff *skb, unsigned int tid,
+				    int cmd)
+{
+	struct cpl_abort_rpl *rpl = cplhdr(skb);
+
+	rpl->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_RPL));
+	rpl->wr.wr_lo = htonl(V_WR_TID(tid));
+	OPCODE_TID(rpl) = htonl(MK_OPCODE_TID(CPL_ABORT_RPL, tid));
+	rpl->cmd = cmd;
+}
+
+/*
+ * CPL message processing ...
+ * ==========================
+ */
+
+/*
+ * Updates socket state from an active establish CPL message.  Runs with the
+ * socket lock held.
+ */
+static void sock_act_establish(struct sock *sk, struct sk_buff *skb)
+{
+	struct cpl_act_establish *req = cplhdr(skb);
+	u32 rcv_isn = ntohl(req->rcv_isn);	/* real RCV_ISN + 1 */
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (unlikely(sk->sk_state != TCP_SYN_SENT))
+		printk(KERN_ERR "TID %u expected SYN_SENT, found %d\n",
+		       C3CN_TID(sk), sk->sk_state);
+
+	tp->rcv_tstamp = tcp_time_stamp;
+	C3CN_DELAK_SEQ(sk) = tp->copied_seq = tp->rcv_wup = tp->rcv_nxt =
+	    rcv_isn;
+	make_established(sk, ntohl(req->snd_isn), ntohs(req->tcp_opt));
+
+#ifdef CONFIG_SECURITY_NETWORK
+	security_inet_conn_established(sk, tcphdr_skb);
+#endif
+
+	/*
+	 * Now that we finally have a TID send any CPL messages that we had to
+	 * defer for lack of a TID.
+	 */
+	if (skb_queue_len(&tp->out_of_order_queue))
+		fixup_and_send_ofo(sk);
+
+	if (likely(!sock_flag(sk, SOCK_DEAD))) {
+		sk->sk_state_change(sk);
+		sk_wake_async(sk, 0, POLL_OUT);
+	}
+
+	__kfree_skb(skb);
+
+	/*
+	 * Currently the send queue must be empty at this point because the
+	 * socket layer does not send anything before a connection is
+	 * established.  To be future proof though we handle the possibility
+	 * that there are pending buffers to send (either TX_DATA or
+	 * CLOSE_CON_REQ).  First we need to adjust the sequence number of the
+	 * buffers according to the just learned write_seq, and then we send
+	 * them on their way.
+	 */
+	fixup_pending_writeq_buffers(sk);
+	if (t3_push_frames(sk, 1))
+		sk->sk_write_space(sk);
+}
+
+/*
+ * Handle active open failures.
+ */
+static void active_open_failed(struct sock *sk, struct sk_buff *skb)
+{
+	struct cpl_act_open_rpl *rpl = cplhdr(skb);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (rpl->status == CPL_ERR_CONN_EXIST &&
+	    icsk->icsk_retransmit_timer.function != act_open_retry_timer) {
+		icsk->icsk_retransmit_timer.function = act_open_retry_timer;
+		sk_reset_timer(sk, &icsk->icsk_retransmit_timer,
+			       jiffies + HZ / 2);
+	} else
+		fail_act_open(sk, act_open_rpl_status_to_errno(rpl->status));
+	__kfree_skb(skb);
+}
+
+/*
+ * Process received pdu for a connection.
+ */
+static void process_rx_iscsi_hdr(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct cpl_iscsi_hdr *hdr_cpl = cplhdr(skb);
+	struct cpl_iscsi_hdr_norss data_cpl;
+	struct cpl_rx_data_ddp_norss ddp_cpl;
+	unsigned int hdr_len, data_len, status;
+	unsigned int len;
+	int err;
+
+	if (unlikely(sk_no_receive(sk))) {
+		handle_excess_rx(sk, skb);
+		return;
+	}
+
+	CXGB3_TCP_SKB_CB(skb)->seq = ntohl(hdr_cpl->seq);
+	CXGB3_TCP_SKB_CB(skb)->flags = 0;
+
+#if VALIDATE_SEQ
+	if (unlikely(CXGB3_TCP_SKB_CB(skb)->seq != tp->rcv_nxt)) {
+		printk(KERN_ERR "%s: TID %u: Bad seq %u, expected %u\n",
+		       C3CN_CDEV(sk)->name, C3CN_TID(sk),
+		       CXGB3_TCP_SKB_CB(skb)->seq, tp->rcv_nxt);
+		goto done;
+	}
+#endif
+	skb_reset_transport_header(skb);
+	__skb_pull(skb, sizeof(struct cpl_iscsi_hdr));
+
+	len = hdr_len = ntohs(hdr_cpl->len);
+	/* msg coalesce is off or not enough data received */
+	if (skb->len <= hdr_len) {
+		printk(KERN_ERR "%s: TID %u, ISCSI_HDR, skb len %u < %u.\n",
+		       C3CN_CDEV(sk)->name, C3CN_TID(sk), skb->len, hdr_len);
+		goto abort_conn;
+	}
+
+	err = skb_copy_bits(skb, skb->len - sizeof(ddp_cpl), &ddp_cpl,
+			    sizeof(ddp_cpl));
+	if (err < 0)
+		goto abort_conn;
+
+	skb_ulp_mode(skb) = ULP2_FLAG_DATA_READY;
+	skb_ulp_pdulen(skb) = ntohs(ddp_cpl.len);
+	skb_ulp_ddigest(skb) = ntohl(ddp_cpl.ulp_crc);
+	status = ntohl(ddp_cpl.ddp_status);
+
+	if (status & (1 << RX_DDP_STATUS_HCRC_SHIFT))
+		skb_ulp_mode(skb) |= ULP2_FLAG_HCRC_ERROR;
+	if (status & (1 << RX_DDP_STATUS_DCRC_SHIFT))
+		skb_ulp_mode(skb) |= ULP2_FLAG_DCRC_ERROR;
+	if (status & (1 << RX_DDP_STATUS_PAD_SHIFT))
+		skb_ulp_mode(skb) |= ULP2_FLAG_PAD_ERROR;
+
+	if (skb->len > (hdr_len + sizeof(ddp_cpl))) {
+		err = skb_copy_bits(skb, hdr_len, &data_cpl, sizeof(data_cpl));
+		if (err < 0)
+			goto abort_conn;
+		data_len = ntohs(data_cpl.len);
+		len += sizeof(data_cpl) + data_len;
+	} else if (status & (1 << RX_DDP_STATUS_DDP_SHIFT))
+		skb_ulp_mode(skb) |= ULP2_FLAG_DATA_DDPED;
+
+	tcp_sk(sk)->rcv_nxt = ntohl(ddp_cpl.seq) + skb_ulp_pdulen(skb);
+	inet_csk(sk)->icsk_ack.lrcvtime = tcp_time_stamp;
+	__pskb_trim(skb, len);
+	__skb_queue_tail(&sk->sk_receive_queue, skb);
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, 0);
+	return;
+
+abort_conn:
+	t3_send_reset(sk, CPL_ABORT_SEND_RST, NULL);
+done:
+	__kfree_skb(skb);
+}
+
+/*
+ * Process an acknowledgment of WR completion.  Advance snd_una and send the
+ * next batch of work requests from the write queue.
+ */
+static void wr_ack(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct cpl_wr_ack *hdr = cplhdr(skb);
+	unsigned int credits = ntohs(hdr->credits);
+	u32 snd_una = ntohl(hdr->snd_una);
+
+	C3CN_WR_AVAIL(sk) += credits;
+	if (C3CN_WR_UNACKED(sk) > C3CN_WR_MAX(sk) - C3CN_WR_AVAIL(sk))
+		C3CN_WR_UNACKED(sk) = C3CN_WR_MAX(sk) - C3CN_WR_AVAIL(sk);
+
+	while (credits) {
+		struct sk_buff *p = peek_wr(tp);
+
+		if (unlikely(!p)) {
+			printk(KERN_ERR "%u WR_ACK credits for TID %u with "
+			       "nothing pending, state %u\n",
+			       credits, C3CN_TID(sk), sk->sk_state);
+			break;
+		}
+		if (unlikely(credits < p->csum)) {
+			p->csum -= credits;
+			break;
+		} else {
+			dequeue_wr(tp);
+			credits -= p->csum;
+			free_wr_skb(p);
+		}
+	}
+
+	if (unlikely(before(snd_una, tp->snd_una))) {
+#if VALIDATE_SEQ
+		struct t3cdev *cdev = C3CN_CDEV(sk);
+
+		printk(KERN_ERR "%s: unexpected sequence # %u in WR_ACK "
+		       "for TID %u, snd_una %u\n", cdev->name, snd_una,
+		       C3CN_TID(sk), tp->snd_una);
+#endif
+		goto out_free;
+	}
+
+	if (tp->snd_una != snd_una) {
+		tp->snd_una = snd_una;
+		dst_confirm(sk->sk_dst_cache);
+		tp->rcv_tstamp = tcp_time_stamp;
+		if (tp->snd_una == tp->snd_nxt)
+			c3cn_reset_flag(sk, C3CN_TX_WAIT_IDLE);
+	}
+
+	if (skb_queue_len(&sk->sk_write_queue) && t3_push_frames(sk, 0))
+		sk->sk_write_space(sk);
+out_free:
+	__kfree_skb(skb);
+}
+
+/*
+ * Handle a peer FIN.
+ */
+static void do_peer_fin(struct sock *sk, struct sk_buff *skb)
+{
+	int keep = 0, dead = sock_flag(sk, SOCK_DEAD);
+
+	if (!is_t3a(C3CN_CDEV(sk)) && c3cn_flag(sk, C3CN_ABORT_RPL_PENDING))
+		goto out;
+
+	sk->sk_shutdown |= RCV_SHUTDOWN;
+	sock_set_flag(sk, SOCK_DONE);
+	switch (sk->sk_state) {
+	case TCP_SYN_RECV:
+	case TCP_ESTABLISHED:
+		tcp_set_state(sk, TCP_CLOSE_WAIT);
+		break;
+	case TCP_FIN_WAIT1:
+		tcp_set_state(sk, TCP_CLOSING);
+		break;
+	case TCP_FIN_WAIT2:
+		/*
+		 * If we've sent an abort_req we must have sent it too late,
+		 * HW will send us a reply telling us so, and this peer_close
+		 * is really the last message for this connection and needs to
+		 * be treated as an abort_rpl, i.e., transition the connection
+		 * to TCP_CLOSE (note that the host stack does this at the
+		 * time of generating the RST but we must wait for HW).
+		 * Otherwise we enter TIME_WAIT.
+		 */
+		t3_release_offload_resources(sk);
+		if (c3cn_flag(sk, C3CN_ABORT_RPL_PENDING))
+			connection_done(sk);
+		else
+			enter_timewait(sk);
+		break;
+	default:
+		printk(KERN_ERR
+		       "%s: TID %u received PEER_CLOSE in bad state %d\n",
+		       C3CN_CDEV(sk)->name, C3CN_TID(sk), sk->sk_state);
+	}
+
+	if (!dead) {
+		sk->sk_state_change(sk);
+
+		/* Do not send POLL_HUP for half duplex close. */
+		if ((sk->sk_shutdown & SEND_SHUTDOWN) ||
+		    sk->sk_state == TCP_CLOSE)
+			sk_wake_async(sk, 1, POLL_HUP);
+		else
+			sk_wake_async(sk, 1, POLL_IN);
+	}
+out:
+	if (!keep)
+		__kfree_skb(skb);
+}
+
+/*
+ * Process abort requests.  If we are waiting for an ABORT_RPL we ignore this
+ * request except that we need to reply to it.
+ */
+static void process_abort_req(struct sock *sk, struct sk_buff *skb)
+{
+	int rst_status = CPL_ABORT_NO_RST;
+	const struct cpl_abort_req_rss *req = cplhdr(skb);
+
+	if (!c3cn_flag(sk, C3CN_ABORT_REQ_RCVD)) {
+		c3cn_set_flag(sk, C3CN_ABORT_REQ_RCVD);
+		c3cn_set_flag(sk, C3CN_ABORT_SHUTDOWN);
+		__kfree_skb(skb);
+		return;
+	}
+	c3cn_reset_flag(sk, C3CN_ABORT_REQ_RCVD);
+
+	/*
+	 * Three cases to consider:
+	 * a) We haven't sent an abort_req; close the connection.
+	 * b) We have sent a post-close abort_req that will get to TP too late
+	 *    and will generate a CPL_ERR_ABORT_FAILED reply.  The reply will
+	 *    be ignored and the connection should be closed now.
+	 * c) We have sent a regular abort_req that will get to TP too late.
+	 *    That will generate an abort_rpl with status 0, wait for it.
+	 */
+	if (!c3cn_flag(sk, C3CN_ABORT_RPL_PENDING)
+	    || (is_t3a(C3CN_CDEV(sk))
+		&& c3cn_flag(sk, C3CN_CLOSE_CON_REQUESTED))) {
+		sk->sk_err =
+		    abort_status_to_errno(sk, req->status, &rst_status);
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+
+		t3_release_offload_resources(sk);
+		connection_done(sk);
+	}
+
+	send_abort_rpl(skb, BLOG_SKB_CB(skb)->cdev, rst_status);
+}
+
+/*
+ * Process abort replies.  We only process these messages if we anticipate
+ * them as the coordination between SW and HW in this area is somewhat lacking
+ * and sometimes we get ABORT_RPLs after we are done with the connection that
+ * originated the ABORT_REQ.
+ */
+static void process_abort_rpl(struct sock *sk, struct sk_buff *skb)
+{
+	if (c3cn_flag(sk, C3CN_ABORT_RPL_PENDING)) {
+		if (!c3cn_flag(sk, C3CN_ABORT_RPL_RCVD)
+		    && !is_t3a(C3CN_CDEV(sk)))
+			c3cn_set_flag(sk, C3CN_ABORT_RPL_RCVD);
+		else {
+			c3cn_reset_flag(sk, C3CN_ABORT_RPL_RCVD);
+			c3cn_reset_flag(sk, C3CN_ABORT_RPL_PENDING);
+			if (!c3cn_flag(sk, C3CN_ABORT_REQ_RCVD) ||
+			    !is_t3a(C3CN_CDEV(sk))) {
+				BUG_ON(c3cn_flag(sk, C3CN_ABORT_REQ_RCVD));
+				t3_release_offload_resources(sk);
+				connection_done(sk);
+			}
+		}
+	}
+	__kfree_skb(skb);
+}
+
+/*
+ * Process a peer ACK to our FIN.
+ */
+static void process_close_con_rpl(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct cpl_close_con_rpl *rpl = cplhdr(skb);
+
+	tp->snd_una = ntohl(rpl->snd_nxt) - 1;	/* exclude FIN */
+
+	if (!is_t3a(C3CN_CDEV(sk)) && c3cn_flag(sk, C3CN_ABORT_RPL_PENDING))
+		goto out;
+
+	switch (sk->sk_state) {
+	case TCP_CLOSING:	/* see FIN_WAIT2 case in do_peer_fin */
+		t3_release_offload_resources(sk);
+		if (c3cn_flag(sk, C3CN_ABORT_RPL_PENDING))
+			connection_done(sk);
+		else
+			enter_timewait(sk);
+		break;
+	case TCP_LAST_ACK:
+		/*
+		 * In this state we don't care about pending abort_rpl.
+		 * If we've sent abort_req it was post-close and was sent too
+		 * late, this close_con_rpl is the actual last message.
+		 */
+		t3_release_offload_resources(sk);
+		connection_done(sk);
+		break;
+	case TCP_FIN_WAIT1:
+		tcp_set_state(sk, TCP_FIN_WAIT2);
+		sk->sk_shutdown |= SEND_SHUTDOWN;
+		dst_confirm(sk->sk_dst_cache);
+
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_state_change(sk);
+		else if (tcp_sk(sk)->linger2 < 0 &&
+			 !c3cn_flag(sk, C3CN_ABORT_SHUTDOWN))
+			abort_conn(sk, skb, LINUX_MIB_TCPABORTONLINGER);
+		break;
+	default:
+		printk(KERN_ERR
+		       "%s: TID %u received CLOSE_CON_RPL in bad state %d\n",
+		       C3CN_CDEV(sk)->name, C3CN_TID(sk), sk->sk_state);
+	}
+out:
+	kfree_skb(skb);
+}
+
+/*
+ * Random utility functions for CPL message processing ...
+ * =======================================================
+ */
+
+/**
+ *	find_best_mtu - find the entry in the MTU table closest to an MTU
+ *	@d: TOM state
+ *	@mtu: the target MTU
+ *
+ *	Returns the index of the value in the MTU table that is closest to but
+ *	does not exceed the target MTU.
+ */
+static unsigned int find_best_mtu(const struct t3c_data *d, unsigned short mtu)
+{
+	int i = 0;
+
+	while (i < d->nmtus - 1 && d->mtus[i + 1] <= mtu)
+		++i;
+	return i;
+}
+
+static unsigned int select_mss(struct sock *sk, unsigned int pmtu)
+{
+	unsigned int idx;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
+	struct t3cdev *cdev = C3CN_CDEV(sk);
+	const struct t3c_data *td = T3C_DATA(cdev);
+
+	tp->advmss = dst_metric(dst, RTAX_ADVMSS);
+	if (tp->rx_opt.user_mss && tp->advmss > tp->rx_opt.user_mss)
+		tp->advmss = tp->rx_opt.user_mss;
+	if (tp->advmss > pmtu - 40)
+		tp->advmss = pmtu - 40;
+	if (tp->advmss < td->mtus[0] - 40)
+		tp->advmss = td->mtus[0] - 40;
+	idx = find_best_mtu(td, tp->advmss + 40);
+	tp->advmss = td->mtus[idx] - 40;
+	inet_csk(sk)->icsk_pmtu_cookie = pmtu;
+	return idx;
+}
+
+/*
+ * Determine the receive window size for a socket.
+ */
+static unsigned int select_rcv_wnd(struct sock *sk)
+{
+	struct t3cdev *cdev = C3CN_CDEV(sk);
+	struct cxgb3i_tcp_data *cdata = CXGB3_TCP_DATA(cdev);
+	unsigned int wnd = tcp_full_space(sk);
+	unsigned int max_rcv_wnd;
+
+	/*
+	 * For receive coalescing to work effectively we need a receive window
+	 * that can accomodate a coalesced segment.
+	 */
+	if (wnd < MIN_RCV_WND)
+		wnd = MIN_RCV_WND;
+
+	max_rcv_wnd = (cdev->type < T3C
+		       ? (u32) cdata->rx_page_size * 23 : MAX_RCV_WND);
+
+	return min(wnd, max_rcv_wnd);
+}
+
+static void fail_act_open(struct sock *sk, int errno)
+{
+	sk->sk_err = errno;
+	sk->sk_error_report(sk);
+	t3_release_offload_resources(sk);
+	connection_done(sk);
+	TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
+}
+
+static void pivot_ca_ops(struct sock *sk, int cong)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (icsk->icsk_ca_ops->release)
+		icsk->icsk_ca_ops->release(sk);
+	module_put(icsk->icsk_ca_ops->owner);
+	icsk->icsk_ca_ops = &t3_cong_ops[cong < 0 ? 2 : cong];
+}
+
+/*
+ * Assign offload parameters to some socket fields.  This code is used by
+ * both active and passive opens.
+ */
+static void init_offload_sk(struct sock *sk, struct t3cdev *cdev,
+			    struct dst_entry *dst)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	BUG_ON(C3CN_CDEV(sk) != cdev);
+	C3CN_WR_MAX(sk) = C3CN_WR_AVAIL(sk) = CXGB3_TCP_TUNABLE(cdev, max_wrs);
+	C3CN_WR_UNACKED(sk) = 0;
+	C3CN_DELAK_MODE(sk) = 0;
+	C3CN_MSS_IDX(sk) = select_mss(sk, dst_mtu(dst));
+	tp->rcv_wnd = select_rcv_wnd(sk);
+
+	C3CN_CTRL_SKB_CACHE(sk) = alloc_skb(CTRL_SKB_LEN, gfp_any());
+	reset_wr_list(tp);
+
+	if (!tp->window_clamp)
+		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
+	pivot_ca_ops(sk, CXGB3_TCP_TUNABLE(cdev, cong_alg));
+}
+
+/*
+ * Returns whether a CPL message is not expected in the socket backlog of a
+ * closed connection.  Most messages are illegal at that point except
+ * ABORT_RPL_RSS and GET_TCB_RPL sent by DDP.
+ */
+static int bad_backlog_msg(unsigned int opcode)
+{
+	return opcode != CPL_ABORT_RPL_RSS && opcode != CPL_GET_TCB_RPL;
+}
+
+/*
+ * Called for each sk_buff in a socket's receive backlog during
+ * backlog processing.
+ */
+static int t3_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+#if VALIDATE_TID
+	unsigned int opcode = ntohl(skb->csum) >> 24;
+
+	if (unlikely(sk->sk_state == TCP_CLOSE && bad_backlog_msg(opcode))) {
+		printk(KERN_ERR "unexpected CPL message with opcode %x for "
+		       "closed TID %u\n", opcode, C3CN_TID(sk));
+		kfree_skb(skb);
+		return 0;
+	}
+#endif
+
+	BLOG_SKB_CB(skb)->backlog_rcv(sk, skb);
+	return 0;
+}
+
+/*
+ * TCP socket write_space callback.  Follows sk_stream_write_space().
+ */
+static void t3_write_space(struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+
+	if (chelsio_wspace(sk) >= sk_stream_min_wspace(sk) && sock) {
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+
+		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+			wake_up_interruptible(sk->sk_sleep);
+
+		if (sock->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
+			sock_wake_async(sock, 2, POLL_OUT);
+	}
+}
+
+static void act_open_retry_timer(unsigned long data)
+{
+	struct sk_buff *skb;
+	struct sock *sk = (struct sock *)data;
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk))	/* try in a bit */
+		sk_reset_timer(sk, &icsk->icsk_retransmit_timer,
+			       jiffies + HZ / 20);
+	else {
+		skb = alloc_skb(sizeof(struct cpl_act_open_req), GFP_ATOMIC);
+		if (!skb)
+			fail_act_open(sk, ENOMEM);
+		else {
+			skb->sk = sk;
+			set_arp_failure_handler(skb, act_open_req_arp_failure);
+			mk_act_open_req(sk, skb, C3CN_TID(sk), C3CN_L2T(sk));
+			l2t_send(C3CN_CDEV(sk), skb, C3CN_L2T(sk));
+		}
+	}
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+/*
+ * Called when we receive the last message from HW for a connection.  A
+ * connection cannot transition to TCP_CLOSE prior to this event.
+ * Resources related to the offload state of a connection (e.g., L2T entries)
+ * must have been relinquished prior to calling this.
+ */
+static void connection_done(struct sock *sk)
+{
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up_all(sk->sk_sleep);
+
+	tcp_done(sk);
+}
+
+/*
+ * Convert an ACT_OPEN_RPL status to a Linux errno.
+ */
+static int act_open_rpl_status_to_errno(int status)
+{
+	switch (status) {
+	case CPL_ERR_CONN_RESET:
+		return ECONNREFUSED;
+	case CPL_ERR_ARP_MISS:
+		return EHOSTUNREACH;
+	case CPL_ERR_CONN_TIMEDOUT:
+		return ETIMEDOUT;
+	case CPL_ERR_TCAM_FULL:
+		return ENOMEM;
+	case CPL_ERR_CONN_EXIST:
+		printk(KERN_ERR "ACTIVE_OPEN_RPL: 4-tuple in use\n");
+		return EADDRINUSE;
+	default:
+		return EIO;
+	}
+}
+
+/*
+ * Adapted from tcp_minisocks.c
+ */
+
+void tcp_time_wait(struct sock *sk, int state, int timeo)
+{
+	struct inet_timewait_sock *tw = NULL;
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	int recycle_ok = 0;
+
+	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
+		tw = inet_twsk_alloc(sk, state);
+
+	if (tw != NULL) {
+		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
+		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
+
+		tw->tw_rcv_wscale = tp->rx_opt.rcv_wscale;
+		tcptw->tw_rcv_nxt = tp->rcv_nxt;
+		tcptw->tw_snd_nxt = tp->snd_nxt;
+		tcptw->tw_rcv_wnd = tcp_receive_window(tp);
+		tcptw->tw_ts_recent = tp->rx_opt.ts_recent;
+		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
+
+		/* Linkage updates. */
+		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);
+
+		/* Get the TIME_WAIT timeout firing. */
+		if (timeo < rto)
+			timeo = rto;
+
+		if (recycle_ok) {
+			tw->tw_timeout = rto;
+		} else {
+			tw->tw_timeout = TCP_TIMEWAIT_LEN;
+			if (state == TCP_TIME_WAIT)
+				timeo = TCP_TIMEWAIT_LEN;
+		}
+
+		inet_twsk_schedule(tw, &tcp_death_row, timeo, TCP_TIMEWAIT_LEN);
+		inet_twsk_put(tw);
+	} else {
+		/* Sorry, if we're out of memory, just CLOSE this
+		 * socket up.  We've got bigger problems than
+		 * non-graceful socket closings.
+		 */
+		if (net_ratelimit())
+			printk(KERN_INFO
+			       "TCP: time wait bucket table overflow\n");
+	}
+
+	tcp_done(sk);
+}
+
+/*
+ * Move a socket to TIME_WAIT state.  We need to make some adjustments to the
+ * socket state before calling tcp_time_wait to comply with its expectations.
+ */
+static void enter_timewait(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/*
+	 * Bump rcv_nxt for the peer FIN.  We don't do this at the time we
+	 * process peer_close because we don't want to carry the peer FIN in
+	 * the socket's receive queue and if we increment rcv_nxt without
+	 * having the FIN in the receive queue we'll confuse facilities such
+	 * as SIOCINQ.
+	 */
+	tp->rcv_nxt++;
+
+	tp->rx_opt.ts_recent_stamp = 0;	/* defeat recycling */
+	tp->srtt = 0;		/* defeat tcp_update_metrics */
+	tcp_time_wait(sk, TCP_TIME_WAIT, 0);	/* calls tcp_done */
+}
+
+/*
+ * Convert the status code of an ABORT_REQ into a Linux error code.  Also
+ * indicate whether RST should be sent in response.
+ */
+static int abort_status_to_errno(struct sock *sk, int abort_reason,
+				 int *need_rst)
+{
+	switch (abort_reason) {
+	case CPL_ERR_BAD_SYN:
+		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN); /* fall through */
+	case CPL_ERR_CONN_RESET:
+		return sk->sk_state == TCP_CLOSE_WAIT ? EPIPE : ECONNRESET;
+	case CPL_ERR_XMIT_TIMEDOUT:
+	case CPL_ERR_PERSIST_TIMEDOUT:
+	case CPL_ERR_FINWAIT2_TIMEDOUT:
+	case CPL_ERR_KEEPALIVE_TIMEDOUT:
+		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONTIMEOUT);
+		return ETIMEDOUT;
+	default:
+		return EIO;
+	}
+}
+
+static void send_abort_rpl(struct sk_buff *skb, struct t3cdev *cdev,
+			   int rst_status)
+{
+	struct sk_buff *reply_skb;
+	struct cpl_abort_req_rss *req = cplhdr(skb);
+
+	reply_skb = get_cpl_reply_skb(skb, sizeof(struct cpl_abort_rpl),
+				      gfp_any());
+	if (!reply_skb) {
+		/* Defer the reply.  Stick rst_status into req->cmd. */
+		req->status = rst_status;
+		t3_defer_reply(skb, cdev, send_deferred_abort_rpl);
+		return;
+	}
+
+	reply_skb->priority = CPL_PRIORITY_DATA;
+	set_abort_rpl_wr(reply_skb, GET_TID(req), rst_status);
+	kfree_skb(skb);
+	cxgb3_ofld_send(cdev, reply_skb);
+}
+
+/*
+ * Returns an sk_buff for a reply CPL message of size len.  If the input
+ * sk_buff has no other users it is trimmed and reused, otherwise a new buffer
+ * is allocated.  The input skb must be of size at least len.  Note that this
+ * operation does not destroy the original skb data even if it decides to reuse
+ * the buffer.
+ */
+static struct sk_buff *get_cpl_reply_skb(struct sk_buff *skb, size_t len,
+					 gfp_t gfp)
+{
+	if (likely(!skb_cloned(skb))) {
+		BUG_ON(skb->len < len);
+		__skb_trim(skb, len);
+		skb_get(skb);
+	} else {
+		skb = alloc_skb(len, gfp);
+		if (skb)
+			__skb_put(skb, len);
+	}
+	return skb;
+}
+
+/*
+ * Add an skb to the deferred skb queue for processing from process context.
+ */
+static void t3_defer_reply(struct sk_buff *skb, struct t3cdev *cdev,
+			   defer_handler_t handler)
+{
+	struct cxgb3i_tcp_data *cdata = CXGB3_TCP_DATA(cdev);
+
+	DEFERRED_SKB_CB(skb)->handler = handler;
+	spin_lock_bh(&cdata->deferq.lock);
+	__skb_queue_tail(&cdata->deferq, skb);
+	if (skb_queue_len(&cdata->deferq) == 1)
+		schedule_work(&cdata->deferq_task);
+	spin_unlock_bh(&cdata->deferq.lock);
+}
+
+/*
+ * Process the defer queue.
+ */
+static void process_deferq(struct work_struct *task_param)
+{
+	struct sk_buff *skb;
+	struct cxgb3i_tcp_data *cdata = container_of(task_param,
+						     struct cxgb3i_tcp_data,
+						     deferq_task);
+
+	spin_lock_bh(&cdata->deferq.lock);
+	while ((skb = __skb_dequeue(&cdata->deferq)) != NULL) {
+		spin_unlock_bh(&cdata->deferq.lock);
+		DEFERRED_SKB_CB(skb)->handler(cdata->cdev, skb);
+		spin_lock_bh(&cdata->deferq.lock);
+	}
+	spin_unlock_bh(&cdata->deferq.lock);
+}
+
+static void send_deferred_abort_rpl(struct t3cdev *cdev, struct sk_buff *skb)
+{
+	struct sk_buff *reply_skb;
+	struct cpl_abort_req_rss *req = cplhdr(skb);
+
+	reply_skb = alloc_skb(sizeof(struct cpl_abort_rpl),
+			      GFP_KERNEL | __GFP_NOFAIL);
+	reply_skb->priority = CPL_PRIORITY_DATA;
+	__skb_put(reply_skb, sizeof(struct cpl_abort_rpl));
+	set_abort_rpl_wr(reply_skb, GET_TID(req), req->status);
+	cxgb3_ofld_send(cdev, reply_skb);
+	kfree_skb(skb);
+}
+
+/*
+ * Release resources held by an offload connection (TID, L2T entry, etc.)
+ */
+static void t3_release_offload_resources(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct t3cdev *cdev = C3CN_CDEV(sk);
+	unsigned int tid = C3CN_TID(sk);
+
+	if (!cdev)
+		return;
+
+	C3CN_QSET(sk) = 0;
+
+	kfree_skb(C3CN_CTRL_SKB_CACHE(sk));
+	C3CN_CTRL_SKB_CACHE(sk) = NULL;
+
+	if (C3CN_WR_AVAIL(sk) != C3CN_WR_MAX(sk)) {
+		purge_wr_queue(tp);
+		reset_wr_list(tp);
+	}
+
+	if (C3CN_L2T(sk)) {
+		l2t_release(L2DATA(cdev), C3CN_L2T(sk));
+		C3CN_L2T(sk) = NULL;
+	}
+
+	if (sk->sk_state == TCP_SYN_SENT) {	/* we have ATID */
+		free_atid(cdev, tid);
+		__skb_queue_purge(&tp->out_of_order_queue);
+	} else {		/* we have TID */
+		cxgb3_remove_tid(cdev, (void *)sk, tid);
+		sock_put(sk);
+	}
+
+	t3_set_ca_ops(sk, &tcp_init_congestion_ops);
+	C3CN_CDEV(sk) = NULL;
+}
+
+/*
+ * Handles Rx data that arrives in a state where the socket isn't accepting
+ * new data.
+ */
+static void handle_excess_rx(struct sock *sk, struct sk_buff *skb)
+{
+	if (need_rst_on_excess_rx(sk) && !c3cn_flag(sk, C3CN_ABORT_SHUTDOWN))
+		abort_conn(sk, skb, LINUX_MIB_TCPABORTONDATA);
+
+	kfree_skb(skb);	/* can't use __kfree_skb here */
+}
+
+/*
+ * Like get_cpl_reply_skb() but the returned buffer starts out empty.
+ */
+static struct sk_buff *__get_cpl_reply_skb(struct sk_buff *skb, size_t len,
+					   gfp_t gfp)
+{
+	if (likely(!skb_cloned(skb) && !skb->data_len)) {
+		__skb_trim(skb, 0);
+		skb_get(skb);
+	} else
+		skb = alloc_skb(len, gfp);
+	return skb;
+}
+
+/*
+ * Completes some final bits of initialization for just established connections
+ * and changes their state to TCP_ESTABLISHED.
+ *
+ * snd_isn here is the ISN after the SYN, i.e., the true ISN + 1.
+ */
+static void make_established(struct sock *sk, u32 snd_isn, unsigned int opt)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tp->pushed_seq = tp->write_seq = tp->snd_nxt = tp->snd_una = snd_isn;
+	inet_sk(sk)->id = tp->write_seq ^ jiffies;
+	assign_rxopt(sk, opt);
+
+	/*
+	 * Causes the first RX_DATA_ACK to supply any Rx credits we couldn't
+	 * pass through opt0.
+	 */
+	if (tp->rcv_wnd > (M_RCV_BUFSIZ << 10))
+		tp->rcv_wup -= tp->rcv_wnd - (M_RCV_BUFSIZ << 10);
+
+	dst_confirm(sk->sk_dst_cache);
+
+	/*
+	 * tcp_poll() does not lock socket, make sure initial values are
+	 * committed before changing to ESTABLISHED.
+	 */
+	smp_mb();
+	tcp_set_state(sk, TCP_ESTABLISHED);
+}
+
+/*
+ * Fill in the right TID for CPL messages waiting in the out-of-order queue
+ * and send them to the TOE.
+ */
+static void fixup_and_send_ofo(struct sock *sk)
+{
+	struct sk_buff *skb;
+	struct t3cdev *cdev = C3CN_CDEV(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int tid = C3CN_TID(sk);
+
+	while ((skb = __skb_dequeue(&tp->out_of_order_queue)) != NULL) {
+		/*
+		 * A variety of messages can be waiting but the fields we'll
+		 * be touching are common to all so any message type will do.
+		 */
+		struct cpl_close_con_req *p = cplhdr(skb);
+
+		p->wr.wr_lo = htonl(V_WR_TID(tid));
+		OPCODE_TID(p) = htonl(MK_OPCODE_TID(p->ot.opcode, tid));
+		cxgb3_ofld_send(cdev, skb);
+	}
+}
+
+/*
+ * Adjust buffers already in write queue after a SYN_SENT->ESTABLISHED
+ * transition.  For TX_DATA we need to adjust the start sequence numbers, and
+ * for other packets we need to adjust the TID.  TX_DATA packets don't have
+ * headers yet and so not TIDs.
+ */
+static void fixup_pending_writeq_buffers(struct sock *sk)
+{
+	struct sk_buff *skb;
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int tid = C3CN_TID(sk);
+
+	skb_queue_walk(&sk->sk_write_queue, skb) {
+		if (CXGB3_TCP_SKB_CB(skb)->flags & C3CB_FLAG_NEED_HDR) {
+			CXGB3_TCP_SKB_CB(skb)->seq = tp->write_seq;
+			tp->write_seq += skb->len + ulp_extra_len(skb);
+		} else {
+			struct cpl_close_con_req *p = cplhdr(skb);
+
+			p->wr.wr_lo = htonl(V_WR_TID(tid));
+			OPCODE_TID(p) = htonl(MK_OPCODE_TID(p->ot.opcode, tid));
+		}
+	}
+}
+
+/*
+ * Called when a connection is established to translate the TCP options
+ * reported by HW to Linux's native format.
+ */
+static void assign_rxopt(struct sock *sk, unsigned int opt)
+{
+	const struct t3c_data *td = T3C_DATA(C3CN_CDEV(sk));
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tp->rx_opt.mss_clamp = td->mtus[G_TCPOPT_MSS(opt)] - 40;
+	tp->mss_cache = tp->rx_opt.mss_clamp;
+	tp->tcp_header_len = sizeof(struct tcphdr);
+	tp->rx_opt.tstamp_ok = G_TCPOPT_TSTAMP(opt);
+	tp->rx_opt.sack_ok = G_TCPOPT_SACK(opt);
+	tp->rx_opt.wscale_ok = G_TCPOPT_WSCALE_OK(opt);
+	tp->rx_opt.snd_wscale = G_TCPOPT_SND_WSCALE(opt);
+	if (!tp->rx_opt.wscale_ok)
+		tp->rx_opt.rcv_wscale = 0;
+	if (tp->rx_opt.tstamp_ok) {
+		tp->tcp_header_len += TCPOLEN_TSTAMP_ALIGNED;
+		tp->mss_cache -= TCPOLEN_TSTAMP_ALIGNED;
+	}
+}
diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.h b/drivers/scsi/cxgb3i/cxgb3i_offload.h
new file mode 100644
index 0000000..e4b34c7
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.h
@@ -0,0 +1,259 @@
+/*
+ * Copyright (C) 2003-2008 Chelsio Communications.  All rights reserved.
+ *
+ * Written by Dimitris Michailidis (dm@chelsio.com)
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the LICENSE file included in this
+ * release for licensing terms and conditions.
+ */
+
+#ifndef _CXGB3I_OFFLOAD_H
+#define _CXGB3I_OFFLOAD_H
+
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+
+#include "t3cdev.h"
+#include "cxgb3_offload.h"
+
+/*
+ * Data structure to keep track of cxgb3 connection.  Linked off of the
+ * (struct sock *).
+ */
+struct cxgb3i_tcp_conn {
+	struct net_device *dev;
+	struct t3cdev *cdev;
+	unsigned long flags;
+	int tid;
+	int qset;
+	int mss_idx;
+	struct l2t_entry *l2t;
+	int ulp_mode;
+	int delack_mode;
+	int delack_seq;
+	int wr_max;
+	int wr_avail;
+	int wr_unacked;
+	struct sk_buff *ctrl_skb_cache;
+
+	/*
+	 * Upper Layer Protocol (ULP) state.  These could probably go into a
+	 * union based on mutually independent ULP modes but so far it's not
+	 * worth the effort.
+	 */
+};
+#define CXGB3_TCP_CONN(sk)	\
+	(*(struct cxgb3i_tcp_conn **)&(sk)->sk_protinfo)
+
+#define C3CN_CDEV(sk)		(CXGB3_TCP_CONN(sk)->cdev)
+#define C3CN_TID(sk)		(CXGB3_TCP_CONN(sk)->tid)
+#define C3CN_QSET(sk)		(CXGB3_TCP_CONN(sk)->qset)
+#define C3CN_MSS_IDX(sk)	(CXGB3_TCP_CONN(sk)->mss_idx)
+#define C3CN_L2T(sk)		(CXGB3_TCP_CONN(sk)->l2t)
+#define C3CN_ULP_MODE(sk)	(CXGB3_TCP_CONN(sk)->ulp_mode)
+#define C3CN_DELAK_MODE(sk)	(CXGB3_TCP_CONN(sk)->delack_mode)
+#define C3CN_DELAK_SEQ(sk)	(CXGB3_TCP_CONN(sk)->delack_seq)
+#define C3CN_WR_MAX(sk)		(CXGB3_TCP_CONN(sk)->wr_max)
+#define C3CN_WR_AVAIL(sk)	(CXGB3_TCP_CONN(sk)->wr_avail)
+#define C3CN_WR_UNACKED(sk)	(CXGB3_TCP_CONN(sk)->wr_unacked)
+#define C3CN_CTRL_SKB_CACHE(sk)	(CXGB3_TCP_CONN(sk)->ctrl_skb_cache)
+
+/*
+ * Connection flags -- many to track some close related events.
+ */
+enum c3cn_flags {
+	C3CN_OFFLOADED,		/* connection offloaded */
+	C3CN_ABORT_RPL_RCVD,	/* received one ABORT_RPL_RSS message */
+	C3CN_ABORT_REQ_RCVD,	/* received one ABORT_REQ_RSS message */
+	C3CN_TX_MORE_DATA,	/* don't set the SHOVE bit */
+	C3CN_TX_WAIT_IDLE,	/* suspend Tx until in-flight data is ACKed */
+	C3CN_ABORT_SHUTDOWN,	/* shouldn't send more abort requests */
+	C3CN_ABORT_RPL_PENDING,	/* expecting an abort reply */
+	C3CN_CLOSE_CON_REQUESTED,	/* we've sent a close_conn_req */
+	C3CN_TX_DATA_SENT,	/* already sent a TX_DATA WR */
+	C3CN_TX_FAILOVER	/* Tx traffic failing over */
+};
+
+static inline void c3cn_set_flag(struct sock *sk, enum c3cn_flags flag)
+{
+	__set_bit(flag, &CXGB3_TCP_CONN(sk)->flags);
+}
+
+static inline void c3cn_reset_flag(struct sock *sk, enum c3cn_flags flag)
+{
+	__clear_bit(flag, &CXGB3_TCP_CONN(sk)->flags);
+}
+
+static inline int c3cn_flag(struct sock *sk, enum c3cn_flags flag)
+{
+	struct cxgb3i_tcp_conn *c3cn = CXGB3_TCP_CONN(sk);
+
+	if (c3cn == NULL)
+		return 0;
+	return test_bit(flag, &CXGB3_TCP_CONN(sk)->flags);
+}
+
+/*
+ * "Tunables" for each t3cdev.
+ */
+struct cxgb3i_tcp_tunables {
+	int max_host_sndbuf;	/* max host RAM consumed by a sndbuf */
+	int max_wrs;		/* max # of outstanding WRs per connection */
+	int rx_credit_thres;	/* min # of RX credits needed for RX_DATA_ACK */
+	int cong_alg;		/* Congestion control algorithm */
+	int delack;		/* delayed ACK control */
+	int tcp_window_scaling;
+};
+
+/*
+ * Per adapter data.  Linked off of each Ethernet device port on the adapter.
+ * Also available via the t3cdev structure since we have pointers to our port
+ * net_device's there ...
+ */
+struct cxgb3i_tcp_data {
+	struct list_head list;
+	struct t3cdev *cdev;
+	struct cxgb3_client *client;
+	struct adap_ports *ports;
+	struct cxgb3i_tcp_tunables conf;
+	unsigned int rx_page_size;
+	struct sk_buff_head deferq;
+	struct work_struct deferq_task;
+};
+#define NDEV2CDATA(ndev) (*(struct cxgb3i_tcp_data **)&(ndev)->ec_ptr)
+#define CXGB3_TCP_DATA(cdev) NDEV2CDATA((cdev)->lldev)
+#define CXGB3_TCP_TUNABLE(cdev, param) ((CXGB3_TCP_DATA(cdev))->conf.param)
+
+/*
+ * Primary API routines.
+ */
+
+int cxgb3i_tcp_init(cxgb3_cpl_handler_func *);
+void cxgb3i_tcp_add(struct t3cdev *, struct cxgb3_client *);
+void cxgb3i_tcp_remove(struct t3cdev *);
+
+int cxgb3i_tcp_connect(struct socket *, struct sockaddr *, int, int);
+void cxgb3i_tcp_cleanup_rbuf(struct sock *, int);
+int cxgb3i_tcp_sendskb(struct sock *, struct sk_buff *, int);
+
+/*
+ * Offload type IDs.
+ */
+enum {
+	TOE_ID_CHELSIO_T1 = 1,
+	TOE_ID_CHELSIO_T1C,
+	TOE_ID_CHELSIO_T2,
+	TOE_ID_CHELSIO_T3,
+	TOE_ID_CHELSIO_T3B,
+	TOE_ID_CHELSIO_T3C,
+};
+
+/*
+ * Definitions for sk_buff state and ULP mode management.
+ */
+
+struct cxgb3_skb_cb {
+	__u8 flags;		/* TCP-like flags */
+	__u8 ulp_mode;		/* ULP mode/submode of sk_buff */
+	__u32 seq;		/* TCP sequence number */
+	union {			/* ULP-specific fields */
+		struct {
+			__u32 ddigest;	/* ULP rx_data_ddp selected field */
+			__u32 pdulen;	/* ULP rx_data_ddp selected field */
+		} iscsi;
+	} ulp;
+	__u8 ulp_data[16];	/* scratch area for ULP */
+};
+
+#define CXGB3_TCP_SKB_CB(skb)	((struct cxgb3_skb_cb *)&((skb)->cb[0]))
+
+#define skb_ulp_mode(skb)	(CXGB3_TCP_SKB_CB(skb)->ulp_mode)
+#define skb_ulp_ddigest(skb)	(CXGB3_TCP_SKB_CB(skb)->ulp.iscsi.ddigest)
+#define skb_ulp_pdulen(skb)	(CXGB3_TCP_SKB_CB(skb)->ulp.iscsi.pdulen)
+#define skb_ulp_data(skb)	(CXGB3_TCP_SKB_CB(skb)->ulp_data)
+
+#define skb_ulp_lhdr(sk)	(C3CN_ULP_LHDR(sk))
+
+enum {
+	C3CB_FLAG_NEED_HDR = 1 << 0,	/* packet needs a TX_DATA_WR header */
+	C3CB_FLAG_NO_APPEND = 1 << 1,	/* don't grow this skb */
+	C3CB_FLAG_BARRIER = 1 << 2,	/* set TX_WAIT_IDLE after sending */
+	C3CB_FLAG_HOLD = 1 << 3,	/* skb not ready for Tx yet */
+	C3CB_FLAG_COMPL = 1 << 4,	/* request WR completion */
+	C3CB_FLAG_URG = 1 << 5,	/* TCP URG */
+};
+
+/*
+ * Definitions for managing deferred CPL replies from process context.
+ */
+
+typedef void (*defer_handler_t) (struct t3cdev *, struct sk_buff *);
+
+struct deferred_skb_cb {
+	defer_handler_t handler;
+	struct t3cdev *cdev;
+};
+
+#define DEFERRED_SKB_CB(skb) ((struct deferred_skb_cb *)(skb)->cb)
+
+/*
+ * Definitions for socket backlog processing ...
+ */
+
+/* Per-skb backlog handler.  Run when a socket's backlog is processed. */
+struct blog_skb_cb {
+	void (*backlog_rcv) (struct sock *, struct sk_buff *);
+	struct t3cdev *cdev;
+};
+
+#define BLOG_SKB_CB(skb) ((struct blog_skb_cb *)(skb)->cb)
+
+#define SET_BLOG_CPL_HANDLER(skb, hnd) BLOG_SKB_CB(skb)->backlog_rcv = (hnd)
+
+#define GL_SKB(skb) (skb)->sp
+
+/*
+ * Top-level CPL message processing used by most CPL messages that
+ * pertain to connections.
+ */
+static inline void process_cpl_msg(void (*fn)(struct sock *, struct sk_buff *),
+				   struct sock *sk, struct sk_buff *skb)
+{
+	bh_lock_sock(sk);
+	if (unlikely(sock_owned_by_user(sk))) {
+		SET_BLOG_CPL_HANDLER(skb, fn);
+		sk_add_backlog(sk, skb);
+	} else
+		fn(sk, skb);
+	bh_unlock_sock(sk);
+}
+
+/*
+ * Opaque version of structure the SGE stores at skb->head of TX_DATA packets
+ * and for which we must reserve space.
+ */
+struct sge_opaque_hdr {
+	void *dev;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+};
+
+/* for TX: a skb must have a headroom of at least TX_HEADER_LEN bytes */
+#define TX_HEADER_LEN \
+		(sizeof(struct tx_data_wr) + sizeof(struct sge_opaque_hdr))
+
+/*
+ * Useful utility functions and inlines.
+ */
+
+/*
+ * Returns true if the socket is in one of the supplied states.
+ */
+static inline unsigned int sk_in_state(const struct sock *sk,
+				       unsigned int states)
+{
+	return states & (1 << sk->sk_state);
+}
+
+#endif /* _CXGB3_TCP_H */
diff --git a/drivers/scsi/cxgb3i/cxgb3i_ulp2.c b/drivers/scsi/cxgb3i/cxgb3i_ulp2.c
new file mode 100644
index 0000000..2f52930
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_ulp2.c
@@ -0,0 +1,722 @@
+/*
+ * cxgb3i_ddp.c: Chelsio S3xx iSCSI driver.
+ *
+ * Copyright (c) 2008 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#include <linux/skbuff.h>
+#include "cxgb3i.h"
+#include "cxgb3i_ulp2.h"
+
+static struct page *pad_page;
+
+#define ULP2_PGIDX_MAX		4
+#define ULP2_4K_PAGE_SHIFT	12
+#define ULP2_4K_PAGE_MASK	(~((1UL << ULP2_4K_PAGE_SHIFT) - 1))
+static unsigned char ddp_page_order[ULP2_PGIDX_MAX];
+static unsigned long ddp_page_size[ULP2_PGIDX_MAX];
+static unsigned char ddp_page_shift[ULP2_PGIDX_MAX];
+static unsigned char sw_tag_idx_bits;
+static unsigned char sw_tag_age_bits;
+
+static void cxgb3i_ddp_page_init(void)
+{
+	int i;
+	unsigned long n = PAGE_SIZE >> ULP2_4K_PAGE_SHIFT;
+
+	if (PAGE_SIZE & (~ULP2_4K_PAGE_MASK)) {
+		cxgb3i_log_warn("PAGE_SIZE 0x%lx is not multiple of 4K, "
+				"ddp disabled.\n", PAGE_SIZE);
+		return;
+	}
+	n = __ilog2_u32(n);
+	for (i = 0; i < ULP2_PGIDX_MAX; i++, n++) {
+		ddp_page_order[i] = n;
+		ddp_page_shift[i] = ULP2_4K_PAGE_SHIFT + n;
+		ddp_page_size[i] = 1 << ddp_page_shift[i];
+		cxgb3i_log_debug("%d, order %u, shift %u, size 0x%lx.\n", i,
+				 ddp_page_order[i], ddp_page_shift[i],
+				 ddp_page_size[i]);
+	}
+
+	sw_tag_idx_bits = (__ilog2_u32(ISCSI_ITT_MASK)) + 1;
+	sw_tag_age_bits = (__ilog2_u32(ISCSI_AGE_MASK)) + 1;
+}
+
+static inline void ulp_mem_io_set_hdr(struct sk_buff *skb, unsigned int addr)
+{
+	struct ulp_mem_io *req = (struct ulp_mem_io *)skb->head;
+	req->wr.wr_lo = 0;
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_BYPASS));
+	req->cmd_lock_addr = htonl(V_ULP_MEMIO_ADDR(addr >> 5) |
+				   V_ULPTX_CMD(ULP_MEM_WRITE));
+	req->len = htonl(V_ULP_MEMIO_DATA_LEN(PPOD_SIZE >> 5) |
+			 V_ULPTX_NFLITS((PPOD_SIZE >> 3) + 1));
+}
+
+static int set_ddp_map(struct cxgb3i_adapter *snic, struct pagepod_hdr *hdr,
+		       unsigned int idx, unsigned int npods,
+		       struct scatterlist *sgl, unsigned int sgcnt)
+{
+	struct cxgb3i_ddp_info *ddp = &snic->ddp;
+	struct scatterlist *sg = sgl;
+	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ddp->llimit;
+	int i;
+
+	for (i = 0; i < npods; i++, pm_addr += PPOD_SIZE) {
+		struct sk_buff *skb;
+		struct pagepod *ppod;
+		int j, k;
+		skb =
+		    alloc_skb(sizeof(struct ulp_mem_io) + PPOD_SIZE,
+			      GFP_ATOMIC);
+		if (!skb)
+			return -ENOMEM;
+		skb_put(skb, sizeof(struct ulp_mem_io) + PPOD_SIZE);
+
+		ulp_mem_io_set_hdr(skb, pm_addr);
+		ppod =
+		    (struct pagepod *)(skb->head + sizeof(struct ulp_mem_io));
+		memcpy(&(ppod->hdr), hdr, sizeof(struct pagepod));
+		for (j = 0, k = i * 4; j < 5; j++, k++) {
+			if (k < sgcnt) {
+				ppod->addr[j] = cpu_to_be64(sg_dma_address(sg));
+				if (j < 4)
+					sg = sg_next(sg);
+			} else
+				ppod->addr[j] = 0UL;
+		}
+
+		skb->priority = CPL_PRIORITY_CONTROL;
+		cxgb3_ofld_send(snic->tdev, skb);
+	}
+	return 0;
+}
+
+static int clear_ddp_map(struct cxgb3i_adapter *snic, unsigned int idx,
+			 unsigned int npods)
+{
+	struct cxgb3i_ddp_info *ddp = &snic->ddp;
+	unsigned int pm_addr = (idx << PPOD_SIZE_SHIFT) + ddp->llimit;
+	int i;
+
+	for (i = 0; i < npods; i++, pm_addr += PPOD_SIZE) {
+		struct sk_buff *skb;
+		skb =
+		    alloc_skb(sizeof(struct ulp_mem_io) + PPOD_SIZE,
+			      GFP_ATOMIC);
+		if (!skb)
+			return -ENOMEM;
+		skb_put(skb, sizeof(struct ulp_mem_io) + PPOD_SIZE);
+		memset((skb->head + sizeof(struct ulp_mem_io)), 0, PPOD_SIZE);
+		ulp_mem_io_set_hdr(skb, pm_addr);
+		skb->priority = CPL_PRIORITY_CONTROL;
+		cxgb3_ofld_send(snic->tdev, skb);
+	}
+	return 0;
+}
+
+static int cxgb3i_ddp_sgl_check(struct scatterlist *sgl, unsigned int sgcnt)
+{
+	struct scatterlist *sg;
+	int i;
+
+	/* make sure the sgl is fit for ddp:
+	 *      each has the same page size, and
+	 *      first & last page do not need to be used completely, and
+	 *      the rest of page must be used completely
+	 */
+	for_each_sg(sgl, sg, sgcnt, i) {
+		if ((i && sg->offset) ||
+		    ((i != sgcnt - 1) &&
+		     (sg->length + sg->offset) != PAGE_SIZE))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static inline int ddp_find_unused_entries(struct cxgb3i_ddp_info *ddp,
+					  int start, int max, int count)
+{
+	unsigned int i, j;
+
+	spin_lock(&ddp->map_lock);
+	for (i = start; i <= max;) {
+		for (j = 0; j < count; j++) {
+			if (ddp->map[i + j])
+				break;
+		}
+		if (j == count) {
+			memset(&ddp->map[i], 1, count);
+			spin_unlock(&ddp->map_lock);
+			return i;
+		}
+		i += j + 1;
+	}
+	spin_unlock(&ddp->map_lock);
+	return -EBUSY;
+}
+
+static inline void ddp_unmark_entries(struct cxgb3i_ddp_info *ddp,
+				      int start, int count)
+{
+	spin_lock(&ddp->map_lock);
+	memset(&ddp->map[start], 0, count);
+	spin_unlock(&ddp->map_lock);
+}
+
+u32 cxgb3i_ddp_tag_reserve(struct cxgb3i_adapter *snic, unsigned int tid,
+			   u32 sw_tag, unsigned int xferlen,
+			   struct scatterlist *sgl, unsigned int sgcnt)
+{
+	struct cxgb3i_ddp_info *ddp = &snic->ddp;
+	struct pagepod_hdr hdr;
+	unsigned int npods;
+	int idx = -1, idx_max;
+	u32 tag;
+	int err;
+
+	if (!ddp || !sgcnt || xferlen < PAGE_SIZE)
+		return RESERVED_ITT;
+
+	err = cxgb3i_ddp_sgl_check(sgl, sgcnt);
+	if (err < 0)
+		return RESERVED_ITT;
+
+	npods = (sgcnt + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
+	idx_max = ddp->nppods - npods + 1;
+
+	if (ddp->idx_last == ddp->nppods)
+		idx = ddp_find_unused_entries(ddp, 0, idx_max, npods);
+	else {
+		idx = ddp_find_unused_entries(ddp, ddp->idx_last + 1, idx_max,
+					      npods);
+		if ((idx < 0) && (ddp->idx_last >= npods))
+			idx = ddp_find_unused_entries(ddp, 0,
+						      ddp->idx_last - npods + 1,
+						      npods);
+	}
+	if (idx < 0)
+		return RESERVED_ITT;
+
+	if (pci_map_sg(snic->pdev, sgl, sgcnt, PCI_DMA_FROMDEVICE) <= 0)
+		goto unmark_entries;
+
+	tag = sw_tag | (idx << snic->tag_format.rsvd_shift);
+
+	hdr.rsvd = 0;
+	hdr.vld_tid = htonl(F_PPOD_VALID | V_PPOD_TID(tid));
+	hdr.pgsz_tag_clr = htonl(tag);
+	hdr.maxoffset = htonl(xferlen);
+	hdr.pgoffset = htonl(sgl->offset);
+
+	if (set_ddp_map(snic, &hdr, idx, npods, sgl, sgcnt) < 0)
+		goto unmap_sgl;
+
+	ddp->idx_last = idx;
+	cxgb3i_log_debug("tid 0x%x, xfer %u, 0x%x -> ddp tag 0x%x (%u, %u).\n",
+			 tid, xferlen, sw_tag, tag, idx, npods);
+	return tag;
+
+unmap_sgl:
+	pci_unmap_sg(snic->pdev, sgl, sgcnt, PCI_DMA_FROMDEVICE);
+
+unmark_entries:
+	ddp_unmark_entries(ddp, idx, npods);
+	return RESERVED_ITT;
+}
+
+void cxgb3i_ddp_tag_release(struct cxgb3i_adapter *snic, u32 tag,
+			    struct scatterlist *sgl, unsigned int sgcnt)
+{
+	u32 idx = (tag >> snic->tag_format.rsvd_shift) &
+	    snic->tag_format.rsvd_mask;
+	unsigned int npods = (sgcnt + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
+
+	if (idx < snic->tag_format.rsvd_mask) {
+		cxgb3i_log_debug("ddp tag 0x%x, release idx 0x%x, npods %u.\n",
+				 tag, idx, npods);
+		clear_ddp_map(snic, idx, npods);
+		ddp_unmark_entries(&snic->ddp, idx, npods);
+		pci_unmap_sg(snic->pdev, sgl, sgcnt, PCI_DMA_FROMDEVICE);
+	}
+}
+
+int cxgb3i_conn_ulp_setup(struct cxgb3i_conn *cconn, int hcrc, int dcrc)
+{
+	struct iscsi_tcp_conn *tcp_conn = cconn->conn->dd_data;
+	struct cxgb3i_tcp_conn *c3cn = CXGB3_TCP_CONN(tcp_conn->sock->sk);
+	struct sk_buff *skb = alloc_skb(sizeof(struct cpl_set_tcb_field),
+					GFP_KERNEL | __GFP_NOFAIL);
+	struct cpl_set_tcb_field *req;
+	u32 submode = (hcrc ? 1 : 0) | (dcrc ? 2 : 0);
+
+	/* set up ulp submode and page size */
+	req = (struct cpl_set_tcb_field *)skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, c3cn->tid));
+	req->reply = V_NO_REPLY(1);
+	req->cpu_idx = 0;
+	req->word = htons(31);
+	req->mask = cpu_to_be64(0xFF000000);
+	/* the connection page size is always the same as ddp-pgsz0 */
+	req->val = cpu_to_be64(submode << 24);
+	skb->priority = CPL_PRIORITY_CONTROL;
+
+	cxgb3_ofld_send(c3cn->cdev, skb);
+	return 0;
+}
+
+static int cxgb3i_conn_read_pdu_skb(struct iscsi_conn *conn,
+				    struct sk_buff *skb)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct iscsi_segment *segment = &tcp_conn->in.segment;
+	struct iscsi_hdr *hdr = (struct iscsi_hdr *)tcp_conn->in.hdr_buf;
+	unsigned char *buf = (unsigned char *)hdr;
+	unsigned int offset = sizeof(struct iscsi_hdr);
+	int err;
+
+	cxgb3i_log_debug("conn 0x%p, skb 0x%p, len %u, flag 0x%x.\n",
+			 conn, skb, skb->len, skb_ulp_mode(skb));
+
+	/* read bhs */
+	err = skb_copy_bits(skb, 0, buf, sizeof(struct iscsi_hdr));
+	if (err < 0)
+		return err;
+	segment->copied = sizeof(struct iscsi_hdr);
+	/* read ahs */
+	if (hdr->hlength) {
+		unsigned int ahslen = hdr->hlength << 2;
+		/* Make sure we don't overflow */
+		if (sizeof(*hdr) + ahslen > sizeof(tcp_conn->in.hdr_buf))
+			return -ISCSI_ERR_AHSLEN;
+		err = skb_copy_bits(skb, offset, buf + offset, ahslen);
+		if (err < 0)
+			return err;
+		offset += ahslen;
+	}
+	/* header digest */
+	if (conn->hdrdgst_en)
+		offset += ISCSI_DIGEST_SIZE;
+
+	/* check header digest */
+	segment->status = (conn->hdrdgst_en &&
+			   (skb_ulp_mode(skb) & ULP2_FLAG_HCRC_ERROR)) ?
+	    ISCSI_SEGMENT_DGST_ERR : 0;
+
+	hdr->itt = ntohl(hdr->itt);
+	segment->total_copied = segment->total_size;
+	tcp_conn->in.hdr = hdr;
+	err = iscsi_tcp_hdr_dissect(conn, hdr);
+	if (err)
+		return err;
+
+	if (tcp_conn->in.datalen) {
+		segment = &tcp_conn->in.segment;
+		segment->status = (conn->datadgst_en &&
+				   (skb_ulp_mode(skb) & ULP2_FLAG_DCRC_ERROR)) ?
+		    ISCSI_SEGMENT_DGST_ERR : 0;
+		if (skb_ulp_mode(skb) & ULP2_FLAG_DATA_DDPED) {
+			cxgb3i_log_debug("opcode 0x%x, data %u, ddp'ed.\n",
+					 hdr->opcode & ISCSI_OPCODE_MASK,
+					 tcp_conn->in.datalen);
+			segment->total_copied = segment->total_size;
+		} else {
+			cxgb3i_log_debug("opcode 0x%x, data %u, not ddp'ed.\n",
+					 hdr->opcode & ISCSI_OPCODE_MASK,
+					 tcp_conn->in.datalen);
+			offset += sizeof(struct cpl_iscsi_hdr_norss);
+		}
+		while (segment->total_copied < segment->total_size) {
+			iscsi_tcp_segment_map(segment, 1);
+			err = skb_copy_bits(skb, offset, segment->data,
+					    segment->size);
+			iscsi_tcp_segment_unmap(segment);
+			if (err)
+				return err;
+			segment->total_copied += segment->size;
+			offset += segment->size;
+
+			if (segment->total_copied < segment->total_size)
+				iscsi_tcp_segment_init_sg(segment,
+							  sg_next(segment->sg),
+							  0);
+		}
+		err = segment->done(tcp_conn, segment);
+	}
+	return err;
+}
+
+static inline void tx_skb_setmode(struct sk_buff *skb, int hcrc, int dcrc)
+{
+	u8 submode = 0;
+	if (hcrc)
+		submode |= 1;
+	if (dcrc)
+		submode |= 2;
+	skb_ulp_mode(skb) = (ULP_MODE_ISCSI << 4) | submode;
+}
+
+int cxgb3i_conn_ulp2_xmit(struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+	struct iscsi_segment *hdr_seg = &tcp_conn->out.segment;
+	struct iscsi_segment *data_seg = &tcp_conn->out.data_segment;
+	struct sock *sk = tcp_conn->sock->sk;
+	unsigned int hdrlen = hdr_seg->total_size;
+	unsigned int datalen = data_seg->total_size;
+	unsigned int padlen = iscsi_padding(datalen);
+	unsigned int copymax = SKB_MAX_HEAD(TX_HEADER_LEN);
+	unsigned int copylen;
+	struct sk_buff *skb;
+	unsigned char *dst;
+	int err = -EAGAIN;
+
+	if (conn->suspend_tx)
+		return 0;
+
+	if (data_seg->data && ((datalen + padlen) < copymax))
+		copylen = hdrlen + datalen + padlen;
+	else
+		copylen = hdrlen;
+
+	/* supports max. 16K pdus, so one skb is enough to hold all the data */
+	skb = alloc_skb(TX_HEADER_LEN + copylen, sk->sk_allocation);
+	if (!skb)
+		return -EAGAIN;
+
+	skb_reserve(skb, TX_HEADER_LEN);
+	skb_put(skb, copylen);
+	dst = skb->data;
+
+	tx_skb_setmode(skb, conn->hdrdgst_en, datalen ? conn->datadgst_en : 0);
+
+	memcpy(dst, hdr_seg->data, hdrlen);
+	dst += hdrlen;
+
+	if (!datalen)
+		goto send_pdu;
+
+	if (data_seg->data) {
+		/* data is in a linear buffer */
+		if (copylen > hdrlen) {
+			/* data fits in the skb's headroom */
+			memcpy(dst, data_seg->data, datalen);
+			dst += datalen;
+			if (padlen)
+				memset(dst, 0, padlen);
+		} else {
+			unsigned int offset = 0;
+			while (datalen) {
+				struct page *page =
+				    alloc_pages(sk->sk_allocation, 0);
+				int idx = skb_shinfo(skb)->nr_frags;
+				skb_frag_t *frag = &skb_shinfo(skb)->frags[idx];
+
+				if (!page)
+					goto free_skb;
+
+				frag->page = page;
+				frag->page_offset = 0;
+				if (datalen > PAGE_SIZE)
+					frag->size = PAGE_SIZE;
+				else
+					frag->size = datalen;
+				memcpy(page_address(page),
+				       data_seg->data + offset, frag->size);
+
+				skb_shinfo(skb)->nr_frags++;
+				datalen -= frag->size;
+				offset += frag->size;
+			}
+		}
+	} else {
+		struct scatterlist *sg = data_seg->sg;
+		unsigned int offset = data_seg->sg_offset;
+		while (datalen) {
+			int idx = skb_shinfo(skb)->nr_frags;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[idx];
+			struct page *pg = sg_page(sg);
+
+			get_page(pg);
+			frag->page = pg;
+			frag->page_offset = offset + sg->offset;
+			frag->size = min(sg->length, datalen);
+
+			offset = 0;
+			skb_shinfo(skb)->nr_frags++;
+			datalen -= frag->size;
+			sg = sg_next(sg);
+		}
+	}
+
+	if (skb_shinfo(skb)->nr_frags) {
+		if (padlen) {
+			int idx = skb_shinfo(skb)->nr_frags;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[idx];
+			frag->page = pad_page;
+			frag->page_offset = 0;
+			frag->size = padlen;
+			skb_shinfo(skb)->nr_frags++;
+		}
+		datalen = data_seg->total_size + padlen;
+		skb->data_len += datalen;
+		skb->truesize += datalen;
+		skb->len += datalen;
+	}
+
+send_pdu:
+	err = cxgb3i_tcp_sendskb(tcp_conn->sock->sk, skb,
+				 MSG_DONTWAIT | MSG_NOSIGNAL);
+	if (err > 0) {
+		int pdulen = hdrlen + datalen + padlen;
+		if (conn->hdrdgst_en)
+			pdulen += ISCSI_DIGEST_SIZE;
+		if (datalen && conn->datadgst_en)
+			pdulen += ISCSI_DIGEST_SIZE;
+
+		hdr_seg->total_copied = hdr_seg->total_size;
+		if (datalen)
+			data_seg->total_copied = data_seg->total_size;
+		conn->txdata_octets += pdulen;
+		return pdulen;
+	}
+
+free_skb:
+	kfree_skb(skb);
+	if (err != -EAGAIN) {
+		cxgb3i_log_error("conn 0x%p, xmit err %d.\n", conn, err);
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+		return err;
+	}
+	return -EAGAIN;
+}
+
+int cxgb3i_ulp2_init(void)
+{
+	pad_page = alloc_page(GFP_KERNEL);
+	if (!pad_page)
+		return -ENOMEM;
+	memset(page_address(pad_page), 0, PAGE_SIZE);
+	cxgb3i_ddp_page_init();
+	return 0;
+}
+
+void cxgb3i_ulp2_cleanup(void)
+{
+	if (pad_page) {
+		__free_page(pad_page);
+		pad_page = NULL;
+	}
+}
+
+static void cxgb3i_sk_data_ready(struct sock *sk, int flag)
+{
+	struct sk_buff *skb;
+	unsigned int read = 0;
+	struct iscsi_conn *conn = sk->sk_user_data;
+	int err = 0;
+
+	if (unlikely(conn->suspend_rx)) {
+		cxgb3i_log_debug("conn %d Rx suspended!\n", conn->id);
+		return;
+	}
+	cxgb3i_log_debug("sk 0x%p, flag %d\n", sk, flag);
+
+	read_lock(&sk->sk_callback_lock);
+	skb = skb_peek(&sk->sk_receive_queue);
+	while (!err && skb) {
+		__skb_unlink(skb, &sk->sk_receive_queue);
+		read += skb_ulp_pdulen(skb);
+		err = cxgb3i_conn_read_pdu_skb(conn, skb);
+		__kfree_skb(skb);
+		skb = skb_peek(&sk->sk_receive_queue);
+	}
+	read_unlock(&sk->sk_callback_lock);
+	if (tcp_sk(sk)) {
+		tcp_sk(sk)->copied_seq += read;
+		cxgb3i_tcp_cleanup_rbuf(sk, read);
+	}
+	conn->rxdata_octets += read;
+
+	if (err) {
+		cxgb3i_log_info("conn 0x%p rx failed err %d.\n", conn, err);
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+	}
+}
+
+static void cxgb3i_sk_write_space(struct sock *sk)
+{
+	struct iscsi_conn *conn = (struct iscsi_conn *)sk->sk_user_data;
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+
+	tcp_conn->old_write_space(sk);
+	cxgb3i_log_debug("sk 0x%p, cid %d.\n", sk, conn->id);
+	scsi_queue_work(conn->session->host, &conn->xmitwork);
+}
+
+static void cxgb3i_sk_state_change(struct sock *sk)
+{
+	struct iscsi_tcp_conn *tcp_conn;
+	struct iscsi_conn *conn;
+	struct iscsi_session *session;
+	void (*old_state_change) (struct sock *);
+
+	cxgb3i_log_debug("sk 0x%p, state %d\n", sk, sk->sk_state);
+
+	read_lock(&sk->sk_callback_lock);
+	conn = (struct iscsi_conn *)sk->sk_user_data;
+	session = conn->session;
+	if ((sk->sk_state == TCP_CLOSE_WAIT || sk->sk_state == TCP_CLOSE) &&
+	    !atomic_read(&sk->sk_rmem_alloc))
+		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+	tcp_conn = conn->dd_data;
+	old_state_change = tcp_conn->old_state_change;
+	read_unlock(&sk->sk_callback_lock);
+
+	old_state_change(sk);
+}
+
+void cxgb3i_sk_set_callbacks(struct sock *sk, struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+
+	write_lock_bh(&sk->sk_callback_lock);
+	sk->sk_user_data = conn;
+	tcp_conn->old_data_ready = sk->sk_data_ready;
+	tcp_conn->old_state_change = sk->sk_state_change;
+	tcp_conn->old_write_space = sk->sk_write_space;
+	sk->sk_data_ready = cxgb3i_sk_data_ready;
+	sk->sk_state_change = cxgb3i_sk_state_change;
+	sk->sk_write_space = cxgb3i_sk_write_space;
+	write_unlock_bh(&sk->sk_callback_lock);
+}
+
+void cxgb3i_sk_restore_callbacks(struct sock *sk, struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+
+	write_lock_bh(&sk->sk_callback_lock);
+	sk->sk_user_data = NULL;
+	sk->sk_data_ready = tcp_conn->old_data_ready;
+	sk->sk_state_change = tcp_conn->old_state_change;
+	sk->sk_write_space = tcp_conn->old_write_space;
+	sk->sk_no_check = 0;
+	write_unlock_bh(&sk->sk_callback_lock);
+}
+
+/**
+ * Allocate a chunk of memory using kmalloc or, if that fails, vmalloc.
+ * The allocated memory is cleared.
+ */
+static void *cxgb3i_alloc_big_mem(unsigned long size)
+{
+	void *p = kmalloc(size, GFP_KERNEL);
+	if (!p)
+		p = vmalloc(size);
+	memset(p, 0, size);
+	return p;
+}
+
+/**
+ * Free memory allocated through cxgb3i_alloc_big_mem().
+ */
+static void cxgb3i_free_big_mem(void *addr)
+{
+	unsigned long p = (unsigned long)addr;
+	if (p >= VMALLOC_START && p < VMALLOC_END)
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
+int cxgb3i_adapter_ulp_init(struct cxgb3i_adapter *snic)
+{
+	struct t3cdev *tdev = snic->tdev;
+	struct cxgb3i_ddp_info *ddp = &snic->ddp;
+	struct ulp_iscsi_info uinfo;
+	unsigned int ppmax, bits, max_bits;
+	int i, err;
+
+	spin_lock_init(&ddp->map_lock);
+
+	err = tdev->ctl(tdev, ULP_ISCSI_GET_PARAMS, &uinfo);
+	if (err < 0) {
+		cxgb3i_log_error("%s, failed to get iscsi param err=%d.\n",
+				 tdev->name, err);
+		return err;
+	}
+
+	ppmax = (uinfo.ulimit - uinfo.llimit + 1) >> PPOD_SIZE_SHIFT;
+	max_bits = min(PPOD_IDX_MAX_SIZE,
+		       (32 - sw_tag_idx_bits - sw_tag_age_bits));
+	bits = __ilog2_u32(ppmax) + 1;
+	if (bits > max_bits)
+		bits = max_bits;
+	ppmax = (1 << bits) - 1;
+
+	snic->tx_max_size = uinfo.max_txsz;
+	snic->rx_max_size = uinfo.max_rxsz;
+	snic->tag_format.idx_bits = sw_tag_idx_bits;
+	snic->tag_format.age_bits = sw_tag_age_bits;
+	snic->tag_format.rsvd_bits = bits;
+	snic->tag_format.rsvd_shift = PPOD_IDX_SHIFT;
+	snic->tag_format.rsvd_mask = (1 << snic->tag_format.rsvd_bits) - 1;
+
+	cxgb3i_log_debug("snic nppods %u, rsvd shift %u, bits %u, mask 0x%x.\n",
+			 ppmax, snic->tag_format.rsvd_shift,
+			 snic->tag_format.rsvd_bits,
+			 snic->tag_format.rsvd_mask);
+
+	ddp->map = cxgb3i_alloc_big_mem(ppmax);
+	if (!ddp->map) {
+		cxgb3i_log_warn("snic unable to alloc ddp ppod 0x%u, "
+				"ddp disabled.\n", ppmax);
+		return 0;
+	}
+	ddp->llimit = uinfo.llimit;
+	ddp->ulimit = uinfo.ulimit;
+
+	uinfo.tagmask =
+	    snic->tag_format.rsvd_mask << snic->tag_format.rsvd_shift;
+	for (i = 0; i < ULP2_PGIDX_MAX; i++)
+		uinfo.pgsz_factor[i] = ddp_page_order[i];
+
+	err = tdev->ctl(tdev, ULP_ISCSI_SET_PARAMS, &uinfo);
+	if (err < 0) {
+		cxgb3i_log_warn("snic unable to set iscsi param err=%d, "
+				"ddp disabled.\n", err);
+		goto free_ppod_map;
+	}
+
+	ddp->nppods = ppmax;
+	ddp->idx_last = ppmax;
+
+	tdev->ulp_iscsi = ddp;
+
+	return 0;
+
+free_ppod_map:
+	cxgb3i_free_big_mem(ddp->map);
+	return 0;
+}
+
+void cxgb3i_adapter_ulp_cleanup(struct cxgb3i_adapter *snic)
+{
+	u8 *map = snic->ddp.map;
+	if (map) {
+		snic->tdev->ulp_iscsi = NULL;
+		spin_lock(&snic->lock);
+		snic->ddp.map = NULL;
+		spin_unlock(&snic->lock);
+		cxgb3i_free_big_mem(map);
+	}
+}
diff --git a/drivers/scsi/cxgb3i/cxgb3i_ulp2.h b/drivers/scsi/cxgb3i/cxgb3i_ulp2.h
new file mode 100644
index 0000000..b38df09
--- /dev/null
+++ b/drivers/scsi/cxgb3i/cxgb3i_ulp2.h
@@ -0,0 +1,102 @@
+/*
+ * cxgb3i_ulp2.h: Chelsio S3xx iSCSI driver.
+ *
+ * Copyright (c) 2008 Chelsio Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#ifndef __CXGB3I_ULP2_H__
+#define __CXGB3I_ULP2_H__
+
+#define PPOD_PAGES_MAX		4
+#define PPOD_PAGES_SHIFT	2	/* 4 pages per pod */
+
+struct pagepod_hdr {
+	u32 vld_tid;
+	u32 pgsz_tag_clr;
+	u32 maxoffset;
+	u32 pgoffset;
+	u64 rsvd;
+};
+
+struct pagepod {
+	struct pagepod_hdr hdr;
+	u64 addr[PPOD_PAGES_MAX + 1];
+};
+
+#define PPOD_SIZE		sizeof(struct pagepod)	/* 64 */
+#define PPOD_SIZE_SHIFT		6
+
+#define PPOD_COLOR_SHIFT	0
+#define PPOD_COLOR_SIZE		6
+#define PPOD_COLOR_MASK		((1 << PPOD_COLOR_SIZE) - 1)
+
+#define PPOD_IDX_SHIFT		PPOD_COLOR_SIZE
+#define PPOD_IDX_MAX_SIZE	24
+
+#define S_PPOD_TID    0
+#define M_PPOD_TID    0xFFFFFF
+#define V_PPOD_TID(x) ((x) << S_PPOD_TID)
+
+#define S_PPOD_VALID    24
+#define V_PPOD_VALID(x) ((x) << S_PPOD_VALID)
+#define F_PPOD_VALID    V_PPOD_VALID(1U)
+
+#define S_PPOD_COLOR    0
+#define M_PPOD_COLOR    0x3F
+#define V_PPOD_COLOR(x) ((x) << S_PPOD_COLOR)
+
+#define S_PPOD_TAG    6
+#define M_PPOD_TAG    0xFFFFFF
+#define V_PPOD_TAG(x) ((x) << S_PPOD_TAG)
+
+#define S_PPOD_PGSZ    30
+#define M_PPOD_PGSZ    0x3
+#define V_PPOD_PGSZ(x) ((x) << S_PPOD_PGSZ)
+
+struct cpl_iscsi_hdr_norss {
+	union opcode_tid ot;
+	u16 pdu_len_ddp;
+	u16 len;
+	u32 seq;
+	u16 urg;
+	u8 rsvd;
+	u8 status;
+};
+
+struct cpl_rx_data_ddp_norss {
+	union opcode_tid ot;
+	u16 urg;
+	u16 len;
+	u32 seq;
+	u32 nxt_seq;
+	u32 ulp_crc;
+	u32 ddp_status;
+};
+
+#define RX_DDP_STATUS_IPP_SHIFT		27	/* invalid pagepod */
+#define RX_DDP_STATUS_TID_SHIFT		26	/* tid mismatch */
+#define RX_DDP_STATUS_COLOR_SHIFT	25	/* color mismatch */
+#define RX_DDP_STATUS_OFFSET_SHIFT	24	/* offset mismatch */
+#define RX_DDP_STATUS_ULIMIT_SHIFT	23	/* ulimit error */
+#define RX_DDP_STATUS_TAG_SHIFT		22	/* tag mismatch */
+#define RX_DDP_STATUS_DCRC_SHIFT	21	/* dcrc error */
+#define RX_DDP_STATUS_HCRC_SHIFT	20	/* hcrc error */
+#define RX_DDP_STATUS_PAD_SHIFT		19	/* pad error */
+#define RX_DDP_STATUS_PPP_SHIFT		18	/* pagepod parity error */
+#define RX_DDP_STATUS_LLIMIT_SHIFT	17	/* llimit error */
+#define RX_DDP_STATUS_DDP_SHIFT		16	/* ddp'able */
+#define RX_DDP_STATUS_PMM_SHIFT		15	/* pagepod mismatch */
+
+#define ULP2_FLAG_DATA_READY		0x1
+#define ULP2_FLAG_DATA_DDPED		0x2
+#define ULP2_FLAG_HCRC_ERROR		0x10
+#define ULP2_FLAG_DCRC_ERROR		0x20
+#define ULP2_FLAG_PAD_ERROR		0x40
+
+#endif
diff --git a/security/security.c b/security/security.c
index 59838a9..bf27d33 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1055,6 +1055,7 @@ void security_inet_conn_established(struct sock *sk,
 {
 	security_ops->inet_conn_established(sk, skb);
 }
+EXPORT_SYMBOL(security_inet_conn_established);
 
 #endif	/* CONFIG_SECURITY_NETWORK */
 






