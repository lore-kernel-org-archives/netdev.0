From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 2/2] netdev: an usage example on igb
Date: Mon, 05 Apr 2010 15:54:56 +0900
Message-ID: <4BB98940.5070003@jp.fujitsu.com>
References: <4BB98828.5030302@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:51559 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab0DEGyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 02:54:51 -0400
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o356solv012359
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 5 Apr 2010 15:54:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAB3E45DE55
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:54:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B676D45DE53
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:54:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E5161DB803E
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:54:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 151171DB8042
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:54:45 +0900 (JST)
In-Reply-To: <4BB98828.5030302@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is usage example of previous patch's buffer on igb.
The output is like below.

# cat /sys/kernel/debug/ndrvbuf/igb-trace-0000\:03\:00.0/buffer
[  1] 50462.369207: clean_tx qidx=1 ntu=154->156
[  0] 50462.369241: clean_rx qidx=0 ntu=111->112
[  0] 50462.369250: xmit qidx=1 ntu=156->158
[  1] 50462.369256: clean_tx qidx=1 ntu=156->158
[  1] 50462.369342: clean_rx qidx=0 ntu=113->114
[  1] 50462.369439: clean_rx qidx=0 ntu=114->115

This example outputs original print style, because it sets original print
function(igb_trace_read) when registered.

register_ndrvbuf(buname, 1000000, igb_trace_read);

If you set NULL to arg3, outputs by ndrvbuf default style.
If you set 0 to size(arg2), recording is disabled at first(but small buffer is
alloced).
When you set non-zero to size, recording becomes enabled.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
  drivers/net/igb/Makefile    |    2 +-
  drivers/net/igb/igb.h       |    1 +
  drivers/net/igb/igb_main.c  |   10 +++++-
  drivers/net/igb/igb_trace.c |   81 +++++++++++++++++++++++++++++++++++++++++++
  drivers/net/igb/igb_trace.h |   21 +++++++++++
  5 files changed, 113 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index 8372cb9..286541e 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -33,5 +33,5 @@
  obj-$(CONFIG_IGB) += igb.o
  
  igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
-	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o
+	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o igb_trace.o
  
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a177570..533c5e6 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -315,6 +315,7 @@ struct igb_adapter {
  	unsigned int vfs_allocated_count;
  	struct vf_data_storage *vf_data;
  	u32 rss_queues;
+	struct ndrvbuf *trace;
  };
  
  #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 583a21c..f754fd1 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -48,6 +48,7 @@
  #include <linux/dca.h>
  #endif
  #include "igb.h"
+#include "igb_trace.h"
  
  #define DRV_VERSION "2.1.0-k2"
  char igb_driver_name[] = "igb";
@@ -1412,6 +1413,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
  	int err, pci_using_dac;
  	u16 eeprom_apme_mask = IGB_EEPROM_APME;
  	u32 part_num;
+	char bufname[NDRVBUF_NAME_SIZE];
  
  	err = pci_enable_device_mem(pdev);
  	if (err)
@@ -1674,6 +1676,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
  		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
  		adapter->num_rx_queues, adapter->num_tx_queues);
  
+	sprintf(bufname, "igb-trace-%s", pci_name(pdev));
+	adapter->trace = register_ndrvbuf(bufname, 1000000, igb_trace_read);
  	return 0;
  
  err_register:
@@ -1734,6 +1738,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
  	 * would have already happened in close and is redundant. */
  	igb_release_hw_control(adapter);
  
+	unregister_ndrvbuf(adapter->trace);
  	unregister_netdev(netdev);
  
  	igb_clear_interrupt_scheme(adapter);
@@ -3814,6 +3819,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
  	}
  
  	igb_tx_queue_adv(tx_ring, tx_flags, count, skb->len, hdr_len);
+	igb_trace_write_xmit(adapter->trace, tx_ring, first);
  
  	/* Make sure there is space in the ring for the next send. */
  	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
@@ -5039,7 +5045,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
  		eop = tx_ring->buffer_info[i].next_to_watch;
  		eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
  	}
