From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes, and a new driver
Date: Mon, 29 Oct 2007 14:52:45 -0400
Message-ID: <20071029185245.GA5204@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39464 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926AbXJ2Swq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 14:52:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Largely fixes, except for new embedded driver mpc52xx.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig                         |   37 +-
 drivers/net/Makefile                        |    4 +
 drivers/net/e1000e/e1000.h                  |    5 +-
 drivers/net/e1000e/netdev.c                 |  425 ++---------
 drivers/net/ehea/ehea.h                     |    2 +-
 drivers/net/ehea/ehea_main.c                |   21 +
 drivers/net/fec_mpc52xx.c                   | 1112 +++++++++++++++++++++++++++
 drivers/net/fec_mpc52xx.h                   |  313 ++++++++
 drivers/net/fec_mpc52xx_phy.c               |  198 +++++
 drivers/net/irda/au1k_ir.c                  |   11 +-
 drivers/net/pcmcia/3c574_cs.c               |    2 +-
 drivers/net/pcmcia/3c589_cs.c               |    2 +-
 drivers/net/pcmcia/axnet_cs.c               |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c             |    2 +-
 drivers/net/pcmcia/pcnet_cs.c               |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c            |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c             |    2 +-
 drivers/net/r8169.c                         |   12 +-
 drivers/net/ucc_geth.c                      |   15 +-
 drivers/net/wireless/b43/main.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/ipw2100.c              |   11 +-
 drivers/net/wireless/ipw2200.c              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 ++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   56 ++-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
 drivers/net/wireless/rtl8187_dev.c          |   20 +-
 drivers/serial/serial_cs.c                  |    2 +-
 29 files changed, 1895 insertions(+), 437 deletions(-)
 create mode 100644 drivers/net/fec_mpc52xx.c
 create mode 100644 drivers/net/fec_mpc52xx.h
 create mode 100644 drivers/net/fec_mpc52xx_phy.c

Anton Blanchard (3):
      ipw2100/ipw2200: jiffies_round -> jiffies_round_relative
      rt2x00: jiffies_round -> jiffies_round_relative
      b43/b43legacy: jiffies_round -> jiffies_round_relative

Auke Kok (4):
      e1000e: Fix jumbo frame receive code.
      e1000e: Fix PBA calculation for jumbo frame packets
      e1000e: Re-enable SECRC - crc stripping
      e1000e: Remove legacy jumbo frame receive code

Domen Puncer (1):
      FEC - fast ethernet controller for mpc52xx

Francois Romieu (2):
      ipg: missing Kconfig dependency
      ipg: Kconfig whitepaces/tab damages

Jan-Bernd Themann (1):
      ehea: add kexec support

Jeff Garzik (1):
      drivers/net/irda/au1k_ir: fix obvious irq handler bugs

Joakim Tjernlund (1):
      Fix ethernet multicast for ucc_geth.

Komuro (1):
      netdrvr/pcmcia: use IRQ_TYPE_DYNAMIC_SHARING flag for irq.Attributes.

Michael Wu (1):
      rtl8187: Allow multicast frames

Mohamed Abbas (3):
      iwl4965: fix scan problem
      iwl3945: cancel scan on rxon command
      iwl3945: fix direct scan problem

Stephen Hemminger (2):
      r8169: napi config
      r8169: remove poll_locked logic

Tomas Winkler (1):
      iwlwifi: fix sending probe request in iwl 4965

mabbas (1):
      iwl4965: fix driver hang related to hardware scan

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 86b8641..867cb73 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -166,13 +166,14 @@ config NET_SB1000
 	  If you don't have this card, of course say N.
 
 config IP1000
-       tristate "IP1000 Gigabit Ethernet support"
-       depends on PCI && EXPERIMENTAL
-       ---help---
-         This driver supports IP1000 gigabit Ethernet cards.
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
+	select MII
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
 
-         To compile this driver as a module, choose M here: the module
-         will be called ipg.  This is recommended.
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
 
 source "drivers/net/arcnet/Kconfig"
 
@@ -1880,6 +1881,30 @@ config FEC2
 	  Say Y here if you want to use the second built-in 10/100 Fast
 	  ethernet controller on some Motorola ColdFire processors.
 
+config FEC_MPC52xx
+	tristate "MPC52xx FEC driver"
+	depends on PPC_MPC52xx
+	select PPC_BESTCOMM
+	select PPC_BESTCOMM_FEC
+	select CRC32
+	select PHYLIB
+	---help---
+	  This option enables support for the MPC5200's on-chip
+	  Fast Ethernet Controller
+	  If compiled as module, it will be called 'fec_mpc52xx.ko'.
+
+config FEC_MPC52xx_MDIO
+	bool "MPC52xx FEC MDIO bus driver"
+	depends on FEC_MPC52xx
+	default y
+	---help---
+	  The MPC5200's FEC can connect to the Ethernet either with
+	  an external MII PHY chip or 10 Mbps 7-wire interface
+	  (Motorola? industry standard).
+	  If your board uses an external PHY connected to FEC, enable this.
+	  If not sure, enable.
+	  If compiled as module, it will be called 'fec_mpc52xx_phy.ko'.
+
 config NE_H8300
 	tristate "NE2000 compatible support for H8/300"
 	depends on H8300
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 5932620..0e5fde4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -96,6 +96,10 @@ obj-$(CONFIG_SHAPER) += shaper.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
+obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
+ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
+	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
+endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
 obj-$(CONFIG_EL2) += 3c503.o 8390.o
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index d2499bb..473f78d 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -122,7 +122,8 @@ struct e1000_buffer {
 			u16 next_to_watch;
 		};
 		/* RX */
-		struct page *page;
+		/* arrays of page information for packet split */
+		struct e1000_ps_page *ps_pages;
 	};
 
 };
@@ -142,8 +143,6 @@ struct e1000_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	/* arrays of page information for packet split */
-	struct e1000_ps_page *ps_pages;
 	struct sk_buff *rx_skb_top;
 
 	struct e1000_queue_stats stats;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 033e124..4fd2e23 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -245,37 +245,36 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 		rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
 
 		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS)
-						     + j];
-			if (j < adapter->rx_ps_pages) {
+			ps_page = &buffer_info->ps_pages[j];
+			if (j >= adapter->rx_ps_pages) {
+				/* all unused desc entries get hw null ptr */
+				rx_desc->read.buffer_addr[j+1] = ~0;
+				continue;
+			}
+			if (!ps_page->page) {
+				ps_page->page = alloc_page(GFP_ATOMIC);
 				if (!ps_page->page) {
-					ps_page->page = alloc_page(GFP_ATOMIC);
-					if (!ps_page->page) {
-						adapter->alloc_rx_buff_failed++;
-						goto no_buffers;
-					}
-					ps_page->dma = pci_map_page(pdev,
-							   ps_page->page,
-							   0, PAGE_SIZE,
-							   PCI_DMA_FROMDEVICE);
-					if (pci_dma_mapping_error(
-							ps_page->dma)) {
-						dev_err(&adapter->pdev->dev,
-						  "RX DMA page map failed\n");
-						adapter->rx_dma_failed++;
-						goto no_buffers;
-					}
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
+				ps_page->dma = pci_map_page(pdev,
+						   ps_page->page,
+						   0, PAGE_SIZE,
+						   PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(ps_page->dma)) {
+					dev_err(&adapter->pdev->dev,
+					  "RX DMA page map failed\n");
+					adapter->rx_dma_failed++;
+					goto no_buffers;
 				}
-				/*
-				 * Refresh the desc even if buffer_addrs
-				 * didn't change because each write-back
-				 * erases this info.
-				 */
-				rx_desc->read.buffer_addr[j+1] =
-				     cpu_to_le64(ps_page->dma);
-			} else {
-				rx_desc->read.buffer_addr[j+1] = ~0;
 			}
+			/*
+			 * Refresh the desc even if buffer_addrs
+			 * didn't change because each write-back
+			 * erases this info.
+			 */
+			rx_desc->read.buffer_addr[j+1] =
+			     cpu_to_le64(ps_page->dma);
 		}
 
 		skb = netdev_alloc_skb(netdev,
@@ -334,94 +333,6 @@ no_buffers:
 }
 
 /**
- * e1000_alloc_rx_buffers_jumbo - Replace used jumbo receive buffers
- *
- * @adapter: address of board private structure
- * @cleaned_count: number of buffers to allocate this pass
- **/
-static void e1000_alloc_rx_buffers_jumbo(struct e1000_adapter *adapter,
-					 int cleaned_count)
-{
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_ring *rx_ring = adapter->rx_ring;
-	struct e1000_rx_desc *rx_desc;
-	struct e1000_buffer *buffer_info;
-	struct sk_buff *skb;
-	unsigned int i;
-	unsigned int bufsz = 256 -
-			     16 /*for skb_reserve */ -
-			     NET_IP_ALIGN;
-
-	i = rx_ring->next_to_use;
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (cleaned_count--) {
-		skb = buffer_info->skb;
-		if (skb) {
-			skb_trim(skb, 0);
-			goto check_page;
-		}
-
-		skb = netdev_alloc_skb(netdev, bufsz);
-		if (!skb) {
-			/* Better luck next round */
-			adapter->alloc_rx_buff_failed++;
-			break;
-		}
-
-		/* Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->skb = skb;
-check_page:
-		/* allocate a new page if necessary */
-		if (!buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
-			if (!buffer_info->page) {
-				adapter->alloc_rx_buff_failed++;
-				break;
-			}
-		}
-
-		if (!buffer_info->dma)
-			buffer_info->dma = pci_map_page(pdev,
-							buffer_info->page, 0,
-							PAGE_SIZE,
-							PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(buffer_info->dma)) {
-			dev_err(&adapter->pdev->dev, "RX DMA page map failed\n");
-			adapter->rx_dma_failed++;
-			break;
-		}
-
-		rx_desc = E1000_RX_DESC(*rx_ring, i);
-		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
-
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-		buffer_info = &rx_ring->buffer_info[i];
-	}
-
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
-		if (i-- == 0)
-			i = (rx_ring->count - 1);
-
-		/* Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
-		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
-	}
-}
-
-/**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  *
@@ -495,10 +406,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			goto next_desc;
 		}
 
-		/* adjust length to remove Ethernet CRC */
-		length -= 4;
-
-		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += length;
 		total_rx_packets++;
 
@@ -554,15 +461,6 @@ next_desc:
 	return cleaned;
 }
 
-static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
-			       u16 length)
-{
-	bi->page = NULL;
-	skb->len += length;
-	skb->data_len += length;
-	skb->truesize += length;
-}
-
 static void e1000_put_txbuf(struct e1000_adapter *adapter,
 			     struct e1000_buffer *buffer_info)
 {
@@ -699,174 +597,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_clean_rx_irq_jumbo - Send received data up the network stack; legacy
- * @adapter: board private structure
- *
- * the return value indicates whether actual cleaning was done, there
- * is no guarantee that everything was cleaned
- **/
-static bool e1000_clean_rx_irq_jumbo(struct e1000_adapter *adapter,
-				     int *work_done, int work_to_do)
-{
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_ring *rx_ring = adapter->rx_ring;
-	struct e1000_rx_desc *rx_desc, *next_rxd;
-	struct e1000_buffer *buffer_info, *next_buffer;
-	u32 length;
-	unsigned int i;
-	int cleaned_count = 0;
-	bool cleaned = 0;
-	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
-
-	i = rx_ring->next_to_clean;
-	rx_desc = E1000_RX_DESC(*rx_ring, i);
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (rx_desc->status & E1000_RXD_STAT_DD) {
-		struct sk_buff *skb;
-		u8 status;
-
-		if (*work_done >= work_to_do)
-			break;
-		(*work_done)++;
-
-		status = rx_desc->status;
-		skb = buffer_info->skb;
-		buffer_info->skb = NULL;
-
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-		next_rxd = E1000_RX_DESC(*rx_ring, i);
-		prefetch(next_rxd);
-
-		next_buffer = &rx_ring->buffer_info[i];
-
-		cleaned = 1;
-		cleaned_count++;
-		pci_unmap_page(pdev,
-			       buffer_info->dma,
-			       PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
-		buffer_info->dma = 0;
-
-		length = le16_to_cpu(rx_desc->length);
-
-		/* errors is only valid for DD + EOP descriptors */
-		if ((status & E1000_RXD_STAT_EOP) &&
-		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
-			/* recycle both page and skb */
-			buffer_info->skb = skb;
-			/* an error means any chain goes out the window too */
-			if (rx_ring->rx_skb_top)
-				dev_kfree_skb(rx_ring->rx_skb_top);
-			rx_ring->rx_skb_top = NULL;
-			goto next_desc;
-		}
-
-#define rxtop rx_ring->rx_skb_top
-		if (!(status & E1000_RXD_STAT_EOP)) {
-			/* this descriptor is only the beginning (or middle) */
-			if (!rxtop) {
-				/* this is the beginning of a chain */
-				rxtop = skb;
-				skb_fill_page_desc(rxtop, 0, buffer_info->page,
-						   0, length);
-			} else {
-				/* this is the middle of a chain */
-				skb_fill_page_desc(rxtop,
-						   skb_shinfo(rxtop)->nr_frags,
-						   buffer_info->page, 0,
-						   length);
-				/* re-use the skb, only consumed the page */
-				buffer_info->skb = skb;
-			}
-			e1000_consume_page(buffer_info, rxtop, length);
-			goto next_desc;
-		} else {
-			if (rxtop) {
-				/* end of the chain */
-				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
-				/* re-use the current skb, we only consumed the
-				 * page */
-				buffer_info->skb = skb;
-				skb = rxtop;
-				rxtop = NULL;
-				e1000_consume_page(buffer_info, skb, length);
-			} else {
-				/* no chain, got EOP, this buf is the packet
-				 * copybreak to save the put_page/alloc_page */
-				if (length <= copybreak &&
-				    skb_tailroom(skb) >= length) {
-					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-							   KM_SKB_DATA_SOFTIRQ);
-					memcpy(skb_tail_pointer(skb),
-					       vaddr, length);
-					kunmap_atomic(vaddr,
-						      KM_SKB_DATA_SOFTIRQ);
-					/* re-use the page, so don't erase
-					 * buffer_info->page */
-					skb_put(skb, length);
-				} else {
-					skb_fill_page_desc(skb, 0,
-							   buffer_info->page, 0,
-							   length);
-					e1000_consume_page(buffer_info, skb,
-							   length);
-				}
-			}
-		}
-
-		/* Receive Checksum Offload XXX recompute due to CRC strip? */
-		e1000_rx_checksum(adapter,
-				  (u32)(status) |
-				  ((u32)(rx_desc->errors) << 24),
-				  le16_to_cpu(rx_desc->csum), skb);
-
-		pskb_trim(skb, skb->len - 4);
-
-		/* probably a little skewed due to removing CRC */
-		total_rx_bytes += skb->len;
-		total_rx_packets++;
-
-		/* eth type trans needs skb->data to point to something */
-		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			ndev_err(netdev, "__pskb_pull_tail failed.\n");
-			dev_kfree_skb(skb);
-			goto next_desc;
-		}
-
-		e1000_receive_skb(adapter, netdev, skb,status,rx_desc->special);
-
-next_desc:
-		rx_desc->status = 0;
-
-		/* return some buffers to hardware, one at a time is too slow */
-		if (cleaned_count >= E1000_RX_BUFFER_WRITE) {
-			adapter->alloc_rx_buf(adapter, cleaned_count);
-			cleaned_count = 0;
-		}
-
-		/* use prefetched values */
-		rx_desc = next_rxd;
-		buffer_info = next_buffer;
-	}
-	rx_ring->next_to_clean = i;
-
-	cleaned_count = e1000_desc_unused(rx_ring);
-	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, cleaned_count);
-
-	adapter->total_rx_packets += total_rx_packets;
-	adapter->total_rx_bytes += total_rx_bytes;
-	return cleaned;
-}
-
-/**
  * e1000_clean_rx_irq_ps - Send received data up the network stack; packet split
  * @adapter: board private structure
  *
@@ -953,7 +683,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		    ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 
-			ps_page = &rx_ring->ps_pages[i * PS_PAGE_BUFFERS];
+			ps_page = &buffer_info->ps_pages[0];
 
 			/* there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping
@@ -965,8 +695,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
 			pci_dma_sync_single_for_device(pdev, ps_page->dma,
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			/* remove the CRC */
-			l1 -= 4;
+
 			skb_put(skb, l1);
 			goto copydone;
 		} /* if */
