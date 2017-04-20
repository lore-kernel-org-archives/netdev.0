From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e/i40evf: Add tracepoints
Date: Wed, 19 Apr 2017 18:57:41 -0700
Message-ID: <20170420015750.6828-6-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Scott Peterson <scott.d.peterson@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939039AbdDTB55 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:57 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Peterson <scott.d.peterson@intel.com>

This patch adds tracepoints to the i40e and i40evf drivers to which
BPF programs can be attached for feature testing and verification.
It's expected that an attached BPF program will identify and count or
log some interesting subset of traffic. The bcc-tools package is
helpful there for containing all the BPF arcana in a handy Python
wrapper. Though you can make these tracepoints log trace messages, the
messages themselves probably won't be very useful (other to verify the
tracepoint is being called while you're debugging your BPF program).

The idea here is that tracepoints have such low performance cost when
disabled that we can leave these in the upstream drivers. This may
eventually enable the instrumentation of unmodified customer systems
should the need arise to verify a NIC feature is working as expected.
In general this enables one set of feature verification tools to be
used on these drivers whether they're built with the kernel or
separately.

Users are advised against using these tracepoints for anything other
than a diagnostic tool. They have a performance impact when enabled,
and their exact placement and form may change as we see how well they
work in practice for the purposes above.

Change-ID: Id6014a7322c0e6d08068114dd20bd156f2f6435e
Signed-off-by: Scott Peterson <scott.d.peterson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/Makefile        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_main.c     |   6 +
 drivers/net/ethernet/intel/i40e/i40e_trace.h    | 229 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |   9 +
 drivers/net/ethernet/intel/i40evf/Makefile      |   3 +
 drivers/net/ethernet/intel/i40evf/i40e_trace.h  | 229 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |   9 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   7 +
 8 files changed, 495 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_trace.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_trace.h

diff --git a/drivers/net/ethernet/intel/i40e/Makefile b/drivers/net/ethernet/intel/i40e/Makefile
index 4f454d364d0d..3da482c3d68d 100644
--- a/drivers/net/ethernet/intel/i40e/Makefile
+++ b/drivers/net/ethernet/intel/i40e/Makefile
@@ -28,6 +28,9 @@
 # Makefile for the Intel(R) Ethernet Connection XL710 (i40e.ko) driver
 #
 
+ccflags-y += -I$(src)
+subdir-ccflags-y += -I$(src)
+
 obj-$(CONFIG_I40E) += i40e.o
 
 i40e-objs := i40e_main.o \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b6ec9beeebff..5e625e0c73ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -32,6 +32,12 @@
 #include "i40e.h"
 #include "i40e_diag.h"
 #include <net/udp_tunnel.h>
+/* All i40e tracepoints are defined by the include below, which
+ * must be included exactly once across the whole kernel with
+ * CREATE_TRACE_POINTS defined
+ */
+#define CREATE_TRACE_POINTS
+#include "i40e_trace.h"
 
 const char i40e_driver_name[] = "i40e";
 static const char i40e_driver_string[] =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_trace.h b/drivers/net/ethernet/intel/i40e/i40e_trace.h
