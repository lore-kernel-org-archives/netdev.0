From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 8/10] ixgb: Ethtool_ops support
Date: Fri, 29 Oct 2004 05:12:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290500450.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2004-10-15 13:15:50.000000000 -0700
@@ -37,6 +37,12 @@ extern char ixgb_driver_version[];
 
 extern int ixgb_up(struct ixgb_adapter *adapter);
 extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+extern void ixgb_reset(struct ixgb_adapter *adapter);
+extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_update_stats(struct ixgb_adapter *adapter);
 
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -89,7 +50,7 @@ struct ixgb_stats {
 	sizeof(ixgb_gstrings_stats) / sizeof(struct ixgb_stats)
 
 static int
-ixgb_ethtool_gset(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
@@ -110,92 +115,149 @@ ixgb_ethtool_gset(struct net_device *net
 }
 
 static int
-ixgb_ethtool_sset(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	if (ecmd->autoneg == AUTONEG_ENABLE ||
 	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
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
+
 	return 0;
 }
 
 static void
-ixgb_ethtool_gpause(struct net_device *dev,
-		    struct ethtool_pauseparam *epause)
+ixgb_get_pauseparam(struct net_device *netdev,
+			 struct ethtool_pauseparam *pause)
 {
-	struct ixgb_adapter *adapter = dev->priv;
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
+	if(hw->fc.type == ixgb_fc_rx_pause)
+		pause->rx_pause = 1;
+	else if(hw->fc.type == ixgb_fc_tx_pause)
+		pause->tx_pause = 1;
+	else if(hw->fc.type == ixgb_fc_full) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
 	}
 }
 
 static int
-ixgb_ethtool_spause(struct net_device *dev,
-		    struct ethtool_pauseparam *epause)
+ixgb_set_pauseparam(struct net_device *netdev,
+			 struct ethtool_pauseparam *pause)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-
-	if (epause->autoneg == AUTONEG_ENABLE)
+	
+	if(pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
-	if (epause->rx_pause && epause->tx_pause)
+	if(pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_full;
-	else if (epause->rx_pause && !epause->tx_pause)
+	else if(pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_rx_pause;
-	else if (!epause->rx_pause && epause->tx_pause)
+	else if(!pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_tx_pause;
-	else if (!epause->rx_pause && !epause->tx_pause)
+	else if(!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_none;
 
-	ixgb_down(adapter, TRUE);
-	ixgb_up(adapter);
-
+	if(netif_running(adapter->netdev)) {
+		ixgb_down(adapter, TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
+		
 	return 0;
 }
 
-static void
-ixgb_ethtool_gdrvinfo(struct net_device *netdev,
-		      struct ethtool_drvinfo *drvinfo)
+static uint32_t
+ixgb_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	strncpy(drvinfo->driver, ixgb_driver_name, 32);
-	strncpy(drvinfo->version, ixgb_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	return adapter->rx_csum;
+}
+
+static int
+ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	adapter->rx_csum = data;
+
+	if(netif_running(netdev)) {
+		ixgb_down(adapter,TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
+	return 0;
+}
+	
+static uint32_t
+ixgb_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static int
+ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
+{
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
-ixgb_ethtool_gregs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
+ixgb_get_regs(struct net_device *netdev,
+		   struct ethtool_regs *regs, void *p)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t *reg = buf;
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
@@ -205,54 +205,55 @@ ixgb_ethtool_gregs(struct net_device *de
 	*reg++ = IXGB_READ_REG(hw, IMC);	/*   8 */
 
 	/* Receive */
-	*reg++ = IXGB_READ_REG(hw, RCTL);	/*   9 */
-	*reg++ = IXGB_READ_REG(hw, FCRTL);	/*  10 */
-	*reg++ = IXGB_READ_REG(hw, FCRTH);	/*  11 */
-	*reg++ = IXGB_READ_REG(hw, RDBAL);	/*  12 */
-	*reg++ = IXGB_READ_REG(hw, RDBAH);	/*  13 */
-	*reg++ = IXGB_READ_REG(hw, RDLEN);	/*  14 */
+	*reg++ = IXGB_READ_REG(hw, RCTL);   /*   9 */
+	*reg++ = IXGB_READ_REG(hw, FCRTL);  /*  10 */
+	*reg++ = IXGB_READ_REG(hw, FCRTH);  /*  11 */
+	*reg++ = IXGB_READ_REG(hw, RDBAL);  /*  12 */
+	*reg++ = IXGB_READ_REG(hw, RDBAH);  /*  13 */
+	*reg++ = IXGB_READ_REG(hw, RDLEN);  /*  14 */
 	*reg++ = IXGB_READ_REG(hw, RDH);	/*  15 */
 	*reg++ = IXGB_READ_REG(hw, RDT);	/*  16 */
-	*reg++ = IXGB_READ_REG(hw, RDTR);	/*  17 */
-	*reg++ = IXGB_READ_REG(hw, RXDCTL);	/*  18 */
-	*reg++ = IXGB_READ_REG(hw, RAIDC);	/*  19 */
-	*reg++ = IXGB_READ_REG(hw, RXCSUM);	/*  20 */
-
-	for (i = 0; i < IXGB_RAR_ENTRIES; i++) {
-		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1));	/*21,...,51 */
-		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1));	/*22,...,52 */
+	*reg++ = IXGB_READ_REG(hw, RDTR);   /*  17 */
+	*reg++ = IXGB_READ_REG(hw, RXDCTL); /*  18 */
+	*reg++ = IXGB_READ_REG(hw, RAIDC);  /*  19 */
+	*reg++ = IXGB_READ_REG(hw, RXCSUM); /*  20 */
+
+	for(i = 0; i < IXGB_RAR_ENTRIES; i++) {
+		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
+		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}
 
 	/* Transmit */
-	*reg++ = IXGB_READ_REG(hw, TCTL);	/*  53 */
-	*reg++ = IXGB_READ_REG(hw, TDBAL);	/*  54 */
-	*reg++ = IXGB_READ_REG(hw, TDBAH);	/*  55 */
-	*reg++ = IXGB_READ_REG(hw, TDLEN);	/*  56 */
+	*reg++ = IXGB_READ_REG(hw, TCTL);   /*  53 */
+	*reg++ = IXGB_READ_REG(hw, TDBAL);  /*  54 */
+	*reg++ = IXGB_READ_REG(hw, TDBAH);  /*  55 */
+	*reg++ = IXGB_READ_REG(hw, TDLEN);  /*  56 */
 	*reg++ = IXGB_READ_REG(hw, TDH);	/*  57 */
 	*reg++ = IXGB_READ_REG(hw, TDT);	/*  58 */
-	*reg++ = IXGB_READ_REG(hw, TIDV);	/*  59 */
-	*reg++ = IXGB_READ_REG(hw, TXDCTL);	/*  60 */
-	*reg++ = IXGB_READ_REG(hw, TSPMT);	/*  61 */
+	*reg++ = IXGB_READ_REG(hw, TIDV);   /*  59 */
+	*reg++ = IXGB_READ_REG(hw, TXDCTL); /*  60 */
+	*reg++ = IXGB_READ_REG(hw, TSPMT);  /*  61 */
 	*reg++ = IXGB_READ_REG(hw, PAP);	/*  62 */
 
 	/* Physical */
-	*reg++ = IXGB_READ_REG(hw, PCSC1);	/*  63 */
-	*reg++ = IXGB_READ_REG(hw, PCSC2);	/*  64 */
-	*reg++ = IXGB_READ_REG(hw, PCSS1);	/*  65 */
-	*reg++ = IXGB_READ_REG(hw, PCSS2);	/*  66 */
-	*reg++ = IXGB_READ_REG(hw, XPCSS);	/*  67 */
-	*reg++ = IXGB_READ_REG(hw, UCCR);	/*  68 */
-	*reg++ = IXGB_READ_REG(hw, XPCSTC);	/*  69 */
-	*reg++ = IXGB_READ_REG(hw, MACA);	/*  70 */
-	*reg++ = IXGB_READ_REG(hw, APAE);	/*  71 */
+	*reg++ = IXGB_READ_REG(hw, PCSC1);  /*  63 */
+	*reg++ = IXGB_READ_REG(hw, PCSC2);  /*  64 */
+	*reg++ = IXGB_READ_REG(hw, PCSS1);  /*  65 */
+	*reg++ = IXGB_READ_REG(hw, PCSS2);  /*  66 */
+	*reg++ = IXGB_READ_REG(hw, XPCSS);  /*  67 */
+	*reg++ = IXGB_READ_REG(hw, UCCR);   /*  68 */
+	*reg++ = IXGB_READ_REG(hw, XPCSTC); /*  69 */
+	*reg++ = IXGB_READ_REG(hw, MACA);   /*  70 */
+	*reg++ = IXGB_READ_REG(hw, APAE);   /*  71 */
 	*reg++ = IXGB_READ_REG(hw, ARD);	/*  72 */
 	*reg++ = IXGB_READ_REG(hw, AIS);	/*  73 */
-	*reg++ = IXGB_READ_REG(hw, MSCA);	/*  74 */
-	*reg++ = IXGB_READ_REG(hw, MSRWD);	/*  75 */
+	*reg++ = IXGB_READ_REG(hw, MSCA);   /*  74 */
+	*reg++ = IXGB_READ_REG(hw, MSRWD);  /*  75 */
+
 
 	/* Statistics */
-	*reg++ = IXGB_GET_STAT(adapter, tprl);	/*  76 */
-	*reg++ = IXGB_GET_STAT(adapter, tprh);	/*  77 */
+	*reg++ = IXGB_GET_STAT(adapter, tprl);	 /*  76 */
+	*reg++ = IXGB_GET_STAT(adapter, tprh);	 /*  77 */
 	*reg++ = IXGB_GET_STAT(adapter, gprcl);	/*  78 */
 	*reg++ = IXGB_GET_STAT(adapter, gprch);	/*  79 */
 	*reg++ = IXGB_GET_STAT(adapter, bprcl);	/*  80 */
@@ -267,18 +331,18 @@ ixgb_ethtool_gregs(struct net_device *de
 	*reg++ = IXGB_GET_STAT(adapter, jprch);	/*  89 */
 	*reg++ = IXGB_GET_STAT(adapter, gorcl);	/*  90 */
 	*reg++ = IXGB_GET_STAT(adapter, gorch);	/*  91 */
-	*reg++ = IXGB_GET_STAT(adapter, torl);	/*  92 */
-	*reg++ = IXGB_GET_STAT(adapter, torh);	/*  93 */
-	*reg++ = IXGB_GET_STAT(adapter, rnbc);	/*  94 */
-	*reg++ = IXGB_GET_STAT(adapter, ruc);	/*  95 */
-	*reg++ = IXGB_GET_STAT(adapter, roc);	/*  96 */
-	*reg++ = IXGB_GET_STAT(adapter, rlec);	/*  97 */
-	*reg++ = IXGB_GET_STAT(adapter, crcerrs);	/*  98 */
-	*reg++ = IXGB_GET_STAT(adapter, icbc);	/*  99 */
-	*reg++ = IXGB_GET_STAT(adapter, ecbc);	/* 100 */
-	*reg++ = IXGB_GET_STAT(adapter, mpc);	/* 101 */
-	*reg++ = IXGB_GET_STAT(adapter, tptl);	/* 102 */
-	*reg++ = IXGB_GET_STAT(adapter, tpth);	/* 103 */
+	*reg++ = IXGB_GET_STAT(adapter, torl);	 /*  92 */
+	*reg++ = IXGB_GET_STAT(adapter, torh);	 /*  93 */
+	*reg++ = IXGB_GET_STAT(adapter, rnbc);	 /*  94 */
+	*reg++ = IXGB_GET_STAT(adapter, ruc);	  /*  95 */
+	*reg++ = IXGB_GET_STAT(adapter, roc);	  /*  96 */
+	*reg++ = IXGB_GET_STAT(adapter, rlec);	 /*  97 */
+	*reg++ = IXGB_GET_STAT(adapter, crcerrs);  /*  98 */
+	*reg++ = IXGB_GET_STAT(adapter, icbc);	 /*  99 */
+	*reg++ = IXGB_GET_STAT(adapter, ecbc);	 /* 100 */
+	*reg++ = IXGB_GET_STAT(adapter, mpc);	  /* 101 */
+	*reg++ = IXGB_GET_STAT(adapter, tptl);	 /* 102 */
+	*reg++ = IXGB_GET_STAT(adapter, tpth);	 /* 103 */
 	*reg++ = IXGB_GET_STAT(adapter, gptcl);	/* 104 */
 	*reg++ = IXGB_GET_STAT(adapter, gptch);	/* 105 */
 	*reg++ = IXGB_GET_STAT(adapter, bptcl);	/* 106 */
@@ -293,96 +357,252 @@ ixgb_ethtool_gregs(struct net_device *de
 	*reg++ = IXGB_GET_STAT(adapter, jptch);	/* 115 */
 	*reg++ = IXGB_GET_STAT(adapter, gotcl);	/* 116 */
 	*reg++ = IXGB_GET_STAT(adapter, gotch);	/* 117 */
-	*reg++ = IXGB_GET_STAT(adapter, totl);	/* 118 */
-	*reg++ = IXGB_GET_STAT(adapter, toth);	/* 119 */
-	*reg++ = IXGB_GET_STAT(adapter, dc);	/* 120 */
-	*reg++ = IXGB_GET_STAT(adapter, plt64c);	/* 121 */
+	*reg++ = IXGB_GET_STAT(adapter, totl);	 /* 118 */
+	*reg++ = IXGB_GET_STAT(adapter, toth);	 /* 119 */
+	*reg++ = IXGB_GET_STAT(adapter, dc);	   /* 120 */
+	*reg++ = IXGB_GET_STAT(adapter, plt64c);   /* 121 */
 	*reg++ = IXGB_GET_STAT(adapter, tsctc);	/* 122 */
-	*reg++ = IXGB_GET_STAT(adapter, tsctfc);	/* 123 */
-	*reg++ = IXGB_GET_STAT(adapter, ibic);	/* 124 */
-	*reg++ = IXGB_GET_STAT(adapter, rfc);	/* 125 */
-	*reg++ = IXGB_GET_STAT(adapter, lfc);	/* 126 */
-	*reg++ = IXGB_GET_STAT(adapter, pfrc);	/* 127 */
-	*reg++ = IXGB_GET_STAT(adapter, pftc);	/* 128 */
+	*reg++ = IXGB_GET_STAT(adapter, tsctfc);   /* 123 */
+	*reg++ = IXGB_GET_STAT(adapter, ibic);	 /* 124 */
+	*reg++ = IXGB_GET_STAT(adapter, rfc);	  /* 125 */
+	*reg++ = IXGB_GET_STAT(adapter, lfc);	  /* 126 */
+	*reg++ = IXGB_GET_STAT(adapter, pfrc);	 /* 127 */
+	*reg++ = IXGB_GET_STAT(adapter, pftc);	 /* 128 */
 	*reg++ = IXGB_GET_STAT(adapter, mcfrc);	/* 129 */
 	*reg++ = IXGB_GET_STAT(adapter, mcftc);	/* 130 */
-	*reg++ = IXGB_GET_STAT(adapter, xonrxc);	/* 131 */
-	*reg++ = IXGB_GET_STAT(adapter, xontxc);	/* 132 */
-	*reg++ = IXGB_GET_STAT(adapter, xoffrxc);	/* 133 */
-	*reg++ = IXGB_GET_STAT(adapter, xofftxc);	/* 134 */
-	*reg++ = IXGB_GET_STAT(adapter, rjc);	/* 135 */
+	*reg++ = IXGB_GET_STAT(adapter, xonrxc);   /* 131 */
+	*reg++ = IXGB_GET_STAT(adapter, xontxc);   /* 132 */
+	*reg++ = IXGB_GET_STAT(adapter, xoffrxc);  /* 133 */
+	*reg++ = IXGB_GET_STAT(adapter, xofftxc);  /* 134 */
+	*reg++ = IXGB_GET_STAT(adapter, rjc);	  /* 135 */
 
 	regs->len = (reg - reg_start) * sizeof(uint32_t);
 }
 
 static int
-ixgb_ethtool_geeprom(struct net_device *dev,
-		     struct ethtool_eeprom *eeprom, u8 *data)
+ixgb_get_eeprom_len(struct net_device *netdev)
+{
+	/* return size in bytes */
+	return (IXGB_EEPROM_SIZE << 1);
+}
+
+static int
+ixgb_get_eeprom(struct net_device *netdev,
+					  struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
+	uint16_t *eeprom_buff;
+	int i, max_len, first_word, last_word;
+	int ret_val = 0;
+
+	if(eeprom->len == 0) {
+		ret_val = -EINVAL;
+		goto geeprom_error;
+	}
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
 
-	/* use our function to read the eeprom and update our cache */
-	ixgb_get_eeprom_data(hw);
-	memcpy(data, (char *)hw->eeprom + eeprom->offset, eeprom->len);
-	return 0;
+	max_len = ixgb_get_eeprom_len(netdev);
+
+	if(eeprom->offset > eeprom->offset + eeprom->len) {
+		ret_val = -EINVAL;
+		goto geeprom_error;
+	}
+
+	if((eeprom->offset + eeprom->len) > max_len)
+		eeprom->len = (max_len - eeprom->offset);
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+
+	eeprom_buff = kmalloc(sizeof(uint16_t) *
+			(last_word - first_word + 1), GFP_KERNEL);
+	if(!eeprom_buff)
+		return -ENOMEM;
+
+	/* note the eeprom was good because the driver loaded */
+	for(i = 0; i <= (last_word - first_word); i++) {
+		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
+	}
+
+	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+			eeprom->len);
+	kfree(eeprom_buff);
+
+geeprom_error:
+	return ret_val;
 }
 
 static int
-ixgb_ethtool_seeprom(struct net_device *dev,
-		     struct ethtool_eeprom *eeprom, u8 *data)
+ixgb_set_eeprom(struct net_device *netdev,
+					  struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	/* We are under rtnl, so static is OK */
-	static uint16_t eeprom_buff[IXGB_EEPROM_SIZE];
-	int i, first_word, last_word;
-	char *ptr;
+	uint16_t *eeprom_buff;
+	void *ptr;
+	int max_len, first_word, last_word;
+	uint16_t i;
 
-	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+	if(eeprom->len == 0)
+		return -EINVAL;
+
+	if(eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
 
+	max_len = ixgb_get_eeprom_len(netdev);
+
+	if(eeprom->offset > eeprom->offset + eeprom->len)
+		return -EINVAL;
+
+	if((eeprom->offset + eeprom->len) > max_len)
+		eeprom->len = (max_len - eeprom->offset);
+
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
-	ptr = (char *)eeprom_buff;
+	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+	if(!eeprom_buff)
+		return -ENOMEM;
 
-	if (eeprom->offset & 1) {
+	ptr = (void *)eeprom_buff;
+
+	if(eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
 		eeprom_buff[0] = ixgb_read_eeprom(hw, first_word);
 		ptr++;
 	}
-	if ((eeprom->offset + eeprom->len) & 1) {
+	if((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word]
-		    = ixgb_read_eeprom(hw, last_word);
+		eeprom_buff[last_word - first_word] 
+			= ixgb_read_eeprom(hw, last_word);
 	}
-	memcpy(ptr, data, eeprom->len);
 
-	for (i = 0; i <= (last_word - first_word); i++)
+
+	memcpy(ptr, bytes, eeprom->len);
+
+	for(i = 0; i <= (last_word - first_word); i++)
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
 
 	/* Update the checksum over the first part of the EEPROM if needed */
-	if (first_word <= EEPROM_CHECKSUM_REG)
+	if(first_word <= EEPROM_CHECKSUM_REG)
 		ixgb_update_eeprom_checksum(hw);
 
+	kfree(eeprom_buff);
 	return 0;
 }
 
+static void
+ixgb_get_drvinfo(struct net_device *netdev,
+					   struct ethtool_drvinfo *drvinfo)
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
+					struct ethtool_ringparam *ring)
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
+					struct ethtool_ringparam *ring)
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
+	return 0;
+err_setup_tx:
+	ixgb_free_rx_resources(adapter);
+err_setup_rx:
+	adapter->rx_ring = rx_old;
+	adapter->tx_ring = tx_old;
+	ixgb_up(adapter);
+	return err;
+}
+
+
+
+
+
+
 /* toggle LED 4 times per second = 2 "blinks" per second */
 #define IXGB_ID_INTERVAL	(HZ/4)
 
 /* bit defines for adapter->led_status */
 #define IXGB_LED_ON		0
 
-static void ixgb_led_blink_callback(unsigned long data)
+static void
+ixgb_led_blink_callback(unsigned long data)
 {
-	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
+	struct ixgb_adapter *adapter = (struct ixgb_adapter *) data;
 
-	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
+	if(test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
 		ixgb_led_off(&adapter->hw);
 	else
 		ixgb_led_on(&adapter->hw);
@@ -391,19 +611,23 @@ static void ixgb_led_blink_callback(unsi
 }
 
 static int
-ixgb_ethtool_led_blink(struct net_device *netdev, u32 data)
+ixgb_phys_id(struct net_device *netdev, uint32_t data)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	if (!adapter->blink_timer.function) {
+
+	if(!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
+		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+
+	if(!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function = ixgb_led_blink_callback;
-		adapter->blink_timer.data = (unsigned long)adapter;
+		adapter->blink_timer.data = (unsigned long) adapter;
 	}
 
 	mod_timer(&adapter->blink_timer, jiffies);
 
 	set_current_state(TASK_INTERRUPTIBLE);
-	if (data)
+	if(data)
 		schedule_timeout(data * HZ);
 	else
 		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
@@ -415,141 +639,74 @@ ixgb_ethtool_led_blink(struct net_device
 	return 0;
 }
 
-static int ixgb_nway_reset(struct net_device *netdev)
-{
-	if (netif_running(netdev)) {
-		struct ixgb_adapter *adapter = netdev->priv;
-		ixgb_down(adapter, TRUE);
-		ixgb_up(adapter);
-	}
-	return 0;
-}
-
-static int ixgb_get_stats_count(struct net_device *dev)
+static int 
+ixgb_get_stats_count(struct net_device *netdev)
 {
 	return IXGB_STATS_LEN;
 }
 
-static void ixgb_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+static void 
+ixgb_get_ethtool_stats(struct net_device *netdev, 
+		struct ethtool_stats *stats, uint64_t *data)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	int i;
-	for (i = 0; i < IXGB_STATS_LEN; i++) {
-		memcpy(data + i * ETH_GSTRING_LEN,
-		       ixgb_gstrings_stats[i].stat_string,
-		       ETH_GSTRING_LEN);
-	}
-}
-
-static int ixgb_get_regs_len(struct net_device *dev)
-{
-	return 136*sizeof(uint32_t);
-}
 
-static int ixgb_get_eeprom_len(struct net_device *dev)
-{
-	/* return size in bytes */
-	return (IXGB_EEPROM_SIZE << 1);
+	ixgb_update_stats(adapter);
+	for(i = 0; i < IXGB_STATS_LEN; i++) {
+		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
+		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
 }
 
-static void get_ethtool_stats(struct net_device *dev,
-		struct ethtool_stats *stats, u64 *data)
+static void 
+ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
-	struct ixgb_adapter *adapter = dev->priv;
 	int i;
 
-	for (i = 0; i < IXGB_STATS_LEN; i++) {
-		void *p = (char *)adapter + ixgb_gstrings_stats[i].stat_offset;
-		stats->data[i] =
-		    (ixgb_gstrings_stats[i].sizeof_stat == sizeof(uint64_t))
-		    ? *(uint64_t *) p
-		    : *(uint32_t *) p;
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for (i=0; i < IXGB_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN, 
+			ixgb_gstrings_stats[i].stat_string,
+			ETH_GSTRING_LEN);
+		}
+		break;
 	}
 }
 
-static u32 ixgb_get_rx_csum(struct net_device *dev)
-{
-	struct ixgb_adapter *adapter = dev->priv;
-	return adapter->rx_csum;
-}
-
-static int ixgb_set_rx_csum(struct net_device *dev, u32 sum)
-{
-	struct ixgb_adapter *adapter = dev->priv;
-	adapter->rx_csum = sum;
-	ixgb_down(adapter, TRUE);
-	ixgb_up(adapter);
-	return 0;
-}
-
-static u32 ixgb_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_HW_CSUM) != 0;
-}
-
-static int ixgb_set_tx_csum(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_HW_CSUM;
-	else
-		dev->features &= ~NETIF_F_HW_CSUM;
-	return 0;
-}
-
-static u32 ixgb_get_sg(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_SG) != 0;
-}
-
-static int ixgb_set_sg(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_SG;
-	else
-		dev->features &= ~NETIF_F_SG;
-	return 0;
-}
-
-#ifdef NETIF_F_TSO
-static u32 ixgb_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) != 0;
-}
-
-static int ixgb_set_tso(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_TSO;
-	else
-		dev->features &= ~NETIF_F_TSO;
-	return 0;
-}
-#endif
-
 struct ethtool_ops ixgb_ethtool_ops = {
-	.get_settings = ixgb_ethtool_gset,
-	.set_settings = ixgb_ethtool_sset,
-	.get_drvinfo = ixgb_ethtool_gdrvinfo,
-	.nway_reset = ixgb_nway_reset,
-	.get_link = ethtool_op_get_link,
-	.phys_id = ixgb_ethtool_led_blink,
-	.get_strings = ixgb_get_strings,
-	.get_stats_count = ixgb_get_stats_count,
-	.get_regs = ixgb_ethtool_gregs,
-	.get_regs_len = ixgb_get_regs_len,
-	.get_eeprom_len = ixgb_get_eeprom_len,
-	.get_eeprom = ixgb_ethtool_geeprom,
-	.set_eeprom = ixgb_ethtool_seeprom,
-	.get_pauseparam = ixgb_ethtool_gpause,
-	.set_pauseparam = ixgb_ethtool_spause,
-	.get_ethtool_stats = get_ethtool_stats,
-	.get_rx_csum = ixgb_get_rx_csum,
-	.set_rx_csum = ixgb_set_rx_csum,
-	.get_tx_csum = ixgb_get_tx_csum,
-	.set_tx_csum = ixgb_set_tx_csum,
-	.get_sg = ixgb_get_sg,
-	.set_sg = ixgb_set_sg,
+	.get_settings		= ixgb_get_settings,
+	.set_settings		= ixgb_set_settings,
+	.get_drvinfo		= ixgb_get_drvinfo,
+	.get_regs_len		= ixgb_get_regs_len,
+	.get_regs		= ixgb_get_regs,
+	.get_link		= ethtool_op_get_link,
+	.get_eeprom_len		= ixgb_get_eeprom_len,
+	.get_eeprom		= ixgb_get_eeprom,
+	.set_eeprom		= ixgb_set_eeprom,
+	.get_ringparam		= ixgb_get_ringparam,
+	.set_ringparam		= ixgb_set_ringparam,
+	.get_pauseparam		= ixgb_get_pauseparam,
+	.set_pauseparam		= ixgb_set_pauseparam,
+	.get_rx_csum		= ixgb_get_rx_csum,
+	.set_rx_csum		= ixgb_set_rx_csum,
+	.get_tx_csum		= ixgb_get_tx_csum,
+	.set_tx_csum		= ixgb_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
-	.get_tso = ixgb_get_tso,
-	.set_tso = ixgb_set_tso,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= ixgb_set_tso,
 #endif
+	.get_strings		= ixgb_get_strings,
+	.phys_id		= ixgb_phys_id,
+	.get_stats_count	= ixgb_get_stats_count,
+	.get_ethtool_stats	= ixgb_get_ethtool_stats,
 };
+
+void set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
+}
diff -up netdev-2.6/drivers/net/ixgb/ixgb.h netdev-2.6/drivers/net/ixgb.new/ixgb.h
--- netdev-2.6/drivers/net/ixgb/ixgb.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-15 13:15:51.000000000 -0700
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
diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-15 13:15:55.000000000 -0700
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
@@ -97,6 +71,7 @@ 
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
+void set_ethtool_ops(struct net_device *netdev);
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct net_device *dev);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
@@ -123,7 +71,6 @@ 
 /* Exported from other modules */
 
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
-extern struct ethtool_ops ixgb_ethtool_ops;
 
 static struct pci_driver ixgb_driver = {
 	.name = ixgb_driver_name,
@@ -371,9 +357,9 @@ ixgb_probe(struct pci_dev *pdev, const s
 	netdev->set_multicast_list = &ixgb_set_multi;
 	netdev->set_mac_address = &ixgb_set_mac;
 	netdev->change_mtu = &ixgb_change_mtu;
+	set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = HZ;
-	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 #ifdef CONFIG_IXGB_NAPI
 	netdev->poll = &ixgb_clean;
 	netdev->weight = 64;
@@ -601,7 +600,8 @@ static int ixgb_close(struct net_device 
  * Return 0 on success, negative on failure
  **/
 
-static int ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -690,7 +691,8 @@ static void ixgb_configure_tx(struct ixg
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -859,7 +865,8 @@ static void ixgb_configure_rx(struct ixg
  * Free all transmit software resources
  **/
 
-static void ixgb_free_tx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -924,7 +932,8 @@ static void ixgb_clean_tx_ring(struct ix
  * Free all receive software resources
  **/
 
-static void ixgb_free_rx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1474,7 +1474,8 @@ static int ixgb_change_mtu(struct net_de
  * @adapter: board private structure
  **/
 
-static void ixgb_update_stats(struct ixgb_adapter *adapter)
+void
+ixgb_update_stats(struct ixgb_adapter *adapter)
 {
 	adapter->stats.tprl += IXGB_READ_REG(&adapter->hw, TPRL);
 	adapter->stats.tprh += IXGB_READ_REG(&adapter->hw, TPRH);
diff -up netdev-2.6/drivers/net/ixgb/ixgb_param.c netdev-2.6/drivers/net/ixgb.new/ixgb_param.c
--- netdev-2.6/drivers/net/ixgb/ixgb_param.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_param.c	2004-10-15 13:15:57.000000000 -0700
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