@@ -977,7 +706,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			if (!length)
 				break;
 
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS) + j];
+			ps_page = &buffer_info->ps_pages[j];
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
 			ps_page->dma = 0;
@@ -988,10 +717,6 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			skb->truesize += length;
 		}
 
-		/* strip the ethernet crc, problem is we're using pages now so
-		 * this whole operation can get a little cpu intensive */
-		pskb_trim(skb, skb->len - 4);
-
 copydone:
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -1043,7 +768,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	struct e1000_ps_page *ps_page;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
 	unsigned int i, j;
 
 	/* Free all the Rx ring sk_buffs */
@@ -1054,9 +778,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_buffer_len,
 						 PCI_DMA_FROMDEVICE);
-			else if (adapter->clean_rx == e1000_clean_rx_irq_jumbo)
-				pci_unmap_page(pdev, buffer_info->dma,
-					       PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			else if (adapter->clean_rx == e1000_clean_rx_irq_ps)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_ps_bsize0,
@@ -1064,19 +785,13 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 			buffer_info->dma = 0;
 		}
 
-		if (buffer_info->page) {
-			put_page(buffer_info->page);
-			buffer_info->page = NULL;
-		}
-
 		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
 
 		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS)
-						     + j];
+			ps_page = &buffer_info->ps_pages[j];
 			if (!ps_page->page)
 				break;
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
@@ -1093,12 +808,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 		rx_ring->rx_skb_top = NULL;
 	}
 
-	size = sizeof(struct e1000_buffer) * rx_ring->count;
-	memset(rx_ring->buffer_info, 0, size);
-	size = sizeof(struct e1000_ps_page)
-	       * (rx_ring->count * PS_PAGE_BUFFERS);
-	memset(rx_ring->ps_pages, 0, size);
-
 	/* Zero out the descriptor ring */
 	memset(rx_ring->desc, 0, rx_ring->size);
 
@@ -1421,7 +1130,8 @@ err:
 int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 {
 	struct e1000_ring *rx_ring = adapter->rx_ring;
-	int size, desc_len, err = -ENOMEM;
+	struct e1000_buffer *buffer_info;
+	int i, size, desc_len, err = -ENOMEM;
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
 	rx_ring->buffer_info = vmalloc(size);
@@ -1429,11 +1139,14 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 		goto err;
 	memset(rx_ring->buffer_info, 0, size);
 
-	rx_ring->ps_pages = kcalloc(rx_ring->count * PS_PAGE_BUFFERS,
-				    sizeof(struct e1000_ps_page),
-				    GFP_KERNEL);
-	if (!rx_ring->ps_pages)
-		goto err;
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		buffer_info->ps_pages = kcalloc(PS_PAGE_BUFFERS,
+						sizeof(struct e1000_ps_page),
+						GFP_KERNEL);
+		if (!buffer_info->ps_pages)
+			goto err_pages;
+	}
 
 	desc_len = sizeof(union e1000_rx_desc_packet_split);
 
@@ -1443,16 +1156,21 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 
 	err = e1000_alloc_ring_dma(adapter, rx_ring);
 	if (err)
-		goto err;
+		goto err_pages;
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 	rx_ring->rx_skb_top = NULL;
 
 	return 0;
+
+err_pages:
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		kfree(buffer_info->ps_pages);
+	}
 err:
 	vfree(rx_ring->buffer_info);
-	kfree(rx_ring->ps_pages);
 	ndev_err(adapter->netdev,
 	"Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
@@ -1518,15 +1236,17 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_ring *rx_ring = adapter->rx_ring;
+	int i;
 
 	e1000_clean_rx_ring(adapter);
 
+	for (i = 0; i < rx_ring->count; i++) {
+		kfree(rx_ring->buffer_info[i].ps_pages);
+	}
+
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
-	kfree(rx_ring->ps_pages);
-	rx_ring->ps_pages = NULL;
-
 	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
 			  rx_ring->dma);
 	rx_ring->desc = NULL;
@@ -2032,9 +1752,11 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 
 		ew32(RFCTL, rfctl);
 
-		/* disable the stripping of CRC because it breaks
-		 * BMC firmware connected over SMBUS */
-		rctl |= E1000_RCTL_DTYP_PS /* | E1000_RCTL_SECRC */;
+		/* Enable Packet split descriptors */
+		rctl |= E1000_RCTL_DTYP_PS;
+		
+		/* Enable hardware CRC frame stripping */
+		rctl |= E1000_RCTL_SECRC;
 
 		psrctl |= adapter->rx_ps_bsize0 >>
 			E1000_PSRCTL_BSIZE0_SHIFT;
@@ -2077,11 +1799,6 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			sizeof(union e1000_rx_desc_packet_split);
 		adapter->clean_rx = e1000_clean_rx_irq_ps;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
