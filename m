From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 12 Jan 2008 18:30:10 -0500
Message-ID: <20080112233010.GA32588@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:58082 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbYALXaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 18:30:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                             |   10 ++-
 drivers/net/3c509.c                     |    4 +
 drivers/net/Kconfig                     |   20 +++---
 drivers/net/fs_enet/fs_enet-main.c      |   11 ++-
 drivers/net/loopback.c                  |    2 +-
 drivers/net/netxen/netxen_nic.h         |   69 +++++++++--------
 drivers/net/netxen/netxen_nic_init.c    |   20 ++---
 drivers/net/netxen/netxen_nic_main.c    |   70 ++++++-----------
 drivers/net/netxen/netxen_nic_niu.c     |    8 +-
 drivers/net/r8169.c                     |    2 +-
 drivers/net/sky2.c                      |   48 +++---------
 drivers/net/sky2.h                      |    4 +-
 drivers/net/tulip/de4x5.c               |  127 +++++++++++--------------------
 drivers/net/tulip/tulip_core.c          |    3 +-
 drivers/net/tulip/xircom_cb.c           |   54 ++++++-------
 drivers/net/usb/asix.c                  |    6 +-
 drivers/net/wireless/rt2x00/rt2500usb.c |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c |   20 ++++-
 drivers/net/wireless/rt2x00/rt2x00usb.c |   17 ++++-
 drivers/net/wireless/rt2x00/rt61pci.c   |   12 +++
 20 files changed, 238 insertions(+), 271 deletions(-)

Al Viro (3):
      xircom_cb endianness fixes
      de4x5 fixes
      endianness noise in tulip_core

Anton Vorontsov (1):
      fs_enet: check for phydev existence in the ethtool handlers

Dhananjay Phadke (1):
      netxen: fix byte-swapping in tx and rx

Emil Medve (1):
      Fixed a small typo in the loopback driver

Francois Romieu (1):
      r8169: fix missing loop variable increment

Ivo van Doorn (2):
      rt2x00: Corectly initialize rt2500usb MAC
      rt2x00: Put 802.11 data on 4 byte boundary

Jens Osterkamp (1):
      spidernet MAINTAINERship update

Krzysztof Helt (1):
      3c509: PnP resource management fix

Mattias Nissler (1):
      rt2x00: Allow rt61 to catch up after a missing tx report

Russ Dill (1):
      [usb netdev] asix: fix regression

Stephen Hemminger (3):
      ip1000: menu location change
      sky2: large memory workaround.
      sky2: remove check for PCI wakeup setting from BIOS

dhananjay@netxen.com (4):
      netxen: update MAINTAINERS
      netxen: update driver version
      netxen: stop second phy correctly
      netxen: optimize tx handling

diff --git a/MAINTAINERS b/MAINTAINERS
index b4f611c..92aa0a7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2739,8 +2739,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
 S:	Maintained
 
 NETXEN (1/10) GbE SUPPORT
-P:	Amit S. Kale
-M:	amitkale@netxen.com
+P:	Dhananjay Phadke
+M:	dhananjay@netxen.com
 L:	netdev@vger.kernel.org
 W:	http://www.netxen.com
 S:	Supported
@@ -3611,8 +3611,10 @@ L:	linux-kernel@vger.kernel.org ?
 S:	Supported
 
 SPIDERNET NETWORK DRIVER for CELL
-P:	Linas Vepstas
-M:	linas@austin.ibm.com
+P:	Ishizaki Kou
+M:	kou.ishizaki@toshiba.co.jp
+P:	Jens Osterkamp
+M:	jens@de.ibm.com
 L:	netdev@vger.kernel.org
 S:	Supported
 
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index edda6e1..8fafac9 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -385,6 +385,7 @@ static int __init el3_probe(int card_idx)
 #if defined(__ISAPNP__)
 	static int pnp_cards;
 	struct pnp_dev *idev = NULL;
+	int pnp_found = 0;
 
 	if (nopnp == 1)
 		goto no_pnp;
@@ -430,6 +431,7 @@ __again:
 			pnp_cards++;
 
 			netdev_boot_setup_check(dev);
+			pnp_found = 1;
 			goto found;
 		}
 	}
@@ -560,6 +562,8 @@ no_pnp:
 	lp = netdev_priv(dev);
 #if defined(__ISAPNP__)
 	lp->dev = &idev->dev;
+	if (pnp_found)
+		lp->type = EL3_PNP;
 #endif
 	err = el3_common_init(dev);
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..114771a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -166,16 +166,6 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
-config IP1000
-	tristate "IP1000 Gigabit Ethernet support"
-	depends on PCI && EXPERIMENTAL
-	select MII
-	---help---
-	  This driver supports IP1000 gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ipg.  This is recommended.
-
 source "drivers/net/arcnet/Kconfig"
 
 source "drivers/net/phy/Kconfig"
@@ -1992,6 +1982,16 @@ config E1000E
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
+config IP1000
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
+	select MII
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 3e1a57a..c83bd65 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -894,14 +894,21 @@ static void fs_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 static int fs_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+
+	if (!fep->phydev)
+		return -ENODEV;
+
 	return phy_ethtool_gset(fep->phydev, cmd);
 }
 
 static int fs_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	phy_ethtool_sset(fep->phydev, cmd);
