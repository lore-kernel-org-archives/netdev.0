From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 ethtool_ops support
Date: Fri, 16 Apr 2004 15:54:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416155449.0796053f@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Cramer <cramer@intel.com>,
        "Feldman, Scott"
 <scott.feldman@intel.com>,
        Jeff Garzik <jgarzik@pobox.com>, Chris Wright
 <chrisw@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, here is a first cut at ethtool ops integration for e1000.

It has been touch tested for the basic operations on a card on
a lab machine.  Please review before including in the 2.6.6 kernel.

diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	Fri Apr 16 15:50:02 2004
+++ b/drivers/net/e1000/e1000_ethtool.c	Fri Apr 16 15:50:02 2004
@@ -53,7 +53,7 @@
 
 #define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
 		      offsetof(struct e1000_adapter, m)
-static struct e1000_stats e1000_gstrings_stats[] = {
+static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(net_stats.rx_packets) },
 	{ "tx_packets", E1000_STAT(net_stats.tx_packets) },
 	{ "rx_bytes", E1000_STAT(net_stats.rx_bytes) },
@@ -100,9 +100,10 @@
 };
 #define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN
 
-static void
-e1000_ethtool_gset(struct e1000_adapter *adapter, struct ethtool_cmd *ecmd)
+static int
+e1000_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	if(hw->media_type == e1000_media_type_copper) {
@@ -169,11 +170,13 @@
 	}
 
 	ecmd->autoneg = (hw->autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
+	return 0;
 }
 
 static int
-e1000_ethtool_sset(struct e1000_adapter *adapter, struct ethtool_cmd *ecmd)
+e1000_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	if(ecmd->autoneg == AUTONEG_ENABLE) {
@@ -195,10 +198,11 @@
 	return 0;
 }
 
-static int
-e1000_ethtool_gpause(struct e1000_adapter *adapter,
+static void
+e1000_get_pauseparam(struct net_device *netdev,
                      struct ethtool_pauseparam *epause)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	
 	epause->autoneg = 
@@ -212,14 +216,13 @@
 		epause->rx_pause = 1;
 		epause->tx_pause = 1;
 	}
-	
-	return 0;
 }
 
 static int
-e1000_ethtool_spause(struct e1000_adapter *adapter,
+e1000_set_pauseparam(struct net_device *netdev,
                      struct ethtool_pauseparam *epause)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	
 	adapter->fc_autoneg = epause->autoneg;
@@ -248,28 +251,117 @@
 	return 0;
 }
 
+static u32
+e1000_get_rx_csum(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	return adapter->rx_csum;
+}
+
+static int
+e1000_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	adapter->rx_csum = data;
+	if(netif_running(netdev)) {
+		e1000_down(adapter);
+		e1000_up(adapter);
+	} else
+		e1000_reset(adapter);
+	return 0;
+}
+
+static u32
+e1000_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static int
+e1000_set_tx_csum(struct net_device *netdev, u32 data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if(adapter->hw.mac_type < e1000_82543)
+		return data ? -EINVAL : 0;
+
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+	return 0;
+}
+
+static u32
+e1000_get_sg(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_SG) != 0;
+}
+
+static int
+e1000_set_sg(struct net_device *netdev, u32 data)
+{
+	if (data)
+		netdev->features |= NETIF_F_SG;
+	else
+		netdev->features &= ~NETIF_F_SG;
+	return 0;
+}
+
+static u32
+e1000_get_tso(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_TSO);
+}
+
+static int
+e1000_set_tso(struct net_device *netdev, u32 data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->hw.mac_type < e1000_82544 ||
+	     adapter->hw.mac_type == e1000_82547)
+		return data ? -EINVAL : 0;
+		
+	if (data)
+		netdev->features |= NETIF_F_TSO;
+	else
+		netdev->features &= ~NETIF_F_TSO;
+	return 0;
+}
+
+
 static void