-	} else if (adapter->netdev->mtu > ETH_FRAME_LEN + VLAN_HLEN + 4) {
-		rdlen = rx_ring->count *
-			sizeof(struct e1000_rx_desc);
-		adapter->clean_rx = e1000_clean_rx_irq_jumbo;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_jumbo;
 	} else {
 		rdlen = rx_ring->count *
 			sizeof(struct e1000_rx_desc);
@@ -2326,8 +2043,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tx_space, min_tx_space, min_rx_space;
+	u32 pba;
 	u16 hwm;
 
+	ew32(PBA, adapter->pba);
+
 	if (mac->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN ) {
 		/* To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accommodate two full transmit packets,
@@ -2335,11 +2055,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		 * the Rx FIFO should be large enough to accommodate at least
 		 * one full receive packet and is similarly rounded up and
 		 * expressed in KB. */
-		adapter->pba = er32(PBA);
+		pba = er32(PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
-		tx_space = adapter->pba >> 16;
+		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
-		adapter->pba &= 0xffff;
+		pba &= 0xffff;
 		/* the tx fifo also stores 16 bytes of information about the tx
 		 * but don't include ethernet FCS because hardware appends it */
 		min_tx_space = (mac->max_frame_size +
@@ -2355,20 +2075,21 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		/* If current Tx allocation is less than the min Tx FIFO size,
 		 * and the min Tx FIFO size is less than the current Rx FIFO
 		 * allocation, take space away from current Rx allocation */
-		if (tx_space < min_tx_space &&
-		    ((min_tx_space - tx_space) < adapter->pba)) {
-			adapter->pba -= - (min_tx_space - tx_space);
+		if ((tx_space < min_tx_space) &&
+		    ((min_tx_space - tx_space) < pba)) {
+			pba -= min_tx_space - tx_space;
 
 			/* if short on rx space, rx wins and must trump tx
 			 * adjustment or use Early Receive if available */
-			if ((adapter->pba < min_rx_space) &&
+			if ((pba < min_rx_space) &&
 			    (!(adapter->flags & FLAG_HAS_ERT)))
 				/* ERT enabled in e1000_configure_rx */
-				adapter->pba = min_rx_space;
+				pba = min_rx_space;
 		}
+
+		ew32(PBA, pba);
 	}
 
-	ew32(PBA, adapter->pba);
 
 	/* flow control settings */
 	/* The high water mark must be low enough to fit one full frame
@@ -3624,9 +3345,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
-	 * i.e. RXBUFFER_2048 --> size-4096 slab
-	 *  however with the new *_jumbo* routines, jumbo receives will use
-	 *  fragmented skbs */
+	 * i.e. RXBUFFER_2048 --> size-4096 slab */
 
 	if (max_frame <= 256)
 		adapter->rx_buffer_len = 256;
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 4b4b74e..f78e5bf 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0079"
+#define DRV_VERSION	"EHEA_0080"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 0a7e789..f0319f1 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -33,6 +33,9 @@
 #include <linux/if.h>
 #include <linux/list.h>
 #include <linux/if_ether.h>
+#include <linux/notifier.h>
+#include <linux/reboot.h>
+
 #include <net/ip.h>
 
 #include "ehea.h"
@@ -3295,6 +3298,20 @@ static int __devexit ehea_remove(struct of_device *dev)
 	return 0;
 }
 
+static int ehea_reboot_notifier(struct notifier_block *nb,
+				unsigned long action, void *unused)
+{
+	if (action == SYS_RESTART) {
+		ehea_info("Reboot: freeing all eHEA resources");
+		ibmebus_unregister_driver(&ehea_driver);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ehea_reboot_nb = {
+        .notifier_call = ehea_reboot_notifier,
+};
+
 static int check_module_parm(void)
 {
 	int ret = 0;
@@ -3351,6 +3368,8 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 
+	register_reboot_notifier(&ehea_reboot_nb);
+
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
@@ -3362,6 +3381,7 @@ int __init ehea_module_init(void)
 	if (ret) {
 		ehea_error("failed to register capabilities attribute, ret=%d",
 			   ret);
+		unregister_reboot_notifier(&ehea_reboot_nb);
 		ibmebus_unregister_driver(&ehea_driver);
 		goto out;
 	}
@@ -3375,6 +3395,7 @@ static void __exit ehea_module_exit(void)
 	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
+	unregister_reboot_notifier(&ehea_reboot_nb);
 	ehea_destroy_busmap();
 }
 
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
new file mode 100644
index 0000000..fc1cf0b
--- /dev/null
+++ b/drivers/net/fec_mpc52xx.c
@@ -0,0 +1,1112 @@
+/*
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Originally written by Dale Farnsworth <dfarnsworth@mvista.com> and
+ * now maintained by Sylvain Munaut <tnt@246tNt.com>
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ * Copyright (C) 2007  Sylvain Munaut <tnt@246tNt.com>
+ * Copyright (C) 2003-2004  MontaVista, Software, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ *
+ */
+
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/crc32.h>
+#include <linux/hardirq.h>
+#include <linux/delay.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/skbuff.h>
+
+#include <asm/io.h>
+#include <asm/delay.h>
+#include <asm/mpc52xx.h>
+
+#include <sysdev/bestcomm/bestcomm.h>
+#include <sysdev/bestcomm/fec.h>
+
+#include "fec_mpc52xx.h"
+
+#define DRIVER_NAME "mpc52xx-fec"
+
+static irqreturn_t mpc52xx_fec_interrupt(int, void *);
+static irqreturn_t mpc52xx_fec_rx_interrupt(int, void *);
+static irqreturn_t mpc52xx_fec_tx_interrupt(int, void *);
+static void mpc52xx_fec_stop(struct net_device *dev);
+static void mpc52xx_fec_start(struct net_device *dev);
+static void mpc52xx_fec_reset(struct net_device *dev);
+
+static u8 mpc52xx_fec_mac_addr[6];
+module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
+MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
+
+#define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
+		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
+static int debug = -1;	/* the above default */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "debugging messages level");
+
+static void mpc52xx_fec_tx_timeout(struct net_device *dev)
+{
+	dev_warn(&dev->dev, "transmit timed out\n");
+
+	mpc52xx_fec_reset(dev);
+
+	dev->stats.tx_errors++;
+
+	netif_wake_queue(dev);
+}
+
+static void mpc52xx_fec_set_paddr(struct net_device *dev, u8 *mac)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	out_be32(&fec->paddr1, *(u32 *)(&mac[0]));
+	out_be32(&fec->paddr2, (*(u16 *)(&mac[4]) << 16) | FEC_PADDR2_TYPE);
+}
+
+static void mpc52xx_fec_get_paddr(struct net_device *dev, u8 *mac)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	*(u32 *)(&mac[0]) = in_be32(&fec->paddr1);
+	*(u16 *)(&mac[4]) = in_be32(&fec->paddr2) >> 16;
+}
+
+static int mpc52xx_fec_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sock = addr;
+
+	memcpy(dev->dev_addr, sock->sa_data, dev->addr_len);
+
+	mpc52xx_fec_set_paddr(dev, sock->sa_data);
+	return 0;
+}
+
+static void mpc52xx_fec_free_rx_buffers(struct net_device *dev, struct bcom_task *s)
+{
+	while (!bcom_queue_empty(s)) {
+		struct bcom_fec_bd *bd;
+		struct sk_buff *skb;
+
+		skb = bcom_retrieve_buffer(s, NULL, (struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		kfree_skb(skb);
+	}
+}
+
+static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task *rxtsk)
+{
+	while (!bcom_queue_full(rxtsk)) {
+		struct sk_buff *skb;
+		struct bcom_fec_bd *bd;
+
+		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb == NULL)
+			return -EAGAIN;
+
+		/* zero out the initial receive buffers to aid debugging */
+		memset(skb->data, 0, FEC_RX_BUFFER_SIZE);
+
+		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
+
+		bd->status = FEC_RX_BUFFER_SIZE;
+		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
+				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+		bcom_submit_next_buffer(rxtsk, skb);
+	}
+
+	return 0;
+}
+
+/* based on generic_adjust_link from fs_enet-main.c */
+static void mpc52xx_fec_adjust_link(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	int new_state = 0;
+
+	if (phydev->link != PHY_DOWN) {
+		if (phydev->duplex != priv->duplex) {
+			struct mpc52xx_fec __iomem *fec = priv->fec;
+			u32 rcntrl;
+			u32 tcntrl;
+
+			new_state = 1;
+			priv->duplex = phydev->duplex;
+
+			rcntrl = in_be32(&fec->r_cntrl);
+			tcntrl = in_be32(&fec->x_cntrl);
+
+			rcntrl &= ~FEC_RCNTRL_DRT;
+			tcntrl &= ~FEC_TCNTRL_FDEN;
+			if (phydev->duplex == DUPLEX_FULL)
+				tcntrl |= FEC_TCNTRL_FDEN;	/* FD enable */
+			else
+				rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+
+			out_be32(&fec->r_cntrl, rcntrl);
+			out_be32(&fec->x_cntrl, tcntrl);
+		}
+
+		if (phydev->speed != priv->speed) {
+			new_state = 1;
+			priv->speed = phydev->speed;
+		}
+
+		if (priv->link == PHY_DOWN) {
+			new_state = 1;
+			priv->link = phydev->link;
+			netif_schedule(dev);
+			netif_carrier_on(dev);
+			netif_start_queue(dev);
+		}
+
+	} else if (priv->link) {
+		new_state = 1;
+		priv->link = PHY_DOWN;
+		priv->speed = 0;
+		priv->duplex = -1;
+		netif_stop_queue(dev);
+		netif_carrier_off(dev);
+	}
+
+	if (new_state && netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+static int mpc52xx_fec_init_phy(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev;
+	char phy_id[BUS_ID_SIZE];
+
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+			(unsigned int)dev->base_addr, priv->phy_addr);
+
+	priv->link = PHY_DOWN;
+	priv->speed = 0;
+	priv->duplex = -1;
+
+	phydev = phy_connect(dev, phy_id, &mpc52xx_fec_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		dev_err(&dev->dev, "phy_connect failed\n");
+		return PTR_ERR(phydev);
+	}
+	dev_info(&dev->dev, "attached phy %i to driver %s\n",
+			phydev->addr, phydev->drv->name);
+
+	priv->phydev = phydev;
+
+	return 0;
+}
+
+static int mpc52xx_fec_phy_start(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	int err;
+
+	if (!priv->has_phy)
+		return 0;
+
+	err = mpc52xx_fec_init_phy(dev);
+	if (err) {
+		dev_err(&dev->dev, "mpc52xx_fec_init_phy failed\n");
+		return err;
+	}
+
+	/* reset phy - this also wakes it from PDOWN */
+	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(priv->phydev);
+
+	return 0;
+}
+
+static void mpc52xx_fec_phy_stop(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->has_phy)
+		return;
+
+	phy_disconnect(priv->phydev);
+	/* power down phy */
+	phy_stop(priv->phydev);
+	phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
+}
+
+static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
+		struct mii_ioctl_data *mii_data, int cmd)
+{
+	if (!priv->has_phy)
+		return -ENOTSUPP;
+
+	return phy_mii_ioctl(priv->phydev, mii_data, cmd);
+}
+
+static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
+{
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	if (!priv->has_phy)
+		return;
+
+	out_be32(&fec->mii_speed, priv->phy_speed);
+}
+
+static int mpc52xx_fec_open(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	int err = -EBUSY;
+
+	if (request_irq(dev->irq, &mpc52xx_fec_interrupt, IRQF_SHARED,
+	                DRIVER_NAME "_ctrl", dev)) {
+		dev_err(&dev->dev, "ctrl interrupt request failed\n");
+		goto out;
+	}
+	if (request_irq(priv->r_irq, &mpc52xx_fec_rx_interrupt, 0,
+	                DRIVER_NAME "_rx", dev)) {
+		dev_err(&dev->dev, "rx interrupt request failed\n");
+		goto free_ctrl_irq;
+	}
+	if (request_irq(priv->t_irq, &mpc52xx_fec_tx_interrupt, 0,
+	                DRIVER_NAME "_tx", dev)) {
+		dev_err(&dev->dev, "tx interrupt request failed\n");
+		goto free_2irqs;
+	}
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	err = mpc52xx_fec_alloc_rx_buffers(dev, priv->rx_dmatsk);
+	if (err) {
+		dev_err(&dev->dev, "mpc52xx_fec_alloc_rx_buffers failed\n");
+		goto free_irqs;
+	}
+
+	err = mpc52xx_fec_phy_start(dev);
+	if (err)
+		goto free_skbs;
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	mpc52xx_fec_start(dev);
+
+	netif_start_queue(dev);
+
+	return 0;
+
+ free_skbs:
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
+
+ free_irqs:
+	free_irq(priv->t_irq, dev);
+ free_2irqs:
+	free_irq(priv->r_irq, dev);
+ free_ctrl_irq:
+	free_irq(dev->irq, dev);
+ out:
+
+	return err;
+}
+
+static int mpc52xx_fec_close(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+
+	mpc52xx_fec_stop(dev);
+
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
+
+	free_irq(dev->irq, dev);
+	free_irq(priv->r_irq, dev);
+	free_irq(priv->t_irq, dev);
+
+	mpc52xx_fec_phy_stop(dev);
+
+	return 0;
+}
+
+/* This will only be invoked if your driver is _not_ in XOFF state.
+ * What this means is that you need not check it, and that this
+ * invariant will hold if you make sure that the netif_*_queue()
+ * calls are done at the proper times.
+ */
+static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct bcom_fec_bd *bd;
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
+		if (net_ratelimit())
+			dev_err(&dev->dev, "transmit queue overrun\n");
+		return 1;
+	}
+
+	spin_lock_irq(&priv->lock);
+	dev->trans_start = jiffies;
+
+	bd = (struct bcom_fec_bd *)
+		bcom_prepare_next_buffer(priv->tx_dmatsk);
+
+	bd->status = skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
+	bd->skb_pa = dma_map_single(&dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
+
+	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
+
+	if (bcom_queue_full(priv->tx_dmatsk)) {
+		netif_stop_queue(dev);
+	}
+
+	spin_unlock_irq(&priv->lock);
+
+	return 0;
+}
+
+/* This handles BestComm transmit task interrupts
+ */
+static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	spin_lock(&priv->lock);
+
+	while (bcom_buffer_done(priv->tx_dmatsk)) {
+		struct sk_buff *skb;
+		struct bcom_fec_bd *bd;
+		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
+				(struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_TO_DEVICE);
+
+		dev_kfree_skb_irq(skb);
+	}
+
+	netif_wake_queue(dev);
+
+	spin_unlock(&priv->lock);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	while (bcom_buffer_done(priv->rx_dmatsk)) {
+		struct sk_buff *skb;
+		struct sk_buff *rskb;
+		struct bcom_fec_bd *bd;
+		u32 status;
+
+		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
+				(struct bcom_bd **)&bd);
+		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+
+		/* Test for errors in received frame */
+		if (status & BCOM_FEC_RX_BD_ERRORS) {
+			/* Drop packet and reuse the buffer */
+			bd = (struct bcom_fec_bd *)
+				bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+			bd->status = FEC_RX_BUFFER_SIZE;
+			bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
+
+			dev->stats.rx_dropped++;
+
+			continue;
+		}
+
+		/* skbs are allocated on open, so now we allocate a new one,
+		 * and remove the old (with the packet) */
+		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		if (skb) {
+			/* Process the received skb */
+			int length = status & BCOM_FEC_RX_BD_LEN_MASK;
+
+			skb_put(rskb, length - 4);	/* length without CRC32 */
+
+			rskb->dev = dev;
+			rskb->protocol = eth_type_trans(rskb, dev);
+
+			netif_rx(rskb);
+			dev->last_rx = jiffies;
+		} else {
+			/* Can't get a new one : reuse the same & drop pkt */
+			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
+			dev->stats.rx_dropped++;
+
+			skb = rskb;
+		}
+
+		bd = (struct bcom_fec_bd *)
+			bcom_prepare_next_buffer(priv->rx_dmatsk);
+
+		bd->status = FEC_RX_BUFFER_SIZE;
+		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+
+		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 ievent;
+
+	ievent = in_be32(&fec->ievent);
+
+	ievent &= ~FEC_IEVENT_MII;	/* mii is handled separately */
+	if (!ievent)
+		return IRQ_NONE;
+
+	out_be32(&fec->ievent, ievent);		/* clear pending events */
+
+	if (ievent & ~(FEC_IEVENT_RFIFO_ERROR | FEC_IEVENT_XFIFO_ERROR)) {
+		if (ievent & ~FEC_IEVENT_TFINT)
+			dev_dbg(&dev->dev, "ievent: %08x\n", ievent);
+		return IRQ_HANDLED;
+	}
+
+	if (net_ratelimit() && (ievent & FEC_IEVENT_RFIFO_ERROR))
+		dev_warn(&dev->dev, "FEC_IEVENT_RFIFO_ERROR\n");
+	if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
+		dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
+
+	mpc52xx_fec_reset(dev);
+
+	netif_wake_queue(dev);
+	return IRQ_HANDLED;
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *mpc52xx_fec_get_stats(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	stats->rx_bytes = in_be32(&fec->rmon_r_octets);
+	stats->rx_packets = in_be32(&fec->rmon_r_packets);
+	stats->rx_errors = in_be32(&fec->rmon_r_crc_align) +
+		in_be32(&fec->rmon_r_undersize) +
+		in_be32(&fec->rmon_r_oversize) +
+		in_be32(&fec->rmon_r_frag) +
+		in_be32(&fec->rmon_r_jab);
+
+	stats->tx_bytes = in_be32(&fec->rmon_t_octets);
+	stats->tx_packets = in_be32(&fec->rmon_t_packets);
+	stats->tx_errors = in_be32(&fec->rmon_t_crc_align) +
+		in_be32(&fec->rmon_t_undersize) +
+		in_be32(&fec->rmon_t_oversize) +
+		in_be32(&fec->rmon_t_frag) +
+		in_be32(&fec->rmon_t_jab);
+
+	stats->multicast = in_be32(&fec->rmon_r_mc_pkt);
+	stats->collisions = in_be32(&fec->rmon_t_col);
+
+	/* detailed rx_errors: */
+	stats->rx_length_errors = in_be32(&fec->rmon_r_undersize)
+					+ in_be32(&fec->rmon_r_oversize)
+					+ in_be32(&fec->rmon_r_frag)
+					+ in_be32(&fec->rmon_r_jab);
+	stats->rx_over_errors = in_be32(&fec->r_macerr);
+	stats->rx_crc_errors = in_be32(&fec->ieee_r_crc);
+	stats->rx_frame_errors = in_be32(&fec->ieee_r_align);
+	stats->rx_fifo_errors = in_be32(&fec->rmon_r_drop);
+	stats->rx_missed_errors = in_be32(&fec->rmon_r_drop);
+
+	/* detailed tx_errors: */
+	stats->tx_aborted_errors = 0;
+	stats->tx_carrier_errors = in_be32(&fec->ieee_t_cserr);
+	stats->tx_fifo_errors = in_be32(&fec->rmon_t_drop);
+	stats->tx_heartbeat_errors = in_be32(&fec->ieee_t_sqe);
+	stats->tx_window_errors = in_be32(&fec->ieee_t_lcol);
+
+	return stats;
+}
+
+/*
+ * Read MIB counters in order to reset them,
+ * then zero all the stats fields in memory
+ */
+static void mpc52xx_fec_reset_stats(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	out_be32(&fec->mib_control, FEC_MIB_DISABLE);
+	memset_io(&fec->rmon_t_drop, 0,	(__force u32)&fec->reserved10 -
+			(__force u32)&fec->rmon_t_drop);
+	out_be32(&fec->mib_control, 0);
+
+	memset(&dev->stats, 0, sizeof(dev->stats));
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ */
+static void mpc52xx_fec_set_multicast_list(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 rx_control;
+
+	rx_control = in_be32(&fec->r_cntrl);
+
+	if (dev->flags & IFF_PROMISC) {
+		rx_control |= FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+	} else {
+		rx_control &= ~FEC_RCNTRL_PROM;
+		out_be32(&fec->r_cntrl, rx_control);
+
+		if (dev->flags & IFF_ALLMULTI) {
+			out_be32(&fec->gaddr1, 0xffffffff);
+			out_be32(&fec->gaddr2, 0xffffffff);
+		} else {
+			u32 crc;
+			int i;
+			struct dev_mc_list *dmi;
+			u32 gaddr1 = 0x00000000;
+			u32 gaddr2 = 0x00000000;
+
+			dmi = dev->mc_list;
+			for (i=0; i<dev->mc_count; i++) {
+				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
+				if (crc >= 32)
+					gaddr1 |= 1 << (crc-32);
+				else
+					gaddr2 |= 1 << crc;
+				dmi = dmi->next;
+			}
+			out_be32(&fec->gaddr1, gaddr1);
+			out_be32(&fec->gaddr2, gaddr2);
+		}
+	}
+}
+
+/**
+ * mpc52xx_fec_hw_init
+ * @dev: network device
+ *
+ * Setup various hardware setting, only needed once on start
+ */
+static void mpc52xx_fec_hw_init(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	int i;
+
+	/* Whack a reset.  We should wait for this. */
+	out_be32(&fec->ecntrl, FEC_ECNTRL_RESET);
+	for (i = 0; i < FEC_RESET_DELAY; ++i) {
+		if ((in_be32(&fec->ecntrl) & FEC_ECNTRL_RESET) == 0)
+			break;
+		udelay(1);
+	}
+	if (i == FEC_RESET_DELAY)
+		dev_err(&dev->dev, "FEC Reset timeout!\n");
+
+	/* set pause to 0x20 frames */
+	out_be32(&fec->op_pause, FEC_OP_PAUSE_OPCODE | 0x20);
+
+	/* high service request will be deasserted when there's < 7 bytes in fifo
+	 * low service request will be deasserted when there's < 4*7 bytes in fifo
+	 */
+	out_be32(&fec->rfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG_7);
+	out_be32(&fec->tfifo_cntrl, FEC_FIFO_CNTRL_FRAME | FEC_FIFO_CNTRL_LTG_7);
+
+	/* alarm when <= x bytes in FIFO */
+	out_be32(&fec->rfifo_alarm, 0x0000030c);
+	out_be32(&fec->tfifo_alarm, 0x00000100);
+
+	/* begin transmittion when 256 bytes are in FIFO (or EOF or FIFO full) */
+	out_be32(&fec->x_wmrk, FEC_FIFO_WMRK_256B);
+
+	/* enable crc generation */
+	out_be32(&fec->xmit_fsm, FEC_XMIT_FSM_APPEND_CRC | FEC_XMIT_FSM_ENABLE_CRC);
+	out_be32(&fec->iaddr1, 0x00000000);	/* No individual filter */
+	out_be32(&fec->iaddr2, 0x00000000);	/* No individual filter */
+
+	/* set phy speed.
+	 * this can't be done in phy driver, since it needs to be called
+	 * before fec stuff (even on resume) */
+	mpc52xx_fec_phy_hw_init(priv);
+}
+
+/**
+ * mpc52xx_fec_start
+ * @dev: network device
+ *
+ * This function is called to start or restart the FEC during a link
+ * change.  This happens on fifo errors or when switching between half
+ * and full duplex.
+ */
+static void mpc52xx_fec_start(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	u32 rcntrl;
+	u32 tcntrl;
+	u32 tmp;
+
+	/* clear sticky error bits */
+	tmp = FEC_FIFO_STATUS_ERR | FEC_FIFO_STATUS_UF | FEC_FIFO_STATUS_OF;
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status) & tmp);
+	out_be32(&fec->tfifo_status, in_be32(&fec->tfifo_status) & tmp);
+
+	/* FIFOs will reset on mpc52xx_fec_enable */
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_ENABLE_IS_RESET);
+
+	/* Set station address. */
+	mpc52xx_fec_set_paddr(dev, dev->dev_addr);
+
+	mpc52xx_fec_set_multicast_list(dev);
+
+	/* set max frame len, enable flow control, select mii mode */
+	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
+	rcntrl |= FEC_RCNTRL_FCE;
+
+	if (priv->has_phy)
+		rcntrl |= FEC_RCNTRL_MII_MODE;
+
+	if (priv->duplex == DUPLEX_FULL)
+		tcntrl = FEC_TCNTRL_FDEN;	/* FD enable */
+	else {
+		rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
+		tcntrl = 0;
+	}
+	out_be32(&fec->r_cntrl, rcntrl);
+	out_be32(&fec->x_cntrl, tcntrl);
+
+	/* Clear any outstanding interrupt. */
+	out_be32(&fec->ievent, 0xffffffff);
+
+	/* Enable interrupts we wish to service. */
+	out_be32(&fec->imask, FEC_IMASK_ENABLE);
+
+	/* And last, enable the transmit and receive processing. */
+	out_be32(&fec->ecntrl, FEC_ECNTRL_ETHER_EN);
+	out_be32(&fec->r_des_active, 0x01000000);
+}
+
+/**
+ * mpc52xx_fec_stop
+ * @dev: network device
+ *
+ * stop all activity on fec and empty dma buffers
+ */
+static void mpc52xx_fec_stop(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+	unsigned long timeout;
+
+	/* disable all interrupts */
+	out_be32(&fec->imask, 0);
+
+	/* Disable the rx task. */
+	bcom_disable(priv->rx_dmatsk);
+
+	/* Wait for tx queue to drain, but only if we're in process context */
+	if (!in_interrupt()) {
+		timeout = jiffies + msecs_to_jiffies(2000);
+		while (time_before(jiffies, timeout) &&
+				!bcom_queue_empty(priv->tx_dmatsk))
+			msleep(100);
+
+		if (time_after_eq(jiffies, timeout))
+			dev_err(&dev->dev, "queues didn't drain\n");
+#if 1
+		if (time_after_eq(jiffies, timeout)) {
+			dev_err(&dev->dev, "  tx: index: %i, outdex: %i\n",
+					priv->tx_dmatsk->index,
+					priv->tx_dmatsk->outdex);
+			dev_err(&dev->dev, "  rx: index: %i, outdex: %i\n",
+					priv->rx_dmatsk->index,
+					priv->rx_dmatsk->outdex);
+		}
+#endif
+	}
+
+	bcom_disable(priv->tx_dmatsk);
+
+	/* Stop FEC */
+	out_be32(&fec->ecntrl, in_be32(&fec->ecntrl) & ~FEC_ECNTRL_ETHER_EN);
+
+	return;
+}
+
+/* reset fec and bestcomm tasks */
+static void mpc52xx_fec_reset(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct mpc52xx_fec __iomem *fec = priv->fec;
+
+	mpc52xx_fec_stop(dev);
+
+	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status));
+	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_RESET_FIFO);
+
+	mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
+
+	mpc52xx_fec_hw_init(dev);
+
+	phy_stop(priv->phydev);
+	phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
+	phy_start(priv->phydev);
+
+	bcom_fec_rx_reset(priv->rx_dmatsk);
+	bcom_fec_tx_reset(priv->tx_dmatsk);
+
+	mpc52xx_fec_alloc_rx_buffers(dev, priv->rx_dmatsk);
+
+	bcom_enable(priv->rx_dmatsk);
+	bcom_enable(priv->tx_dmatsk);
+
+	mpc52xx_fec_start(dev);
+}
+
+
+/* ethtool interface */
+static void mpc52xx_fec_get_drvinfo(struct net_device *dev,
+		struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRIVER_NAME);
+}
+
+static int mpc52xx_fec_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int mpc52xx_fec_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	priv->msg_enable = level;
+}
+
+static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
+	.get_drvinfo = mpc52xx_fec_get_drvinfo,
+	.get_settings = mpc52xx_fec_get_settings,
+	.set_settings = mpc52xx_fec_set_settings,
+	.get_link = ethtool_op_get_link,
+	.get_msglevel = mpc52xx_fec_get_msglevel,
+	.set_msglevel = mpc52xx_fec_set_msglevel,
+};
+
+
+static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
+}
+
+/* ======================================================================== */
+/* OF Driver                                                                */
+/* ======================================================================== */
+
+static int __devinit
+mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
+{
+	int rv;
+	struct net_device *ndev;
+	struct mpc52xx_fec_priv *priv = NULL;
+	struct resource mem;
+	const phandle *ph;
+
+	phys_addr_t rx_fifo;
+	phys_addr_t tx_fifo;
+
+	/* Get the ether ndev & it's private zone */
+	ndev = alloc_etherdev(sizeof(struct mpc52xx_fec_priv));
+	if (!ndev)
+		return -ENOMEM;
+
+	priv = netdev_priv(ndev);
+
+	/* Reserve FEC control zone */
+	rv = of_address_to_resource(op->node, 0, &mem);
+	if (rv) {
+		printk(KERN_ERR DRIVER_NAME ": "
+				"Error while parsing device node resource\n" );
+		return rv;
+	}
+	if ((mem.end - mem.start + 1) != sizeof(struct mpc52xx_fec)) {
+		printk(KERN_ERR DRIVER_NAME
+			" - invalid resource size (%lx != %x), check mpc52xx_devices.c\n",
+			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
+		return -EINVAL;
+	}
+
+	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec), DRIVER_NAME))
+		return -EBUSY;
+
+	/* Init ether ndev with what we have */
+	ndev->open		= mpc52xx_fec_open;
+	ndev->stop		= mpc52xx_fec_close;
+	ndev->hard_start_xmit	= mpc52xx_fec_hard_start_xmit;
+	ndev->do_ioctl		= mpc52xx_fec_ioctl;
+	ndev->ethtool_ops	= &mpc52xx_fec_ethtool_ops;
+	ndev->get_stats		= mpc52xx_fec_get_stats;
+	ndev->set_mac_address	= mpc52xx_fec_set_mac_address;
+	ndev->set_multicast_list = mpc52xx_fec_set_multicast_list;
+	ndev->tx_timeout	= mpc52xx_fec_tx_timeout;
+	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
+	ndev->base_addr		= mem.start;
+
+	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
+
+	spin_lock_init(&priv->lock);
+
+	/* ioremap the zones */
+	priv->fec = ioremap(mem.start, sizeof(struct mpc52xx_fec));
+
+	if (!priv->fec) {
+		rv = -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Bestcomm init */
+	rx_fifo = ndev->base_addr + offsetof(struct mpc52xx_fec, rfifo_data);
+	tx_fifo = ndev->base_addr + offsetof(struct mpc52xx_fec, tfifo_data);
+
+	priv->rx_dmatsk = bcom_fec_rx_init(FEC_RX_NUM_BD, rx_fifo, FEC_RX_BUFFER_SIZE);
+	priv->tx_dmatsk = bcom_fec_tx_init(FEC_TX_NUM_BD, tx_fifo);
+
+	if (!priv->rx_dmatsk || !priv->tx_dmatsk) {
+		printk(KERN_ERR DRIVER_NAME ": Can not init SDMA tasks\n" );
+		rv = -ENOMEM;
+		goto probe_error;
+	}
+
+	/* Get the IRQ we need one by one */
+		/* Control */
+	ndev->irq = irq_of_parse_and_map(op->node, 0);
+
+		/* RX */
+	priv->r_irq = bcom_get_task_irq(priv->rx_dmatsk);
+
+		/* TX */
+	priv->t_irq = bcom_get_task_irq(priv->tx_dmatsk);
+
+	/* MAC address init */
+	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
+		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
+	else
+		mpc52xx_fec_get_paddr(ndev, ndev->dev_addr);
+
+	priv->msg_enable = netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
+	priv->duplex = DUPLEX_FULL;
+
+	/* is the phy present in device tree? */
+	ph = of_get_property(op->node, "phy-handle", NULL);
+	if (ph) {
+		const unsigned int *prop;
+		struct device_node *phy_dn;
+		priv->has_phy = 1;
+
+		phy_dn = of_find_node_by_phandle(*ph);
+		prop = of_get_property(phy_dn, "reg", NULL);
+		priv->phy_addr = *prop;
+
+		of_node_put(phy_dn);
+
+		/* Phy speed */
+		priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
+	} else {
+		dev_info(&ndev->dev, "can't find \"phy-handle\" in device"
+				" tree, using 7-wire mode\n");
+	}
+
+	/* Hardware init */
+	mpc52xx_fec_hw_init(ndev);
+
+	mpc52xx_fec_reset_stats(ndev);
+
+	/* Register the new network device */
+	rv = register_netdev(ndev);
+	if (rv < 0)
+		goto probe_error;
+
+	/* We're done ! */
+	dev_set_drvdata(&op->dev, ndev);
+
+	return 0;
+
+
+	/* Error handling - free everything that might be allocated */
+probe_error:
+
+	irq_dispose_mapping(ndev->irq);
+
+	if (priv->rx_dmatsk)
+		bcom_fec_rx_release(priv->rx_dmatsk);
+	if (priv->tx_dmatsk)
+		bcom_fec_tx_release(priv->tx_dmatsk);
+
+	if (priv->fec)
+		iounmap(priv->fec);
+
+	release_mem_region(mem.start, sizeof(struct mpc52xx_fec));
+
+	free_netdev(ndev);
+
+	return rv;
+}
+
+static int
+mpc52xx_fec_remove(struct of_device *op)
+{
+	struct net_device *ndev;
+	struct mpc52xx_fec_priv *priv;
+
+	ndev = dev_get_drvdata(&op->dev);
+	priv = netdev_priv(ndev);
+
+	unregister_netdev(ndev);
+
+	irq_dispose_mapping(ndev->irq);
+
+	bcom_fec_rx_release(priv->rx_dmatsk);
+	bcom_fec_tx_release(priv->tx_dmatsk);
+
+	iounmap(priv->fec);
+
+	release_mem_region(ndev->base_addr, sizeof(struct mpc52xx_fec));
+
+	free_netdev(ndev);
+
+	dev_set_drvdata(&op->dev, NULL);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int mpc52xx_fec_of_suspend(struct of_device *op, pm_message_t state)
+{
+	struct net_device *dev = dev_get_drvdata(&op->dev);
+
+	if (netif_running(dev))
+		mpc52xx_fec_close(dev);
+
+	return 0;
+}
+
+static int mpc52xx_fec_of_resume(struct of_device *op)
+{
+	struct net_device *dev = dev_get_drvdata(&op->dev);
+
+	mpc52xx_fec_hw_init(dev);
+	mpc52xx_fec_reset_stats(dev);
+
+	if (netif_running(dev))
+		mpc52xx_fec_open(dev);
+
+	return 0;
+}
+#endif
+
+static struct of_device_id mpc52xx_fec_match[] = {
+	{
+		.type		= "network",
+		.compatible	= "mpc5200-fec",
+	},
+	{ }
+};
+
+MODULE_DEVICE_TABLE(of, mpc52xx_fec_match);
+
+static struct of_platform_driver mpc52xx_fec_driver = {
+	.owner		= THIS_MODULE,
+	.name		= DRIVER_NAME,
+	.match_table	= mpc52xx_fec_match,
+	.probe		= mpc52xx_fec_probe,
+	.remove		= mpc52xx_fec_remove,
+#ifdef CONFIG_PM
+	.suspend	= mpc52xx_fec_of_suspend,
+	.resume		= mpc52xx_fec_of_resume,
+#endif
+};
+
+
+/* ======================================================================== */
+/* Module                                                                   */
+/* ======================================================================== */
+
+static int __init
+mpc52xx_fec_init(void)
+{
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	int ret;
+	ret = of_register_platform_driver(&mpc52xx_fec_mdio_driver);
+	if (ret) {
+		printk(KERN_ERR DRIVER_NAME ": failed to register mdio driver\n");
+		return ret;
+	}
+#endif
+	return of_register_platform_driver(&mpc52xx_fec_driver);
+}
+
+static void __exit
+mpc52xx_fec_exit(void)
+{
+	of_unregister_platform_driver(&mpc52xx_fec_driver);
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	of_unregister_platform_driver(&mpc52xx_fec_mdio_driver);
+#endif
+}
+
+
+module_init(mpc52xx_fec_init);
+module_exit(mpc52xx_fec_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dale Farnsworth");
+MODULE_DESCRIPTION("Ethernet driver for the Freescale MPC52xx FEC");
diff --git a/drivers/net/fec_mpc52xx.h b/drivers/net/fec_mpc52xx.h
new file mode 100644
index 0000000..8b1f753
--- /dev/null
+++ b/drivers/net/fec_mpc52xx.h
@@ -0,0 +1,313 @@
+/*
+ * drivers/drivers/net/fec_mpc52xx/fec.h
+ *
+ * Driver for the MPC5200 Fast Ethernet Controller
+ *
+ * Author: Dale Farnsworth <dfarnsworth@mvista.com>
+ *
+ * 2003-2004 (c) MontaVista, Software, Inc.  This file is licensed under
+ * the terms of the GNU General Public License version 2.  This program
+ * is licensed "as is" without any warranty of any kind, whether express
+ * or implied.
+ */
+
+#ifndef __DRIVERS_NET_MPC52XX_FEC_H__
+#define __DRIVERS_NET_MPC52XX_FEC_H__
+
+#include <linux/phy.h>
+
+/* Tunable constant */
+/* FEC_RX_BUFFER_SIZE includes 4 bytes for CRC32 */
+#define FEC_RX_BUFFER_SIZE	1522	/* max receive packet size */
+#define FEC_RX_NUM_BD		256
+#define FEC_TX_NUM_BD		64
+
+#define FEC_RESET_DELAY		50 	/* uS */
+
+#define FEC_WATCHDOG_TIMEOUT	((400*HZ)/1000)
+
+struct mpc52xx_fec_priv {
+	int duplex;
+	int r_irq;
+	int t_irq;
+	struct mpc52xx_fec __iomem *fec;
+	struct bcom_task *rx_dmatsk;
+	struct bcom_task *tx_dmatsk;
+	spinlock_t lock;
+	int msg_enable;
+
+	int has_phy;
+	unsigned int phy_speed;
+	unsigned int phy_addr;
+	struct phy_device *phydev;
+	enum phy_state link;
+	int speed;
+};
+
+
+/* ======================================================================== */
+/* Hardware register sets & bits                                            */
+/* ======================================================================== */
+
+struct mpc52xx_fec {
+	u32 fec_id;			/* FEC + 0x000 */
+	u32 ievent;			/* FEC + 0x004 */
+	u32 imask;			/* FEC + 0x008 */
+
+	u32 reserved0[1];		/* FEC + 0x00C */
+	u32 r_des_active;		/* FEC + 0x010 */
+	u32 x_des_active;		/* FEC + 0x014 */
+	u32 r_des_active_cl;		/* FEC + 0x018 */
+	u32 x_des_active_cl;		/* FEC + 0x01C */
+	u32 ivent_set;			/* FEC + 0x020 */
+	u32 ecntrl;			/* FEC + 0x024 */
+
+	u32 reserved1[6];		/* FEC + 0x028-03C */
+	u32 mii_data;			/* FEC + 0x040 */
+	u32 mii_speed;			/* FEC + 0x044 */
+	u32 mii_status;			/* FEC + 0x048 */
+
+	u32 reserved2[5];		/* FEC + 0x04C-05C */
+	u32 mib_data;			/* FEC + 0x060 */
+	u32 mib_control;		/* FEC + 0x064 */
+
+	u32 reserved3[6];		/* FEC + 0x068-7C */
+	u32 r_activate;			/* FEC + 0x080 */
+	u32 r_cntrl;			/* FEC + 0x084 */
+	u32 r_hash;			/* FEC + 0x088 */
+	u32 r_data;			/* FEC + 0x08C */
+	u32 ar_done;			/* FEC + 0x090 */
+	u32 r_test;			/* FEC + 0x094 */
+	u32 r_mib;			/* FEC + 0x098 */
+	u32 r_da_low;			/* FEC + 0x09C */
+	u32 r_da_high;			/* FEC + 0x0A0 */
+
+	u32 reserved4[7];		/* FEC + 0x0A4-0BC */
+	u32 x_activate;			/* FEC + 0x0C0 */
+	u32 x_cntrl;			/* FEC + 0x0C4 */
+	u32 backoff;			/* FEC + 0x0C8 */
+	u32 x_data;			/* FEC + 0x0CC */
+	u32 x_status;			/* FEC + 0x0D0 */
+	u32 x_mib;			/* FEC + 0x0D4 */
+	u32 x_test;			/* FEC + 0x0D8 */
+	u32 fdxfc_da1;			/* FEC + 0x0DC */
+	u32 fdxfc_da2;			/* FEC + 0x0E0 */
+	u32 paddr1;			/* FEC + 0x0E4 */
+	u32 paddr2;			/* FEC + 0x0E8 */
+	u32 op_pause;			/* FEC + 0x0EC */
+
+	u32 reserved5[4];		/* FEC + 0x0F0-0FC */
+	u32 instr_reg;			/* FEC + 0x100 */
+	u32 context_reg;		/* FEC + 0x104 */
+	u32 test_cntrl;			/* FEC + 0x108 */
+	u32 acc_reg;			/* FEC + 0x10C */
+	u32 ones;			/* FEC + 0x110 */
+	u32 zeros;			/* FEC + 0x114 */
+	u32 iaddr1;			/* FEC + 0x118 */
+	u32 iaddr2;			/* FEC + 0x11C */
+	u32 gaddr1;			/* FEC + 0x120 */
+	u32 gaddr2;			/* FEC + 0x124 */
+	u32 random;			/* FEC + 0x128 */
+	u32 rand1;			/* FEC + 0x12C */
+	u32 tmp;			/* FEC + 0x130 */
+
+	u32 reserved6[3];		/* FEC + 0x134-13C */
+	u32 fifo_id;			/* FEC + 0x140 */
+	u32 x_wmrk;			/* FEC + 0x144 */
+	u32 fcntrl;			/* FEC + 0x148 */
+	u32 r_bound;			/* FEC + 0x14C */
+	u32 r_fstart;			/* FEC + 0x150 */
+	u32 r_count;			/* FEC + 0x154 */
+	u32 r_lag;			/* FEC + 0x158 */
+	u32 r_read;			/* FEC + 0x15C */
+	u32 r_write;			/* FEC + 0x160 */
+	u32 x_count;			/* FEC + 0x164 */
+	u32 x_lag;			/* FEC + 0x168 */
+	u32 x_retry;			/* FEC + 0x16C */
+	u32 x_write;			/* FEC + 0x170 */
+	u32 x_read;			/* FEC + 0x174 */
+
+	u32 reserved7[2];		/* FEC + 0x178-17C */
+	u32 fm_cntrl;			/* FEC + 0x180 */
+	u32 rfifo_data;			/* FEC + 0x184 */
+	u32 rfifo_status;		/* FEC + 0x188 */
+	u32 rfifo_cntrl;		/* FEC + 0x18C */
+	u32 rfifo_lrf_ptr;		/* FEC + 0x190 */
+	u32 rfifo_lwf_ptr;		/* FEC + 0x194 */
+	u32 rfifo_alarm;		/* FEC + 0x198 */
+	u32 rfifo_rdptr;		/* FEC + 0x19C */
+	u32 rfifo_wrptr;		/* FEC + 0x1A0 */
+	u32 tfifo_data;			/* FEC + 0x1A4 */
+	u32 tfifo_status;		/* FEC + 0x1A8 */
+	u32 tfifo_cntrl;		/* FEC + 0x1AC */
+	u32 tfifo_lrf_ptr;		/* FEC + 0x1B0 */
+	u32 tfifo_lwf_ptr;		/* FEC + 0x1B4 */
+	u32 tfifo_alarm;		/* FEC + 0x1B8 */
+	u32 tfifo_rdptr;		/* FEC + 0x1BC */
+	u32 tfifo_wrptr;		/* FEC + 0x1C0 */
+
+	u32 reset_cntrl;		/* FEC + 0x1C4 */
+	u32 xmit_fsm;			/* FEC + 0x1C8 */
+
+	u32 reserved8[3];		/* FEC + 0x1CC-1D4 */
+	u32 rdes_data0;			/* FEC + 0x1D8 */
+	u32 rdes_data1;			/* FEC + 0x1DC */
+	u32 r_length;			/* FEC + 0x1E0 */
+	u32 x_length;			/* FEC + 0x1E4 */
+	u32 x_addr;			/* FEC + 0x1E8 */
+	u32 cdes_data;			/* FEC + 0x1EC */
+	u32 status;			/* FEC + 0x1F0 */
+	u32 dma_control;		/* FEC + 0x1F4 */
+	u32 des_cmnd;			/* FEC + 0x1F8 */
+	u32 data;			/* FEC + 0x1FC */
+
+	u32 rmon_t_drop;		/* FEC + 0x200 */
+	u32 rmon_t_packets;		/* FEC + 0x204 */
+	u32 rmon_t_bc_pkt;		/* FEC + 0x208 */
+	u32 rmon_t_mc_pkt;		/* FEC + 0x20C */
+	u32 rmon_t_crc_align;		/* FEC + 0x210 */
+	u32 rmon_t_undersize;		/* FEC + 0x214 */
+	u32 rmon_t_oversize;		/* FEC + 0x218 */
+	u32 rmon_t_frag;		/* FEC + 0x21C */
+	u32 rmon_t_jab;			/* FEC + 0x220 */
+	u32 rmon_t_col;			/* FEC + 0x224 */
+	u32 rmon_t_p64;			/* FEC + 0x228 */
+	u32 rmon_t_p65to127;		/* FEC + 0x22C */
+	u32 rmon_t_p128to255;		/* FEC + 0x230 */
+	u32 rmon_t_p256to511;		/* FEC + 0x234 */
+	u32 rmon_t_p512to1023;		/* FEC + 0x238 */
+	u32 rmon_t_p1024to2047;		/* FEC + 0x23C */
+	u32 rmon_t_p_gte2048;		/* FEC + 0x240 */
+	u32 rmon_t_octets;		/* FEC + 0x244 */
+	u32 ieee_t_drop;		/* FEC + 0x248 */
+	u32 ieee_t_frame_ok;		/* FEC + 0x24C */
+	u32 ieee_t_1col;		/* FEC + 0x250 */
+	u32 ieee_t_mcol;		/* FEC + 0x254 */
+	u32 ieee_t_def;			/* FEC + 0x258 */
+	u32 ieee_t_lcol;		/* FEC + 0x25C */
+	u32 ieee_t_excol;		/* FEC + 0x260 */
+	u32 ieee_t_macerr;		/* FEC + 0x264 */
+	u32 ieee_t_cserr;		/* FEC + 0x268 */
+	u32 ieee_t_sqe;			/* FEC + 0x26C */
+	u32 t_fdxfc;			/* FEC + 0x270 */
+	u32 ieee_t_octets_ok;		/* FEC + 0x274 */
+
+	u32 reserved9[2];		/* FEC + 0x278-27C */
+	u32 rmon_r_drop;		/* FEC + 0x280 */
+	u32 rmon_r_packets;		/* FEC + 0x284 */
+	u32 rmon_r_bc_pkt;		/* FEC + 0x288 */
+	u32 rmon_r_mc_pkt;		/* FEC + 0x28C */
+	u32 rmon_r_crc_align;		/* FEC + 0x290 */
+	u32 rmon_r_undersize;		/* FEC + 0x294 */
+	u32 rmon_r_oversize;		/* FEC + 0x298 */
+	u32 rmon_r_frag;		/* FEC + 0x29C */
+	u32 rmon_r_jab;			/* FEC + 0x2A0 */
+
+	u32 rmon_r_resvd_0;		/* FEC + 0x2A4 */
+
+	u32 rmon_r_p64;			/* FEC + 0x2A8 */
+	u32 rmon_r_p65to127;		/* FEC + 0x2AC */
+	u32 rmon_r_p128to255;		/* FEC + 0x2B0 */
+	u32 rmon_r_p256to511;		/* FEC + 0x2B4 */
+	u32 rmon_r_p512to1023;		/* FEC + 0x2B8 */
+	u32 rmon_r_p1024to2047;		/* FEC + 0x2BC */
+	u32 rmon_r_p_gte2048;		/* FEC + 0x2C0 */
+	u32 rmon_r_octets;		/* FEC + 0x2C4 */
+	u32 ieee_r_drop;		/* FEC + 0x2C8 */
+	u32 ieee_r_frame_ok;		/* FEC + 0x2CC */
+	u32 ieee_r_crc;			/* FEC + 0x2D0 */
+	u32 ieee_r_align;		/* FEC + 0x2D4 */
+	u32 r_macerr;			/* FEC + 0x2D8 */
+	u32 r_fdxfc;			/* FEC + 0x2DC */
+	u32 ieee_r_octets_ok;		/* FEC + 0x2E0 */
+
+	u32 reserved10[7];		/* FEC + 0x2E4-2FC */
+
+	u32 reserved11[64];		/* FEC + 0x300-3FF */
+};
+
+#define	FEC_MIB_DISABLE			0x80000000
+
+#define	FEC_IEVENT_HBERR		0x80000000
+#define	FEC_IEVENT_BABR			0x40000000
+#define	FEC_IEVENT_BABT			0x20000000
+#define	FEC_IEVENT_GRA			0x10000000
+#define	FEC_IEVENT_TFINT		0x08000000
+#define	FEC_IEVENT_MII			0x00800000
+#define	FEC_IEVENT_LATE_COL		0x00200000
+#define	FEC_IEVENT_COL_RETRY_LIM	0x00100000
+#define	FEC_IEVENT_XFIFO_UN		0x00080000
+#define	FEC_IEVENT_XFIFO_ERROR		0x00040000
+#define	FEC_IEVENT_RFIFO_ERROR		0x00020000
+
+#define	FEC_IMASK_HBERR			0x80000000
+#define	FEC_IMASK_BABR			0x40000000
+#define	FEC_IMASK_BABT			0x20000000
+#define	FEC_IMASK_GRA			0x10000000
+#define	FEC_IMASK_MII			0x00800000
+#define	FEC_IMASK_LATE_COL		0x00200000
+#define	FEC_IMASK_COL_RETRY_LIM		0x00100000
+#define	FEC_IMASK_XFIFO_UN		0x00080000
+#define	FEC_IMASK_XFIFO_ERROR		0x00040000
+#define	FEC_IMASK_RFIFO_ERROR		0x00020000
+
+/* all but MII, which is enabled separately */
+#define FEC_IMASK_ENABLE	(FEC_IMASK_HBERR | FEC_IMASK_BABR | \
+		FEC_IMASK_BABT | FEC_IMASK_GRA | FEC_IMASK_LATE_COL | \
+		FEC_IMASK_COL_RETRY_LIM | FEC_IMASK_XFIFO_UN | \
+		FEC_IMASK_XFIFO_ERROR | FEC_IMASK_RFIFO_ERROR)
+
+#define	FEC_RCNTRL_MAX_FL_SHIFT		16
+#define	FEC_RCNTRL_LOOP			0x01
+#define	FEC_RCNTRL_DRT			0x02
+#define	FEC_RCNTRL_MII_MODE		0x04
+#define	FEC_RCNTRL_PROM			0x08
+#define	FEC_RCNTRL_BC_REJ		0x10
+#define	FEC_RCNTRL_FCE			0x20
+
+#define	FEC_TCNTRL_GTS			0x00000001
+#define	FEC_TCNTRL_HBC			0x00000002
+#define	FEC_TCNTRL_FDEN			0x00000004
+#define	FEC_TCNTRL_TFC_PAUSE		0x00000008
+#define	FEC_TCNTRL_RFC_PAUSE		0x00000010
+
+#define	FEC_ECNTRL_RESET		0x00000001
+#define	FEC_ECNTRL_ETHER_EN		0x00000002
+
+#define FEC_MII_DATA_ST			0x40000000	/* Start frame */
+#define FEC_MII_DATA_OP_RD		0x20000000	/* Perform read */
+#define FEC_MII_DATA_OP_WR		0x10000000	/* Perform write */
+#define FEC_MII_DATA_PA_MSK		0x0f800000	/* PHY Address mask */
+#define FEC_MII_DATA_RA_MSK		0x007c0000	/* PHY Register mask */
+#define FEC_MII_DATA_TA			0x00020000	/* Turnaround */
+#define FEC_MII_DATA_DATAMSK		0x0000ffff	/* PHY data mask */
+
+#define FEC_MII_READ_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_RD | FEC_MII_DATA_TA)
+#define FEC_MII_WRITE_FRAME	(FEC_MII_DATA_ST | FEC_MII_DATA_OP_WR | FEC_MII_DATA_TA)
+
+#define FEC_MII_DATA_RA_SHIFT		0x12		/* MII reg addr bits */
+#define FEC_MII_DATA_PA_SHIFT		0x17		/* MII PHY addr bits */
+
+#define FEC_PADDR2_TYPE			0x8808
+
+#define FEC_OP_PAUSE_OPCODE		0x00010000
+
+#define FEC_FIFO_WMRK_256B		0x3
+
+#define FEC_FIFO_STATUS_ERR		0x00400000
+#define FEC_FIFO_STATUS_UF		0x00200000
+#define FEC_FIFO_STATUS_OF		0x00100000
+
+#define FEC_FIFO_CNTRL_FRAME		0x08000000
+#define FEC_FIFO_CNTRL_LTG_7		0x07000000
+
+#define FEC_RESET_CNTRL_RESET_FIFO	0x02000000
+#define FEC_RESET_CNTRL_ENABLE_IS_RESET	0x01000000
+
+#define FEC_XMIT_FSM_APPEND_CRC		0x02000000
+#define FEC_XMIT_FSM_ENABLE_CRC		0x01000000
+
+
+extern struct of_platform_driver mpc52xx_fec_mdio_driver;
+
+#endif	/* __DRIVERS_NET_MPC52XX_FEC_H__ */
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
new file mode 100644
index 0000000..ba6e8b2
--- /dev/null
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -0,0 +1,198 @@
+/*
+ * Driver for the MPC5200 Fast Ethernet Controller - MDIO bus driver
+ *
+ * Copyright (C) 2007  Domen Puncer, Telargo, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/of_platform.h>
+#include <asm/io.h>
+#include <asm/mpc52xx.h>
+#include "fec_mpc52xx.h"
+
+struct mpc52xx_fec_mdio_priv {
+	struct mpc52xx_fec __iomem *regs;
+};
+
+static int mpc52xx_fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	int tries = 100;
+	u32 request = FEC_MII_READ_FRAME;
+
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	request |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	request |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, request);
+
+	/* wait for it to finish, this takes about 23 us on lite5200b */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries == 0)
+		return -ETIMEDOUT;
+
+	return in_be32(&priv->regs->mii_data) & FEC_MII_DATA_DATAMSK;
+}
+
+static int mpc52xx_fec_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
+{
+	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
+	u32 value = data;
+	int tries = 100;
+
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
+	value |= FEC_MII_WRITE_FRAME;
+	value |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
+	value |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
+
+	out_be32(&priv->regs->mii_data, value);
+
+	/* wait for request to finish */
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
+		udelay(5);
+
+	if (tries == 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct of_device_id *match)
+{
+	struct device *dev = &of->dev;
+	struct device_node *np = of->node;
+	struct device_node *child = NULL;
+	struct mii_bus *bus;
+	struct mpc52xx_fec_mdio_priv *priv;
+	struct resource res = {};
+	int err;
+	int i;
+
+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
+	if (bus == NULL)
+		return -ENOMEM;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+
+	bus->name = "mpc52xx MII bus";
+	bus->read = mpc52xx_fec_mdio_read;
+	bus->write = mpc52xx_fec_mdio_write;
+
+	/* setup irqs */
+	bus->irq = kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (bus->irq == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	while ((child = of_get_next_child(np, child)) != NULL) {
+		int irq = irq_of_parse_and_map(child, 0);
+		if (irq != NO_IRQ) {
+			const u32 *id = of_get_property(child, "reg", NULL);
+			bus->irq[*id] = irq;
+		}
+	}
+
+	/* setup registers */
+	err = of_address_to_resource(np, 0, &res);
+	if (err)
+		goto out_free;
+	priv->regs = ioremap(res.start, res.end - res.start + 1);
+	if (priv->regs == NULL) {
+		err = -ENOMEM;
+		goto out_free;
+	}
+
+	bus->id = res.start;
+	bus->priv = priv;
+
+	bus->dev = dev;
+	dev_set_drvdata(dev, bus);
+
+	/* set MII speed */
+	out_be32(&priv->regs->mii_speed, ((mpc52xx_find_ipb_freq(of->node) >> 20) / 5) << 1);
+
+	/* enable MII interrupt */
+	out_be32(&priv->regs->imask, in_be32(&priv->regs->imask) | FEC_IMASK_MII);
+
+	err = mdiobus_register(bus);
+	if (err)
+		goto out_unmap;
+
+	return 0;
+
+ out_unmap:
+	iounmap(priv->regs);
+ out_free:
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i] != PHY_POLL)
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(bus->irq);
+	kfree(priv);
+	kfree(bus);
+
+	return err;
+}
+
+static int mpc52xx_fec_mdio_remove(struct of_device *of)
+{
+	struct device *dev = &of->dev;
+	struct mii_bus *bus = dev_get_drvdata(dev);
+	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
+	int i;
+
+	mdiobus_unregister(bus);
+	dev_set_drvdata(dev, NULL);
+
+	iounmap(priv->regs);
+	for (i=0; i<PHY_MAX_ADDR; i++)
+		if (bus->irq[i])
+			irq_dispose_mapping(bus->irq[i]);
+	kfree(priv);
+	kfree(bus->irq);
+	kfree(bus);
+
+	return 0;
+}
+
+
+static struct of_device_id mpc52xx_fec_mdio_match[] = {
+	{
+		.type = "mdio",
+		.compatible = "mpc5200b-fec-phy",
+	},
+	{},
+};
+
+struct of_platform_driver mpc52xx_fec_mdio_driver = {
+	.name = "mpc5200b-fec-phy",
+	.probe = mpc52xx_fec_mdio_probe,
+	.remove = mpc52xx_fec_mdio_remove,
+	.match_table = mpc52xx_fec_mdio_match,
+};
+
+/* let fec driver call it, since this has to be registered before it */
+EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);
+
+
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 4dbdfaa..a1e4508 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -627,19 +627,16 @@ static int au1k_irda_rx(struct net_device *dev)
 }
 
 
