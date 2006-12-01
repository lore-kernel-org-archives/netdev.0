From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/3] NetXen: 64-bit memory fixes
Date: Fri, 1 Dec 2006 05:40:14 -0800
Message-ID: <200612011340.kB1DeEhR014690@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, shemminger@osdl.org, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:60262 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1031409AbWLANkO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 08:40:14 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: 1G/10G Ethernet driver updates
	- These fixes take care of driver on machines with >4G memory
	- Driver cleanup

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic.h          |   29 +++++--
 netxen_nic_ethtool.c  |   19 ++--
 netxen_nic_hw.c       |    4 
 netxen_nic_hw.h       |    4 
 netxen_nic_init.c     |   51 +++++++++++-
 netxen_nic_isr.c      |    3 
 netxen_nic_main.c     |  204 +++++++++++++++++++++++++++++++++++++++++++++++---
 netxen_nic_phan_reg.h |   10 +-
 8 files changed, 286 insertions(+), 38 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d925053..029e6c7 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -89,8 +89,8 @@
  * normalize a 64MB crb address to 32MB PCI window 
  * To use NETXEN_CRB_NORMALIZE, window _must_ be set to 1
  */
-#define NETXEN_CRB_NORMAL(reg)        \
-	(reg) - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST
+#define NETXEN_CRB_NORMAL(reg)	\
+	((reg) - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST)
 
 #define NETXEN_CRB_NORMALIZE(adapter, reg) \
 	pci_base_offset(adapter, NETXEN_CRB_NORMAL(reg))
@@ -164,7 +164,7 @@ enum {
 
 #define MAX_CMD_DESCRIPTORS		1024
 #define MAX_RCV_DESCRIPTORS		32768
-#define MAX_JUMBO_RCV_DESCRIPTORS	1024
+#define MAX_JUMBO_RCV_DESCRIPTORS	4096
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
 #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
@@ -591,6 +591,16 @@ struct netxen_skb_frag {
 	u32 length;
 };
 
+/* Bounce buffer index */
+struct bounce_index {
+	/* Index of a buffer */
+	unsigned buffer_index;
+	/* Offset inside the buffer */
+	unsigned buffer_offset;
+};
+
+#define IS_BOUNCE 0xcafebb
+
 /*    Following defines are for the state of the buffers    */
 #define	NETXEN_BUFFER_FREE	0
 #define	NETXEN_BUFFER_BUSY	1
@@ -610,6 +620,8 @@ struct netxen_cmd_buffer {
 	unsigned long time_stamp;
 	u32 state;
 	u32 no_of_descriptors;
+	u32 tx_bounce_buff;
+	struct bounce_index bnext;
 };
 
 /* In rx_buffer, we do not need multiple fragments as is a single buffer */
@@ -618,6 +630,9 @@ struct netxen_rx_buffer {
 	u64 dma;
 	u16 ref_handle;
 	u16 state;
+	u32 rx_bounce_buff;
+	struct bounce_index bnext;
+	char *bounce_ptr;
 };
 
 /* Board types */
@@ -702,6 +717,7 @@ struct netxen_recv_context {
 };
 
 #define NETXEN_NIC_MSI_ENABLED 0x02
+#define NETXEN_DMA_MASK	0xfffffffe
 
 struct netxen_drvops;
 
@@ -1018,6 +1034,9 @@ static inline void get_brd_name_by_type(
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);
+int netxen_get_next_bounce_buffer(struct bounce_index *head,
+				  struct bounce_index *tail,
+				  struct bounce_index *biret, unsigned len);
 
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
 extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 9a914ae..8d8e5e1 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -118,7 +118,7 @@ netxen_nic_get_drvinfo(struct net_device
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 
-	strncpy(drvinfo->driver, "netxen_nic", 32);
+	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
 	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
 					      NETXEN_FW_VERSION_MAJOR));
@@ -210,7 +210,6 @@ netxen_nic_get_settings(struct net_devic
 		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
 		       (netxen_brdtype_t) boardinfo->board_type);
 		return -EIO;
-
 	}
 
 	return 0;
