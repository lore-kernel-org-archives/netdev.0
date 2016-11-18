From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) Bus driver
Date: Fri, 18 Nov 2016 14:42:10 -0800
Message-ID: <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VNIC bus driver interfaces between hardware independent VNIC
functionality and the hardware dependent VNIC functionality.
Support creation of Intel HFI VNIC devices and binding with Intel
HFI VNIC drivers. Define the bus operations the HFI VNIC device
should support.

Change-Id: I91f65d0957d4866b133ee2b6b5246c49cbc0ba69
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 MAINTAINERS                                        |   7 +
 drivers/infiniband/Kconfig                         |   1 +
 drivers/infiniband/sw/Makefile                     |   1 +
 drivers/infiniband/sw/intel/vnic/Makefile          |   1 +
 .../infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig  |   8 +
 .../infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile |   5 +
 .../sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c      | 366 +++++++++++++++++++++
 .../infiniband/sw/intel/vnic/include/hfi_vnic.h    | 282 ++++++++++++++++
 8 files changed, 671 insertions(+)
 create mode 100644 drivers/infiniband/sw/intel/vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/include/hfi_vnic.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 3d838cf..8c37878 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5628,6 +5628,13 @@ F:	drivers/block/cciss*
 F:	include/linux/cciss_ioctl.h
 F:	include/uapi/linux/cciss_ioctl.h
 
+HFI-VNIC DRIVER
+M:	Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+M:	Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Supported
+F:	drivers/infiniband/sw/intel/vnic
+
 HFI1 DRIVER
 M:	Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index fb3fb89..7fe9095 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -84,6 +84,7 @@ source "drivers/infiniband/ulp/srpt/Kconfig"
 source "drivers/infiniband/ulp/iser/Kconfig"
 source "drivers/infiniband/ulp/isert/Kconfig"
 
+source "drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig"
 source "drivers/infiniband/sw/rdmavt/Kconfig"
 source "drivers/infiniband/sw/rxe/Kconfig"
 
diff --git a/drivers/infiniband/sw/Makefile b/drivers/infiniband/sw/Makefile
index 8b095b2..4fa6058 100644
--- a/drivers/infiniband/sw/Makefile
+++ b/drivers/infiniband/sw/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_INFINIBAND_RDMAVT)		+= rdmavt/
 obj-$(CONFIG_RDMA_RXE)			+= rxe/