-void au1k_irda_interrupt(int irq, void *dev_id)
+static irqreturn_t au1k_irda_interrupt(int dummy, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
-		return;
-	}
+	struct net_device *dev = dev_id;
 
 	writel(0, IR_INT_CLEAR); /* ack irda interrupts */
 
 	au1k_irda_rx(dev);
 	au1k_tx_ack(dev);
+
+	return IRQ_HANDLED;
 }
 
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 73dcbb7..ad134a6 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -274,7 +274,7 @@ static int tc574_probe(struct pcmcia_device *link)
 	spin_lock_init(&lp->window_lock);
 	link->io.NumPorts1 = 32;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
 	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->irq.Handler = &el3_interrupt;
 	link->irq.Instance = dev;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 32076ca..a98fe07 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -188,7 +188,7 @@ static int tc589_probe(struct pcmcia_device *link)
     spin_lock_init(&lp->lock);
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->irq.Handler = &el3_interrupt;
     link->irq.Instance = dev;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index a95a2ca..8d910a3 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -158,7 +158,7 @@ static int axnet_probe(struct pcmcia_device *link)
     info = PRIV(dev);
     info->p_dev = link;
     link->priv = dev;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6284467..8c719b4 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -249,7 +249,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     link->io.IOAddrLines = 5;
 
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->irq.Handler = &fjn_interrupt;
     link->irq.Instance = dev;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 9d45e96..db6a97d 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -254,7 +254,7 @@ static int pcnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
 
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 58d716f..c9868e9 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -328,7 +328,7 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 4;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
     link->irq.Handler = &smc_interrupt;
     link->irq.Instance = dev;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index c3b6960..1f09bea 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -886,7 +886,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	}
 	printk(KNOT_XIRC "no ports available\n");
     } else {
-	link->irq.Attributes |= IRQ_TYPE_EXCLUSIVE;
+	link->irq.Attributes |= IRQ_TYPE_DYNAMIC_SHARING;
 	link->io.NumPorts1 = 16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
 	    link->io.BasePort1 = ioaddr;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e8960f2..b94fa7e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -392,7 +392,9 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
+#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
+#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -2989,13 +2991,16 @@ static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int poll_locked = 0;
 	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_R8169_NAPI
+	napi_disable(&tp->napi);
+#endif
+
 core_down:
 	spin_lock_irq(&tp->lock);
 
@@ -3009,11 +3014,6 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
-	if (!poll_locked) {
-		napi_disable(&tp->napi);
-		poll_locked++;
-	}
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 9741d61..a3ff270 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2214,9 +2214,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 	struct dev_mc_list *dmi;
 	struct ucc_fast *uf_regs;
 	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-	u8 tempaddr[6];
-	u8 *mcptr, *tdptr;
-	int i, j;
+	int i;
 
 	ugeth = netdev_priv(dev);
 
@@ -2255,19 +2253,10 @@ static void ucc_geth_set_multi(struct net_device *dev)
 				if (!(dmi->dmi_addr[0] & 1))
 					continue;
 
-				/* The address in dmi_addr is LSB first,
-				 * and taddr is MSB first.  We have to
-				 * copy bytes MSB first from dmi_addr.
-				 */
-				mcptr = (u8 *) dmi->dmi_addr + 5;
-				tdptr = (u8 *) tempaddr;
-				for (j = 0; j < 6; j++)
-					*tdptr++ = *mcptr--;
-
 				/* Ask CPM to run CRC and set bit in
 				 * filter mask.
 				 */
-				hw_add_addr_in_hash(ugeth, tempaddr);
+				hw_add_addr_in_hash(ugeth, dmi->dmi_addr);
 			}
 		}
 	}
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 9d9ff76..5058e60 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2391,7 +2391,7 @@ out_requeue:
 	if (b43_debug(dev, B43_DBG_PWORK_FAST))
 		delay = msecs_to_jiffies(50);
 	else
