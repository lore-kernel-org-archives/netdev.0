From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 24/27] HFI: hfi_ip network driver
Date: Thu, 21 Apr 2011 17:38:54 -0400
Message-ID: <1303421937-2325-25-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:59328 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143Ab1DUVj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:26 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLK1w7015538
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:20:01 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdDap2408494
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCJ7012792
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

It is a separate binary because it is not strictly necessary to use the HFI.
This patch includes module load/unload and the window open/setup with the
hfi device driver.

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/Kconfig              |    1 +
 drivers/net/hfi/Makefile         |    1 +
 drivers/net/hfi/ip/Kconfig       |    9 +
 drivers/net/hfi/ip/Makefile      |    6 +
 drivers/net/hfi/ip/hf_proto.h    |   48 +++
 drivers/net/hfi/ip/hfi_ip_main.c |  613 ++++++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfi_ip.h       |  148 +++++++++
 include/linux/if_arp.h           |    1 +
 8 files changed, 827 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/hfi/ip/Kconfig
 create mode 100644 drivers/net/hfi/ip/Makefile
 create mode 100644 drivers/net/hfi/ip/hf_proto.h
 create mode 100644 drivers/net/hfi/ip/hfi_ip_main.c
 create mode 100644 include/linux/hfi/hfi_ip.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1abbfd9..ddae700 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3437,5 +3437,6 @@ config VMXNET3
 	  module will be called vmxnet3.
 
 source "drivers/net/hfi/core/Kconfig"
+source "drivers/net/hfi/ip/Kconfig"
 
 endif # NETDEVICES