-e1000_ethtool_gdrvinfo(struct e1000_adapter *adapter,
-                       struct ethtool_drvinfo *drvinfo)
+e1000_get_drvinfo(struct net_device *dev, 
+		  struct ethtool_drvinfo *drvinfo)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
+
 	strncpy(drvinfo->driver,  e1000_driver_name, 32);
 	strncpy(drvinfo->version, e1000_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->n_stats = E1000_STATS_LEN;
-	drvinfo->testinfo_len = E1000_TEST_LEN;
+}
+
+static int
+e1000_get_regs_len(struct net_device *dev)
+{
 #define E1000_REGS_LEN 32
-	drvinfo->regdump_len  = E1000_REGS_LEN * sizeof(uint32_t);
-	drvinfo->eedump_len = adapter->hw.eeprom.word_size * 2;
+	return E1000_REGS_LEN * sizeof(uint32_t);
 }
 
 static void
-e1000_ethtool_gregs(struct e1000_adapter *adapter,
-                    struct ethtool_regs *regs, uint32_t *regs_buff)
+e1000_get_regs(struct net_device *dev,
+	       struct ethtool_regs *regs, void *p)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 *regs_buff = p;
 	uint16_t phy_data;
 
+	memset(p, 0, E1000_REGS_LEN * sizeof(uint32_t));
+
 	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
 
 	regs_buff[0]  = E1000_READ_REG(hw, CTRL);
@@ -342,30 +434,36 @@
 	e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
 	regs_buff[24] = (uint32_t)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
+}
+
+static int
+e1000_get_eeprom_len(struct net_device *dev)
+{
+	struct e1000_adapter *adapter = netdev_priv(dev);
 
-	return;
+	return adapter->hw.eeprom.word_size * 2;
 }
 
 static int
-e1000_ethtool_geeprom(struct e1000_adapter *adapter,
-                      struct ethtool_eeprom *eeprom, uint16_t *eeprom_buff)
+e1000_get_eeprom(struct net_device *dev,
+		 struct ethtool_eeprom *eeprom, u8 *bytes)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
+	uint16_t *eeprom_buff = (uint16_t *) bytes;
 	int first_word, last_word;
 	int ret_val = 0;
 	uint16_t i;
 
-	if(eeprom->len == 0) {
-		ret_val = -EINVAL;
-		goto geeprom_error;
-	}
+	if(eeprom->len == 0) 
+		return  -EINVAL;
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
 
-	if(eeprom->offset > eeprom->offset + eeprom->len) {
-		ret_val = -EINVAL;
-		goto geeprom_error;
-	}
+	if(eeprom->offset > eeprom->offset + eeprom->len) 
+		return -EINVAL;
+
+	memset(bytes, 0, adapter->hw.eeprom.word_size*2);
 
 	if((eeprom->offset + eeprom->len) > (hw->eeprom.word_size * 2))
 		eeprom->len = ((hw->eeprom.word_size * 2) - eeprom->offset);
@@ -388,14 +486,14 @@
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-geeprom_error:
 	return ret_val;
 }
 
 static int
-e1000_ethtool_seeprom(struct e1000_adapter *adapter,
-                      struct ethtool_eeprom *eeprom, void *user_data)
+e1000_set_eeprom(struct net_device *netdev,
+		 struct ethtool_eeprom *eeprom, u8 *bytes)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint16_t *eeprom_buff;
 	void *ptr;
@@ -439,11 +537,7 @@
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-	if((ret_val != 0) || copy_from_user(ptr, user_data, eeprom->len)) {
-		ret_val = -EFAULT;
-		goto seeprom_error;
-	}
-
+	memcpy(ptr, bytes, eeprom->len);
 	for (i = 0; i < last_word - first_word + 1; i++)
 		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
 
@@ -454,15 +548,15 @@
 	if((ret_val == 0) && first_word <= EEPROM_CHECKSUM_REG)
 		e1000_update_eeprom_checksum(hw);
 