@@ -460,20 +459,22 @@ netxen_nic_get_ringparam(struct net_devi
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	int i, j;
+	int i;
 
 	ring->rx_pending = 0;
+	ring->rx_jumbo_pending = 0;
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
-		for (j = 0; j < NUM_RCV_DESC_RINGS; j++)
-			ring->rx_pending +=
-			    adapter->recv_ctx[i].rcv_desc[j].rcv_pending;
+		ring->rx_pending += adapter->recv_ctx[i].
+		    rcv_desc[RCV_DESC_NORMAL_CTXID].rcv_pending;
+		ring->rx_jumbo_pending += adapter->recv_ctx[i].
+		    rcv_desc[RCV_DESC_JUMBO_CTXID].rcv_pending;
 	}
 
 	ring->rx_max_pending = adapter->max_rx_desc_count;
 	ring->tx_max_pending = adapter->max_tx_desc_count;
+	ring->rx_jumbo_max_pending = adapter->max_jumbo_rx_desc_count;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_mini_pending = 0;
-	ring->rx_jumbo_max_pending = 0;
 	ring->rx_jumbo_pending = 0;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 105c24f..84c69a4 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -648,7 +648,7 @@ void netxen_nic_reg_write(struct netxen_
 
 	addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
-		pci_base(adapter, off), off, addr);
+		pci_base(adapter, off), off, addr, val);
 	writel(val, addr);
 
 }
@@ -660,7 +660,7 @@ int netxen_nic_reg_read(struct netxen_ad
 
 	addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
-		adapter->ahw.pci_base, off, addr);
+		pci_base(adapter, off), off, addr);
 	val = readl(addr);
 	writel(val, addr);
 
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 201a636..e5620a6 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -83,8 +83,8 @@ struct netxen_adapter;
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
 
 #define NETXEN_NIC_LOCKED_READ_REG(X, Y)	\
-	addr = pci_base_offset(adapter, (X));	\
-	*(u32 *)Y = readl(addr);
+	addr = pci_base_offset(adapter, X);	\
+	*(u32 *)Y = readl((void __iomem*) addr);
 
 struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_port *port);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0dca029..b7e83a9 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -53,6 +53,11 @@ static unsigned int crb_addr_xform[NETXE
 
 #define NETXEN_NIC_XDMA_RESET 0x8000ff
 
+extern char *rx_bounce_ptr;
+extern struct bounce_index tx_bounce_head, tx_bounce_tail,
+    rx_bounce_head, rx_bounce_tail;
+extern spinlock_t rx_bounce_lock, tx_bounce_lock;
+
 static inline void
 netxen_nic_locked_write_reg(struct netxen_adapter *adapter,
 			    unsigned long off, int *data)
@@ -191,8 +196,6 @@ void netxen_initialize_adapter_sw(struct
 			}
 		}
 	}
-	DPRINTK(INFO, "initialized buffers for %s and %s\n",
-		"adapter->free_cmd_buf_list", "adapter->free_rxbuf");
 }
 
 void netxen_initialize_adapter_hw(struct netxen_adapter *adapter)
@@ -383,8 +386,8 @@ int netxen_rom_wip_poll(struct netxen_ad
 	return 0;
 }
 
