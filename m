From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 09:05:04 -0700
Message-ID: <20100826090504.30ce58e5@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


+static int pch_gbe_probe(struct pci_dev *pdev,
+			  const struct pci_device_id *pci_id)
+{
+	struct net_device *netdev;
+	struct pch_gbe_adapter *adapter;
+	unsigned long mmio_start;
+	unsigned long mmio_len;
+	int i, ret;
+
+	PCH_GBE_DEBUG("pch_gbe_probe\n");
+	ret = pci_enable_device(pdev);
+	if (ret)
+		return ret;
+
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
+		&& !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		;
+	} else {
+		ret = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (ret) {
+			ret = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
+			if (ret) {
+				printk(KERN_ERR KBUILD_MODNAME ": ERR: "
+				    "No usable DMA configuration, aborting\n");
+				goto err_disable_device;
+			}
+		}
+	}
+	ret = pci_request_regions(pdev, KBUILD_MODNAME);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+		    "ERR: Can't reserve PCI I/O and memory resources\n");
+		goto err_disable_device;
+	}
+	pci_set_master(pdev);
+
+	netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
+	if (!netdev) {
+		ret = -ENOMEM;
+		printk(KERN_ERR KBUILD_MODNAME ": "
+		    "ERR: Can't allocates and sets up an Ethernet device\n");
+		goto err_release_pci;
+	}
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	pci_set_drvdata(pdev, netdev);
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->pdev = pdev;
+	adapter->hw.back = adapter;
+	mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
+	mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
+	adapter->hw.reg = ioremap_nocache(mmio_start, mmio_len);
+	if (!adapter->hw.reg) {
+		ret = -EIO;
+		printk(KERN_ERR KBUILD_MODNAME ": " "Can't ioremap\n");
+		goto err_free_netdev;
+	}
+
+	netdev->netdev_ops = &pch_gbe_netdev_ops;
+	netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
+	netif_napi_add(netdev, &adapter->napi,
+		       pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
+	strncpy(netdev->name, pci_name(pdev), (int)sizeof(netdev->name) - 1);
+	netdev->mem_start = mmio_start;
+	netdev->mem_end = mmio_start + mmio_len;
+	netdev->features = NETIF_F_HW_CSUM;
+	pch_gbe_set_ethtool_ops(netdev);
+
+	pch_gbe_mac_reset_hw(&adapter->hw);
+
+	/* setup the private structure */
+	ret = pch_gbe_sw_init(adapter);
+	if (ret)
+		goto err_iounmap;
+
+	/* Initialize PHY */
+	ret = pch_gbe_init_phy(adapter);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "PHY initialize error\n");
+		goto err_free_adapter;
+	}
+	pch_gbe_hal_get_bus_info(&adapter->hw);
+
+	/* Read the MAC address. and store to the private data */
+	ret = pch_gbe_hal_read_mac_addr(&adapter->hw);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "MAC address Read Error\n");
+		goto err_free_adapter;
+	}
+
+	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "Invalid MAC Address\n");
+		ret = -EIO;
+		goto err_free_adapter;
+	}
+
+	init_timer(&adapter->watchdog_timer);
+	adapter->watchdog_timer.function = &pch_gbe_watchdog;
+	adapter->watchdog_timer.data = (unsigned long)adapter;
+
+	INIT_WORK(&adapter->reset_task, pch_gbe_reset_task);
+
+	pch_gbe_check_options(adapter);
+
+	if (adapter->tx_csum)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	/* initialize the wol settings based on the eeprom settings */
+	adapter->wake_up_evt = PCH_GBE_WL_INIT_SETTING;
+	for (i = 0; i < 6; i++)
+		printk(KERN_INFO "%2.2x%c",
+			netdev->dev_addr[i], i == 5 ? '\n' : ':');

This is wrong since it produces KERN_INFO tag without newline, and probably
you just want:
         printk(KERN_INFO "%pM", netdev->dev_addr);

or better yet, convert to dev_printk

+
+	/* reset the hardware with the new settings */
+	pch_gbe_reset(adapter);
+
+	strcpy(netdev->name, "eth%d");

This is unnecessary since you used alloc_etherdev()


+	ret = register_netdev(netdev);
+	if (ret)
+		goto err_free_adapter;
+	/* tell the stack to leave us alone until pch_gbe_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	PCH_GBE_DEBUG("OKIsemi(R) PCH Network Connection\n");
+
+	device_set_wakeup_enable(&pdev->dev, 1);
+	return 0;
+
+err_free_adapter:
+	pch_gbe_hal_phy_hw_reset(&adapter->hw);
+	dev_put(adapter->polling_netdev);
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+	kfree(adapter->polling_netdev);
+err_iounmap:
+	iounmap(adapter->hw.reg);
+err_free_netdev:
+	free_netdev(netdev);
+err_release_pci:
+	pci_release_regions(pdev);
+err_disable_device:
+	pci_disable_device(pdev);
+	return ret;
+}