-seeprom_error:
 	kfree(eeprom_buff);
 	return ret_val;
 }
 
-static int
-e1000_ethtool_gring(struct e1000_adapter *adapter,
+static void
+e1000_get_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->rx_ring;
@@ -477,13 +571,12 @@
 	ring->tx_pending = txdr->count;
 	ring->rx_mini_pending = 0;
 	ring->rx_jumbo_pending = 0;
-
-	return 0;
 }
+
 static int 
-e1000_ethtool_sring(struct e1000_adapter *adapter,
-                    struct ethtool_ringparam *ring)
+e1000_set_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int err;
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
@@ -806,8 +899,6 @@
 		kfree(txdr->buffer_info);
 	if(rxdr->buffer_info)
 		kfree(rxdr->buffer_info);
-
-	return;
 }
 
 static int
@@ -939,8 +1030,6 @@
 	e1000_write_phy_reg(&adapter->hw, 30, 0x8FFC);
 	e1000_write_phy_reg(&adapter->hw, 29, 0x001A);
 	e1000_write_phy_reg(&adapter->hw, 30, 0x8FF0);
-
-	return;
 }
 
 static void
@@ -1257,11 +1346,19 @@
 	return *data;
 }
 
+
 static int
-e1000_ethtool_test(struct e1000_adapter *adapter,
-		   struct ethtool_test *eth_test, uint64_t *data)
+e1000_diag_test_count(struct net_device *dev)
 {
-	boolean_t if_running = netif_running(adapter->netdev);
+	return E1000_TEST_LEN;
+}
+
+static void 
+e1000_diag_test(struct net_device *netdev,
+		struct ethtool_test *eth_test, u64 *data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	boolean_t if_running = netif_running(netdev);
 
 	if(eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
@@ -1305,12 +1402,12 @@
 		data[2] = 0;
 		data[3] = 0;
 	}
-	return 0;
 }
 
 static void
-e1000_ethtool_gwol(struct e1000_adapter *adapter, struct ethtool_wolinfo *wol)
+e1000_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	switch(adapter->hw.device_id) {
@@ -1348,10 +1445,10 @@
 		return;
 	}
 }
-
 static int
-e1000_ethtool_swol(struct e1000_adapter *adapter, struct ethtool_wolinfo *wol)
+e1000_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	switch(adapter->hw.device_id) {
@@ -1408,8 +1505,13 @@
 }
 
 static int
-e1000_ethtool_led_blink(struct e1000_adapter *adapter, struct ethtool_value *id)
+e1000_phys_id(struct net_device *netdev, u32 data)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
+		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
+
 	if(!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function = e1000_led_blink_callback;
@@ -1420,11 +1522,7 @@
 	mod_timer(&adapter->blink_timer, jiffies);
 
 	set_current_state(TASK_INTERRUPTIBLE);
-	if(id->data)
-		schedule_timeout(id->data * HZ);
-	else
-		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
-
+	schedule_timeout(data * HZ);
 	del_timer_sync(&adapter->blink_timer);
 	e1000_led_off(&adapter->hw);
 	clear_bit(E1000_LED_ON, &adapter->led_status);
@@ -1433,342 +1531,96 @@
 	return 0;
 }
 