-	return 0;
+
+	if (!fep->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(fep->phydev, cmd);
 }
 
 static int fs_nway_reset(struct net_device *dev)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 662b8d1..fa147cd 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -242,7 +242,7 @@ static void loopback_setup(struct net_device *dev)
 		| NETIF_F_NO_CSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
-		| NETIF_F_NETNS_LOCAL,
+		| NETIF_F_NETNS_LOCAL;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->init = loopback_dev_init;
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index fbc2553..a8f63c4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -65,8 +65,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 4
-#define _NETXEN_NIC_LINUX_SUBVERSION 2
-#define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
+#define _NETXEN_NIC_LINUX_SUBVERSION 18
+#define NETXEN_NIC_LINUX_VERSIONID  "3.4.18"
 
 #define NETXEN_NUM_FLASH_SECTORS (64)
 #define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
@@ -309,23 +309,26 @@ struct netxen_ring_ctx {
 	((cmd_desc)->port_ctxid |= ((var) & 0xF0))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x7f), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
+	(cmd_desc)->flags_opcode = ((cmd_desc)->flags_opcode & \
+		~cpu_to_le16(0x7f)) | cpu_to_le16((val) & 0x7f)
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
+	(cmd_desc)->flags_opcode = ((cmd_desc)->flags_opcode & \
+		~cpu_to_le16((u16)0x3f << 7)) | cpu_to_le16(((val) & 0x3f) << 7)
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
+	(cmd_desc)->num_of_buffers_total_length = \
+		((cmd_desc)->num_of_buffers_total_length & \
+		~cpu_to_le32(0xff)) | cpu_to_le32((val) & 0xff)
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xffffff00), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
+	(cmd_desc)->num_of_buffers_total_length = \
+		((cmd_desc)->num_of_buffers_total_length & \
+		~cpu_to_le32((u32)0xffffff << 8)) | \
+		cpu_to_le32(((val) & 0xffffff) << 8)
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
+	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003f)
 #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8)
+	((le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8) & 0xffffff)
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
@@ -412,29 +415,29 @@ struct rcv_desc {
 #define netxen_get_sts_desc_lro_last_frag(status_desc)	\
 	(((status_desc)->lro & 0x80) >> 7)
 
-#define netxen_get_sts_port(status_desc)	\
-	(le64_to_cpu((status_desc)->status_desc_data) & 0x0F)
-#define netxen_get_sts_status(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 4) & 0x0F)
-#define netxen_get_sts_type(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 8) & 0x0F)
-#define netxen_get_sts_totallength(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 12) & 0xFFFF)
-#define netxen_get_sts_refhandle(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 28) & 0xFFFF)
-#define netxen_get_sts_prot(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 44) & 0x0F)
+#define netxen_get_sts_port(sts_data)	\
+	((sts_data) & 0x0F)
+#define netxen_get_sts_status(sts_data)	\
+	(((sts_data) >> 4) & 0x0F)
+#define netxen_get_sts_type(sts_data)	\
+	(((sts_data) >> 8) & 0x0F)
+#define netxen_get_sts_totallength(sts_data)	\
+	(((sts_data) >> 12) & 0xFFFF)
+#define netxen_get_sts_refhandle(sts_data)	\
+	(((sts_data) >> 28) & 0xFFFF)
+#define netxen_get_sts_prot(sts_data)	\
+	(((sts_data) >> 44) & 0x0F)
+#define netxen_get_sts_opcode(sts_data)	\
+	(((sts_data) >> 58) & 0x03F)
+
 #define netxen_get_sts_owner(status_desc)	\
 	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
-#define netxen_get_sts_opcode(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 58) & 0x03F)
-
-#define netxen_clear_sts_owner(status_desc)	\
-	((status_desc)->status_desc_data &=	\
-	~cpu_to_le64(((unsigned long long)3) << 56 ))
-#define netxen_set_sts_owner(status_desc, val)	\
-	((status_desc)->status_desc_data |=	\
-	cpu_to_le64(((unsigned long long)((val) & 0x3)) << 56 ))
+#define netxen_set_sts_owner(status_desc, val)	{ \
+	(status_desc)->status_desc_data = \
+		((status_desc)->status_desc_data & \
+		~cpu_to_le64(0x3ULL << 56)) | \
+		cpu_to_le64((u64)((val) & 0x3) << 56); \
+}
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 3758926..485ff93 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1070,16 +1070,17 @@ netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
-	int index = netxen_get_sts_refhandle(desc);
+	u64 sts_data = le64_to_cpu(desc->status_desc_data);
+	int index = netxen_get_sts_refhandle(sts_data);
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = netxen_get_sts_totallength(desc);
+	u32 length = netxen_get_sts_totallength(sts_data);
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
 