new file mode 100644
index 000000000000..d3e55f54a05e
--- /dev/null
+++ b/drivers/net/ethernet/intel/i40e/i40e_trace.h
@@ -0,0 +1,229 @@
+/*******************************************************************************
+ *
+ * Intel(R) 40-10 Gigabit Ethernet Connection Network Driver
+ * Copyright(c) 2013 - 2017 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
+
+/* Modeled on trace-events-sample.h */
+
+/* The trace subsystem name for i40e will be "i40e".
+ *
+ * This file is named i40e_trace.h.
+ *
+ * Since this include file's name is different from the trace
+ * subsystem name, we'll have to define TRACE_INCLUDE_FILE at the end
+ * of this file.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM i40e
+
+/* See trace-events-sample.h for a detailed description of why this
+ * guard clause is different from most normal include files.
+ */
+#if !defined(_I40E_TRACE_H_) || defined(TRACE_HEADER_MULTI_READ)
+#define _I40E_TRACE_H_
+
+#include <linux/tracepoint.h>
+
+/**
+ * i40e_trace() macro enables shared code to refer to trace points
+ * like:
+ *
+ * trace_i40e{,vf}_example(args...)
+ *
+ * ... as:
+ *
+ * i40e_trace(example, args...)
+ *
+ * ... to resolve to the PF or VF version of the tracepoint without
+ * ifdefs, and to allow tracepoints to be disabled entirely at build
+ * time.
+ *
+ * Trace point should always be referred to in the driver via this
+ * macro.
+ *
+ * Similarly, i40e_trace_enabled(trace_name) wraps references to
+ * trace_i40e{,vf}_<trace_name>_enabled() functions.
+ */
+#define _I40E_TRACE_NAME(trace_name) (trace_ ## i40e ## _ ## trace_name)
+#define I40E_TRACE_NAME(trace_name) _I40E_TRACE_NAME(trace_name)
+
+#define i40e_trace(trace_name, args...) I40E_TRACE_NAME(trace_name)(args)
+
+#define i40e_trace_enabled(trace_name) I40E_TRACE_NAME(trace_name##_enabled)()
+
+/* Events common to PF and VF. Corresponding versions will be defined
+ * for both, named trace_i40e_* and trace_i40evf_*. The i40e_trace()
+ * macro above will select the right trace point name for the driver
+ * being built from shared code.
+ */
+
+/* Events related to a vsi & ring */
+DECLARE_EVENT_CLASS(
+	i40e_tx_template,
+
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf),
+
+	/* The convention here is to make the first fields in the
+	 * TP_STRUCT match the TP_PROTO exactly. This enables the use
+	 * of the args struct generated by the tplist tool (from the
+	 * bcc-tools package) to be used for those fields. To access
+	 * fields other than the tracepoint args will require the
+	 * tplist output to be adjusted.
+	 */
+	TP_STRUCT__entry(
+		__field(void*, ring)
+		__field(void*, desc)
+		__field(void*, buf)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->ring = ring;
+		__entry->desc = desc;
+		__entry->buf = buf;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s ring: %p desc: %p buf %p",
+		__get_str(devname), __entry->ring,
+		__entry->desc, __entry->buf)
+);
+
+DEFINE_EVENT(
+	i40e_tx_template, i40e_clean_tx_irq,
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf));
+
+DEFINE_EVENT(
+	i40e_tx_template, i40e_clean_tx_irq_unmap,
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf));
+
+DECLARE_EVENT_CLASS(
+	i40e_rx_template,
+
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb),
+
+	TP_STRUCT__entry(
+		__field(void*, ring)
+		__field(void*, desc)
+		__field(void*, skb)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->ring = ring;
+		__entry->desc = desc;
+		__entry->skb = skb;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s ring: %p desc: %p skb %p",
+		__get_str(devname), __entry->ring,
+		__entry->desc, __entry->skb)
+);
+
+DEFINE_EVENT(
+	i40e_rx_template, i40e_clean_rx_irq,
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb));
+
+DEFINE_EVENT(
+	i40e_rx_template, i40e_clean_rx_irq_rx,
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb));
+
+DECLARE_EVENT_CLASS(
+	i40e_xmit_template,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring),
+
+	TP_STRUCT__entry(
+		__field(void*, skb)
+		__field(void*, ring)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->skb = skb;
+		__entry->ring = ring;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s skb: %p ring: %p",
+		__get_str(devname), __entry->skb,
+		__entry->ring)
+);
+
+DEFINE_EVENT(
+	i40e_xmit_template, i40e_xmit_frame_ring,
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring));
+
+DEFINE_EVENT(
+	i40e_xmit_template, i40e_xmit_frame_ring_drop,
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring));
+
+/* Events unique to the PF. */
+
+#endif /* _I40E_TRACE_H_ */
+/* This must be outside ifdef _I40E_TRACE_H */
+
+/* This trace include file is not located in the .../include/trace
+ * with the kernel tracepoint definitions, because we're a loadable
+ * module.
+ */
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH .
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_FILE i40e_trace
+#include <trace/define_trace.h>
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 843d7ffe1784..1531a0f9fcc6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -27,6 +27,7 @@
 #include <linux/prefetch.h>
 #include <net/busy_poll.h>
 #include "i40e.h"
