From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 13/16 2.5] ixgb: ethtool_ops support
Date: Fri, 15 Oct 2004 06:56:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150639340.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2004-10-05 16:02:20.000000000 -0700
@@ -37,12 +37,13 @@ extern char ixgb_driver_version[];
 
 extern int ixgb_up(struct ixgb_adapter *adapter);
 extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+extern void ixgb_reset(struct ixgb_adapter *adapter);
+extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_update_stats(struct ixgb_adapter *adapter);
 
-static inline int ixgb_eeprom_size(struct ixgb_hw *hw)
-{
-	/* return size in bytes */
-	return (IXGB_EEPROM_SIZE << 1);
-}
 
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -94,9 +55,11 @@ struct ixgb_stats {
 #define IXGB_STATS_LEN	\
 	sizeof(ixgb_gstrings_stats) / sizeof(struct ixgb_stats)
 
-static void
-ixgb_ethtool_gset(struct ixgb_adapter *adapter, struct ethtool_cmd *ecmd)
+static int
+ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
+
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->port = PORT_FIBRE;
@@ -111,98 +114,151 @@ ixgb_ethtool_gset(struct ixgb_adapter *a
 	}
 
 	ecmd->autoneg = AUTONEG_DISABLE;
+	return 0;
 }
 
 static int
-ixgb_ethtool_sset(struct ixgb_adapter *adapter, struct ethtool_cmd *ecmd)
+ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
+	struct ixgb_adapter *adapter = netdev->priv;
+	if (ecmd->autoneg == AUTONEG_ENABLE ||
+	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
-	else {
+	
+	if(netif_running(adapter->netdev)) {
 		ixgb_down(adapter, TRUE);
+		ixgb_reset(adapter);
 		ixgb_up(adapter);
-	}
+	} else
+		ixgb_reset(adapter);
 
 	return 0;
 }
 
-static int
-ixgb_ethtool_gpause(struct ixgb_adapter *adapter,
-		    struct ethtool_pauseparam *epause)
+static void
+ixgb_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-
-	epause->autoneg = AUTONEG_DISABLE;
-
-	if (hw->fc.type == ixgb_fc_rx_pause)
-		epause->rx_pause = 1;
-	else if (hw->fc.type == ixgb_fc_tx_pause)
-		epause->tx_pause = 1;
-	else if (hw->fc.type == ixgb_fc_full) {
-		epause->rx_pause = 1;
-		epause->tx_pause = 1;
+	
+	pause->autoneg = AUTONEG_DISABLE;
+		
+	
+	if (hw->fc.type == ixgb_fc_rx_pause)
+		pause->rx_pause = 1;
+	else if (hw->fc.type == ixgb_fc_tx_pause)
+		pause->tx_pause = 1;
+	else if (hw->fc.type == ixgb_fc_full) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
 	}
-
-	return 0;
 }
 
 static int