-	desc_ctx = netxen_get_sts_type(desc);
+	desc_ctx = netxen_get_sts_type(sts_data);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
 		printk("%s: %s Bad Rcv descriptor ring\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -1119,7 +1120,7 @@ netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	skb = (struct sk_buff *)buffer->skb;
 
 	if (likely(adapter->rx_csum &&
-				netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
+				netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -1209,7 +1210,6 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 			break;
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
-		netxen_clear_sts_owner(desc);
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
@@ -1248,7 +1248,6 @@ int netxen_process_cmd_ring(unsigned long data)
 	struct pci_dev *pdev;
 	struct netxen_skb_frag *frag;
 	u32 i;
-	struct sk_buff *skb = NULL;
 	int done;
 
 	spin_lock(&adapter->tx_lock);
@@ -1278,9 +1277,8 @@ int netxen_process_cmd_ring(unsigned long data)
 	while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
 		buffer = &adapter->cmd_buf_arr[last_consumer];
 		pdev = adapter->pdev;
-		frag = &buffer->frag_array[0];
-		skb = buffer->skb;
-		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
+		if (buffer->skb) {
+			frag = &buffer->frag_array[0];
 			pci_unmap_single(pdev, frag->dma, frag->length,
 					 PCI_DMA_TODEVICE);
 			frag->dma = 0ULL;
@@ -1293,8 +1291,8 @@ int netxen_process_cmd_ring(unsigned long data)
 			}
 
 			adapter->stats.skbfreed++;
-			dev_kfree_skb_any(skb);
-			skb = NULL;
+			dev_kfree_skb_any(buffer->skb);
+			buffer->skb = NULL;
 		} else if (adapter->proc_cmd_buf_counter == 1) {
 			adapter->stats.txnullskb++;
 		}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 454226f..263b55e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -732,11 +732,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	if (adapter->stop_port)
-		adapter->stop_port(adapter);
-
-	netxen_nic_disable_int(adapter);
-
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		init_firmware_done++;
 		netxen_free_hw_resources(adapter);
@@ -919,6 +914,9 @@ static int netxen_nic_close(struct net_device *netdev)
 	netif_stop_queue(netdev);
 	napi_disable(&adapter->napi);
 
+	if (adapter->stop_port)
+		adapter->stop_port(adapter);
+
 	netxen_nic_disable_int(adapter);
 
 	cmd_buff = adapter->cmd_buf_arr;
@@ -996,28 +994,6 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	/*
-	 * Everything is set up. Now, we just need to transmit it out.
-	 * Note that we have to copy the contents of buffer over to
-	 * right place. Later on, this can be optimized out by de-coupling the
-	 * producer index from the buffer index.
-	 */
-      retry_getting_window:
-	spin_lock_bh(&adapter->tx_lock);
-	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
-		spin_unlock_bh(&adapter->tx_lock);
-		/*
-		 * Yield CPU
-		 */
-		if (!in_atomic())
-			schedule();
-		else {
-			for (i = 0; i < 20; i++)
-				cpu_relax();	/*This a nop instr on i386 */
-		}
-		goto retry_getting_window;
-	}
-	local_producer = adapter->cmd_producer;
 	/* There 4 fragments per descriptor */
 	no_of_desc = (frag_count + 3) >> 2;
 	if (netdev->features & NETIF_F_TSO) {
@@ -1031,16 +1007,19 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			}
 		}
 	}
+
+	spin_lock_bh(&adapter->tx_lock);
+	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
+		goto out_requeue;
+	}
+	local_producer = adapter->cmd_producer;
 	k = adapter->cmd_producer;
 	max_tx_desc_count = adapter->max_tx_desc_count;
 	last_cmd_consumer = adapter->last_cmd_consumer;
 	if ((k + no_of_desc) >=
 	    ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
 	     last_cmd_consumer)) {
-		netif_stop_queue(netdev);
-		adapter->flags |= NETXEN_NETDEV_STATUS;
-		spin_unlock_bh(&adapter->tx_lock);
-		return NETDEV_TX_BUSY;
+		goto out_requeue;
 	}
 	k = get_index_range(k, max_tx_desc_count, no_of_desc);
 	adapter->cmd_producer = k;
@@ -1093,6 +1072,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 						  adapter->max_tx_desc_count);
 			hwdesc = &hw->cmd_desc_head[producer];
 			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
+			pbuf = &adapter->cmd_buf_arr[producer];
+			pbuf->skb = NULL;
 		}
 		frag = &skb_shinfo(skb)->frags[i - 1];
 		len = frag->size;
@@ -1148,6 +1129,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 		/* copy the MAC/IP/TCP headers to the cmd descriptor list */
 		hwdesc = &hw->cmd_desc_head[producer];