+obj-$(CONFIG_INFINIBAND)		+= intel/vnic/
diff --git a/drivers/infiniband/sw/intel/vnic/Makefile b/drivers/infiniband/sw/intel/vnic/Makefile
new file mode 100644
index 0000000..083e55b
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_HFI_VNIC_BUS)		+= hfi_vnic_bus/
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig
new file mode 100644
index 0000000..85952d6
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig
@@ -0,0 +1,8 @@
+config HFI_VNIC_BUS
+	tristate "Intel HFI VNIC bus support"
+	depends on X86_64
+	---help---
+	This is HFI Virtual Network Interface Controller (VNIC) Bus driver
+	for binding Intel HFI VNIC devices and drivers. It separates the
+	hardware independent VNIC functionaity from the hw dependent. It
+	provides APIs to register and unregister VNIC devices and drivers.
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile
new file mode 100644
index 0000000..5fac098
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Makefile
@@ -0,0 +1,5 @@
+# Makefile - Intel HFI Virtual Network Controller bus driver
+# Copyright(c) 2016, Intel Corporation.
+#
+ccflags-y += -I$(src)/../include
+obj-$(CONFIG_HFI_VNIC_BUS) += hfi_vnic_bus.o
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c
new file mode 100644
index 0000000..5455fc7
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/hfi_vnic_bus.c
@@ -0,0 +1,366 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI Virtual Network Controller bus driver
+ */
+#include <linux/idr.h>
+#include <linux/module.h>
+
+#include "hfi_vnic.h"
+
+#define HFI_VNIC_ID_HFI_SHFT     16
+#define HFI_VNIC_ID_PORT_SHFT     8
+#define HFI_VNIC_GET_ID(hfi, port, vport)   (((hfi) << HFI_VNIC_ID_HFI_SHFT) | \
+				((port) << HFI_VNIC_ID_PORT_SHFT) | (vport))
+
+/* Unique numbering for vnic control devices */
+static struct ida hfi_vnic_ctrl_ida;
+
+/* Unique numbering for vnic devices */
+static struct idr hfi_vnic_idr;
+
+/* hfi vnic device type */
+static const struct device_type hfi_vnic_dev_type = {
+	.name = "hfi_vnic_dev",
+};
+
+/* hfi vnic control device type */
+static const struct device_type hfi_vnic_ctrl_dev_type = {
+	.name = "hfi_vnic_ctrl_dev",
+};
+
+static inline enum hfi_vnic_drv_type
+hfi_vnic_get_drv_type(struct device_driver *drv)
+{
+	return container_of(drv, struct hfi_vnic_drvwrap, driver)->type;
+}
+
+/* hfi_vnic_match_device - device, driver match function */
+static int hfi_vnic_match_device(struct device *dev, struct device_driver *drv)
+{
+	enum hfi_vnic_drv_type drv_type = hfi_vnic_get_drv_type(drv);
+
+	if ((dev->type == &hfi_vnic_dev_type) && (drv_type == HFI_VNIC_DRV))
+		return 1;
+	else if ((dev->type == &hfi_vnic_ctrl_dev_type) &&
+		 (drv_type == HFI_VNIC_CTRL_DRV))
+		return 1;
+
+	return 0;
+}
+
+/* hfi vnic bus structure */
+static struct bus_type hfi_vnic_bus = {
+	.name = "hfi_vnic_bus",
+	.match = hfi_vnic_match_device,
+};
+
+static void hfi_vnic_dev_release(struct device *dev)
+{
+	struct hfi_vnic_device *vdev = container_of(dev,
+					    struct hfi_vnic_device, dev);
+	kfree(vdev);
+}
+
+/**
+ * hfi_vnic_get_dev - return hfi vnic device
+ * @cdev: pointer to the control device
+ * @port_num: hfi port number
+ * @vport_num: vnic port number
+ *
+ * Return pointer to the vnic device on the given hfi instance
+ * (control device) and hfi port, with specified vnic port number.
+ *
+ */
+struct hfi_vnic_device *hfi_vnic_get_dev(struct hfi_vnic_ctrl_device *cdev,
+					 u8 port_num, u8 vport_num)
+{
+	int id;
+
+	if (vport_num == HFI_MAX_NUM_VNICS)
+		return NULL;
+
+	id = HFI_VNIC_GET_ID(cdev->id, port_num, vport_num);
+	return idr_find(&hfi_vnic_idr, id);
+}
+EXPORT_SYMBOL(hfi_vnic_get_dev);
+
+/**
+ * hfi_vnic_device_register - register hfi vnic device on the hfi vnic bus
+ * @cdev: pointer to the control device
+ * @port_num: hfi port number
+ * @vport_num: vnic port number
+ * @priv: pointer to the device private data
+ * @ops: pointer to the bus operations
+ * @hfi_info: hfi device hw specific information
+ *
+ * A hfi vnic device is created and registered on the hfi vnic bus.
+ * The device is assigned a unique id based on the hfi instance (id of the
+ * control device associated with it), hfi port number and the vnic port
+ * number on the given hfi port.
+ */
+struct hfi_vnic_device *hfi_vnic_device_register(
+					 struct hfi_vnic_ctrl_device *cdev,
+					 u8 port_num, u8 vport_num, void *priv,
+					 struct hfi_vnic_ops *ops,
+					 struct hfi_vnic_info hfi_info)
+{
+	struct hfi_vnic_device *vdev;
+	int id, rc;
+
+	if (vport_num == HFI_MAX_NUM_VNICS)
+		return ERR_PTR(-EINVAL);
+
+	id = HFI_VNIC_GET_ID(cdev->id, port_num, vport_num);
+	vdev = kzalloc(sizeof(*vdev), GFP_KERNEL);
+	if (!vdev)
+		return ERR_PTR(-ENOMEM);
+
+	rc = idr_alloc(&hfi_vnic_idr, vdev, id, (id + 1), GFP_NOWAIT);
+	if (rc < 0) {
+		kfree(vdev);
+		goto idr_err;
+	}
+
+	vdev->dev.release = hfi_vnic_dev_release;
+	vdev->dev.bus = &hfi_vnic_bus;
+
+	vdev->id = id;
+	vdev->cdev = cdev;
+	vdev->bus_ops = ops;
+	vdev->hfi_priv = priv;
+	vdev->hfi_info = hfi_info;
+	vdev->port_num = port_num;
+	vdev->vport_num = vport_num;
+	vdev->dev.parent = cdev->dev.parent;
+
+	vdev->dev.type = &hfi_vnic_dev_type;
+	dev_set_name(&vdev->dev, "hfi_vnic_%02x.%02x.%02x",
+		     cdev->id, port_num, vport_num);
+
+	rc = device_register(&vdev->dev);
+	if (rc) {
+		put_device(&vdev->dev);
+		goto dev_err;
+	}
+
+	dev_info(&vdev->dev, "added vport\n");
+	return vdev;
+
+dev_err:
+	idr_remove(&hfi_vnic_idr, id);
+idr_err:
+	return ERR_PTR(rc);
+}
+EXPORT_SYMBOL(hfi_vnic_device_register);
+
+/**
+ * hfi_vnic_device_unregister - remove hfi vnic device from the hfi vnic bus
+ * @vdev: pointer to hfi vnic device
+ */
+void hfi_vnic_device_unregister(struct hfi_vnic_device *vdev)
+{
+	int id = vdev->id;
+
+	dev_info(&vdev->dev, "removing vport\n");
+	device_unregister(&vdev->dev);
+	idr_remove(&hfi_vnic_idr, id);
+}
+EXPORT_SYMBOL(hfi_vnic_device_unregister);
+
+/**
+ * hfi_vnic_driver_register - register hfi vnic driver on the hfi vnic bus
+ * @drv: pointer to hfi vnic driver
+ */
+int hfi_vnic_driver_register(struct hfi_vnic_driver *drv)
+{
+	drv->drvwrap.driver.bus = &hfi_vnic_bus;
+	return driver_register(&drv->drvwrap.driver);
+}
+EXPORT_SYMBOL(hfi_vnic_driver_register);
+
+/**
+ * hfi_vnic_driver_unregister - remove hfi vnic driver from the hfi vnic bus
+ * @drv: pointer to hfi vnic driver
+ */
+void hfi_vnic_driver_unregister(struct hfi_vnic_driver *drv)
+{
+	driver_unregister(&drv->drvwrap.driver);
+}
+EXPORT_SYMBOL(hfi_vnic_driver_unregister);
+
+static void hfi_vnic_ctrl_dev_release(struct device *dev)
+{
+	struct hfi_vnic_ctrl_device *cdev = container_of(dev,
+					    struct hfi_vnic_ctrl_device, dev);
+	kfree(cdev);
+}
+
+/**
+ * hfi_vnic_ctrl_device_register - register hfi vnic control device
+ * @parent: pointer to the parent device
+ * @ibdev: pointer to the ib device
+ * @num_ports: number of hfi ports
+ * @priv: pointer to the device private data
+ * @ops: pointer to the bus operations
+ *
+ * A hfi vnic control device is created and registered on the hfi vnic bus.
+ * The device is assigned a unique id.
+ */
+struct hfi_vnic_ctrl_device *hfi_vnic_ctrl_device_register(
+					   struct device *parent,
+					   struct ib_device *ibdev,
+					   u8 num_ports, void *priv,
+					   struct hfi_vnic_ctrl_ops *ops)
+{
+	struct hfi_vnic_ctrl_device *cdev;
+	int rc;
+
+	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
+	if (!cdev)
+		return ERR_PTR(-ENOMEM);
+
+	rc = ida_simple_get(&hfi_vnic_ctrl_ida, 0, 0, GFP_KERNEL);
+	if (rc < 0) {
+		kfree(cdev);
+		goto ida_err;
+	}
+
+	cdev->id = rc;
+	cdev->dev.release = hfi_vnic_ctrl_dev_release;
+	cdev->dev.bus = &hfi_vnic_bus;
+	cdev->dev.parent = parent;
+
+	cdev->ibdev = ibdev;
+	cdev->num_ports = num_ports;
+	cdev->ctrl_ops = ops;
+	cdev->hfi_priv = priv;
+	dev_set_name(&cdev->dev, "hfi_vnic_ctrl_%02x", cdev->id);
+	cdev->dev.type = &hfi_vnic_ctrl_dev_type;
+	rc = device_register(&cdev->dev);
+	if (rc) {
+		put_device(&cdev->dev);
+		goto dev_err;
+	}
+
+	dev_info(&cdev->dev, "added vnic control port\n");
+	return cdev;
+
+dev_err:
+	ida_simple_remove(&hfi_vnic_ctrl_ida, cdev->id);
+ida_err:
+	return ERR_PTR(rc);
+}
+EXPORT_SYMBOL(hfi_vnic_ctrl_device_register);
+
+/**
+ * hfi_vnic_ctrl_device_unregister - remove hfi vnic control device
+ * @cdev: pointer to hfi vnic control device
+ */
+void hfi_vnic_ctrl_device_unregister(struct hfi_vnic_ctrl_device *cdev)
+{
+	int id = cdev->id;
+
+	dev_info(&cdev->dev, "removing vnic control port\n");
+	device_unregister(&cdev->dev);
+	ida_simple_remove(&hfi_vnic_ctrl_ida, id);
+}
+EXPORT_SYMBOL(hfi_vnic_ctrl_device_unregister);
+
+/**
+ * hfi_vnic_ctrl_driver_register - register hfi vnic control driver
+ * @drv: pointer to hfi vnic control driver
+ */
+int hfi_vnic_ctrl_driver_register(struct hfi_vnic_ctrl_driver *drv)
+{
+	drv->drvwrap.driver.bus = &hfi_vnic_bus;
+	return driver_register(&drv->drvwrap.driver);
+}
+EXPORT_SYMBOL(hfi_vnic_ctrl_driver_register);
+
+/**
+ * hfi_vnic_ctrl_driver_unregister - remove hfi vnic control driver
+ * @drv: pointer to hfi vnic control driver
+ */
+void hfi_vnic_ctrl_driver_unregister(struct hfi_vnic_ctrl_driver *drv)
+{
+	driver_unregister(&drv->drvwrap.driver);
+}
+EXPORT_SYMBOL(hfi_vnic_ctrl_driver_unregister);
+
+/* hfi_vnic_bus_init - initialize the hfi vnic bus drvier */
+static int hfi_vnic_bus_init(void)
+{
+	int rc;
+
+	ida_init(&hfi_vnic_ctrl_ida);
+	idr_init(&hfi_vnic_idr);
+
+	rc = bus_register(&hfi_vnic_bus);
+	if (rc) {
+		pr_err("hfi vnic bus init failed %d\n", rc);
+		idr_destroy(&hfi_vnic_idr);
+		ida_destroy(&hfi_vnic_ctrl_ida);
+	}
+
+	return rc;
+}
+postcore_initcall(hfi_vnic_bus_init);
+
+/* hfi_vnic_bus_deinit - remove the hfi vnic bus drvier */
+static void hfi_vnic_bus_deinit(void)
+{
+	bus_unregister(&hfi_vnic_bus);
+	idr_destroy(&hfi_vnic_idr);
+	ida_destroy(&hfi_vnic_ctrl_ida);
+}
+module_exit(hfi_vnic_bus_deinit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Intel Corporation");
+MODULE_DESCRIPTION("Intel HFI Virtual Network Controller bus driver");
diff --git a/drivers/infiniband/sw/intel/vnic/include/hfi_vnic.h b/drivers/infiniband/sw/intel/vnic/include/hfi_vnic.h
new file mode 100644
index 0000000..a5a723b
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/include/hfi_vnic.h
@@ -0,0 +1,282 @@
+#ifndef _HFI_VNIC_H
+#define _HFI_VNIC_H
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI Virtual Network Interface Controller (VNIC)
+ * driver interfaces
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/module.h>
+
+/* Maximum possible number of VNICs */
+#define HFI_MAX_NUM_VNICS     255
+
+#define HFI_VNIC_MAX_QUEUE    16
+
+#define HFI_VNIC_CAP_SG   BIT(0)
+
+enum hfi_vnic_drv_type {
+	HFI_VNIC_DRV,          /* VNIC NETDEV driver */
+	HFI_VNIC_CTRL_DRV      /* VNIC control driver */
+};
+
+enum {
+	/* Packet received on queue 0 */
+	HFI_VNIC_EVT_RX0,
+	/* Tx wakeup notification on queue 0 */
+	HFI_VNIC_EVT_TX0
+		= HFI_VNIC_EVT_RX0 + HFI_VNIC_MAX_QUEUE,
+	HFI_VNIC_NUM_EVTS
+		= HFI_VNIC_EVT_TX0 + HFI_VNIC_MAX_QUEUE,
+};
+
+struct hfi_vnic_device;
+struct hfi_vnic_ctrl_device;
+
+typedef void (*hfi_vnic_evt_cb_fn)(struct hfi_vnic_device *vdev, u8 evt);
+
+/**
+ * struct hfi_vnic_ops - HFI HW specific VNIC functions
+ * @init: Initialize the hfi device
+ * @deinit: De-initialize the hfi device
+ * @open: Open vnic hfi device for vnic traffic
+ * @close: Close vnic hfi device for vnic traffic
+ * @put_skb: transmit an skb
+ * @get_skb: receive an skb
+ * @get_read_avail: return number of available to read
+ * @get_write_avail: return whether write space is available or not
+ * @select_queue: select tx queue
+ * @config_notify: enable/disable notification
+ */
+struct hfi_vnic_ops {
+	int (*init)(struct hfi_vnic_device *vdev);
+	void (*deinit)(struct hfi_vnic_device *vdev);
+	int (*open)(struct hfi_vnic_device *vdev,
+		    hfi_vnic_evt_cb_fn cb);
+	void (*close)(struct hfi_vnic_device *vdev);
+	int (*put_skb)(struct hfi_vnic_device *vdev,
+		       u8 q_idx, struct sk_buff *skb);
+	struct sk_buff *(*get_skb)(struct hfi_vnic_device *vdev, u8 q_idx);
+	u16 (*get_read_avail)(struct hfi_vnic_device *vdev, u8 q_idx);
+	bool (*get_write_avail)(struct hfi_vnic_device *vdev, u8 q_idx);
+	u8 (*select_queue)(struct hfi_vnic_device *vdev, u8 vl, u8 entropy);
+	void (*config_notify)(struct hfi_vnic_device *vdev,
+			      u8 evt, bool enable);
+};
+
+/**
+ * struct hfi_vnic_ctrl_ops - HFI HW specific VNIC control functions
+ * @add_vport: add a vnic port device
+ * @rem_vport: remove a vnic port device
+ */
+struct hfi_vnic_ctrl_ops {
+	int (*add_vport)(struct hfi_vnic_ctrl_device *cdev,
+			 u8 port_num, u8 vport_num);
+	void (*rem_vport)(struct hfi_vnic_ctrl_device *cdev,
+			  u8 port_num, u8 vport_num);
+};
+
+/**
+ * struct hfi_vnic_stats - HFI HW specific statistics
+ * @rx_fifo_errors: receive packets dropped due to fifo full
+ * @tx_fifo_errors: transmit packets dropped due to fifo full
+ * @rx_missed_errors: receive packets missed due to no memory
+ * @tx_carrier_errors: packet transmits when STL link is down
+ * @rx_bad_veswid: receive packets with invalid vesw id
+ * @rx_logic_errors: receive packets dropped due to other errors
+ * @tx_logic_errors: transmit packets dropped due to other errors
+ *
+ * This structure holds any statistics information that is
+ * collected by HW specific driver layer.
+ */
+struct hfi_vnic_stats {
+	u64  rx_fifo_errors;
+	u64  tx_fifo_errors;
+	u64  rx_missed_errors;
+	u64  tx_carrier_errors;
+	u64  rx_bad_veswid;
+	u64  rx_logic_errors;
+	u64  tx_logic_errors;
+};
+
+/**
+ * struct hfi_vnic_info - HFI HW specific VNIC information
+ * @cap: capabilities
+ * @num_rx_q: number of receive queues
+ * @num_tx_q: number of transmit queues
+ */
+struct hfi_vnic_info {
+	u32  cap;
+	u8   num_rx_q;
+	u8   num_tx_q;
+};
+
+/**
+ * struct hfi_vnic_device - HFI virtual NIC device
+ * @dev: device
+ * @id: unique hfi vnic device instance
+ * @vesw_id: virtual ethernet switch id
+ * @netdev: pointer to associated netdev
+ * @port_num: hfi port instance
+ * @vport_num: vnic port instance on the hfi port
+ * @cdev: vnic control device pointer
+ * @bus_ops: hfi vnic bus operations
+ * @hfi_priv: hfi private data pointer
+ * @hfi_info: hfi information
+ * @hfi_stats: per queue hfi statistics
+ */
+struct hfi_vnic_device {
+	struct device                dev;
+	int                          id;
+	u16                          vesw_id;
+	struct net_device           *netdev;
+	u8                           port_num;
+	u8                           vport_num;
+
+	struct hfi_vnic_ctrl_device *cdev;
+	struct hfi_vnic_ops         *bus_ops;
+	void                        *hfi_priv;
+	struct hfi_vnic_info         hfi_info;
+	struct hfi_vnic_stats        hfi_stats[HFI_VNIC_MAX_QUEUE];
+};
+
+/**
+ * struct hfi_vnic_ctrl_device - HFI virtual NIC control device
+ * @dev: device
+ * @id: unique hfi vnic control device instance
+ * @ibdev: pointer to ib device
+ * @num_ports: number of hfi ports
+ * @ctrl_ops: hfi vnic control operations
+ * @hfi_priv: hfi private data pointer
+ */
+struct hfi_vnic_ctrl_device {
+	struct device             dev;
+	int                       id;
+
+	struct ib_device         *ibdev;
+	u8                        num_ports;
+
+	struct hfi_vnic_ctrl_ops *ctrl_ops;
+	void                     *hfi_priv;
+};
+
+/**
+ * struct hfi_vnic_drvwrap - HFI vnic driver wrapper
+ * @type: driver type
+ * @driver: device driver
+ */
+struct hfi_vnic_drvwrap {
+	enum hfi_vnic_drv_type  type;
+	struct device_driver    driver;
+};
+
+/**
+ * struct hfi_vnic_driver - HFI virtual NIC driver
+ * @drvwrap: driver wrapper
+ */
+struct hfi_vnic_driver {
+	struct hfi_vnic_drvwrap  drvwrap;
+};
+
+/**
+ * struct hfi_vnic_ctrl_driver -  HFI virtual NIC Control driver
+ * @drvwrap: driver wrapper
+ */
+struct hfi_vnic_ctrl_driver {
+	struct hfi_vnic_drvwrap  drvwrap;
+};
+
+/* VNIC device interface functions */
+int hfi_vnic_driver_register(struct hfi_vnic_driver *drv);
+void hfi_vnic_driver_unregister(struct hfi_vnic_driver *drv);
+
+struct hfi_vnic_device *hfi_vnic_device_register(
+					 struct hfi_vnic_ctrl_device *cdev,
+					 u8 port_num, u8 vport_num, void *priv,
+					 struct hfi_vnic_ops *ops,
+					 struct hfi_vnic_info hfi_info);
+void hfi_vnic_device_unregister(struct hfi_vnic_device *vdev);
+
+struct hfi_vnic_device *hfi_vnic_get_dev(struct hfi_vnic_ctrl_device *cdev,
+					 u8 port_num, u8 vport_num);
+
+/* VNIC control device interface functions */
+int hfi_vnic_ctrl_driver_register(struct hfi_vnic_ctrl_driver *drv);
+void hfi_vnic_ctrl_driver_unregister(struct hfi_vnic_ctrl_driver *drv);
+
+struct hfi_vnic_ctrl_device *hfi_vnic_ctrl_device_register(
+					   struct device *parent,
+					   struct ib_device *ibdev,
+					   u8 num_ports, void *priv,
+					   struct hfi_vnic_ctrl_ops *ops);
+void hfi_vnic_ctrl_device_unregister(struct hfi_vnic_ctrl_device *cdev);
+
+/* hfi_vdev_get - Get module and vdev reference counts */
+static inline int hfi_vdev_get(struct hfi_vnic_device *vdev)
+{
+	struct module *owner = vdev->dev.parent->driver->owner;
+
+	if (owner && !try_module_get(owner))
+		return -ENXIO;
+
+	get_device(&vdev->dev);
+	return 0;
+}
+
+/* hfi_vdev_put - Put module and vdev reference counts */
+static inline void hfi_vdev_put(struct hfi_vnic_device *vdev)
+{
+	struct module *owner = vdev->dev.parent->driver->owner;
+
+	put_device(&vdev->dev);
+	module_put(owner);
+}
+
+#endif /* _HFI_VNIC_H */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
