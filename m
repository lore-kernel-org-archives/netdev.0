From: "Kevin Pedretti" <ktpedre@sandia.gov>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver (review comments
 addressed)
Date: Tue, 2 Feb 2010 18:08:27 -0700
Message-ID: <1265159307.15726.4.camel@hawkeye.sandia.gov>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sentry-three.sandia.gov ([132.175.109.17]:53259 "EHLO
	sentry-three.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184Ab0BCBeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 20:34:12 -0500
In-Reply-To: <20100202205845.GE5246@hawkeye.sandia.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] seastar - SeaStar Ethernet driver (review comments addressed)

The following patch introduces the seastar driver for the
SeaStar network interface in Cray XT3/XT4/XT5 systems. The
driver is called 'seastar'. This patch is against 2.6.32.7.

The driver uses a simple datagram interface exported by the
SeaStar network interface to encapsulate Ethernet frames
on the Cray XT high speed network. The driver has been tested
to function correctly and is in use on Cray XT4 development
systems at Sandia. 

Signed-off-by: Kevin Pedretti <ktpedre@sandia.gov>


diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/Kconfig linux-2.6.32.7/drivers/net/Kconfig
--- linux-2.6.32.7-vanilla/drivers/net/Kconfig	2010-02-02 09:10:55.000000000 -0700
+++ linux-2.6.32.7/drivers/net/Kconfig	2010-02-02 09:12:04.000000000 -0700
@@ -2760,6 +2760,17 @@ config QLGE
 	  To compile this driver as a module, choose M here: the module
 	  will be called qlge.
 
+config SEASTAR
+	tristate "Cray XT SeaStar Ethernet driver"
+	depends on PCI
+	depends on HT_IRQ
+	---help---
+	  This driver supports the Cray XT SeaStar network interface in
+	  Ethernet mode.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called seastar.
+
 source "drivers/net/sfc/Kconfig"
 
 source "drivers/net/benet/Kconfig"
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/Makefile linux-2.6.32.7/drivers/net/Makefile
--- linux-2.6.32.7-vanilla/drivers/net/Makefile	2010-02-02 09:10:55.000000000 -0700
+++ linux-2.6.32.7/drivers/net/Makefile	2010-02-02 09:12:04.000000000 -0700
@@ -149,6 +149,7 @@ obj-$(CONFIG_XILINX_LL_TEMAC) += ll_tema
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o
 obj-$(CONFIG_QLGE) += qlge/