+		pbuf = &adapter->cmd_buf_arr[producer];
+		pbuf->skb = NULL;
 
 		/* copy the first 64 bytes */
 		memcpy(((void *)hwdesc) + 2,
@@ -1156,6 +1139,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 		if (more_hdr) {
 			hwdesc = &hw->cmd_desc_head[producer];
+			pbuf = &adapter->cmd_buf_arr[producer];
+			pbuf->skb = NULL;
 			/* copy the next 64 bytes - should be enough except
 			 * for pathological case
 			 */
@@ -1167,16 +1152,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	i = netxen_get_cmd_desc_totallength(&hw->cmd_desc_head[saved_producer]);
-
-	hw->cmd_desc_head[saved_producer].flags_opcode =
-		cpu_to_le16(hw->cmd_desc_head[saved_producer].flags_opcode);
-	hw->cmd_desc_head[saved_producer].num_of_buffers_total_length =
-	  cpu_to_le32(hw->cmd_desc_head[saved_producer].
-			  num_of_buffers_total_length);
-
 	spin_lock_bh(&adapter->tx_lock);
-	adapter->stats.txbytes += i;
+	adapter->stats.txbytes += skb->len;
 
 	/* Code to update the adapter considering how many producer threads
 	   are currently working */
@@ -1189,14 +1166,17 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	adapter->stats.xmitfinished++;
-	spin_unlock_bh(&adapter->tx_lock);
-
 	netdev->trans_start = jiffies;
 
-	DPRINTK(INFO, "wrote CMD producer %x to phantom\n", producer);
-
-	DPRINTK(INFO, "Done. Send\n");
+	spin_unlock_bh(&adapter->tx_lock);
 	return NETDEV_TX_OK;
+
+out_requeue:
+	netif_stop_queue(netdev);
+	adapter->flags |= NETXEN_NETDEV_STATUS;
+
+	spin_unlock_bh(&adapter->tx_lock);
+	return NETDEV_TX_BUSY;
 }
 
 static void netxen_watchdog(unsigned long v)
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 5b9e1b3..d04ecb7 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -736,12 +736,12 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 	__u32 mac_cfg;
 	u32 port = physical_port[adapter->portnum];
 
-	if (port != 0)
+	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
+
 	mac_cfg = 0;
-	netxen_xg_soft_reset(mac_cfg);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
-				   &mac_cfg, 4))
+	if (netxen_nic_hw_write_wx(adapter,
+		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), &mac_cfg, 4))
 		return -EIO;
 	return 0;
 }
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index af80309..3acfeea 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2002,7 +2002,7 @@ static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 	u32 clk;
 
 	clk = RTL_R8(Config2) & PCI_Clock_66MHz;
-	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
+	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++, p++) {
 		if ((p->mac_version == mac_version) && (p->clk == clk)) {
 			RTL_W32(0x7c, p->val);
 			break;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 52ec89b..7023bbe 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -944,7 +944,6 @@ static void tx_init(struct sky2_port *sky2)
 	le = get_tx_le(sky2);
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
-	sky2->tx_addr64 = 0;
 }
 
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
@@ -978,13 +977,11 @@ static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
-	u32 hi = upper_32_bits(map);
 
-	if (sky2->rx_addr64 != hi) {
+	if (sizeof(dma_addr_t) > sizeof(u32)) {
 		le = sky2_next_rx(sky2);
-		le->addr = cpu_to_le32(hi);
+		le->addr = cpu_to_le32(upper_32_bits(map));
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->rx_addr64 = upper_32_bits(map + len);
 	}
 
 	le = sky2_next_rx(sky2);
@@ -1480,7 +1477,6 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	struct tx_ring_info *re;
 	unsigned i, len;
 	dma_addr_t mapping;
-	u32 addr64;
 	u16 mss;
 	u8 ctrl;
 
@@ -1493,15 +1489,12 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	addr64 = upper_32_bits(mapping);
 
-	/* Send high bits if changed or crosses boundary */
-	if (addr64 != sky2->tx_addr64 ||
-	    upper_32_bits(mapping + len) != sky2->tx_addr64) {
+	/* Send high bits if needed */
+	if (sizeof(dma_addr_t) > sizeof(u32)) {
 		le = get_tx_le(sky2);
-		le->addr = cpu_to_le32(addr64);
+		le->addr = cpu_to_le32(upper_32_bits(mapping));
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->tx_addr64 = upper_32_bits(mapping + len);
 	}
 
 	/* Check for TCP Segmentation Offload */
@@ -1582,13 +1575,12 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
-		addr64 = upper_32_bits(mapping);
-		if (addr64 != sky2->tx_addr64) {
+
+		if (sizeof(dma_addr_t) > sizeof(u32)) {
 			le = get_tx_le(sky2);
-			le->addr = cpu_to_le32(addr64);
+			le->addr = cpu_to_le32(upper_32_bits(mapping));
 			le->ctrl = 0;
 			le->opcode = OP_ADDR64 | HW_OWNER;
-			sky2->tx_addr64 = addr64;
 		}
 
 		le = get_tx_le(sky2);
@@ -3957,7 +3949,7 @@ static __exit void sky2_debug_cleanup(void)
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
-						     int highmem, int wol)
+						     int highmem)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -3997,7 +3989,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
 	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
-	sky2->wol = wol;
+	sky2->wol = sky2_wol_supported(hw) & WAKE_MAGIC;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
@@ -4094,24 +4086,12 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 	return err;
 }
 
-static int __devinit pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	if (!pm)
-		return 0;
-	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
-		return 0;
-	return value & PCI_PM_CTRL_PME_ENABLE;
-}
-
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
-	int err, using_dac = 0, wol_default;
+	int err, using_dac = 0;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4144,8 +4124,6 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
-
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
@@ -4189,7 +4167,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	sky2_reset(hw);
 