diff --git a/drivers/net/hfi/Makefile b/drivers/net/hfi/Makefile
index 0440cbe..768f27c 100644
--- a/drivers/net/hfi/Makefile
+++ b/drivers/net/hfi/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_HFI)                += core/
+obj-$(CONFIG_HFI_IP)             += ip/
diff --git a/drivers/net/hfi/ip/Kconfig b/drivers/net/hfi/ip/Kconfig
new file mode 100644
index 0000000..422782a
--- /dev/null
+++ b/drivers/net/hfi/ip/Kconfig
@@ -0,0 +1,9 @@
+config HFI_IP
+	tristate "IP-over-HFI"
+	depends on NETDEVICES && INET && HFI
+	---help---
+	Support for IP over HFI. It transports IP
+	packets over HFI.
+
+	To compile the driver as a module, choose M here. The module
+	will be called hfi_ip.
diff --git a/drivers/net/hfi/ip/Makefile b/drivers/net/hfi/ip/Makefile
new file mode 100644
index 0000000..90c7dea
--- /dev/null
+++ b/drivers/net/hfi/ip/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the HF IP interface for IBM eServer System p
+#
+obj-$(CONFIG_HFI_IP) += hfi_ip.o
+
+hfi_ip-objs :=	hfi_ip_main.o
diff --git a/drivers/net/hfi/ip/hf_proto.h b/drivers/net/hfi/ip/hf_proto.h
new file mode 100644
index 0000000..b4133b7
--- /dev/null
+++ b/drivers/net/hfi/ip/hf_proto.h
@@ -0,0 +1,48 @@
+/*
+ * hf_proto.h
+ *
+ * HF IP driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HF_PROTO_H_
+#define _HF_PROTO_H_
+
+extern int hfidd_open_window_func(struct hfidd_acs *p_acs,
+		u32 is_userspace,
+		struct hfi_client_info *user_p,
+		struct hfi_client_info *out_p);
+extern int hfidd_close_window_func(struct hfidd_acs *p_acs,
+		u32 is_userspace,
+		struct hfi_window_info *user_p);
+extern int hfidd_callback_register(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *arg);
+extern int hfidd_callback_unregister(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *arg);
+
+#endif
diff --git a/drivers/net/hfi/ip/hfi_ip_main.c b/drivers/net/hfi/ip/hfi_ip_main.c
new file mode 100644
index 0000000..0c1ebd7
--- /dev/null
+++ b/drivers/net/hfi/ip/hfi_ip_main.c
@@ -0,0 +1,613 @@
+/*
+ * hfi_ip_main.c
+ *
+ * HF IP driver for IBM System p
+ *
+ *  Authors:
+ *	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *	William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *	Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *	Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *	Jian Xiao <jian@linux.vnet.ibm.com>
+ *	Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *	Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/hfi/hfi_ip.h>
+#include "hf_proto.h"
+
+MODULE_AUTHOR("James Dykman <dykmanj@linux.vnet.ibm.com>, "
+		"Piyush Chaudhary <piyushc@linux.vnet.ibm.com>");
+MODULE_DESCRIPTION("IP driver v" HF_DRV_VERSION " (" HF_DRV_RELDATE ")"
+		" for IBM eServer HFI for System p");
+MODULE_VERSION(HF_DRV_VERSION);
+MODULE_LICENSE("GPL v2");
+
+struct hf_global_info		hf_ginfo;
+
+static const u8 hfi_bcast_addr[] = {
+	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+};
+
+static void hf_free_tx_resource(struct hf_if *net_if)
+{
+	int	i;
+
+	if (net_if->tx_skb) {
+		for (i = 0; i <= net_if->tx_fifo.emax; i++) {
+			if (net_if->tx_skb[i])
+				dev_kfree_skb_any(net_if->tx_skb[i]);
+		}
+
+		free_pages((unsigned long)(net_if->tx_skb),
+				get_order((net_if->tx_fifo.emax + 1) *
+				sizeof(struct sk_buff *)));
+		net_if->tx_skb = 0;
+	}
+	if (net_if->tx_fifo.addr) {
+		free_pages((unsigned long)(net_if->tx_fifo.addr),
+				get_order(net_if->tx_fifo.size + PAGE_SIZE_4K));
+		net_if->tx_fifo.addr = 0;
+	}
+}
+
+static int hf_alloc_tx_resource(struct hf_net *net)
+{
+	struct hf_if *net_if = &(net->hfif);
+	int	i;
+
+	net_if->tx_fifo.size = HF_SFIFO_SIZE;
+	net_if->tx_fifo.head = 0;
+	net_if->tx_fifo.tail = 0;
+	net_if->tx_fifo.emax = HF_SFIFO_SLOTS - 1;
+	atomic_set(&net_if->tx_fifo.avail, HF_SFIFO_SLOTS - 1);
+
+	net_if->tx_fifo.addr =
+		(void *)__get_free_pages(GFP_KERNEL,
+				get_order(net_if->tx_fifo.size + PAGE_SIZE_4K));
+
+	if (net_if->tx_fifo.addr == 0) {
+		netdev_err(net->netdev, "%s: hf_alloc_tx_resource: "
+			"tx_fifo fail, size=0x%x\n",
+			net_if->name, net_if->tx_fifo.size);
+
+		return -ENOMEM;
+	}
+	memset(net_if->tx_fifo.addr, 0, net_if->tx_fifo.size + PAGE_SIZE_4K);
+
+	/* Sfifo finish vector locates at very next page of sfifo */
+	net_if->sfifo_finishvec = net_if->tx_fifo.addr + net_if->tx_fifo.size;
+	net_if->sfifo_fv_polarity = 0;
+	net_if->sfifo_slots_per_blk = HF_SFIFO_SLOTS / HF_FV_BIT_CNT;
+
+	/* allocate array to hold the tx skbs */
+	net_if->tx_skb =
+		(struct sk_buff **)__get_free_pages(GFP_KERNEL,
+		get_order((net_if->tx_fifo.emax + 1) *
+		sizeof(struct sk_buff *)));
+
+	if (net_if->tx_skb == 0) {
+		netdev_err(net->netdev,
+			"%s: hf_alloc_tx_resource: tx_skb failed\n",
+			net_if->name);
+
+		goto err_out;
+	}
+
+	for (i = 0; i <= net_if->tx_fifo.emax; i++)
+		net_if->tx_skb[i] = NULL;
+
+	return 0;
+
+err_out:
+	hf_free_tx_resource(net_if);
+
+	return -ENOMEM;
+}
+
+static void hf_free_rx_resource(struct hf_if *net_if)
+{
+	if (net_if->rx_fifo.addr) {
+		free_pages((unsigned long)(net_if->rx_fifo.addr),
+				get_order(net_if->rx_fifo.size));
+		net_if->rx_fifo.addr = 0;
+	}
+}
+
+static int hf_alloc_rx_resource(struct hf_net *net)
+{
+	struct hf_if *net_if = &(net->hfif);
+
+	net_if->rx_fifo.size = HF_RFIFO_SIZE;
+	net_if->rx_fifo.head = 0;
+	net_if->rx_fifo.tail = 0;
+	net_if->rx_fifo.emax = HF_RFIFO_SLOTS - 1;
+
+	net_if->rx_fifo.addr =
+		(void *)__get_free_pages(GFP_KERNEL,
+				get_order(net_if->rx_fifo.size));
+
+	if (net_if->rx_fifo.addr == 0) {
+		netdev_err(net->netdev,
+			"%s: hf_alloc_rx_resource: fail, size=0x%x\n",
+			net_if->name, net_if->rx_fifo.size);
+
+		return -ENOMEM;
+	}
+
+	memset(net_if->rx_fifo.addr, 0, net_if->rx_fifo.size);
+
+	return 0;
+}
+
+static void hf_free_resource(struct hf_if *net_if)
+{
+	hf_free_rx_resource(net_if);
+
+	hf_free_tx_resource(net_if);
+}
+
+static int hf_alloc_resource(struct hf_net *net)
+{
+	int			rc;
+	struct hf_if		*net_if = &(net->hfif);
+
+	rc = hf_alloc_tx_resource(net);
+	if (rc)
+		goto alloc_resource_err0;
+
+	rc = hf_alloc_rx_resource(net);
+	if (rc)
+		goto alloc_resource_err1;
+
+	return 0;
+
+alloc_resource_err1:
+	hf_free_tx_resource(net_if);
+alloc_resource_err0:
+	return rc;
+}
+
+static int hf_close_ip_window(struct hf_net *net, struct hfidd_acs *p_acs)
+{
+	struct hf_if *net_if = &(net->hfif);
+	int		rc;
+
+	if (net_if->doorbell) {
+		iounmap(net_if->doorbell);
+		net_if->doorbell = NULL;
+	}
+
+	/* Fill in the request structure */
+	net_if->client.hdr.req		   = HFIDD_REQ_CLOSE_WINDOW;
+	net_if->client.hdr.req_len	   = sizeof(struct hfi_window_info);
+	net_if->client.hdr.result.use.kptr = &(net_if->client);
+
+	rc = hfidd_close_window_func(HF_ACS(net_if), 0,
+			(struct hfi_window_info *)(&(net_if->client)));
+	if (rc) {
+		netdev_err(net->netdev,
+			"%s: hf_close_ip_window: fail, rc=0x%x\n",
+			net_if->name, rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+static int hf_open_ip_window(struct hf_net *net,
+			     struct hfidd_acs *p_acs)
+{
+	struct hf_if		*net_if = &(net->hfif);
+	int			rc = 0;
+
+	net_if->client.win_type = HFIDD_IP_WIN;
+
+	net_if->client.sfifo.eaddr.use.kptr	 = net_if->tx_fifo.addr;
+	net_if->client.sfifo.size		 = net_if->tx_fifo.size;
+	net_if->client.rfifo.eaddr.use.kptr	 = net_if->rx_fifo.addr;
+	net_if->client.rfifo.size		 = net_if->rx_fifo.size;
+	net_if->client.sfifo_finish_vec.use.kptr = net_if->sfifo_finishvec;
+	net_if->client.job_id			 = HF_IP_JOBID;
+
+	/* Fill in the request structure */
+	net_if->client.hdr.req		   = HFIDD_REQ_OPEN_WINDOW;
+	net_if->client.hdr.req_len	   = sizeof(struct hfi_client_info);
+	net_if->client.hdr.result.use.kptr = &(net_if->client);
+
+	rc = hfidd_open_window_func(p_acs, 0, &(net_if->client),
+			&(net_if->client));
+	if (rc) {
+		netdev_err(net->netdev,
+			"%s: hf_open_ip_window: fail open rc=0x%x\n",
+			net_if->name, rc);
+		return rc;
+	}
+
+	net_if->doorbell = (ioremap(
+		(u64)(net_if->client.mmio_regs.use.kptr), PAGE_SIZE_64K));
+
+	if (unlikely(net_if->doorbell == NULL)) {
+		netdev_err(net->netdev,
+			"%s: hf_open_ip_window: fail to map doorbell\n",
+			net_if->name);
+		hf_close_ip_window(net, p_acs);
+	}
+
+	net_if->isr_id = net_if->client.local_isrid;
+
+	return 0;
+}
+
+static int hf_set_mac_addr(struct net_device *netdev, void *p)
+{
+	struct hf_net		*net = netdev_priv(netdev);
+	struct hf_if		*net_if = &(net->hfif);
+
+	/* Mac address format: 02:ClusterID:ISR:ISR:HFI_WIN:WIN */
+
+	/* Locally administered MAC address */
+	netdev->dev_addr[0] = 0x2; /* bit6=1, bit7=0 */
+
+	netdev->dev_addr[1] = 0x0; /* cluster id */
+
+	*(u16 *)(&(netdev->dev_addr[2])) = (u16)(net_if->isr_id);
+
+	*(u16 *)(&(netdev->dev_addr[4])) = (u16)
+	(((net_if->ai) << HF_MAC_HFI_SHIFT) | (net_if->client.window));
+
+	return 0;
+}
+
+static int hf_net_delayed_open(void *parm, u16 win, u16 ext)
+{
+	struct net_device	*netdev = (struct net_device *)parm;
+	struct hf_net		*net = netdev_priv(netdev);
+	struct hf_if		*net_if = &(net->hfif);
+	int			rc = 0;
+	struct hfidd_acs	*p_acs = HF_ACS(net_if);
+
+	spin_lock(&(net_if->lock));
+	if (net_if->state != HF_NET_HALF_OPEN) {
+		netdev_err(netdev, "hf_net_delayed_open: net_if state=0x%x\n",
+			net_if->state);
+		spin_unlock(&(net_if->lock));
+		return -EINVAL;
+	}
+
+	rc = hf_alloc_resource(net);
+	if (rc)
+		goto delayed_open_err0;
+
+	rc = hf_open_ip_window(net, p_acs);
+	if (rc)
+		goto delayed_open_err1;
+
+	hf_set_mac_addr(netdev, NULL);
+
+	net_if->state = HF_NET_OPEN;
+	spin_unlock(&(net_if->lock));
+
+	return 0;
+
+delayed_open_err1:
+	hf_free_resource(net_if);
+
+delayed_open_err0:
+	spin_unlock(&(net_if->lock));
+
+	return rc;
+}
+
+static int hf_register_hfi_ready_callback(struct net_device *netdev,
+					  struct hfidd_acs *p_acs,
+					  int flag)
+{
+	struct hfi_reg_events	reg_events;
+	int			rc = 0;
+
+	reg_events.hdr.req    = flag;
+	reg_events.hdr.req_len = sizeof(struct hfi_reg_events);
+	reg_events.hdr.result.use.kptr = NULL;
+	reg_events.type	= FUNCTIONS_FOR_EVENTS;
+
+	reg_events.info.func.index = HFIDD_HFI_READY_REG;
+	reg_events.info.func.function_p.use.kptr = hf_net_delayed_open;
+	reg_events.info.func.parameter.use.kptr  = (void *)(netdev);
+
+	if (flag == HFIDD_REQ_EVENT_REGISTER)
+		rc = hfidd_callback_register(p_acs, &reg_events);
+	else
+		rc = hfidd_callback_unregister(p_acs, &reg_events);
+	if (rc) {
+		netdev_err(netdev, "hf_register_hfi_ready_callback: fail"
+			" flag=0x%x rc=0x%x\n", flag, rc);
+
+		return rc;
+	}
+
+	return 0;
+}
+
+static int hf_net_open(struct net_device *netdev)
+{
+	struct hf_net		*net = netdev_priv(netdev);
+	struct hf_if		*net_if = &(net->hfif);
+	int			rc = 0;
+	struct hfidd_acs	*p_acs = HF_ACS(net_if);
+
+	memset(&(netdev->stats), 0, sizeof(struct net_device_stats));
+	net_if->sfifo_packets = 0;
+
+	spin_lock(&(net_if->lock));
+	net_if->state = HF_NET_HALF_OPEN;
+	spin_unlock(&(net_if->lock));
+
+	netif_carrier_off(netdev);
+
+	rc = hf_register_hfi_ready_callback(netdev, p_acs,
+			HFIDD_REQ_EVENT_REGISTER);
+	if (rc != 0) {
+		spin_lock(&(net_if->lock));
+		net_if->state = HF_NET_CLOSE;
+		spin_unlock(&(net_if->lock));
+
+		netdev_err(netdev, "hf_net_open: hf_register_hfi_ready_callback"
+			"fail, rc=0x%x, state=0x%x", rc, net_if->state);
+		return rc;
+	}
+
+	return 0;
+}
+
+static int hf_net_close(struct net_device *netdev)
+{
+	struct hf_net		*net = netdev_priv(netdev);
+	struct hf_if		*net_if = &(net->hfif);
+	struct hfidd_acs	*p_acs = HF_ACS(net_if);
+
+	spin_lock(&(net_if->lock));
+	if (net_if->state == HF_NET_OPEN) {
+		hf_close_ip_window(net, p_acs);
+
+		hf_free_resource(net_if);
+	}
+
+	hf_register_hfi_ready_callback(netdev, p_acs,
+			HFIDD_REQ_EVENT_UNREGISTER);
+
+	net_if->state = HF_NET_CLOSE;
+	spin_unlock(&(net_if->lock));
+
+	return 0;
+}
+
+static int hf_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	if ((new_mtu <= 68) || (new_mtu > HF_NET_MTU))
+		return -ERANGE;
+
+	netdev->mtu = new_mtu;
+
+	return 0;
+}
+
+static int hf_hard_header(struct sk_buff *skb,
+			  struct net_device *netdev,
+			  u16 type,
+			  const void *daddr,
+			  const void *saddr,
+			  u32 len)
+{
+	struct ethhdr		*hwhdr_p;
+
+	skb_push(skb, ETH_HLEN);
+
+	hwhdr_p = (struct ethhdr *)(skb->data);
+	hwhdr_p->h_proto = htons(type);
+
+	if (!saddr)
+		saddr = netdev->dev_addr;
+
+	memcpy(hwhdr_p->h_source, saddr, netdev->addr_len);
+
+	if (daddr) {
+		memcpy(hwhdr_p->h_dest, daddr, netdev->addr_len);
+		return netdev->hard_header_len;
+	}
+
+	if (netdev->flags & IFF_NOARP) {
+		memset(hwhdr_p->h_dest, 0, netdev->addr_len);
+		return netdev->hard_header_len;
+	}
+
+	return -netdev->hard_header_len;
+}
+
+static const struct header_ops hf_header_ops = {
+	.create = hf_hard_header,
+};
+
+static const struct net_device_ops hf_netdev_ops = {
+	.ndo_open		= hf_net_open,
+	.ndo_stop		= hf_net_close,
+	.ndo_change_mtu		= hf_change_mtu,
+	.ndo_set_mac_address	= NULL,
+};
+
+static void hf_if_setup(struct net_device *netdev)
+{
+	netdev->type		= ARPHRD_HFI;
+	netdev->mtu		= HF_NET_MTU;
+	netdev->tx_queue_len	= 1000;
+	netdev->flags		= IFF_BROADCAST;
+	netdev->hard_header_len	= ETH_HLEN;
+	netdev->addr_len	= ETH_ALEN;
+	netdev->needed_headroom	= 0;
+
+	netdev->header_ops	= &hf_header_ops;
+	netdev->netdev_ops	= &hf_netdev_ops;
+
+	memcpy(netdev->broadcast, hfi_bcast_addr, ETH_ALEN);
+}
+
+static struct hf_net *hf_init_netdev(int idx, int ai)
+{
+	struct net_device	*netdev;
+	struct hf_net		*net;
+	int			ii;
+	int			rc;
+	char			ifname[HF_MAX_NAME_LEN];
+
+	ii = (idx * MAX_HFIS) + ai;
+	sprintf(ifname, "hf%d", ii);
+	netdev = alloc_netdev(sizeof(struct hf_net), ifname, hf_if_setup);
+	if (!netdev) {
+		printk(KERN_ERR "hf_init_netdev: "
+				"alloc_netdev for hfi%d:hf%d fail\n", ai, idx);
+		return ERR_PTR(-ENODEV);
+	}
+
+	net = netdev_priv(netdev);
+	net->netdev = netdev;
+
+	memset(&(net->hfif), 0, sizeof(struct hf_if));
+	net->hfif.idx = ii;	/* interface index */
+	net->hfif.ai  = ai;	/* adapter index */
+	strncpy(net->hfif.name, ifname, HF_MAX_NAME_LEN);
+	net->hfif.state = HF_NET_CLOSE;
+
+	spin_lock_init(&net->hfif.lock);
+
+	rc = register_netdev(netdev);
+	if (rc) {
+		netdev_err(netdev, "hf_init_netdev: "
+				"failed to register netdev=hfi%d:hf%d, "
+				"rc = 0x%x\n", ai, idx, rc);
+		free_netdev(netdev);
+		return ERR_PTR(-ENODEV);
+	}
+
+	return net;
+}
+
+static void hf_del_netdev(struct hf_net *net)
+{
+	struct net_device	*netdev = net->netdev;
+
+	unregister_netdev(netdev);
+
+	free_netdev(netdev);
+}
+
+static int hf_inet_event(struct notifier_block *this,
+			 unsigned long event,
+			 void *ifa)
+{
+	struct in_device	*in_dev;
+	struct net_device	*netdev;
+
+	in_dev = ((struct in_ifaddr *)ifa)->ifa_dev;
+
+	netdev = in_dev->dev;
+
+	if (!net_eq(dev_net(netdev), &init_net))
+		return NOTIFY_DONE;
+
+	if ((event == NETDEV_UP) && (netdev->netdev_ops == &hf_netdev_ops)) {
+		struct hf_if	*net_if;
+
+		net_if = &(((struct hf_net *)(netdev_priv(netdev)))->hfif);
+		net_if->ip_addr = ntohl(in_dev->ifa_list->ifa_address);
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block hf_inet_notifier = {
+	.notifier_call = hf_inet_event,
+};
+
+static int __init hf_init_module(void)
+{
+	u32		idx, ai;
+	int		rc;
+	struct hf_net	*net;
+
+	memset(&hf_ginfo, 0, sizeof(struct hf_global_info));
+
+	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
+		for (ai = 0; ai < MAX_HFIS; ai++) {
+			net = hf_init_netdev(idx, ai);
+			if (IS_ERR(net)) {
+				printk(KERN_ERR "hf_init_module: hf_init_netdev"
+						" for idx %d ai %d failed rc"
+						" %ld\n",
+						idx, ai, PTR_ERR(net));
+
+				goto err_out;
+			}
+
+			hf_ginfo.net[idx][ai] = net;
+		}
+	}
+
+	register_inetaddr_notifier(&hf_inet_notifier);
+
+	printk(KERN_INFO "hfi_ip module loaded\n");
+	return 0;
+
+err_out:
+	rc = PTR_ERR(net);
+	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
+		for (ai = 0; ai < MAX_HFIS; ai++) {
+			net = hf_ginfo.net[idx][ai];
+			if (net != NULL) {
+				hf_del_netdev(net);
+				hf_ginfo.net[idx][ai] = NULL;
+			}
+		}
+	}
+
+	return rc;
+}
+
+static void __exit hf_cleanup_module(void)
+{
+	u32		idx, ai;
+	struct hf_net	*net;
+
+	unregister_inetaddr_notifier(&hf_inet_notifier);
+	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
+		for (ai = 0; ai < MAX_HFIS; ai++) {
+
+			net = hf_ginfo.net[idx][ai];
+			if (net != NULL) {
+				hf_del_netdev(net);
+				hf_ginfo.net[idx][ai] = NULL;
+			}
+		}
+	}
+
+	return;
+}
+
+module_init(hf_init_module);
+module_exit(hf_cleanup_module);
diff --git a/include/linux/hfi/hfi_ip.h b/include/linux/hfi/hfi_ip.h
new file mode 100644
index 0000000..6b6a74c
--- /dev/null
+++ b/include/linux/hfi/hfi_ip.h
@@ -0,0 +1,148 @@
+/*
+ * hfi_ip.h
+ *
+ * HF IP driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <wcchen@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFI_IP_H_
+#define _HFI_IP_H_
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <net/arp.h>
+
+#include <linux/hfi/hfidd_internal.h>
+#include <linux/hfi/hfidd_client.h>
+#include <linux/hfi/hfidd_requests.h>
+#include <linux/hfi/hfidd_pkt_formats.h>
+
+#define HF_DRV_VERSION			"1.0"
+#define HF_DRV_RELDATE			"July 7, 2010"
+#define HF_DRV_NAME			"hf"
+
+#define MAX_HF_PER_HFI			2
+#define	HF_IP_JOBID			0xFFFFFFF0
+#define HF_MAX_NAME_LEN			64
+
+#define HF_SFIFO_SIZE			0x40000	/* 256K */
+#define HF_SFIFO_SLOTS			(HF_SFIFO_SIZE >> HFI_CACHE_LINE_SHIFT)
+#define HF_RFIFO_SIZE			0x1000000	/* 16M */
+#define HF_RFIFO_SLOTS			(HF_RFIFO_SIZE >> HFI_CACHE_LINE_SHIFT)
+
+#define HF_FV_BIT_CNT			32
+
+#define HF_NET_MTU			(2048 - HF_IP_HDR_LEN - HF_PROTO_LEN)
+
+struct hfi_ip_extended_hdr {            /* 16B */
+	unsigned int	immediate_len:7;/* In bytes */
+	unsigned int	num_desc:3;     /* number of descriptors */
+					/* Logical Port ID: */
+	unsigned int	lpid_valid:1;   /* set by sending HFI */
+	unsigned int	lpid:4;         /* set by sending HFI */
+	/* Ethernet Service Header is 113 bits, which is 14 bytes + 1 bit */
+	unsigned int	ethernet_svc_hdr_hi:1;    /* Not used by HFI */
+	char            ethernet_svc_hdr[12];     /* Not used by HFI */
+	__sum16         bcast_csum;
+} __packed;
+
+struct hfi_ip_with_payload_pkt {
+	struct hfi_hdr			hfi_hdr;
+	struct hfi_ip_extended_hdr	ip_ext;
+	char				payload[2016];
+} __packed;
+
+#define HF_IP_HDR_LEN			((sizeof(struct hfi_hdr) + \
+				sizeof(struct hfi_ip_extended_hdr)))
+#define HF_ALIGN_PAD			2
+
+struct hf_if_proto_hdr {
+	u16			version;
+	u8			msg_type;
+	u8			msg_flag;
+	u32			msg_len;	/* Include HFI header */
+	u32			msg_id;
+};
+
+#define HF_PROTO_LEN		sizeof(struct hf_if_proto_hdr)
+
+struct hf_fifo {
+	void			*addr;
+	u32			size;		/* total bytes	*/
+	u32			head;
+	u32			tail;
+	u32			emax;		/* power 2 mask */
+	atomic_t		avail;		/* for tx	*/
+	atomic_t		outstanding;	/* for rx	*/
+};
+
+#define	HF_NET_CLOSE		0x00
+#define	HF_NET_HALF_OPEN	0xA0
+#define	HF_NET_OPEN		0xA1
+
+struct hf_if {
+	u32			idx;			/* 0, 1, 2, 3 ...   */
+	u32			ai;			/* 0=hfi0, 1=hfi1   */
+	char			name[HF_MAX_NAME_LEN];
+	u32			isr_id;
+	u32			ip_addr;
+	u32			state;			/* CLOSE, OPEN */
+	spinlock_t		lock;			/* lock for state */
+	u32			sfifo_fv_polarity;
+	u32			sfifo_slots_per_blk;
+	u32			sfifo_packets;
+	void __iomem		*doorbell;		/* mapped mmio_regs */
+	struct hf_fifo		tx_fifo;
+	struct hf_fifo		rx_fifo;
+	struct hfi_client_info	client;
+	struct sk_buff		**tx_skb;		/* array to store tx
+							   2k skb */
+	void			*sfifo_finishvec;
+};
+
+/* Private structure for HF inetrface */
+struct hf_net {
+	struct net_device	*netdev;
+	struct hf_if		hfif;
+};
+
+extern struct hfidd_global	hfidd_global;
+
+#define HF_ACS(net_if)		(hfidd_global.p_acs[(net_if)->ai])
+
+struct hf_global_info {
+	struct hf_net		*net[MAX_HF_PER_HFI][MAX_HFI_PER_TORRENT];
+};
+
+extern struct hf_global_info	hf_ginfo;
+
+#define HF_MAC_HFI_SHIFT	12
+#endif
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 6d722f4..f2cfdc1 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -41,6 +41,7 @@
 #define	ARPHRD_IEEE1394	24		/* IEEE 1394 IPv4 - RFC 2734	*/
 #define ARPHRD_EUI64	27		/* EUI-64                       */
 #define ARPHRD_INFINIBAND 32		/* InfiniBand			*/
+#define ARPHRD_HFI	37		/* Host Fabric Interface	*/
 
 /* Dummy types for non ARP hardware */
 #define ARPHRD_SLIP	256
-- 
1.7.3.5

