From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 4/5] NetEffect 10Gb RNIC Userspace Library: userspace main c file
Date: Thu, 26 Oct 2006 19:49:38 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9ED0@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:19938 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1423735AbWJ0Ati convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:49:38 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace driver patch 4 of 5.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/src/userspace/libnes/src/nes_umain.c
new/src/userspace/libnes/src/nes_umain.c
--- old/src/userspace/libnes/src/nes_umain.c	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/src/nes_umain.c	2006-10-25
10:27:58.000000000 -0500
@@ -0,0 +1,251 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#if HAVE_CONFIG_H
+#  include <config.h>
+#endif				/* HAVE_CONFIG_H */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/mman.h>
+#include <pthread.h>
+
+#include "nes_umain.h"
+#include "nes-abi.h"
+
+long int page_size;
+
+#ifdef HAVE_SYSFS_LIBSYSFS_H
+#include <sysfs/libsysfs.h>
+#endif
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+#ifndef PCI_VENDOR_ID_NETEFFECT
+#define PCI_VENDOR_ID_NETEFFECT		0x1678
+#endif
+
+#ifndef PCI_DEVICE_ID_NETEFFECT_nes
+#define PCI_DEVICE_ID_NETEFFECT_nes	0x0100
+#endif
+
+
+#define HCA(v, d, t) \
+	{ .vendor = PCI_VENDOR_ID_##v,			\
+	  .device = PCI_DEVICE_ID_NETEFFECT_##d,		\
+	  .type = NETEFFECT_##t }
+
+struct {
+	unsigned vendor;
+	unsigned device;
+	enum nes_uhca_type type;
+} hca_table[] = {
+	HCA(NETEFFECT, nes, nes),};
+
+static struct ibv_context *nes_ualloc_context(struct ibv_device *,
int);
+static void nes_ufree_context(struct ibv_context *);
+
+static struct ibv_context_ops nes_uctx_ops = {
+	.query_device = nes_uquery_device,
+	.query_port = nes_uquery_port,
+	.alloc_pd = nes_ualloc_pd,
+	.dealloc_pd = nes_ufree_pd,
+	.reg_mr = nes_ureg_mr,
+	.dereg_mr = nes_udereg_mr,
+	.create_cq = nes_ucreate_cq,
+	.poll_cq = nes_upoll_cq,
+	.req_notify_cq = nes_uarm_cq,
+	.cq_event = NULL,
+	.resize_cq = nes_uresize_cq,
+	.destroy_cq = nes_udestroy_cq,
+	.create_srq = NULL,
+	.modify_srq = NULL,
+	.query_srq = NULL,
+	.destroy_srq = NULL,
+	.post_srq_recv = NULL,
+	.create_qp = nes_ucreate_qp,
+	.modify_qp = nes_umodify_qp,
+	.destroy_qp = nes_udestroy_qp,
+	.post_send = nes_upost_send,
+	.post_recv = nes_upost_recv,
+	.create_ah = nes_ucreate_ah,
+	.destroy_ah = nes_udestroy_ah,
+	.attach_mcast = nes_uattach_mcast,
+	.detach_mcast = nes_udetach_mcast
+};
+
+
+/**
+ * nes_ualloc_context
+ * 
+ * @param ibdev
+ * @param cmd_fd
+ * 
+ * @return struct ibv_context*
+ */
+static struct ibv_context *nes_ualloc_context(struct ibv_device *ibdev,
int cmd_fd)
+{
+	// void *mymmapp = NULL;
+	struct ibv_pd *ibv_pd;
+	struct nes_uvcontext *nesvctx;
+	struct ibv_get_context cmd;
+	struct nes_ualloc_ucontext_resp resp;
+
+	page_size = sysconf(_SC_PAGESIZE);
+
+	nesvctx = malloc(sizeof *nesvctx);
+	if (!nesvctx)
+		return NULL;
+
+	nesvctx->ibv_ctx.cmd_fd = cmd_fd;
+
+	if (ibv_cmd_get_context(&nesvctx->ibv_ctx, &cmd, sizeof cmd,
+				&resp.ibv_resp, sizeof resp))
+		goto err_free;
+
+	nesvctx->ibv_ctx.device = ibdev;
+	nesvctx->ibv_ctx.ops = nes_uctx_ops;
+	nesvctx->max_pds = resp.max_pds;
+	nesvctx->max_qps = resp.max_qps;
+	nesvctx->wq_size = resp.wq_size;
+
+	/* Get a doorbell region for the CQs */
+	ibv_pd = nes_ualloc_pd(&nesvctx->ibv_ctx);
+	if (!ibv_pd)
+		goto err_free;
+	ibv_pd->context = &nesvctx->ibv_ctx;
+	nesvctx->nesupd = to_nes_upd(ibv_pd);
+
+
+	return (&nesvctx->ibv_ctx);
+
+err_free:
+ 	fprintf(stderr, PFX "%s: Failed to allocate context for
device.\n", __FUNCTION__);
+	free(nesvctx);
+
+	return NULL;
+}
+
+
+/**
+ * nes_ufree_context
+ * 
+ * @param ibctx
+ */
+static void nes_ufree_context(struct ibv_context *ibctx)
+{
+	struct nes_uvcontext *nesvctx = to_nes_uctx(ibctx);
+	nes_ufree_pd(&nesvctx->nesupd->ibv_pd);
+
+	free(nesvctx);
+}
+
+
+static struct ibv_device_ops nes_udev_ops = {
+	.alloc_context = nes_ualloc_context,
+	.free_context = nes_ufree_context
+};
+
+
+/**
+ * ibv_driver_init
+ * 
+ * @param uverbs_sys_path
+ * @param abi_version
+ * 
+ * @return struct ibv_device*
+ */
+struct ibv_device *ibv_driver_init(const char *uverbs_sys_path, int
abi_version)
+{
+	char value[8];
+	struct nes_udevice *dev;
+	unsigned vendor, device;
+	int i;
+
+	if (ibv_read_sysfs_file(uverbs_sys_path, "device/vendor", value,
sizeof(value)) < 0) {
+		return (NULL);
+	}
+
+	sscanf(value, "%i", &vendor);
+
+	if (ibv_read_sysfs_file(uverbs_sys_path, "device/device", value,
sizeof(value)) < 0) {
+		return (NULL);
+	}
+	sscanf(value, "%i", &device);
+
+	for (i = 0; i < sizeof hca_table / sizeof hca_table[0]; ++i)
+		if (vendor == hca_table[i].vendor &&
+			device == hca_table[i].device)
+			goto found;
+
+	return NULL;
+
+found:
+	dev = malloc(sizeof *dev);
+	if (!dev) {
+		fprintf(stderr, PFX "Fatal: couldn't allocate device for
libnes\n"); 
+		return (NULL);
+	}
+
+	dev->ibv_dev.ops = nes_udev_ops;
+	dev->hca_type = hca_table[i].type;
+	dev->page_size = sysconf(_SC_PAGESIZE);
+
+	return (&dev->ibv_dev);
+}
+
+
+#ifdef HAVE_SYSFS_LIBSYSFS_H
+/**
+ * openib_driver_init
+ * 
+ * @param sysdev
+ * 
+ * @return struct ibv_device*
+ */
+struct ibv_device *openib_driver_init(struct sysfs_class_device
*sysdev)
+{
+	int abi_ver = 0;
+	char value[8];
+
+	if (ibv_read_sysfs_file(sysdev->path, "abi_version", value,
sizeof(value)) > 0) {
+		abi_ver = strtol(value, NULL, 10);
+	}
+
+	return (ibv_driver_init(sysdev->path, abi_ver));
+}
+#endif /* HAVE_SYSFS_LIBSYSFS_H */
+