+obj-$(CONFIG_SEASTAR) += seastar/
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/seastar/firmware.c linux-2.6.32.7/drivers/net/seastar/firmware.c
--- linux-2.6.32.7-vanilla/drivers/net/seastar/firmware.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32.7/drivers/net/seastar/firmware.c	2010-02-02 17:41:57.000000000 -0700
@@ -0,0 +1,232 @@
+/*******************************************************************************
+    SeaStar NIC Linux Driver
+
+    Copyright 2009-2010 Sandia Corporation. Under the terms of Contract
+    DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government
+    retains certain rights in this software.
+
+    Copyright (c) 2009-2010 Cray Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+
+    Contact Information:
+    Kevin Pedretti <ktpedre@sandia.gov>
+    Sandia National Laboratories
+    P.O. Box 5800
+    Albuquerque, NM 87185-1319
+
+*******************************************************************************/
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include "firmware.h"
+#include "seastar.h"
+
+/* Maps a region of host memory into the SeaStar */
+static void seastar_map_host_region(struct ss_priv *ssp, const void *addr)
+{
+	/* Round addr to the nearest 128 MB */
+	unsigned long raw_paddr = __pa(addr);
+	unsigned long paddr = raw_paddr & ~((1 << 28) - 1);
+
+	htb_map[8] = 0x8000 | ((paddr >> 28) + 0);
+	htb_map[9] = 0x8000 | ((paddr >> 28) + 1);
+
+	ssp->host_region_phys = paddr;
+}
+
+/* Converts a kernel virtual address to a SeaStar address */
+static u32 virt_to_fw(struct ss_priv *ssp, void *addr)
+{
+	unsigned long saddr;
+
+	saddr = __pa(addr) - ssp->host_region_phys;
+	saddr &= (2 << 28) - 1;
+	saddr += (8 << 28);
+
+	return saddr;
+}
+
+/* Send a command to the Seastar */
+static u32 seastar_cmd(struct ss_priv *ssp,
+		       const struct command *cmd,
+		       int wait_for_result)
+{
+	struct mailbox *mbox = ssp->mailbox;
+	unsigned int next_write;
+	u32 tail, result;
+	unsigned long long timeout;
+
+	/* Copy the command into the mailbox */
+	mbox->commandq[ssp->mailbox_cached_write] = *cmd;
+	next_write = ssp->mailbox_cached_write + 1;
+	if (next_write == COMMAND_Q_LENGTH)
+		next_write = 0;
+
+	/* Wait until it is safe to advance the write pointer */
+	timeout = 60000000000ULL; /* Empirically ~60 sec. on 2 GHz Cray XT */
+	while (next_write == ssp->mailbox_cached_read) {
+		ssp->mailbox_cached_read = mbox->commandq_read;
+		if (--timeout == 0) {
+			dev_err(&ssp->pdev->dev,
+				"waited too long sending cmd to NIC\n");
+			return (u32) -1;
+		}
+	}
+
+	/* Advance the write pointer */
+	mbox->commandq_write = next_write;
+	ssp->mailbox_cached_write = next_write;
+
+	if (!wait_for_result)
+		return 0;
+
+	/* Wait for the result to arrive */
+	tail = mbox->resultq_read;
+	timeout = 60000000000ULL; /* Empirically ~60 sec. on 2 GHz Cray XT */
+	while (tail == mbox->resultq_write) {
+		if (--timeout == 0) {
+			dev_err(&ssp->pdev->dev,
+				"waited too long getting result from NIC\n");
+			return (u32) -1;
+		}
+	}
+
+	/* Read the result */
+	result = mbox->resultq[tail];
+	mbox->resultq_read = (tail >= RESULT_Q_LENGTH - 1) ? 0 : tail + 1;
+
+	return result;
+}
+
+/* Sends a datagram transmit command to the SeaStar */
+void seastar_ip_tx_cmd(struct ss_priv *ssp,
+		       u16 nid,
+		       u16 length,
+		       u64 address,
+		       u16 pending_index)
+{
+	struct command_ip_tx tx_cmd = {
+		.op		= COMMAND_IP_TX,
+		.nid		= nid,
+		.length		= length,
+		.address	= address,
+		.pending_index	= pending_index,
+	};
+
+	seastar_cmd(ssp, (struct command *) &tx_cmd, 0);
+}
+
+/* Programs the SeaStar's HTB_BI register */
+void seastar_setup_htb_bi(u32 idr)
+{
+	/* Mask the APIC dest setup by Linux, causes problems with SeaStar */
+	idr &= 0xFFFF0000;
+
+	*htb_bi = 0xFD000000 | (idr >> 8);
+}
+
+/* Brings up the low-level Seastar hardware */
+int seastar_hw_init(struct ss_priv *ssp)
+{
+	u32 lower_memory = SEASTAR_HOST_BASE;
+	const int num_eq = 1;
+	u32 lower_pending;
+	u32 lower_eqcb;
+	u32 result;
+	struct command_init init_cmd;
+	struct command_init_eqcb eqcb_cmd;
+	struct command_mark_alive alive_cmd;
+
+	/* Read our NID from SeaStar and write it to the NIC control block */
+	niccb->local_nid = *tx_source;
+
+	printk(KERN_INFO "%s: nid %d (0x%x) version %x built %x\n",
+		__func__, niccb->local_nid, niccb->local_nid,
+		niccb->version, niccb->build_time);
+
+	/* Allocate the PPC memory */
+	lower_pending = lower_memory;
+	lower_memory += NUM_PENDINGS * FW_PENDING_SIZE;
+
+	lower_eqcb = lower_memory;
+	lower_memory = num_eq * FW_EQCB_SIZE;
+
+	/* Initialize the HTB map so that the Seastar can see our memory.
+	 * Since we are only doing upper pendings, we just use the
+	 * upper_pending_phys instead of the host_phys area. */
+	seastar_map_host_region(ssp, ssp);
+
+	ssp->mailbox			= &seastar_mailbox[0];
+	ssp->mailbox_cached_read	= ssp->mailbox->commandq_read;
+	ssp->mailbox_cached_write	= ssp->mailbox->commandq_write;
+
+	/* Attempt to send a setup command to the NIC */
+	init_cmd.op			= COMMAND_INIT;
+	init_cmd.process_index		= 1;
+	init_cmd.uid			= 0;
+	init_cmd.jid			= 0;
+
+	init_cmd.num_pendings		= NUM_PENDINGS;
+	init_cmd.pending_tx_limit	= NUM_TX_PENDINGS;
+	init_cmd.pending_table_addr	= lower_pending;
+	init_cmd.up_pending_table_addr	= virt_to_fw(ssp, ssp->pending_table);
+	init_cmd.up_pending_table_ht_addr = 0;
+
+	init_cmd.num_memds		= 0;
+	init_cmd.memd_table_addr	= 0;
+
+	init_cmd.num_eqcbs		= num_eq;
+	init_cmd.eqcb_table_addr	= lower_eqcb;
+	init_cmd.eqheap_addr		= virt_to_fw(ssp, ssp->eq);
+	init_cmd.eqheap_length		= NUM_EQ_ENTRIES * sizeof(ssp->eq[0]);
+
+	init_cmd.shdr_table_ht_addr	= 0;
+	init_cmd.result_block_addr	= 0;
+	init_cmd.smb_table_addr		= 0;
+
+	result = seastar_cmd(ssp, (struct command *) &init_cmd, 1);
+	if (result != 0) {
+		dev_err(&ssp->pdev->dev,
+			"init command failed, result=%d.\n", result);
+		return -1;
+	}
+
+	eqcb_cmd.op			= COMMAND_INIT_EQCB;
+	eqcb_cmd.eqcb_index		= 0;
+	eqcb_cmd.base			= virt_to_fw(ssp, ssp->eq);
+	eqcb_cmd.count			= NUM_EQ_ENTRIES;
+
+	result = seastar_cmd(ssp, (struct command *) &eqcb_cmd, 1);
+	if (result != 1) {
+		dev_err(&ssp->pdev->dev,
+			"init_eqcb command failed, result=%d.\n", result);
+		return -1;
+	}
+
+	alive_cmd.op			= COMMAND_MARK_ALIVE;
+	alive_cmd.index			= 1;
+
+	result = seastar_cmd(ssp, (struct command *) &alive_cmd, 1);
+	if (result != 0) {
+		dev_err(&ssp->pdev->dev,
+			"mark_alive command failed, result=%d\n", result);
+		return -1;
+	}
+
+	return 0;
+}
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/seastar/firmware.h linux-2.6.32.7/drivers/net/seastar/firmware.h
--- linux-2.6.32.7-vanilla/drivers/net/seastar/firmware.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32.7/drivers/net/seastar/firmware.h	2010-02-02 16:39:27.000000000 -0700
@@ -0,0 +1,278 @@
+/*******************************************************************************
+    SeaStar NIC Linux Driver
+
+    Copyright 2009-2010 Sandia Corporation. Under the terms of Contract
+    DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government
+    retains certain rights in this software.
+
+    Copyright (c) 2009-2010 Cray Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+
+    Contact Information:
+    Kevin Pedretti <ktpedre@sandia.gov>
+    Sandia National Laboratories
+    P.O. Box 5800
+    Albuquerque, NM 87185-1319
+
+*******************************************************************************/
+
+#ifndef _SEASTAR_FIRMWARE_H
+#define _SEASTAR_FIRMWARE_H
+
+/*
+ * Number of entries in Host -> SeaStar command queue.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+#define COMMAND_Q_LENGTH		63
+
+/*
+ * Number of entries in SeaStar -> Host result queue.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+#define RESULT_Q_LENGTH			2
+
+/*
+ * SeaStar -> Host event types.
+ *
+ * WARNING: These must match the definitions used by the
+ *          closed-source SeaStar firmware.
+ */
+#define EVENT_TX_END			125
+#define EVENT_RX			126
+#define EVENT_RX_EMPTY			127
+
+/*
+ * Host -> SeaStar command types.
+ *
+ * WARNING: These must match the definitions used by the
+ *          closed-source SeaStar firmware.
+ */
+#define COMMAND_INIT			0
+#define COMMAND_MARK_ALIVE		1
+#define COMMAND_INIT_EQCB		2
+#define COMMAND_IP_TX			13
+
+/*
+ * Number of entries in the incoming datagram buffer table.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+#define NUM_SKBS			64
+
+/*
+ * Size of the pending structure used by the SeaStar firmware.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+#define FW_PENDING_SIZE			32
+
+/*
+ * Size of the event queue control block structure used by the SeaStar firmware.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+#define FW_EQCB_SIZE			32
+
+/*
+ * SeaStar addresses of important structures in SeaStar memory.
+ *
+ * WARNING: These must match the definitions used by the
+ *          closed-source SeaStar firmware.
+ */
+#define SEASTAR_SCRATCH_BASE		0xFFFA0000
+#define SEASTAR_TX_SOURCE		0xFFE00108
+#define SEASTAR_MAILBOX_BASE		0xFFFA0000
+#define SEASTAR_SKB_BASE		0xFFFA4000
+#define SEASTAR_HOST_BASE		0xFFFA5000
+#define SEASTAR_HTB_BASE		0xFFE20000
+#define SEASTAR_HTB_BI			0xFFE20048
+#define SEASTAR_NICCB_BASE		0xFFFFE000
+
+/* Kernel virtual address where the SeaStar memory is mapped. */
+#define SEASTAR_VIRT_BASE		(0xFFFFFFFFull << 32)
+
+/* Kernel virtual address of the SeaStar's NIC control block. */
+static volatile struct niccb * const niccb
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_NICCB_BASE);
+
+/* Kernel virtual address of the SeaStar's HTB_BI register. */
+static volatile u32 * const htb_bi
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_HTB_BI);
+
+/* Kernel virtual address of the SeaStar's HyperTransport map. */
+static volatile u32 * const htb_map
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_HTB_BASE);
+
+/* Kernel virtual address of the Host <-> SeaStar mailbox. */
+static struct mailbox * const seastar_mailbox
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_MAILBOX_BASE);
+
+/* Kernel virtual address of the incoming datagram buffer table. */
+static volatile u64 * const seastar_skb
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_SKB_BASE);
+
+/* Kernel virtual address of the SeaStar TX Source register. */
+static volatile u16 * const tx_source
+	= (void *)(SEASTAR_VIRT_BASE + SEASTAR_TX_SOURCE);
+
+/*
+ * The SeaStar NIC Control Block.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct niccb {
+	u32		version;			/* 0   */
+	u8		pad[24];
+	u32		build_time;			/* 28  */
+	u8		pad2[68];
+	u32		ip_tx;				/* 100 */
+	u32		ip_tx_drop;			/* 104 */
+	u32		ip_rx;				/* 108 */
+	u32		ip_rx_drop;			/* 112 */
+	u8		pad3[52];
+	u16		local_nid;			/* 168 */
+} __attribute__((packed, aligned));
+
+/*
+ * SeaStar datagram packet wire header.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct sshdr {
+	u16		length;				/* 0 */
+	u8		lo_macs;			/* 2 */
+	u8		hdr_type;			/* 3 */
+} __attribute__((packed));
+
+/*
+ * Generic Host -> SeaStar command structure.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct command {
+	u8		op;				/* 0      */
+	u8		pad[63];			/* [1,63] */
+} __attribute__((packed));
+
+/*
+ * Initialize firmware command.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct command_init {
+	u8		op;				/* 0  */
+	u8		process_index;			/* 1  */
+	u16		pad;				/* 2  */
+	u16		pid;				/* 4  */
+	u16		jid;				/* 6  */
+	u16		num_pendings;			/* 8  */
+	u16		num_memds;			/* 10 */
+	u16		num_eqcbs;			/* 12 */
+	u16		pending_tx_limit;		/* 14 */
+	u32		pending_table_addr;		/* 16 */
+	u32		up_pending_table_addr;		/* 20 */
+	u32		up_pending_table_ht_addr;	/* 24 */
+	u32		memd_table_addr;		/* 28 */
+	u32		eqcb_table_addr;		/* 32 */
+	u32		shdr_table_ht_addr;		/* 36 */
+	u32		result_block_addr;		/* 40 */
+	u32		eqheap_addr;			/* 44 */
+	u32		eqheap_length;			/* 48 */
+	u32		smb_table_addr;			/* 52 */
+	u32		uid;				/* 56 */
+} __attribute__((packed));
+
+/*
+ * Start firmware running command.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct command_mark_alive {
+	u8		op;				/* 0 */
+	u8		index;				/* 1 */
+} __attribute__((packed));
+
+/*
+ * Initialize event queue command.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct command_init_eqcb {
+	u8		op;				/* 0 */
+	u8 		pad;				/* 1 */
+	u16		eqcb_index;			/* 2 */
+	u32		base;				/* 4 */
+	u32		count;				/* 8 */
+} __attribute__((packed));
+
+/*
+ * Send datagram command.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct command_ip_tx {
+	u8		op;				/* 0  */
+	u8		pad;				/* 1  */
+	u16		nid;				/* 2  */
+	u16		length;				/* 4  */
+	u16		pad2;				/* 6  */
+	u64		address;			/* 8  */
+	u16		pending_index;			/* 16 */
+} __attribute__((packed));
+
+/*
+ * Host <-> SeaStar Mailbox structure.
+ *
+ * WARNING: This must match the definition used by the
+ *          closed-source SeaStar firmware.
+ */
+struct mailbox {
+	volatile struct command		commandq[COMMAND_Q_LENGTH]; /* 0    */
+	volatile u32			resultq[RESULT_Q_LENGTH];   /* 4032 */
+
+	volatile u32			resultq_read;		    /* 4040 */
+	volatile u32			resultq_write;		    /* 4044 */
+	volatile u32			commandq_write;		    /* 4048 */
+	volatile u32			commandq_read;		    /* 4052 */
+} __attribute__((packed, aligned(PAGE_SIZE)));
+
+struct ss_priv;
+
+extern void seastar_ip_tx_cmd(struct ss_priv *ssp,
+			      u16 nid,
+			      u16 length,
+			      u64 address,
+			      u16 pending_index);
+
+extern void seastar_setup_htb_bi(u32 idr);
+
+extern int seastar_hw_init(struct ss_priv *ssp);
+
+#endif
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/seastar/main.c linux-2.6.32.7/drivers/net/seastar/main.c
--- linux-2.6.32.7-vanilla/drivers/net/seastar/main.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32.7/drivers/net/seastar/main.c	2010-02-02 17:52:31.000000000 -0700
@@ -0,0 +1,535 @@
+/*******************************************************************************
+    SeaStar NIC Linux Driver
+
+    Copyright 2009-2010 Sandia Corporation. Under the terms of Contract
+    DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government
+    retains certain rights in this software.
+
+    Copyright (c) 2009-2010 Cray Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+
+    Contact Information:
+    Kevin Pedretti <ktpedre@sandia.gov>
+    Sandia National Laboratories
+    P.O. Box 5800
+    Albuquerque, NM 87185-1319
+
+*******************************************************************************/
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/if_arp.h>
+#include <linux/ip.h>
+#include <linux/htirq.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
+#include <net/arp.h>
+#include "firmware.h"
+#include "seastar.h"
+
+#define SEASTAR_VERSION_STR "1.0"
+
+MODULE_DESCRIPTION("Cray SeaStar Native IP driver");
+MODULE_AUTHOR("Maintainer: Kevin Pedretti <ktpedre@sandia.gov>");
+MODULE_VERSION(SEASTAR_VERSION_STR);
+MODULE_LICENSE("GPL");
+
+static struct pending *alloc_tx_pending(struct ss_priv *ssp)
+{
+	struct pending *pending = ssp->tx_pending_free_list;
+	if (!pending)
+		return NULL;
+
+	ssp->tx_pending_free_list = pending->next;
+	pending->next = 0;
+
+	return pending;
+}
+
+static void free_tx_pending(struct ss_priv *ssp, struct pending *pending)
+{
+	pending->next		  = ssp->tx_pending_free_list;
+	ssp->tx_pending_free_list = pending;
+}
+
+static u16 pending_to_index(struct ss_priv *ssp, struct pending *pending)
+{
+	return pending - ssp->pending_table;
+}
+
+static struct pending *index_to_pending(struct ss_priv *ssp, unsigned int index)
+{
+	return &ssp->pending_table[index];
+}
+
+static void refill_skb(struct net_device *netdev, int i)
+{
+	struct ss_priv *ssp = netdev_priv(netdev);
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(netdev->mtu + SKB_PAD);
+	if (!skb) {
+		dev_err(&ssp->pdev->dev, "dev_alloc_skb() failed.\n");
+		return;
+	}
+
+	skb->dev = netdev;
+	skb_reserve(skb, SKB_PAD);
+
+	/* Push it down to the PPC as a quadbyte address */
+	ssp->skb_table_phys[i] = virt_to_phys(skb->data) >> 2;
+	ssp->skb_table_virt[i] = skb;
+}
+
+static int ss_open(struct net_device *netdev)
+{
+	struct ss_priv *ssp = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < NUM_SKBS; i++) {
+		ssp->skb_table_phys[i] = 0;
+		ssp->skb_table_virt[i] = 0;
+		refill_skb(netdev, i);
+	}
+
+	netif_start_queue(netdev);
+
+	return 0;
+}
+
+static int eth2ss(struct ss_priv *ssp, struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr;
+	struct sshdr *sshdr;
+	u8 source_lo_mac, dest_lo_mac;
+	u32 qb_len;
+
+	/* Read the "low" bytes of the source and destination MAC addresses */
+	ethhdr = (struct ethhdr *)skb->data;
+	source_lo_mac = ethhdr->h_source[5];
+	dest_lo_mac   = ethhdr->h_dest[5];
+
+	/* Drop anything not IPv4 */
+	if (ethhdr->h_proto != ntohs(ETH_P_IP)) {
+		dev_err(&ssp->pdev->dev, "squashing non-IPv4 packet.");
+		return -1;
+	}
+
+	/* Squash broadcast packets, SeaStar doesn't support broadcast */
+	if (dest_lo_mac == 0xFF) {
+		dev_err(&ssp->pdev->dev, "squashing broadcast packet.");
+		return -1;
+	}
+
+	/* We only support 4 bits of virtual hosts per physical node */
+	if ((source_lo_mac & ~0xF) || (dest_lo_mac & ~0xF)) {
+		dev_err(&ssp->pdev->dev, "lo_mac out of range.");
+		return -1;
+	}
+
+	/* Move ahead to allow sshdr to be filled in overtop of the ethhdr */
+	sshdr = (struct sshdr *) skb_pull(skb,
+			(unsigned int)(ETH_HLEN - sizeof(struct sshdr)));
+
+	/* The length in quad bytes, rounded up to the nearest quad byte.
+	 * SS header is already counted in skb->len as per skb_pull() above.
+	 * The -1 avoids transmitting the CRC on the wire, which is
+	 * unnecessary since underlying network is already reliable
+	 * (i.e., it has its own CRC, making the Ethernet CRC redundant) */
+	qb_len = (ROUNDUP4(skb->len) >> 2) - 1;
+
+	/* Build the SeaStar header */
+	sshdr->length   = qb_len;
+	sshdr->lo_macs  = (source_lo_mac << 4) | dest_lo_mac;
+	sshdr->hdr_type = (2 << 5); /* Datagram 2, type 0 == IP */
+
+	return 0;
+}
+
+static int ss2eth(struct sk_buff *skb)
+{
+	struct sshdr *sshdr;
+	struct ethhdr *ethhdr;
+	u8 source_lo_mac, dest_lo_mac;
+
+	/* Read the "low" bytes of the source and destination MAC addresses */
+	sshdr = (struct sshdr *)skb->data;
+	source_lo_mac = (sshdr->lo_macs >> 4);
+	dest_lo_mac    = sshdr->lo_macs & 0xF;
+
+	/* Make room for the rest of the ethernet header and zero it */
+	ethhdr = (struct ethhdr *) skb_push(skb,
+			(unsigned int)(ETH_HLEN - sizeof(struct sshdr)));
+	memset(ethhdr, 0x00, ETH_HLEN);
+
+	/* h_proto and h_dest[] are available.  Just 0xff h_source[2-5] */
+	ethhdr->h_proto = htons(ETH_P_IP);
+
+	/* We're assuming the source MAC is the same as the local
+	 * host's MAC in order to support loopback in promiscous mode */
+	memcpy(&ethhdr->h_source, &skb->dev->dev_addr, ETH_ALEN);
+	memcpy(&ethhdr->h_dest, &skb->dev->dev_addr, ETH_ALEN);
+	ethhdr->h_source[5] = source_lo_mac;
+	ethhdr->h_dest[5]   = dest_lo_mac;
+
+	return 0;
+}
+
+static int ss_tx(struct sk_buff *skb, struct net_device *netdev)
+{
+	unsigned long flags;
+	struct ss_priv *ssp = netdev_priv(netdev);
+	struct ethhdr *eh = (struct ethhdr *)skb->data;
+	struct sshdr *sshdr;
+	u32 dest_nid = ntohl(*(u32 *)eh->h_dest);
+	struct pending *pending = NULL;
+	void *msg;
+
+	spin_lock_irqsave(&ssp->lock, flags);
+
+	if (netif_queue_stopped(netdev)) {
+		spin_unlock_irqrestore(&ssp->lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Convert the SKB from an ethernet frame to a seastar frame */
+	if (eth2ss(ssp, skb)) {
+		netdev->stats.tx_errors++;
+		goto drop;
+	}
+
+	sshdr = (struct sshdr *)skb->data;
+
+	/* Get a tx_pending so that we can track the completion of this SKB */
+	pending = alloc_tx_pending(ssp);
+	if (!pending) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&ssp->lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Stash skb away in the pending, will be needed in ss_tx_end() */
+	pending->skb = skb;
+
+	/* Make sure buffer we pass to SeaStar is quad-byte aligned */
+	if (((unsigned long)skb->data & 0x3) == 0) {
+		pending->bounce = NULL;
+		msg = skb->data;
+	} else {
+		/* Need to use bounce buffer to get quad-byte alignment */
+		pending->bounce = kmalloc(skb->len, GFP_KERNEL);
+		if (!pending->bounce) {
+			dev_err(&ssp->pdev->dev, "dev_alloc_skb() failed.\n");
+			goto drop;
+		}
+		memcpy(pending->bounce, skb->data, skb->len);
+		msg = pending->bounce;
+	}
+
+	seastar_ip_tx_cmd(ssp, dest_nid, sshdr->length, virt_to_phys(msg) >> 2,
+			  pending_to_index(ssp, pending));
+
+	netdev->stats.tx_packets++;
+	netdev->stats.tx_bytes += skb->len;
+
+	spin_unlock_irqrestore(&ssp->lock, flags);
+	return 0;
+
+drop:
+	dev_kfree_skb_any(skb);
+	if (pending)
+		free_tx_pending(ssp, pending);
+	spin_unlock_irqrestore(&ssp->lock, flags);
+	return 0;
+}
+
+static void ss_tx_end(struct net_device *netdev, unsigned int pending_index)
+{
+	unsigned long flags;
+	struct ss_priv *ssp = netdev_priv(netdev);
+	struct pending *pending = index_to_pending(ssp, pending_index);
+
+	spin_lock_irqsave(&ssp->lock, flags);
+
+	if (pending->skb)
+		dev_kfree_skb_any(pending->skb);
+
+	kfree(pending->bounce);
+
+	free_tx_pending(ssp, pending);
+
+	if (netif_queue_stopped(netdev))
+		netif_wake_queue(netdev);
+
+	spin_unlock_irqrestore(&ssp->lock, flags);
+}
+
+static void ss_rx_skb(struct net_device *netdev, struct sk_buff *skb)
+{
+	struct sshdr *sshdr = (struct sshdr *)skb_tail_pointer(skb);
+
+	const u32 qb_len = sshdr->length;
+	const u32 len    = (qb_len + 1) << 2;
+
+	skb_put(skb, len);
+	ss2eth(skb);
+
+	skb->protocol  = htons(ETH_P_IP);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb_set_mac_header(skb, 0);
+
+	/* Skip past the ethernet header we just built */
+	skb_pull(skb, ETH_HLEN);
+
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes += len;
+
+	netif_rx(skb);
+}
+
+static void ss_rx(struct net_device *netdev, unsigned int skb_index)
+{
+	struct ss_priv *ssp = netdev_priv(netdev);
+	struct sk_buff *skb = ssp->skb_table_virt[skb_index];
+
+	ssp->skb_table_virt[skb_index] = 0;
+	ss_rx_skb(netdev, skb);
+
+	refill_skb(netdev, skb_index);
+}
+
+static int ss_header_create(struct sk_buff *skb, struct net_device *netdev,
+			    unsigned short type, const void *daddr,
+			    const void *saddr, unsigned int length)
+{
+	struct ethhdr *eh;
+
+	/* Make room for the ethernet header and zero it */
+	eh = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+	memset(eh, 0, ETH_HLEN);
+
+	/* Although we can only do IPv4, build other packets correctly for
+	 * now and drop it in the ndo_start_xmit hook.  This way the fact that
+	 * these packets are being generated is not invisible. */
+	eh->h_proto = htons(type);
+
+	/* Set the source hardware address */
+	if (!saddr)
+		saddr = netdev->dev_addr;
+	memcpy(eh->h_source, saddr, ETH_ALEN);
+
+	/* Set the destination hardware address */
+	if (daddr) {
+		memcpy(eh->h_dest, daddr, ETH_ALEN);
+		return ETH_HLEN;
+	}
+
+	/* No destination address supplied !?! */
+	return -ETH_HLEN;
+}
+
+static u32 next_event(struct ss_priv *ssp)
+{
+	u32 ev = ssp->eq[ssp->eq_read];
+	if (!ev)
+		return 0;
+
+	ssp->eq[ssp->eq_read] = 0;
+	ssp->eq_read = (ssp->eq_read + 1) % NUM_EQ_ENTRIES;
+
+	return ev;
+}
+
+static void ss_rx_refill(struct net_device *netdev)
+{
+	struct ss_priv *ssp = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < NUM_SKBS; i++) {
+		if (ssp->skb_table_virt[i] == 0)
+			refill_skb(netdev, i);
+	}
+}
+
+static irqreturn_t ss_interrupt(int irq, void *dev)
+{
+	struct net_device *netdev = (struct net_device *)dev;
+	struct ss_priv *ssp = netdev_priv(netdev);
+	u32 ev;
+	unsigned int type, index;
+
+	while (1) {
+		ev = next_event(ssp);
+		if (!ev)
+			break;
+
+		type  = (ev >> 16) & 0xFFFF;
+		index = (ev >>  0) & 0xFFFF;
+
+		switch (type) {
+
+		case EVENT_TX_END:
+			ss_tx_end(netdev, index);
+			break;
+
+		case EVENT_RX:
+			ss_rx(netdev, index);
+			break;
+
+		case EVENT_RX_EMPTY:
+			ss_rx_refill(netdev);
+			break;
+
+		default:
+			dev_err(&ssp->pdev->dev,
+				"unknown event type (type=%u, index=%u).\n",
+				type, index);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static const struct net_device_ops ss_netdev_ops = {
+	.ndo_open		= ss_open,
+	.ndo_start_xmit		= ss_tx,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static const struct header_ops ss_header_ops = {
+	.create			= ss_header_create,
+};
+
+static void ss_ht_irq_update(struct pci_dev *dev, int irq,
+			     struct ht_irq_msg *msg)
+{
+	seastar_setup_htb_bi(msg->address_lo);
+}
+
+static int __devinit ss_probe(struct pci_dev *pdev,
+			      const struct pci_device_id *id)
+{
+	struct net_device *netdev;
+	struct ss_priv *ssp;
+	int i, irq, err = 0;
+
+	err = pci_enable_device(pdev);
+	if (err != 0) {
+		dev_err(&pdev->dev, "Could not enable PCI device.\n");
+		return -ENODEV;
+	}
+
+	netdev = alloc_etherdev(sizeof(*ssp));
+	if (netdev == NULL) {
+		dev_err(&pdev->dev, "Could not allocate ethernet device.\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	strcpy(netdev->name, "ss");
+	netdev->netdev_ops	= &ss_netdev_ops;
+	netdev->header_ops	= &ss_header_ops;
+	netdev->mtu		= 16000;
+	netdev->flags		= IFF_NOARP;
+
+	/* Setup private state */
+	ssp = netdev_priv(netdev);
+
+	spin_lock_init(&ssp->lock);
+	ssp->skb_table_phys	= seastar_skb;
+	ssp->eq_read		= 0;
+	ssp->pdev		= pdev;
+
+	/* Build the TX pending free list */
+	ssp->tx_pending_free_list = 0;
+	for (i = 0; i < NUM_TX_PENDINGS; i++)
+		free_tx_pending(ssp, index_to_pending(ssp, i));
+
+	irq = __ht_create_irq(pdev, 0, ss_ht_irq_update);
+	if (irq < 0) {
+		dev_err(&pdev->dev, "__ht_create_irq() failed, err=%d.\n", err);
+		goto err_out;
+	}
+
+	err = request_irq(irq, ss_interrupt, IRQF_NOBALANCING,
+			  "seastar", netdev);
+	if (err != 0) {
+		dev_err(&pdev->dev, "request_irq() failed, err=%d.\n", err);
+		goto err_out;
+	}
+
+	err = seastar_hw_init(netdev_priv(netdev));
+	if (err != 0) {
+		dev_err(&pdev->dev, "seastar_hw_init() failed, err=%d.\n", err);
+		goto err_out;
+	}
+
+	err = register_netdev(netdev);
+	if (err != 0) {
+		dev_err(&pdev->dev, "register_netdev() failed, err=%d.\n", err);
+		goto err_out;
+	}
+
+	return 0;
+
+err_out:
+	free_netdev(netdev);
+	return err;
+}
+
+static void __devexit ss_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	unregister_netdev(netdev);
+	free_netdev(netdev);
+	pci_disable_device(pdev);
+}
+
+#define PCI_VENDOR_ID_CRAY		0x17DB
+#define PCI_DEVICE_ID_SEASTAR		0x0101
+
+static struct pci_device_id ss_pci_tbl[] = {
+	{PCI_DEVICE(PCI_VENDOR_ID_CRAY, PCI_DEVICE_ID_SEASTAR)},
+	{0},
+};
+
+static struct pci_driver ss_driver = {
+	.name = "seastar",
+	.probe = ss_probe,
+	.remove = __devexit_p(ss_remove),
+	.id_table = ss_pci_tbl,
+};
+
+static __init int ss_init_module(void)
+{
+	printk(KERN_INFO "%s: module loaded (version %s)\n",
+	       ss_driver.name, SEASTAR_VERSION_STR);
+
+	return pci_register_driver(&ss_driver);
+}
+
+static __exit void ss_cleanup_module(void)
+{
+	pci_unregister_driver(&ss_driver);
+}
+
+module_init(ss_init_module);
+module_exit(ss_cleanup_module);
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/seastar/Makefile linux-2.6.32.7/drivers/net/seastar/Makefile
--- linux-2.6.32.7-vanilla/drivers/net/seastar/Makefile	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32.7/drivers/net/seastar/Makefile	2010-02-02 09:12:04.000000000 -0700
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SEASTAR) += seastar.o
+
+seastar-y := main.o firmware.o
diff -uprN -X linux-2.6.32.7-vanilla/Documentation/dontdiff linux-2.6.32.7-vanilla/drivers/net/seastar/seastar.h linux-2.6.32.7/drivers/net/seastar/seastar.h
--- linux-2.6.32.7-vanilla/drivers/net/seastar/seastar.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32.7/drivers/net/seastar/seastar.h	2010-02-02 16:45:18.000000000 -0700
@@ -0,0 +1,86 @@
+/*******************************************************************************
+    SeaStar NIC Linux Driver
+
+    Copyright 2009-2010 Sandia Corporation. Under the terms of Contract
+    DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government
+    retains certain rights in this software.
+
+    Copyright (c) 2009-2010 Cray Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+
+    Contact Information:
+    Kevin Pedretti <ktpedre@sandia.gov>
+    Sandia National Laboratories
+    P.O. Box 5800
+    Albuquerque, NM 87185-1319
+
+*******************************************************************************/
+
+#ifndef _SEASTAR_H
+#define _SEASTAR_H
+
+/* Rounds up to the nearest quadbyte */
+#define ROUNDUP4(val)		((val + (4-1)) & ~(4-1))
+
+/* SeaStar datagram packet maximum transfer unit size in bytes */
+#define SEASTAR_MTU		8192
+
+/* Number of transmit and receive pending structures */
+#define NUM_TX_PENDINGS		64
+#define NUM_RX_PENDINGS		64
+#define NUM_PENDINGS		(NUM_TX_PENDINGS + NUM_RX_PENDINGS)
+
+/* Number of entries in the SeaStar -> Host event queue */
+#define NUM_EQ_ENTRIES		1024
+
+/* When allocating an SKB, allocate this many bytes extra */
+#define SKB_PAD			(16 - sizeof(struct sshdr))
+
+/*
+ * Pending structure.
+ * One of these is used to track each in progress transmit.
+ */
+struct pending {
+	struct sk_buff		*skb;
+	struct pending		*next;
+	void			*bounce;
+};
+
+/*
+ * SeaStar driver private data.
+ */
+struct ss_priv {
+	spinlock_t		lock;
+
+	unsigned long		host_region_phys;
+
+	volatile u64		*skb_table_phys;
+	struct sk_buff		*skb_table_virt[NUM_SKBS];
+
+	struct pending		pending_table[NUM_PENDINGS];
+	struct pending		*tx_pending_free_list;
+
+	u32			eq[NUM_EQ_ENTRIES];
+	unsigned int		eq_read;
+
+	struct mailbox		*mailbox;
+	unsigned int		mailbox_cached_read;
+	unsigned int		mailbox_cached_write;
+
+	struct pci_dev		*pdev;
+};
+
+#endif



