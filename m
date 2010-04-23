From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 1/7] Topcliff GbE: Add The Main code [2/3]
Date: Fri, 23 Apr 2010 20:56:25 +0900
Message-ID: <002e01cae2dd$1f9b9460$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=3;
	id="01CAE2DD.1F112EB0@tsmail03";
	number=2
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34050 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757239Ab0DWMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


+ disable_irq(adapter->pdev->irq);
+ pch_gbe_intr(adapter->pdev->irq, netdev);
+ enable_irq(adapter->pdev->irq);
+}
+#endif
+
+/* ------------------------------------------------------------------------
----
+ Linux driver internal function
+---------------------------------------------------------------------------
- */
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
+ * @brief   Initialize general software structures (struct pch_gbe_adapter)
+ * @param   adapter  [INOUT] Board private structure to initialize
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ * @remarks
+ *   pch_gbe_sw_init initializes the Adapter private data structure.
+ *   Fields are initialized based on PCI device information and
+ *   OS network device settings (MTU size).
+ */
+static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct net_device *netdev = adapter->netdev;
+ struct pci_dev *pdev = adapter->pdev;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ /* PCI config space info */
+ hw->vendor_id = pdev->vendor;
+ hw->device_id = pdev->device;
+ hw->subsystem_vendor_id = pdev->subsystem_vendor;
+ hw->subsystem_device_id = pdev->subsystem_device;
+
+ pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+
+ adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_2048;
+ hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+ hw->mac.min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
+
+ /* Initialize the hardware-specific values */
+ if (pch_gbe_hal_setup_init_funcs(hw) != 0) {
+  DPRINTK(DRV, ERR, "Hardware Initialization Failure\n");
+  return -EIO;
+ }
+ if (pch_gbe_alloc_queues(adapter) != 0) {
+  DPRINTK(DRV, ERR, "Unable to allocate memory for queues\n");
+  return -ENOMEM;
+ }
+ dev_hold(adapter->polling_netdev);
+ set_bit(__LINK_STATE_START, &adapter->polling_netdev->state);
+
+ spin_lock_init(&adapter->hw.miim_lock);
+ spin_lock_init(&adapter->stats_lock);
+ atomic_set(&adapter->irq_sem, 0);
+ pch_gbe_irq_disable(adapter);
+
+ pch_gbe_init_stats(adapter);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("hw->vendor_id : 0x%08x\n", hw->vendor_id);
+ PCH_DEBUG("hw->device_id : 0x%08x\n", hw->device_id);
+ PCH_DEBUG("hw->subsystem_vendor_id :0x%08x\n",
+   hw->subsystem_vendor_id);
+ PCH_DEBUG("hw->subsystem_device_id :0x%08x\n",
+   hw->subsystem_device_id);
+ PCH_DEBUG("hw->revision_id :0x%08x\n", hw->revision_id);
+ PCH_DEBUG("adapter->rx_buffer_len : %d\n",
+   (u32) adapter->rx_buffer_len);
+ PCH_DEBUG("hw->mac.max_frame_size : %d\n",
+   hw->mac.max_frame_size);
+ PCH_DEBUG("hw->mac.min_frame_size : %d\n",
+   hw->mac.min_frame_size);
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static int pch_gbe_alloc_queues(struct pch_gbe_adapter
*adapter)
+ * @brief   Allocate memory for all rings
+ * @param   adapter  [INOUT] Board private structure to initialize
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ * @remarks
+ *   We allocate one ring per queue at run-time since we don't know the
+ *   number of queues at compile-time.  The polling_netdev array is
+ *   intended for Multiqueue, but should work fine with a single queue.
+ */
+static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
+{
+ int size;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ size = (int)sizeof(struct pch_gbe_tx_ring);
+ adapter->tx_ring = kmalloc(size, GFP_KERNEL);
+ if (!adapter->tx_ring)
+  return -ENOMEM;
+ memset(adapter->tx_ring, 0, size);
+
+ size = (int)sizeof(struct pch_gbe_rx_ring);
+ adapter->rx_ring = kmalloc(size, GFP_KERNEL);
+ if (!adapter->rx_ring) {
+  kfree(adapter->tx_ring);
+  return -ENOMEM;
+ }
+ memset(adapter->rx_ring, 0, size);
+
+ size = (int)sizeof(struct net_device);
+ adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+ if (!adapter->polling_netdev) {
+  kfree(adapter->tx_ring);
+  kfree(adapter->rx_ring);
+  return -ENOMEM;
+ }
+ memset(adapter->polling_netdev, 0, size);
+
+#ifdef DEBUG_TEST
+ {
+  u32 *st_area, *sp_area;
+  st_area = (u32 *) adapter->tx_ring;
+  sp_area = (u32 *) (adapter->tx_ring +
+   (int)sizeof(struct pch_gbe_tx_ring) - 1);
+  PCH_DEBUG("tx_ring : 0x%08x - 0x%08x\n", *st_area,
+    *sp_area);
+  st_area = (u32 *) adapter->rx_ring;
+  sp_area = (u32 *) (adapter->rx_ring +
+   (int)sizeof(struct pch_gbe_rx_ring) - 1);
+  PCH_DEBUG("rx_ring : 0x%08x - 0x%08x\n", *st_area,
+    *sp_area);
+  st_area = (u32 *) adapter->polling_netdev;
+  sp_area = (u32 *) (adapter->polling_netdev +
+   (int)sizeof(struct net_device) - 1);
+  PCH_DEBUG("polling_netdev : 0x%08x - 0x%08x\n",
+    *st_area, *sp_area);
+ }
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter)
+ * @brief   Initialize status
+ * @param   adapter  [INOUT] Board private structure to initialize
+ * @return  None
+ */
+static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw_stats *stats = &adapter->stats;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ stats->rx_packets = 0;
+ stats->tx_packets = 0;
+ stats->rx_bytes = 0;
+ stats->tx_bytes = 0;
+ stats->rx_errors = 0;
+ stats->tx_errors = 0;
+ stats->rx_dropped = 0;
+ stats->tx_dropped = 0;
+ stats->multicast = 0;
+ stats->collisions = 0;
+ stats->rx_crc_errors = 0;
+ stats->rx_frame_errors = 0;
+ stats->rx_alloc_buff_failed = 0;
+ stats->tx_length_errors = 0;
+ stats->tx_aborted_errors = 0;
+ stats->tx_carrier_errors = 0;
+ stats->tx_timeout_count = 0;
+ stats->tx_restart_count = 0;
+ stats->intr_rx_dsc_empty_count = 0;
+ stats->intr_rx_frame_err_count = 0;
+ stats->intr_rx_fifo_err_count = 0;
+ stats->intr_rx_dma_err_count = 0;
+ stats->intr_tx_fifo_err_count = 0;
+ stats->intr_tx_dma_err_count = 0;
+ stats->intr_tcpip_err_count = 0;
+ return;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static int pch_gbe_init_nvm(struct pch_gbe_adapter *adapter)
+ * @brief   Initialize NVM
+ * @param   adapter  [INOUT] Board private structure to initialize
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+static int pch_gbe_init_nvm(struct pch_gbe_adapter *adapter)
+{
+ DPRINTK(DRV, DEBUG, "\n");
+
+#ifdef CONFIG_PCH_PHUB
+ /* make sure the NVM is good */
+ if ((pch_gbe_hal_validate_nvm_checksum(&adapter->hw) < 0)) {
+  DPRINTK(DRV, ERR, "The NVM Checksum Is Not Valid\n");
+  return -EIO;
+ }
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
+ * @brief   Initialize PHY
+ * @param   adapter  [INOUT] Board private structure to initialize
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
+{
+ struct net_device *netdev = adapter->netdev;
+ u32 addr;
+ u16 bmcr, stat;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ /* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
+ for (addr = 0; addr <= PHY_MAX_REG_ADDRESS; addr++) {
+  adapter->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
+  bmcr = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMCR);
+  stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
+  stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
+  if (!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
+   break;
+ }
+ adapter->hw.phy.addr = adapter->mii.phy_id;
+ DPRINTK(DRV, DEBUG, "phy_addr = %d\n", adapter->mii.phy_id);
+ if (addr == 32)
+  return -EAGAIN;
+ /* Selected the phy and isolate the rest */
+ for (addr = 0; addr <= PHY_MAX_REG_ADDRESS; addr++) {
+  if (addr != adapter->mii.phy_id) {
+   pch_gbe_mdio_write(netdev, addr, MII_BMCR,
+      BMCR_ISOLATE);
+  } else {
+   bmcr = pch_gbe_mdio_read(netdev, addr, MII_BMCR);
+   pch_gbe_mdio_write(netdev, addr, MII_BMCR,
+      bmcr & ~BMCR_ISOLATE);
+  }
+ }
+
+ /* MII setup */
+ adapter->mii.phy_id_mask = 0x1F;
+ adapter->mii.reg_num_mask = 0x1F;
+ adapter->mii.dev = adapter->netdev;
+ adapter->mii.mdio_read = pch_gbe_mdio_read;
+ adapter->mii.mdio_write = pch_gbe_mdio_write;
+ adapter->mii.supports_gmii = mii_check_gmii_support(&adapter->mii);
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      int pch_gbe_mdio_read(struct net_device *netdev, int addr, int
reg)
+ * @brief   The read function for mii
+ * @param   netdev [INOUT] Network interface device structure
+ * @param   addr   [IN] Phy ID
+ * @param   reg    [IN] Access location
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("pch_gbe_mdio_read\n");
+#endif
+ return pch_gbe_hal_ctrl_miim(hw, addr, PCH_GBE_HAL_MIIM_READ,
+     reg, (u16) 0);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_mdio_write(struct net_device *netdev,
+ *                                  int addr, int reg, int data)
+ * @brief   TThe write function for mii
+ * @param   netdev [INOUT] Network interface device structure
+ * @param   addr   [IN] Phy ID (not used)
+ * @param   reg    [IN]Access location
+ * @param   data   [IN] Write data
+ * @return  None
+ */
+void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg, int
data)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("pch_gbe_mdio_write\n");
+#endif
+ pch_gbe_hal_ctrl_miim(hw, addr, PCH_GBE_HAL_MIIM_WRITE, reg, data);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_reset_task(struct work_struct *work)
+ * @brief   Reset processing at the time of transmission timeout
+ * @param   work  [INOUT] Pointer of board private structure
+ * @return  None
+ */
+static void pch_gbe_reset_task(struct work_struct *work)
+{
+ struct pch_gbe_adapter *adapter;
+ adapter = container_of(work, struct pch_gbe_adapter, reset_task);
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ pch_gbe_reinit_locked(adapter);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter)
+ * @brief   Re-initialization
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter)
+{
+ DPRINTK(DRV, DEBUG, "\n");
+
+ while ((test_and_set_bit(__PCH_GBE_RESETTING, &adapter->flags)) != 0)
+  msleep(1);
+ pch_gbe_down(adapter);
+ pch_gbe_up(adapter);
+ clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_reset(struct pch_gbe_adapter *adapter)
+ * @brief   Reset GbE
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+void pch_gbe_reset(struct pch_gbe_adapter *adapter)
+{
+ DPRINTK(DRV, DEBUG, "\n");
+
+ pch_gbe_hal_reset_hw(&adapter->hw);
+
+ if (pch_gbe_hal_init_hw(&adapter->hw) != 0)
+  DPRINTK(DRV, ERR, "Hardware Error\n");
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
+ * @brief   Allocate an interrupt line
+ * @param   adapter  [INOUT] Board private structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
+{
+ struct net_device *netdev = adapter->netdev;
+ int err;
+ int flags;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ flags = IRQF_SHARED;
+ adapter->have_msi = FALSE;
+ err = pci_enable_msi(adapter->pdev);
+ PCH_DEBUG("call pci_enable_msi\n");
+ if (err != 0) {
+  DPRINTK(DRV, ERR,
+   "Unable to allocate MSI interrupt Error: %d\n", err);
+ } else {
+  flags = 0;
+  adapter->have_msi = TRUE;
+ }
+ err = request_irq(adapter->pdev->irq, &pch_gbe_intr,
+     flags, netdev->name, netdev);
+ if (err != 0) {
+  DPRINTK(DRV, ERR, "Unable to allocate interrupt Error: %d\n",
+   err);
+ }
+
+ PCH_DEBUG
+ ("adapter->have_msi : %d  flags : 0x%04x  return : 0x%04x\n",
+ adapter->have_msi, flags, err);
+ return err;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
+ * @brief   Free an interrupt
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
+{
+ struct net_device *netdev = adapter->netdev;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ free_irq(adapter->pdev->irq, netdev);
+ if (adapter->have_msi != 0) {
+  pci_disable_msi(adapter->pdev);
+  PCH_DEBUG("call pci_disable_msi");
+ }
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_irq_disable(struct pch_gbe_adapter
*adapter)
+ * @brief   Mask off interrupt generation on the NIC
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ atomic_inc(&adapter->irq_sem);
+ PCH_GBE_WRITE_REG(hw, INT_EN, 0);
+ synchronize_irq(adapter->pdev->irq);
+
+ PCH_DEBUG("INT_EN reg : 0x%08x\n", PCH_GBE_READ_REG(hw, INT_EN));
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter)
+ * @brief   Enable default interrupt generation settings
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ if (likely(atomic_dec_and_test(&adapter->irq_sem)))
+  PCH_GBE_WRITE_REG(hw, INT_EN, PCH_GBE_INT_ENABLE_MASK);
+ PCH_DEBUG("INT_EN reg : 0x%08x\n", PCH_GBE_READ_REG(hw, INT_EN));
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      int pch_gbe_up(struct pch_gbe_adapter *adapter)
+ * @brief   Up GbE network device
+ * @param   adapter  [INOUT] Board private structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+int pch_gbe_up(struct pch_gbe_adapter *adapter)
+{
+ struct net_device *netdev = adapter->netdev;
+ struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
+ struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
+ int err;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+
+ /* hardware has been reset, we need to reload some things */
+ pch_gbe_set_multi(netdev);
+
+ pch_gbe_setup_tctl(adapter);
+ pch_gbe_configure_tx(adapter);
+ pch_gbe_setup_rctl(adapter);
+ pch_gbe_configure_rx(adapter);
+
+ err = pch_gbe_request_irq(adapter);
+ if (err != 0) {
+  PCH_LOG(KERN_ERR, "Error: can't bring device up\n");
+  return err;
+ }
+ pch_gbe_alloc_tx_buffers(adapter, tx_ring);
+ pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
+ adapter->tx_queue_len = netdev->tx_queue_len;
+
+ mod_timer(&adapter->watchdog_timer, jiffies);
+
+ napi_enable(&adapter->napi);
+ pch_gbe_irq_enable(adapter);
+ netif_start_queue(adapter->netdev);
+
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_down(struct pch_gbe_adapter *adapter)
+ * @brief   Down GbE network device
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+void pch_gbe_down(struct pch_gbe_adapter *adapter)
+{
+ struct net_device *netdev = adapter->netdev;
+
+ DPRINTK(IFDOWN, DEBUG, "\n");
+
+ /* signal that we're down so the interrupt handler does not
+  * reschedule our watchdog timer */
+ napi_disable(&adapter->napi);
+ atomic_set(&adapter->irq_sem, 0);
+
+ pch_gbe_irq_disable(adapter);
+ pch_gbe_free_irq(adapter);
+
+ del_timer_sync(&adapter->watchdog_timer);
+
+ netdev->tx_queue_len = adapter->tx_queue_len;
+ netif_carrier_off(netdev);
+ netif_stop_queue(netdev);
+
+ pch_gbe_reset(adapter);
+ pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
+ pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+ *                                         struct pch_gbe_tx_ring *tx_ring)
+ * @brief   Allocate Tx resources (Descriptors)
+ * @param   adapter  [INOUT] Board private structure
+ * @param   tx_ring  [OUT] Tx descriptor ring (for a specific queue) to
setup
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+int
+pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+      struct pch_gbe_tx_ring *tx_ring)
+{
+ struct pci_dev *pdev = adapter->pdev;
+ struct pch_gbe_tx_desc *tx_desc;
+ int size;
+ int desNo;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
+ tx_ring->buffer_info = vmalloc(size);
+ if (!tx_ring->buffer_info) {
+  DPRINTK(DRV, ERR,
+   "Unable to allocate memory "
+   "for the buffer infomation\n");
+  return -ENOMEM;
+ }
+ memset(tx_ring->buffer_info, 0, size);
+
+ tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
+
+ tx_ring->desc =
+  pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);
+ if (!tx_ring->desc) {
+  vfree(tx_ring->buffer_info);
+  DPRINTK(DRV, ERR,
+   "Unable to allocate memory "
+   "for the transmit descriptor ring\n");
+  return -ENOMEM;
+ }
+ memset(tx_ring->desc, 0, tx_ring->size);
+
+ tx_ring->next_to_use = 0;
+ tx_ring->next_to_clean = 0;
+ spin_lock_init(&tx_ring->tx_lock);
+
+ for (desNo = 0; desNo < tx_ring->count; desNo++) {
+  tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
+  tx_desc->gbec_status = DSC_INIT16;
+ }
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("tx_ring->desc = 0x%08x  tx_ring->dma = 0x%08x\n",
+   (u32) tx_ring->desc, tx_ring->dma);
+ PCH_DEBUG("next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+   tx_ring->next_to_clean, tx_ring->next_to_use);
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+ *                                         struct pch_gbe_rx_ring *rx_ring)
+ * @brief   Allocate Rx resources (Descriptors)
+ * @param   adapter  [INOUT] Board private structure
+ * @param   rx_ring  [OUT] Rx descriptor ring (for a specific queue) to
setup
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+int
+pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring)
+{
+ struct pci_dev *pdev = adapter->pdev;
+ struct pch_gbe_rx_desc *rx_desc;
+ int size;
+ int desNo;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
+ rx_ring->buffer_info = vmalloc(size);
+ if (!rx_ring->buffer_info) {
+  DPRINTK(DRV, ERR,
+   "Unable to allocate memory "
+   "for the receive descriptor ring\n");
+  return -ENOMEM;
+ }
+ memset(rx_ring->buffer_info, 0, size);
+
+ rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
+
+ rx_ring->desc =
+  pci_alloc_consistent(pdev, rx_ring->size, &rx_ring->dma);
+
+ if (!rx_ring->desc) {
+  DPRINTK(DRV, ERR,
+   "Unable to allocate memory "
+   "for the receive descriptor ring\n");
+  vfree(rx_ring->buffer_info);
+  return -ENOMEM;
+ }
+
+ memset(rx_ring->desc, 0, rx_ring->size);
+
+ rx_ring->next_to_clean = 0;
+ rx_ring->next_to_use = 0;
+
+ for (desNo = 0; desNo < rx_ring->count; desNo++) {
+  rx_desc = PCH_GBE_RX_DESC(*rx_ring, desNo);
+  rx_desc->gbec_status = DSC_INIT16;
+ }
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("rx_ring->desc = 0x%08x  rx_ring->dma = 0x%08x\n",
+   (u32) rx_ring->desc, rx_ring->dma);
+ PCH_DEBUG("next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+   rx_ring->next_to_clean, rx_ring->next_to_use);
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+ *                                         struct pch_gbe_tx_ring *tx_ring)
+ * @brief   Free Tx Resources
+ * @param   adapter  [INOUT] Board private structure
+ * @param   tx_ring  [OUT] Tx descriptor ring for a specific queue
+ * @return  None
+ * @remarks
+ *    Free all transmit software resources
+ */
+void
+pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+     struct pch_gbe_tx_ring *tx_ring)
+{
+ struct pci_dev *pdev = adapter->pdev;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ pch_gbe_clean_tx_ring(adapter, tx_ring);
+ vfree(tx_ring->buffer_info);
+ tx_ring->buffer_info = NULL;
+ pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
+ tx_ring->desc = NULL;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+ *                                         struct pch_gbe_rx_ring *rx_ring)
+ * @brief   Free Rx Resources
+ * @param   adapter  [INOUT] Board private structure
+ * @param   rx_ring  [OUT] ring to clean the resources from
+ * @return  None
+ * @remarks
+ *   Free all receive software resources
+ */
+void
+pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+     struct pch_gbe_rx_ring *rx_ring)
+{
+ struct pci_dev *pdev = adapter->pdev;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ pch_gbe_clean_rx_ring(adapter, rx_ring);
+ vfree(rx_ring->buffer_info);
+ rx_ring->buffer_info = NULL;
+ pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+ rx_ring->desc = NULL;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_setup_tctl(struct pch_gbe_adapter *adapter)
+ * @brief   configure the Transmit control registers
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ */
+static void pch_gbe_setup_tctl(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 tx_mode, tcpip;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+
+ tx_mode = PCH_GBE_TM_LONG_PKT |
+  PCH_GBE_TM_ST_AND_FD |
+  PCH_GBE_TM_SHORT_PKT |
+  PCH_GBE_TM_TH_TX_STRT_8 |
+  PCH_GBE_TM_TH_ALM_EMP_4 | PCH_GBE_TM_TH_ALM_FULL_8;
+
+ PCH_GBE_WRITE_REG(hw, TX_MODE, tx_mode);
+
+ tcpip = PCH_GBE_READ_REG(hw, TCPIP_ACC);
+ tcpip |= PCH_GBE_TX_TCPIPACC_EN;
+ PCH_GBE_WRITE_REG(hw, TCPIP_ACC, tcpip);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("TX_MODE reg = 0x%08x  TCPIP_ACC reg = 0x%08x\n",
+   PCH_GBE_READ_REG(hw, TX_MODE),
+   PCH_GBE_READ_REG(hw, TCPIP_ACC));
+#endif
+ return;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_configure_tx(struct pch_gbe_adapter
*adapter)
+ * @brief   Configure Transmit Unit after Reset
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ * @remarks
+ *   Configure the Tx unit of the MAC after a reset.
+ */
+static void pch_gbe_configure_tx(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 tdba, tdlen, dctrl;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+ PCH_DEBUG("dma adr = 0x%08x  size = 0x%08x\n",
+   adapter->tx_ring->dma, adapter->tx_ring->size);
+
+ /* Setup the HW Tx Head and Tail descriptor pointers */
+ tdba = adapter->tx_ring->dma;
+ tdlen = adapter->tx_ring->size - 0x10;
+ PCH_GBE_WRITE_REG(hw, TX_DSC_BASE, tdba);
+ PCH_GBE_WRITE_REG(hw, TX_DSC_SIZE, tdlen);
+ PCH_GBE_WRITE_REG(hw, TX_DSC_SW_P, tdba);
+
+ /* Enables Transmission DMA */
+ dctrl = PCH_GBE_READ_REG(hw, DMA_CTRL);
+ dctrl |= PCH_GBE_TX_DMA_EN;
+ PCH_GBE_WRITE_REG(hw, DMA_CTRL, dctrl);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+ ("BASE = 0x%08x  HW_P = 0x%08x  SIZE = 0x%08x  SW_P = 0x%08x\n",
+ PCH_GBE_READ_REG(hw, TX_DSC_BASE),
+ PCH_GBE_READ_REG(hw, TX_DSC_HW_P),
+ PCH_GBE_READ_REG(hw, TX_DSC_SIZE),
+ PCH_GBE_READ_REG(hw, TX_DSC_SW_P));
+ PCH_DEBUG("DMA_CTRL reg[bit0] = 0x%08x\n",
+   PCH_GBE_READ_REG(hw, DMA_CTRL));
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
+ * @brief   Configure the receive control registers
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ * @remarks
+ *   Configure the Tx unit of the MAC after a reset.
+ */
+static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 rx_mode, tcpip;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+
+ rx_mode = PCH_GBE_ADD_FIL_EN | PCH_GBE_MLT_FIL_EN |
+ PCH_GBE_RH_ALM_EMP_4 | PCH_GBE_RH_ALM_FULL_4 | PCH_GBE_RH_RD_TRG_8;
+
+ PCH_GBE_WRITE_REG(hw, RX_MODE, rx_mode);
+
+ tcpip = PCH_GBE_READ_REG(hw, TCPIP_ACC);
+
+ if (adapter->rx_csum == TRUE) {
+  tcpip &= ~PCH_GBE_RX_TCPIPACC_OFF;
+  tcpip |= PCH_GBE_RX_TCPIPACC_EN;
+ } else {
+  tcpip |= PCH_GBE_RX_TCPIPACC_OFF;
+  tcpip &= ~PCH_GBE_RX_TCPIPACC_EN;
+ }
+ PCH_GBE_WRITE_REG(hw, TCPIP_ACC, tcpip);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("RX_MODE reg = 0x%08x  TCPIP_ACC reg = 0x%08x\n",
+   PCH_GBE_READ_REG(hw, RX_MODE),
+   PCH_GBE_READ_REG(hw, TCPIP_ACC));
+#endif
+ return;
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_configure_rx(struct pch_gbe_adapter
*adapter)
+ * @brief   Configure Receive Unit after Reset
+ * @param   adapter  [INOUT] Board private structure
+ * @return  None
+ * @remarks
+ *   Configure the Rx unit of the MAC after a reset.
+ */
+static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 rdba, rdlen, rctl, rxdma;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+ PCH_DEBUG("dma adr = 0x%08x  size = 0x%08x\n",
+   adapter->rx_ring->dma, adapter->rx_ring->size);
+
+ pch_gbe_hal_force_mac_fc(hw);
+
+ /* Disables Receive MAC */
+ rctl = PCH_GBE_READ_REG(hw, MAC_RX_EN);
+ PCH_GBE_WRITE_REG(hw, MAC_RX_EN, (rctl & ~PCH_GBE_MRE_MAC_RX_EN));
+
+ /* Disables Receive DMA */
+ rxdma = PCH_GBE_READ_REG(hw, DMA_CTRL);
+ rxdma &= ~PCH_GBE_RX_DMA_EN;
+ PCH_GBE_WRITE_REG(hw, DMA_CTRL, rxdma);
+
+ PCH_DEBUG("MAC_RX_EN reg = 0x%08x  DMA_CTRL reg = 0x%08x\n",
+   PCH_GBE_READ_REG(hw, MAC_RX_EN),
+   PCH_GBE_READ_REG(hw, DMA_CTRL));
+
+ /* Setup the HW Rx Head and Tail Descriptor Pointers and
+  * the Base and Length of the Rx Descriptor Ring */
+ rdba = adapter->rx_ring->dma;
+ rdlen = adapter->rx_ring->size - 0x10;
+ PCH_GBE_WRITE_REG(hw, RX_DSC_BASE, rdba);
+ PCH_GBE_WRITE_REG(hw, RX_DSC_SIZE, rdlen);
+ PCH_GBE_WRITE_REG(hw, RX_DSC_SW_P, rdba + rdlen);
+
+ /* Enables Receive DMA */
+ rxdma = PCH_GBE_READ_REG(hw, DMA_CTRL);
+ rxdma |= PCH_GBE_RX_DMA_EN;
+ PCH_GBE_WRITE_REG(hw, DMA_CTRL, rxdma);
+ /* Enables Receive */
+ PCH_GBE_WRITE_REG(hw, MAC_RX_EN, PCH_GBE_MRE_MAC_RX_EN);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+ ("BASE = 0x%08x  HW_P = 0x%08x  SIZE = 0x%08x  SW_P = 0x%08x\n",
+ PCH_GBE_READ_REG(hw, RX_DSC_BASE),
+ PCH_GBE_READ_REG(hw, RX_DSC_HW_P),
+ PCH_GBE_READ_REG(hw, RX_DSC_SIZE),
+ PCH_GBE_READ_REG(hw, RX_DSC_SW_P));
+ PCH_DEBUG("MAC_RX_EN reg = 0x%08x  DMA_CTRL reg = 0x%08x\n",
+   PCH_GBE_READ_REG(hw, MAC_RX_EN),
+   PCH_GBE_READ_REG(hw, DMA_CTRL));
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_unmap_and_free_tx_resource(
+ *                                          struct pch_gbe_adapter
*adapter,
+ *                                          struct pch_gbe_buffer
*buffer_info)
+ * @brief   Unmap and free tx socket buffer
+ * @param   adapter     [INOUT] Board private structure
+ * @param   buffer_info [OUT] Buffer information structure
+ * @return  None
+ */
+static void
+pch_gbe_unmap_and_free_tx_resource(struct pch_gbe_adapter *adapter,
+     struct pch_gbe_buffer *buffer_info)
+{
+#ifdef DEBUG_TEST
+ PCH_DEBUG("pch_gbe_unmap_and_free_tx_resource\n");
+#endif
+ if (buffer_info->dma != 0) {
+  pci_unmap_page(adapter->pdev, buffer_info->dma,
+    buffer_info->length, PCI_DMA_TODEVICE);
+  buffer_info->dma = 0;
+ }
+ if (buffer_info->skb != 0) {
+  dev_kfree_skb_any(buffer_info->skb);
+  buffer_info->skb = NULL;
+ }
+ if (buffer_info->kernel_skb != 0) {
+  dev_kfree_skb_any(buffer_info->kernel_skb);
+  buffer_info->kernel_skb = NULL;
+ }
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+  ("buffer_info->dma : 0x%08x  buffer_info->skb : 0x%08x\n",
+  buffer_info->dma, buffer_info->skb);
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_unmap_and_free_rx_resource(
+ *                                          struct pch_gbe_adapter
*adapter,
+ *                                          struct pch_gbe_buffer
*buffer_info)
+ * @brief   Unmap and free rx socket buffer
+ * @param   adapter      [INOUT] Board private structure
+ * @param   buffer_info  [OUT] Buffer information structure
+ * @return  None
+ */
+static void
+pch_gbe_unmap_and_free_rx_resource(struct pch_gbe_adapter *adapter,
+       struct pch_gbe_buffer *buffer_info)
+{
+#ifdef DEBUG_TEST
+ PCH_DEBUG("pch_gbe_unmap_and_free_rx_resource\n");
+#endif
+ if (buffer_info->dma != 0) {
+  pci_unmap_single(adapter->pdev, buffer_info->dma,
+     buffer_info->length, PCI_DMA_FROMDEVICE);
+  buffer_info->dma = 0;
+ }
+ if (buffer_info->skb != 0) {
+  dev_kfree_skb_any(buffer_info->skb);
+  buffer_info->skb = NULL;
+ }
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+  ("buffer_info->dma : 0x%08x  buffer_info->skb : 0x%08x\n",
+  buffer_info->dma, buffer_info->skb);
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_clean_tx_ring(struct pch_gbe_adapter
*adapter,
+ *                                            struct pch_gbe_tx_ring
*tx_ring)
+ * @brief   Free Tx Buffers
+ * @param   adapter  [INOUT] Board private structure
+ * @param   tx_ring  [OUT] Ring to be cleaned
+ * @return  None
+ */
+static void
+pch_gbe_clean_tx_ring(struct pch_gbe_adapter *adapter,
+   struct pch_gbe_tx_ring *tx_ring)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct pch_gbe_buffer *buffer_info;
+ unsigned long size;
+ unsigned int i;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ /* Free all the Tx ring sk_buffs */
+ for (i = 0; i < tx_ring->count; i++) {
+  buffer_info = &tx_ring->buffer_info[i];
+  pch_gbe_unmap_and_free_tx_resource(adapter, buffer_info);
+ }
+ PCH_DEBUG("call pch_gbe_unmap_and_free_tx_resource() %d count\n",
+   i);
+
+ size = (unsigned long)sizeof(struct pch_gbe_buffer) * tx_ring->count;
+ memset(tx_ring->buffer_info, 0, size);
+
+ /* Zero out the descriptor ring */
+ memset(tx_ring->desc, 0, tx_ring->size);
+
+ tx_ring->next_to_use = 0;
+ tx_ring->next_to_clean = 0;
+
+ PCH_GBE_WRITE_REG(hw, TX_DSC_HW_P, tx_ring->dma);
+ PCH_GBE_WRITE_REG(hw, TX_DSC_SIZE, (tx_ring->size - 0x10));
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("next_to_use : %d  next_to_clean : %d\n",
+   tx_ring->next_to_use, tx_ring->next_to_clean);
+ PCH_DEBUG("TX_DSC_HW_P reg : 0x%08x  TX_DSC_SIZE reg : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, TX_DSC_HW_P),
+   PCH_GBE_READ_REG(hw, TX_DSC_SIZE));
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_clean_rx_ring(struct pch_gbe_adapter
*adapter,
+ *                                            struct pch_gbe_rx_ring
*rx_ring)
+ * @brief   Free Rx Buffers
+ * @param   adapter  [INOUT] Board private structure
+ * @param   rx_ring  [OUT] Ring to free buffers from
+ * @return  None
+ */
+static void
+pch_gbe_clean_rx_ring(struct pch_gbe_adapter *adapter,
+        struct pch_gbe_rx_ring *rx_ring)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct pch_gbe_buffer *buffer_info;
+ unsigned long size;
+ unsigned int i;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ /* Free all the Rx ring sk_buffs */
+ for (i = 0; i < rx_ring->count; i++) {
+  buffer_info = &rx_ring->buffer_info[i];
+  pch_gbe_unmap_and_free_rx_resource(adapter, buffer_info);
+ }
+ PCH_DEBUG("call pch_gbe_unmap_and_free_rx_resource() %d count\n",
+   i);
+
+ size = (unsigned long)sizeof(struct pch_gbe_buffer) * rx_ring->count;
+ memset(rx_ring->buffer_info, 0, size);
+
+ /* Zero out the descriptor ring */
+ memset(rx_ring->desc, 0, rx_ring->size);
+
+ rx_ring->next_to_clean = 0;
+ rx_ring->next_to_use = 0;
+
+ PCH_GBE_WRITE_REG(hw, RX_DSC_HW_P, rx_ring->dma);
+ PCH_GBE_WRITE_REG(hw, RX_DSC_SIZE, (rx_ring->size - 0x10));
+#ifdef DEBUG_TEST
+ PCH_DEBUG("next_to_use : %d  next_to_clean : %d\n",
+   rx_ring->next_to_use, rx_ring->next_to_clean);
+ PCH_DEBUG("RX_DSC_HW_P reg : 0x%08x  RX_DSC_SIZE reg : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, RX_DSC_HW_P),
+   PCH_GBE_READ_REG(hw, RX_DSC_SIZE));
+#endif
+}
+
+static void
+pch_gbe_set_rgmii_ctrl(struct pch_gbe_adapter *adapter, u16 speed, u16
duplex)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ unsigned long rgmii = 0;
+
+ DPRINTK(DRV, DEBUG, "\n");
+ /* Set the RGMII control. */
+#ifdef PCH_GBE_MAC_IFOP_RGMII
+ switch (speed) {
+ case SPEED_10:
+  rgmii = (PCH_GBE_RGMII_RATE_2_5M |
+    PCH_GBE_MAC_RGMII_CTRL_SETTING);
+  break;
+ case SPEED_100:
+  rgmii = (PCH_GBE_RGMII_RATE_25M |
+    PCH_GBE_MAC_RGMII_CTRL_SETTING);
+  break;
+ case SPEED_1000:
+  rgmii = (PCH_GBE_RGMII_RATE_125M |
+    PCH_GBE_MAC_RGMII_CTRL_SETTING);
+  break;
+ }
+ PCH_GBE_WRITE_REG(hw, RGMII_CTRL, rgmii);
+#else /* GMII */
+ rgmii = 0;
+ PCH_GBE_WRITE_REG(hw, RGMII_CTRL, rgmii);
+#endif
+}
+static void
+pch_gbe_set_mode(struct pch_gbe_adapter *adapter, u16 speed, u16 duplex)
+{
+ struct net_device *netdev = adapter->netdev;
+ struct pch_gbe_hw *hw = &adapter->hw;
+ unsigned long mode = 0;
+
+ DPRINTK(DRV, DEBUG, "\n");
+ /* Set the communication mode */
+ switch (speed) {
+ case SPEED_10:
+  mode = PCH_GBE_MODE_MII_ETHER;
+  netdev->tx_queue_len = 10;
+  break;
+ case SPEED_100:
+  mode = PCH_GBE_MODE_MII_ETHER;
+  netdev->tx_queue_len = 100;
+  break;
+ case SPEED_1000:
+  mode = PCH_GBE_MODE_GMII_ETHER;
+  break;
+ }
+ if (duplex == DUPLEX_FULL)
+  mode |= PCH_GBE_MODE_FULL_DUPLEX;
+ else
+  mode |= PCH_GBE_MODE_HALF_DUPLEX;
+ PCH_GBE_WRITE_REG(hw, MODE, mode);
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_watchdog(unsigned long data)
+ * @brief   Watchdog process
+ * @param   data  [INOUT] Board private structure
+ * @return  None
+ */
+static void pch_gbe_watchdog(unsigned long data)
+{
+ struct pch_gbe_adapter *adapter = (struct pch_gbe_adapter *)data;
+ struct net_device *netdev = adapter->netdev;
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct ethtool_cmd cmd;
+
+ DPRINTK(INTR, DEBUG, "right now = %ld\n", jiffies);
+
+ pch_gbe_update_stats(adapter);
+ if ((mii_link_ok(&adapter->mii)) && (!netif_carrier_ok(netdev))) {
+  netdev->tx_queue_len = adapter->tx_queue_len;
+  /* mii library handles link maintenance tasks */
+  if (mii_ethtool_gset(&adapter->mii, &cmd) != 0) {
+   DPRINTK(INTR, ERR, "ethtool get setting Error\n");
+   mod_timer(&adapter->watchdog_timer,
+      round_jiffies(jiffies +
+      PCH_GBE_WATCHDOG_PERIOD));
+   return;
+  }
+  hw->mac.link_speed = cmd.speed;
+  hw->mac.link_duplex = cmd.duplex;
+  /* Set the RGMII control. */
+  pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
+      hw->mac.link_duplex);
+  /* Set the communication mode */
+  pch_gbe_set_mode(adapter, hw->mac.link_speed,
+      hw->mac.link_duplex);
+  DPRINTK(INTR, INFO, "NIC Link is Up %d Mbps %s-Duplex\n",
+   cmd.speed, cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
+  netif_carrier_on(netdev);
+  netif_wake_queue(netdev);
+ } else if ((!mii_link_ok(&adapter->mii)) &&
+     (netif_carrier_ok(netdev))) {
+  DPRINTK(INTR, INFO, "NIC Link is Down\n");
+  hw->mac.link_speed = SPEED_10;
+  hw->mac.link_duplex = DUPLEX_HALF;
+  netif_carrier_off(netdev);
+  netif_stop_queue(netdev);
+ }
+ mod_timer(&adapter->watchdog_timer,
+    round_jiffies(jiffies + PCH_GBE_WATCHDOG_PERIOD));
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+  ("RGMII_CTRL reg : 0x%08x  RGMII_ST reg : 0x%08x "
+  " MODE reg : 0x%08x\n",
+  PCH_GBE_READ_REG(hw, RGMII_CTRL),
+  PCH_GBE_READ_REG(hw, RGMII_ST),
+  PCH_GBE_READ_REG(hw, MODE));
+ PCH_DEBUG
+  ("link_speed : %d  link_duplex : %d  tx_queue_len : %d\n",
+  hw->mac.link_speed, hw->mac.link_duplex,
+  (u32) netdev->tx_queue_len);
+#endif
+}
+
+/*!
+ * @ingroup Linux driver internal function
+ * @fn      static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
+ *                    struct pch_gbe_tx_ring *tx_ring, struct sk_buff *skb)
+ * @brief   Carry out queuing of the transmission data
+ * @param   adapter  [INOUT] Board private structure
+ * @param   tx_ring  [OUT] Tx descriptor ring structure
+ * @param   skb      [IN] Sockt buffer structure
+ * @return  None
+ */
+static void
+pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
+   struct pch_gbe_tx_ring *tx_ring, struct sk_buff *skb)
+{
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct pch_gbe_tx_desc *tx_desc;
+ struct pch_gbe_buffer *buffer_info;
+ struct sk_buff *tmp_skb;
+ unsigned int frame_ctrl;
+ unsigned int ring_num;
+ unsigned long flags;
+
+ DPRINTK(DRV, DEBUG, "\n");
+
+ /*-- Set frame control --*/
+ frame_ctrl = 0;
+ if (unlikely(skb->len < PCH_GBE_SHORT_PKT))
+  frame_ctrl |= PCH_GBE_TXD_CTRL_APAD;
+ if (unlikely(adapter->tx_csum == FALSE))
+  frame_ctrl |= PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
+
+ /* Performs checksum processing */
+ /*
+  * It is because the hardware accelerator does not support a checksum,
+  * when the received data size is less than 64 bytes.
+  */
+ if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum == TRUE)) {
+  frame_ctrl |=
+   PCH_GBE_TXD_CTRL_APAD | PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
+  if (skb->protocol == htons(ETH_P_IP)) {
+   struct iphdr *iph = ip_hdr(skb);
+   unsigned int offset;
+   iph->check = 0;
+   iph->check = ip_fast_csum((u8 *) iph, iph->ihl);
+   offset = skb_transport_offset(skb);
+   if (iph->protocol == IPPROTO_TCP) {
+    skb->csum = 0;
+    tcp_hdr(skb)->check = 0;
+    skb->csum =
+     skb_checksum(skb, offset,
+      skb->len - offset, 0);
+    tcp_hdr(skb)->check =
+     csum_tcpudp_magic(iph->saddr,
+       iph->daddr,
+       skb->len - offset,
+       IPPROTO_TCP, skb->csum);
+   } else if (iph->protocol == IPPROTO_UDP) {
+    skb->csum = 0;
+    udp_hdr(skb)->check = 0;
+    skb->csum =
+     skb_checksum(skb, offset,
+      skb->len - offset, 0);
+    udp_hdr(skb)->check =
+     csum_tcpudp_magic(iph->saddr,
+       iph->daddr,
+       skb->len - offset,
+       IPPROTO_UDP, skb->csum);
+   }
+  }
+ }
+
+ spin_lock_irqsave(&tx_ring->tx_lock, flags);
+ ring_num = tx_ring->next_to_use;
+ if (unlikely((ring_num + 1) == tx_ring->count))
+  tx_ring->next_to_use = 0;
+ else
+  tx_ring->next_to_use = ring_num + 1;
+
+ spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+ buffer_info = &tx_ring->buffer_info[ring_num];
+ tmp_skb = buffer_info->skb;
+
+ /* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
+ memcpy(tmp_skb->data, skb->data, ETH_HLEN);
+ tmp_skb->data[ETH_HLEN] = 0x00;
+ tmp_skb->data[ETH_HLEN + 1] = 0x00;
+ tmp_skb->len = skb->len;
+ memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
+        (skb->len - ETH_HLEN));
+ buffer_info->kernel_skb = skb;
+ skb = tmp_skb;
+
+ /*-- Set Buffer infomation --*/
+ buffer_info->length = skb->len;
+ buffer_info->dma =
+     pci_map_single(adapter->pdev, skb->data, buffer_info->length,
+      PCI_DMA_TODEVICE);
+ buffer_info->time_stamp = jiffies;
+
+ /*-- Set Tx descriptor --*/