+#include "i40e_trace.h"
 #include "i40e_prototype.h"
 
 static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
@@ -765,6 +766,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 		/* prevent any other reads prior to eop_desc */
 		read_barrier_depends();
 
+		i40e_trace(clean_tx_irq, tx_ring, tx_desc, tx_buf);
 		/* we have caught up to head, no work left to do */
 		if (tx_head == tx_desc)
 			break;
@@ -791,6 +793,8 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 
 		/* unmap remaining buffers */
 		while (tx_desc != eop_desc) {
+			i40e_trace(clean_tx_irq_unmap,
+				   tx_ring, tx_desc, tx_buf);
 
 			tx_buf++;
 			tx_desc++;
@@ -2005,6 +2009,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		if (!size)
 			break;
 
+		i40e_trace(clean_rx_irq, rx_ring, rx_desc, skb);
 		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
 
 		/* retrieve a buffer from the ring */
@@ -2057,6 +2062,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		vlan_tag = (qword & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)) ?
 			   le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1) : 0;
 
+		i40e_trace(clean_rx_irq_rx, rx_ring, rx_desc, skb);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 		skb = NULL;
 
@@ -3138,6 +3144,8 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	/* prefetch the data, we'll need it later */
 	prefetch(skb->data);
 
+	i40e_trace(xmit_frame_ring, skb, tx_ring);
+
 	count = i40e_xmit_descriptor_count(skb);
 	if (i40e_chk_linearize(skb, count)) {
 		if (__skb_linearize(skb)) {
@@ -3216,6 +3224,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 out_drop:
+	i40e_trace(xmit_frame_ring_drop, first->skb, tx_ring);
 	dev_kfree_skb_any(first->skb);
 	first->skb = NULL;
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/intel/i40evf/Makefile b/drivers/net/ethernet/intel/i40evf/Makefile
index 827c7a6ed0ba..a393f4a07f06 100644
--- a/drivers/net/ethernet/intel/i40evf/Makefile
+++ b/drivers/net/ethernet/intel/i40evf/Makefile
@@ -29,6 +29,9 @@
 #
 #
 
+ccflags-y += -I$(src)
+subdir-ccflags-y += -I$(src)
+
 obj-$(CONFIG_I40EVF) += i40evf.o
 
 i40evf-objs :=	i40evf_main.o i40evf_ethtool.o i40evf_virtchnl.o \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_trace.h b/drivers/net/ethernet/intel/i40evf/i40e_trace.h
new file mode 100644
index 000000000000..9a5100b2b7c7
--- /dev/null
+++ b/drivers/net/ethernet/intel/i40evf/i40e_trace.h
@@ -0,0 +1,229 @@
+/*******************************************************************************
+ *
+ * Intel(R) 40-10 Gigabit Ethernet Virtual Function Driver
+ * Copyright(c) 2013 - 2017 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
+
+/* Modeled on trace-events-sample.h */
+
+/* The trace subsystem name for i40evf will be "i40evf".
+ *
+ * This file is named i40e_trace.h.
+ *
+ * Since this include file's name is different from the trace
+ * subsystem name, we'll have to define TRACE_INCLUDE_FILE at the end
+ * of this file.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM i40evf
+
+/* See trace-events-sample.h for a detailed description of why this
+ * guard clause is different from most normal include files.
+ */
+#if !defined(_I40E_TRACE_H_) || defined(TRACE_HEADER_MULTI_READ)
+#define _I40E_TRACE_H_
+
+#include <linux/tracepoint.h>
+
+/**
+ * i40e_trace() macro enables shared code to refer to trace points
+ * like:
+ *
+ * trace_i40e{,vf}_example(args...)
+ *
+ * ... as:
+ *
+ * i40e_trace(example, args...)
+ *
+ * ... to resolve to the PF or VF version of the tracepoint without
+ * ifdefs, and to allow tracepoints to be disabled entirely at build
+ * time.
+ *
+ * Trace point should always be referred to in the driver via this
+ * macro.
+ *
+ * Similarly, i40e_trace_enabled(trace_name) wraps references to
+ * trace_i40e{,vf}_<trace_name>_enabled() functions.
+ */
+#define _I40E_TRACE_NAME(trace_name) (trace_ ## i40evf ## _ ## trace_name)
+#define I40E_TRACE_NAME(trace_name) _I40E_TRACE_NAME(trace_name)
+
+#define i40e_trace(trace_name, args...) I40E_TRACE_NAME(trace_name)(args)
+
+#define i40e_trace_enabled(trace_name) I40E_TRACE_NAME(trace_name##_enabled)()
+
+/* Events common to PF and VF. Corresponding versions will be defined
+ * for both, named trace_i40e_* and trace_i40evf_*. The i40e_trace()
+ * macro above will select the right trace point name for the driver
+ * being built from shared code.
+ */
+
+/* Events related to a vsi & ring */
+DECLARE_EVENT_CLASS(
+	i40evf_tx_template,
+
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf),
+
+	/* The convention here is to make the first fields in the
+	 * TP_STRUCT match the TP_PROTO exactly. This enables the use
+	 * of the args struct generated by the tplist tool (from the
+	 * bcc-tools package) to be used for those fields. To access
+	 * fields other than the tracepoint args will require the
+	 * tplist output to be adjusted.
+	 */
+	TP_STRUCT__entry(
+		__field(void*, ring)
+		__field(void*, desc)
+		__field(void*, buf)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->ring = ring;
+		__entry->desc = desc;
+		__entry->buf = buf;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s ring: %p desc: %p buf %p",
+		__get_str(devname), __entry->ring,
+		__entry->desc, __entry->buf)
+);
+
+DEFINE_EVENT(
+	i40evf_tx_template, i40evf_clean_tx_irq,
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf));
+
+DEFINE_EVENT(
+	i40evf_tx_template, i40evf_clean_tx_irq_unmap,
+	TP_PROTO(struct i40e_ring *ring,
+		 struct i40e_tx_desc *desc,
+		 struct i40e_tx_buffer *buf),
+
+	TP_ARGS(ring, desc, buf));
+
+DECLARE_EVENT_CLASS(
+	i40evf_rx_template,
+
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb),
+
+	TP_STRUCT__entry(
+		__field(void*, ring)
+		__field(void*, desc)
+		__field(void*, skb)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->ring = ring;
+		__entry->desc = desc;
+		__entry->skb = skb;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s ring: %p desc: %p skb %p",
+		__get_str(devname), __entry->ring,
+		__entry->desc, __entry->skb)
+);
+
+DEFINE_EVENT(
+	i40evf_rx_template, i40evf_clean_rx_irq,
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb));
+
+DEFINE_EVENT(
+	i40evf_rx_template, i40evf_clean_rx_irq_rx,
+	TP_PROTO(struct i40e_ring *ring,
+		 union i40e_32byte_rx_desc *desc,
+		 struct sk_buff *skb),
+
+	TP_ARGS(ring, desc, skb));
+
+DECLARE_EVENT_CLASS(
+	i40evf_xmit_template,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring),
+
+	TP_STRUCT__entry(
+		__field(void*, skb)
+		__field(void*, ring)
+		__string(devname, ring->netdev->name)
+	),
+
+	TP_fast_assign(
+		__entry->skb = skb;
+		__entry->ring = ring;
+		__assign_str(devname, ring->netdev->name);
+	),
+
+	TP_printk(
+		"netdev: %s skb: %p ring: %p",
+		__get_str(devname), __entry->skb,
+		__entry->ring)
+);
+
+DEFINE_EVENT(
+	i40evf_xmit_template, i40evf_xmit_frame_ring,
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring));
+
+DEFINE_EVENT(
+	i40evf_xmit_template, i40evf_xmit_frame_ring_drop,
+	TP_PROTO(struct sk_buff *skb,
+		 struct i40e_ring *ring),
+
+	TP_ARGS(skb, ring));
+
+/* Events unique to the VF. */
+
+#endif /* _I40E_TRACE_H_ */
+/* This must be outside ifdef _I40E_TRACE_H */
+
+/* This trace include file is not located in the .../include/trace
+ * with the kernel tracepoint definitions, because we're a loadable
+ * module.
+ */
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH .
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_FILE i40e_trace
+#include <trace/define_trace.h>
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 80931e3f9445..34e96d98251a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -28,6 +28,7 @@
 #include <net/busy_poll.h>
 
 #include "i40evf.h"