-static inline int do_rom_fast_write(struct netxen_adapter *adapter,
-				    int addr, int data)
+static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
+				    int data)
 {
 	if (netxen_rom_wren(adapter)) {
 		return -1;
@@ -774,6 +777,11 @@ netxen_process_rcv(struct netxen_adapter
 			 PCI_DMA_FROMDEVICE);
 
 	skb = (struct sk_buff *)buffer->skb;
+	if (buffer->rx_bounce_buff == IS_BOUNCE) {
+		buffer->rx_bounce_buff = 0;
+		memcpy(skb->data, buffer->bounce_ptr, rcv_desc->dma_size);
+		rx_bounce_tail = buffer->bnext;
+	}
 
 	if (likely(STATUS_DESC_STATUS(desc) == STATUS_CKSUM_OK)) {
 		port->stats.csummed++;
@@ -938,6 +946,10 @@ void netxen_process_cmd_ring(unsigned lo
 					       PCI_DMA_TODEVICE);
 			}
 
+			if (buffer->tx_bounce_buff == IS_BOUNCE) {
+				buffer->tx_bounce_buff = 0;
+				tx_bounce_tail = buffer->bnext;
+			}
 			port->stats.skbfreed++;
 			dev_kfree_skb_any(skb);
 			skb = NULL;
@@ -1006,6 +1018,8 @@ void netxen_post_rx_buffers(struct netxe
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
 	int index = 0;
+	unsigned long bounce_flags;
+	struct bounce_index tmpbi;
 
 	adapter->stats.post_called++;
 	rcv_desc = &recv_ctx->rcv_desc[ringid];
@@ -1029,6 +1043,7 @@ void netxen_post_rx_buffers(struct netxe
 		count++;	/* now there should be no failure */
 		pdesc = &rcv_desc->desc_head[producer];
 		skb_reserve(skb, NET_IP_ALIGN);
+		buffer->rx_bounce_buff = 0;
 		/* 
 		 * This will be setup when we receive the
 		 * buffer after it has been filled
@@ -1039,6 +1054,34 @@ void netxen_post_rx_buffers(struct netxe
 		buffer->dma = pci_map_single(pdev, skb->data,
 					     rcv_desc->dma_size,
 					     PCI_DMA_FROMDEVICE);
+		if (buffer->dma > NETXEN_DMA_MASK) {
+			pci_unmap_single(pdev, buffer->dma, rcv_desc->dma_size,
+					 PCI_DMA_FROMDEVICE);
+			spin_lock_irqsave(&rx_bounce_lock, bounce_flags);
+			if (netxen_get_next_bounce_buffer(&rx_bounce_head,
+							  &rx_bounce_tail,
+							  &tmpbi,
+							  rcv_desc->dma_size)) {
+				spin_unlock_irqrestore(&rx_bounce_lock,
+						       bounce_flags);
+				dev_kfree_skb_any(skb);
+				skb = NULL;
+				buffer->skb = NULL;
+				buffer->state = NETXEN_BUFFER_FREE;
+				count--;
+				break;
+			}
+			spin_unlock_irqrestore(&rx_bounce_lock, bounce_flags);
+			buffer->rx_bounce_buff = IS_BOUNCE;
+			buffer->bnext = rx_bounce_head;
+			buffer->bounce_ptr = (void *)(ptrdiff_t)
+			    (rx_bounce_ptr[tmpbi.buffer_index]
+			     + tmpbi.buffer_offset);
+			buffer->dma = pci_map_single(pdev, buffer->bounce_ptr,
+						     rcv_desc->dma_size,
+						     PCI_DMA_FROMDEVICE);
+		}
+
 		/* make a rcv descriptor  */
 		pdesc->reference_handle = le16_to_cpu(buffer->ref_handle);
 		pdesc->buffer_length = le16_to_cpu(rcv_desc->dma_size);
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index ae180fe..f6ae9fd 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -68,8 +68,7 @@ struct net_device_stats *netxen_nic_get_
 void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 portno,
 				 u32 link)
 {
-	struct netxen_port *pport = adapter->port[portno];
-	struct net_device *netdev = pport->netdev;
+	struct net_device *netdev = (adapter->port[portno])->netdev;
 
 	if (link)
 		netif_carrier_on(netdev);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1cb662d..1f9abc6 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -48,7 +48,7 @@ MODULE_DESCRIPTION("NetXen Multi port (1
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 
-char netxen_nic_driver_name[] = "netxen";
+char netxen_nic_driver_name[] = "netxen-nic";
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
@@ -56,6 +56,19 @@ static char netxen_nic_driver_string[] =
 #define NETXEN_ADAPTER_UP_MAGIC 777
 #define NETXEN_NIC_PEG_TUNE 0
 
+/* Number of bounce buffers. Has to be a power of two */
+#define NUM_BOUNCE 256
+char *tx_bounce_ptr[NUM_BOUNCE];
+char *rx_bounce_ptr[NUM_BOUNCE];
+
+struct bounce_index tx_bounce_head, tx_bounce_tail,
+    rx_bounce_head, rx_bounce_tail;
+
+spinlock_t rx_bounce_lock, tx_bounce_lock;
+
+#define BOUNCE_BUFFER_ORDER 2
+#define BOUNCE_BUFFER_SIZE (PAGE_SIZE << BOUNCE_BUFFER_ORDER)
+
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 				      const struct pci_device_id *ent);
@@ -88,6 +101,114 @@ static struct pci_device_id netxen_pci_t
 MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
 
 /*
+ * Whenever we cross the 16K boundary of bounce buffer, we use the next
+ * 16K buffer and wrap up if its the last buffer.
+ */
+int netxen_get_next_bounce_buffer(struct bounce_index *head,
+				  struct bounce_index *tail,
+				  struct bounce_index *biret, unsigned len)
+{
+	struct bounce_index tmpbi;
+
+	tmpbi.buffer_index = head->buffer_index;
+	tmpbi.buffer_offset = head->buffer_offset;
+
+	if ((tmpbi.buffer_offset + len) > BOUNCE_BUFFER_SIZE) {
+		if ((tmpbi.buffer_index == tail->buffer_index) &&
+		    (tmpbi.buffer_offset < tail->buffer_offset)) {
+			return -1;
+		}
+		tmpbi.buffer_index =
+		    (tmpbi.buffer_index + 1) & (NUM_BOUNCE - 1);
+		tmpbi.buffer_offset = 0;
+	}
+
+	if (tmpbi.buffer_index == tail->buffer_index &&
+	    tmpbi.buffer_offset < tail->buffer_offset &&
+	    (tmpbi.buffer_offset + len) >= tail->buffer_offset) {
+		return -1;
+	}
+	head->buffer_index = tmpbi.buffer_index;
+	head->buffer_offset = tmpbi.buffer_offset + len;
+	*biret = tmpbi;
+	return 0;
+}
+
+static void netxen_free_bounce_buffers(void)
+{
+	int i;
+
+	for (i = 0; i < NUM_BOUNCE && tx_bounce_ptr[i]; i++) {
+		free_pages((unsigned long)tx_bounce_ptr[i],
+			   BOUNCE_BUFFER_ORDER);
+		tx_bounce_ptr[i] = NULL;
+	}
+
+	for (i = 0; i < NUM_BOUNCE && rx_bounce_ptr[i]; i++) {
+		free_pages((unsigned long)rx_bounce_ptr[i],
+			   BOUNCE_BUFFER_ORDER);
+		rx_bounce_ptr[i] = NULL;
+	}
+}
+
+/*
+ * We have 4MB space reserved for bounce buffers.
+ * The 4MB space is divided in 256 chunks of 16K buffers.
+ */
+static int netxen_alloc_bounce_buffers(void)
+{
+	int i;
+
+	memset(tx_bounce_ptr, 0, sizeof(tx_bounce_ptr));
+	memset(rx_bounce_ptr, 0, sizeof(rx_bounce_ptr));
+
+	for (i = 0; i < NUM_BOUNCE; i++) {
+		tx_bounce_ptr[i] = (char *)__get_free_pages(GFP_KERNEL,
+							    BOUNCE_BUFFER_ORDER);
+		if (!tx_bounce_ptr[i])
+			goto err_out;
+		if (virt_to_phys(tx_bounce_ptr[i])
+		    + BOUNCE_BUFFER_SIZE > NETXEN_DMA_MASK) {
+
+			free_pages((unsigned long)tx_bounce_ptr[i],
+				   BOUNCE_BUFFER_ORDER);
+			tx_bounce_ptr[i] = (char *)__get_free_pages(GFP_DMA,
+								    BOUNCE_BUFFER_ORDER);
+		}
+		if (!tx_bounce_ptr[i])
+			goto err_out;
+
+	}
+	tx_bounce_head.buffer_index = tx_bounce_tail.buffer_index = 0;
+	tx_bounce_head.buffer_offset = tx_bounce_tail.buffer_offset = 0;
+
+	for (i = 0; i < NUM_BOUNCE; i++) {
+		rx_bounce_ptr[i] = (char *)
+		    __get_free_pages(GFP_KERNEL, BOUNCE_BUFFER_ORDER);
+		if (!rx_bounce_ptr[i])
+			goto err_out;
+		if (virt_to_phys(rx_bounce_ptr[i])
+		    + BOUNCE_BUFFER_SIZE > NETXEN_DMA_MASK) {
+			free_pages((unsigned long)rx_bounce_ptr[i],
+				   BOUNCE_BUFFER_ORDER);
+			rx_bounce_ptr[i] = (char *)
+			    __get_free_pages(GFP_DMA, BOUNCE_BUFFER_ORDER);
+		}
+		if (!rx_bounce_ptr[i])
+			goto err_out;
+
+	}
+	rx_bounce_head.buffer_index = rx_bounce_tail.buffer_index = 0;
+	rx_bounce_head.buffer_offset = rx_bounce_tail.buffer_offset = 0;
+	return 0;
+
+      err_out:
+	netxen_free_bounce_buffers();
+	return -ENOMEM;
+
+}
+
+/*
  * netxen_nic_probe()
  *
  * The Linux system will invoke this after identifying the vendor ID and
@@ -105,9 +226,9 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	struct net_device *netdev = NULL;
 	struct netxen_adapter *adapter = NULL;
 	struct netxen_port *port = NULL;
-	u8 *mem_ptr0 = NULL;
-	u8 *mem_ptr1 = NULL;
-	u8 *mem_ptr2 = NULL;
+	void __iomem *mem_ptr0 = NULL;
+	void __iomem *mem_ptr1 = NULL;
+	void __iomem *mem_ptr2 = NULL;
 
 	unsigned long mem_base, mem_len;
 	int pci_using_dac, i, err;
@@ -198,6 +319,13 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		goto err_out_free_adapter;
 	}
 	memset(cmd_buf_arr, 0, TX_RINGSIZE);
+	spin_lock_init(&tx_bounce_lock);
+	spin_lock_init(&rx_bounce_lock);
+
+	/*Only one set of bounce buffers for all adapters */
+	err = netxen_alloc_bounce_buffers();
+	if (err)
+		goto err_out_fcba;
 
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
 		recv_ctx = &adapter->recv_ctx[i];
@@ -308,6 +436,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 
 	/* initialize the all the ports */
+	adapter->active_ports = 0;
 
 	for (i = 0; i < adapter->ahw.max_ports; i++) {
 		netdev = alloc_etherdev(sizeof(struct netxen_port));
@@ -392,7 +521,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 			goto err_out_free_dev;
 		}
 		adapter->port_count++;
-		adapter->active_ports = 0;
 		adapter->port[i] = port;
 	}
 
@@ -441,10 +569,9 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		}
 	}
 
+      err_out_fcba:
 	vfree(cmd_buf_arr);
 
-	kfree(adapter->port);
-
       err_out_free_adapter:
 	pci_set_drvdata(pdev, NULL);
 	kfree(adapter);
@@ -471,6 +598,7 @@ static void __devexit netxen_nic_remove(
 	int i;
 	int ctxid, ring;
 
+	netxen_free_bounce_buffers();
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
 		return;
@@ -596,6 +724,9 @@ static int netxen_nic_open(struct net_de
 	netxen_nic_set_link_parameters(port);
 
 	netxen_nic_set_multi(netdev);
+	if (adapter->ops->set_mtu)
+		adapter->ops->set_mtu(port, netdev->mtu);
+
 	if (!adapter->driver_mismatch)
 		netif_start_queue(netdev);
 
@@ -675,6 +806,9 @@ static int netxen_nic_xmit_frame(struct
 	u32 max_tx_desc_count = 0;
 	u32 last_cmd_consumer = 0;
 	int no_of_desc;
+	struct bounce_index tmpbi;
+	char *bounce_data;
+	unsigned long bounce_flags;
 
 	port->stats.xmitcalled++;
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
@@ -792,6 +926,7 @@ static int netxen_nic_xmit_frame(struct
 	buffrag = &pbuf->frag_array[0];
 	buffrag->dma = pci_map_single(port->pdev, skb->data, first_seg_len,
 				      PCI_DMA_TODEVICE);
+	pbuf->tx_bounce_buff = 0;
 	buffrag->length = first_seg_len;
 	CMD_DESC_TOTAL_LENGTH_WRT(hwdesc, skb->len);
 	hwdesc->num_of_buffers = frag_count;
@@ -801,11 +936,33 @@ static int netxen_nic_xmit_frame(struct
 	hwdesc->buffer1_length = cpu_to_le16(first_seg_len);
 	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
+	if (buffrag->dma > NETXEN_DMA_MASK) {
+		pci_unmap_single(port->pdev, buffrag->dma, first_seg_len,
+				 PCI_DMA_TODEVICE);
+		spin_lock_irqsave(&tx_bounce_lock, bounce_flags);
+		if (netxen_get_next_bounce_buffer
+		    (&tx_bounce_head, &tx_bounce_tail, &tmpbi, first_seg_len)) {
+			spin_unlock_irqrestore(&tx_bounce_lock, bounce_flags);
+			return NETDEV_TX_BUSY;
+		}
+		spin_unlock_irqrestore(&tx_bounce_lock, bounce_flags);
+		pbuf->tx_bounce_buff = IS_BOUNCE;
+		bounce_data = tx_bounce_ptr[tmpbi.buffer_index] +
+		    tmpbi.buffer_offset;
+		buffrag->dma = pci_map_single(port->pdev, bounce_data,
+					      first_seg_len, PCI_DMA_TODEVICE);
+		hwdesc->addr_buffer1 = buffrag->dma;
+		memcpy(bounce_data, skb->data, first_seg_len);
+		pbuf->bnext = tx_bounce_head;
+	}
+
 	for (i = 1, k = 1; i < frag_count; i++, k++) {
 		struct skb_frag_struct *frag;
 		int len, temp_len;
 		unsigned long offset;
 		dma_addr_t temp_dma;
+		struct page *bounce_frag_page;
+		u32 bounce_page_offset;
 
 		/* move to next desc. if there is a need */
 		if ((i & 0x3) == 0) {
@@ -827,6 +984,34 @@ static int netxen_nic_xmit_frame(struct
 		buffrag->dma = temp_dma;
 		buffrag->length = temp_len;
 
+		if (temp_dma > NETXEN_DMA_MASK) {
+			pci_unmap_single(port->pdev, temp_dma, len,
+					 PCI_DMA_TODEVICE);
+			spin_lock_irqsave(&tx_bounce_lock, bounce_flags);
+			if (netxen_get_next_bounce_buffer(&tx_bounce_head,
+							  &tx_bounce_tail,
+							  &tmpbi, len)) {
+				spin_unlock_irqrestore(&tx_bounce_lock,
+						       bounce_flags);
+				return NETDEV_TX_BUSY;
+			}
+			spin_unlock_irqrestore(&tx_bounce_lock, bounce_flags);
+			pbuf->tx_bounce_buff = IS_BOUNCE;
+			bounce_data = tx_bounce_ptr[tmpbi.buffer_index] +
+			    tmpbi.buffer_offset;
+
+			bounce_frag_page = virt_to_page(bounce_data);
+			bounce_page_offset = (unsigned long)bounce_data -
+			    (unsigned long)page_address(bounce_frag_page);
+			temp_dma = pci_map_page(port->pdev, bounce_frag_page,
+						bounce_page_offset, len,
+						PCI_DMA_TODEVICE);
+			buffrag->dma = temp_dma;
+			memcpy(bounce_data, page_address(frag->page) + offset,
+			       len);
+			pbuf->bnext = tx_bounce_head;
+		}
+
 		DPRINTK(INFO, "for loop. i=%d k=%d\n", i, k);
 		switch (k) {
 		case 0:
@@ -1116,8 +1301,9 @@ netxen_nic_ioctl(struct net_device *netd
 		if (ifr->ifr_data) {
 			sprintf(dev_name, "%s-%d", NETXEN_NIC_NAME_RSP,
 				port->portnum);
-			nr_bytes = copy_to_user((char *)ifr->ifr_data, dev_name,
-						NETXEN_NIC_NAME_LEN);
+			nr_bytes =
+			    copy_to_user((char __user *)ifr->ifr_data, dev_name,
+					 NETXEN_NIC_NAME_LEN);
 			if (nr_bytes)
 				err = -EIO;
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 8181d43..1da7093 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -85,17 +85,17 @@
 #define CRB_TX_PKT_TIMER		NETXEN_NIC_REG(0x94)
 #define CRB_RX_PKT_CNT			NETXEN_NIC_REG(0x98)
 #define CRB_RX_TMR_CNT			NETXEN_NIC_REG(0x9c)
-#define CRB_INT_THRESH		 NETXEN_NIC_REG(0xa4)
+#define CRB_INT_THRESH			NETXEN_NIC_REG(0xa4)
 
 /* Register for communicating XG link status */
 #define CRB_XG_STATE			NETXEN_NIC_REG(0xa0)
 
 /* Register for communicating card temperature */
 /* Upper 16 bits are temperature value. Lower 16 bits are the state */
-#define CRB_TEMP_STATE		 NETXEN_NIC_REG(0xa8)
-#define nx_get_temp_val(x)	     ((x) >> 16)
-#define nx_get_temp_state(x)	   ((x) & 0xffff)
-#define nx_encode_temp(val, state)     (((val) << 16) | (state))
+#define CRB_TEMP_STATE			NETXEN_NIC_REG(0xa8)
+#define nx_get_temp_val(x)		((x) >> 16)
+#define nx_get_temp_state(x)		((x) & 0xffff)
+#define nx_encode_temp(val, state)	(((val) << 16) | (state))
 
 /* Debug registers for controlling NIC pkt gen agent */
 #define CRB_AGENT_GO			NETXEN_NIC_REG(0xb0)
