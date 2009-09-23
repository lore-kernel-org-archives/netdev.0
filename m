From: sjur.brandeland@stericsson.com
Subject: [PATCH 5/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:26 +0200
Message-ID: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55448 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbZIWSb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:28 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003QMQ0HF560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:29 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF00JEJQ0FGQD1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>

Signed-off-by: sjur.brandeland@stericsson.com

---
 net/caif/Kconfig            |   61 +++
 net/caif/Makefile           |   62 +++
 net/caif/caif_chnlif.c      |  219 ++++++++
 net/caif/caif_chr.c         |  378 ++++++++++++++
 net/caif/caif_config_util.c |  167 +++++++
 net/caif/chnl_chr.c         | 1161 +++++++++++++++++++++++++++++++++++++++++++
 net/caif/chnl_net.c         |  464 +++++++++++++++++
 7 files changed, 2512 insertions(+), 0 deletions(-)
 create mode 100644 net/caif/Kconfig
 create mode 100644 net/caif/Makefile
 create mode 100644 net/caif/caif_chnlif.c
 create mode 100644 net/caif/caif_chr.c
 create mode 100644 net/caif/caif_config_util.c
 create mode 100644 net/caif/chnl_chr.c
 create mode 100644 net/caif/chnl_net.c

diff --git a/net/caif/Kconfig b/net/caif/Kconfig
new file mode 100644
index 0000000..24151c1
--- /dev/null
+++ b/net/caif/Kconfig
@@ -0,0 +1,61 @@
+#
+# CAIF net configurations
+#
+
+#menu "Caif Support"
+comment "CAIF Support"
+
+menuconfig CAIF
+	tristate "Enable Caif support"
+	default m
+	---help---
+	Say Y here if you need to a phone modem that uses CAIF as transport
+	You will also need to say yes to anny caif physical devices that your platform
+	supports.
+	This can be built as either built in or as a module, if you select to build it as module
+	the other CAIF parts also needs to built as modules
+	See Documentation/CAIF for a further explanation on how to use and configure.
+
+if CAIF
+
+config CAIF_CHARDEV
+	tristate "CAIF character device"
+	default CAIF
+	---help---
+	Say Y if you will be using the CAIF character devices,
+	This is needed for AT type channels
+	If you select to build it as a built in then the main caif device must also be a builtin
+	If unsure say Y
+
+config CAIF_NETDEV
+	tristate "CAIF Network device"
+	default CAIF
+	---help---
+	If you select to build it as a built in then the main caif device must also be a builtin
+	Say Y if you will be using the CAIF based network device
+	If unsure say Y
+
+
+config  CAIF_USE_PLAIN
+	bool  "Use plain buffers instead of SKB in caif"
+	default n
+	---help---
+	Use plain buffer to transport data
+	Select what type of internal buffering CAIF should use,
+	skb or plain,
+	If unsure say y
+
+config  CAIF_DEBUG
+	bool "Enable Debug"
+	default n
+	--- help ---
+	Enable the inclusion of debug code in the caif stack
+	be aware that doing this will impact performance
+	If unsure say n here.
+
+# Include physical drivers
+# should be broken out into its own config file
+# source "drivers/net/caif/Kconfig"
+source "drivers/net/caif/Kconfig"
+endif
+#endmenu
diff --git a/net/caif/Makefile b/net/caif/Makefile
new file mode 100644
index 0000000..49696ab
--- /dev/null
+++ b/net/caif/Makefile
@@ -0,0 +1,62 @@
+ifeq ($(CONFIG_CAIF_USE_PLAIN),1)
+CFPKT:=plain
+else
+CFPKT:=skbuff
+CAIF_FLAGS+=-DCAIF_USE_SKB
+endif
+
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_FLAGS+=-DCAIF_DEBUG_ON
+endif
+
+
+ccflags-y := -DCAIF_KERNEL $(CAIF_FLAGS) -Iinclude/net/caif/ -Iinclude/net/caif/generic/ -Iinclude/linux/caif/
+
+
+caif-objs :=  caif_chr.o caif_chnlif.o  caif_config_util.o \
+	generic/cfcnfg.o generic/cfmuxl.o generic/cfctrl.o \
+	generic/cffrml.o generic/cfveil.o generic/cflist.o  \
+	generic/fcs.o    generic/cfserl.o generic/cfdgml.o \
+	generic/cfspil.o generic/cfrfml.o generic/cfvidl.o \
+	generic/cfmsll.o generic/cfutill.o  generic/cfshml.o \
+	generic/cfloopcfg.o  generic/cflooplayer.o generic/cfsrvl.o \
+	generic/cfpkt_$(CFPKT).o
+
+
+clean-dirs:= .tmp_versions
+
+clean-files:= Module.symvers modules.order *.cmd *~ \
+	generic/loopback/Module.symvers \
+	generic/loopback/modules.order \
+	generic/loopback/*.cmd \
+	generic/loopback/*.o \
+	generic/loopback/*~ \
+	generic/Module.symvers \
+	generic/modules.order \
+	generic/*.cmd \
+	generic/*.o \
+	generic/*~
+
+
+# Main caif module
+obj-$(CONFIG_CAIF) += caif.o
+
+# Character device
+obj-$(CAIF_CHRDEV) += chnl_chr.o
+
+# Net device
+obj-$(CAIF_NETDEV) += chnl_net.o
+
+export-objs := caif_chr.o
+
+## Indent..  to remove all DOS cruft like CRLF and trailing spaces, and to standardize the indenting style
+indent:
+	${MAKE} -C generic indent
+	sh -c 'for F in *.[ch]; do cat $$F | tr -d "\r" |tr -c '\015'| sed "s/[ \t]*$$//;" > $$F.tmp; mv $$F.tmp $$F; done'
+	${INDENT} -kr -i8 *.[ch]
+
+clean:
+	${MAKE} -C generic clean
+	rm generic/modules.order  generic/Module.symvers generic/*.cmd generic/*~ \
+	generic/modules.order generic/Module.symvers \
+	generic/*.o generic/loopback/*.o
diff --git a/net/caif/caif_chnlif.c b/net/caif/caif_chnlif.c
new file mode 100644
index 0000000..e53ca7a
--- /dev/null
+++ b/net/caif/caif_chnlif.c
@@ -0,0 +1,219 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+#include <linux/skbuff.h>
+#include "caif_kernel.h"
+#include "caif_layer.h"
+#include "caif_config_util.h"
+#include "caif_log.h"
+#include "cfpkt.h"
+#include "cfcnfg.h"
+#include "cfglue.h"
+
+
+
+struct caif_kernelif {
+	layer_t layer;
+	struct caif_device *dev;
+	cfctrl_link_param_t param;
+};
+static cfcnfg_t *cnfg;
+/**
+ * func chnlif_set_cnfg - Set the global config
+ * @cfg:	Config structure to set
+*/
+
+void chnlif_set_cnfg(cfcnfg_t *cfg)
+{
+	cnfg = cfg;
+}
+EXPORT_SYMBOL(chnlif_set_cnfg);
+
+/**
+ * func caif_create_skb - Creates a caif skb buffer
+ * @data:	data to add to buffer
+ * @data_length: lenht of data
+*/
+struct sk_buff *caif_create_skb(unsigned char *data, unsigned int data_length)
+{
+	/* NOTE: Make room for CAIF headers when using SKB inside CAIF. */
+	struct sk_buff *skb =
+	    alloc_skb(data_length + CAIF_SKB_HEAD_RESERVE +
+		      CAIF_SKB_TAIL_RESERVE, GFP_ATOMIC);
+	skb_reserve(skb, CAIF_SKB_HEAD_RESERVE);
+	if (skb == NULL)
+		return NULL;
+
+	memcpy(skb_put(skb, data_length), data, data_length);
+	return skb;
+}
+EXPORT_SYMBOL(caif_create_skb);
+
+int
+caif_extract_and_destroy_skb(struct sk_buff *skb, unsigned char *data,
+			     unsigned int max_length)
+{
+	unsigned int len;
+	len = skb->len;
+	skb_linearize(skb);
+	if (skb->len > max_length)
+		return CFGLU_EOVERFLOW;
+	memcpy(data, skb->data, skb->len);
+	kfree_skb(skb);
+	return len;
+}
+EXPORT_SYMBOL(caif_extract_and_destroy_skb);
+
+/* NOTE: transmit takes ownership of the SKB.
+ *       i.e. transmit only fails on severe errors.
+ *       flow_off is not checked on transmit this is clients responcibility.
+ */
+
+int caif_transmit(struct caif_device *dev, struct sk_buff *skb)
+{
+	struct caif_kernelif *chnlif =
+	    (struct caif_kernelif *) dev->_caif_handle;
+	cfpkt_t *pkt;
+#ifdef CAIF_USE_SKB
+	pkt = cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
+#else
+	pkt = cfpkt_create(skb->len);
+	cfpkt_add_body(pkt, skb->data, skb->len);
+	kfree_skb(skb);
+#endif
+	CAIFLOG_TRACE2("Transmit (%p)", chnlif->layer.dn);
+	return chnlif->layer.dn->transmit(chnlif->layer.dn, NULL, pkt);
+}
+EXPORT_SYMBOL(caif_transmit);
+
+
+int caif_flow_control(struct caif_device *dev, enum caif_flowctrl flow)
+{
+	caif_modemcmd_t modemcmd;
+	struct caif_kernelif *chnlif =
+	    (struct caif_kernelif *) dev->_caif_handle;
+	switch (flow) {
+	case CAIF_FLOWCTRL_ON:
+		modemcmd = CAIF_MODEMCMD_FLOW_ON_REQ;
+		break;
+	case CAIF_FLOWCTRL_OFF:
+		modemcmd = CAIF_MODEMCMD_FLOW_OFF_REQ;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return chnlif->layer.dn->modemcmd(chnlif->layer.dn, modemcmd);
+}
+EXPORT_SYMBOL(caif_flow_control);
+
+
+static int chnlif_receive(layer_t *layr, struct _cfpkt_t *cfpkt)
+{
+	/* FIXME: Use container of */
+	struct caif_kernelif *chnl = (struct caif_kernelif *) layr;
+
+	struct sk_buff *skb;
+#ifndef CAIF_USE_SKB
+	unsigned int pktlen = cfpkt_getlen(cfpkt);
+	unsigned int actual_len;
+	skb = alloc_skb(pktlen, GFP_ATOMIC);
+	if (skb == NULL)
+		return CFGLU_ENOMEM;
+
+	/* Extract data from the caif packet and copy it to the skb. */
+	cfpkt_extract(cfpkt, skb_put(skb, pktlen), pktlen, &actual_len);
+	cfglu_assert(pktlen == actual_len);
+	cfpkt_destroy(cfpkt);
+#else
+	skb = (struct sk_buff *) cfpkt_tonative(cfpkt);
+#endif
+	chnl->dev->receive_cb(chnl->dev, skb);
+	return CFGLU_EOK;
+}
+
+static void chnlif_flowctrl(layer_t *layr, caif_ctrlcmd_t ctrl, int phyid)
+{
+	struct caif_kernelif *chnl = (struct caif_kernelif *) layr;
+	enum caif_control ctl;
+
+	CAIFLOG_TRACE("Flow Control received %d\n", ctrl);
+
+	switch (ctrl) {
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		ctl = CAIF_CONTROL_FLOW_OFF;
+		break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		ctl = CAIF_CONTROL_FLOW_ON;
+		break;
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		ctl = CAIF_CONTROL_REMOTE_SHUTDOWN;
+		break;
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		ctl = CAIF_CONTROL_DEV_DEINIT;
+		chnl->dev->_caif_handle = NULL;
+		chnl->dev->control_cb(chnl->dev, ctl);
+		memset(chnl, 0, sizeof(chnl));
+		cfglu_free(chnl);
+		return;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		ctl = CAIF_CONTROL_DEV_INIT;
+		break;
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		ctl = CAIF_CONTROL_DEV_INIT_FAILED;
+		break;
+	default:
+		return;
+	}
+	chnl->dev->control_cb(chnl->dev, ctl);
+}
+
+
+int caif_add_device(struct caif_device *dev)
+{
+	int ret;
+	struct caif_kernelif *chnl = cfglu_alloc(sizeof(struct caif_kernelif));
+	chnl->dev = dev;
+	chnl->layer.ctrlcmd = chnlif_flowctrl;
+	chnl->layer.receive = chnlif_receive;
+	ret =
+	    channel_config_2_link_param(cnfg, &dev->caif_config, &chnl->param);
+
+
+	if (ret < 0) {
+		CAIFLOG_WARN("Bad Channel Configuration\n");
+		ret = CFGLU_EBADPARAM;
+		goto error;
+	}
+
+	if (!cfcnfg_add_adaptation_layer(cnfg, &chnl->param, &chnl->layer)) {
+		ret = CFGLU_ENOTCONN;
+		goto error;
+	}
+
+	dev->_caif_handle = chnl;
+
+	return CFGLU_EOK;
+error:
+	chnl->dev->_caif_handle = NULL;
+	memset(chnl, 0, sizeof(chnl));
+	cfglu_free(chnl);
+	return ret;
+}
+EXPORT_SYMBOL(caif_add_device);
+
+int caif_remove_device(struct caif_device *caif_dev)
+{
+
+	struct caif_kernelif *chnl =
+	    container_of(caif_dev->_caif_handle, struct caif_kernelif, layer);
+	bool ok = cfcnfg_del_adapt_layer(cnfg, &chnl->layer);
+	return ok ? CFGLU_EOK : CFGLU_EIO;
+}
+EXPORT_SYMBOL(caif_remove_device);
diff --git a/net/caif/caif_chr.c b/net/caif/caif_chr.c
new file mode 100644
index 0000000..92c60cd
--- /dev/null
+++ b/net/caif/caif_chr.c
@@ -0,0 +1,378 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/miscdevice.h>
+#include <linux/ioctl.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/uaccess.h>
+
+#include "caif_actions.h"
+#include "caif_chr.h"
+#include "cfloopcfg.h"
+#include "cfpkt.h"
+#include "cfcnfg.h"
+#include "caif_config_util.h"
+#include "caif_log.h"
+#include "caif_ioctl.h"
+
+#define caif_assert(assert) BUG_ON(!(assert))
+
+MODULE_LICENSE("GPL");
+int (*chrdev_mgmt_func) (int action, union caif_action *param);
+int (*netdev_mgmt_func) (int action, union caif_action *param);
+
+struct caif_chr {
+	cfcnfg_t *cfg;
+	cfloopcfg_t *loop;
+	struct miscdevice misc;
+};
+
+int caif_dbg_level = CAIFLOG_LEVEL_WARNING;
+EXPORT_SYMBOL(caif_dbg_level);
+
+static struct caif_chr caifdev;
+
+struct class caif_class = {
+	.name = "caif",
+};
+
+static ssize_t dbg_lvl_show(struct class *class, char *buf)
+{
+	return sprintf(buf, "%d\n", caif_dbg_level);
+}
+
+static ssize_t dbg_lvl_store(struct class *class, const char *buf,
+			     size_t count)
+{
+	int val;
+
+	sscanf(buf, "%d", &val);
+	if ((val < CAIFLOG_MIN_LEVEL) || (val > CAIFLOG_MAX_LEVEL)) {
+		printk(KERN_WARNING "caif_dbg_level: Invalid value\n");
+		return -EINVAL;
+	}
+
+	caif_dbg_level = val;
+
+	return count;
+}
+
+CLASS_ATTR(dbg_lvl, 0644, dbg_lvl_show, dbg_lvl_store);
+
+int caifdev_open(struct inode *inode, struct file *filp)
+{
+	printk(KERN_WARNING "caifdev_open: Entered\n");
+	return 0;
+}
+
+int caifdev_release(struct inode *inode, struct file *filp)
+{
+	printk(KERN_WARNING "caifdev_release: Entered\n");
+	return 0;
+}
+
+static int caifdev_ioctl(struct inode *inode, struct file *filp,
+			 unsigned int cmd, unsigned long argp)
+{
+	union caif_action param;
+	int ret;
+	int (*mgmt_func) (int action, union caif_action *param) = NULL;
+	int type;
+	int size;
+	int operation;
+	enum caif_dev_type devtype;
+
+	printk(KERN_WARNING "caifdev_ioctl: Entered\n");
+
+	if (argp == 0) {
+		printk(KERN_INFO "caifdev_ioctl: argument is null\n");
+		return -EINVAL;
+	}
+
+	type = _IOC_TYPE(cmd);
+	printk(KERN_INFO "caifdev_ioctl: type = %d\n", type);
+
+	if (type != CAIF_IOC_MAGIC) {
+		printk(KERN_INFO "caifdev_ioctl: unknown ioctl type\n");
+		return -EINVAL;
+	}
+
+	/* Check if command is valid before copying anything */
+	switch (cmd) {
+	case CAIF_IOC_CONFIG_DEVICE:
+	case CAIF_IOC_REMOVE_DEVICE:
+		break;
+	default:
+		printk(KERN_INFO "caifdev_ioctl: unknown ioctl command\n");
+		return -EINVAL;
+	}
+
+	size = _IOC_SIZE(cmd);
+	printk(KERN_INFO "caifdev_ioctl: size = %d\n", size);
+
+	if (copy_from_user(&param, (void *) argp, size)) {
+		printk(KERN_WARNING
+		       "caifdev_ioctl: copy_from_user returned non zero.\n");
+		return -EINVAL;
+	}
+
+	switch (cmd) {
+
+	case CAIF_IOC_CONFIG_DEVICE:
+
+		operation = CAIF_ACT_CREATE_DEVICE;
+		devtype = param.create_channel.name.devtype;
+		break;
+
+	case CAIF_IOC_REMOVE_DEVICE:
+
+		operation = CAIF_ACT_DELETE_DEVICE;
+		devtype = param.delete_channel.devtype;
+		break;
+
+	default:
+		printk(KERN_INFO
+		       "caifdev_ioctl: OTHER ACTIONS NOT YET IMPLEMENTED\n");
+		return -EINVAL;
+	}
+
+	if (devtype == CAIF_DEV_CHR) {
+		printk(KERN_INFO "caifdev_ioctl: device type CAIF_DEV_CHR\n");
+		mgmt_func = chrdev_mgmt_func;
+	} else if (devtype == CAIF_DEV_NET) {
+		printk(KERN_INFO "caifdev_ioctl: device type CAIF_DEV_NET\n");
+		mgmt_func = netdev_mgmt_func;
+	}
+
+	if (mgmt_func == NULL) {
+		printk(KERN_WARNING
+		       "caifdev_ioctl: DevType %s is not registered\n",
+		       devtype == CAIF_DEV_CHR ? "CHAR" :
+		       devtype == CAIF_DEV_NET ? "NET" : "UNKNOWN");
+		return -EINVAL;
+	}
+
+	ret = (*mgmt_func) (operation, &param);
+
+	if (ret < 0) {
+		printk(KERN_INFO
+		       "caifdev_ioctl: error performing device operation\n");
+		return ret;
+	}
+	if (copy_to_user((void *) argp, &param, size)) {
+		printk(KERN_WARNING
+		       "caifdev_ioctl: copy_to_user returned non zero.\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+const struct file_operations caifdev_fops = {
+	.owner = THIS_MODULE,
+	.open = caifdev_open,
+	.ioctl = caifdev_ioctl,
+	.release = caifdev_release,
+};
+
+void caifdev_exit_module(void)
+{
+	class_remove_file(&caif_class, &class_attr_dbg_lvl);
+	class_unregister(&caif_class);
+	misc_deregister(&caifdev.misc);
+}
+
+int caifdev_init_module(void)
+{
+	int result;
+	/* FIXME: Reverse the directon, rather make chnlif do a get! */
+	extern void chnlif_set_cnfg(cfcnfg_t *cfg);
+
+	caifdev.cfg = cfcnfg_create();
+	if (!caifdev.cfg) {
+		printk(KERN_WARNING "caifdev: err: can't create cfcnfg.\n");
+		goto err_cfcnfg_create_failed;
+	}
+
+	chnlif_set_cnfg(caifdev.cfg);
+
+	caifdev.misc.minor = MISC_DYNAMIC_MINOR;
+	/*FIXME: Rename device to "caifconfig" */
+	caifdev.misc.name = "caifconfig";
+	caifdev.misc.fops = &caifdev_fops;
+
+	result = misc_register(&caifdev.misc);
+
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "caifdev: err: %d, can't register misc.\n", result);
+		goto err_misc_register_failed;
+	}
+
+	/* Register class for SYSFS. */
+	result = class_register(&caif_class);
+	if (unlikely(result)) {
+		printk(KERN_WARNING
+		       "caifdev: err: %d, can't create sysfs node.\n", result);
+		goto err_class_register_failed;
+	}
+
+	/* Create SYSFS nodes. */
+	result = class_create_file(&caif_class, &class_attr_dbg_lvl);
+	if (unlikely(result)) {
+		printk(KERN_WARNING
+		       "caifdev: err: %d, can't create sysfs node.\n", result);
+		goto err_sysfs_create_failed;
+	}
+
+	return result;
+
+err_sysfs_create_failed:
+	class_unregister(&caif_class);
+err_class_register_failed:
+	misc_deregister(&caifdev.misc);
+err_misc_register_failed:
+err_cfcnfg_create_failed:
+	return -ENODEV;
+}
+
+int caifdev_phy_register(layer_t *phyif, cfcnfg_phy_type_t phy_type,
+			 cfcnfg_phy_preference_t phy_pref)
+{
+	uint16 phyid;
+
+	/* Hook up the physical interface.
+	 * Right now we are not using the returned id. */
+	cfcnfg_add_phy_layer(caifdev.cfg, phy_type, phyif, &phyid, phy_pref);
+	printk(KERN_WARNING "caifdev_phy_register: phy:%p id:%d\n",
+	       phyif, phyid);
+
+	printk(KERN_WARNING "caifdev_phy_register: %p ID %d == %d\n",
+	       (void *)phyif, phyid, phyif->id);
+	return 0;
+}
+EXPORT_SYMBOL(caifdev_phy_register);
+
+int caifdev_phy_unregister(layer_t *phyif)
+{
+	printk(KERN_WARNING "caifdev_phy_unregister: phy:%p id:%d\n",
+	       phyif, phyif->id);
+	cfcnfg_del_phy_layer(caifdev.cfg, phyif);
+	return 0;
+}
+EXPORT_SYMBOL(caifdev_phy_unregister);
+
+
+int caifdev_phy_loop_register(layer_t *phyif, cfcnfg_phy_type_t phy_type)
+{
+	/* Create the loop stack. */
+	caifdev.loop = cfloopcfg_create();
+
+	/* Hook up the loop layer. */
+	cfloopcfg_add_phy_layer(caifdev.loop, phy_type, phyif);
+
+	return 0;
+}
+EXPORT_SYMBOL(caifdev_phy_loop_register);
+
+int caifdev_phy_spi_xmitlen(cfspil_t *layr)
+{
+	return cfspil_xmitlen(layr);
+}
+EXPORT_SYMBOL(caifdev_phy_spi_xmitlen);
+
+cfpkt_t *caifdev_phy_spi_getxmitpkt(cfspil_t *layr)
+{
+	return cfspil_getxmitpkt(layr);
+}
+EXPORT_SYMBOL(caifdev_phy_spi_getxmitpkt);
+
+/* FIXME: Generally comment on the new
+ *	   and old fashion functions for phy registration.
+ */
+
+int caifdev_adapt_register(struct caif_channel_config *config,
+			   layer_t *adap_layer)
+{
+	cfctrl_link_param_t param;
+
+	if (channel_config_2_link_param(caifdev.cfg, config, &param) == 0)
+		/* Hook up the adaptation layer. */
+		if (cfcnfg_add_adaptation_layer(caifdev.cfg,
+						&param, adap_layer))
+			return 0;
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(caifdev_adapt_register);
+
+
+/* FIXME: Comment on this function being new and not yet in use */
+int caifdev_adapt_unregister(layer_t *adap_layer)
+{
+	if (cfcnfg_del_adapt_layer(caifdev.cfg, adap_layer))
+		return 0;
+	else
+		return -1;
+}
+EXPORT_SYMBOL(caifdev_adapt_unregister);
+
+int caif_register_chrdev(int (*chrdev_mgmt)
+			  (int action, union caif_action *param))
+{
+
+	chrdev_mgmt_func = chrdev_mgmt;
+	return 0;
+}
+EXPORT_SYMBOL(caif_register_chrdev);
+
+int caif_register_netdev(int (*netdev_mgmt)
+			  (int action, union caif_action *param))
+{
+	netdev_mgmt_func = netdev_mgmt;
+	return 0;
+}
+EXPORT_SYMBOL(caif_register_netdev);
+
+
+void caif_unregister_chrdev()
+{
+	chrdev_mgmt_func = NULL;
+}
+EXPORT_SYMBOL(caif_unregister_chrdev);
+
+void caif_unregister_netdev()
+{
+	netdev_mgmt_func = NULL;
+}
+EXPORT_SYMBOL(caif_unregister_netdev);
+
+/* Exported CAIF functions. */
+EXPORT_SYMBOL(cfcnfg_get_packet_funcs);
+
+
+extern int serial_use_stx;
+EXPORT_SYMBOL(serial_use_stx);
+
+extern cfglu_atomic_t cfpkt_packet_count;
+EXPORT_SYMBOL(cfpkt_packet_count);
+module_exit(caifdev_exit_module);
+module_init(caifdev_init_module);
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
new file mode 100644
index 0000000..093d1be
--- /dev/null
+++ b/net/caif/caif_config_util.c
@@ -0,0 +1,167 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+#include "cfglue.h"
+#include "cfctrl.h"
+#include "cfcnfg.h"
+#include "caif_config_util.h"
+#include "caif_config.h"
+#include "caif_ioctl.h"
+#include "caif_actions.h"
+
+
+
+int
+channel_config_2_link_param(cfcnfg_t *cnfg, struct caif_channel_config *s,
+			    cfctrl_link_param_t *l)
+{
+
+	cfcnfg_phy_preference_t pref;
+
+	memset(l, 0, sizeof(*l));
+
+	l->priority = s->priority;
+
+	if (s->phy_name[0] != '\0') {
+		l->phyid = cfcnfg_get_named(cnfg, s->phy_name);
+		CFLOG_TRACE(("PHYNAME: '%s' -> id:%d\n", s->phy_name,
+			     l->phyid));
+
+	} else {
+		switch (s->phy_pref) {
+		case CAIF_PHYPREF_UNSPECIFIED:
+			pref = CFPHYPREF_UNSPECIFIED;
+			break;
+		case CAIF_PHYPREF_LOW_LAT:
+			pref = CFPHYPREF_LOW_LAT;
+			break;
+		case CAIF_PHYPREF_HIGH_BW:
+			pref = CFPHYPREF_HIGH_BW;
+			break;
+		case _CAIF_PHYPREF_LOOP:
+			pref = CFPHYPREF_LOOP;
+			break;
+		case _CAIF_PHYPREF_RAW_LOOP:
+			pref = CFPHYPREF_RAW_LOOP;
+			break;
+		default:
+			CFLOG_TRACE(("PHYPREF: "
+				     "No Preferered Device Specified '%d'\n",
+				     s->phy_pref));
+			return -CFGLU_ENODEV;
+		}
+		l->phyid = cfcnfg_get_phyid(cnfg, pref);
+		CFLOG_TRACE(("PHYPREF: '%d' -> id:%d\n", pref, l->phyid));
+	}
+
+	switch (s->type) {
+	case CAIF_CHTY_AT:
+		l->linktype = CFCTRL_SRV_VEI;
+		l->chtype = 0x02;
+		l->endpoint = 0x00;
+		CFLOG_TRACE(("CHTY: AT\n"));
+		break;
+
+	case CAIF_CHTY_AT_CTRL:
+		CFLOG_TRACE(("CHTY: AT_CTRL\n"));
+		l->linktype = CFCTRL_SRV_VEI;
+		l->chtype = 0x00;
+		l->endpoint = 0x00;
+		break;
+
+	case CAIF_CHTY_AT_PAIRED:
+		CFLOG_TRACE(("CHTY: AT_PAIRED\n"));
+		l->linktype = CFCTRL_SRV_VEI;
+		l->chtype = 0x03;
+		l->endpoint = 0x00;
+		break;
+
+	case CAIF_CHTY_VIDEO:
+		CFLOG_TRACE(("CHTY: VIDEO\n"));
+		l->linktype = CFCTRL_SRV_VIDEO;
+		l->chtype = 0x00;
+		l->endpoint = 0x00;
+		l->u.video.connid = s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DATAGRAM:
+		CFLOG_TRACE(("CHTY: DATAGRAM\n"));
+		l->linktype = CFCTRL_SRV_DATAGRAM;
+		l->chtype = 0x00;
+		l->u.datagram.connid = s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DATAGRAM_LOOP:
+		CFLOG_TRACE(("CHTY: DATAGRAM\n"));
+		l->linktype = CFCTRL_SRV_DATAGRAM;
+		l->chtype = 0x03;
+		l->endpoint = 0x00;
+		l->u.datagram.connid = s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DEBUG:
+		CFLOG_TRACE(("CHTY: DEBUG\n"));
+		l->linktype = CFCTRL_SRV_DBG;
+		l->endpoint = 0x01;	/* ACC SIDE */
+		l->chtype = 0x00;	/* Single channel with interactive
+					   debug and print-out mixed */
+		break;
+
+	case CAIF_CHTY_DEBUG_INTERACT:
+		CFLOG_TRACE(("CHTY: IDEBUG\n"));
+		l->linktype = CFCTRL_SRV_DBG;
+		l->endpoint = 0x01;	/* ACC SIDE */
+		l->chtype = 0x02;	/* Interactive debug only */
+		break;
+
+	case CAIF_CHTY_DEBUG_TRACE:
+		CFLOG_TRACE(("CHTY: TRACE\n"));
+		l->linktype = CFCTRL_SRV_DBG;
+		l->endpoint = 0x01;	/* ACC SIDE */
+		l->chtype = 0x01;	/* Debug print-out only */
+		break;
+
+	case CAIF_CHTY_RFM:
+
+		CFLOG_TRACE(("CHTY: RFN\n"));
+		l->linktype = CFCTRL_SRV_RFM;
+		l->u.datagram.connid = s->u.rfm.connection_id;
+		strncpy(l->u.rfm.volume, s->u.rfm.volume,
+			sizeof(l->u.rfm.volume));
+		break;
+
+	case CAIF_CHTY_UTILITY:
+		CFLOG_TRACE(("CHTY: UTILTY\n"));
+		l->linktype = CFCTRL_SRV_UTIL;
+		l->endpoint = 0x00;
+		l->chtype = 0x00;
+		l->u.utility.fifosize_bufs = s->u.utility.fifosize_bufs;
+		l->u.utility.fifosize_kb = s->u.utility.fifosize_kb;
+		strncpy(l->u.utility.name, s->u.utility.name,
+			sizeof(l->u.utility.name));
+		l->u.utility.paramlen = s->u.utility.paramlen;
+		if (l->u.utility.paramlen > sizeof(l->u.utility.params))
+			l->u.utility.paramlen = sizeof(l->u.utility.params);
+		memcpy(l->u.utility.params, s->u.utility.params,
+		       l->u.utility.paramlen);
+		break;
+
+	case CAIF_CHTY_RAW:
+		l->linktype = s->u._raw.channeltype;
+		l->endpoint = s->u._raw.endpoint;
+		l->chtype = s->u._raw.subtype;
+		break;
+
+	default:
+		CFLOG_TRACE(("CAIF_CHTY: Specified bad channel type '%d'\n",
+			     s->type));
+		return -CFGLU_EINVAL;
+	}
+	return 0;
+}
diff --git a/net/caif/chnl_chr.c b/net/caif/chnl_chr.c
new file mode 100644
index 0000000..b45e93c
--- /dev/null
+++ b/net/caif/chnl_chr.c
@@ -0,0 +1,1161 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Per Sigmond / Per.Sigmond@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/miscdevice.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/uaccess.h>
+#include <asm/atomic.h>
+
+/* Caif header files. */
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+#include "cffrml.h"
+#include "caif_chr.h"
+#include "caif_config.h"
+#include "caif_config_util.h"
+#include "caif_actions.h"
+#include "caif_log.h"
+MODULE_LICENSE("GPL");
+
+#define COUNTER_DEBUG 0
+
+/* Seconds */
+#define CAIF_CONNECT_TIMEOUT 30
+
+#define CHNL_CHR_READ_QUEUE_HIGH 2000
+#define CHNL_CHR_READ_QUEUE_LOW 100
+
+static LIST_HEAD(caif_chrdev_list);
+static spinlock_t list_lock;
+
+#define STATE_IS_OPEN_BIT        1
+#define STATE_OPEN_PENDING_BIT   2
+#define STATE_IS_CLOSED_BIT      3
+#define STATE_CLOSE_PENDING_BIT  4
+#define STATE_TX_FLOW_ON         5
+#define STATE_RX_FLOW_OFF        6
+
+
+
+#define CHR_READ_FLAG 0x01
+#define CHR_WRITE_FLAG 0x02
+
+#define chnl_assert(assert) BUG_ON(!(assert))
+
+
+struct caif_char_dev {
+	layer_t layer;
+	unsigned int status;
+	cfpktq_t *pktq;
+	char name[256];		/* Redundnt! Already in struct miscdevice */
+	struct miscdevice misc;
+	int file_mode;
+	caif_packet_funcs_t pktf;
+	struct caif_channel_config config;
+	/* Access to this struct and below layers */
+	struct mutex mutex;
+	int read_queue_len;
+	spinlock_t read_queue_len_lock;
+	wait_queue_head_t read_wq;
+	wait_queue_head_t mgmt_wq;
+	/* List of misc test devices */
+	struct list_head list_field;
+#if COUNTER_DEBUG
+	unsigned long counter;
+	int mismatch_reported;
+#endif
+
+};
+
+/** Packet Receive Callback function called from CAIF Stack */
+
+static int caif_chrrecv_cb(layer_t *layr, cfpkt_t *pkt)
+{
+	struct caif_char_dev *dev;
+#if COUNTER_DEBUG
+	unsigned long *data_p;
+#endif
+
+	CAIFLOG_ENTER("");
+	dev = container_of(layr, struct caif_char_dev, layer);
+
+	CAIFLOG_TRACE2("[%s] data received: %d bytes.\n",
+		       __func__, dev->pktf.cfpkt_getlen(pkt));
+
+	/** NOTE: This function may be called in Tasklet context! */
+
+
+
+#if COUNTER_DEBUG
+	dev->pktf.cfpkt_raw_extract(pkt, (void **) &data_p, 0);
+
+	if (data_p[0] == 1) {
+		dev->counter = data_p[0];
+		dev->mismatch_reported = 0;
+	}
+
+	if ((dev->counter != data_p[0]) && !dev->mismatch_reported) {
+		CAIFLOG_TRACE
+		    ("WARNING: caif_chrrecv_cb() - " "sequence: expected "
+		     "%ld, got %ld\n", dev->counter, data_p[0]);
+		dev->mismatch_reported = 1;
+	}
+
+	if (!(dev->counter % 100000))
+		CAIFLOG_TRACE("caif_chrrecv_cb(): %ld\n", dev->counter);
+
+
+	dev->counter++;
+#endif
+
+	/* The queue has its own lock */
+	dev->pktf.cfpkt_queue(dev->pktq, pkt, 0);
+	spin_lock(&dev->read_queue_len_lock);
+	dev->read_queue_len++;
+
+	if (!test_bit(STATE_RX_FLOW_OFF, (void *) &dev->status) &&
+	    (dev->read_queue_len > CHNL_CHR_READ_QUEUE_HIGH)) {
+		set_bit(STATE_RX_FLOW_OFF, (void *) &dev->status);
+
+		/* Todo: send flow off (NOTE: must not sleep) */
+		CAIFLOG_TRACE2
+		    ("caif_chrrecv_cb(): sending flow OFF (queue len = %d)\n",
+		     dev->read_queue_len);
+		chnl_assert(dev->layer.dn);
+		chnl_assert(dev->layer.dn->ctrlcmd);
+		(void) dev->layer.dn->modemcmd(dev->layer.dn,
+					       CAIF_MODEMCMD_FLOW_OFF_REQ);
+	}
+	spin_unlock(&dev->read_queue_len_lock);
+
+	/* Signal reader that data is available. */
+	wake_up_interruptible(&dev->read_wq);
+
+	return 0;
+}
+
+/** Packet Flow Control Callback function called from CAIF */
+static void caif_chrflowctrl_cb(layer_t *layr, caif_ctrlcmd_t flow, int phyid)
+{
+	struct caif_char_dev *dev;
+
+	CAIFLOG_ENTER("");
+
+	/** NOTE: This function may be called in Tasklet context! */
+	CAIFLOG_TRACE("AT flowctrl func called flow: %s.\n",
+		      flow == CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
+		      flow == CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
+		      flow == CAIF_CTRLCMD_INIT_RSP ? "INIT_RSP" :
+		      flow == CAIF_CTRLCMD_DEINIT_RSP ? "DEINIT_RSP" :
+		      flow == CAIF_CTRLCMD_INIT_FAIL_RSP ? "INIT_FAIL_RSP" :
+		      flow ==
+		      CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ? "REMOTE_SHUTDOWN" :
+		      "UKNOWN CTRL COMMAND");
+
+	dev = container_of(layr, struct caif_char_dev, layer);
+
+	switch (flow) {
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_FLOW_ON_IND\n",
+			      __func__, __LINE__);
+		/* Signal reader that data is available. */
+		set_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		wake_up_interruptible(&dev->mgmt_wq);
+		break;
+
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_FLOW_OFF_IND\n",
+			      __func__, __LINE__);
+		clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		break;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_INIT_RSP\n",
+			      __func__, __LINE__);
+		/* Signal reader that data is available. */
+		set_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		set_bit(STATE_IS_OPEN_BIT, (void *) &dev->status);
+		clear_bit(STATE_OPEN_PENDING_BIT, (void *) &dev->status);
+		wake_up_interruptible(&dev->mgmt_wq);
+		break;
+
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_DEINIT_RSP\n",
+			      __func__, __LINE__);
+		clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		set_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status);
+		clear_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status);
+		wake_up_interruptible(&dev->mgmt_wq);
+		break;
+
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_INIT_FAIL_RSP\n",
+			      __func__, __LINE__);
+		clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		set_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status);
+		clear_bit(STATE_OPEN_PENDING_BIT, (void *) &dev->status);
+		wake_up_interruptible(&dev->mgmt_wq);
+		break;
+
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND\n",
+			      __func__, __LINE__);
+		clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+		set_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status);
+		clear_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status);
+		clear_bit(STATE_OPEN_PENDING_BIT, (void *) &dev->status);
+		wake_up_interruptible(&dev->mgmt_wq);
+		break;
+
+	default:
+		CAIFLOG_TRACE("[%s:%d] Unexpected flow command %d\n",
+			      __func__, __LINE__, flow);
+
+	}
+}
+
+/** Device Read function called from Linux Kernel */
+ssize_t caif_chrread(struct file *filp, char __user *buf, size_t count,
+		     loff_t *f_pos)
+{
+	cfpkt_t *pkt = NULL;
+	unsigned char *rxbuf = NULL;
+	size_t len;
+	int result;
+	struct caif_char_dev *dev = filp->private_data;
+	ssize_t ret = -EIO;
+
+	CAIFLOG_ENTER("");
+
+	if (dev == NULL) {
+		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
+			      __func__, __LINE__);
+		return -EBADFD;
+	}
+
+
+	/* I want to be alone on dev (except status and queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chrread: mutex_lock_interruptible got signalled\n");
+		return -ERESTARTSYS;
+	}
+
+	chnl_assert(dev->pktq);
+
+	if (!test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device not open\n", __func__, __LINE__);
+		ret = -EINVAL;
+		goto read_error;
+	}
+
+	if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+			      __func__, __LINE__);
+		ret = -EPIPE;
+		goto read_error;
+	}
+
+	if (test_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device is closing...\n",
+			      __func__, __LINE__);
+		ret = -EPIPE;
+		goto read_error;
+	}
+
+
+	/* Block if we don't have any received buffers. */
+	/* The queue has its own lock */
+	while ((pkt = dev->pktf.cfpkt_qpeek(dev->pktq)) == NULL) {
+
+		if (filp->f_flags & O_NONBLOCK) {
+			CAIFLOG_TRACE("caif_chrread: O_NONBLOCK\n");
+			ret = -EAGAIN;
+			goto read_error;
+		}
+		CAIFLOG_TRACE2("[%s:%d] wait_event\n", __func__, __LINE__);
+
+		/* Let writers in */
+		mutex_unlock(&dev->mutex);
+
+		/* Block reader until data arrives. */
+		if (wait_event_interruptible(dev->read_wq,
+					     dev->pktf.cfpkt_qpeek(dev->pktq)
+					     || test_bit(STATE_IS_CLOSED_BIT,
+							 (void *)
+							 &dev->status)) ==
+		    -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			    ("caif_chrread: wait_event_interruptible woken by "
+			     "a signal, signal_pending(current) = %d\n",
+			     signal_pending(current));
+			return -ERESTARTSYS;
+		}
+
+		CAIFLOG_TRACE2("[%s:%d] awake\n", __func__, __LINE__);
+
+		/* I want to be alone on dev (except status and queue) */
+		if (mutex_lock_interruptible(&dev->mutex)) {
+			CAIFLOG_TRACE
+			    ("caif_chrread: "
+			     "mutex_lock_interruptible got signalled\n");
+			return -ERESTARTSYS;
+		}
+
+		if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)) {
+			/* someone closed the link, report error */
+			CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+				      __func__, __LINE__);
+			ret = -EPIPE;
+			goto read_error;
+		}
+
+	}
+
+	/* The queue has its own lock */
+	len = dev->pktf.cfpkt_getlen(pkt);
+
+	/* Check max length that can be copied. */
+	if (len > count) {
+		CAIFLOG_TRACE("caif_chrread: user buffer too small\n");
+		ret = -EINVAL;
+		goto read_error;
+	}
+
+	/* Get packet from queue */
+	/* The queue has its own lock */
+	pkt = dev->pktf.cfpkt_dequeue(dev->pktq);
+
+	spin_lock(&dev->read_queue_len_lock);
+	dev->read_queue_len--;
+	if (test_bit(STATE_RX_FLOW_OFF, (void *) &dev->status) &&
+	    (dev->read_queue_len < CHNL_CHR_READ_QUEUE_LOW)) {
+
+		clear_bit(STATE_RX_FLOW_OFF, (void *) &dev->status);
+
+		/* Todo: send flow on */
+		CAIFLOG_TRACE2
+		    ("caif_chrread(): sending flow ON (queue len = %d)\n",
+		     dev->read_queue_len);
+		chnl_assert(dev->layer.dn);
+		chnl_assert(dev->layer.dn->ctrlcmd);
+		(void) dev->layer.dn->modemcmd(dev->layer.dn,
+					       CAIF_MODEMCMD_FLOW_ON_REQ);
+
+		chnl_assert(dev->read_queue_len >= 0);
+
+	}
+	spin_unlock(&dev->read_queue_len_lock);
+
+	result = dev->pktf.cfpkt_raw_extract(pkt, (void **) &rxbuf, len);
+
+	chnl_assert(result >= 0);
+
+	if (result < 0) {
+		CAIFLOG_TRACE("caif_chrread: cfpkt_raw_extract failed\n");
+		dev->pktf.cfpkt_destroy(pkt);
+		ret = -EINVAL;
+		goto read_error;
+	}
+
+	/* Copy data from the RX buffer to the user buffer. */
+	if (copy_to_user(buf, rxbuf, len)) {
+		CAIFLOG_TRACE("caif_chrread: copy_to_user returned non zero.");
+		dev->pktf.cfpkt_destroy(pkt);
+		ret = -EINVAL;
+		goto read_error;
+	}
+
+
+	/* Liberate packet. */
+	dev->pktf.cfpkt_destroy(pkt);
+
+
+	/* Let the others in */
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return len;
+
+read_error:
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+/** Device write function called from Linux Kernel (misc device) */
+ssize_t caif_chrwrite(struct file *filp, const char __user *buf,
+		      size_t count, loff_t *f_pos)
+{
+	cfpkt_t *pkt = NULL;
+	struct caif_char_dev *dev = filp->private_data;
+	transmt_info info;
+	unsigned char *txbuf;
+	ssize_t ret = -EIO;
+	CAIFLOG_ENTER("");
+
+	if (dev == NULL) {
+		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
+			      __func__, __LINE__);
+		ret = -EBADFD;
+		goto write_error_no_unlock;
+	}
+
+
+	if (count > CAIF_MAX_PAYLOAD_SIZE) {
+		CAIFLOG_TRACE("[%s:%d] buffer too long\n", __func__, __LINE__);
+		ret = -EINVAL;
+		goto write_error_no_unlock;
+	}
+
+	/* I want to be alone on dev (except status and queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chrwrite: mutex_lock_interruptible got signalled");
+		ret = -ERESTARTSYS;
+		goto write_error_no_unlock;
+	}
+
+	chnl_assert(dev->pktq);
+
+	if (!test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device not open", __func__, __LINE__);
+		ret = -EINVAL;
+		goto write_error;
+	}
+
+	if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] remote end shutdown!",
+			      __func__, __LINE__);
+		ret = -EPIPE;
+		goto write_error;
+	}
+
+	if (test_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device is closing...",
+			      __func__, __LINE__);
+		ret = -EPIPE;
+		goto write_error;
+	}
+
+	if (!test_bit(STATE_TX_FLOW_ON, (void *) &dev->status) &&
+	    (filp->f_flags & O_NONBLOCK)) {
+		CAIFLOG_TRACE("caif_chrwrite: O_NONBLOCK");
+		ret = -EAGAIN;
+		goto write_error;
+	}
+
+	/* Let readers in */
+	mutex_unlock(&dev->mutex);
+
+	if (wait_event_interruptible(dev->mgmt_wq,
+				     test_bit(STATE_TX_FLOW_ON,
+					      (void *) &dev->status)
+				     || test_bit(STATE_IS_CLOSED_BIT,
+						 (void *) &dev->status)) ==
+	    -ERESTARTSYS) {
+		CAIFLOG_TRACE
+		    ("caif_chrwrite:"
+		     " wait_event_interruptible woken by a signal");
+		ret = -ERESTARTSYS;
+		goto write_error_no_unlock;
+	}
+
+	/* I want to be alone on dev (except status and queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chrwrite: mutex_lock_interruptible got signalled\n");
+		ret = -ERESTARTSYS;
+		goto write_error_no_unlock;
+	}
+
+	if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)) {
+		/* someone closed the link, report error */
+		CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+			      __func__, __LINE__);
+		ret = -EPIPE;
+		goto write_error;
+	}
+
+	/* Create packet, buf=NULL means no copying */
+	pkt = dev->pktf.cfpkt_create_xmit_pkt((const unsigned char *) NULL,
+					      count);
+
+	if (pkt == NULL) {
+		CAIFLOG_TRACE
+		    ("caif_chrwrite: cfpkt_create_pkt returned NULL\n");
+		ret = -EIO;
+		goto write_error;
+	}
+
+	if (!dev->pktf.cfpkt_raw_append(pkt, (void **) &txbuf, count)) {
+		CAIFLOG_TRACE("caif_chrwrite: cfpkt_raw_append failed\n");
+		dev->pktf.cfpkt_destroy(pkt);
+		ret = -EINVAL;
+		goto write_error;
+	}
+
+	/* Copy data into buffer. */
+
+	if (copy_from_user(txbuf, buf, count)) {
+		CAIFLOG_TRACE
+		    ("caif_chrwrite: copy_from_user returned non zero.\n");
+		dev->pktf.cfpkt_destroy(pkt);
+		ret = -EINVAL;
+		goto write_error;
+	}
+
+	memset(&info, 0, sizeof(info));
+
+	/* Send the packet down the stack. */
+	chnl_assert(dev->layer.dn);
+	chnl_assert(dev->layer.dn->transmit);
+
+	ret = dev->layer.dn->transmit(dev->layer.dn, &info, pkt);
+	if (ret < 0) {
+		dev->pktf.cfpkt_destroy(pkt);
+		CAIFLOG_TRACE("caif_chrwrite: transmit failed, error = %d\n",
+			      ret);
+		goto write_error;
+	}
+
+
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return count;
+
+write_error:
+	mutex_unlock(&dev->mutex);
+write_error_no_unlock:
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+
+static unsigned int caif_chrpoll(struct file *filp, poll_table *waittab)
+{
+	struct caif_char_dev *dev = filp->private_data;
+	unsigned int mask = 0;
+
+	CAIFLOG_ENTER("");
+
+	if (dev == NULL) {
+		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
+			      __func__, __LINE__);
+		return -EBADFD;
+	}
+
+
+	/* I want to be alone on dev (except status and queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chrpoll: mutex_lock_interruptible got signalled\n");
+		goto poll_error;
+	}
+
+	chnl_assert(dev->pktq);
+
+	if (!test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device not open\n", __func__, __LINE__);
+		goto poll_error;
+	}
+
+	if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+			      __func__, __LINE__);
+		goto poll_error;
+	}
+
+	if (test_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] device is closing...\n",
+			      __func__, __LINE__);
+		goto poll_error;
+	}
+
+	poll_wait(filp, &dev->read_wq, waittab);
+
+	if (dev->pktf.cfpkt_qpeek(dev->pktq) != NULL)
+		mask |= (POLLIN | POLLRDNORM);
+
+
+	if (test_bit(STATE_TX_FLOW_ON, (void *) &dev->status))
+		mask |= (POLLOUT | POLLWRNORM);
+
+
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_TRACE("[%s:%d] caif_chrpoll mask=0x%04x...\n",
+		      __func__, __LINE__, mask);
+
+	CAIFLOG_EXIT("");
+	return mask;
+
+poll_error:
+	mask |= POLLERR;
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return mask;
+}
+
+/* Usage:
+   minor >= 0 : find from minor
+   minor < 0 and name == name : find from name
+   minor < 0 and name == NULL : get first
+*/
+
+static struct caif_char_dev *find_device(int minor, char *name,
+					 int remove_from_list)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct caif_char_dev *dev = NULL;
+	struct caif_char_dev *tmp;
+	CAIFLOG_ENTER("");
+	spin_lock(&list_lock);
+	CAIFLOG_TRACE("[%s:%d] start looping \n", __func__, __LINE__);
+	list_for_each_safe(list_node, n, &caif_chrdev_list) {
+		tmp = list_entry(list_node, struct caif_char_dev, list_field);
+		CAIFLOG_TRACE("[%s:%d] check %d,%d, %s, %s \n",
+			      __func__, __LINE__, tmp->misc.minor, minor,
+			      tmp->name, name);
+		if (minor >= 0) {	/* find from minor */
+			if (tmp->misc.minor == minor)
+				dev = tmp;
+
+		} else if (name) {	/* find from name */
+			if (!strncmp(tmp->name, name, sizeof(tmp->name)))
+				dev = tmp;
+		} else {	/* take first */
+			dev = tmp;
+		}
+
+		if (dev) {
+			CAIFLOG_TRACE("[%s:%d] match %d, %s \n",
+				      __func__, __LINE__, minor, name);
+			if (remove_from_list)
+				list_del(list_node);
+			break;
+		}
+	}
+	spin_unlock(&list_lock);
+	return dev;
+}
+
+#if CAIFLOG_ON
+static void print_device_list(void)
+{
+	int i = 0;
+	struct list_head *list_node;
+	struct caif_char_dev *tmp;
+	CAIFLOG_ENTER("");
+	spin_lock(&list_lock);
+	CAIFLOG_TRACE("List of devices:\n");
+	list_for_each(list_node, &caif_chrdev_list) {
+		tmp = list_entry(list_node, struct caif_char_dev, list_field);
+		CAIFLOG_TRACE("i = %d, minor= %d, name = %s, open = %d\n", i,
+			      tmp->misc.minor, tmp->name,
+			      test_bit(STATE_IS_OPEN_BIT,
+				       (void *) &tmp->status) ? 1 : 0);
+		i++;
+	}
+	if (i == 0)
+		CAIFLOG_TRACE("list is empty\n");
+
+	spin_unlock(&list_lock);
+}
+#endif
+
+
+static void drain_queue(struct caif_char_dev *dev)
+{
+	cfpkt_t *pkt;
+
+	/* Empty the queue */
+	do {
+		/* The queue has its own lock */
+		pkt = dev->pktf.cfpkt_dequeue(dev->pktq);
+
+		if (!pkt)
+			break;
+
+		CAIFLOG_TRACE
+		    ("[%s:%d] drain_queue(): freeing packet from read queue\n",
+		     __func__, __LINE__);
+		dev->pktf.cfpkt_destroy(pkt);
+
+	} while (1);
+}
+
+
+int caif_chropen(struct inode *inode, struct file *filp)
+{
+	struct caif_char_dev *dev = NULL;
+	int result = -1;
+	int minor = iminor(inode);
+	int mode = 0;
+	int ret = -EIO;
+
+	CAIFLOG_ENTER("");
+
+	IF_CAIF_TRACE(print_device_list());
+
+	dev = find_device(minor, NULL, 0);
+
+	if (dev == NULL) {
+		CAIFLOG_TRACE("[%s] COULD NOT FIND DEVICE\n", __func__);
+		return -EBADF;
+	}
+
+	CAIFLOG_TRACE("[%s:%d] dev=%p \n", __func__, __LINE__, dev);
+
+	/* I want to be alone on dev (except status and queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chropen: mutex_lock_interruptible got signalled\n");
+		return -ERESTARTSYS;
+	}
+
+	filp->private_data = dev;
+
+	switch (filp->f_flags & O_ACCMODE) {
+	case O_RDONLY:
+		mode = CHR_READ_FLAG;
+		break;
+	case O_WRONLY:
+		mode = CHR_WRITE_FLAG;
+		break;
+	case O_RDWR:
+		mode = CHR_READ_FLAG | CHR_WRITE_FLAG;
+		break;
+	}
+
+	/* If close is pending we need to wait for its conclusion */
+	result = wait_event_interruptible_timeout(dev->mgmt_wq,
+						  !test_bit
+						  (STATE_CLOSE_PENDING_BIT,
+						   (void *) &dev->status),
+						  CAIF_CONNECT_TIMEOUT * HZ);
+	if (result == -ERESTARTSYS) {
+		CAIFLOG_TRACE
+		    ("caif_chropen:"
+		     " wait_event_interruptible woken by a signal (1)");
+		ret = -ERESTARTSYS;
+		goto open_error;
+	} else if (result == 0) {
+		/* Timed out */
+		/* Timeout */
+		CAIFLOG_TRACE("caif_chropen: close pending timed out\n");
+		ret = -ETIMEDOUT;
+		goto open_error;
+	}
+
+	if (!test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+
+		/* Test if we have already registered the channel,
+		 * we could have been interrupted by a signal last time...
+		 */
+		if (!test_bit(STATE_OPEN_PENDING_BIT, (void *) &dev->status)) {
+
+			/* First opening of file; connect lower layers: */
+
+			dev->layer.receive = caif_chrrecv_cb;
+
+			clear_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status);
+			clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+			set_bit(STATE_OPEN_PENDING_BIT, (void *) &dev->status);
+
+			/* Register this channel. */
+			result =
+			    caifdev_adapt_register(&dev->config, &dev->layer);
+			if (result < 0) {
+				CAIFLOG_TRACE
+				    ("caif_chropen: can't register channel\n");
+				ret = -EIO;
+				goto open_error;
+			}
+		}
+
+		CAIFLOG_TRACE("[%s:%d] WAIT FOR CONNECT RESPONSE \n", __func__,
+			      __LINE__);
+
+		result = wait_event_interruptible_timeout(dev->mgmt_wq,
+							  test_bit
+							  (STATE_IS_OPEN_BIT,
+							   (void *)
+							   &dev->status)
+							  ||
+							  test_bit
+							  (STATE_IS_CLOSED_BIT,
+							   (void *)
+							   &dev->status),
+							  CAIF_CONNECT_TIMEOUT
+							  * HZ);
+		if (result == -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			    ("caif_chropen: "
+			     "wait_event_interruptible woken by a signal (2)");
+			ret = -ERESTARTSYS;
+			goto open_error;
+		} else if (result == 0) {
+			/* Timed out */
+			/* Timeout */
+			CAIFLOG_TRACE("caif_open: connect timed out\n");
+			ret = -ETIMEDOUT;
+			goto open_error;
+		}
+
+		if (test_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status)
+		    ) {
+			/* Lower layers said "no" */
+			CAIFLOG_TRACE
+			    ("[%s:%d] caif_chropen: CLOSED RECEIVED\n",
+			     __func__, __LINE__);
+			ret = -EPIPE;
+			goto open_error;
+		}
+
+		CAIFLOG_TRACE("[%s:%d] caif_chropen: CONNECT RECEIVED\n",
+			      __func__, __LINE__);
+	} else {
+		/* Already open */
+		CAIFLOG_TRACE
+		    ("[%s:%d] Device is already opened (dev=%p) check access "
+		     "f_flags = 0x%x file_mode = 0x%x\n",
+		     __func__, __LINE__, dev, mode, dev->file_mode);
+
+		if (mode & dev->file_mode) {
+			CAIFLOG_TRACE
+			    ("[%s:%d] Access mode already in use 0x%x \n",
+			     __func__, __LINE__, mode);
+			ret = -EBUSY;
+			goto open_error;
+		}
+	}
+
+	/* Open is ok */
+	dev->file_mode |= mode;
+
+	CAIFLOG_TRACE("[%s:%d] Open - file mode = %x\n",
+		      __func__, __LINE__, dev->file_mode);
+
+	CAIFLOG_TRACE("[%s:%d] CONNECTED \n", __func__, __LINE__);
+
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return 0;
+
+open_error:
+	mutex_unlock(&dev->mutex);
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+int caif_chrrelease(struct inode *inode, struct file *filp)
+{
+	struct caif_char_dev *dev = NULL;
+	int minor = iminor(inode);
+	int result;
+	int mode = 0;
+	CAIFLOG_ENTER("");
+
+	IF_CAIF_TRACE(print_device_list());
+	dev = find_device(minor, NULL, 0);
+	if (dev == NULL) {
+		CAIFLOG_TRACE("[%s] COULD NOT FIND DEVICE\n", __func__);
+		return -EBADF;
+	}
+
+	/* I want to be alone on dev (except status queue) */
+	if (mutex_lock_interruptible(&dev->mutex)) {
+		CAIFLOG_TRACE
+		    ("caif_chrrelease: "
+		     "mutex_lock_interruptible got signalled\n");
+		return -ERESTARTSYS;
+	}
+
+	/* Don't need to test for CLOSE _PENDING because if set IS_OPEN is
+	   always cleared
+	 */
+	if (!test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE("[%s:%d] Device not open (dev=%p) \n",
+			      __func__, __LINE__, dev);
+		mutex_unlock(&dev->mutex);
+		return 0;
+	}
+
+	switch (filp->f_flags & O_ACCMODE) {
+	case O_RDONLY:
+		mode = CHR_READ_FLAG;
+		break;
+	case O_WRONLY:
+		mode = CHR_WRITE_FLAG;
+		break;
+	case O_RDWR:
+		mode = CHR_READ_FLAG | CHR_WRITE_FLAG;
+		break;
+	}
+
+
+	dev->file_mode &= ~mode;
+	if (dev->file_mode) {
+		CAIFLOG_TRACE
+		    ("[%s:%d] Don't yet close CAIF connection - file_mode "
+		     "= %x\n", __func__, __LINE__, dev->file_mode);
+		mutex_unlock(&dev->mutex);
+		return 0;
+	}
+
+	/* IS_CLOSED have double meaning:
+	 * 1) Spontanous Remote Shutdown Request.
+	 * 2) Ack on a channel teardown(disconnect)
+	 * Must clear bit in case we previously received
+	 * remote shudown request.
+	 */
+
+	clear_bit(STATE_IS_CLOSED_BIT, (void *) &dev->status);
+	set_bit(STATE_CLOSE_PENDING_BIT, (void *) &dev->status);
+
+	result = caifdev_adapt_unregister(&dev->layer);
+
+	if (result < 0) {
+		/* Timeout */
+		CAIFLOG_TRACE
+		    ("caif_chrrelease: caifdev_adapt_unregister() failed\n");
+		mutex_unlock(&dev->mutex);
+		return -EIO;
+	}
+
+	/* wait for flow control callback with flow == shutdown */
+	result = wait_event_interruptible_timeout(dev->mgmt_wq,
+						  test_bit(STATE_IS_CLOSED_BIT,
+							   (void *)
+							   &dev->status),
+						  CAIF_CONNECT_TIMEOUT * HZ);
+	if (result == -ERESTARTSYS) {
+		CAIFLOG_TRACE
+		    ("caif_chrrelease: "
+		     "wait_event_interruptible woken by signal,"
+		     " signal_pending(current) = %d\n",
+		     signal_pending(current));
+	} else if (result == 0) {
+		/* Timeout */
+		CAIFLOG_TRACE("caif_chrrelease: disconnect timed out\n");
+		mutex_unlock(&dev->mutex);
+		return -ETIMEDOUT;
+	} else {
+		CAIFLOG_TRACE("[%s:%d] caif_chrrelease: DISCONNECT RECEIVED\n",
+			      __func__, __LINE__);
+	}
+
+	/* Empty the queue */
+	drain_queue(dev);
+	dev->file_mode = 0;
+	clear_bit(STATE_IS_OPEN_BIT, (void *) &dev->status);
+	clear_bit(STATE_TX_FLOW_ON, (void *) &dev->status);
+	IF_CAIF_TRACE(print_device_list());
+
+	mutex_unlock(&dev->mutex);
+	return 0;
+}
+
+const struct file_operations caif_chrfops = {
+	.owner = THIS_MODULE,
+	.read = caif_chrread,
+	.write = caif_chrwrite,
+	.open = caif_chropen,
+	.release = caif_chrrelease,
+	.poll = caif_chrpoll,
+};
+
+int chrdev_create(struct caif_channel_create_action *action)
+{
+
+	struct caif_char_dev *dev = NULL;
+	int result;
+	CAIFLOG_ENTER("");
+
+	IF_CAIF_TRACE(print_device_list());
+
+	/* Allocate device */
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+
+	if (!dev) {
+		CAIFLOG_TRACE(KERN_ERR "chnl_chr: kmalloc failed.\n");
+		return -ENOMEM;
+	}
+
+	CAIFLOG_TRACE("[%s:%d] dev=%p \n", __func__, __LINE__, dev);
+	memset(dev, 0, sizeof(*dev));
+
+	mutex_init(&dev->mutex);
+	init_waitqueue_head(&dev->read_wq);
+	init_waitqueue_head(&dev->mgmt_wq);
+	spin_lock_init(&dev->read_queue_len_lock);
+
+	/* Fill in some information concerning the misc device. */
+	dev->misc.minor = MISC_DYNAMIC_MINOR;
+	strncpy(dev->name, action->name.name, sizeof(dev->name));
+	dev->misc.name = dev->name;
+	dev->misc.fops = &caif_chrfops;
+
+	/* Register the device */
+	result = misc_register(&dev->misc);
+
+	/* Lock in order to try to stop someone from opening the device
+	   too early. The misc device has its own lock. We cannot take our
+	   lock until misc_register() is finished, because in open() the
+	   locks are taken in this order (misc first and then dev).
+	   So anyone managing to open the device between the misc_register
+	   and the mutex_lock will get a "device not found" error. Don't
+	   think it can be avoided.
+	 */
+	mutex_lock_interruptible(&dev->mutex);
+
+	if (result < 0) {
+		CAIFLOG_ERROR("chnl_chr: error - %d, can't register misc.\n",
+			      result);
+		mutex_unlock(&dev->mutex);
+		goto err_failed;
+	}
+
+
+	dev->pktf = cfcnfg_get_packet_funcs();
+
+	dev->pktq = dev->pktf.cfpktq_create();
+	if (!dev->pktq) {
+		CAIFLOG_ERROR("chnl_chr: queue create failed.\n");
+		result = -ENOMEM;
+		mutex_unlock(&dev->mutex);
+		misc_deregister(&dev->misc);
+		goto err_failed;
+	}
+
+	CAIFLOG_TRACE("[%s:%d] pktf=%p\n", __func__, __LINE__, &dev->pktf);
+	CAIFLOG_TRACE("[%s:%d] cfpkt_create_xmit=%p\n", __func__,
+		      __LINE__, dev->pktf.cfpkt_create_xmit_pkt);
+
+	strncpy(action->name.name, dev->misc.name, sizeof(action->name.name));
+	action->major = MISC_MAJOR;
+	action->minor = dev->misc.minor;
+
+	dev->config = action->config;
+	CAIFLOG_TRACE("dev: Registered dev with name=%s minor=%d, dev=%p\n",
+		      dev->misc.name, dev->misc.minor, dev->misc.this_device);
+
+	dev->layer.ctrlcmd = caif_chrflowctrl_cb;
+
+	/* Add the device */
+	spin_lock(&list_lock);
+	list_add(&dev->list_field, &caif_chrdev_list);
+	spin_unlock(&list_lock);
+
+	IF_CAIF_TRACE(print_device_list());
+
+	CAIFLOG_EXIT("");
+	mutex_unlock(&dev->mutex);
+	return 0;
+err_failed:
+	action->name.name[0] = '\0';
+	action->major = -1;
+	action->minor = -1;
+	kfree(dev);
+	CAIFLOG_EXIT("");
+	return result;
+}
+
+
+int chrdev_remove(char *name)
+{
+	int ret = 0;
+
+	struct caif_char_dev *dev = NULL;
+	CAIFLOG_ENTER("");
+
+	IF_CAIF_TRACE(print_device_list());
+
+	/* Find device from name */
+	dev = find_device(-1, name, 0);
+	if (!dev)
+		return -EBADF;
+
+
+	mutex_lock_interruptible(&dev->mutex);
+
+	if (test_bit(STATE_IS_OPEN_BIT, (void *) &dev->status)) {
+		CAIFLOG_TRACE
+		    ("[%s:%d] Device is opened (dev=%p) file_mode = 0x%x\n",
+		     __func__, __LINE__, dev, dev->file_mode);
+		mutex_unlock(&dev->mutex);
+		return -EBUSY;
+	}
+
+	/* Remove from list */
+	(void) find_device(-1, name, 1);
+
+	drain_queue(dev);
+	ret = misc_deregister(&dev->misc);
+
+	cfglu_free(dev->pktq);
+	mutex_unlock(&dev->mutex);
+	kfree(dev);
+
+	IF_CAIF_TRACE(print_device_list());
+
+	return ret;
+}
+
+
+int chrdev_mgmt(int action, union caif_action *param)
+{
+
+	switch (action) {
+	case CAIF_ACT_CREATE_DEVICE:
+		return chrdev_create(&param->create_channel);
+	case CAIF_ACT_DELETE_DEVICE:
+		return chrdev_remove(param->delete_channel.name);
+	default:
+		return -EINVAL;
+	}
+}
+
+int caif_chrinit_module(void)
+{
+	CAIFLOG_ENTER("");
+	CAIFLOG_TRACE("\nCompiled:%s:%s\n", __DATE__, __TIME__);
+	spin_lock_init(&list_lock);
+	caif_register_chrdev(chrdev_mgmt);
+	return 0;
+}
+
+void caif_chrexit_module(void)
+{
+	int result;
+
+	CAIFLOG_ENTER("");
+	IF_CAIF_TRACE(print_device_list());
+
+	do {
+		/* Remove any device (the first in the list) */
+		result = chrdev_remove(NULL);
+	} while (result == 0);
+
+	caif_unregister_chrdev();
+
+	IF_CAIF_TRACE(print_device_list());
+	CAIFLOG_EXIT("");
+}
+
+module_init(caif_chrinit_module);
+module_exit(caif_chrexit_module);
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
new file mode 100644
index 0000000..1d80f09
--- /dev/null
+++ b/net/caif/chnl_net.c
@@ -0,0 +1,464 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2 or later.
+*
+*/
+
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+
+#include <linux/if_ether.h>
+#include <linux/moduleparam.h>
+#include <linux/ip.h>
+
+/* Caif header files. */
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+
+#include "caif_chr.h"
+#include "caif_log.h"
+
+
+#define SIZE_MTU 1500
+#define SIZE_MTU_MAX 4080 /*FIXME: check this number*/
+#define SIZE_MTU_MIN 68	 /*FIXME: check this number*/
+
+static LIST_HEAD(chnl_net_list);
+static spinlock_t list_lock;
+
+MODULE_LICENSE("GPL");
+
+static int loop;
+module_param(loop, bool, S_IRUGO);
+MODULE_PARM_DESC(loop,
+		"Loop enabled or not (looping will switch src "
+		 "and dest of transmitted packages)");
+/*Flow status to remember and control the transmission*/
+static bool flowenabled;
+
+struct chnl_net {
+	layer_t chnl;
+	struct net_device_stats stats;
+	spinlock_t lock;
+	struct caif_channel_config config;
+	struct list_head list_field;
+	struct net_device *netdev;
+	char name[256];
+	bool deviceOpen;
+};
+
+struct net_device *netdevptr;
+
+static struct chnl_net *find_device(char *name, bool remove_from_list)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct chnl_net *dev = NULL;
+	struct chnl_net *tmp;
+	CAIFLOG_ENTER("");
+	spin_lock(&list_lock);
+	CAIFLOG_TRACE("[%s:%d] start looping \n", __func__,
+		__LINE__);
+	list_for_each_safe(list_node, n, &chnl_net_list) {
+		tmp =
+		list_entry(list_node, struct chnl_net,
+			list_field);
+		if (name) {	/* find from name */
+			if (!strncmp(tmp->name, name, sizeof(tmp->name)))
+				dev = tmp;
+			else
+				/* Get the first element if name
+				 * is not specified*/
+				dev = tmp;
+
+			if (dev) {
+				CAIFLOG_TRACE("[%s:%d] match %s \n",
+					__func__, __LINE__,  name);
+				if (remove_from_list)
+					list_del(list_node);
+
+				break;
+			}
+		}
+	}
+	spin_unlock(&list_lock);
+	return dev;
+}
+
+
+
+static int chnl_recv_cb(layer_t *layr, cfpkt_t *pkt)
+{
+	struct sk_buff *skb;
+	caif_packet_funcs_t f;
+	struct chnl_net *priv  = NULL;
+	int pktlen;
+
+#ifdef CAIF_USE_SKB
+#else
+	int actual_len;
+#endif
+	int err = 0;
+
+	priv = container_of(layr, struct chnl_net, chnl);
+
+	if (!priv) {
+		printk(KERN_INFO "chnl_recv_cb: netdev container not found\n");
+		return -EINVAL;
+	}
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	/* Get length of caif packet. */
+	pktlen = f.cfpkt_getlen(pkt);
+
+
+#ifdef CAIF_USE_SKB
+	/* TODO: Don't we make to much assumptions here ?
+	 * Cast received packet to a native sk_buff. */
+	skb = (struct sk_buff *) f.cfpkt_tonative(pkt);
+#else
+	skb = dev_alloc_skb(pktlen);
+
+	if (!skb) {
+		printk(KERN_INFO "chnl_recv_cb: dev_alloc_skb failed.\n");
+		/* Update statistics. */
+		priv->netdev->stats.rx_dropped++;
+		err = -ENOMEM;
+		goto err_alloc_skb;
+	}
+
+	/* Extract data from the caif packet and copy it to the skb. */
+	f.cfpkt_extract(pkt, skb_put(skb, pktlen), pktlen, &actual_len);
+#endif
+	/* Pass some minimum information and send the
+	 * packet to the net stack. */
+	skb->dev = priv->netdev;
+	skb->protocol = htons(ETH_P_IP);
+	/*FIXME: This is wrong checksum is needed!!*/
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	/*netif_rx(skb);*/
+	if (in_interrupt())
+		netif_rx(skb);
+	else
+		netif_rx_ni(skb);
+
+	/* Update statistics. */
+	priv->netdev->stats.rx_packets++;
+	priv->netdev->stats.rx_bytes += pktlen;
+
+#ifdef CAIF_USE_SKB
+#else
+
+err_alloc_skb:
+	f.cfpkt_destroy(pkt);
+#endif
+
+	return err;
+}
+
+static void chnl_flowctrl_cb(layer_t *layr, caif_ctrlcmd_t flow, int phyid)
+{
+	struct chnl_net *priv  = NULL;
+	CAIFLOG_TRACE("NET flowctrl func called flow: %s.\n",
+		flow == CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
+		flow == CAIF_CTRLCMD_INIT_RSP ? "INIT" :
+		flow == CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
+		flow == CAIF_CTRLCMD_DEINIT_RSP ? "CLOSE/DEINIT" :
+		flow == CAIF_CTRLCMD_INIT_FAIL_RSP ? "OPEN_FAIL" :
+		flow == CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ?
+		"REMOTE_SHUTDOWN" : "UKNOWN CTRL COMMAND");
+
+	priv = container_of(layr, struct chnl_net, chnl);
+
+	switch (flow) {
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+	case CAIF_CTRLCMD_DEINIT_RSP:
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		flowenabled = false;
+		netif_tx_disable(priv->netdev);
+		break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+	case CAIF_CTRLCMD_INIT_RSP:
+		flowenabled = true;
+		netif_wake_queue(priv->netdev);
+		break;
+
+	default:
+		break;
+	}
+
+
+}
+
+int chnl_net_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct chnl_net *priv;
+	cfpkt_t *pkt = NULL;
+	int len;
+	caif_packet_funcs_t f;
+	int result = -1;
+
+	if (!flowenabled) {
+		#ifndef CAIF_USE_SKB
+			dev_kfree_skb(skb);
+		#endif
+		CAIFLOG_TRACE("Dropping packets Flow OFF\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	if (loop) {
+		struct iphdr *hdr;
+		__be32 swap;
+		/* Retrieve IP header. */
+		hdr = ip_hdr(skb);
+		/* Change source and destination address. */
+		swap = hdr->saddr;
+		hdr->saddr = hdr->daddr;
+		hdr->daddr = swap;
+	}
+
+	/* Store original skb length. */
+	len = skb->len;
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+#ifdef CAIF_USE_SKB
+	/* TODO: Don't we make to much assumptions here ?
+	 * Cast sk_buff to cfpck. */
+	pkt = f.cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
+#else
+	/* Create a caif packet based on the skbuf. */
+	pkt = f.cfpkt_create_xmit_pkt(skb->data, skb->len);
+
+	if (!pkt) {
+		printk(KERN_INFO "chnl_write: cfpkt_create failed.\n");
+		goto err_cfpkt_create;
+	}
+#endif
+
+	/* Get our private data. */
+	priv = (struct chnl_net *)netdev_priv(dev);
+
+	if (!priv) {
+		printk(KERN_INFO "chnl_write: priv not found\n");
+		#ifndef CAIF_USE_SKB
+			goto err_cfpkt_create;
+		#else
+			return -ENOSPC;
+		#endif
+	}
+
+	/* Send the packet down the stack. */
+	result = priv->chnl.dn->transmit(priv->chnl.dn, NULL, pkt);
+	if (result) {
+		if (result == CFGLU_ERETRY)
+			result = NETDEV_TX_BUSY;
+
+	#ifndef CAIF_USE_SKB
+		f.cfpkt_destroy(pkt);
+	#endif
+		return result;
+	}
+	/* Update statistics. */
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
+
+#ifndef CAIF_USE_SKB
+	dev_kfree_skb(skb);
+#endif
+	return NETDEV_TX_OK;
+
+#ifndef CAIF_USE_SKB
+err_cfpkt_create:
+	dev_kfree_skb(skb);/*FIXME: Freeing necessary here?*/
+	/*FIXME: Check if ENOMEM or ENOSPC should be used in CAIF?*/
+	return -ENOSPC;
+#endif
+}
+
+/*FIXME: MTU is not used, so why do we handle it in this function?
+ *  who calls it?*/
+int chnl_net_change_mtu(struct net_device *dev, int mtu)
+{
+	unsigned long flags;
+	struct chnl_net *priv = netdev_priv(dev);
+	spinlock_t *lock = &priv->lock;
+
+	/* check range.
+	 *  MTU can not exceed maximum CAIF frame size (4095 bytes) */
+	if ((mtu < SIZE_MTU_MIN) || (mtu > SIZE_MTU_MAX))
+		return -EINVAL;
+
+	spin_lock_irqsave(lock, flags);
+	dev->mtu = mtu;
+	spin_unlock_irqrestore(lock, flags);
+	return 0;
+}
+
+
+int chnl_net_open(struct net_device *dev)
+{
+	struct chnl_net *priv = NULL;
+	int result;
+	CAIFLOG_ENTER("chnl_net_open:");
+	priv = (struct chnl_net *)netdev_priv(dev);
+	printk(KERN_INFO "chnl_net_open dev name: %s\n", priv->name);
+
+	if (!priv) {
+		printk(KERN_WARNING "chnl_net_open: no priv\n");
+		return -ENODEV;
+	}
+	result = caifdev_adapt_register(&priv->config, &priv->chnl);
+	if (result != 0) {
+		printk(KERN_WARNING
+		"chnl_net_open: err: Unable to open device, Err:%d\n", result);
+		return -ENODEV;
+	}
+	priv->deviceOpen = true;
+	CAIFLOG_EXIT("chnl_net_open:\n");
+	return 0;
+}
+
+int chnl_net_stop(struct net_device *dev)
+{
+	struct chnl_net *priv;
+	int result;
+	CAIFLOG_ENTER("chnl_net_stop:");
+	printk("chnl_net_stop: %s \n", dev->name);
+	priv = (struct chnl_net *)netdev_priv(dev);
+	result = caifdev_adapt_unregister(&priv->chnl);
+	if (result != 0) {
+		printk(KERN_WARNING
+		"chnl_net_stop: err: Unable to STOP device, Err:%d\n", result);
+		return -EBUSY;
+	}
+	priv->deviceOpen = false;
+	CAIFLOG_EXIT("chnl_net_stop:\n");
+	return 0;
+}
+
+
+void chnl_net_init(struct net_device *dev)
+{
+	CAIFLOG_ENTER("chnl_net_init:");
+	dev->open = chnl_net_open;
+	dev->stop = chnl_net_stop;
+	dev->hard_start_xmit = chnl_net_hard_start_xmit;
+	dev->flags |= IFF_NOARP; /*FIXME: Check additional flags*/
+	dev->mtu = SIZE_MTU;
+	CAIFLOG_EXIT("chnl_net_init:\n");
+}
+
+
+int netdev_create(struct caif_channel_create_action *action)
+{
+	struct chnl_net *priv;
+
+	int result = -1;
+
+	netdevptr = alloc_netdev(sizeof(struct chnl_net),
+				 action->name.name, chnl_net_init);
+	priv = (struct chnl_net *)netdev_priv(netdevptr);
+	memset(&priv->config, 0, sizeof(priv->config));
+	priv->chnl.receive = chnl_recv_cb;
+	priv->chnl.ctrlcmd = chnl_flowctrl_cb;
+	priv->config = action->config;
+	priv->netdev = netdevptr;
+	strcpy(priv->name, action->name.name);
+	priv->deviceOpen = false;
+
+	/* Make sure flow is disabled until INIT_RSP is received. */
+	netif_tx_disable(priv->netdev);
+
+	spin_lock_init(&priv->lock);
+	/* Add the device */
+	spin_lock(&list_lock);
+	list_add(&priv->list_field, &chnl_net_list);
+	spin_unlock(&list_lock);
+
+	printk(KERN_WARNING "netdev_create: Creating channel: %s\n",
+	       action->name.name);
+
+	if (!priv->netdev) {
+		printk(KERN_WARNING "chnl: can't allocate netdev.\n");
+		return	-ENODEV;
+	}
+	result = register_netdev(priv->netdev);
+	if (result < 0) {
+		printk(KERN_WARNING
+		"chnl: err: %d, can't register netdev.\n", result);
+		free_netdev(priv->netdev);
+		return	-ENODEV;
+	}
+	return 0;
+
+}
+
+int delete_device(struct chnl_net *dev)
+{
+	if (dev->netdev) {
+		unregister_netdev(dev->netdev);
+		free_netdev(dev->netdev);
+	}
+	printk(KERN_WARNING
+	"delete_device: Removing Device: %s\n", dev->name);
+	return 0;
+}
+
+int netdev_remove(char *name)
+{
+	struct chnl_net *dev = NULL;
+	/* Find device from name */
+	dev = find_device(name, true);
+	if (!dev)
+		return -EBADF;
+	else
+		if (delete_device(dev) != 0)
+			return -EBUSY;
+
+	return 0;
+}
+
+
+int netdev_mgmt(int action, union caif_action *param)
+{
+
+	switch (action) {
+	case CAIF_ACT_CREATE_DEVICE:
+		return netdev_create(&param->create_channel);
+	case CAIF_ACT_DELETE_DEVICE:
+		return netdev_remove(param->delete_channel.name);
+	default:
+		return -EINVAL;
+	}
+}
+
+int chnl_init_module(void)
+{
+	caif_register_netdev(netdev_mgmt);
+	return 0; /*FIXME: Return error code for success*/
+}
+
+void chnl_exit_module(void)
+{
+	struct chnl_net *dev = NULL;
+
+	while ((dev = find_device(NULL, true)) != NULL) {
+		/* Remove any device (the first in the list) */
+		delete_device(dev);
+	};
+	caif_unregister_netdev();
+}
+
+module_init(chnl_init_module);
+module_exit(chnl_exit_module);
-- 
1.6.0.4