-int
-e1000_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr)
+static int
+e1000_nway_reset(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
-	void *addr = ifr->ifr_data;
-	uint32_t cmd;
-
-	if(get_user(cmd, (uint32_t *) addr))
-		return -EFAULT;
-
-	switch(cmd) {
-	case ETHTOOL_GSET: {
-		struct ethtool_cmd ecmd = {ETHTOOL_GSET};
-		e1000_ethtool_gset(adapter, &ecmd);
-		if(copy_to_user(addr, &ecmd, sizeof(ecmd)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SSET: {
-		struct ethtool_cmd ecmd;
-		if(copy_from_user(&ecmd, addr, sizeof(ecmd)))
-			return -EFAULT;
-		return e1000_ethtool_sset(adapter, &ecmd);
-	}
-	case ETHTOOL_GDRVINFO: {
-		struct ethtool_drvinfo drvinfo = {ETHTOOL_GDRVINFO};
-		e1000_ethtool_gdrvinfo(adapter, &drvinfo);
-		if(copy_to_user(addr, &drvinfo, sizeof(drvinfo)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_GSTRINGS: {
-		struct ethtool_gstrings gstrings = { ETHTOOL_GSTRINGS };
-		char *strings = NULL;
-		int err = 0;
-
-		if(copy_from_user(&gstrings, addr, sizeof(gstrings)))
-			return -EFAULT;
-		switch(gstrings.string_set) {
-		case ETH_SS_TEST:
-			gstrings.len = E1000_TEST_LEN;
-			strings = kmalloc(E1000_TEST_LEN * ETH_GSTRING_LEN,
-					  GFP_KERNEL);
-			if(!strings)
-				return -ENOMEM;
-			memcpy(strings, e1000_gstrings_test, E1000_TEST_LEN *
-			       ETH_GSTRING_LEN);
-			break;
-		case ETH_SS_STATS: {
-			int i;
-			gstrings.len = E1000_STATS_LEN;
-			strings = kmalloc(E1000_STATS_LEN * ETH_GSTRING_LEN,
-					  GFP_KERNEL);
-			if(!strings)
-				return -ENOMEM;
-			for(i=0; i < E1000_STATS_LEN; i++) {
-				memcpy(&strings[i * ETH_GSTRING_LEN],
-				       e1000_gstrings_stats[i].stat_string,
-				       ETH_GSTRING_LEN);
-			}
-			break;
-		}
-		default:
-			return -EOPNOTSUPP;
-		}
-		if(copy_to_user(addr, &gstrings, sizeof(gstrings)))
-			err = -EFAULT;
-		addr += offsetof(struct ethtool_gstrings, data);
-		if(!err && copy_to_user(addr, strings,
-		   gstrings.len * ETH_GSTRING_LEN))
-			err = -EFAULT;
-
-		kfree(strings);
-		return err;
-	}
-	case ETHTOOL_GREGS: {
-		struct ethtool_regs regs = {ETHTOOL_GREGS};
-		uint32_t regs_buff[E1000_REGS_LEN];
-
-		if(copy_from_user(&regs, addr, sizeof(regs)))
-			return -EFAULT;
-		e1000_ethtool_gregs(adapter, &regs, regs_buff);
-		if(copy_to_user(addr, &regs, sizeof(regs)))
-			return -EFAULT;
-
-		addr += offsetof(struct ethtool_regs, data);
-		if(copy_to_user(addr, regs_buff, regs.len))
-			return -EFAULT;
-
-		return 0;
-	}
-	case ETHTOOL_NWAY_RST: {
-		if(netif_running(netdev)) {
-			e1000_down(adapter);
-			e1000_up(adapter);
-		}
-		return 0;
-	}
-	case ETHTOOL_PHYS_ID: {
-		struct ethtool_value id;
-		if(copy_from_user(&id, addr, sizeof(id)))
-			return -EFAULT;
-		return e1000_ethtool_led_blink(adapter, &id);
-	}
-	case ETHTOOL_GLINK: {
-		struct ethtool_value link = {ETHTOOL_GLINK};
-		link.data = netif_carrier_ok(netdev);
-		if(copy_to_user(addr, &link, sizeof(link)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_GWOL: {
-		struct ethtool_wolinfo wol = {ETHTOOL_GWOL};
-		e1000_ethtool_gwol(adapter, &wol);
-		if(copy_to_user(addr, &wol, sizeof(wol)) != 0)
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SWOL: {
-		struct ethtool_wolinfo wol;
-		if(copy_from_user(&wol, addr, sizeof(wol)) != 0)
-			return -EFAULT;
-		return e1000_ethtool_swol(adapter, &wol);
-	}
-	case ETHTOOL_GEEPROM: {
-		struct ethtool_eeprom eeprom = {ETHTOOL_GEEPROM};
-		struct e1000_hw *hw = &adapter->hw;
-		uint16_t *eeprom_buff;
-		void *ptr;
-		int err = 0;
-
-		if(copy_from_user(&eeprom, addr, sizeof(eeprom)))
-			return -EFAULT;
-
-		eeprom_buff = kmalloc(hw->eeprom.word_size * 2, GFP_KERNEL);
-
-		if(!eeprom_buff)
-			return -ENOMEM;
-
-		if((err = e1000_ethtool_geeprom(adapter, &eeprom,
-						eeprom_buff)))
-			goto err_geeprom_ioctl;
-
-		if(copy_to_user(addr, &eeprom, sizeof(eeprom))) {
-			err = -EFAULT;
-			goto err_geeprom_ioctl;
-		}
-
-		addr += offsetof(struct ethtool_eeprom, data);
-		ptr = ((void *)eeprom_buff) + (eeprom.offset & 1);
-
-		if(copy_to_user(addr, ptr, eeprom.len))
-			err = -EFAULT;
-
-err_geeprom_ioctl:
-		kfree(eeprom_buff);
-		return err;
-	}
-	case ETHTOOL_SEEPROM: {
-		struct ethtool_eeprom eeprom;
-
-		if(copy_from_user(&eeprom, addr, sizeof(eeprom)))
-			return -EFAULT;
-
-		addr += offsetof(struct ethtool_eeprom, data);
-		return e1000_ethtool_seeprom(adapter, &eeprom, addr);
-	}
-	case ETHTOOL_GRINGPARAM: {
-		struct ethtool_ringparam ering = {ETHTOOL_GRINGPARAM};
-		e1000_ethtool_gring(adapter, &ering);
-		if(copy_to_user(addr, &ering, sizeof(ering)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SRINGPARAM: {
-		struct ethtool_ringparam ering;
-		if(copy_from_user(&ering, addr, sizeof(ering)))
-			return -EFAULT;
-		return e1000_ethtool_sring(adapter, &ering);
-	}
-	case ETHTOOL_GPAUSEPARAM: {
-		struct ethtool_pauseparam epause = {ETHTOOL_GPAUSEPARAM};
-		e1000_ethtool_gpause(adapter, &epause);
-		if(copy_to_user(addr, &epause, sizeof(epause)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SPAUSEPARAM: {
-		struct ethtool_pauseparam epause;
-		if(copy_from_user(&epause, addr, sizeof(epause)))
-			return -EFAULT;
-		return e1000_ethtool_spause(adapter, &epause);
-	}
-	case ETHTOOL_GSTATS: {
-		struct {
-			struct ethtool_stats eth_stats;
-			uint64_t data[E1000_STATS_LEN];
-		} stats = { {ETHTOOL_GSTATS, E1000_STATS_LEN} };
-		int i;
-
-		e1000_update_stats(adapter);
-		for(i = 0; i < E1000_STATS_LEN; i++)
-			stats.data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-					sizeof(uint64_t)) ?
-				*(uint64_t *)((char *)adapter +
-					e1000_gstrings_stats[i].stat_offset) :
-				*(uint32_t *)((char *)adapter +
-					e1000_gstrings_stats[i].stat_offset);
-		if(copy_to_user(addr, &stats, sizeof(stats)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_TEST: {
-		struct {
-			struct ethtool_test eth_test;
-			uint64_t data[E1000_TEST_LEN];
-		} test = { {ETHTOOL_TEST} };
-		int err;
-
-		if(copy_from_user(&test.eth_test, addr, sizeof(test.eth_test)))
-			return -EFAULT;
-
-		test.eth_test.len = E1000_TEST_LEN;
-
-		if((err = e1000_ethtool_test(adapter, &test.eth_test,
-					     test.data)))
-			return err;
-
-		if(copy_to_user(addr, &test, sizeof(test)) != 0)
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_GRXCSUM: {
-		struct ethtool_value edata = { ETHTOOL_GRXCSUM };
-
-		edata.data = adapter->rx_csum;
-		if (copy_to_user(addr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SRXCSUM: {
-		struct ethtool_value edata;
-
-		if (copy_from_user(&edata, addr, sizeof(edata)))
-			return -EFAULT;
-		adapter->rx_csum = edata.data;
-		if(netif_running(netdev)) {
-			e1000_down(adapter);
-			e1000_up(adapter);
-		} else
-			e1000_reset(adapter);
-		return 0;
-	}
-	case ETHTOOL_GTXCSUM: {
-		struct ethtool_value edata = { ETHTOOL_GTXCSUM };
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-		edata.data =
-			(netdev->features & NETIF_F_HW_CSUM) != 0;
-		if (copy_to_user(addr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
+	if(netif_running(netdev)) {
+		e1000_down(adapter);
+		e1000_up(adapter);
 	}
-	case ETHTOOL_STXCSUM: {
-		struct ethtool_value edata;
+	return 0;
+}
 
-		if (copy_from_user(&edata, addr, sizeof(edata)))
-			return -EFAULT;
+static u32
+e1000_get_link(struct net_device *netdev)
+{
+	return netif_carrier_ok(netdev);
+}
 
-		if(adapter->hw.mac_type < e1000_82543) {
-			if (edata.data != 0)
-				return -EINVAL;
-			return 0;
-		}
 
-		if (edata.data)
-			netdev->features |= NETIF_F_HW_CSUM;
-		else
-			netdev->features &= ~NETIF_F_HW_CSUM;
+static int
+e1000_get_stats_count(struct net_device *dev)
+{
+	return E1000_STATS_LEN;
+}
 
-		return 0;
-	}
-	case ETHTOOL_GSG: {
-		struct ethtool_value edata = { ETHTOOL_GSG };
+static void
+e1000_get_ethtool_stats(struct net_device *netdev,
+			struct ethtool_stats *stats, u64 *data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int i;
 
-		edata.data =
-			(netdev->features & NETIF_F_SG) != 0;
-		if (copy_to_user(addr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
+	e1000_update_stats(adapter);
+	for(i = 0; i < E1000_STATS_LEN; i++) {
+		char *p = (char *) adapter + e1000_gstrings_stats[i].stat_offset;
+		data[i] = (e1000_gstrings_stats[i].sizeof_stat == sizeof(uint64_t)) 
+			? *(uint64_t *)p : *(uint32_t *)p;
 	}
-	case ETHTOOL_SSG: {
-		struct ethtool_value edata;
-
-		if (copy_from_user(&edata, addr, sizeof(edata)))
-			return -EFAULT;
-
-		if (edata.data)
-			netdev->features |= NETIF_F_SG;
-		else
-			netdev->features &= ~NETIF_F_SG;
+}
 
-		return 0;
-	}
-#ifdef NETIF_F_TSO
-	case ETHTOOL_GTSO: {
-		struct ethtool_value edata = { ETHTOOL_GTSO };
-
-		edata.data = (netdev->features & NETIF_F_TSO) != 0;
-		if (copy_to_user(addr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_STSO: {
-		struct ethtool_value edata;
+static void
+e1000_get_strings(struct net_device *netdev, u32 string_set, u8 *data)
+{
+	int i;
 
-		if (copy_from_user(&edata, addr, sizeof(edata)))
-			return -EFAULT;
+	switch(string_set) {
+	case ETH_SS_TEST:
+		memcpy(data, e1000_gstrings_test, E1000_TEST_LEN * ETH_GSTRING_LEN);
+		break;
 
-		if ((adapter->hw.mac_type < e1000_82544) ||
-		    (adapter->hw.mac_type == e1000_82547)) {
-			if (edata.data != 0)
-				return -EINVAL;
-			return 0;
+	case ETH_SS_STATS:
+		for(i=0; i < E1000_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       e1000_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
 		}
-
-		if (edata.data)
-			netdev->features |= NETIF_F_TSO;
-		else
-			netdev->features &= ~NETIF_F_TSO;
-
-		return 0;
-	}
-#endif
-	default:
-		return -EOPNOTSUPP;
+		break;
 	}
 }
 
 
+struct ethtool_ops e1000_ethtool_ops = {
+	.get_settings		= e1000_get_settings,
+	.set_settings		= e1000_set_settings,
+	.get_drvinfo		= e1000_get_drvinfo,
+	.get_regs_len		= e1000_get_regs_len,
+	.get_regs		= e1000_get_regs,
+	.get_wol		= e1000_get_wol,
+	.set_wol		= e1000_set_wol,
+	.nway_reset		= e1000_nway_reset,
+	.get_link		= e1000_get_link,
+	.get_eeprom_len		= e1000_get_eeprom_len,
+	.get_eeprom		= e1000_get_eeprom,
+	.set_eeprom		= e1000_set_eeprom,
+	.get_ringparam		= e1000_get_ringparam,
+	.set_ringparam		= e1000_set_ringparam,
+	.get_pauseparam		= e1000_get_pauseparam,
+	.set_pauseparam		= e1000_set_pauseparam,
+	.get_rx_csum		= e1000_get_rx_csum,
+	.set_rx_csum		= e1000_set_rx_csum,
+	.get_tx_csum		= e1000_get_tx_csum,
+	.set_tx_csum		= e1000_set_tx_csum,
+	.get_sg			= e1000_get_sg,
+	.set_sg			= e1000_set_sg,
+	.get_tso		= e1000_get_tso,
+	.set_tso		= e1000_set_tso,
+	.self_test_count	= e1000_diag_test_count,
+	.self_test		= e1000_diag_test,
+	.get_strings		= e1000_get_strings,
+	.phys_id		= e1000_phys_id,
+	.get_stats_count	= e1000_get_stats_count,
+	.get_ethtool_stats	= e1000_get_ethtool_stats,
+};
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Fri Apr 16 15:50:02 2004
+++ b/drivers/net/e1000/e1000_main.c	Fri Apr 16 15:50:02 2004
@@ -167,9 +167,9 @@
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter);
 #endif
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter);
-static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
-static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
-			   int cmd);
+
+static int e1000_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
+extern struct ethtool_ops e1000_ethtool_ops;
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
 static inline void e1000_rx_checksum(struct e1000_adapter *adapter,
@@ -206,7 +206,6 @@
 /* Exported from other modules */
 
 extern void e1000_check_options(struct e1000_adapter *adapter);
-extern int e1000_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr);
 
 static struct pci_driver e1000_driver = {
 	.name     = e1000_driver_name,
@@ -445,7 +444,8 @@
 	netdev->set_multicast_list = &e1000_set_multi;
 	netdev->set_mac_address = &e1000_set_mac;
 	netdev->change_mtu = &e1000_change_mtu;
-	netdev->do_ioctl = &e1000_ioctl;
+	netdev->do_ioctl = &e1000_do_ioctl;
+	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_E1000_NAPI
@@ -2498,37 +2498,16 @@
 		adapter->smartspeed = 0;
 }
 
-/**
- * e1000_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- **/
-
-static int
-e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		return e1000_mii_ioctl(netdev, ifr, cmd);
-	case SIOCETHTOOL:
-		return e1000_ethtool_ioctl(netdev, ifr);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
 
 /**
- * e1000_mii_ioctl -
+ * e1000_do_ioctl -
  * @netdev:
  * @ifreq:
  * @cmd:
  **/
 
 static int
-e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+e1000_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&ifr->ifr_data;
