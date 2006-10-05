From: Misha Tomushev <misha@fabric7.com> (by way of Misha Tomushev
	<misha@fabric7.com>)
Subject: [PATCH 8/10] VIOC: New Network Device Driver
Date: Thu, 5 Oct 2006 11:55:16 -0700
Message-ID: <200610051155.16533.misha@fabric7.com>
Reply-To: misha@fabric7.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext-103.mv.fabric7.com ([68.120.107.103]:59611 "EHLO
	corp.fabric7.com") by vger.kernel.org with ESMTP id S1750739AbWJETF3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 15:05:29 -0400
To: NETDEV Linux <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding VIOC device driver. Device driver provisioning settings.

Signed-off-by: Misha Tomushev  <misha@fabric7.com>

diff -uprN linux-2.6.17/drivers/net/vioc/vioc_provision.c
linux-2.6.17.vioc/drivers/net/vioc/vioc_provision.c
--- linux-2.6.17/drivers/net/vioc/vioc_provision.c	1969-12-31
16:00:00.000000000 -0800
+++ linux-2.6.17.vioc/drivers/net/vioc/vioc_provision.c	2006-10-03
12:17:03.000000000 -0700
@@ -0,0 +1,226 @@
+/*
+ * Fabric7 Systems Virtual IO Controller Driver
+ * Copyright (C) 2003-2005 Fabric7 Systems.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
+ * USA
+ *
+ * http://www.fabric7.com/
+ *
+ * Maintainers:
+ *    driver-support@fabric7.com
+ *
+ *
+ */
+#include "f7/vnic_hw_registers.h"
+#include "vioc_vnic.h"
+
+/*
+ * Standard parameters for ring provisioning.  Single TxQ per VNIC.
+ * Two RX sets per VIOC, with 3 RxDs, 1 RxC, 1 Rx interrupt per set.
+ */
+
+#define TXQ_ENTRIES                    1024
+#define TX_INTR_ON_EMPTY       false
+
+/* RXDQ sizes (entry counts) must be multiples of this */
+#define        RXDQ_ALIGN              VIOC_RXD_BATCH_BITS
+#define        RXDQ_ENTRIES    1024
+
+#define        RXDQ_JUMBO_ENTRIES              ALIGN(RXDQ_ENTRIES,
RXDQ_ALIGN)
+#define        RXDQ_STD_ENTRIES                ALIGN(RXDQ_ENTRIES,
RXDQ_ALIGN)
+#define        RXDQ_SMALL_ENTRIES              ALIGN(RXDQ_ENTRIES,
RXDQ_ALIGN)
+#define        RXDQ_EXTRA_ENTRIES              ALIGN(RXDQ_ENTRIES,
RXDQ_ALIGN)
+
+#define        RXC_ENTRIES
(RXDQ_JUMBO_ENTRIES+RXDQ_STD_ENTRIES+RXDQ_SMALL_ENTRIES+RXDQ_EXTRA_ENTRIES)
+
+#define        RXDQ_JUMBO_BUFSIZE      (VNIC_MAX_MTU+ETH_HLEN+F7PF_HLEN_STD)
+#define        RXDQ_STD_BUFSIZE        (VNIC_STD_MTU+ETH_HLEN+F7PF_HLEN_STD)
+#define        RXDQ_SMALL_BUFSIZE      (256+ETH_HLEN+F7PF_HLEN_STD)
+
+#define        RXDQ_JUMBO_ALLOC_BUFSIZE        ALIGN(RXDQ_JUMBO_BUFSIZE,64)
+#define        RXDQ_STD_ALLOC_BUFSIZE  ALIGN(RXDQ_STD_BUFSIZE,64)
+#define        RXDQ_SMALL_ALLOC_BUFSIZE        ALIGN(RXDQ_SMALL_BUFSIZE,64)
+
+/*
+ Every entry in this structure is defined as follows:
+
+struct vnic_prov_def {
+       struct rxd_q_prov rxd_ring[4];
+       u32  tx_entries;        Size of Tx Ring
+       u32  rxc_entries;   Size of Rx Completion Ring
+       u8      rxc_id;                 Rx Completion queue ID
+       u8      rxc_intr_id;    INTR servicing the above Rx Completion queue
+};
+
+The 4 rxd_q_prov structures of rxd_ring[] array define  Rx queues per VNIC.
+struct rxd_q_prov {
+       u32        buf_size;    Buffer size
+       u32        entries;             Size of the queue
+       u8         id;                  Queue id/
+       u8         state;               Provisioning state 1-ena, 0-dis
+};
+
+*/
+
+struct vnic_prov_def vnic_set_0 = {
+	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
+	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
+	.rxd_ring[0].id = 0,
+	.rxd_ring[0].state = 1,
+	.rxd_ring[1].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[1].entries = RXDQ_STD_ENTRIES,
+	.rxd_ring[1].id = 1,
+	.rxd_ring[1].state = 1,
+	.rxd_ring[2].buf_size = RXDQ_JUMBO_ALLOC_BUFSIZE,
+	.rxd_ring[2].entries = RXDQ_JUMBO_ENTRIES,
+	.rxd_ring[2].id = 2,
+	.rxd_ring[2].state = 1,
+	.tx_entries = TXQ_ENTRIES,.rxc_entries = RXC_ENTRIES,.rxc_id =
+	    0,.rxc_intr_id = 0
+};
+
+struct vnic_prov_def vnic_set_1 = {
+	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
+	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
+	.rxd_ring[0].id = 4,
+	.rxd_ring[0].state = 1,
+	.rxd_ring[1].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[1].entries = RXDQ_STD_ENTRIES,
+	.rxd_ring[1].id = 5,
+	.rxd_ring[1].state = 1,
+	.rxd_ring[2].buf_size = RXDQ_JUMBO_ALLOC_BUFSIZE,
+	.rxd_ring[2].entries = RXDQ_JUMBO_ENTRIES,
+	.rxd_ring[2].id = 6,
+	.rxd_ring[2].state = 1,
+	.tx_entries = TXQ_ENTRIES,.rxc_entries = RXC_ENTRIES,.rxc_id =
+	    1,.rxc_intr_id = 1
+};
+
+struct vnic_prov_def vnic_set_2 = {
+	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
+	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
+	.rxd_ring[0].id = 8,
+	.rxd_ring[0].state = 1,
+	.rxd_ring[1].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[1].entries = RXDQ_STD_ENTRIES,
+	.rxd_ring[1].id = 9,
+	.rxd_ring[1].state = 1,
+	.rxd_ring[2].buf_size = RXDQ_JUMBO_ALLOC_BUFSIZE,
+	.rxd_ring[2].entries = RXDQ_JUMBO_ENTRIES,
+	.rxd_ring[2].id = 10,
+	.rxd_ring[2].state = 1,
+	.tx_entries = TXQ_ENTRIES,.rxc_entries = RXC_ENTRIES,.rxc_id =
+	    2,.rxc_intr_id = 2
+};
+
+struct vnic_prov_def vnic_set_3 = {
+	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
+	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
+	.rxd_ring[0].id = 12,
+	.rxd_ring[0].state = 1,
+	.rxd_ring[1].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[1].entries = RXDQ_STD_ENTRIES,
+	.rxd_ring[1].id = 13,
+	.rxd_ring[1].state = 1,
+	.rxd_ring[2].buf_size = RXDQ_JUMBO_ALLOC_BUFSIZE,
+	.rxd_ring[2].entries = RXDQ_JUMBO_ENTRIES,
+	.rxd_ring[2].id = 15,
+	.rxd_ring[2].state = 1,
+	.tx_entries = TXQ_ENTRIES,.rxc_entries = RXC_ENTRIES,.rxc_id =
+	    3,.rxc_intr_id = 3
+};
+
+struct vnic_prov_def vnic_set_sim = {
+	.rxd_ring[0].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[0].entries = 256,
+	.rxd_ring[0].id = 0,
+	.rxd_ring[0].state = 1,
+	.rxd_ring[1].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[1].entries = 256,
+	.rxd_ring[1].id = 1,
+	.rxd_ring[1].state = 1,
+	.rxd_ring[2].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
+	.rxd_ring[2].entries = 256,
+	.rxd_ring[2].id = 2,
+	.rxd_ring[2].state = 1,
+	.tx_entries = 256,.rxc_entries = 256 * 3,.rxc_id = 0,.rxc_intr_id = 0
+};
+
+struct vnic_prov_def *vnic_prov_pmm_pin_irq[VIOC_MAX_VNICS] = {
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_0,
+	&vnic_set_1
+};
+
+struct vnic_prov_def *vnic_prov_pmm_msi_x[VIOC_MAX_VNICS] = {
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_2,
+	&vnic_set_3,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_2,
+	&vnic_set_3,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_2,
+	&vnic_set_3,
+	&vnic_set_0,
+	&vnic_set_1,
+	&vnic_set_2,
+	&vnic_set_3
+};
+
+struct vnic_prov_def *vnic_prov_sim[VIOC_MAX_VNICS] = {
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim,
+	&vnic_set_sim
+};
+
+struct vnic_prov_def **vioc_prov_get(int num_rx_irq)
+{
+	if (num_rx_irq == 16)
+		return (struct vnic_prov_def **)&vnic_prov_pmm_msi_x;
+	else
+		return (struct vnic_prov_def **)&vnic_prov_pmm_pin_irq;
+
+}


--
Misha Tomushev
misha@fabric7.com

