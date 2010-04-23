From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 1/7] Topcliff GbE: Add The Main code [3/3]
Date: Fri, 23 Apr 2010 20:56:25 +0900
Message-ID: <002f01cae2dd$1fcb2fe0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=3;
	id="01CAE2DD.1F112EB0@tsmail03";
	number=3
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34053 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757304Ab0DWMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


+ tx_desc = PCH_GBE_TX_DESC(*tx_ring, ring_num);
+ tx_desc->buffer_addr = (buffer_info->dma);
+ tx_desc->length = (skb->len);
+ tx_desc->tx_words_eob = ((skb->len + 3));
+ tx_desc->tx_frame_ctrl = (frame_ctrl);
+ tx_desc->gbec_status = (DSC_INIT16);
+
+ if (unlikely(++ring_num == tx_ring->count))
+  ring_num = 0;
+
+#ifdef DEBUG_TEST
+ {
+  unsigned char *rd_data;
+
+  rd_data = (unsigned char *)tx_desc;
+  PCH_DEBUG
+      ("buffer_info->dma : 0x%08x  skb->len : 0x%08x  "
+       "frame_ctrl : 0x%08x\n",
+       buffer_info->dma, skb->len, frame_ctrl);
+  PCH_DEBUG
+      ("tx_desc: \n 0x%02x 0x%02x 0x%02x 0x%02x\n 0x%02x "
+       "0x%02x 0x%02x 0x%02x\n 0x%02x 0x%02x 0x%02x 0x%02x\n "
+       "0x%02x 0x%02x 0x%02x 0x%02x\n",
+       rd_data[0], rd_data[1], rd_data[2], rd_data[3], rd_data[4],
+       rd_data[5], rd_data[6], rd_data[7], rd_data[8], rd_data[9],
+       rd_data[10], rd_data[11], rd_data[12], rd_data[13],
+       rd_data[14], rd_data[15]);
+ }
+#endif
+
+ /* Update software pointer of TX descriptor */
+ PCH_GBE_WRITE_REG(hw, TX_DSC_SW_P,
+     tx_ring->dma +
+     (int)sizeof(struct pch_gbe_tx_desc) * ring_num);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
+ * @brief   Update the board statistics counters
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
+{
+ struct pci_dev *pdev = adapter->pdev;
+ struct pch_gbe_hw_stats *stats = &adapter->stats;
+ struct net_device_stats *net_stats = &adapter->net_stats;
+ unsigned long flags;
+
+ DPRINTK(DRV, DEBUG, "\n");
+ /*
+  * Prevent stats update while adapter is being reset, or if the pci
+  * connection is down.
+  */
+ if ((pdev->error_state) && (pdev->error_state != pci_channel_io_normal))
+  return;
+
+ spin_lock_irqsave(&adapter->stats_lock, flags);
+
+ /* Update device status "adapter->stats" */
+ stats->rx_errors = stats->rx_crc_errors + stats->rx_frame_errors;
+ stats->tx_errors = stats->tx_length_errors +
+     stats->tx_aborted_errors +
+     stats->tx_carrier_errors + stats->tx_timeout_count;
+
+ /* Update network device status "adapter->net_stats" */
+ net_stats->rx_packets = stats->rx_packets;
+ net_stats->tx_packets = stats->tx_packets;
+ net_stats->rx_bytes = stats->rx_bytes;
+ net_stats->tx_bytes = stats->tx_bytes;
+ net_stats->rx_errors = stats->rx_errors;
+ net_stats->tx_errors = stats->tx_errors;
+ net_stats->rx_dropped = stats->rx_dropped;
+ net_stats->tx_dropped = stats->tx_dropped;
+ net_stats->multicast = stats->multicast;
+ net_stats->collisions = stats->collisions;
+ net_stats->rx_crc_errors = stats->rx_crc_errors;
+ net_stats->rx_frame_errors = stats->rx_frame_errors;
+ net_stats->tx_aborted_errors = stats->tx_aborted_errors;
+ net_stats->tx_carrier_errors = stats->tx_carrier_errors;
+
+ spin_unlock_irqrestore(&adapter->stats_lock, flags);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static irqreturn_t pch_gbe_intr(int irq, void *data)
+ * @brief   Interrupt Handler
+ * @param   irq   [IN] Interrupt number
+ * @param   data  [INOUT] Pointer to a network interface device structure
+ * @return  None
+ */
+static irqreturn_t pch_gbe_intr(int irq, void *data)
+{
+ struct net_device *netdev = data;
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 int_st;
+ u32 int_en;
+
+ DPRINTK(INTR, DEBUG, "\n");
+
+ /* Check request status */
+ int_st = PCH_GBE_READ_REG(hw, INT_ST);
+ PCH_DEBUG("int_st = 0x%08x\n", int_st);
+
+ int_st = int_st & PCH_GBE_READ_REG(hw, INT_EN);
+ /* When request status is no interruption factor */
+ if (unlikely(!int_st)) {
+  /* End processing. */
+  PCH_DEBUG("return = 0x%08x\n", IRQ_NONE);
+  return IRQ_NONE; /* Not our interrupt */
+ }
+ if (int_st & PCH_GBE_INT_RX_FRAME_ERR)
+  adapter->stats.intr_rx_frame_err_count++;
+ if (int_st & PCH_GBE_INT_RX_FIFO_ERR)
+  adapter->stats.intr_rx_fifo_err_count++;
+ if (int_st & PCH_GBE_INT_RX_DMA_ERR)
+  adapter->stats.intr_rx_dma_err_count++;
+ if (int_st & PCH_GBE_INT_TX_FIFO_ERR)
+  adapter->stats.intr_tx_fifo_err_count++;
+ if (int_st & PCH_GBE_INT_TX_DMA_ERR)
+  adapter->stats.intr_tx_dma_err_count++;
+ if (int_st & PCH_GBE_INT_TCPIP_ERR)
+  adapter->stats.intr_tcpip_err_count++;
+ /* When Rx descriptor is empty  */
+ if ((int_st & PCH_GBE_INT_RX_DSC_EMP) != 0) {
+  adapter->stats.intr_rx_dsc_empty_count++;
+  DPRINTK(INTR, ERR, "Rx descriptor is empty\n");
+  int_en = PCH_GBE_READ_REG(hw, INT_EN);
+  PCH_GBE_WRITE_REG(hw, INT_EN,
+      (int_en & ~PCH_GBE_INT_RX_DSC_EMP));
+  if (hw->mac.tx_fc_enable == TRUE) {
+   /* Set Pause packet */
+   pch_gbe_hal_set_pause_packet(hw);
+  }
+  if ((int_en & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))
+      == 0) {
+   return IRQ_HANDLED;
+  }
+ }
+
+ /* When request status is Receive interruption */
+ if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT)) != 0) {
+  if (likely(napi_schedule_prep(&adapter->napi))) {
+   /* Enable only Rx Descriptor empty */
+   atomic_inc(&adapter->irq_sem);
+   int_en = PCH_GBE_READ_REG(hw, INT_EN);
+   int_en &=
+       ~(PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT);
+   PCH_GBE_WRITE_REG(hw, INT_EN, int_en);
+   /* Start polling for NAPI */
+   __napi_schedule(&adapter->napi);
+  }
+ }
+ PCH_DEBUG("return = 0x%08x  INT_EN reg = 0x%08x\n",
+   IRQ_HANDLED, PCH_GBE_READ_REG(hw, INT_EN));
+ return IRQ_HANDLED;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static unsigned char pch_gbe_clean_tx(struct pch_gbe_adapter
*adapter,
+ *                                            struct pch_gbe_tx_ring
*tx_ring)
+ * @brief   Reclaim resources after transmit completes
+ * @param   adapter   [INOUT] Board private structure
+ * @param   tx_ring   [OUT] Tx descriptor ring
+ * @return  TRUE:  Cleaned the descriptor
+ * @return  FALSE: Not cleaned the descriptor
+ */
+static unsigned char
+pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
+   struct pch_gbe_tx_ring *tx_ring)
+{
+ struct pch_gbe_tx_desc *tx_desc;
+ struct pch_gbe_buffer *buffer_info;
+ struct sk_buff *skb;
+ unsigned int i;
+ unsigned int cleaned_count = 0;
+ unsigned char cleaned = FALSE;
+
+ DPRINTK(DRV, DEBUG, "\n");
+ PCH_DEBUG("next_to_clean : %d\n", tx_ring->next_to_clean);
+
+ i = tx_ring->next_to_clean;
+ tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+ PCH_DEBUG("gbec_status:0x%04x  dma_status:0x%04x\n",
+   tx_desc->gbec_status, tx_desc->dma_status);
+
+ while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
+  PCH_DEBUG("gbec_status:0x%04x\n", tx_desc->gbec_status);
+  cleaned = TRUE;
+  buffer_info = &tx_ring->buffer_info[i];
+  skb = buffer_info->skb;
+
+  if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_ABT) != 0) {
+   adapter->stats.tx_aborted_errors++;
+   DPRINTK(DRV, ERR, "Transfer Aboat Error\n");
+  } else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CRSER)
+      != 0) {
+   adapter->stats.tx_carrier_errors++;
+   DPRINTK(DRV, ERR, "Transfer Carrier Sense Error\n");
+  } else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_EXCOL)
+      != 0) {
+   adapter->stats.tx_aborted_errors++;
+   DPRINTK(DRV, ERR, "Transfer Collision Abort Error\n");
+  } else if ((tx_desc->gbec_status &
+       (PCH_GBE_TXD_GMAC_STAT_SNGCOL |
+        PCH_GBE_TXD_GMAC_STAT_MLTCOL)) != 0) {
+   adapter->stats.collisions++;
+   adapter->stats.tx_packets++;
+   adapter->stats.tx_bytes += skb->len;
+   DPRINTK(DRV, DEBUG, "Transfer Collision\n");
+  } else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CMPLT)
+      != 0) {
+   adapter->stats.tx_packets++;
+   adapter->stats.tx_bytes += skb->len;
+  }
+  if (buffer_info->dma != 0) {
+   PCH_DEBUG("unmap buffer_info->dma : %d\n", i);
+   pci_unmap_page(adapter->pdev, buffer_info->dma,
+           buffer_info->length, PCI_DMA_TODEVICE);
+   buffer_info->dma = 0;
+  }
+  if (buffer_info->skb != 0) {
+   PCH_DEBUG("trim buffer_info->skb : %d\n", i);
+   skb_trim(buffer_info->skb, 0);
+  }
+  if (buffer_info->kernel_skb != 0) {
+   PCH_DEBUG
+       ("free buffer_info->kernel_skb adr: 0x%x\n",
+        (u32)(buffer_info->kernel_skb));
+   dev_kfree_skb(buffer_info->kernel_skb);
+   buffer_info->kernel_skb = NULL;
+  }
+  tx_desc->gbec_status = DSC_INIT16;
+  if (unlikely(++i == tx_ring->count))
+   i = 0;
+  tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+
+  /* weight of a sort for tx, to avoid endless transmit cleanup */
+  if (cleaned_count++ == PCH_GBE_TX_WEIGHT)
+   break;
+ }
+ PCH_DEBUG("called pch_gbe_unmap_and_free_tx_resource() %dcount\n",
+   cleaned_count);
+ /* Recover from running out of Tx resources in xmit_frame */
+ if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
+  netif_wake_queue(adapter->netdev);
+  adapter->stats.tx_restart_count++;
+  DPRINTK(DRV, DEBUG, "Tx wake queue\n");
+ }
+ spin_lock(&adapter->tx_queue_lock);
+ tx_ring->next_to_clean = i;
+ spin_unlock(&adapter->tx_queue_lock);
+ PCH_DEBUG("next_to_clean : %d\n", tx_ring->next_to_clean);
+ return cleaned;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static unsigned char pch_gbe_clean_rx(struct pch_gbe_adapter
*adapter,
+ *                                            struct pch_gbe_rx_ring
*rx_ring,
+ *                                            int *work_done, int
work_to_do)
+ * @brief   Send received data up the network stack; legacy
+ * @param   adapter     [INOUT] Board private structure
+ * @param   rx_ring     [OUT] Rx descriptor ring
+ * @param   work_done   [OUT] Completed count
+ * @param   work_to_do  [IN] Request count
+ * @return  TRUE:  Cleaned the descriptor
+ * @return  FALSE: Not cleaned the descriptor
+ */
+static unsigned char
+pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
+   struct pch_gbe_rx_ring *rx_ring,
+   int *work_done, int work_to_do)
+{
+ struct net_device *netdev = adapter->netdev;
+ struct pci_dev *pdev = adapter->pdev;
+ struct pch_gbe_buffer *buffer_info;
+ struct pch_gbe_rx_desc *rx_desc;
+ u32 length;
+ unsigned char tmp_packet[ETH_HLEN];
+ unsigned int i;
+ unsigned int cleaned_count = 0;
+ unsigned char cleaned = FALSE;
+ struct sk_buff *skb;
+ u8 dma_status;
+ u16 gbec_status;
+ u32 tcp_ip_status;
+ u8 skb_copy_flag = 0;
+ u8 skb_padding_flag = 0;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ i = rx_ring->next_to_clean;
+
+ while (*work_done < work_to_do) {
+  /* Check Rx descriptor status */
+  rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+  if (rx_desc->gbec_status == DSC_INIT16)
+   break;
+  cleaned = TRUE;
+  cleaned_count++;
+
+  dma_status = rx_desc->dma_status;
+  gbec_status = rx_desc->gbec_status;
+  tcp_ip_status = rx_desc->tcp_ip_status;
+  rx_desc->gbec_status = DSC_INIT16;
+  buffer_info = &rx_ring->buffer_info[i];
+  skb = buffer_info->skb;
+
+  /* unmap dma */
+  pci_unmap_single(pdev, buffer_info->dma, buffer_info->length,
+     PCI_DMA_FROMDEVICE);
+  buffer_info->dma = 0;
+  /* Prefetch the packet */
+  prefetch(skb->data);
+
+  PCH_DEBUG
+   ("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
+    "TCP:0x%08x]  BufInf = 0x%08x\n",
+    i, dma_status, gbec_status, tcp_ip_status,
+    (u32) (buffer_info));
+  /* Error check */
+  if (unlikely(gbec_status & PCH_GBE_RXD_GMAC_STAT_NOTOCTAL)) {
+   adapter->stats.rx_frame_errors++;
+   DPRINTK(DRV, ERR, "Receive Not Octal Error\n");
+  } else if (unlikely(gbec_status &
+    PCH_GBE_RXD_GMAC_STAT_NBLERR)) {
+   adapter->stats.rx_frame_errors++;
+   DPRINTK(DRV, ERR, "Receive Nibble Error\n");
+  } else if (unlikely(gbec_status &
+    PCH_GBE_RXD_GMAC_STAT_CRCERR)) {
+   adapter->stats.rx_crc_errors++;
+   DPRINTK(DRV, ERR, "Receive CRC Error\n");
+  } else {
+   /* get receive length */
+   /* length convert[-3], padding[-2] */
+   length = (rx_desc->rx_words_eob) - 3 - 2;
+
+   /* Decide the data conversion method */
+   if (adapter->rx_csum != TRUE) {
+    /* [Header:14][payload] */
+    skb_padding_flag = 0;
+    skb_copy_flag = 1;
+   } else {
+    /* [Header:14][padding:2][payload] */
+    skb_padding_flag = 1;
+    if (length < copybreak)
+     skb_copy_flag = 1;
+    else
+     skb_copy_flag = 0;
+   }
+
+   /* Data conversion */
+   if (skb_copy_flag != 0) { /* recycle  skb */
+    struct sk_buff *new_skb;
+    new_skb =
+        netdev_alloc_skb(netdev,
+           length + NET_IP_ALIGN);
+    if (new_skb != 0) {
+     if (!skb_padding_flag) {
+      skb_reserve(new_skb,
+        NET_IP_ALIGN);
+     }
+     memcpy(new_skb->data, skb->data,
+      length);
+     /* save the skb
+      * in buffer_info as good */
+     skb = new_skb;
+    } else if (!skb_padding_flag) {
+     /* dorrop error */
+     DPRINTK(DRV, ERR,
+      "New skb allocation Error\n");
+     goto dorrop;
+    }
+   } else {
+    buffer_info->skb = NULL;
+   }
+   if (skb_padding_flag != 0) {
+    memcpy(&tmp_packet[0], &skb->data[0], ETH_HLEN);
+    memcpy(&skb->data[NET_IP_ALIGN], &tmp_packet[0],
+     ETH_HLEN);
+    skb_reserve(skb, NET_IP_ALIGN);
+
+   }
+
+   /* update status of driver */
+   adapter->stats.rx_bytes += length;
+   adapter->stats.rx_packets++;
+   if ((gbec_status & PCH_GBE_RXD_GMAC_STAT_MARMLT) != 0)
+    adapter->stats.multicast++;
+   /* Write meta date of skb */
+   skb_put(skb, length);
+   skb->protocol = eth_type_trans(skb, netdev);
+   if ((tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK) ==
+       PCH_GBE_RXD_ACC_STAT_TCPIPOK) {
+    skb->ip_summed = CHECKSUM_UNNECESSARY;
+   } else {
+    skb->ip_summed = CHECKSUM_NONE;
+   }
+
+   if (netif_receive_skb(skb) == NET_RX_DROP) {
+    adapter->stats.rx_dropped++;
+    DPRINTK(DRV, ERR,
+     "Receive Netif Receive Dropped Error\n");
+   }
+   (*work_done)++;
+   netdev->last_rx = jiffies;
+   PCH_DEBUG
+       ("Receive skb->ip_summed: %d length: %d\n",
+        skb->ip_summed, length);
+  }
+dorrop:
+  /* return some buffers to hardware, one at a time is too slow */
+  if (unlikely(cleaned_count >= PCH_GBE_RX_BUFFER_WRITE)) {
+   pch_gbe_alloc_rx_buffers(adapter, rx_ring,
+       cleaned_count);
+   cleaned_count = 0;
+  }
+  if (++i == rx_ring->count)
+   i = 0;
+ }
+ rx_ring->next_to_clean = i;
+ if (cleaned_count != 0)
+  pch_gbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
+#ifdef DEBUG_TEST
+ {
+  u32 tmp1, tmp2, tmp3, tmp4;
+  struct pch_gbe_hw *hw = &adapter->hw;
+
+  PCH_DEBUG
+   ("cleaned_count = %d  next_to_clean = %d  "
+    "next_to_use = %d\n",
+    cleaned_count, rx_ring->next_to_clean,
+    rx_ring->next_to_use);
+  tmp1 = PCH_GBE_READ_REG(hw, RX_DSC_BASE);
+  tmp2 = PCH_GBE_READ_REG(hw, RX_DSC_HW_P);
+  tmp3 = PCH_GBE_READ_REG(hw, RX_DSC_SIZE);
+  tmp4 = PCH_GBE_READ_REG(hw, RX_DSC_SW_P);
+  PCH_DEBUG
+   ("BASE = 0x%08x  HW_P = 0x%08x  "
+    "SIZE = 0x%08x  SW_P = 0x%08x\n",
+    tmp1, tmp2, tmp3, tmp4);
+  tmp1 = PCH_GBE_READ_REG(hw, DMA_CTRL);
+  tmp2 = PCH_GBE_READ_REG(hw, MAC_RX_EN);
+  PCH_DEBUG("DMA_CTRL = 0x%08x  MAC_RX_EN = 0x%08x\n", tmp1,
+    tmp2);
+  tmp1 = PCH_GBE_READ_REG(hw, RX_MODE);
+  tmp2 = PCH_GBE_READ_REG(hw, ADDR_MASK);
+  tmp3 = PCH_GBE_READ_REG(hw, MAC_ADR1A);
+  tmp4 = PCH_GBE_READ_REG(hw, MAC_ADR1B);
+  PCH_DEBUG
+   ("RX_MODE = 0x%08x  ADDR_MASK = 0x%08x  "
+    "MAC_ADR1A = 0x%08x  MAC_ADR1B = 0x%08x\n",
+    tmp1, tmp2, tmp3, tmp4);
+ }
+#endif
+ return cleaned;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_alloc_rx_buffers(
+ *                      struct pch_gbe_adapter *adapter,
+ *                      struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
+ * @brief   Replace used receive buffers; legacy & extended
+ * @param   adapter       [INOUT] Board private structure
+ * @param   rx_ring       [OUT] Rx descriptor ring
+ * @param   cleaned_count [IN] Cleaned count
+ * @return  None
+ */
+static void
+pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
+{
+ struct net_device *netdev = adapter->netdev;
+ struct pci_dev *pdev = adapter->pdev;
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct pch_gbe_rx_desc *rx_desc;
+ struct pch_gbe_buffer *buffer_info;
+ struct sk_buff *skb;
+ unsigned int i;
+ unsigned int bufsz;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ bufsz = adapter->rx_buffer_len + PCH_GBE_DMA_ALIGN;
+ i = rx_ring->next_to_use;
+
+ while ((cleaned_count--) != 0) {
+  buffer_info = &rx_ring->buffer_info[i];
+  skb = buffer_info->skb;
+  if (skb != 0) {
+   skb_trim(skb, 0);
+  } else {
+   skb = netdev_alloc_skb(netdev, bufsz);
+   if (unlikely(!skb)) {
+    /* Better luck next round */
+    adapter->stats.rx_alloc_buff_failed++;
+    break;
+   }
+   /* 64byte align */
+   skb_reserve(skb, PCH_GBE_DMA_ALIGN);
+
+   buffer_info->skb = skb;
+   buffer_info->length = adapter->rx_buffer_len;
+  }
+
+  buffer_info->dma = pci_map_single(pdev,
+        skb->data,
+        buffer_info->length,
+        PCI_DMA_FROMDEVICE);
+
+  rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+  rx_desc->buffer_addr = (buffer_info->dma);
+  rx_desc->gbec_status = DSC_INIT16;
+
+  PCH_DEBUG("i = %d  buffer_info->dma = 0x%x  "
+    "buffer_info->length = 0x%x\n",
+    i, buffer_info->dma, buffer_info->length);
+
+  if (unlikely(++i == rx_ring->count))
+   i = 0;
+ }
+ if (likely(rx_ring->next_to_use != i)) {
+  rx_ring->next_to_use = i;
+  if (unlikely(i-- == 0))
+   i = (rx_ring->count - 1);
+  wmb();
+  PCH_GBE_WRITE_REG(hw, RX_DSC_SW_P,
+      rx_ring->dma +
+      (int)sizeof(struct pch_gbe_rx_desc) * i);
+ }
+ return;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_alloc_tx_buffers(
+ *                                   struct pch_gbe_adapter *adapter,
+ *                                   struct pch_gbe_tx_ring *tx_ring)
+ * @brief   Allocate transmit buffers
+ * @param   adapter   [INOUT] Board private structure
+ * @param   tx_ring   [OUT] Tx descriptor ring
+ * @return  None
+ */
+static void
+pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *tx_ring)
+{
+ struct pch_gbe_buffer *buffer_info;
+ struct sk_buff *skb;
+ unsigned int i;
+ unsigned int bufsz;
+ struct pch_gbe_tx_desc *tx_desc;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ bufsz =
+     adapter->hw.mac.max_frame_size + PCH_GBE_DMA_ALIGN + NET_IP_ALIGN;
+
+ for (i = 0; i < tx_ring->count; i++) {
+  buffer_info = &tx_ring->buffer_info[i];
+  skb = netdev_alloc_skb(adapter->netdev, bufsz);
+  skb_reserve(skb, PCH_GBE_DMA_ALIGN);
+  buffer_info->skb = skb;
+  tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+  tx_desc->gbec_status = (DSC_INIT16);
+ }
+
+ return;
+}
+/* pch_gbe_main.c */