-		delay = round_jiffies(HZ * 15);
+		delay = round_jiffies_relative(HZ * 15);
 	queue_delayed_work(wl->hw->workqueue, &dev->periodic_work, delay);
 out:
 	mutex_unlock(&wl->mutex);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index d09479e..f0e56df 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2260,7 +2260,7 @@ out_requeue:
 	if (b43legacy_debug(dev, B43legacy_DBG_PWORK_FAST))
 		delay = msecs_to_jiffies(50);
 	else
-		delay = round_jiffies(HZ);
+		delay = round_jiffies_relative(HZ);
 	queue_delayed_work(dev->wl->hw->workqueue,
 			   &dev->periodic_work, delay);
 out:
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index a6c7904..8d53d08 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1769,7 +1769,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 		if (priv->stop_rf_kill) {
 			priv->stop_rf_kill = 0;
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		}
 
 		deferred = 1;
@@ -2086,7 +2086,8 @@ static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
 	/* Make sure the RF Kill check timer is running */
 	priv->stop_rf_kill = 0;
 	cancel_delayed_work(&priv->rf_kill);
-	queue_delayed_work(priv->workqueue, &priv->rf_kill, round_jiffies(HZ));
+	queue_delayed_work(priv->workqueue, &priv->rf_kill,
+			   round_jiffies_relative(HZ));
 }
 
 static void send_scan_event(void *data)
