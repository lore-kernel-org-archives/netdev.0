From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 12/12] rocker: introduce rocker switch driver
Date: Thu, 21 Aug 2014 18:19:05 +0200
Message-ID: <1408637945-10390-13-git-send-email-jiri@resnulli.us>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33402 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbaHUQTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:19:54 -0400
Received: by mail-wi0-f170.google.com with SMTP id f8so8331610wiw.3
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:19:52 -0700 (PDT)
In-Reply-To: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the first driver to benefit from the switchdev
infrastructure and to implement newly introduced switch ndos. This is a
driver for emulated switch chip implemented in qemu:
https://github.com/sfeldma/qemu-rocker/

This patch is a result of joint work with Scott Feldman.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    8 +
 drivers/net/Makefile |    2 +
 drivers/net/rocker.c | 3446 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/rocker.h |  465 +++++++
 5 files changed, 3927 insertions(+)
 create mode 100644 drivers/net/rocker.c
 create mode 100644 drivers/net/rocker.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 2f85f55..55b9fd2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7607,6 +7607,12 @@ F:	drivers/hid/hid-roccat*
 F:	include/linux/hid-roccat*
 F:	Documentation/ABI/*/sysfs-driver-hid-roccat*
 
+ROCKER DRIVER
+M:	Jiri Pirko <jiri@resnulli.us>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/rocker.*
+
 ROCKETPORT DRIVER
 P:	Comtrol Corp.
 W:	http://www.comtrol.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7822c74..64914a8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -366,4 +366,12 @@ config VMXNET3
 
 source "drivers/net/hyperv/Kconfig"
 
+config ROCKER
+	tristate "Rocker switch driver"
+	depends on PCI && INET && NET_SWITCHDEV
+	help
+	  This driver supports Rocker switch device.
+	  To compile this driver as a module, choose M here: the
+	  module will be called rocker.
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3c835ba..8fe0ea1 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -66,3 +66,5 @@ obj-$(CONFIG_USB_NET_DRIVERS) += usb/
 
 obj-$(CONFIG_HYPERV_NET) += hyperv/
 obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
+
+obj-$(CONFIG_ROCKER) += rocker.o
diff --git a/drivers/net/rocker.c b/drivers/net/rocker.c
new file mode 100644
index 0000000..7426db5
--- /dev/null
+++ b/drivers/net/rocker.c
@@ -0,0 +1,3446 @@
+/*
+ * drivers/net/rocker.c - Rocker switch device driver
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@cumulusnetworks.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <linux/spinlock.h>
+#include <linux/hashtable.h>
+#include <linux/crc32.h>
+#include <linux/sort.h>
+#include <linux/random.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/sw_flow.h>
+#include <net/rtnetlink.h>
+#include <asm-generic/io-64-nonatomic-lo-hi.h>
+#include <generated/utsrelease.h>
+
+#include "rocker.h"
+
+static const char rocker_driver_name[] = "rocker";
+
+static const struct pci_device_id rocker_pci_id_table[] = {
+	{PCI_VDEVICE(REDHAT, PCI_DEVICE_ID_REDHAT_ROCKER), 0},
+	{0, }
+};
+
+enum rocker_op {
+	ROCKER_OP_ADD,
+	ROCKER_OP_DEL,
+};
+
+struct rocker_flow_tbl_key {
+	u32 priority;
+	enum rocker_of_dpa_table_id tbl_id;
+	union {
+		struct {
+			u32 in_lport;
+			u32 in_lport_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+		} ig_port;
+		struct {
+			u32 in_lport;
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			enum rocker_of_dpa_table_id goto_tbl;
+			bool untagged;
+			__be16 new_vlan_id;
+		} vlan;
+		struct {
+			/* TODO */
+		} term_mac;
+		struct {
+			u8 eth_dst[ETH_ALEN];
+			u8 eth_dst_mask[ETH_ALEN];
+			int has_eth_dst;
+			int has_eth_dst_mask;
+			__be16 vlan_id;
+			u32 tunnel_id;
+			enum rocker_of_dpa_table_id goto_tbl;
+			u32 group_id;
+		} bridge;
+		struct {
+			u32 in_lport;
+			u32 in_lport_mask;
+			u8 eth_src[ETH_ALEN];
+			u8 eth_src_mask[ETH_ALEN];
+			u8 eth_dst[ETH_ALEN];
+			u8 eth_dst_mask[ETH_ALEN];
+			__be16 eth_type;
+			__be16 vlan_id;
+			__be16 vlan_id_mask;
+			u32 group_id;
+		} acl;
+	};
+};
+
+struct rocker_flow_tbl_entry {
+	struct hlist_node entry;
+	u32 ref_count;
+	u64 cookie;
+	struct rocker_flow_tbl_key key;
+	u32 key_crc32;
+};
+
+struct rocker_group_tbl_entry {
+	struct hlist_node entry;
+	u32 ref_count;
+	u32 group_id;
+	u16 group_count;
+	u32 *group_ids;
+	union {
+		struct {
+			u8 pop_vlan;
+		} l2_interface;
+	};
+};
+
+struct rocker_desc_info {
+	char *data; /* mapped */
+	size_t data_size;
+	size_t tlv_size;
+	struct rocker_desc *desc;
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+};
+
+struct rocker_dma_ring_info {
+	size_t size;
+	u32 head;
+	u32 tail;
+	struct rocker_desc *desc; /* mapped */
+	dma_addr_t mapaddr;
+	struct rocker_desc_info *desc_info;
+	unsigned int type;
+};
+
+struct rocker;
+
+struct rocker_port {
+	struct net_device *dev;
+	unsigned int prev_flags;
+	struct rocker *rocker;
+	unsigned port_number;
+	struct napi_struct napi_tx;
+	struct napi_struct napi_rx;
+	struct rocker_dma_ring_info tx_ring;
+	struct rocker_dma_ring_info rx_ring;
+};
+
+struct rocker {
+	struct pci_dev *pdev;
+	u8 __iomem *hw_addr;
+	struct msix_entry *msix_entries;
+	unsigned port_count;
+	struct rocker_port **ports;
+	struct {
+		u64 id;
+	} hw;
+	spinlock_t cmd_ring_lock;
+	struct rocker_dma_ring_info cmd_ring;
+	struct rocker_dma_ring_info event_ring;
+	DECLARE_HASHTABLE(flow_tbl, 16);
+	spinlock_t flow_tbl_lock;
+	u64 flow_tbl_next_cookie;
+	DECLARE_HASHTABLE(group_tbl, 16);
+	spinlock_t group_tbl_lock;
+	u16 group_index_next;
+};
+
+struct rocker_wait {
+	wait_queue_head_t wait;
+	bool done;
+};
+
+static const u8 zero_mac[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+static const u8 ff_mac[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+static const u8 lldp_mac[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x0e };
+
+/* Rocker priority levels for flow table entries.  Higher
+ * priority match takes precedence over lower priority match.
+ */
+
+enum {
+	ROCKER_PRIORITY_UNKNOWN = 0,
+	ROCKER_PRIORITY_IG_PORT = 1,
+	ROCKER_PRIORITY_VLAN = 1,
+	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT = 1,
+	ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD = 2,
+	ROCKER_PRIORITY_BRIDGING_VLAN = 3,
+	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT = 1,
+	ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD = 2,
+	ROCKER_PRIORITY_BRIDGING_TENANT = 3,
+	ROCKER_PRIORITY_ACL_PORT_PROMISC = 1,
+	ROCKER_PRIORITY_ACL = 2,
+};
+
+static u32 rocker_port_to_lport(struct rocker_port *rocker_port)
+{
+	return rocker_port->port_number + 1;
+}
+
+static void rocker_wait_reset(struct rocker_wait *wait)
+{
+	wait->done = false;
+}
+
+static void rocker_wait_init(struct rocker_wait *wait)
+{
+	init_waitqueue_head(&wait->wait);
+	rocker_wait_reset(wait);
+}
+
+static bool rocker_wait_event_timeout(struct rocker_wait *wait,
+				      unsigned long timeout)
+{
+	wait_event_timeout(wait->wait, wait->done, HZ / 10);
+	if (!wait->done)
+		return false;
+	return true;
+}
+
+static void rocker_wait_wake_up(struct rocker_wait *wait)
+{
+	wait->done = true;
+	wake_up(&wait->wait);
+}
+
+static u32 rocker_msix_vector(struct rocker *rocker, unsigned vector)
+{
+	return rocker->msix_entries[vector].vector;
+}
+
+static u32 rocker_msix_tx_vector(struct rocker_port *rocker_port)
+{
+	return rocker_msix_vector(rocker_port->rocker,
+				  ROCKER_MSIX_VEC_TX(rocker_port->port_number));
+}
+
+static u32 rocker_msix_rx_vector(struct rocker_port *rocker_port)
+{
+	return rocker_msix_vector(rocker_port->rocker,
+				  ROCKER_MSIX_VEC_RX(rocker_port->port_number));
+}
+
+#define rocker_write32(rocker, reg, val)	\
+	writel((val), (rocker)->hw_addr + (ROCKER_ ## reg))
+#define rocker_read32(rocker, reg)	\
+	readl((rocker)->hw_addr + (ROCKER_ ## reg))
+#define rocker_write64(rocker, reg, val)	\
+	writeq((val), (rocker)->hw_addr + (ROCKER_ ## reg))
+#define rocker_read64(rocker, reg)	\
+	readq((rocker)->hw_addr + (ROCKER_ ## reg))
+
+/*****************************
+ * HW basic testing functions
+ *****************************/
+
+static int rocker_reg_test(struct rocker *rocker)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	u64 test_reg;
+	u64 rnd;
+
+	rnd = prandom_u32();
+	rnd >>= 1;
+	rocker_write32(rocker, TEST_REG, rnd);
+	test_reg = rocker_read32(rocker, TEST_REG);
+	if (test_reg != rnd * 2) {
+		dev_err(&pdev->dev, "unexpected 32bit register value %08llx, expected %08llx\n",
+			test_reg, rnd * 2);
+		return -EIO;
+	}
+
+	rnd = prandom_u32();
+	rnd <<= 31;
+	rnd |= prandom_u32();
+	rocker_write64(rocker, TEST_REG64, rnd);
+	test_reg = rocker_read64(rocker, TEST_REG64);
+	if (test_reg != rnd * 2) {
+		dev_err(&pdev->dev, "unexpected 64bit register value %16llx, expected %16llx\n",
+			test_reg, rnd * 2);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int rocker_dma_test_one(struct rocker *rocker, struct rocker_wait *wait,
+			       u32 test_type, dma_addr_t dma_handle,
+			       unsigned char *buf, unsigned char *expect,
+			       size_t size)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int i;
+
+	rocker_wait_reset(wait);
+	rocker_write32(rocker, TEST_DMA_CTRL, test_type);
+
+	if (!rocker_wait_event_timeout(wait, HZ / 10)) {
+		dev_err(&pdev->dev, "no interrupt received within a timeout\n");
+		return -EIO;
+	}
+
+	for (i = 0; i < size; i++) {
+		if (buf[i] != expect[i]) {
+			dev_err(&pdev->dev, "unexpected memory content %02x at byte %x\n, %02x expected",
+				buf[i], i, expect[i]);
+			return -EIO;
+		}
+	}
+	return 0;
+}
+
+#define ROCKER_TEST_DMA_BUF_SIZE (PAGE_SIZE * 4)
+#define ROCKER_TEST_DMA_FILL_PATTERN 0x96
+
+static int rocker_dma_test_offset(struct rocker *rocker,
+				  struct rocker_wait *wait, int offset)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	unsigned char *alloc;
+	unsigned char *buf;
+	unsigned char *expect;
+	dma_addr_t dma_handle;
+	int i;
+	int err;
+
+	alloc = kzalloc(ROCKER_TEST_DMA_BUF_SIZE * 2 + offset,
+			GFP_KERNEL | GFP_DMA);
+	if (!alloc)
+		return -ENOMEM;
+	buf = alloc + offset;
+	expect = buf + ROCKER_TEST_DMA_BUF_SIZE;
+
+	dma_handle = pci_map_single(pdev, buf, ROCKER_TEST_DMA_BUF_SIZE,
+				    PCI_DMA_BIDIRECTIONAL);
+	if (pci_dma_mapping_error(pdev, dma_handle)) {
+		err = -EIO;
+		goto free_alloc;
+	}
+
+	rocker_write64(rocker, TEST_DMA_ADDR, dma_handle);
+	rocker_write32(rocker, TEST_DMA_SIZE, ROCKER_TEST_DMA_BUF_SIZE);
+
+	memset(expect, ROCKER_TEST_DMA_FILL_PATTERN, ROCKER_TEST_DMA_BUF_SIZE);
+	err = rocker_dma_test_one(rocker, wait, ROCKER_TEST_DMA_CTRL_FILL,
+				  dma_handle, buf, expect,
+				  ROCKER_TEST_DMA_BUF_SIZE);
+	if (err)
+		goto unmap;
+
+	memset(expect, 0, ROCKER_TEST_DMA_BUF_SIZE);
+	err = rocker_dma_test_one(rocker, wait, ROCKER_TEST_DMA_CTRL_CLEAR,
+				  dma_handle, buf, expect,
+				  ROCKER_TEST_DMA_BUF_SIZE);
+	if (err)
+		goto unmap;
+
+	prandom_bytes(buf, ROCKER_TEST_DMA_BUF_SIZE);
+	for (i = 0; i < ROCKER_TEST_DMA_BUF_SIZE; i++)
+		expect[i] = ~buf[i];
+	err = rocker_dma_test_one(rocker, wait, ROCKER_TEST_DMA_CTRL_INVERT,
+				  dma_handle, buf, expect,
+				  ROCKER_TEST_DMA_BUF_SIZE);
+	if (err)
+		goto unmap;
+
+unmap:
+	pci_unmap_single(pdev, dma_handle, ROCKER_TEST_DMA_BUF_SIZE,
+			 PCI_DMA_BIDIRECTIONAL);
+free_alloc:
+	kfree(alloc);
+
+	return err;
+}
+
+static int rocker_dma_test(struct rocker *rocker, struct rocker_wait *wait)
+{
+	int i;
+	int err;
+
+	for (i = 0; i < 8; i++) {
+		err = rocker_dma_test_offset(rocker, wait, i);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static irqreturn_t rocker_test_irq_handler(int irq, void *dev_id)
+{
+	struct rocker_wait *wait = dev_id;
+
+	rocker_wait_wake_up(wait);
+
+	return IRQ_HANDLED;
+}
+
+static int rocker_basic_hw_test(struct rocker *rocker)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	struct rocker_wait wait;
+	int err;
+
+	err = rocker_reg_test(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "reg test failed\n");
+		return err;
+	}
+
+	err = request_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_TEST),
+			  rocker_test_irq_handler, 0,
+			  rocker_driver_name, &wait);
+	if (err) {
+		dev_err(&pdev->dev, "cannot assign test irq\n");
+		return err;
+	}
+
+	rocker_wait_init(&wait);
+	rocker_write32(rocker, TEST_IRQ, ROCKER_MSIX_VEC_TEST);
+
+	if (!rocker_wait_event_timeout(&wait, HZ / 10)) {
+		dev_err(&pdev->dev, "no interrupt received within a timeout\n");
+		err = -EIO;
+		goto free_irq;
+	}
+
+	err = rocker_dma_test(rocker, &wait);
+	if (err)
+		dev_err(&pdev->dev, "dma test failed\n");
+
+free_irq:
+	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_TEST), &wait);
+	return err;
+}
+
+/******
+ * TLV
+ ******/
+
+#define ROCKER_TLV_ALIGNTO 8U
+#define ROCKER_TLV_ALIGN(len) \
+	(((len) + ROCKER_TLV_ALIGNTO - 1) & ~(ROCKER_TLV_ALIGNTO - 1))
+#define ROCKER_TLV_HDRLEN ROCKER_TLV_ALIGN(sizeof(struct rocker_tlv))
+
+/*  <------- ROCKER_TLV_HDRLEN -------> <--- ROCKER_TLV_ALIGN(payload) --->
+ * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
+ * |             Header          | Pad |           Payload           | Pad |
+ * |      (struct rocker_tlv)    | ing |                             | ing |
+ * +-----------------------------+- - -+- - - - - - - - - - - - - - -+- - -+
+ *  <--------------------------- tlv->len -------------------------->
+ */
+
+static struct rocker_tlv *rocker_tlv_next(const struct rocker_tlv *tlv,
+					  int *remaining)
+{
+	int totlen = ROCKER_TLV_ALIGN(tlv->len);
+
+	*remaining -= totlen;
+	return (struct rocker_tlv *) ((char *) tlv + totlen);
+}
+
+static int rocker_tlv_ok(const struct rocker_tlv *tlv, int remaining)
+{
+	return remaining >= (int) ROCKER_TLV_HDRLEN &&
+	       tlv->len >= ROCKER_TLV_HDRLEN &&
+	       tlv->len <= remaining;
+}
+
+#define rocker_tlv_for_each(pos, head, len, rem)	\
+	for (pos = head, rem = len;			\
+	     rocker_tlv_ok(pos, rem);			\
+	     pos = rocker_tlv_next(pos, &(rem)))
+
+#define rocker_tlv_for_each_nested(pos, tlv, rem)	\
+	rocker_tlv_for_each(pos, rocker_tlv_data(tlv),	\
+			    rocker_tlv_len(tlv), rem)
+
+static int rocker_tlv_attr_size(int payload)
+{
+	return ROCKER_TLV_HDRLEN + payload;
+}
+
+static int rocker_tlv_total_size(int payload)
+{
+	return ROCKER_TLV_ALIGN(rocker_tlv_attr_size(payload));
+}
+
+static int rocker_tlv_padlen(int payload)
+{
+	return rocker_tlv_total_size(payload) - rocker_tlv_attr_size(payload);
+}
+
+static int rocker_tlv_type(const struct rocker_tlv *tlv)
+{
+	return tlv->type;
+}
+
+static void *rocker_tlv_data(const struct rocker_tlv *tlv)
+{
+	return (char *) tlv + ROCKER_TLV_HDRLEN;
+}
+
+static int rocker_tlv_len(const struct rocker_tlv *tlv)
+{
+	return tlv->len - ROCKER_TLV_HDRLEN;
+}
+
+static u8 rocker_tlv_get_u8(const struct rocker_tlv *tlv)
+{
+	return *(u8 *) rocker_tlv_data(tlv);
+}
+
+static u16 rocker_tlv_get_u16(const struct rocker_tlv *tlv)
+{
+	return *(u16 *) rocker_tlv_data(tlv);
+}
+
+static u32 rocker_tlv_get_u32(const struct rocker_tlv *tlv)
+{
+	return *(u32 *) rocker_tlv_data(tlv);
+}
+
+static u64 rocker_tlv_get_u64(const struct rocker_tlv *tlv)
+{
+	return *(u64 *) rocker_tlv_data(tlv);
+}
+
+static void rocker_tlv_parse(struct rocker_tlv **tb, int maxtype,
+			     const char *buf, int buf_len)
+{
+	const struct rocker_tlv *tlv;
+	const struct rocker_tlv *head = (const struct rocker_tlv *) buf;
+	int rem;
+
+	memset(tb, 0, sizeof(struct rocker_tlv *) * (maxtype + 1));
+
+	rocker_tlv_for_each(tlv, head, buf_len, rem) {
+		u32 type = rocker_tlv_type(tlv);
+
+		if (type > 0 && type <= maxtype)
+			tb[type] = (struct rocker_tlv *) tlv;
+	}
+}
+
+static void rocker_tlv_parse_nested(struct rocker_tlv **tb, int maxtype,
+				    const struct rocker_tlv *tlv)
+{
+	rocker_tlv_parse(tb, maxtype, rocker_tlv_data(tlv),
+			 rocker_tlv_len(tlv));
+}
+
+static void rocker_tlv_parse_desc(struct rocker_tlv **tb, int maxtype,
+				  struct rocker_desc_info *desc_info)
+{
+	rocker_tlv_parse(tb, maxtype, desc_info->data,
+			 desc_info->desc->tlv_size);
+}
+
+static struct rocker_tlv *rocker_tlv_start(struct rocker_desc_info *desc_info)
+{
+	return (struct rocker_tlv *) ((char *) desc_info->data +
+					       desc_info->tlv_size);
+}
+
+static int rocker_tlv_put(struct rocker_desc_info *desc_info,
+			  int attrtype, int attrlen, const void *data)
+{
+	int tail_room = desc_info->data_size - desc_info->tlv_size;
+	int total_size = rocker_tlv_total_size(attrlen);
+	struct rocker_tlv *tlv;
+
+	if (unlikely(tail_room < total_size))
+		return -EMSGSIZE;
+
+	tlv = rocker_tlv_start(desc_info);
+	desc_info->tlv_size += total_size;
+	tlv->type = attrtype;
+	tlv->len = rocker_tlv_attr_size(attrlen);
+	memcpy(rocker_tlv_data(tlv), data, attrlen);
+	memset((char *) tlv + tlv->len, 0, rocker_tlv_padlen(attrlen));
+	return 0;
+}
+
+static int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
+			     int attrtype, u8 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
+}
+
+static int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
+			      int attrtype, u16 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
+}
+
+static int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
+			      int attrtype, u32 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
+}
+
+static int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
+			      int attrtype, u64 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
+}
+
+static struct rocker_tlv *
+rocker_tlv_nest_start(struct rocker_desc_info *desc_info, int attrtype)
+{
+	struct rocker_tlv *start = rocker_tlv_start(desc_info);
+
+	if (rocker_tlv_put(desc_info, attrtype, 0, NULL) < 0)
+		return NULL;
+
+	return start;
+}
+
+static void rocker_tlv_nest_end(struct rocker_desc_info *desc_info,
+				struct rocker_tlv *start)
+{
+	start->len = (char *) rocker_tlv_start(desc_info) - (char *) start;
+}
+
+static void rocker_tlv_nest_cancel(struct rocker_desc_info *desc_info,
+				   struct rocker_tlv *start)
+{
+	desc_info->tlv_size = (char *) start - desc_info->data;
+}
+
+/******************************************
+ * DMA rings and descriptors manipulations
+ ******************************************/
+
+static u32 __pos_inc(u32 pos, size_t limit)
+{
+	return ++pos == limit ? 0 : pos;
+}
+
+static int rocker_desc_err(struct rocker_desc_info *desc_info)
+{
+	return -(desc_info->desc->comp_err & ~ROCKER_DMA_DESC_COMP_ERR_GEN);
+}
+
+static void rocker_desc_gen_clear(struct rocker_desc_info *desc_info)
+{
+	desc_info->desc->comp_err &= ~ROCKER_DMA_DESC_COMP_ERR_GEN;
+}
+
+static bool rocker_desc_gen(struct rocker_desc_info *desc_info)
+{
+	u32 comp_err = desc_info->desc->comp_err;
+
+	return comp_err & ROCKER_DMA_DESC_COMP_ERR_GEN ? true : false;
+}
+
+static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
+{
+	return (void *) desc_info->desc->cookie;
+}
+
+static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
+				       void *ptr)
+{
+	desc_info->desc->cookie = (long) ptr;
+}
+
+static struct rocker_desc_info *
+rocker_desc_head_get(struct rocker_dma_ring_info *info)
+{
+	static struct rocker_desc_info *desc_info;
+	u32 head = __pos_inc(info->head, info->size);
+
+	desc_info = &info->desc_info[info->head];
+	if (head == info->tail)
+		return NULL; /* ring full */
+	desc_info->tlv_size = 0;
+	return desc_info;
+}
+
+static void rocker_desc_commit(struct rocker_desc_info *desc_info)
+{
+	desc_info->desc->buf_size = desc_info->data_size;
+	desc_info->desc->tlv_size = desc_info->tlv_size;
+}
+
+static void rocker_desc_head_set(struct rocker *rocker,
+				 struct rocker_dma_ring_info *info,
+				 struct rocker_desc_info *desc_info)
+{
+	u32 head = __pos_inc(info->head, info->size);
+
+	BUG_ON(head == info->tail);
+	rocker_desc_commit(desc_info);
+	info->head = head;
+	rocker_write32(rocker, DMA_DESC_HEAD(info->type), head);
+}
+
+static struct rocker_desc_info *
+rocker_desc_tail_get(struct rocker_dma_ring_info *info)
+{
+	static struct rocker_desc_info *desc_info;
+
+	if (info->tail == info->head)
+		return NULL; /* no thing to be done between head and tail */
+	desc_info = &info->desc_info[info->tail];
+	if (!rocker_desc_gen(desc_info))
+		return NULL; /* gen bit not set, desc is not ready yet */
+	info->tail = __pos_inc(info->tail, info->size);
+	desc_info->tlv_size = desc_info->desc->tlv_size;
+	return desc_info;
+}
+
+static void rocker_dma_ring_credits_set(struct rocker *rocker,
+					struct rocker_dma_ring_info *info,
+					u32 credits)
+{
+	if (credits)
+		rocker_write32(rocker, DMA_DESC_CREDITS(info->type), credits);
+}
+
+static unsigned long rocker_dma_ring_size_fix(size_t size)
+{
+	return max(ROCKER_DMA_SIZE_MIN,
+		   min(roundup_pow_of_two(size), ROCKER_DMA_SIZE_MAX));
+}
+
+static int rocker_dma_ring_create(struct rocker *rocker,
+				  unsigned int type,
+				  size_t size,
+				  struct rocker_dma_ring_info *info)
+{
+	int i;
+
+	BUG_ON(size != rocker_dma_ring_size_fix(size));
+	info->size = size;
+	info->type = type;
+	info->head = 0;
+	info->tail = 0;
+	info->desc_info = kcalloc(info->size, sizeof(*info->desc_info),
+				  GFP_KERNEL);
+	if (!info->desc_info)
+		return -ENOMEM;
+
+	info->desc = pci_alloc_consistent(rocker->pdev,
+					  info->size * sizeof(*info->desc),
+					  &info->mapaddr);
+	if (!info->desc) {
+		kfree(info->desc_info);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < info->size; i++)
+		info->desc_info[i].desc = &info->desc[i];
+
+	rocker_write32(rocker, DMA_DESC_CTRL(info->type),
+		       ROCKER_DMA_DESC_CTRL_RESET);
+	rocker_write64(rocker, DMA_DESC_ADDR(info->type), info->mapaddr);
+	rocker_write32(rocker, DMA_DESC_SIZE(info->type), info->size);
+
+	return 0;
+}
+
+static void rocker_dma_ring_destroy(struct rocker *rocker,
+				    struct rocker_dma_ring_info *info)
+{
+	rocker_write64(rocker, DMA_DESC_ADDR(info->type), 0);
+
+	pci_free_consistent(rocker->pdev,
+			    info->size * sizeof(struct rocker_desc),
+			    info->desc, info->mapaddr);
+	kfree(info->desc_info);
+}
+
+static void rocker_dma_ring_pass_to_producer(struct rocker *rocker,
+					     struct rocker_dma_ring_info *info)
+{
+	int i;
+
+	BUG_ON(info->head || info->tail);
+
+	/* When ring is consumer, we need to advance head for each desc.
+	 * That tells hw that the desc is ready to be used by it.
+	 */
+	for (i = 0; i < info->size - 1; i++)
+		rocker_desc_head_set(rocker, info, &info->desc_info[i]);
+	rocker_desc_commit(&info->desc_info[i]);
+}
+
+static int rocker_dma_ring_bufs_alloc(struct rocker *rocker,
+				      struct rocker_dma_ring_info *info,
+				      int direction, size_t buf_size)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int i;
+	int err;
+
+	for (i = 0; i < info->size; i++) {
+		struct rocker_desc_info *desc_info = &info->desc_info[i];
+		struct rocker_desc *desc = &info->desc[i];
+		dma_addr_t dma_handle;
+		char *buf;
+
+		buf = kzalloc(buf_size, GFP_KERNEL | GFP_DMA);
+		if (!buf) {
+			err = -ENOMEM;
+			goto rollback;
+		}
+
+		dma_handle = pci_map_single(pdev, buf, buf_size, direction);
+		if (pci_dma_mapping_error(pdev, dma_handle)) {
+			kfree(buf);
+			err = -EIO;
+			goto rollback;
+		}
+
+		desc_info->data = buf;
+		desc_info->data_size = buf_size;
+		dma_unmap_addr_set(desc_info, mapaddr, dma_handle);
+
+		desc->buf_addr = dma_handle;
+		desc->buf_size = buf_size;
+	}
+	return 0;
+
+rollback:
+	for (i--; i >= 0; i--) {
+		struct rocker_desc_info *desc_info = &info->desc_info[i];
+
+		pci_unmap_single(pdev, dma_unmap_addr(desc_info, mapaddr),
+				 desc_info->data_size, direction);
+		kfree(desc_info->data);
+	}
+	return err;
+}
+
+static void rocker_dma_ring_bufs_free(struct rocker *rocker,
+				      struct rocker_dma_ring_info *info,
+				      int direction)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int i;
+
+	for (i = 0; i < info->size; i++) {
+		struct rocker_desc_info *desc_info = &info->desc_info[i];
+		struct rocker_desc *desc = &info->desc[i];
+
+		desc->buf_addr = 0;
+		desc->buf_size = 0;
+		pci_unmap_single(pdev, dma_unmap_addr(desc_info, mapaddr),
+				 desc_info->data_size, direction);
+		kfree(desc_info->data);
+	}
+}
+
+static int rocker_dma_rings_init(struct rocker *rocker)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int err;
+
+	err = rocker_dma_ring_create(rocker, ROCKER_DMA_CMD,
+				     ROCKER_DMA_CMD_DEFAULT_SIZE,
+				     &rocker->cmd_ring);
+	if (err) {
+		dev_err(&pdev->dev, "failed to create command dma ring\n");
+		return err;
+	}
+
+	spin_lock_init(&rocker->cmd_ring_lock);
+
+	err = rocker_dma_ring_bufs_alloc(rocker, &rocker->cmd_ring,
+					 PCI_DMA_BIDIRECTIONAL, PAGE_SIZE);
+	if (err) {
+		dev_err(&pdev->dev, "failed to alloc command dma ring buffers\n");
+		goto err_dma_cmd_ring_bufs_alloc;
+	}
+
+	err = rocker_dma_ring_create(rocker, ROCKER_DMA_EVENT,
+				     ROCKER_DMA_EVENT_DEFAULT_SIZE,
+				     &rocker->event_ring);
+	if (err) {
+		dev_err(&pdev->dev, "failed to create event dma ring\n");
+		goto err_dma_event_ring_create;
+	}
+
+	err = rocker_dma_ring_bufs_alloc(rocker, &rocker->event_ring,
+					 PCI_DMA_FROMDEVICE, PAGE_SIZE);
+	if (err) {
+		dev_err(&pdev->dev, "failed to alloc event dma ring buffers\n");
+		goto err_dma_event_ring_bufs_alloc;
+	}
+	rocker_dma_ring_pass_to_producer(rocker, &rocker->event_ring);
+	return 0;
+
+err_dma_event_ring_bufs_alloc:
+	rocker_dma_ring_destroy(rocker, &rocker->event_ring);
+err_dma_event_ring_create:
+	rocker_dma_ring_bufs_free(rocker, &rocker->cmd_ring,
+				  PCI_DMA_BIDIRECTIONAL);
+err_dma_cmd_ring_bufs_alloc:
+	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
+	return err;
+}
+
+static void rocker_dma_rings_fini(struct rocker *rocker)
+{
+	rocker_dma_ring_bufs_free(rocker, &rocker->event_ring,
+				  PCI_DMA_BIDIRECTIONAL);
+	rocker_dma_ring_destroy(rocker, &rocker->event_ring);
+	rocker_dma_ring_bufs_free(rocker, &rocker->cmd_ring,
+				  PCI_DMA_BIDIRECTIONAL);
+	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
+}
+
+static int rocker_dma_rx_ring_skb_map(struct rocker *rocker,
+				      struct rocker_port *rocker_port,
+				      struct rocker_desc_info *desc_info,
+				      struct sk_buff *skb, size_t buf_len)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	dma_addr_t dma_handle;
+
+	dma_handle = pci_map_single(pdev, skb->data, buf_len,
+				    PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(pdev, dma_handle))
+		return -EIO;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_RX_FRAG_ADDR, dma_handle))
+		goto tlv_put_failure;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_RX_FRAG_MAX_LEN, buf_len))
+		goto tlv_put_failure;
+	return 0;
+
+tlv_put_failure:
+	pci_unmap_single(pdev, dma_handle, buf_len, PCI_DMA_FROMDEVICE);
+	desc_info->tlv_size = 0;
+	return -EMSGSIZE;
+}
+
+static size_t rocker_port_rx_buf_len(struct rocker_port *rocker_port)
+{
+	return rocker_port->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+}
+
+static int rocker_dma_rx_ring_skb_alloc(struct rocker *rocker,
+					struct rocker_port *rocker_port,
+					struct rocker_desc_info *desc_info)
+{
+	struct net_device *dev = rocker_port->dev;
+	struct sk_buff *skb;
+	size_t buf_len = rocker_port_rx_buf_len(rocker_port);
+	int err;
+
+	/* Ensure that hw will see tlv_size zero in case of an error.
+	 * That tells hw to use another descriptor.
+	 */
+	rocker_desc_cookie_ptr_set(desc_info, NULL);
+	desc_info->tlv_size = 0;
+
+	skb = netdev_alloc_skb_ip_align(dev, buf_len);
+	if (!skb)
+		return -ENOMEM;
+	err = rocker_dma_rx_ring_skb_map(rocker, rocker_port, desc_info,
+					 skb, buf_len);
+	if (err) {
+		dev_kfree_skb_any(skb);
+		return err;
+	}
+	rocker_desc_cookie_ptr_set(desc_info, skb);
+	return 0;
+}
+
+static void rocker_dma_rx_ring_skb_unmap(struct rocker *rocker,
+					 struct rocker_tlv **attrs)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	dma_addr_t dma_handle;
+	size_t len;
+
+	if (!attrs[ROCKER_TLV_RX_FRAG_ADDR] ||
+	    !attrs[ROCKER_TLV_RX_FRAG_MAX_LEN])
+		return;
+	dma_handle = rocker_tlv_get_u64(attrs[ROCKER_TLV_RX_FRAG_ADDR]);
+	len = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FRAG_MAX_LEN]);
+	pci_unmap_single(pdev, dma_handle, len, PCI_DMA_FROMDEVICE);
+}
+
+static void rocker_dma_rx_ring_skb_free(struct rocker *rocker,
+					struct rocker_desc_info *desc_info)
+{
+	struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
+	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
+
+	if (!skb)
+		return;
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_RX_MAX, desc_info);
+	rocker_dma_rx_ring_skb_unmap(rocker, attrs);
+	dev_kfree_skb_any(skb);
+}
+
+static int rocker_dma_rx_ring_skbs_alloc(struct rocker *rocker,
+					 struct rocker_port *rocker_port)
+{
+	struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	int i;
+	int err;
+
+	for (i = 0; i < rx_ring->size; i++) {
+		err = rocker_dma_rx_ring_skb_alloc(rocker, rocker_port,
+						   &rx_ring->desc_info[i]);
+		if (err)
+			goto rollback;
+	}
+	return 0;
+
+rollback:
+	for (i--; i >= 0; i--)
+		rocker_dma_rx_ring_skb_free(rocker, &rx_ring->desc_info[i]);
+	return err;
+}
+
+static void rocker_dma_rx_ring_skbs_free(struct rocker *rocker,
+					 struct rocker_port *rocker_port)
+{
+	struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	int i;
+
+	for (i = 0; i < rx_ring->size; i++)
+		rocker_dma_rx_ring_skb_free(rocker, &rx_ring->desc_info[i]);
+}
+
+static int rocker_port_dma_rings_init(struct rocker_port *rocker_port)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	int err;
+
+	err = rocker_dma_ring_create(rocker,
+				     ROCKER_DMA_TX(rocker_port->port_number),
+				     ROCKER_DMA_TX_DEFAULT_SIZE,
+				     &rocker_port->tx_ring);
+	if (err) {
+		netdev_err(rocker_port->dev, "failed to create tx dma ring\n");
+		return err;
+	}
+
+	err = rocker_dma_ring_bufs_alloc(rocker, &rocker_port->tx_ring,
+					 PCI_DMA_TODEVICE,
+					 ROCKER_DMA_TX_DESC_SIZE);
+	if (err) {
+		netdev_err(rocker_port->dev, "failed to alloc tx dma ring buffers\n");
+		goto err_dma_tx_ring_bufs_alloc;
+	}
+
+	err = rocker_dma_ring_create(rocker,
+				     ROCKER_DMA_RX(rocker_port->port_number),
+				     ROCKER_DMA_RX_DEFAULT_SIZE,
+				     &rocker_port->rx_ring);
+	if (err) {
+		netdev_err(rocker_port->dev, "failed to create rx dma ring\n");
+		goto err_dma_rx_ring_create;
+	}
+
+	err = rocker_dma_ring_bufs_alloc(rocker, &rocker_port->rx_ring,
+					 PCI_DMA_BIDIRECTIONAL,
+					 ROCKER_DMA_RX_DESC_SIZE);
+	if (err) {
+		netdev_err(rocker_port->dev, "failed to alloc rx dma ring buffers\n");
+		goto err_dma_rx_ring_bufs_alloc;
+	}
+
+	err = rocker_dma_rx_ring_skbs_alloc(rocker, rocker_port);
+	if (err) {
+		netdev_err(rocker_port->dev, "failed to alloc rx dma ring skbs\n");
+		goto err_dma_rx_ring_skbs_alloc;
+	}
+	rocker_dma_ring_pass_to_producer(rocker, &rocker_port->rx_ring);
+
+	return 0;
+
+err_dma_rx_ring_skbs_alloc:
+	rocker_dma_ring_bufs_free(rocker, &rocker_port->rx_ring,
+				  PCI_DMA_BIDIRECTIONAL);
+err_dma_rx_ring_bufs_alloc:
+	rocker_dma_ring_destroy(rocker, &rocker_port->rx_ring);
+err_dma_rx_ring_create:
+	rocker_dma_ring_bufs_free(rocker, &rocker_port->tx_ring,
+				  PCI_DMA_TODEVICE);
+err_dma_tx_ring_bufs_alloc:
+	rocker_dma_ring_destroy(rocker, &rocker_port->tx_ring);
+	return err;
+}
+
+static void rocker_port_dma_rings_fini(struct rocker_port *rocker_port)
+{
+	struct rocker *rocker = rocker_port->rocker;
+
+	rocker_dma_rx_ring_skbs_free(rocker, rocker_port);
+	rocker_dma_ring_bufs_free(rocker, &rocker_port->rx_ring,
+				  PCI_DMA_BIDIRECTIONAL);
+	rocker_dma_ring_destroy(rocker, &rocker_port->rx_ring);
+	rocker_dma_ring_bufs_free(rocker, &rocker_port->tx_ring,
+				  PCI_DMA_TODEVICE);
+	rocker_dma_ring_destroy(rocker, &rocker_port->tx_ring);
+}
+
+static void rocker_port_set_enable(struct rocker_port *rocker_port, bool enable)
+{
+	u64 val = rocker_read64(rocker_port->rocker, PORT_PHYS_ENABLE);
+
+	if (enable)
+		val |= 1 << rocker_port_to_lport(rocker_port);
+	else
+		val &= ~(1 << rocker_port_to_lport(rocker_port));
+	rocker_write64(rocker_port->rocker, PORT_PHYS_ENABLE, val);
+}
+
+/********************************
+ * Interrupt handler and helpers
+ ********************************/
+
+static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
+{
+	struct rocker *rocker = dev_id;
+	struct rocker_desc_info *desc_info;
+	struct rocker_wait *wait;
+	u32 credits = 0;
+
+	spin_lock(&rocker->cmd_ring_lock);
+	while ((desc_info = rocker_desc_tail_get(&rocker->cmd_ring))) {
+		wait = rocker_desc_cookie_ptr_get(desc_info);
+		rocker_wait_wake_up(wait);
+		credits++;
+	}
+	spin_unlock(&rocker->cmd_ring_lock);
+	rocker_dma_ring_credits_set(rocker, &rocker->cmd_ring, credits);
+
+	return IRQ_HANDLED;
+}
+
+static void rocker_port_link_up(struct rocker_port *rocker_port)
+{
+	netif_carrier_on(rocker_port->dev);
+	netdev_info(rocker_port->dev, "Link is up\n");
+}
+
+static void rocker_port_link_down(struct rocker_port *rocker_port)
+{
+	netif_carrier_off(rocker_port->dev);
+	netdev_info(rocker_port->dev, "Link is down\n");
+}
+
+static int rocker_event_process(struct rocker *rocker,
+				struct rocker_desc_info *desc_info)
+{
+	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAX + 1];
+	struct rocker_tlv *info_attrs[ROCKER_TLV_EVENT_LINK_CHANGED_MAX + 1];
+	u16 type;
+	unsigned port_number;
+	bool link_up;
+	struct rocker_port *rocker_port;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_EVENT_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_EVENT_TYPE] ||
+	    !attrs[ROCKER_TLV_EVENT_INFO])
+		return -EIO;
+
+	type = rocker_tlv_get_u16(attrs[ROCKER_TLV_EVENT_TYPE]);
+	if (!type)
+		return -EOPNOTSUPP;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_EVENT_LINK_CHANGED_MAX,
+				attrs[ROCKER_TLV_EVENT_INFO]);
+	if (!info_attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LPORT] ||
+	    !info_attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP])
+		return -EIO;
+	port_number = rocker_tlv_get_u32(info_attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LPORT]) - 1;
+	link_up = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);
+
+	if (port_number >= rocker->port_count)
+		return -EINVAL;
+
+	rocker_port = rocker->ports[port_number];
+	if (netif_carrier_ok(rocker_port->dev) != link_up) {
+		if (link_up)
+			rocker_port_link_up(rocker_port);
+		else
+			rocker_port_link_down(rocker_port);
+	}
+	return 0;
+}
+
+static irqreturn_t rocker_event_irq_handler(int irq, void *dev_id)
+{
+	struct rocker *rocker = dev_id;
+	struct pci_dev *pdev = rocker->pdev;
+	struct rocker_desc_info *desc_info;
+	u32 credits = 0;
+	int err;
+
+	while ((desc_info = rocker_desc_tail_get(&rocker->event_ring))) {
+		err = rocker_desc_err(desc_info);
+		if (err) {
+			dev_err(&pdev->dev, "event desc received with err %d\n",
+				err);
+		} else {
+			err = rocker_event_process(rocker, desc_info);
+			if (err)
+				dev_err(&pdev->dev, "event processing failed with err %d\n",
+					err);
+		}
+		rocker_desc_gen_clear(desc_info);
+		rocker_desc_head_set(rocker, &rocker->event_ring, desc_info);
+		credits++;
+	}
+	rocker_dma_ring_credits_set(rocker, &rocker->event_ring, credits);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t rocker_tx_irq_handler(int irq, void *dev_id)
+{
+	struct rocker_port *rocker_port = dev_id;
+
+	napi_schedule(&rocker_port->napi_tx);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t rocker_rx_irq_handler(int irq, void *dev_id)
+{
+	struct rocker_port *rocker_port = dev_id;
+
+	napi_schedule(&rocker_port->napi_rx);
+	return IRQ_HANDLED;
+}
+
+/********************
+ * Command interface
+ ********************/
+
+typedef int (*rocker_cmd_cb_t)(struct rocker *rocker,
+			       struct rocker_port *rocker_port,
+			       struct rocker_desc_info *desc_info,
+			       void *priv);
+
+static int rocker_cmd_exec(struct rocker *rocker,
+			   struct rocker_port *rocker_port,
+			   rocker_cmd_cb_t prepare, void *prepare_priv,
+			   rocker_cmd_cb_t process, void *process_priv)
+{
+	struct rocker_desc_info *desc_info;
+	struct rocker_wait wait;
+	unsigned long flags;
+	int err;
+
+	spin_lock_irqsave(&rocker->cmd_ring_lock, flags);
+	desc_info = rocker_desc_head_get(&rocker->cmd_ring);
+	if (!desc_info) {
+		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+		return -EAGAIN;
+	}
+	err = prepare(rocker, rocker_port, desc_info, prepare_priv);
+	if (err) {
+		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+		return err;
+	}
+	rocker_desc_cookie_ptr_set(desc_info, &wait);
+	rocker_wait_init(&wait);
+	rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
+	spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
+
+	if (!rocker_wait_event_timeout(&wait, HZ / 10))
+		return -EIO;
+
+	err = rocker_desc_err(desc_info);
+	if (err)
+		return err;
+
+	if (process)
+		err = process(rocker, rocker_port, desc_info, process_priv);
+
+	rocker_desc_gen_clear(desc_info);
+	return err;
+}
+
+static int
+rocker_cmd_get_port_settings_prep(struct rocker *rocker,
+				  struct rocker_port *rocker_port,
+				  struct rocker_desc_info *desc_info,
+				  void *priv)
+{
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_GET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
+			       rocker_port_to_lport(rocker_port)))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
+static int
+rocker_cmd_get_port_settings_ethtool_proc(struct rocker *rocker,
+					  struct rocker_port *rocker_port,
+					  struct rocker_desc_info *desc_info,
+					  void *priv)
+{
+	struct ethtool_cmd *ecmd = priv;
+	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	u32 speed;
+	u8 duplex;
+	u8 autoneg;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+	if (!info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_SPEED] ||
+	    !info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX] ||
+	    !info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG])
+		return -EIO;
+
+	speed = rocker_tlv_get_u32(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_SPEED]);
+	duplex = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX]);
+	autoneg = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG]);
+
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->supported = SUPPORTED_TP;
+	ecmd->phy_address = 0xff;
+	ecmd->port = PORT_TP;
+	ethtool_cmd_speed_set(ecmd, speed);
+	ecmd->duplex = duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	ecmd->autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static int
+rocker_cmd_get_port_settings_macaddr_proc(struct rocker *rocker,
+					  struct rocker_port *rocker_port,
+					  struct rocker_desc_info *desc_info,
+					  void *priv)
+{
+	unsigned char *macaddr = priv;
+	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	struct rocker_tlv *attr;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+	attr = info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR];
+	if (!attr)
+		return -EIO;
+
+	if (rocker_tlv_len(attr) != ETH_ALEN)
+		return -EINVAL;
+
+	ether_addr_copy(macaddr, rocker_tlv_data(attr));
+	return 0;
+}
+
+static int
+rocker_cmd_get_port_settings_mode_proc(struct rocker *rocker,
+				       struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info,
+				       void *priv)
+{
+	enum rocker_port_mode *mode = priv;
+	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+	if (!info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MODE])
+		return -EIO;
+
+	*mode = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MODE]);
+
+	return 0;
+}
+
+static int
+rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
+					  struct rocker_port *rocker_port,
+					  struct rocker_desc_info *desc_info,
+					  void *priv)
+{
+	struct ethtool_cmd *ecmd = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
+			       rocker_port_to_lport(rocker_port)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_SPEED,
+			       ethtool_cmd_speed(ecmd)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX,
+			      ecmd->duplex))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG,
+			      ecmd->autoneg))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
+static int
+rocker_cmd_set_port_settings_macaddr_prep(struct rocker *rocker,
+					  struct rocker_port *rocker_port,
+					  struct rocker_desc_info *desc_info,
+					  void *priv)
+{
+	unsigned char *macaddr = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
+			       rocker_port_to_lport(rocker_port)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,
+			   ETH_ALEN, macaddr))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
+static int
+rocker_cmd_set_port_settings_mode_prep(struct rocker *rocker,
+				       struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info,
+				       void *priv)
+{
+	enum rocker_port_mode *mode = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
+			       rocker_port_to_lport(rocker_port)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_MODE,
+			      *mode))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
+static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
+						struct ethtool_cmd *ecmd)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_get_port_settings_prep, NULL,
+			       rocker_cmd_get_port_settings_ethtool_proc,
+			       ecmd);
+}
+
+static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
+						unsigned char *macaddr)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_get_port_settings_prep, NULL,
+			       rocker_cmd_get_port_settings_macaddr_proc,
+			       macaddr);
+}
+
+static int rocker_cmd_get_port_settings_mode(struct rocker_port *rocker_port,
+					     enum rocker_port_mode *mode)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_get_port_settings_prep, NULL,
+			       rocker_cmd_get_port_settings_mode_proc,
+			       mode);
+}
+
+static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
+						struct ethtool_cmd *ecmd)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_set_port_settings_ethtool_prep,
+			       ecmd, NULL, NULL);
+}
+
+static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
+						unsigned char *macaddr)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_set_port_settings_macaddr_prep,
+			       macaddr, NULL, NULL);
+}
+
+static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
+					     enum rocker_port_mode mode)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_set_port_settings_mode_prep,
+			       &mode, NULL, NULL);
+}
+
+static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
+					   struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.ig_port.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
+			       entry->key.ig_port.in_lport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.ig_port.goto_tbl))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
+					struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.vlan.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.vlan.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+			       entry->key.vlan.vlan_id_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.vlan.goto_tbl))
+		return -EMSGSIZE;
+	if (entry->key.vlan.untagged &&
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
+			       entry->key.vlan.new_vlan_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
+					  struct rocker_flow_tbl_entry *entry)
+{
+	if (entry->key.bridge.has_eth_dst &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.bridge.eth_dst))
+		return -EMSGSIZE;
+	if (entry->key.bridge.has_eth_dst_mask &&
+	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.bridge.eth_dst_mask))
+		return -EMSGSIZE;
+	if (entry->key.bridge.vlan_id &&
+	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.bridge.vlan_id))
+		return -EMSGSIZE;
+	if (entry->key.bridge.tunnel_id &&
+	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_TUNNEL_ID,
+			       entry->key.bridge.tunnel_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
+			       entry->key.bridge.goto_tbl))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->key.bridge.group_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
+				       struct rocker_flow_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
+			       entry->key.acl.in_lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
+			       entry->key.acl.in_lport_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
+			   ETH_ALEN, entry->key.acl.eth_src))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC_MASK,
+			   ETH_ALEN, entry->key.acl.eth_src_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
+			   ETH_ALEN, entry->key.acl.eth_dst))
+		return -EMSGSIZE;
+	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
+			   ETH_ALEN, entry->key.acl.eth_dst_mask))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+			       entry->key.acl.eth_type))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+			       entry->key.acl.vlan_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+			       entry->key.acl.vlan_id_mask))
+		return -EMSGSIZE;
+	if (entry->key.acl.group_id != ROCKER_GROUP_NONE &&
+	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->key.acl.group_id))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_add(struct rocker *rocker,
+				   struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	struct rocker_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+	int err = 0;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_TABLE_ID,
+			       entry->key.tbl_id))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_PRIORITY,
+			       entry->key.priority))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_HARDTIME, 0))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
+			       entry->cookie))
+		return -EMSGSIZE;
+
+	switch (entry->key.tbl_id) {
+	case ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT:
+		err = rocker_cmd_flow_tbl_add_ig_port(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_VLAN:
+		err = rocker_cmd_flow_tbl_add_vlan(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
+		err = rocker_cmd_flow_tbl_add_bridge(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
+		err = rocker_cmd_flow_tbl_add_acl(desc_info, entry);
+		break;
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	if (err)
+		return err;
+
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int rocker_cmd_flow_tbl_del(struct rocker *rocker,
+				   struct rocker_port *rocker_port,
+				   struct rocker_desc_info *desc_info,
+				   void *priv)
+{
+	const struct rocker_flow_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_OF_DPA_COOKIE,
+			       entry->cookie))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int
+rocker_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
+				      struct rocker_group_tbl_entry *entry)
+{
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_LPORT,
+			       ROCKER_GROUP_PORT_GET(entry->group_id)))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_POP_VLAN,
+			      entry->l2_interface.pop_vlan))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int
+rocker_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
+				   struct rocker_group_tbl_entry *entry)
+{
+	int i;
+	struct rocker_tlv *group_ids;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GROUP_COUNT,
+			       entry->group_count))
+		return -EMSGSIZE;
+
+	group_ids = rocker_tlv_nest_start(desc_info,
+					  ROCKER_TLV_OF_DPA_GROUP_IDS);
+	if (!group_ids)
+		return -EMSGSIZE;
+
+	for (i = 0; i < entry->group_count; i++)
+		/* Note TLV array is 1-based */
+		if (rocker_tlv_put_u32(desc_info, i + 1, entry->group_ids[i]))
+			return -EMSGSIZE;
+
+	rocker_tlv_nest_end(desc_info, group_ids);
+
+	return 0;
+}
+
+static int rocker_cmd_group_tbl_add(struct rocker *rocker,
+				    struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv)
+{
+	struct rocker_group_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+	int err = 0;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->group_id))
+		return -EMSGSIZE;
+
+	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE:
+		err = rocker_cmd_group_tbl_add_l2_interface(desc_info, entry);
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		err = rocker_cmd_group_tbl_add_group_ids(desc_info, entry);
+		break;
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	if (err)
+		return err;
+
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+static int rocker_cmd_group_tbl_del(struct rocker *rocker,
+				    struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv)
+{
+	const struct rocker_group_tbl_entry *entry = priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID,
+			       entry->group_id))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+
+	return 0;
+}
+
+/************************
+ * Flow and group tables
+ ************************/
+
+static struct rocker_flow_tbl_entry *rocker_flow_tbl_find(
+	struct rocker *rocker, struct rocker_flow_tbl_entry *match)
+{
+	struct rocker_flow_tbl_entry *found;
+
+	hash_for_each_possible(rocker->flow_tbl, found, entry, match->key_crc32)
+		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+			return found;
+
+	return NULL;
+}
+
+static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
+			       struct rocker_flow_tbl_entry *match)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_flow_tbl_entry *found;
+	unsigned long flags;
+	bool add_to_hw = false;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+
+	netdev_info(rocker_port->dev, "flow tbl_add match->key_crc32 0x%08x\n",
+		    match->key_crc32);
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+
+	found = rocker_flow_tbl_find(rocker, match);
+	netdev_info(rocker_port->dev, "flow tbl_add found %p\n", found);
+
+	if (found) {
+		kfree(match);
+	} else {
+		found = match;
+		found->cookie = rocker->flow_tbl_next_cookie++;
+		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
+		add_to_hw = true;
+	}
+
+	found->ref_count++;
+
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	if (add_to_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_flow_tbl_add,
+				      found, NULL, NULL);
+		netdev_info(rocker_port->dev, "flow tbl_add err %d\n", err);
+		if (err) {
+			spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+			hash_del(&found->entry);
+			spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+			kfree(found);
+		}
+	}
+
+	return err;
+}
+
+static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
+			       struct rocker_flow_tbl_entry *match)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_flow_tbl_entry *found;
+	unsigned long flags;
+	int del_from_hw = 0;
+	int err = 0;
+
+	match->key_crc32 = crc32(~0, &match->key, sizeof(match->key));
+
+	netdev_info(rocker_port->dev, "flow tbl_del match->key_crc32 0x%08x\n",
+		    match->key_crc32);
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+
+	found = rocker_flow_tbl_find(rocker, match);
+	netdev_info(rocker_port->dev, "flow tbl_del found %p\n", found);
+
+	if (found) {
+		found->ref_count--;
+		if (found->ref_count == 0) {
+			hash_del(&found->entry);
+			del_from_hw = 1;
+		}
+	}
+
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	kfree(match);
+
+	if (del_from_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_flow_tbl_del,
+				      found, NULL, NULL);
+		netdev_info(rocker_port->dev, "flow tbl_del err %d\n", err);
+		kfree(found);
+	}
+
+	return err;
+}
+
+static int rocker_flow_op_do(struct rocker_port *rocker_port,
+			     enum rocker_op op,
+			     struct rocker_flow_tbl_entry *entry)
+{
+	switch (op) {
+	case ROCKER_OP_ADD:
+		return rocker_flow_tbl_add(rocker_port, entry);
+	case ROCKER_OP_DEL:
+		return rocker_flow_tbl_del(rocker_port, entry);
+	}
+
+	return -ENOTSUPP;
+}
+
+static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
+				   enum rocker_op op,
+				   u32 in_lport, u32 in_lport_mask,
+				   enum rocker_of_dpa_table_id goto_tbl)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = ROCKER_PRIORITY_IG_PORT;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
+	entry->key.ig_port.in_lport = in_lport;
+	entry->key.ig_port.in_lport_mask = in_lport_mask;
+	entry->key.ig_port.goto_tbl = goto_tbl;
+
+	netdev_info(rocker_port->dev, "flow ig_port\n");
+
+	return rocker_flow_op_do(rocker_port, op, entry);
+}
+
+static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
+				enum rocker_op op, u32 in_lport,
+				__be16 vlan_id, __be16 vlan_id_mask,
+				enum rocker_of_dpa_table_id goto_tbl,
+				bool untagged, __be16 new_vlan_id)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = ROCKER_PRIORITY_VLAN;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_VLAN;
+	entry->key.vlan.in_lport = in_lport;
+	entry->key.vlan.vlan_id = vlan_id;
+	entry->key.vlan.vlan_id_mask = vlan_id_mask;
+	entry->key.vlan.goto_tbl = goto_tbl;
+
+	entry->key.vlan.untagged = untagged;
+	entry->key.vlan.new_vlan_id = new_vlan_id;
+
+	netdev_info(rocker_port->dev, "flow vlan\n");
+
+	return rocker_flow_op_do(rocker_port, op, entry);
+}
+
+static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
+				  enum rocker_op op,
+				  const u8 *eth_dst, const u8 *eth_dst_mask,
+				  __be16 vlan_id, u32 tunnel_id,
+				  enum rocker_of_dpa_table_id goto_tbl,
+				  u32 group_id)
+{
+	struct rocker_flow_tbl_entry *entry;
+	u32 priority;
+	bool vlan_bridging = !!vlan_id;
+	bool dflt = !eth_dst || (eth_dst && eth_dst_mask);
+	bool wild = false;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_BRIDGING;
+
+	if (eth_dst) {
+		entry->key.bridge.has_eth_dst = 1;
+		ether_addr_copy(entry->key.bridge.eth_dst, eth_dst);
+	}
+	if (eth_dst_mask) {
+		entry->key.bridge.has_eth_dst_mask = 1;
+		ether_addr_copy(entry->key.bridge.eth_dst_mask, eth_dst_mask);
+		if (memcmp(eth_dst_mask, zero_mac, ETH_ALEN))
+			wild = true;
+	}
+
+	priority = ROCKER_PRIORITY_UNKNOWN;
+	if (vlan_bridging & dflt & wild)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
+	else if (vlan_bridging & dflt & !wild)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
+	else if (vlan_bridging & !dflt)
+		priority = ROCKER_PRIORITY_BRIDGING_VLAN;
+	else if (!vlan_bridging & dflt & wild)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
+	else if (!vlan_bridging & dflt & !wild)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
+	else if (!vlan_bridging & !dflt)
+		priority = ROCKER_PRIORITY_BRIDGING_TENANT;
+
+	entry->key.priority = priority;
+	entry->key.bridge.vlan_id = vlan_id;
+	entry->key.bridge.tunnel_id = tunnel_id;
+	entry->key.bridge.goto_tbl = goto_tbl;
+	entry->key.bridge.group_id = group_id;
+
+	netdev_info(rocker_port->dev, "flow bridge\n");
+
+	return rocker_flow_op_do(rocker_port, op, entry);
+}
+
+static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
+			       enum rocker_op op,
+			       u32 priority, u32 in_lport,
+			       u32 in_lport_mask,
+			       const u8 *eth_src, const u8 *eth_src_mask,
+			       const u8 *eth_dst, const u8 *eth_dst_mask,
+			       __be16 eth_type,
+			       __be16 vlan_id, __be16 vlan_id_mask,
+			       u32 group_id)
+{
+	struct rocker_flow_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->key.priority = priority;
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	entry->key.acl.in_lport = in_lport;
+	entry->key.acl.in_lport_mask = in_lport_mask;
+
+	if (eth_src)
+		ether_addr_copy(entry->key.acl.eth_src, eth_src);
+	if (eth_src_mask)
+		ether_addr_copy(entry->key.acl.eth_src_mask, eth_src_mask);
+	if (eth_dst)
+		ether_addr_copy(entry->key.acl.eth_dst, eth_dst);
+	if (eth_dst_mask)
+		ether_addr_copy(entry->key.acl.eth_dst_mask, eth_dst_mask);
+
+	entry->key.acl.eth_type = eth_type;
+	entry->key.acl.vlan_id = vlan_id;
+	entry->key.acl.vlan_id_mask = vlan_id_mask;
+	entry->key.acl.group_id = group_id;
+
+	netdev_info(rocker_port->dev, "flow acl\n");
+
+	return rocker_flow_op_do(rocker_port, op, entry);
+}
+
+static struct rocker_group_tbl_entry *rocker_group_tbl_find(
+	struct rocker *rocker, struct rocker_group_tbl_entry *match)
+{
+	struct rocker_group_tbl_entry *found;
+	u8 type = ROCKER_GROUP_TYPE_GET(match->group_id);
+	u16 index;
+	int bkt;
+
+	switch (type) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE:
+		/* search for match by group_id */
+		hash_for_each_possible(rocker->group_tbl, found,
+				       entry, match->group_id)
+			if (found->group_id == match->group_id)
+				return found;
+		break;
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		/* search for match by group_ids */
+		hash_for_each(rocker->group_tbl, bkt, found, entry) {
+			if (type != ROCKER_GROUP_TYPE_GET(found->group_id))
+				continue;
+			if (found->group_count != match->group_count)
+				continue;
+			if (memcmp(found->group_ids, match->group_ids,
+				   found->group_count * sizeof(u32)) == 0)
+				return found;
+		}
+		/* no match: create new unique group_id */
+		index = rocker->group_index_next++;
+		match->group_id &= ~ROCKER_GROUP_INDEX_MASK;
+		match->group_id |= ROCKER_GROUP_INDEX_SET(index);
+		break;
+	default:
+		break;
+	}
+
+	return NULL;
+}
+
+static void rocker_group_tbl_entry_free(struct rocker_group_tbl_entry *entry)
+{
+	switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+	case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+		kfree(entry->group_ids);
+		break;
+	default:
+		break;
+	}
+	kfree(entry);
+}
+
+static int rocker_group_tbl_add(struct rocker_port *rocker_port,
+				struct rocker_group_tbl_entry *match,
+				u32 *group_id)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_group_tbl_entry *found;
+	unsigned long flags;
+	bool add_to_hw = false;
+	int err = 0;
+
+	netdev_info(rocker_port->dev, "group tbl_add\n");
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+
+	found = rocker_group_tbl_find(rocker, match);
+	netdev_info(rocker_port->dev, "group tbl_add found %p\n", found);
+
+	if (found) {
+		rocker_group_tbl_entry_free(match);
+	} else {
+		found = match;
+		hash_add(rocker->group_tbl, &found->entry, found->group_id);
+		add_to_hw = true;
+	}
+
+	found->ref_count++;
+
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	*group_id = found->group_id;
+
+	if (add_to_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_group_tbl_add,
+				      found, NULL, NULL);
+		netdev_info(rocker_port->dev, "group tbl_add err %d\n", err);
+		if (err) {
+			spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+			hash_del(&found->entry);
+			spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+			rocker_group_tbl_entry_free(found);
+		}
+	}
+
+	return err;
+}
+
+static int rocker_group_tbl_del(struct rocker_port *rocker_port,
+				struct rocker_group_tbl_entry *match,
+				u32 *group_id)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_group_tbl_entry *found;
+	unsigned long flags;
+	bool del_from_hw = false;
+	int err = 0;
+
+	netdev_info(rocker_port->dev, "group tbl_del\n");
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+
+	found = rocker_group_tbl_find(rocker, match);
+	netdev_info(rocker_port->dev, "group tbl_del found %p\n", found);
+
+	if (found) {
+		*group_id = found->group_id;
+		found->ref_count--;
+		if (found->ref_count == 0) {
+			hash_del(&found->entry);
+			del_from_hw = true;
+		}
+	}
+
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	rocker_group_tbl_entry_free(match);
+
+	if (del_from_hw) {
+		err = rocker_cmd_exec(rocker, rocker_port,
+				      rocker_cmd_group_tbl_del,
+				      found, NULL, NULL);
+		netdev_info(rocker_port->dev, "group tbl_del err %d\n", err);
+		rocker_group_tbl_entry_free(found);
+	}
+
+	return err;
+}
+
+static int rocker_group_op_do(struct rocker_port *rocker_port,
+			      enum rocker_op op,
+			      struct rocker_group_tbl_entry *entry,
+			      u32 *group_id)
+{
+	switch (op) {
+	case ROCKER_OP_ADD:
+		return rocker_group_tbl_add(rocker_port, entry, group_id);
+	case ROCKER_OP_DEL:
+		return rocker_group_tbl_del(rocker_port, entry, group_id);
+	}
+
+	return -ENOTSUPP;
+}
+
+static int rocker_group_l2_interface(struct rocker_port *rocker_port,
+				     enum rocker_op op, u32 group_id,
+				     int pop_vlan)
+{
+	struct rocker_group_tbl_entry *entry;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = group_id;
+	entry->l2_interface.pop_vlan = pop_vlan;
+
+	netdev_info(rocker_port->dev, "group l2 interface\n");
+
+	return rocker_group_op_do(rocker_port, op, entry, &group_id);
+}
+
+static int rocker_group_l2_mcast(struct rocker_port *rocker_port,
+				 enum rocker_op op, __be16 vlan_id,
+				 u16 group_count, u32 *group_ids,
+				 u32 *group_id)
+{
+	struct rocker_group_tbl_entry *entry;
+
+	*group_id = 0;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->group_id = ROCKER_GROUP_L2_MCAST(vlan_id, 0);
+	entry->group_count = group_count;
+	entry->group_ids = group_ids;
+
+	netdev_info(rocker_port->dev, "group l2 mcast\n");
+
+	return rocker_group_op_do(rocker_port, op, entry, group_id);
+}
+
+static int rocker_group_id_compare(const void *a, const void *b)
+{
+	return memcmp(a, b, sizeof(u32));
+}
+
+static bool rocker_port_dev_check(struct net_device *dev);
+
+static u32 *rocker_flow_get_group_ids(const struct sw_flow *flow,
+				      __be16 vlan_id, u16 *count)
+{
+	struct net_device *out_port_dev;
+	u32 *group_ids = NULL;
+	u32 out_lport;
+	bool send_up = false;
+	int i;
+
+	*count = 0;
+
+	for (i = 0; i < flow->actions->count; i++) {
+		out_port_dev = flow->actions->actions[i].output_dev;
+		if (rocker_port_dev_check(out_port_dev)) {
+			group_ids = krealloc(group_ids,
+					     ++(*count) * sizeof(u32),
+					     GFP_KERNEL);
+			if (!group_ids)
+				goto err_out;
+			out_lport =
+				rocker_port_to_lport(netdev_priv(out_port_dev));
+			group_ids[i] = ROCKER_GROUP_L2_INTERFACE(vlan_id,
+								 out_lport);
+		} else if (!send_up) {
+			send_up = true;
+			group_ids = krealloc(group_ids,
+					     ++(*count) * sizeof(u32),
+					     GFP_KERNEL);
+			if (!group_ids)
+				goto err_out;
+			out_lport = 0;
+			group_ids[i] = ROCKER_GROUP_L2_INTERFACE(vlan_id,
+								 out_lport);
+		}
+	}
+
+	sort(group_ids, *count, sizeof(u32), rocker_group_id_compare, NULL);
+
+	return group_ids;
+
+err_out:
+	*count = 0;
+	return NULL;
+}
+
+#define ROCKER_FLOW_WITHIN(flow, field) \
+	((offsetof(struct sw_flow_key, field) >= (flow)->mask->range.start) && \
+	 (offsetof(struct sw_flow_key, field) <= (flow)->mask->range.end))
+
+static int rocker_bridging_vlan_ucast(struct rocker_port *rocker_port,
+				      const struct sw_flow *flow,
+				      enum rocker_op op,
+				      __be16 vlan_id, bool pop_vlan)
+{
+	struct net_device *out_port_dev;
+	u32 out_lport;
+	u32 tunnel_id = 0;
+	u32 group_l2_interface;
+	int err;
+
+	/* L2 interface group for output */
+
+	if (flow->actions->count == 0) {
+		out_lport = 0; /* send it up */
+	} else if (flow->actions->count == 1) {
+		out_port_dev = flow->actions->actions[0].output_dev;
+		if (rocker_port_dev_check(out_port_dev))
+			out_lport = rocker_port_to_lport(
+				netdev_priv(out_port_dev));
+		else
+			out_lport = 0; /* send it up */
+	} else {
+		netdev_err(rocker_port->dev, "Trying to install unicast bridge vlan flow with more than one output device\n");
+		return -EINVAL;
+	}
+
+	group_l2_interface = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+	err = rocker_group_l2_interface(rocker_port, op,
+					group_l2_interface, pop_vlan);
+	netdev_info(rocker_port->dev, "ucast bridge l2 interface group err %d\n",
+		    err);
+	if (err)
+		return err;
+
+	/* VLAN unicast bridge table entry */
+
+	err = rocker_flow_tbl_bridge(rocker_port, op,
+				     flow->key.eth.dst, NULL,
+				     vlan_id, tunnel_id,
+				     ROCKER_OF_DPA_TABLE_ID_ACL_POLICY,
+				     group_l2_interface);
+	netdev_info(rocker_port->dev, "ucast bridge err %d\n", err);
+
+	return err;
+}
+
+static int rocker_bridging_vlan_mcast(struct rocker_port *rocker_port,
+				      const struct sw_flow *flow,
+				      enum rocker_op op,
+				      __be16 vlan_id, bool pop_vlan)
+{
+	u32 tunnel_id = 0;
+	u32 group_l2_mcast;
+	u16 group_count;
+	u32 *group_ids;
+	int err;
+	int i;
+
+	/* Get sorted list of output L2 interface group ids;
+	 * if there are none, there is nothing to forward in HW,
+	 * so we're done.
+	 */
+
+	group_ids = rocker_flow_get_group_ids(flow, vlan_id,
+					      &group_count);
+	if (group_ids == 0)
+		return 0;
+
+	/* L2 interface groups for each out_lport */
+
+	for (i = 0; i < group_count; i++) {
+		err = rocker_group_l2_interface(rocker_port, op,
+						group_ids[i], pop_vlan);
+		netdev_info(rocker_port->dev, "mcast bridge l2 interface group err %d\n",
+			    err);
+		if (err)
+			goto err_free_group_ids;
+	}
+
+	/* L2 multicast group entry */
+
+	err = rocker_group_l2_mcast(rocker_port, op,
+				    vlan_id, group_count,
+				    group_ids, &group_l2_mcast);
+	netdev_info(rocker_port->dev, "group l2 mcast group_id 0x%08x err %d\n",
+		    group_l2_mcast, err);
+	if (err)
+		goto err_free_group_ids;
+
+	/* VLAN multicast bridge table entry */
+
+	err = rocker_flow_tbl_bridge(rocker_port, op,
+				     flow->key.eth.dst, NULL,
+				     vlan_id, tunnel_id,
+				     ROCKER_OF_DPA_TABLE_ID_ACL_POLICY,
+				     group_l2_mcast);
+	netdev_info(rocker_port->dev, "mcast bridge err %d\n", err);
+
+	return err;
+
+err_free_group_ids:
+	kfree(group_ids);
+	return err;
+}
+
+static int rocker_flow_parse(struct rocker_port *rocker_port,
+			     const struct sw_flow *flow,
+			     enum rocker_op op)
+{
+	struct net_device *in_port_dev;
+	u32 in_lport;
+	u32 in_lport_mask;
+	__be16 vlan_id;
+	__be16 vlan_id_mask;
+	__be16 new_vlan_id;
+	__be16 outer_vlan_id;
+	u16 bridge_id;
+	u32 tunnel_id;
+	bool untagged;
+	bool unicast;
+	bool eth_dst_exact;
+	int err;
+
+	enum {
+		BRIDGING_MODE_UNKNOWN,
+		BRIDGING_MODE_VLAN_UCAST,
+		BRIDGING_MODE_VLAN_MCAST,
+		BRIDGING_MODE_VLAN_DFLT,
+		BRIDGING_MODE_TUNNEL_UCAST,
+		BRIDGING_MODE_TUNNEL_MCAST,
+		BRIDGING_MODE_TUNNEL_DFLT,
+	} bridging_mode = BRIDGING_MODE_UNKNOWN;
+
+	tunnel_id = 0; /* XXX for now */
+
+	/* A note about value masks: sw_flow uses mask bit value of
+	 * 0 for "don't care", whereas OF-DPA HW uses mask bit value
+	 * of 1 for "don't care", so sw_flow mask value must be
+	 * inverted beforing passing to OF-DPA HW.  To summurize:
+	 *
+	 *      mask bit   sw_flow         OF-DPA
+	 *      -------------------------------------
+	 *      0          don't care      care
+	 *      1          care            don't care
+	 */
+
+	/* Get lport fot in_port.  Skip sw_flows if in_port is not a
+	 * rocker port in our network namespace.
+	 */
+
+	if (!ROCKER_FLOW_WITHIN(flow, phy.in_port))
+		return 0;
+
+	in_port_dev = dev_get_by_index(rocker_port->dev->nd_net,
+				       flow->key.misc.in_port_ifindex);
+	if (!in_port_dev || !rocker_port_dev_check(in_port_dev))
+		return 0;
+
+	in_lport = rocker_port_to_lport(netdev_priv(in_port_dev));
+	in_lport_mask = 0;
+
+	/* Determine outer VLAN ID.  If untagged, use bridge VLAN ID,
+	 * otherwise use tagged VLAN ID for outer VLAN ID.
+	 */
+
+	if (!ROCKER_FLOW_WITHIN(flow, eth.tci))
+		return 0;
+
+	if (flow->key.eth.tci == htons(0) &&
+	    flow->mask->key.eth.tci == htons(0xffff)) {
+		vlan_id = flow->key.eth.tci;
+		vlan_id_mask = htons(0x0fff);
+		untagged = true;
+	} else {
+		/* XXX For now, fail any vlan except untagged vlan 0 */
+		netdev_warn(rocker_port->dev,
+			    "Can't parse vlan info, vlan 0x%04x mask 0x%04x\n",
+			    ntohs(flow->key.eth.tci),
+			    ntohs(flow->mask->key.eth.tci));
+		return 0;
+	}
+
+	bridge_id = 0; /* XXX for now, need unique ID for each bridge */
+	new_vlan_id = htons(bridge_id << 8 | in_lport);
+	outer_vlan_id = untagged ? new_vlan_id : vlan_id;
+
+	/* Ingress port table entry */
+
+	err = rocker_flow_tbl_ig_port(rocker_port, op,
+				      in_lport, in_lport_mask,
+				      ROCKER_OF_DPA_TABLE_ID_VLAN);
+	netdev_info(rocker_port->dev, "flow parse ig port err %d\n", err);
+	if (err)
+		return err;
+
+	/* VLAN table entry */
+
+	err = rocker_flow_tbl_vlan(rocker_port, op,
+				   in_lport, vlan_id, vlan_id_mask,
+				   ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC,
+				   untagged, new_vlan_id);
+	if (err)
+		return err;
+
+	/* XXX Determine if sw_flow wants L2 bridging or L3 routing.
+	 * XXX If wanting L3 routing, need to add termination mac
+	 * XXX table entry to catch L3 routing prefixes.
+	 * XXX For now, just doing L2 bridging, so skip term mac tbl
+	 * XXX (miss on term mac tbl goes to bridge tbl).
+	 */
+
+	unicast = (flow->key.eth.dst[5] & 0x01) == 0x00;
+	eth_dst_exact = memcmp(flow->mask->key.eth.dst, ff_mac, ETH_ALEN) == 0;
+
+	if (outer_vlan_id && unicast && eth_dst_exact)
+		bridging_mode = BRIDGING_MODE_VLAN_UCAST;
+	else if (outer_vlan_id && !unicast && eth_dst_exact)
+		bridging_mode = BRIDGING_MODE_VLAN_MCAST;
+
+	switch (bridging_mode) {
+	case BRIDGING_MODE_VLAN_UCAST:
+		err = rocker_bridging_vlan_ucast(rocker_port, flow, op,
+						 outer_vlan_id, untagged);
+		break;
+	case BRIDGING_MODE_VLAN_MCAST:
+		err = rocker_bridging_vlan_mcast(rocker_port, flow, op,
+						 outer_vlan_id, untagged);
+		break;
+	default:
+		netdev_info(rocker_port->dev, "Unknown bridging mode\n");
+		err = -ENOTSUPP;
+		break;
+	}
+
+	if (err)
+		return err;
+
+	/* ACL table entry */
+
+	err = rocker_flow_tbl_acl(rocker_port, op,
+				  ROCKER_PRIORITY_ACL,
+				  in_lport, in_lport_mask,
+				  flow->key.eth.src, zero_mac,
+				  flow->key.eth.dst, zero_mac,
+				  flow->key.eth.type,
+				  outer_vlan_id, vlan_id_mask,
+				  ROCKER_GROUP_NONE);
+	netdev_info(rocker_port->dev, "mcast bridge acl err %d\n", err);
+
+	return err;
+}
+
+static int rocker_flow_add(struct rocker_port *rocker_port,
+			   const struct sw_flow *flow)
+{
+	return rocker_flow_parse(rocker_port, flow, ROCKER_OP_ADD);
+}
+
+static int rocker_flow_del(struct rocker_port *rocker_port,
+			   const struct sw_flow *flow)
+{
+	return rocker_flow_parse(rocker_port, flow, ROCKER_OP_DEL);
+}
+
+/*****************
+ * Net device ops
+ *****************/
+
+static int rocker_port_open(struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	err = rocker_port_dma_rings_init(rocker_port);
+	if (err)
+		return err;
+
+	err = request_irq(rocker_msix_tx_vector(rocker_port),
+			  rocker_tx_irq_handler, 0,
+			  rocker_driver_name, rocker_port);
+	if (err) {
+		netdev_err(rocker_port->dev, "cannot assign tx irq\n");
+		goto err_request_tx_irq;
+	}
+
+	err = request_irq(rocker_msix_rx_vector(rocker_port),
+			  rocker_rx_irq_handler, 0,
+			  rocker_driver_name, rocker_port);
+	if (err) {
+		netdev_err(rocker_port->dev, "cannot assign rx irq\n");
+		goto err_request_rx_irq;
+	}
+
+	napi_enable(&rocker_port->napi_tx);
+	napi_enable(&rocker_port->napi_rx);
+	rocker_port_set_enable(rocker_port, true);
+	netif_start_queue(dev);
+	return 0;
+
+err_request_rx_irq:
+	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
+err_request_tx_irq:
+	rocker_port_dma_rings_fini(rocker_port);
+	return err;
+}
+
+static int rocker_port_stop(struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	rocker_port_set_enable(rocker_port, false);
+	napi_disable(&rocker_port->napi_rx);
+	napi_disable(&rocker_port->napi_tx);
+	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
+	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
+	rocker_port_dma_rings_fini(rocker_port);
+
+	return 0;
+}
+
+static void rocker_tx_desc_frags_unmap(struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct pci_dev *pdev = rocker->pdev;
+	struct rocker_tlv *attrs[ROCKER_TLV_TX_MAX + 1];
+	struct rocker_tlv *attr;
+	int rem;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_TX_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_TX_FRAGS])
+		return;
+	rocker_tlv_for_each_nested(attr, attrs[ROCKER_TLV_TX_FRAGS], rem) {
+		struct rocker_tlv *frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_MAX + 1];
+		dma_addr_t dma_handle;
+		size_t len;
+
+		if (rocker_tlv_type(attr) != ROCKER_TLV_TX_FRAG)
+			continue;
+		rocker_tlv_parse_nested(frag_attrs, ROCKER_TLV_TX_FRAG_ATTR_MAX,
+					attr);
+		if (!frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_ADDR] ||
+		    !frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_LEN])
+			continue;
+		dma_handle = rocker_tlv_get_u64(frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_ADDR]);
+		len = rocker_tlv_get_u16(frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_LEN]);
+		pci_unmap_single(pdev, dma_handle, len, DMA_TO_DEVICE);
+	}
+}
+
+static int rocker_tx_desc_frag_map_put(struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info,
+				       char *buf, size_t buf_len)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct pci_dev *pdev = rocker->pdev;
+	dma_addr_t dma_handle;
+	struct rocker_tlv *frag;
+
+	dma_handle = pci_map_single(pdev, buf, buf_len, DMA_TO_DEVICE);
+	if (unlikely(pci_dma_mapping_error(pdev, dma_handle))) {
+		if (net_ratelimit())
+			netdev_err(rocker_port->dev, "failed to dma map tx frag\n");
+		return -EIO;
+	}
+	frag = rocker_tlv_nest_start(desc_info, ROCKER_TLV_TX_FRAG);
+	if (!frag)
+		goto unmap_frag;
+	if (rocker_tlv_put_u64(desc_info, ROCKER_TLV_TX_FRAG_ATTR_ADDR,
+			       dma_handle))
+		goto nest_cancel;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_TX_FRAG_ATTR_LEN,
+			       buf_len))
+		goto nest_cancel;
+	rocker_tlv_nest_end(desc_info, frag);
+	return 0;
+
+nest_cancel:
+	rocker_tlv_nest_cancel(desc_info, frag);
+unmap_frag:
+	pci_unmap_single(pdev, dma_handle, buf_len, DMA_TO_DEVICE);
+	return -EMSGSIZE;
+}
+
+static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_desc_info *desc_info;
+	struct rocker_tlv *frags;
+	int i;
+	int err;
+
+	desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
+	if (unlikely(!desc_info)) {
+		if (net_ratelimit())
+			netdev_err(dev, "tx ring full when queue awake\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	rocker_desc_cookie_ptr_set(desc_info, skb);
+
+	frags = rocker_tlv_nest_start(desc_info, ROCKER_TLV_TX_FRAGS);
+	if (!frags)
+		goto out;
+	err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
+					  skb->data, skb_headlen(skb));
+	if (err)
+		goto nest_cancel;
+	if (skb_shinfo(skb)->nr_frags > ROCKER_TX_FRAGS_MAX)
+		goto nest_cancel;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
+						  skb_frag_address(frag),
+						  skb_frag_size(frag));
+		if (err)
+			goto unmap_frags;
+	}
+	rocker_tlv_nest_end(desc_info, frags);
+
+	rocker_desc_gen_clear(desc_info);
+	rocker_desc_head_set(rocker, &rocker_port->tx_ring, desc_info);
+
+	desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
+	if (!desc_info)
+		netif_stop_queue(dev);
+
+	return NETDEV_TX_OK;
+
+unmap_frags:
+	rocker_tx_desc_frags_unmap(rocker_port, desc_info);
+nest_cancel:
+	rocker_tlv_nest_cancel(desc_info, frags);
+out:
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static struct rocker_promisc_acl {
+	u16 eth_type;
+	const u8 *eth_src;
+	const u8 *eth_src_mask;
+	const u8 *eth_dst;
+	const u8 *eth_dst_mask;
+} rocker_promisc_acls[] = {
+	{
+		/* allow any ARP pkts */
+		.eth_type = htons(ETH_P_ARP),
+		.eth_src = zero_mac,
+		.eth_src_mask = ff_mac,
+		.eth_dst = zero_mac,
+		.eth_dst_mask = ff_mac,
+	},
+	{
+		/* allow any IP pkts */
+		.eth_type = htons(ETH_P_IP),
+		.eth_src = zero_mac,
+		.eth_src_mask = ff_mac,
+		.eth_dst = zero_mac,
+		.eth_dst_mask = ff_mac,
+	},
+	{
+		/* allow LLDP pkts */
+		.eth_type = htons(ETH_P_IP),
+		.eth_src = zero_mac,
+		.eth_src_mask = ff_mac,
+		.eth_dst = lldp_mac,
+		.eth_dst_mask = zero_mac,
+	},
+	{
+		/* mark end of list */
+		.eth_type = 0,
+	},
+};
+
+static int rocker_port_set_promisc(struct rocker_port *rocker_port,
+				   enum rocker_op op)
+{
+	u32 in_lport = rocker_port_to_lport(rocker_port);
+	u32 in_lport_mask = 0;
+	u32 out_lport;
+	u16 bridge_id;
+	__be16 vlan_id;
+	__be16 vlan_id_mask;
+	__be16 new_vlan_id;
+	struct rocker_promisc_acl *acl;
+	u32 group_l2_interface;
+	bool untagged;
+	bool pop_vlan;
+	int err;
+
+	/* ingress port table entry */
+
+	err = rocker_flow_tbl_ig_port(rocker_port, op,
+				      in_lport, in_lport_mask,
+				      ROCKER_OF_DPA_TABLE_ID_VLAN);
+	if (err)
+		return err;
+
+	/* VLAN table entry for untagged traffic */
+
+	vlan_id = 0;
+	vlan_id_mask = htons(0x0fff);
+	untagged = true;
+	bridge_id = 0; /* XXX for now, need a unique ID for each bridge */
+	new_vlan_id = htons(bridge_id << 8 | in_lport);
+
+	err = rocker_flow_tbl_vlan(rocker_port, op,
+				   in_lport, vlan_id, vlan_id_mask,
+				   ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC,
+				   untagged, new_vlan_id);
+	if (err)
+		return err;
+
+	/* L2 interface group entry for bridge (port 0) */
+
+	out_lport = 0;
+	pop_vlan = untagged;
+
+	group_l2_interface = ROCKER_GROUP_L2_INTERFACE(new_vlan_id, out_lport);
+	err = rocker_group_l2_interface(rocker_port, op, group_l2_interface,
+					pop_vlan);
+	if (err)
+		return err;
+
+	/* ACL table entries for acceptable pkts */
+
+	for (acl = rocker_promisc_acls; acl->eth_type; acl++) {
+		err = rocker_flow_tbl_acl(rocker_port, op,
+					  ROCKER_PRIORITY_ACL_PORT_PROMISC,
+					  in_lport, in_lport_mask,
+					  acl->eth_src, acl->eth_src_mask,
+					  acl->eth_dst, acl->eth_dst_mask,
+					  acl->eth_type,
+					  new_vlan_id, vlan_id_mask,
+					  group_l2_interface);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static void rocker_port_set_rx_mode(struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int prev_promisc = (rocker_port->prev_flags & IFF_PROMISC) ? 1 : 0;
+	int promisc = (dev->flags & IFF_PROMISC) ? 1 : 0;
+	enum rocker_op op = promisc ? ROCKER_OP_ADD : ROCKER_OP_DEL;
+
+	if (promisc != prev_promisc)
+		rocker_port_set_promisc(rocker_port, op);
+
+	rocker_port->prev_flags = dev->flags;
+}
+
+static int rocker_port_set_mac_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	err = rocker_cmd_set_port_settings_macaddr(rocker_port, addr->sa_data);
+	if (err)
+		return err;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+static int rocker_port_swdev_get_id(struct net_device *dev,
+				    struct netdev_phys_item_id *psid)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker *rocker = rocker_port->rocker;
+
+	psid->id_len = sizeof(rocker->hw.id);
+	memcpy(&psid->id, &rocker->hw.id, psid->id_len);
+	return 0;
+}
+
+static int rocker_port_swdev_flow_insert(struct net_device *dev,
+					 const struct sw_flow *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	return rocker_flow_add(rocker_port, flow);
+}
+
+static int rocker_port_swdev_flow_remove(struct net_device *dev,
+					 const struct sw_flow *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	return rocker_flow_del(rocker_port, flow);
+}
+
+static const struct net_device_ops rocker_port_netdev_ops = {
+	.ndo_open		= rocker_port_open,
+	.ndo_stop		= rocker_port_stop,
+	.ndo_start_xmit		= rocker_port_xmit,
+	.ndo_set_rx_mode	= rocker_port_set_rx_mode,
+	.ndo_set_mac_address	= rocker_port_set_mac_address,
+	.ndo_swdev_get_id	= rocker_port_swdev_get_id,
+	.ndo_swdev_flow_insert	= rocker_port_swdev_flow_insert,
+	.ndo_swdev_flow_remove	= rocker_port_swdev_flow_remove,
+};
+
+static bool rocker_port_dev_check(struct net_device *dev)
+{
+	return dev->netdev_ops == &rocker_port_netdev_ops;
+}
+
+/********************
+ * ethtool interface
+ ********************/
+
+static int rocker_port_get_settings(struct net_device *dev,
+				    struct ethtool_cmd *ecmd)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	return rocker_cmd_get_port_settings_ethtool(rocker_port, ecmd);
+}
+
+static int rocker_port_set_settings(struct net_device *dev,
+				    struct ethtool_cmd *ecmd)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	return rocker_cmd_set_port_settings_ethtool(rocker_port, ecmd);
+}
+
+static void rocker_port_get_drvinfo(struct net_device *dev,
+				    struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, rocker_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
+}
+
+static const struct ethtool_ops rocker_port_ethtool_ops = {
+	.get_settings		= rocker_port_get_settings,
+	.set_settings		= rocker_port_set_settings,
+	.get_drvinfo		= rocker_port_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+};
+
+/*****************
+ * NAPI interface
+ *****************/
+
+static struct rocker_port *rocker_port_napi_tx_get(struct napi_struct *napi)
+{
+	return container_of(napi, struct rocker_port, napi_tx);
+}
+
+static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
+{
+	struct rocker_port *rocker_port = rocker_port_napi_tx_get(napi);
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_desc_info *desc_info;
+	u32 credits = 0;
+	int err;
+
+	/* Cleanup tx descriptors */
+	while ((desc_info = rocker_desc_tail_get(&rocker_port->tx_ring))) {
+		err = rocker_desc_err(desc_info);
+		if (err && net_ratelimit())
+			netdev_err(rocker_port->dev, "tx desc received with err %d\n",
+				   err);
+		rocker_tx_desc_frags_unmap(rocker_port, desc_info);
+		dev_kfree_skb_any(rocker_desc_cookie_ptr_get(desc_info));
+		credits++;
+	}
+
+	if (credits && netif_queue_stopped(rocker_port->dev))
+		netif_wake_queue(rocker_port->dev);
+
+	napi_complete(napi);
+	rocker_dma_ring_credits_set(rocker, &rocker_port->tx_ring, credits);
+
+	return 0;
+}
+
+static int rocker_port_rx_proc(struct rocker *rocker,
+			       struct rocker_port *rocker_port,
+			       struct rocker_desc_info *desc_info)
+{
+	struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
+	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
+	size_t rx_len;
+
+	if (!skb)
+		return -ENOENT;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_RX_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_RX_FRAG_LEN])
+		return -EINVAL;
+
+	rocker_dma_rx_ring_skb_unmap(rocker, attrs);
+
+	rx_len = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FRAG_LEN]);
+	skb_put(skb, rx_len);
+	skb->protocol = eth_type_trans(skb, rocker_port->dev);
+	netif_receive_skb(skb);
+
+	return rocker_dma_rx_ring_skb_alloc(rocker, rocker_port, desc_info);
+}
+
+static struct rocker_port *rocker_port_napi_rx_get(struct napi_struct *napi)
+{
+	return container_of(napi, struct rocker_port, napi_rx);
+}
+
+static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
+{
+	struct rocker_port *rocker_port = rocker_port_napi_rx_get(napi);
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_desc_info *desc_info;
+	u32 credits = 0;
+	int err;
+
+	/* Process rx descriptors */
+	while (credits < budget &&
+	       (desc_info = rocker_desc_tail_get(&rocker_port->rx_ring))) {
+		err = rocker_desc_err(desc_info);
+		if (err) {
+			if (net_ratelimit())
+				netdev_err(rocker_port->dev, "rx desc received with err %d\n",
+					   err);
+		} else {
+			err = rocker_port_rx_proc(rocker, rocker_port,
+						  desc_info);
+			if (err && net_ratelimit())
+				netdev_err(rocker_port->dev, "rx processing failed with err %d\n",
+					   err);
+		}
+		rocker_desc_gen_clear(desc_info);
+		rocker_desc_head_set(rocker, &rocker_port->rx_ring, desc_info);
+		credits++;
+	}
+
+	if (credits < budget)
+		napi_complete(napi);
+
+	rocker_dma_ring_credits_set(rocker, &rocker_port->rx_ring, credits);
+
+	return credits;
+}
+
+/*****************
+ * PCI driver ops
+ *****************/
+
+static void rocker_carrier_init(struct rocker_port *rocker_port)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	u64 link_status = rocker_read64(rocker, PORT_PHYS_LINK_STATUS);
+	bool link_up;
+
+	link_up = link_status & (1 << rocker_port_to_lport(rocker_port));
+	if (link_up)
+		netif_carrier_on(rocker_port->dev);
+	else
+		netif_carrier_off(rocker_port->dev);
+}
+
+static void rocker_remove_ports(struct rocker *rocker)
+{
+	int i;
+
+	for (i = 0; i < rocker->port_count; i++)
+		unregister_netdev(rocker->ports[i]->dev);
+	kfree(rocker->ports);
+}
+
+static void rocker_port_dev_addr_init(struct rocker *rocker,
+				      struct rocker_port *rocker_port)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int err;
+
+	err = rocker_cmd_get_port_settings_macaddr(rocker_port,
+						   rocker_port->dev->dev_addr);
+	if (err) {
+		dev_warn(&pdev->dev, "failed to get mac address, using random\n");
+		eth_hw_addr_random(rocker_port->dev);
+	}
+}
+
+static int rocker_probe_port(struct rocker *rocker, unsigned port_number)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	struct rocker_port *rocker_port;
+	struct net_device *dev;
+	int err;
+
+	dev = alloc_etherdev(sizeof(struct rocker_port));
+	if (!dev)
+		return -ENOMEM;
+	rocker_port = netdev_priv(dev);
+	rocker_port->dev = dev;
+	rocker_port->rocker = rocker;
+	rocker_port->port_number = port_number;
+
+	rocker_port_dev_addr_init(rocker, rocker_port);
+	dev->netdev_ops = &rocker_port_netdev_ops;
+	dev->ethtool_ops = &rocker_port_ethtool_ops;
+	netif_napi_add(dev, &rocker_port->napi_tx, rocker_port_poll_tx,
+		       NAPI_POLL_WEIGHT);
+	netif_napi_add(dev, &rocker_port->napi_rx, rocker_port_poll_rx,
+		       NAPI_POLL_WEIGHT);
+	rocker_carrier_init(rocker_port);
+
+	err = register_netdev(dev);
+	if (err) {
+		dev_err(&pdev->dev, "register_netdev failed\n");
+		goto free_netdev;
+	}
+	rocker->ports[port_number] = rocker_port;
+	return 0;
+
+free_netdev:
+	free_netdev(dev);
+	return err;
+}
+
+static int rocker_probe_ports(struct rocker *rocker)
+{
+	int i;
+	size_t alloc_size;
+	int err;
+
+	alloc_size = sizeof(struct rocker_port *) * rocker->port_count;
+	rocker->ports = kmalloc(alloc_size, GFP_KERNEL);
+	for (i = 0; i < rocker->port_count; i++) {
+		err = rocker_probe_port(rocker, i);
+		if (err)
+			goto remove_ports;
+	}
+	return 0;
+
+remove_ports:
+	rocker_remove_ports(rocker);
+	return err;
+}
+
+static int rocker_msix_init(struct rocker *rocker)
+{
+	struct pci_dev *pdev = rocker->pdev;
+	int msix_entries;
+	int i;
+	int err;
+
+	msix_entries = pci_msix_vec_count(pdev);
+	if (msix_entries < 0)
+		return msix_entries;
+
+	if (msix_entries != ROCKER_MSIX_VEC_COUNT(rocker->port_count))
+		return -EINVAL;
+
+	rocker->msix_entries = kmalloc_array(msix_entries,
+					     sizeof(struct msix_entry),
+					     GFP_KERNEL);
+	if (!rocker->msix_entries)
+		return -ENOMEM;
+
+	for (i = 0; i < msix_entries; i++)
+		rocker->msix_entries[i].entry = i;
+
+	err = pci_enable_msix_exact(pdev, rocker->msix_entries, msix_entries);
+	if (err < 0)
+		goto err_enable_msix;
+
+	return 0;
+
+err_enable_msix:
+	kfree(rocker->msix_entries);
+	return err;
+}
+
+static void rocker_msix_fini(struct rocker *rocker)
+{
+	pci_disable_msix(rocker->pdev);
+	kfree(rocker->msix_entries);
+}
+
+static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	struct rocker *rocker;
+	int err;
+
+	rocker = kzalloc(sizeof(*rocker), GFP_KERNEL);
+	if (!rocker)
+		return -ENOMEM;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_device failed\n");
+		goto err_pci_enable_device;
+	}
+
+	err = pci_request_regions(pdev, rocker_driver_name);
+	if (err) {
+		dev_err(&pdev->dev, "pci_request_regions failed\n");
+		goto err_pci_request_regions;
+	}
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (!err) {
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
+		if (err) {
+			dev_err(&pdev->dev, "pci_set_consistent_dma_mask failed\n");
+			goto err_pci_set_dma_mask;
+		}
+	} else {
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev, "pci_set_dma_mask failed\n");
+			goto err_pci_set_dma_mask;
+		}
+	}
+
+	if (pci_resource_len(pdev, 0) < ROCKER_PCI_BAR0_SIZE) {
+		dev_err(&pdev->dev, "invalid PCI region size\n");
+		goto err_pci_resource_len_check;
+	}
+
+	rocker->hw_addr = ioremap(pci_resource_start(pdev, 0),
+				  pci_resource_len(pdev, 0));
+	if (!rocker->hw_addr) {
+		dev_err(&pdev->dev, "ioremap failed\n");
+		err = -EIO;
+		goto err_ioremap;
+	}
+	pci_set_master(pdev);
+
+	rocker->pdev = pdev;
+	pci_set_drvdata(pdev, rocker);
+
+	rocker->port_count = rocker_read32(rocker, PORT_PHYS_COUNT);
+
+	err = rocker_msix_init(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "MSI-X init failed\n");
+		goto err_msix_init;
+	}
+
+	err = rocker_basic_hw_test(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "basic hw test failed\n");
+		goto err_basic_hw_test;
+	}
+
+	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
+
+	err = rocker_dma_rings_init(rocker);
+	if (err)
+		goto err_dma_rings_init;
+
+	err = request_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD),
+			  rocker_cmd_irq_handler, 0,
+			  rocker_driver_name, rocker);
+	if (err) {
+		dev_err(&pdev->dev, "cannot assign cmd irq\n");
+		goto err_request_cmd_irq;
+	}
+
+	err = request_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT),
+			  rocker_event_irq_handler, 0,
+			  rocker_driver_name, rocker);
+	if (err) {
+		dev_err(&pdev->dev, "cannot assign event irq\n");
+		goto err_request_event_irq;
+	}
+
+	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
+
+	err = rocker_probe_ports(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "failed to probe ports\n");
+		goto err_probe_ports;
+	}
+
+	hash_init(rocker->flow_tbl);
+	spin_lock_init(&rocker->flow_tbl_lock);
+
+	hash_init(rocker->group_tbl);
+	spin_lock_init(&rocker->group_tbl_lock);
+
+	dev_info(&pdev->dev, "Rocker switch with id %016llx\n", rocker->hw.id);
+
+	return 0;
+
+err_probe_ports:
+	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
+err_request_event_irq:
+	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
+err_request_cmd_irq:
+	rocker_dma_rings_fini(rocker);
+err_dma_rings_init:
+err_basic_hw_test:
+	rocker_msix_fini(rocker);
+err_msix_init:
+	iounmap(rocker->hw_addr);
+err_ioremap:
+err_pci_resource_len_check:
+err_pci_set_dma_mask:
+	pci_release_regions(pdev);
+err_pci_request_regions:
+	pci_disable_device(pdev);
+err_pci_enable_device:
+	kfree(rocker);
+	return err;
+}
+
+static void rocker_remove(struct pci_dev *pdev)
+{
+	struct rocker *rocker = pci_get_drvdata(pdev);
+
+	rocker_remove_ports(rocker);
+	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
+	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
+	rocker_dma_rings_fini(rocker);
+	rocker_msix_fini(rocker);
+	iounmap(rocker->hw_addr);
+	pci_release_regions(rocker->pdev);
+	pci_disable_device(rocker->pdev);
+	kfree(rocker);
+}
+
+static struct pci_driver rocker_pci_driver = {
+	.name		= rocker_driver_name,
+	.id_table	= rocker_pci_id_table,
+	.probe		= rocker_probe,
+	.remove		= rocker_remove,
+};
+
+/************************************
+ * Net device notifier event handler
+ ************************************/
+
+static int rocker_port_master_changed(struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	enum rocker_port_mode newmode = ROCKER_PORT_MODE_L2L3;
+	enum rocker_port_mode oldmode;
+	struct net_device *master = netdev_master_upper_dev_get(dev);
+	int err;
+
+	if (master && master->rtnl_link_ops &&
+	    !strcmp(master->rtnl_link_ops->kind, "openvswitch"))
+		newmode = ROCKER_PORT_MODE_OF_DPA;
+	err = rocker_cmd_get_port_settings_mode(rocker_port, &oldmode);
+	if (err)
+		return err;
+	if (newmode == oldmode)
+		return 0;
+	err = rocker_cmd_set_port_settings_mode(rocker_port, newmode);
+	if (err)
+		return err;
+	netdev_info(dev, "port mode changed from %d to %d\n", oldmode, newmode);
+	return err;
+}
+
+static int rocker_device_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	int err;
+
+	if (!rocker_port_dev_check(dev))
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_CHANGEUPPER:
+		err = rocker_port_master_changed(dev);
+		if (err)
+			netdev_warn(dev, "failed to reflect master change (err %d)\n",
+				    err);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rocker_notifier_block __read_mostly = {
+	.notifier_call = rocker_device_event,
+};
+
+/***********************
+ * Module init and exit
+ ***********************/
+
+static int __init rocker_module_init(void)
+{
+	int err;
+
+	register_netdevice_notifier(&rocker_notifier_block);
+	err = pci_register_driver(&rocker_pci_driver);
+	if (err)
+		goto err_pci_register_driver;
+	return 0;
+
+err_pci_register_driver:
+	unregister_netdevice_notifier(&rocker_notifier_block);
+	return err;
+}
+
+static void __exit rocker_module_exit(void)
+{
+	unregister_netdevice_notifier(&rocker_notifier_block);
+	pci_unregister_driver(&rocker_pci_driver);
+}
+
+module_init(rocker_module_init);
+module_exit(rocker_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_AUTHOR("Scott Feldman <sfeldma@cumulusnetworks.com>");
+MODULE_DESCRIPTION("Rocker switch device driver");
+MODULE_DEVICE_TABLE(pci, rocker_pci_id_table);
diff --git a/drivers/net/rocker.h b/drivers/net/rocker.h
new file mode 100644
index 0000000..74836a4
--- /dev/null
+++ b/drivers/net/rocker.h
@@ -0,0 +1,465 @@
+/*
+ * drivers/net/rocker.h - Rocker switch device driver
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@cumulusnetworks.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ROCKER_H
+#define _ROCKER_H
+
+#include <linux/types.h>
+
+#define PCI_VENDOR_ID_REDHAT		0x1b36
+#define PCI_DEVICE_ID_REDHAT_ROCKER	0x0006
+
+#define ROCKER_PCI_BAR0_SIZE		0x2000
+
+/* MSI-X vectors */
+enum {
+	ROCKER_MSIX_VEC_CMD,
+	ROCKER_MSIX_VEC_EVENT,
+	ROCKER_MSIX_VEC_TEST,
+	ROCKER_MSIX_VEC_RESERVED0,
+	__ROCKER_MSIX_VEC_TX,
+	__ROCKER_MSIX_VEC_RX,
+#define ROCKER_MSIX_VEC_TX(port) \
+	(__ROCKER_MSIX_VEC_TX + ((port) * 2))
+#define ROCKER_MSIX_VEC_RX(port) \
+	(__ROCKER_MSIX_VEC_RX + ((port) * 2))
+#define ROCKER_MSIX_VEC_COUNT(portcnt) \
+	(ROCKER_MSIX_VEC_RX((portcnt - 1)) + 1)
+};
+
+/* Rocker bogus registers */
+#define ROCKER_BOGUS_REG0		0x0000
+#define ROCKER_BOGUS_REG1		0x0004
+#define ROCKER_BOGUS_REG2		0x0008
+#define ROCKER_BOGUS_REG3		0x000c
+
+/* Rocker test registers */
+#define ROCKER_TEST_REG			0x0010
+#define ROCKER_TEST_REG64		0x0018  /* 8-byte */
+#define ROCKER_TEST_IRQ			0x0020
+#define ROCKER_TEST_DMA_ADDR		0x0028  /* 8-byte */
+#define ROCKER_TEST_DMA_SIZE		0x0030
+#define ROCKER_TEST_DMA_CTRL		0x0034
+
+/* Rocker test register ctrl */
+#define ROCKER_TEST_DMA_CTRL_CLEAR	(1 << 0)
+#define ROCKER_TEST_DMA_CTRL_FILL	(1 << 1)
+#define ROCKER_TEST_DMA_CTRL_INVERT	(1 << 2)
+
+/* Rocker DMA ring register offsets */
+#define ROCKER_DMA_DESC_ADDR(x)		(0x1000 + (x) * 32)  /* 8-byte */
+#define ROCKER_DMA_DESC_SIZE(x)		(0x1008 + (x) * 32)
+#define ROCKER_DMA_DESC_HEAD(x)		(0x100c + (x) * 32)
+#define ROCKER_DMA_DESC_TAIL(x)		(0x1010 + (x) * 32)
+#define ROCKER_DMA_DESC_CTRL(x)		(0x1014 + (x) * 32)
+#define ROCKER_DMA_DESC_CREDITS(x)	(0x1018 + (x) * 32)
+#define ROCKER_DMA_DESC_RES1(x)		(0x101c + (x) * 32)
+
+/* Rocker dma ctrl register bits */
+#define ROCKER_DMA_DESC_CTRL_RESET	(1 << 0)
+
+/* Rocker DMA ring types */
+enum rocker_dma_type {
+	ROCKER_DMA_CMD,
+	ROCKER_DMA_EVENT,
+	__ROCKER_DMA_TX,
+	__ROCKER_DMA_RX,
+#define ROCKER_DMA_TX(port) (__ROCKER_DMA_TX + (port) * 2)
+#define ROCKER_DMA_RX(port) (__ROCKER_DMA_RX + (port) * 2)
+};
+
+/* Rocker DMA ring size limits and default sizes */
+#define ROCKER_DMA_SIZE_MIN		2ul
+#define ROCKER_DMA_SIZE_MAX		65536ul
+#define ROCKER_DMA_CMD_DEFAULT_SIZE	32ul
+#define ROCKER_DMA_EVENT_DEFAULT_SIZE	32ul
+#define ROCKER_DMA_TX_DEFAULT_SIZE	64ul
+#define ROCKER_DMA_TX_DESC_SIZE		256
+#define ROCKER_DMA_RX_DEFAULT_SIZE	64ul
+#define ROCKER_DMA_RX_DESC_SIZE		256
+
+/* Rocker DMA descriptor struct */
+struct rocker_desc {
+	u64 buf_addr;
+	u64 cookie;
+	u16 buf_size;
+	u16 tlv_size;
+	u16 resv[5];
+	u16 comp_err;
+} __packed __aligned(8);
+
+#define ROCKER_DMA_DESC_COMP_ERR_GEN	(1 << 15)
+
+/* Rocker DMA TLV struct */
+struct rocker_tlv {
+	u32 type;
+	u16 len;
+} __packed __aligned(8);
+
+/* TLVs */
+enum {
+	ROCKER_TLV_CMD_UNSPEC,
+	ROCKER_TLV_CMD_TYPE,	/* u16 */
+	ROCKER_TLV_CMD_INFO,	/* nest */
+
+	__ROCKER_TLV_CMD_MAX,
+	ROCKER_TLV_CMD_MAX = __ROCKER_TLV_CMD_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_CMD_TYPE_UNSPEC,
+	ROCKER_TLV_CMD_TYPE_GET_PORT_SETTINGS,
+	ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_ADD,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_MOD,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_DEL,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_FLOW_GET_STATS,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_ADD,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_MOD,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL,
+	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_GET_STATS,
+	ROCKER_TLV_CMD_TYPE_TRUNK,
+	ROCKER_TLV_CMD_TYPE_BRIDGE,
+
+	__ROCKER_TLV_CMD_TYPE_MAX,
+	ROCKER_TLV_CMD_TYPE_MAX = __ROCKER_TLV_CMD_TYPE_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_CMD_PORT_SETTINGS_UNSPEC,
+	ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,		/* u32 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_SPEED,		/* u32 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX,		/* u8 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG,		/* u8 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,		/* binary */
+	ROCKER_TLV_CMD_PORT_SETTINGS_MODE,		/* u8 */
+
+	__ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+	ROCKER_TLV_CMD_PORT_SETTINGS_MAX =
+			__ROCKER_TLV_CMD_PORT_SETTINGS_MAX - 1,
+};
+
+enum rocker_port_mode {
+	ROCKER_PORT_MODE_OF_DPA,
+	ROCKER_PORT_MODE_L2L3,
+};
+
+enum {
+	ROCKER_TLV_EVENT_UNSPEC,
+	ROCKER_TLV_EVENT_TYPE,	/* u16 */
+	ROCKER_TLV_EVENT_INFO,	/* nest */
+
+	__ROCKER_TLV_EVENT_MAX,
+	ROCKER_TLV_EVENT_MAX = __ROCKER_TLV_EVENT_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_EVENT_TYPE_UNSPEC,
+	ROCKER_TLV_EVENT_TYPE_LINK_CHANGED,
+
+	__ROCKER_TLV_EVENT_TYPE_MAX,
+	ROCKER_TLV_EVENT_TYPE_MAX = __ROCKER_TLV_EVENT_TYPE_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_EVENT_LINK_CHANGED_UNSPEC,
+	ROCKER_TLV_EVENT_LINK_CHANGED_LPORT,	/* u32 */
+	ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP,	/* u8 */
+
+	__ROCKER_TLV_EVENT_LINK_CHANGED_MAX,
+	ROCKER_TLV_EVENT_LINK_CHANGED_MAX =
+			__ROCKER_TLV_EVENT_LINK_CHANGED_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_RX_UNSPEC,
+	ROCKER_TLV_RX_FLAGS,		/* u16, see ROCKER_RX_FLAGS_ */
+	ROCKER_TLV_RX_CSUM,		/* u16 */
+	ROCKER_TLV_RX_FRAG_ADDR,	/* u64 */
+	ROCKER_TLV_RX_FRAG_MAX_LEN,	/* u16 */
+	ROCKER_TLV_RX_FRAG_LEN,		/* u16 */
+
+	__ROCKER_TLV_RX_MAX,
+	ROCKER_TLV_RX_MAX = __ROCKER_TLV_RX_MAX - 1,
+};
+
+#define ROCKER_RX_FLAGS_IPV4			(1 << 0)
+#define ROCKER_RX_FLAGS_IPV6			(1 << 1)
+#define ROCKER_RX_FLAGS_CSUM_CALC		(1 << 2)
+#define ROCKER_RX_FLAGS_IPV4_CSUM_GOOD		(1 << 3)
+#define ROCKER_RX_FLAGS_IP_FRAG			(1 << 4)
+#define ROCKER_RX_FLAGS_TCP			(1 << 5)
+#define ROCKER_RX_FLAGS_UDP			(1 << 6)
+#define ROCKER_RX_FLAGS_TCP_UDP_CSUM_GOOD	(1 << 7)
+
+enum {
+	ROCKER_TLV_TX_UNSPEC,
+	ROCKER_TLV_TX_OFFLOAD,		/* u8, see ROCKER_TX_OFFLOAD_ */
+	ROCKER_TLV_TX_L3_CSUM_OFF,	/* u16 */
+	ROCKER_TLV_TX_TSO_MSS,		/* u16 */
+	ROCKER_TLV_TX_TSO_HDR_LEN,	/* u16 */
+	ROCKER_TLV_TX_FRAGS,		/* array */
+
+	__ROCKER_TLV_TX_MAX,
+	ROCKER_TLV_TX_MAX = __ROCKER_TLV_TX_MAX - 1,
+};
+
+#define ROCKER_TX_OFFLOAD_NONE		0
+#define ROCKER_TX_OFFLOAD_IP_CSUM	1
+#define ROCKER_TX_OFFLOAD_TCP_UDP_CSUM	2
+#define ROCKER_TX_OFFLOAD_L3_CSUM	3
+#define ROCKER_TX_OFFLOAD_TSO		4
+
+#define ROCKER_TX_FRAGS_MAX		16
+
+enum {
+	ROCKER_TLV_TX_FRAG_UNSPEC,
+	ROCKER_TLV_TX_FRAG,		/* nest */
+
+	__ROCKER_TLV_TX_FRAG_MAX,
+	ROCKER_TLV_TX_FRAG_MAX = __ROCKER_TLV_TX_FRAG_MAX - 1,
+};
+
+enum {
+	ROCKER_TLV_TX_FRAG_ATTR_UNSPEC,
+	ROCKER_TLV_TX_FRAG_ATTR_ADDR,	/* u64 */
+	ROCKER_TLV_TX_FRAG_ATTR_LEN,	/* u16 */
+
+	__ROCKER_TLV_TX_FRAG_ATTR_MAX,
+	ROCKER_TLV_TX_FRAG_ATTR_MAX = __ROCKER_TLV_TX_FRAG_ATTR_MAX - 1,
+};
+
+/* cmd info nested for OF-DPA msgs */
+enum {
+	ROCKER_TLV_OF_DPA_UNSPEC,
+	ROCKER_TLV_OF_DPA_TABLE_ID,		/* u16 */
+	ROCKER_TLV_OF_DPA_PRIORITY,		/* u32 */
+	ROCKER_TLV_OF_DPA_HARDTIME,		/* u32 */
+	ROCKER_TLV_OF_DPA_IDLETIME,		/* u32 */
+	ROCKER_TLV_OF_DPA_COOKIE,		/* u64 */
+	ROCKER_TLV_OF_DPA_IN_LPORT,		/* u32 */
+	ROCKER_TLV_OF_DPA_IN_LPORT_MASK,	/* u32 */
+	ROCKER_TLV_OF_DPA_OUT_LPORT,		/* u32 */
+	ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,	/* u16 */
+	ROCKER_TLV_OF_DPA_GROUP_ID,		/* u32 */
+	ROCKER_TLV_OF_DPA_GROUP_COUNT,		/* u16 */
+	ROCKER_TLV_OF_DPA_GROUP_IDS,		/* u32 array */
+	ROCKER_TLV_OF_DPA_VLAN_ID,		/* __be16 */
+	ROCKER_TLV_OF_DPA_VLAN_ID_MASK,		/* __be16 */
+	ROCKER_TLV_OF_DPA_VLAN_PCP,		/* __be16 */
+	ROCKER_TLV_OF_DPA_VLAN_PCP_MASK,	/* __be16 */
+	ROCKER_TLV_OF_DPA_VLAN_PCP_ACTION,	/* u8 */
+	ROCKER_TLV_OF_DPA_NEW_VLAN_ID,		/* __be16 */
+	ROCKER_TLV_OF_DPA_NEW_VLAN_PCP,		/* u8 */
+	ROCKER_TLV_OF_DPA_TUNNEL_ID,		/* u32 */
+	ROCKER_TLV_OF_DPA_TUN_LOG_LPORT,	/* u32 */
+	ROCKER_TLV_OF_DPA_ETHERTYPE,		/* __be16 */
+	ROCKER_TLV_OF_DPA_DST_MAC,		/* binary */
+	ROCKER_TLV_OF_DPA_DST_MAC_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_SRC_MAC,		/* binary */
+	ROCKER_TLV_OF_DPA_SRC_MAC_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_IP_PROTO,		/* __be16 */
+	ROCKER_TLV_OF_DPA_IP_PROTO_MASK,	/* __be16 */
+	ROCKER_TLV_OF_DPA_DSCP,			/* __be16 */
+	ROCKER_TLV_OF_DPA_DSCP_MASK,		/* __be16 */
+	ROCKER_TLV_OF_DPA_DSCP_ACTION,		/* u8 */
+	ROCKER_TLV_OF_DPA_NEW_DSCP,		/* u8 */
+	ROCKER_TLV_OF_DPA_ECN,			/* __be16 */
+	ROCKER_TLV_OF_DPA_ECN_MASK,		/* __be16 */
+	ROCKER_TLV_OF_DPA_DST_IP,		/* __be32 */
+	ROCKER_TLV_OF_DPA_DST_IP_MASK,		/* __be32 */
+	ROCKER_TLV_OF_DPA_SRC_IP,		/* __be32 */
+	ROCKER_TLV_OF_DPA_SRC_IP_MASK,		/* __be32 */
+	ROCKER_TLV_OF_DPA_DST_IPV6,		/* binary */
+	ROCKER_TLV_OF_DPA_DST_IPV6_MASK,	/* binary */
+	ROCKER_TLV_OF_DPA_SRC_IPV6,		/* binary */
+	ROCKER_TLV_OF_DPA_SRC_IPV6_MASK,	/* binary */
+	ROCKER_TLV_OF_DPA_SRC_ARP_IP,		/* __be32 */
+	ROCKER_TLV_OF_DPA_SRC_ARP_IP_MASK,	/* __be32 */
+	ROCKER_TLV_OF_DPA_L4_DST_PORT,		/* __be16 */
+	ROCKER_TLV_OF_DPA_L4_DST_PORT_MASK,	/* __be16 */
+	ROCKER_TLV_OF_DPA_L4_SRC_PORT,		/* __be16 */
+	ROCKER_TLV_OF_DPA_L4_SRC_PORT_MASK,	/* __be16 */
+	ROCKER_TLV_OF_DPA_ICMP_TYPE,		/* u8 */
+	ROCKER_TLV_OF_DPA_ICMP_TYPE_MASK,	/* u8 */
+	ROCKER_TLV_OF_DPA_ICMP_CODE,		/* u8 */
+	ROCKER_TLV_OF_DPA_ICMP_CODE_MASK,	/* u8 */
+	ROCKER_TLV_OF_DPA_IPV6_LABEL,		/* __be32 */
+	ROCKER_TLV_OF_DPA_IPV6_LABEL_MASK,	/* __be32 */
+	ROCKER_TLV_OF_DPA_QUEUE_ID_ACTION,	/* u8 */
+	ROCKER_TLV_OF_DPA_NEW_QUEUE_ID,		/* u8 */
+	ROCKER_TLV_OF_DPA_CLEAR_ACTIONS,	/* u32 */
+	ROCKER_TLV_OF_DPA_POP_VLAN,		/* u8 */
+
+	__ROCKER_TLV_OF_DPA_MAX,
+	ROCKER_TLV_OF_DPA_MAX = __ROCKER_TLV_OF_DPA_MAX - 1,
+};
+
+/* OF-DPA table IDs */
+
+enum rocker_of_dpa_table_id {
+	ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT = 0,
+	ROCKER_OF_DPA_TABLE_ID_VLAN = 10,
+	ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC = 20,
+	ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING = 30,
+	ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING = 40,
+	ROCKER_OF_DPA_TABLE_ID_BRIDGING = 50,
+	ROCKER_OF_DPA_TABLE_ID_ACL_POLICY = 60,
+};
+
+/* OF_DPA_xxx nest */
+enum {
+	ROCKER_TLV_OF_DPA_INFO_UNSPEC,
+	ROCKER_TLV_OF_DPA_INFO_IN_LPORT,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_IN_LPORT_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_OUT_LPORT,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_GOTO_TABLE_ID,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_GROUP_ID,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_VLAN_ID,			/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_VLAN_ID_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_VLAN_PCP,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_VLAN_PCP_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_VLAN_PCP_ACTION,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_NEW_VLAN_ID,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_NEW_VLAN_PCP,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_TUNNEL_ID,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_TUN_LOG_LPORT,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_ETHERTYPE,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_DST_MAC,			/* binary */
+	ROCKER_TLV_OF_DPA_INFO_DST_MAC_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_MAC,			/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_MAC_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_IP_PROTO,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_IP_PROTO_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_DSCP,			/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_DSCP_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_DSCP_ACTION,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_NEW_DSCP,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_ECN,			/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_ECN_MASK,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_DST_IP,			/* binary */
+	ROCKER_TLV_OF_DPA_INFO_DST_IP_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_IP,			/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_IP_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_DST_IPV6,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_DST_IPV6_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_IPV6,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_IPV6_MASK,		/* binary */
+	ROCKER_TLV_OF_DPA_INFO_SRC_ARP_IP,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_SRC_ARP_IP_MASK,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_L4_DST_PORT,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_L4_DST_PORT_MASK,	/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_L4_SRC_PORT,		/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_L4_SRC_PORT_MASK,	/* u16 */
+	ROCKER_TLV_OF_DPA_INFO_ICMP_TYPE,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_ICMP_TYPE_MASK,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_ICMP_CODE,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_ICMP_CODE_MASK,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_IPV6_LABEL,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_IPV6_LABEL_MASK,		/* u32 */
+	ROCKER_TLV_OF_DPA_INFO_QUEUE_ID_ACTION,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_NEW_QUEUE_ID,		/* u8 */
+	ROCKER_TLV_OF_DPA_INFO_CLEAR_ACTIONS,		/* u32 */
+
+	__ROCKER_TLV_OF_DPA_INFO_MAX,
+	ROCKER_TLV_OF_DPA_INFO_MAX = __ROCKER_TLV_OF_DPA_INFO_MAX - 1,
+};
+
+/* OF-DPA flow stats */
+enum {
+	ROCKER_TLV_OF_DPA_FLOW_STAT_UNSPEC,
+	ROCKER_TLV_OF_DPA_FLOW_STAT_DURATION,	/* u32 */
+	ROCKER_TLV_OF_DPA_FLOW_STAT_RX_PKTS,	/* u64 */
+	ROCKER_TLV_OF_DPA_FLOW_STAT_TX_PKTS,	/* u64 */
+
+	__ROCKER_TLV_OF_DPA_FLOW_STAT_MAX,
+	ROCKER_TLV_OF_DPA_FLOW_STAT_MAX = __ROCKER_TLV_OF_DPA_FLOW_STAT_MAX - 1,
+};
+
+/* OF-DPA group types */
+enum rocker_of_dpa_group_type {
+	ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE = 0,
+	ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE,
+	ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST,
+	ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST,
+	ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD,
+	ROCKER_OF_DPA_GROUP_TYPE_L3_INTERFACE,
+	ROCKER_OF_DPA_GROUP_TYPE_L3_MCAST,
+	ROCKER_OF_DPA_GROUP_TYPE_L3_ECMP,
+	ROCKER_OF_DPA_GROUP_TYPE_L2_OVERLAY,
+};
+
+/* OF-DPA group L2 overlay types */
+enum rocker_of_dpa_overlay_type {
+	ROCKER_OF_DPA_OVERLAY_TYPE_FLOOD_UCAST = 0,
+	ROCKER_OF_DPA_OVERLAY_TYPE_FLOOD_MCAST,
+	ROCKER_OF_DPA_OVERLAY_TYPE_MCAST_UCAST,
+	ROCKER_OF_DPA_OVERLAY_TYPE_MCAST_MCAST,
+};
+
+/* OF-DPA group ID encoding */
+#define ROCKER_GROUP_TYPE_SHIFT 28
+#define ROCKER_GROUP_TYPE_MASK 0xf0000000
+#define ROCKER_GROUP_VLAN_SHIFT 16
+#define ROCKER_GROUP_VLAN_MASK 0x0fff0000
+#define ROCKER_GROUP_PORT_SHIFT 0
+#define ROCKER_GROUP_PORT_MASK 0x0000ffff
+#define ROCKER_GROUP_TUNNEL_ID_SHIFT 12
+#define ROCKER_GROUP_TUNNEL_ID_MASK 0x0ffff000
+#define ROCKER_GROUP_SUBTYPE_SHIFT 10
+#define ROCKER_GROUP_SUBTYPE_MASK 0x00000c00
+#define ROCKER_GROUP_INDEX_SHIFT 0
+#define ROCKER_GROUP_INDEX_MASK 0x0000ffff
+#define ROCKER_GROUP_INDEX_LONG_SHIFT 0
+#define ROCKER_GROUP_INDEX_LONG_MASK 0x0fffffff
+
+#define ROCKER_GROUP_TYPE_GET(group_id) \
+	(((group_id) & ROCKER_GROUP_TYPE_MASK) >> ROCKER_GROUP_TYPE_SHIFT)
+#define ROCKER_GROUP_TYPE_SET(type) \
+	(((type) << ROCKER_GROUP_TYPE_SHIFT) & ROCKER_GROUP_TYPE_MASK)
+#define ROCKER_GROUP_VLAN_GET(group_id) \
+	(((group_id) & ROCKER_GROUP_VLAN_ID_MASK) >> ROCKER_GROUP_VLAN_ID_SHIFT)
+#define ROCKER_GROUP_VLAN_SET(vlan_id) \
+	(((vlan_id) << ROCKER_GROUP_VLAN_SHIFT) & ROCKER_GROUP_VLAN_MASK)
+#define ROCKER_GROUP_PORT_GET(group_id) \
+	(((group_id) & ROCKER_GROUP_PORT_MASK) >> ROCKER_GROUP_PORT_SHIFT)
+#define ROCKER_GROUP_PORT_SET(port) \
+	(((port) << ROCKER_GROUP_PORT_SHIFT) & ROCKER_GROUP_PORT_MASK)
+#define ROCKER_GROUP_INDEX_GET(group_id) \
+	(((group_id) & ROCKER_GROUP_INDEX_MASK) >> ROCKER_GROUP_INDEX_SHIFT)
+#define ROCKER_GROUP_INDEX_SET(index) \
+	(((index) << ROCKER_GROUP_INDEX_SHIFT) & ROCKER_GROUP_INDEX_MASK)
+#define ROCKER_GROUP_INDEX_LONG_GET(group_id) \
+	(((group_id) & ROCKER_GROUP_INDEX_LONG_MASK) >> \
+	 ROCKER_GROUP_INDEX_LONG_SHIFT)
+#define ROCKER_GROUP_INDEX_LONG_SET(index) \
+	(((index) << ROCKER_GROUP_INDEX_LONG_SHIFT) & \
+	 ROCKER_GROUP_INDEX_LONG_MASK)
+
+#define ROCKER_GROUP_NONE 0
+#define ROCKER_GROUP_L2_INTERFACE(vlan_id, port) \
+	(ROCKER_GROUP_TYPE_SET(ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE) |\
+	 ROCKER_GROUP_VLAN_SET(vlan_id) | ROCKER_GROUP_PORT_SET(port))
+#define ROCKER_GROUP_L2_MCAST(vlan_id, index) \
+	(ROCKER_GROUP_TYPE_SET(ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST) |\
+	 ROCKER_GROUP_VLAN_SET(vlan_id) | ROCKER_GROUP_INDEX_SET(index))
+
+/* Rocker general purpose registers */
+#define ROCKER_CONTROL			0x0300
+#define ROCKER_PORT_PHYS_COUNT		0x0304
+#define ROCKER_PORT_PHYS_LINK_STATUS	0x0310 /* 8-byte */
+#define ROCKER_PORT_PHYS_ENABLE		0x0318 /* 8-byte */
+#define ROCKER_SWITCH_ID		0x0320 /* 8-byte */
+
+/* Rocker control bits */
+#define ROCKER_CONTROL_RESET		(1 << 0)
+
+#endif
-- 
1.9.3