-	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
+	dev = sky2_init_netdev(hw, 0, using_dac);
 	if (!dev) {
 		err = -ENOMEM;
 		goto err_out_free_pci;
@@ -4226,7 +4204,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	if (hw->ports > 1) {
 		struct net_device *dev1;
 
-		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
+		dev1 = sky2_init_netdev(hw, 1, using_dac);
 		if (!dev1)
 			dev_warn(&pdev->dev, "allocation for second device failed\n");
 		else if ((err = register_netdev(dev1))) {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index bc646a4..ffe9b8a 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1991,14 +1991,14 @@ struct sky2_port {
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
 	u16		     tx_next;		/* debug only */
-	u32		     tx_addr64;
+
 	u16		     tx_pending;
 	u16		     tx_last_mss;
 	u32		     tx_tcpsum;
 
 	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
-	u32		     rx_addr64;
+
 	u16		     rx_next;		/* next re to check */
 	u16		     rx_put;		/* next le index to use */
 	u16		     rx_pending;
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 41f34bb..6e8b18a 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -911,7 +911,7 @@ static int     de4x5_init(struct net_device *dev);
 static int     de4x5_sw_reset(struct net_device *dev);
 static int     de4x5_rx(struct net_device *dev);
 static int     de4x5_tx(struct net_device *dev);
-static int     de4x5_ast(struct net_device *dev);
+static void    de4x5_ast(struct net_device *dev);
 static int     de4x5_txur(struct net_device *dev);
 static int     de4x5_rx_ovfc(struct net_device *dev);
 
@@ -984,11 +984,9 @@ static int     test_bad_enet(struct net_device *dev, int status);
 static int     an_exception(struct de4x5_private *lp);
 static char    *build_setup_frame(struct net_device *dev, int mode);
 static void    disable_ast(struct net_device *dev);
-static void    enable_ast(struct net_device *dev, u32 time_out);
 static long    de4x5_switch_mac_port(struct net_device *dev);
 static int     gep_rd(struct net_device *dev);
 static void    gep_wr(s32 data, struct net_device *dev);
-static void    timeout(struct net_device *dev, void (*fn)(u_long data), u_long data, u_long msec);
 static void    yawn(struct net_device *dev, int state);
 static void    de4x5_parse_params(struct net_device *dev);
 static void    de4x5_dbg_open(struct net_device *dev);
@@ -1139,6 +1137,8 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 	lp->gendev = gendev;
 	spin_lock_init(&lp->lock);
 	init_timer(&lp->timer);
+	lp->timer.function = (void (*)(unsigned long))de4x5_ast;
+	lp->timer.data = (unsigned long)dev;
 	de4x5_parse_params(dev);
 
 	/*
@@ -1311,7 +1311,7 @@ de4x5_open(struct net_device *dev)
     lp->state = OPEN;
     de4x5_dbg_open(dev);
 
-    if (request_irq(dev->irq, (void *)de4x5_interrupt, IRQF_SHARED,
+    if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 		                                     lp->adapter_name, dev)) {
 	printk("de4x5_open(): Requested IRQ%d is busy - attemping FAST/SHARE...", dev->irq);
 	if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
@@ -1737,27 +1737,29 @@ de4x5_tx(struct net_device *dev)
     return 0;
 }
 
-static int
+static void
 de4x5_ast(struct net_device *dev)
 {
-    struct de4x5_private *lp = netdev_priv(dev);
-    int next_tick = DE4X5_AUTOSENSE_MS;
+	struct de4x5_private *lp = netdev_priv(dev);
+	int next_tick = DE4X5_AUTOSENSE_MS;
+	int dt;
 
-    disable_ast(dev);
+	if (lp->useSROM)
+		next_tick = srom_autoconf(dev);
+	else if (lp->chipset == DC21140)
+		next_tick = dc21140m_autoconf(dev);
+	else if (lp->chipset == DC21041)
+		next_tick = dc21041_autoconf(dev);
+	else if (lp->chipset == DC21040)
+		next_tick = dc21040_autoconf(dev);
+	lp->linkOK = 0;
 
-    if (lp->useSROM) {
-	next_tick = srom_autoconf(dev);
-    } else if (lp->chipset == DC21140) {
-	next_tick = dc21140m_autoconf(dev);
-    } else if (lp->chipset == DC21041) {
-	next_tick = dc21041_autoconf(dev);
-    } else if (lp->chipset == DC21040) {
-	next_tick = dc21040_autoconf(dev);
-    }
-    lp->linkOK = 0;
-    enable_ast(dev, next_tick);
+	dt = (next_tick * HZ) / 1000;
 
-    return 0;
+	if (!dt)
+		dt = 1;
+
+	mod_timer(&lp->timer, jiffies + dt);
 }
 
 static int
@@ -2174,7 +2176,7 @@ srom_search(struct net_device *dev, struct pci_dev *pdev)
 	for (j=0, i=0; i<ETH_ALEN; i++) {
 	    j += (u_char) *((u_char *)&lp->srom + SROM_HWADD + i);
 	}
-	if ((j != 0) && (j != 0x5fa)) {
+	if (j != 0 && j != 6 * 0xff) {
 	    last.chipset = device;
 	    last.bus = pb;
 	    last.irq = irq;
@@ -2371,30 +2373,19 @@ static struct pci_driver de4x5_pci_driver = {
 static int
 autoconf_media(struct net_device *dev)
 {
-    struct de4x5_private *lp = netdev_priv(dev);
-    u_long iobase = dev->base_addr;
-    int next_tick = DE4X5_AUTOSENSE_MS;
+	struct de4x5_private *lp = netdev_priv(dev);
+	u_long iobase = dev->base_addr;
 
-    lp->linkOK = 0;
-    lp->c_media = AUTO;                     /* Bogus last media */
-    disable_ast(dev);
-    inl(DE4X5_MFC);                         /* Zero the lost frames counter */
-    lp->media = INIT;
-    lp->tcount = 0;
+	disable_ast(dev);
 
-    if (lp->useSROM) {
-	next_tick = srom_autoconf(dev);
-    } else if (lp->chipset == DC21040) {
-	next_tick = dc21040_autoconf(dev);
-    } else if (lp->chipset == DC21041) {
-	next_tick = dc21041_autoconf(dev);
-    } else if (lp->chipset == DC21140) {
-	next_tick = dc21140m_autoconf(dev);
-    }
+	lp->c_media = AUTO;                     /* Bogus last media */
+	inl(DE4X5_MFC);                         /* Zero the lost frames counter */
+	lp->media = INIT;
+	lp->tcount = 0;
 
-    enable_ast(dev, next_tick);
+	de4x5_ast(dev);
 
-    return (lp->media);
+	return lp->media;
 }
 
 /*
@@ -4018,20 +4009,22 @@ DevicePresent(struct net_device *dev, u_long aprom_addr)
 	    outl(0, aprom_addr);       /* Reset Ethernet Address ROM Pointer */
 	}
     } else {                           /* Read new srom */
-	u_short tmp, *p = (short *)((char *)&lp->srom + SROM_HWADD);
+	u_short tmp;
+	__le16 *p = (__le16 *)((char *)&lp->srom + SROM_HWADD);
 	for (i=0; i<(ETH_ALEN>>1); i++) {
 	    tmp = srom_rd(aprom_addr, (SROM_HWADD>>1) + i);
-	    *p = le16_to_cpu(tmp);
-	    j += *p++;
+	    j += tmp;	/* for check for 0:0:0:0:0:0 or ff:ff:ff:ff:ff:ff */
+	    *p = cpu_to_le16(tmp);
 	}
-	if ((j == 0) || (j == 0x2fffd)) {
-	    return;
+	if (j == 0 || j == 3 * 0xffff) {
+		/* could get 0 only from all-0 and 3 * 0xffff only from all-1 */
+		return;
 	}
 
-	p=(short *)&lp->srom;
+	p = (__le16 *)&lp->srom;
 	for (i=0; i<(sizeof(struct de4x5_srom)>>1); i++) {
 	    tmp = srom_rd(aprom_addr, i);
-	    *p++ = le16_to_cpu(tmp);
+	    *p++ = cpu_to_le16(tmp);
 	}
 	de4x5_dbg_srom((struct de4x5_srom *)&lp->srom);
     }
@@ -5161,21 +5154,10 @@ build_setup_frame(struct net_device *dev, int mode)
 }
 
 static void
-enable_ast(struct net_device *dev, u32 time_out)
-{
-    timeout(dev, (void *)&de4x5_ast, (u_long)dev, time_out);
-
-    return;
-}
-
-static void
 disable_ast(struct net_device *dev)
 {
-    struct de4x5_private *lp = netdev_priv(dev);
-
-    del_timer(&lp->timer);
-
-    return;
+	struct de4x5_private *lp = netdev_priv(dev);
+	del_timer_sync(&lp->timer);
 }
 
 static long
@@ -5245,29 +5227,6 @@ gep_rd(struct net_device *dev)
 }
 
 static void