-
+	igb_trace_write_clean_tx(adapter->trace, tx_ring, i);
  	tx_ring->next_to_clean = i;
  
  	if (unlikely(count &&
@@ -5195,6 +5201,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
  {
  	struct igb_ring *rx_ring = q_vector->rx_ring;
  	struct net_device *netdev = rx_ring->netdev;
+	struct igb_adapter *adapter = netdev_priv(netdev);
  	struct pci_dev *pdev = rx_ring->pdev;
  	union e1000_adv_rx_desc *rx_desc , *next_rxd;
  	struct igb_buffer *buffer_info , *next_buffer;
@@ -5309,6 +5316,7 @@ next_desc:
  		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
  	}
  
+	igb_trace_write_clean_rx(adapter->trace, rx_ring, i);
  	rx_ring->next_to_clean = i;
  	cleaned_count = igb_desc_unused(rx_ring);
  
diff --git a/drivers/net/igb/igb_trace.c b/drivers/net/igb/igb_trace.c
new file mode 100644
index 0000000..ab96300
--- /dev/null
+++ b/drivers/net/igb/igb_trace.c
@@ -0,0 +1,81 @@
+#include "igb_trace.h"
+
+struct trace_data_common {
+	unsigned short type;
+	u8 qidx;
+	int from;
+	int to;
+};
+
+void igb_trace_write_xmit(struct ndrvbuf *ndrvbuf,
+				struct igb_ring *tx_ring, int i)
+{
+	struct trace_data_common tdata;
+
+	tdata.type = IGB_TRACE_EVENT_XMIT;
+	tdata.qidx = tx_ring->queue_index;
+	tdata.from = i;
+	tdata.to = tx_ring->next_to_use;
+
+	write_ndrvbuf(ndrvbuf, sizeof(struct trace_data_common), &tdata);
+}
+
+void igb_trace_write_clean_tx(struct ndrvbuf *ndrvbuf,
+				struct igb_ring *tx_ring, int i)
+{
+	struct trace_data_common tdata;
+
+	tdata.type = IGB_TRACE_EVENT_CLEAN_TX;
+	tdata.qidx = tx_ring->queue_index;
+	tdata.from = tx_ring->next_to_clean;
+	tdata.to = i;
+
+	write_ndrvbuf(ndrvbuf, sizeof(struct trace_data_common), &tdata);
+}
+
+void igb_trace_write_clean_rx(struct ndrvbuf *ndrvbuf,
+				struct igb_ring *rx_ring, int i)
+{
+	struct trace_data_common tdata;
+
+	tdata.type = IGB_TRACE_EVENT_CLEAN_RX;
+	tdata.qidx = rx_ring->queue_index;
+	tdata.from = rx_ring->next_to_clean;
+	tdata.to = i;
+
+	write_ndrvbuf(ndrvbuf, sizeof(struct trace_data_common), &tdata);
+}
+
+size_t igb_trace_read(void *ubuf, size_t bufsize, void *entry,
+			size_t size, int cpu, u64 ts)
+{
+	struct trace_data_common *tdata = entry;
+	int bufpos = 0;
+	size_t headlen;
+
+	headlen = typical_ndrvbuf_header(ubuf, bufsize, cpu, ts);
+	bufpos += headlen;
+
+	switch (tdata->type) {
+	case IGB_TRACE_EVENT_XMIT:
+		bufpos += snprintf(ubuf + bufpos, bufsize - bufpos,
+					"xmit qidx=%u ntu=%d->%d\n",
+					tdata->qidx, tdata->from, tdata->to);
+		break;
+	case IGB_TRACE_EVENT_CLEAN_TX:
+		bufpos += snprintf(ubuf + bufpos, bufsize - bufpos,
+					"clean_tx qidx=%u ntu=%d->%d\n",
+					tdata->qidx, tdata->from, tdata->to);
+		break;
+	case IGB_TRACE_EVENT_CLEAN_RX:
+		bufpos += snprintf(ubuf + bufpos, bufsize - bufpos,
+					"clean_rx qidx=%u ntu=%d->%d\n",
+					tdata->qidx, tdata->from, tdata->to);
+		break;
+	default:
+		bufpos += snprintf(ubuf + bufpos, bufsize - bufpos,
+					"EVENT ID:%u is not defined\n",
+					tdata->type);
+	}
+	return bufpos;
+}
diff --git a/drivers/net/igb/igb_trace.h b/drivers/net/igb/igb_trace.h
new file mode 100644
index 0000000..fa130e1
--- /dev/null
+++ b/drivers/net/igb/igb_trace.h
@@ -0,0 +1,21 @@
+#ifndef _IGB_TRACE_H_
+#define _IGB_TRACE_H_
+
+#include <linux/ndrvbuf.h>
+#include "igb.h"
+
+#define IGB_TRACE_EVENT_XMIT		0x01
+#define IGB_TRACE_EVENT_CLEAN_TX	0x02
+#define IGB_TRACE_EVENT_CLEAN_RX	0x03
+
+extern void igb_trace_write_xmit(struct ndrvbuf *ndrvbuf,
+			struct igb_ring *tx_ring, int i);
+extern void igb_trace_write_clean_tx(struct ndrvbuf *ndrvbuf,
+			struct igb_ring *tx_ring, int i);
+extern void igb_trace_write_clean_rx(struct ndrvbuf *ndrvbuf,
+			struct igb_ring *rx_ring, int i);
+
+extern size_t igb_trace_read(void *ubuf, size_t bufsize, void *entry,
+			size_t size, int cpu, u64 ts);
+
+#endif /*_IGB_TRACE_H_*/