-ixgb_ethtool_spause(struct ixgb_adapter *adapter,
-		    struct ethtool_pauseparam *epause)
+ixgb_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-
-	if (epause->autoneg == AUTONEG_ENABLE)
+	
+	if (pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
-	if (epause->rx_pause && epause->tx_pause)
+	if (pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_full;
-	else if (epause->rx_pause && !epause->tx_pause)
+	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_rx_pause;
-	else if (!epause->rx_pause && epause->tx_pause)
+	else if (!pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_tx_pause;
-	else if (!epause->rx_pause && !epause->tx_pause)
+	else if (!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_none;
 
-	ixgb_down(adapter, TRUE);
-	ixgb_up(adapter);
+	if (netif_running(adapter->netdev)) {
+		ixgb_down(adapter, TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
+		
+	return 0;
+}
+
+static uint32_t
+ixgb_get_rx_csum(struct net_device *netdev)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	return adapter->rx_csum;
+}
+
+static int
+ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	adapter->rx_csum = data;
 
+	if (netif_running(netdev)) {
+		ixgb_down(adapter,TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
 	return 0;
 }
+	
+static uint32_t
+ixgb_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
 
-static void
-ixgb_ethtool_gdrvinfo(struct ixgb_adapter *adapter,
-		      struct ethtool_drvinfo *drvinfo)
+static int
+ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
 {
-	strncpy(drvinfo->driver, ixgb_driver_name, 32);
-	strncpy(drvinfo->version, ixgb_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->n_stats = IXGB_STATS_LEN;
-#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
-	drvinfo->regdump_len = IXGB_REG_DUMP_LEN;
-	drvinfo->eedump_len = ixgb_eeprom_size(&adapter->hw);
+
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
 }
 
+#ifdef NETIF_F_TSO
+static int
+ixgb_set_tso(struct net_device *netdev, uint32_t data)
+{
+
+	if (data)
+		netdev->features |= NETIF_F_TSO;
+	else
+		netdev->features &= ~NETIF_F_TSO;
+	return 0;
+} 
+#endif /* NETIF_F_TSO */
+
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
+
+static int 
+ixgb_get_regs_len(struct net_device *netdev)
+{
+#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
+	return IXGB_REG_DUMP_LEN;
+}
+
 static void
-ixgb_ethtool_gregs(struct ixgb_adapter *adapter,
-		   struct ethtool_regs *regs, uint32_t * regs_buff)
+ixgb_get_regs(struct net_device *netdev,
+		   struct ethtool_regs *regs, void *p)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t *reg = regs_buff;
+	uint32_t *reg = p;
 	uint32_t *reg_start = reg;
 	uint8_t i;
 
-	regs->version =
-	    (adapter->hw.device_id << 16) | adapter->hw.subsystem_id;
+	regs->version = (adapter->hw.device_id << 16) | adapter->hw.subsystem_id;
 
 	/* General Registers */
-	*reg++ = IXGB_READ_REG(hw, CTRL0);	/*   0 */
-	*reg++ = IXGB_READ_REG(hw, CTRL1);	/*   1 */
-	*reg++ = IXGB_READ_REG(hw, STATUS);	/*   2 */
-	*reg++ = IXGB_READ_REG(hw, EECD);	/*   3 */
+	*reg++ = IXGB_READ_REG(hw, CTRL0);  /*   0 */
+	*reg++ = IXGB_READ_REG(hw, CTRL1);  /*   1 */
+	*reg++ = IXGB_READ_REG(hw, STATUS); /*   2 */
+	*reg++ = IXGB_READ_REG(hw, EECD);   /*   3 */
 	*reg++ = IXGB_READ_REG(hw, MFS);	/*   4 */
 
 	/* Interrupt */
@@ -323,10 +304,19 @@ ixgb_ethtool_gregs(struct ixgb_adapter *
 }
 
 static int
-ixgb_ethtool_geeprom(struct ixgb_adapter *adapter,
-		     struct ethtool_eeprom *eeprom, uint16_t * eeprom_buff)
+ixgb_get_eeprom_len(struct net_device *netdev)
 {
+	/* return size in bytes */
+	return (IXGB_EEPROM_SIZE << 1);
+}
+
+static int
+ixgb_get_eeprom(struct net_device *netdev,
+		struct ethtool_eeprom *eeprom, uint8_t *bytes)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
+	uint16_t *eeprom_buff;
 	int i, max_len, first_word, last_word;
 	int ret_val = 0;
 
@@ -337,10 +304,7 @@ 
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
 
-	max_len = ixgb_eeprom_size(hw);
-
-	/* use our function to read the eeprom and update our cache */
-	ixgb_get_eeprom_data(hw);
+	max_len = ixgb_get_eeprom_len(netdev);
 
 	if (eeprom->offset > eeprom->offset + eeprom->len) {
 		ret_val = -EINVAL;
@@ -353,31 +304,44 @@ 
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	for (i = 0; i <= (last_word - first_word); i++) {
-		eeprom_buff[i] = hw->eeprom[first_word + i];
+	eeprom_buff = kmalloc(sizeof(uint16_t) *
+			(last_word - first_word + 1), GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
+	/* note the eeprom was good because the driver loaded */
+	for(i = 0; i <= (last_word - first_word); i++) {
+		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
 	}
-      geeprom_error:
+
+	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+			eeprom->len);
+	kfree(eeprom_buff);
+
+geeprom_error:
 	return ret_val;
 }
 
 static int
-ixgb_ethtool_seeprom(struct ixgb_adapter *adapter,
-		     struct ethtool_eeprom *eeprom, void __user *user_data)
+ixgb_set_eeprom(struct net_device *netdev,
+		struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint16_t eeprom_buff[256];
-	int i, max_len, first_word, last_word;
+	uint16_t *eeprom_buff;
 	void *ptr;
+	int max_len, first_word, last_word;
+	uint16_t i;
 
-	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
-		return -EFAULT;
-
-	if (eeprom->len == 0)
+	if (eeprom->len == 0)
 		return -EINVAL;
 
-	max_len = ixgb_eeprom_size(hw);
+	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+		return -EFAULT;
 
-	if (eeprom->offset > eeprom->offset + eeprom->len)
+	max_len = ixgb_get_eeprom_len(netdev);
+
+	if (eeprom->offset > eeprom->offset + eeprom->len)
 		return -EINVAL;
 
 	if ((eeprom->offset + eeprom->len) > max_len)
@@ -385,6 +304,10 @@ 
 
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+	if(!eeprom_buff)
+		return -ENOMEM;
+
 	ptr = (void *)eeprom_buff;
 
 	if (eeprom->offset & 1) {
@@ -396,13 +304,14 @@ 
 	if ((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word]
-		    = ixgb_read_eeprom(hw, last_word);
+		eeprom_buff[last_word - first_word] 
+			= ixgb_read_eeprom(hw, last_word);
 	}
-	if (copy_from_user(ptr, user_data, eeprom->len))
-		return -EFAULT;
 
-	for (i = 0; i <= (last_word - first_word); i++)
+
+	memcpy(ptr, bytes, eeprom->len);
+
+	for(i = 0; i <= (last_word - first_word); i++)
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
 
 	/* Update the checksum over the first part of the EEPROM if needed */
@@ -409,7 +304,100 @@ 
 	if (first_word <= EEPROM_CHECKSUM_REG)
 		ixgb_update_eeprom_checksum(hw);
 
+	kfree(eeprom_buff);
+	return 0;
+}
+
+static void
+ixgb_get_drvinfo(struct net_device *netdev,
+		 struct ethtool_drvinfo *drvinfo)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	strncpy(drvinfo->driver,  ixgb_driver_name, 32);
+	strncpy(drvinfo->version, ixgb_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	drvinfo->n_stats = IXGB_STATS_LEN;
+	drvinfo->regdump_len = ixgb_get_regs_len(netdev);
+	drvinfo->eedump_len = ixgb_get_eeprom_len(netdev);
+}
+
+static void
+ixgb_get_ringparam(struct net_device *netdev,
+		   struct ethtool_ringparam *ring)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
+	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
+
+	ring->rx_max_pending = MAX_RXD; 
+	ring->tx_max_pending = MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rxdr->count;
+	ring->tx_pending = txdr->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int 
+ixgb_set_ringparam(struct net_device *netdev,
+		   struct ethtool_ringparam *ring)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
+	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
+	struct ixgb_desc_ring tx_old, tx_new, rx_old, rx_new;
+	int err;
+
+	tx_old = adapter->tx_ring;
+	rx_old = adapter->rx_ring;
+
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+		return -EINVAL;
+
+	if(netif_running(adapter->netdev))
+		ixgb_down(adapter,TRUE);
+
+	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
+	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
+	IXGB_ROUNDUP(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE); 
+
+	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
+	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
+	IXGB_ROUNDUP(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE); 
+
+	if(netif_running(adapter->netdev)) {
+		/* Try to get new resources before deleting old */
+		if((err = ixgb_setup_rx_resources(adapter)))
+			goto err_setup_rx;
+		if((err = ixgb_setup_tx_resources(adapter)))
+			goto err_setup_tx;
+
+		/* save the new, restore the old in order to free it,
+		 * then restore the new back again */
+
+		rx_new = adapter->rx_ring;
+		tx_new = adapter->tx_ring;
+		adapter->rx_ring = rx_old;
+		adapter->tx_ring = tx_old;
+		ixgb_free_rx_resources(adapter);
+		ixgb_free_tx_resources(adapter);
+		adapter->rx_ring = rx_new;
+		adapter->tx_ring = tx_new;
+		if((err = ixgb_up(adapter)))
+			return err;
+	}
+
 	return 0;
+err_setup_tx:
+	ixgb_free_rx_resources(adapter);
+err_setup_rx:
+	adapter->rx_ring = rx_old;
+	adapter->tx_ring = tx_old;
+	ixgb_up(adapter);
+	return err;
 }
 
 /* toggle LED 4 times per second = 2 "blinks" per second */
@@ -420,7 +304,7 @@ 
 
 static void ixgb_led_blink_callback(unsigned long data)
 {
-	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
+	struct ixgb_adapter *adapter = (struct ixgb_adapter *) data;
 
 	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
 		ixgb_led_off(&adapter->hw);
@@ -431,19 +441,24 @@ static void ixgb_led_blink_callback(unsi
 }
 
 static int
-ixgb_ethtool_led_blink(struct ixgb_adapter *adapter, struct ethtool_value *id)
+ixgb_phys_id(struct net_device *netdev, uint32_t data)
 {
-	if (!adapter->blink_timer.function) {
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	if (!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
+		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+
+	if (!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function = ixgb_led_blink_callback;
-		adapter->blink_timer.data = (unsigned long)adapter;
+		adapter->blink_timer.data = (unsigned long) adapter;
 	}
 
 	mod_timer(&adapter->blink_timer, jiffies);
 
 	set_current_state(TASK_INTERRUPTIBLE);
-	if (id->data)
-		schedule_timeout(id->data * HZ);
+	if (data)
+		schedule_timeout(data * HZ);
 	else
 		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
 
@@ -454,268 +464,74 @@ ixgb_ethtool_led_blink(struct ixgb_adapt
 	return 0;
 }
 
-int ixgb_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr)
+static int 
+ixgb_get_stats_count(struct net_device *netdev)
 {
-	struct ixgb_adapter *adapter = netdev->priv;
-	void __user *addr = ifr->ifr_data;
-	uint32_t cmd;
-
-	if (get_user(cmd, (uint32_t __user *) addr))
-		return -EFAULT;
-
-	switch (cmd) {
-	case ETHTOOL_GSET:{
-			struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-			ixgb_ethtool_gset(adapter, &ecmd);
-			if (copy_to_user(addr, &ecmd, sizeof(ecmd)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SSET:{
-			struct ethtool_cmd ecmd;
-			if (copy_from_user(&ecmd, addr, sizeof(ecmd)))
-				return -EFAULT;
-			return ixgb_ethtool_sset(adapter, &ecmd);
-		}
-	case ETHTOOL_GDRVINFO:{
-			struct ethtool_drvinfo drvinfo = { ETHTOOL_GDRVINFO };
-			ixgb_ethtool_gdrvinfo(adapter, &drvinfo);
-			if (copy_to_user(addr, &drvinfo, sizeof(drvinfo)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_GSTRINGS:{
-			struct ethtool_gstrings gstrings = { ETHTOOL_GSTRINGS };
-			char *strings = NULL;
-			int err = 0;
-
-			if (copy_from_user(&gstrings, addr, sizeof(gstrings)))
-				return -EFAULT;
-			switch (gstrings.string_set) {
-			case ETH_SS_STATS:{
-					int i;
-					gstrings.len = IXGB_STATS_LEN;
-					strings =
-					    kmalloc(IXGB_STATS_LEN *
-						    ETH_GSTRING_LEN,
-						    GFP_KERNEL);
-					if (!strings)
-						return -ENOMEM;
-					for (i = 0; i < IXGB_STATS_LEN; i++) {
-						memcpy(&strings
-						       [i * ETH_GSTRING_LEN],
-						       ixgb_gstrings_stats[i].
-						       stat_string,
-						       ETH_GSTRING_LEN);
-					}
-					break;
-				}
-			default:
-				return -EOPNOTSUPP;
-			}
-			if (copy_to_user(addr, &gstrings, sizeof(gstrings)))
-				err = -EFAULT;
-			addr += offsetof(struct ethtool_gstrings, data);
-			if (!err && copy_to_user(addr, strings,
-						 gstrings.len *
-						 ETH_GSTRING_LEN))
-				err = -EFAULT;
-
-			kfree(strings);
-			return err;
-		}
-	case ETHTOOL_GREGS:{
-			struct ethtool_regs regs = { ETHTOOL_GREGS };
-			uint32_t regs_buff[IXGB_REG_DUMP_LEN];
-
-			if (copy_from_user(&regs, addr, sizeof(regs)))
-				return -EFAULT;
-			ixgb_ethtool_gregs(adapter, &regs, regs_buff);
-			if (copy_to_user(addr, &regs, sizeof(regs)))
-				return -EFAULT;
-
-			addr += offsetof(struct ethtool_regs, data);
-			if (copy_to_user(addr, regs_buff, regs.len))
-				return -EFAULT;
-
-			return 0;
-		}
-	case ETHTOOL_NWAY_RST:{
-			if (netif_running(netdev)) {
-				ixgb_down(adapter, TRUE);
-				ixgb_up(adapter);
-			}
-			return 0;
-		}
-	case ETHTOOL_PHYS_ID:{
-			struct ethtool_value id;
-			if (copy_from_user(&id, addr, sizeof(id)))
-				return -EFAULT;
-			return ixgb_ethtool_led_blink(adapter, &id);
-		}
-	case ETHTOOL_GLINK:{
-			struct ethtool_value link = { ETHTOOL_GLINK };
-			link.data = netif_carrier_ok(netdev);
-			if (copy_to_user(addr, &link, sizeof(link)))
-				return -EFAULT;
-			return 0;
-		}
-
-	case ETHTOOL_GEEPROM:{
-			struct ethtool_eeprom eeprom = { ETHTOOL_GEEPROM };
-			uint16_t eeprom_buff[IXGB_EEPROM_SIZE];
-			void *ptr;
-			int err = 0;
-
-			if (copy_from_user(&eeprom, addr, sizeof(eeprom)))
-				return -EFAULT;
-
-			if ((err =
-			     ixgb_ethtool_geeprom(adapter, &eeprom,
-						  eeprom_buff)) < 0)
-				return err;
-
-			if (copy_to_user(addr, &eeprom, sizeof(eeprom)))
-				return -EFAULT;
-
-			addr += offsetof(struct ethtool_eeprom, data);
-			ptr = ((void *)eeprom_buff) + (eeprom.offset & 1);
-
-			if (copy_to_user(addr, ptr, eeprom.len))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SEEPROM:{
-			struct ethtool_eeprom eeprom;
-
-			if (copy_from_user(&eeprom, addr, sizeof(eeprom)))
-				return -EFAULT;
-
-			addr += offsetof(struct ethtool_eeprom, data);
-			return ixgb_ethtool_seeprom(adapter, &eeprom, addr);
-		}
-	case ETHTOOL_GPAUSEPARAM:{
-			struct ethtool_pauseparam epause =
-			    { ETHTOOL_GPAUSEPARAM };
-			ixgb_ethtool_gpause(adapter, &epause);
-			if (copy_to_user(addr, &epause, sizeof(epause)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SPAUSEPARAM:{
-			struct ethtool_pauseparam epause;
-			if (copy_from_user(&epause, addr, sizeof(epause)))
-				return -EFAULT;
-			return ixgb_ethtool_spause(adapter, &epause);
-		}
-	case ETHTOOL_GSTATS:{
-			struct {
-				struct ethtool_stats eth_stats;
-				uint64_t data[IXGB_STATS_LEN];
-			} stats = { {
-			ETHTOOL_GSTATS, IXGB_STATS_LEN}};
-			int i;
-
-			for (i = 0; i < IXGB_STATS_LEN; i++)
-				stats.data[i] =
-				    (ixgb_gstrings_stats[i].sizeof_stat ==
-				     sizeof(uint64_t)) ? *(uint64_t *) ((char *)
-									adapter
-									+
-									ixgb_gstrings_stats
-									[i].
-									stat_offset)
-				    : *(uint32_t *) ((char *)adapter +
-						     ixgb_gstrings_stats[i].
-						     stat_offset);
-			if (copy_to_user(addr, &stats, sizeof(stats)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_GRXCSUM:{
-			struct ethtool_value edata = { ETHTOOL_GRXCSUM };
-
-			edata.data = adapter->rx_csum;
-			if (copy_to_user(addr, &edata, sizeof(edata)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SRXCSUM:{
-			struct ethtool_value edata;
-
-			if (copy_from_user(&edata, addr, sizeof(edata)))
-				return -EFAULT;
-			adapter->rx_csum = edata.data;
-			ixgb_down(adapter, TRUE);
-			ixgb_up(adapter);
-			return 0;
-		}
-	case ETHTOOL_GTXCSUM:{
-			struct ethtool_value edata = { ETHTOOL_GTXCSUM };
-
-			edata.data = (netdev->features & NETIF_F_HW_CSUM) != 0;
-			if (copy_to_user(addr, &edata, sizeof(edata)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_STXCSUM:{
-			struct ethtool_value edata;
-
-			if (copy_from_user(&edata, addr, sizeof(edata)))
-				return -EFAULT;
-
-			if (edata.data)
-				netdev->features |= NETIF_F_HW_CSUM;
-			else
-				netdev->features &= ~NETIF_F_HW_CSUM;
-
-			return 0;
-		}
-	case ETHTOOL_GSG:{
-			struct ethtool_value edata = { ETHTOOL_GSG };
+	return IXGB_STATS_LEN;
+}
 
-			edata.data = (netdev->features & NETIF_F_SG) != 0;
-			if (copy_to_user(addr, &edata, sizeof(edata)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SSG:{
-			struct ethtool_value edata;
+static void 
+ixgb_get_ethtool_stats(struct net_device *netdev, 
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	int i;
 
-			if (copy_from_user(&edata, addr, sizeof(edata)))
-				return -EFAULT;
+	ixgb_update_stats(adapter);
+	for(i = 0; i < IXGB_STATS_LEN; i++) {
+		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
+		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
+}
 
-			if (edata.data)
-				netdev->features |= NETIF_F_SG;
-			else
-				netdev->features &= ~NETIF_F_SG;
+static void 
+ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+{
+	int i;
+
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for (i=0; i < IXGB_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN, 
+			ixgb_gstrings_stats[i].stat_string,
+			ETH_GSTRING_LEN);
+		}
+		break;
+	}
+}
 
-			return 0;
-		}
+struct ethtool_ops ixgb_ethtool_ops = {
+	.get_settings		   = ixgb_get_settings,
+	.set_settings		   = ixgb_set_settings,
+	.get_drvinfo			= ixgb_get_drvinfo,
+	.get_regs_len		   = ixgb_get_regs_len,
+	.get_regs			   = ixgb_get_regs,
+	.get_link			   = ethtool_op_get_link,
+	.get_eeprom_len		 = ixgb_get_eeprom_len,
+	.get_eeprom			 = ixgb_get_eeprom,
+	.set_eeprom			 = ixgb_set_eeprom,
+	.get_ringparam		  = ixgb_get_ringparam,
+	.set_ringparam		  = ixgb_set_ringparam,
+	.get_pauseparam		= ixgb_get_pauseparam,
+	.set_pauseparam		= ixgb_set_pauseparam,
+	.get_rx_csum		= ixgb_get_rx_csum,
+	.set_rx_csum		= ixgb_set_rx_csum,
+	.get_tx_csum		= ixgb_get_tx_csum,
+	.set_tx_csum		= ixgb_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
-	case ETHTOOL_GTSO:{
-			struct ethtool_value edata = { ETHTOOL_GTSO };
-
-			edata.data = (netdev->features & NETIF_F_TSO) != 0;
-			if (copy_to_user(addr, &edata, sizeof(edata)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_STSO:{
-			struct ethtool_value edata;
-
-			if (copy_from_user(&edata, addr, sizeof(edata)))
-				return -EFAULT;
-
-			if (edata.data)
-				netdev->features |= NETIF_F_TSO;
-			else
-				netdev->features &= ~NETIF_F_TSO;
-
-			return 0;
-		}
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= ixgb_set_tso,
 #endif
-	default:
-		return -EOPNOTSUPP;
-	}
+	.get_strings			= ixgb_get_strings,
+	.phys_id				= ixgb_phys_id,
+	.get_stats_count		= ixgb_get_stats_count,
+	.get_ethtool_stats	  = ixgb_get_ethtool_stats,
+};
+
+void set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 }
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-05 16:03:24.000000000 -0700
@@ -86,6 +86,15 @@ struct ixgb_adapter;
 
 #define IXGB_ERR(args...) printk(KERN_ERR "ixgb: " args)
 
+/* TX/RX descriptor defines */
+#define DEFAULT_TXD	256
+#define MAX_TXD	4096
+#define MIN_TXD	64
+
+#define DEFAULT_RXD	1024
+#define MAX_RXD	4096
+#define MIN_RXD	64
+
 /* Supported Rx Buffer Sizes */
 #define IXGB_RXBUFFER_2048  2048
 #define IXGB_RXBUFFER_4096  4096
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -60,6 +60,11 @@ MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 int ixgb_up(struct ixgb_adapter *adapter);
 void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
 void ixgb_reset(struct ixgb_adapter *adapter);
+int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+void ixgb_update_stats(struct ixgb_adapter *adapter);
 
 static int ixgb_init_module(void);
 static void ixgb_exit_module(void);
@@ -68,15 +71,11 @@ static void __devexit ixgb_remove(struct
 static int ixgb_sw_init(struct ixgb_adapter *adapter);
 static int ixgb_open(struct net_device *netdev);
 static int ixgb_close(struct net_device *netdev);
-static int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-static int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
 static void ixgb_configure_tx(struct ixgb_adapter *adapter);
 static void ixgb_configure_rx(struct ixgb_adapter *adapter);
 static void ixgb_setup_rctl(struct ixgb_adapter *adapter);
 static void ixgb_clean_tx_ring(struct ixgb_adapter *adapter);
 static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter);
-static void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-static void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
 static void ixgb_set_multi(struct net_device *netdev);
 static void ixgb_watchdog(unsigned long data);
 static int ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
@@ -83,7 +71,6 @@ 
 static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
-static void ixgb_update_stats(struct ixgb_adapter *adapter);
 static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 static inline void ixgb_rx_checksum(struct ixgb_adapter *adapter,
@@ -98,6 +71,9 @@ 
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
 static int ixgb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
+
+void set_ethtool_ops(struct net_device *netdev);
+
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct net_device *dev);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
@@ -124,7 +71,6 @@ 
 /* Exported from other modules */
 
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
-extern int ixgb_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr);
 
 static struct pci_driver ixgb_driver = {
 	.name = ixgb_driver_name,
@@ -373,6 +356,7 @@ ixgb_probe(struct pci_dev *pdev, const s
 	netdev->set_mac_address = &ixgb_set_mac;
 	netdev->change_mtu = &ixgb_change_mtu;
 	netdev->do_ioctl = &ixgb_ioctl;
+	set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = HZ;
 #ifdef CONFIG_IXGB_NAPI
@@ -602,7 +597,8 @@ static int ixgb_close(struct net_device 
  * Return 0 on success, negative on failure
  **/
 
-static int ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -691,7 +688,8 @@ static void ixgb_configure_tx(struct ixg
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -860,7 +862,8 @@ static void ixgb_configure_rx(struct ixg
  * Free all transmit software resources
  **/
 
-static void ixgb_free_tx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -925,7 +929,8 @@ static void ixgb_clean_tx_ring(struct ix
  * Free all receive software resources
  **/
 
-static void ixgb_free_rx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1475,7 +1475,8 @@ static int ixgb_change_mtu(struct net_de
  * @adapter: board private structure
  **/
 
-static void ixgb_update_stats(struct ixgb_adapter *adapter)
+void
+ixgb_update_stats(struct ixgb_adapter *adapter)
 {
 	adapter->stats.tprl += IXGB_READ_REG(&adapter->hw, TPRL);
 	adapter->stats.tprh += IXGB_READ_REG(&adapter->hw, TPRH);
@@ -1980,7 +1984,6 @@ static void ixgb_alloc_rx_buffers(struct
 {
 	switch (cmd) {
 	case SIOCETHTOOL:
-		return ixgb_ethtool_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_param.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_param.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c	2004-10-05 17:55:52.000000000 -0700
@@ -173,13 +173,6 @@ IXGB_PARAM(FCReqTimeout, "Flow Control R
 
 IXGB_PARAM(IntDelayEnable, "Transmit Interrupt Delay Enable");
 
-#define DEFAULT_TXD			    256
-#define MAX_TXD				   4096
-#define MIN_TXD				     64
-
-#define DEFAULT_RXD			   1024
-#define MAX_RXD				   4096
-#define MIN_RXD				     64
 
 #define DEFAULT_TIDV	   		     32
 #define MAX_TIDV			 0xFFFF