+#include "i40e_trace.h"
 #include "i40e_prototype.h"
 
 static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
@@ -180,6 +181,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 		/* prevent any other reads prior to eop_desc */
 		read_barrier_depends();
 
+		i40e_trace(clean_tx_irq, tx_ring, tx_desc, tx_buf);
 		/* if the descriptor isn't done, no work yet to do */
 		if (!(eop_desc->cmd_type_offset_bsz &
 		      cpu_to_le64(I40E_TX_DESC_DTYPE_DESC_DONE)))
@@ -207,6 +209,8 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 
 		/* unmap remaining buffers */
 		while (tx_desc != eop_desc) {
+			i40e_trace(clean_tx_irq_unmap,
+				   tx_ring, tx_desc, tx_buf);
 
 			tx_buf++;
 			tx_desc++;
@@ -1329,6 +1333,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		if (!size)
 			break;
 
+		i40e_trace(clean_rx_irq, rx_ring, rx_desc, skb);
 		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
 
 		/* retrieve a buffer from the ring */
@@ -1382,6 +1387,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		vlan_tag = (qword & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)) ?
 			   le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1) : 0;
 
+		i40e_trace(clean_rx_irq_rx, rx_ring, rx_desc, skb);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 		skb = NULL;
 
@@ -2223,6 +2229,8 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	/* prefetch the data, we'll need it later */
 	prefetch(skb->data);
 
+	i40e_trace(xmit_frame_ring, skb, tx_ring);
+
 	count = i40e_xmit_descriptor_count(skb);
 	if (i40e_chk_linearize(skb, count)) {
 		if (__skb_linearize(skb)) {
@@ -2290,6 +2298,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 out_drop:
+	i40e_trace(xmit_frame_ring_drop, first->skb, tx_ring);
 	dev_kfree_skb_any(first->skb);
 	first->skb = NULL;
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 671913c74bf8..5915273c372f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -27,6 +27,13 @@
 #include "i40evf.h"
 #include "i40e_prototype.h"
 #include "i40evf_client.h"
+/* All i40evf tracepoints are defined by the include below, which must
+ * be included exactly once across the whole kernel with
+ * CREATE_TRACE_POINTS defined
+ */
+#define CREATE_TRACE_POINTS
+#include "i40e_trace.h"
+
 static int i40evf_setup_all_tx_resources(struct i40evf_adapter *adapter);
 static int i40evf_setup_all_rx_resources(struct i40evf_adapter *adapter);
 static int i40evf_close(struct net_device *netdev);
-- 
2.12.2