-timeout(struct net_device *dev, void (*fn)(u_long data), u_long data, u_long msec)
-{
-    struct de4x5_private *lp = netdev_priv(dev);
-    int dt;
-
-    /* First, cancel any pending timer events */
-    del_timer(&lp->timer);
-
-    /* Convert msec to ticks */
-    dt = (msec * HZ) / 1000;
-    if (dt==0) dt=1;
-
-    /* Set up timer */
-    init_timer(&lp->timer);
-    lp->timer.expires = jiffies + dt;
-    lp->timer.function = fn;
-    lp->timer.data = data;
-    add_timer(&lp->timer);
-
-    return;
-}
-
-static void
 yawn(struct net_device *dev, int state)
 {
     struct de4x5_private *lp = netdev_priv(dev);
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index e5e2c9c..ed600bf 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -797,7 +797,8 @@ static int tulip_close (struct net_device *dev)
 
 		tp->rx_ring[i].status = 0;	/* Not owned by Tulip chip. */
 		tp->rx_ring[i].length = 0;
-		tp->rx_ring[i].buffer1 = 0xBADF00D0;	/* An invalid address. */
+		/* An invalid address. */
+		tp->rx_ring[i].buffer1 = cpu_to_le32(0xBADF00D0);
 		if (skb) {
 			pci_unmap_single(tp->pdev, mapping, PKT_BUF_SZ,
 					 PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 70befe3..8fc7274 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -83,8 +83,8 @@ static int bufferoffsets[NUMDESCRIPTORS] = {128,2048,4096,6144};
 struct xircom_private {
 	/* Send and receive buffers, kernel-addressable and dma addressable forms */
 
-	unsigned int *rx_buffer;
-	unsigned int *tx_buffer;
+	__le32 *rx_buffer;
+	__le32 *tx_buffer;
 
 	dma_addr_t rx_dma_handle;
 	dma_addr_t tx_dma_handle;
@@ -412,19 +412,20 @@ static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* FIXME: The specification tells us that the length we send HAS to be a multiple of
 			   4 bytes. */
 
-			card->tx_buffer[4*desc+1] = skb->len;
-			if (desc == NUMDESCRIPTORS-1)
-				card->tx_buffer[4*desc+1] |= (1<<25);  /* bit 25: last descriptor of the ring */
+			card->tx_buffer[4*desc+1] = cpu_to_le32(skb->len);
+			if (desc == NUMDESCRIPTORS - 1) /* bit 25: last descriptor of the ring */
+				card->tx_buffer[4*desc+1] |= cpu_to_le32(1<<25);  
 
-			card->tx_buffer[4*desc+1] |= 0xF0000000;
+			card->tx_buffer[4*desc+1] |= cpu_to_le32(0xF0000000);
 						 /* 0xF0... means want interrupts*/
 			card->tx_skb[desc] = skb;
 
 			wmb();
 			/* This gives the descriptor to the card */
-			card->tx_buffer[4*desc] = 0x80000000;
+			card->tx_buffer[4*desc] = cpu_to_le32(0x80000000);
 			trigger_transmit(card);
-			if (((int)card->tx_buffer[nextdescriptor*4])<0) {	/* next descriptor is occupied... */
+			if (card->tx_buffer[nextdescriptor*4] & cpu_to_le32(0x8000000)) {
+				/* next descriptor is occupied... */
 				netif_stop_queue(dev);
 			}
 			card->transmit_used = nextdescriptor;
@@ -590,8 +591,7 @@ descriptors and programs the addresses into the card.
 */
 static void setup_descriptors(struct xircom_private *card)
 {
-	unsigned int val;
-	unsigned int address;
+	u32 address;
 	int i;
 	enter("setup_descriptors");
 
@@ -604,16 +604,16 @@ static void setup_descriptors(struct xircom_private *card)
 	for (i=0;i<NUMDESCRIPTORS;i++ ) {
 
 		/* Rx Descr0: It's empty, let the card own it, no errors -> 0x80000000 */
-		card->rx_buffer[i*4 + 0] = 0x80000000;
+		card->rx_buffer[i*4 + 0] = cpu_to_le32(0x80000000);
 		/* Rx Descr1: buffer 1 is 1536 bytes, buffer 2 is 0 bytes */
-		card->rx_buffer[i*4 + 1] = 1536;
-		if (i==NUMDESCRIPTORS-1)
-			card->rx_buffer[i*4 + 1] |= (1 << 25); /* bit 25 is "last descriptor" */
+		card->rx_buffer[i*4 + 1] = cpu_to_le32(1536);
+		if (i == NUMDESCRIPTORS - 1) /* bit 25 is "last descriptor" */
+			card->rx_buffer[i*4 + 1] |= cpu_to_le32(1 << 25);
 
 		/* Rx Descr2: address of the buffer
 		   we store the buffer at the 2nd half of the page */
 
-		address = (unsigned long) card->rx_dma_handle;
+		address = card->rx_dma_handle;
 		card->rx_buffer[i*4 + 2] = cpu_to_le32(address + bufferoffsets[i]);
 		/* Rx Desc3: address of 2nd buffer -> 0 */
 		card->rx_buffer[i*4 + 3] = 0;
@@ -621,9 +621,8 @@ static void setup_descriptors(struct xircom_private *card)
 
 	wmb();
 	/* Write the receive descriptor ring address to the card */
-	address = (unsigned long) card->rx_dma_handle;
-	val = cpu_to_le32(address);
-	outl(val, card->io_port + CSR3);	/* Receive descr list address */
+	address = card->rx_dma_handle;
+	outl(address, card->io_port + CSR3);	/* Receive descr list address */
 
 
 	/* transmit descriptors */
@@ -633,13 +632,13 @@ static void setup_descriptors(struct xircom_private *card)
 		/* Tx Descr0: Empty, we own it, no errors -> 0x00000000 */
 		card->tx_buffer[i*4 + 0] = 0x00000000;
 		/* Tx Descr1: buffer 1 is 1536 bytes, buffer 2 is 0 bytes */
-		card->tx_buffer[i*4 + 1] = 1536;
-		if (i==NUMDESCRIPTORS-1)
-			card->tx_buffer[i*4 + 1] |= (1 << 25); /* bit 25 is "last descriptor" */
+		card->tx_buffer[i*4 + 1] = cpu_to_le32(1536);
+		if (i == NUMDESCRIPTORS - 1) /* bit 25 is "last descriptor" */
+			card->tx_buffer[i*4 + 1] |= cpu_to_le32(1 << 25);
 
 		/* Tx Descr2: address of the buffer
 		   we store the buffer at the 2nd half of the page */
-		address = (unsigned long) card->tx_dma_handle;
+		address = card->tx_dma_handle;
 		card->tx_buffer[i*4 + 2] = cpu_to_le32(address + bufferoffsets[i]);
 		/* Tx Desc3: address of 2nd buffer -> 0 */
 		card->tx_buffer[i*4 + 3] = 0;
@@ -647,9 +646,8 @@ static void setup_descriptors(struct xircom_private *card)
 
 	wmb();
 	/* wite the transmit descriptor ring to the card */
-	address = (unsigned long) card->tx_dma_handle;
-	val =cpu_to_le32(address);
-	outl(val, card->io_port + CSR4);	/* xmit descr list address */
+	address = card->tx_dma_handle;
+	outl(address, card->io_port + CSR4);	/* xmit descr list address */
 
 	leave("setup_descriptors");
 }
@@ -1180,7 +1178,7 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 		int status;
 
 		enter("investigate_read_descriptor");
-		status = card->rx_buffer[4*descnr];
+		status = le32_to_cpu(card->rx_buffer[4*descnr]);
 
 		if ((status > 0)) {	/* packet received */
 
@@ -1210,7 +1208,7 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 
 		      out:
 			/* give the buffer back to the card */
-			card->rx_buffer[4*descnr] =  0x80000000;
+			card->rx_buffer[4*descnr] =  cpu_to_le32(0x80000000);
 			trigger_receive(card);
 		}
 
@@ -1226,7 +1224,7 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
 
 		enter("investigate_write_descriptor");
 
-		status = card->tx_buffer[4*descnr];
+		status = le32_to_cpu(card->tx_buffer[4*descnr]);
 #if 0
 		if (status & 0x8000) {	/* Major error */
 			printk(KERN_ERR "Major transmit error status %x \n", status);
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 1249f44..569028b 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -202,10 +202,10 @@ static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 		buf,
 		size,
 		USB_CTRL_GET_TIMEOUT);
-	if (err >= 0 && err < size)
-		err = -EINVAL;
-	if (!err)
+	if (err == size)
 		memcpy(data, buf, size);
+	else if (err >= 0)
+		err = -EINVAL;
 	kfree(buf);
 
 out:
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 50775f9..18b1f91 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -257,7 +257,7 @@ static const struct rt2x00debug rt2500usb_rt2x00debug = {
 static void rt2500usb_config_mac_addr(struct rt2x00_dev *rt2x00dev,
 				      __le32 *mac)
 {
-	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, &mac,
+	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, mac,
 				      (3 * sizeof(__le16)));
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 2780df0..6d5d9ab 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -124,7 +124,10 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 	struct data_entry *entry;
 	struct data_desc *rxd;
 	struct sk_buff *skb;
+	struct ieee80211_hdr *hdr;
 	struct rxdata_entry_desc desc;
+	int header_size;
+	int align;
 	u32 word;
 
 	while (1) {
@@ -138,17 +141,26 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 		memset(&desc, 0x00, sizeof(desc));
 		rt2x00dev->ops->lib->fill_rxdone(entry, &desc);
 
+		hdr = (struct ieee80211_hdr *)entry->data_addr;
+		header_size =
+		    ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_control));
+
+		/*
+		 * The data behind the ieee80211 header must be
+		 * aligned on a 4 byte boundary.
+		 */
+		align = NET_IP_ALIGN + (2 * (header_size % 4 == 0));
+
 		/*
 		 * Allocate the sk_buffer, initialize it and copy
 		 * all data into it.
 		 */
-		skb = dev_alloc_skb(desc.size + NET_IP_ALIGN);
+		skb = dev_alloc_skb(desc.size + align);
 		if (!skb)
 			return;
 
-		skb_reserve(skb, NET_IP_ALIGN);
-		skb_put(skb, desc.size);
-		memcpy(skb->data, entry->data_addr, desc.size);
+		skb_reserve(skb, align);
+		memcpy(skb_put(skb, desc.size), entry->data_addr, desc.size);
 
 		/*
 		 * Send the frame to rt2x00lib for further processing.
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 1f5675d..ab4797e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -221,7 +221,9 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	struct data_ring *ring = entry->ring;
 	struct rt2x00_dev *rt2x00dev = ring->rt2x00dev;
 	struct sk_buff *skb;
+	struct ieee80211_hdr *hdr;
 	struct rxdata_entry_desc desc;
+	int header_size;
 	int frame_size;
 
 	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags) ||
@@ -253,9 +255,20 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	skb_put(skb, frame_size);
 
 	/*
-	 * Trim the skb_buffer to only contain the valid
-	 * frame data (so ignore the device's descriptor).
+	 * The data behind the ieee80211 header must be
+	 * aligned on a 4 byte boundary.
+	 * After that trim the entire buffer down to only
+	 * contain the valid frame data excluding the device
+	 * descriptor.
 	 */
+	hdr = (struct ieee80211_hdr *)entry->skb->data;
+	header_size =
+	    ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_control));
+
+	if (header_size % 4 == 0) {
+		skb_push(entry->skb, 2);
+		memmove(entry->skb->data, entry->skb->data + 2, skb->len - 2);
+	}
 	skb_trim(entry->skb, desc.size);
 
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 01dbef1..ecae968 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1738,6 +1738,7 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 {
 	struct data_ring *ring;
 	struct data_entry *entry;
+	struct data_entry *entry_done;
 	struct data_desc *txd;
 	u32 word;
 	u32 reg;
@@ -1791,6 +1792,17 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 		    !rt2x00_get_field32(word, TXD_W0_VALID))
 			return;
 
+		entry_done = rt2x00_get_data_entry_done(ring);
+		while (entry != entry_done) {
+			/* Catch up. Just report any entries we missed as
+			 * failed. */
+			WARNING(rt2x00dev,
+				"TX status report missed for entry %p\n",
+				entry_done);
+			rt2x00lib_txdone(entry_done, TX_FAIL_OTHER, 0);
+			entry_done = rt2x00_get_data_entry_done(ring);
+		}
+
 		/*
 		 * Obtain the status about this packet.
 		 */