@@ -2123,7 +2124,7 @@ static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
 		if (!delayed_work_pending(&priv->scan_event_later))
 			queue_delayed_work(priv->workqueue,
 					&priv->scan_event_later,
-					round_jiffies(msecs_to_jiffies(4000)));
+					round_jiffies_relative(msecs_to_jiffies(4000)));
 	} else {
 		priv->user_requested_scan = 0;
 		cancel_delayed_work(&priv->scan_event_later);
@@ -4242,7 +4243,7 @@ static int ipw_radio_kill_sw(struct ipw2100_priv *priv, int disable_radio)
 			priv->stop_rf_kill = 0;
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		} else
 			schedule_reset(priv);
 	}
@@ -5981,7 +5982,7 @@ static void ipw2100_rf_kill(struct work_struct *work)
 		IPW_DEBUG_RF_KILL("RF Kill active, rescheduling GPIO check\n");
 		if (!priv->stop_rf_kill)
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		goto exit_unlock;
 	}
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index e3c8284..54f44e5 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1753,7 +1753,7 @@ static int ipw_radio_kill_sw(struct ipw_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(2 * HZ));
+					   round_jiffies_relative(2 * HZ));
 		} else
 			queue_work(priv->workqueue, &priv->up);
 	}
@@ -4364,7 +4364,7 @@ static void handle_scan_event(struct ipw_priv *priv)
 	if (!priv->user_requested_scan) {
 		if (!delayed_work_pending(&priv->scan_event))
 			queue_delayed_work(priv->workqueue, &priv->scan_event,
-					 round_jiffies(msecs_to_jiffies(4000)));
+					 round_jiffies_relative(msecs_to_jiffies(4000)));
 	} else {
 		union iwreq_data wrqu;
 
@@ -4728,7 +4728,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 				 && priv->status & STATUS_ASSOCIATED)
 				queue_delayed_work(priv->workqueue,
 						   &priv->request_scan,
-						   round_jiffies(HZ));
+						   round_jiffies_relative(HZ));
 
 			/* Send an empty event to user space.
 			 * We don't send the received data on the event because
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 557deeb..891f90d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -3232,9 +3232,7 @@ int iwl4965_tx_cmd(struct iwl_priv *priv, struct iwl_cmd *out_cmd,
 	tx->rate_n_flags = iwl_hw_set_rate_n_flags(iwl_rates[rate_index].plcp,
 						rate_flags);
 
-	if (ieee80211_is_probe_request(fc))
-		tx->tx_flags |= TX_CMD_FLG_TSF_MSK;
-	else if (ieee80211_is_back_request(fc))
+	if (ieee80211_is_back_request(fc))
 		tx->tx_flags |= TX_CMD_FLG_ACK_MSK |
 			TX_CMD_FLG_IMM_BA_RSP_MASK;
 #ifdef CONFIG_IWLWIFI_HT
@@ -3872,7 +3870,7 @@ static void iwl4965_rx_reply_rx(struct iwl_priv *priv,
 			 */
 		case IEEE80211_STYPE_ASSOC_RESP:
 		case IEEE80211_STYPE_REASSOC_RESP:
-			if (network_packet && iwl_is_associated(priv)) {
+			if (network_packet) {
 #ifdef CONFIG_IWLWIFI_HT
 				u8 *pos = NULL;
 				struct ieee802_11_elems elems;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 83019d1..4f22a71 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6478,8 +6478,9 @@ static void iwl_bg_scan_check(struct work_struct *data)
 		IWL_DEBUG(IWL_DL_INFO | IWL_DL_SCAN,
 			  "Scan completion watchdog resetting adapter (%dms)\n",
 			  jiffies_to_msecs(IWL_SCAN_CHECK_WATCHDOG));
+
 		if (!test_bit(STATUS_EXIT_PENDING, &priv->status))
-			queue_work(priv->workqueue, &priv->restart);
+			iwl_send_scan_abort(priv);
 	}
 	mutex_unlock(&priv->mutex);
 }
@@ -6575,7 +6576,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		spin_unlock_irqrestore(&priv->lock, flags);
 
 		scan->suspend_time = 0;
-		scan->max_out_time = cpu_to_le32(600 * 1024);
+		scan->max_out_time = cpu_to_le32(200 * 1024);
 		if (!interval)
 			interval = suspend_time;
 		/*
@@ -6605,7 +6606,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		memcpy(scan->direct_scan[0].ssid,
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
-	} else if (!iwl_is_associated(priv)) {
+	} else if (!iwl_is_associated(priv) && priv->essid_len) {
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
@@ -6744,6 +6745,12 @@ static void iwl_bg_post_associate(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	if (!priv->interface_id || !priv->is_open) {
+		mutex_unlock(&priv->mutex);
+		return;
+	}
+	iwl_scan_cancel_timeout(priv, 200);
+
 	conf = ieee80211_get_hw_conf(priv->hw);
 
 	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
@@ -6882,9 +6889,19 @@ static void iwl_mac_stop(struct ieee80211_hw *hw)
 	struct iwl_priv *priv = hw->priv;
 
 	IWL_DEBUG_MAC80211("enter\n");
+
+
+	mutex_lock(&priv->mutex);
+	/* stop mac, cancel any scan request and clear
+	 * RXON_FILTER_ASSOC_MSK BIT
+	 */
 	priv->is_open = 0;
-	/*netif_stop_queue(dev); */
-	flush_workqueue(priv->workqueue);
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+	mutex_unlock(&priv->mutex);
+
 	IWL_DEBUG_MAC80211("leave\n");
 }
 
@@ -7169,8 +7186,6 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		if (priv->iw_mode == IEEE80211_IF_TYPE_AP)
 			iwl_config_ap(priv);
 		else {
-			priv->staging_rxon.filter_flags |=
-						RXON_FILTER_ASSOC_MSK;
 			rc = iwl_commit_rxon(priv);
 			if ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && rc)
 				iwl_add_station(priv,
@@ -7178,6 +7193,7 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		}
 
 	} else {
+		iwl_scan_cancel_timeout(priv, 100);
 		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
 		iwl_commit_rxon(priv);
 	}
@@ -7217,6 +7233,12 @@ static void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	IWL_DEBUG_MAC80211("enter\n");
 
 	mutex_lock(&priv->mutex);
+
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+
 	if (priv->interface_id == conf->if_id) {
 		priv->interface_id = 0;
 		memset(priv->bssid, 0, ETH_ALEN);
@@ -7238,6 +7260,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 	IWL_DEBUG_MAC80211("enter\n");
 
+	mutex_lock(&priv->mutex);
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!iwl_is_ready_rf(priv)) {
@@ -7268,7 +7291,8 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 		priv->direct_ssid_len = (u8)
 		    min((u8) len, (u8) IW_ESSID_MAX_SIZE);
 		memcpy(priv->direct_ssid, ssid, priv->direct_ssid_len);
-	}
+	} else
+		priv->one_direct_scan = 0;
 
 	rc = iwl_scan_initiate(priv);
 
@@ -7276,6 +7300,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 out_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
+	mutex_unlock(&priv->mutex);
 
 	return rc;
 }
@@ -7310,6 +7335,8 @@ static int iwl_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	mutex_lock(&priv->mutex);
 
+	iwl_scan_cancel_timeout(priv, 100);
+
 	switch (cmd) {
 	case  SET_KEY:
 		rc = iwl_update_sta_key_info(priv, key, sta_id);
@@ -7479,8 +7506,18 @@ static void iwl_mac_reset_tsf(struct ieee80211_hw *hw)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
+	/* we are restarting association process
+	 * clear RXON_FILTER_ASSOC_MSK bit
+	*/
+	if (priv->iw_mode != IEEE80211_IF_TYPE_AP) {
+		iwl_scan_cancel_timeout(priv, 100);
+		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+		iwl_commit_rxon(priv);
+	}
+
 	/* Per mac80211.h: This is only used in IBSS mode... */
 	if (priv->iw_mode != IEEE80211_IF_TYPE_IBSS) {
+
 		IWL_DEBUG_MAC80211("leave - not in IBSS\n");
 		mutex_unlock(&priv->mutex);
 		return;
@@ -8558,6 +8595,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 		iwl_rate_control_unregister(priv->hw);
 	}
 
+	/*netif_stop_queue(dev); */
+	flush_workqueue(priv->workqueue);
+
 	/* ieee80211_unregister_hw calls iwl_mac_stop, which flushes
 	 * priv->workqueue... so we can't take down the workqueue
 	 * until now... */
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 5e12792..d60adcb 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6845,8 +6845,9 @@ static void iwl_bg_scan_check(struct work_struct *data)
 		IWL_DEBUG(IWL_DL_INFO | IWL_DL_SCAN,
 			  "Scan completion watchdog resetting adapter (%dms)\n",
 			  jiffies_to_msecs(IWL_SCAN_CHECK_WATCHDOG));
+
 		if (!test_bit(STATUS_EXIT_PENDING, &priv->status))
-			queue_work(priv->workqueue, &priv->restart);
+			iwl_send_scan_abort(priv);
 	}
 	mutex_unlock(&priv->mutex);
 }
@@ -6942,7 +6943,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		spin_unlock_irqrestore(&priv->lock, flags);
 
 		scan->suspend_time = 0;
-		scan->max_out_time = cpu_to_le32(600 * 1024);
+		scan->max_out_time = cpu_to_le32(200 * 1024);
 		if (!interval)
 			interval = suspend_time;
 
@@ -6965,7 +6966,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		memcpy(scan->direct_scan[0].ssid,
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
-	} else if (!iwl_is_associated(priv)) {
+	} else if (!iwl_is_associated(priv) && priv->essid_len) {
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
@@ -7118,6 +7119,12 @@ static void iwl_bg_post_associate(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	if (!priv->interface_id || !priv->is_open) {
+		mutex_unlock(&priv->mutex);
+		return;
+	}
+	iwl_scan_cancel_timeout(priv, 200);
+
 	conf = ieee80211_get_hw_conf(priv->hw);
 
 	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
@@ -7271,9 +7278,19 @@ static void iwl_mac_stop(struct ieee80211_hw *hw)
 	struct iwl_priv *priv = hw->priv;
 
 	IWL_DEBUG_MAC80211("enter\n");
+
+
+	mutex_lock(&priv->mutex);
+	/* stop mac, cancel any scan request and clear
+	 * RXON_FILTER_ASSOC_MSK BIT
+	 */
 	priv->is_open = 0;
-	/*netif_stop_queue(dev); */
-	flush_workqueue(priv->workqueue);
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+	mutex_unlock(&priv->mutex);
+
 	IWL_DEBUG_MAC80211("leave\n");
 }
 
@@ -7573,8 +7590,6 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		if (priv->iw_mode == IEEE80211_IF_TYPE_AP)
 			iwl_config_ap(priv);
 		else {
-			priv->staging_rxon.filter_flags |=
-						RXON_FILTER_ASSOC_MSK;
 			rc = iwl_commit_rxon(priv);
 			if ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && rc)
 				iwl_rxon_add_station(
@@ -7582,6 +7597,7 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		}
 
 	} else {
+		iwl_scan_cancel_timeout(priv, 100);
 		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
 		iwl_commit_rxon(priv);
 	}
@@ -7621,6 +7637,12 @@ static void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	IWL_DEBUG_MAC80211("enter\n");
 
 	mutex_lock(&priv->mutex);
+
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+
 	if (priv->interface_id == conf->if_id) {
 		priv->interface_id = 0;
 		memset(priv->bssid, 0, ETH_ALEN);
@@ -7642,6 +7664,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 	IWL_DEBUG_MAC80211("enter\n");
 
+	mutex_lock(&priv->mutex);
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!iwl_is_ready_rf(priv)) {
@@ -7672,7 +7695,8 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 		priv->direct_ssid_len = (u8)
 		    min((u8) len, (u8) IW_ESSID_MAX_SIZE);
 		memcpy(priv->direct_ssid, ssid, priv->direct_ssid_len);
-	}
+	} else
+		priv->one_direct_scan = 0;
 
 	rc = iwl_scan_initiate(priv);
 
@@ -7680,6 +7704,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 out_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
+	mutex_unlock(&priv->mutex);
 
 	return rc;
 }
@@ -7713,6 +7738,8 @@ static int iwl_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	mutex_lock(&priv->mutex);
 
+	iwl_scan_cancel_timeout(priv, 100);
+
 	switch (cmd) {
 	case  SET_KEY:
 		rc = iwl_update_sta_key_info(priv, key, sta_id);
@@ -7903,8 +7930,18 @@ static void iwl_mac_reset_tsf(struct ieee80211_hw *hw)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
+	/* we are restarting association process
+	 * clear RXON_FILTER_ASSOC_MSK bit
+	 */
+	if (priv->iw_mode != IEEE80211_IF_TYPE_AP) {
+		iwl_scan_cancel_timeout(priv, 100);
+		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+		iwl_commit_rxon(priv);
+	}
+
 	/* Per mac80211.h: This is only used in IBSS mode... */
 	if (priv->iw_mode != IEEE80211_IF_TYPE_IBSS) {
+
 		IWL_DEBUG_MAC80211("leave - not in IBSS\n");
 		mutex_unlock(&priv->mutex);
 		return;
@@ -9152,6 +9189,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 		iwl_rate_control_unregister(priv->hw);
 	}
 
+	/*netif_stop_queue(dev); */
+	flush_workqueue(priv->workqueue);
+
 	/* ieee80211_unregister_hw calls iwl_mac_stop, which flushes
 	 * priv->workqueue... so we can't take down the workqueue
 	 * until now... */
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 298faa9..06d9bc0 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -30,7 +30,7 @@
  * Interval defines
  * Both the link tuner as the rfkill will be called once per second.
  */
-#define LINK_TUNE_INTERVAL	( round_jiffies(HZ) )
+#define LINK_TUNE_INTERVAL	( round_jiffies_relative(HZ) )
 #define RFKILL_POLL_INTERVAL	( 1000 )
 
 /*
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index de61c8f..e454ae8 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -433,6 +433,9 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 
 	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0xFFFF);
 
+	rtl818x_iowrite32(priv, &priv->map->MAR[0], ~0);
+	rtl818x_iowrite32(priv, &priv->map->MAR[1], ~0);
+
 	rtl8187_init_urbs(dev);
 
 	reg = RTL818X_RX_CONF_ONLYERLPKT |
@@ -582,32 +585,31 @@ static int rtl8187_config_interface(struct ieee80211_hw *dev, int if_id,
 static void rtl8187_configure_filter(struct ieee80211_hw *dev,
 				     unsigned int changed_flags,
 				     unsigned int *total_flags,
-				     int mc_count, struct dev_addr_list *mc_list)
+				     int mc_count, struct dev_addr_list *mclist)
 {
 	struct rtl8187_priv *priv = dev->priv;
 
-	*total_flags = 0;
-
-	if (changed_flags & FIF_ALLMULTI)
-		priv->rx_conf ^= RTL818X_RX_CONF_MULTICAST;
 	if (changed_flags & FIF_FCSFAIL)
 		priv->rx_conf ^= RTL818X_RX_CONF_FCS;
 	if (changed_flags & FIF_CONTROL)
 		priv->rx_conf ^= RTL818X_RX_CONF_CTRL;
 	if (changed_flags & FIF_OTHER_BSS)
 		priv->rx_conf ^= RTL818X_RX_CONF_MONITOR;
-
-	if (mc_count > 0)
+	if (*total_flags & FIF_ALLMULTI || mc_count > 0)
 		priv->rx_conf |= RTL818X_RX_CONF_MULTICAST;
+	else
+		priv->rx_conf &= ~RTL818X_RX_CONF_MULTICAST;
+
+	*total_flags = 0;
 
-	if (priv->rx_conf & RTL818X_RX_CONF_MULTICAST)
-		*total_flags |= FIF_ALLMULTI;
 	if (priv->rx_conf & RTL818X_RX_CONF_FCS)
 		*total_flags |= FIF_FCSFAIL;
 	if (priv->rx_conf & RTL818X_RX_CONF_CTRL)
 		*total_flags |= FIF_CONTROL;
 	if (priv->rx_conf & RTL818X_RX_CONF_MONITOR)
 		*total_flags |= FIF_OTHER_BSS;
+	if (priv->rx_conf & RTL818X_RX_CONF_MULTICAST)
+		*total_flags |= FIF_ALLMULTI;
 
 	rtl818x_iowrite32_async(priv, &priv->map->RX_CONF, priv->rx_conf);
 }
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 5afcb2f..d8b6600 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -345,7 +345,7 @@ static int serial_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	if (do_sound) {
