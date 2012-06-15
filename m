From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 08/20] ipw2x00: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:48 -0700
Message-ID: <95f5ab1036b2aaffba5ea2ff791e269ffb8dc2b6.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c       |  225 +++++++++++---------------
 drivers/net/wireless/ipw2x00/ipw2100.h       |    4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |   54 +++----
 drivers/net/wireless/ipw2x00/ipw2200.h       |   36 +++--
 drivers/net/wireless/ipw2x00/libipw.h        |   24 ++-
 drivers/net/wireless/ipw2x00/libipw_geo.c    |    3 +
 drivers/net/wireless/ipw2x00/libipw_module.c |    9 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c     |   49 +++---
 drivers/net/wireless/ipw2x00/libipw_tx.c     |   11 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c     |    4 +-
 10 files changed, 197 insertions(+), 222 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 95aa8e1..064b16f 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -133,6 +133,8 @@ that only one external action is invoked at a time.
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
@@ -212,16 +214,21 @@ MODULE_PARM_DESC(disable, "manually disable the radio (default 0 [radio on])");
 static u32 ipw2100_debug_level = IPW_DL_NONE;
 
 #ifdef CONFIG_IPW2100_DEBUG
-#define IPW_DEBUG(level, message...) \
-do { \
-	if (ipw2100_debug_level & (level)) { \
-		printk(KERN_DEBUG "ipw2100: %c %s ", \
-                       in_interrupt() ? 'I' : 'U',  __func__); \
-		printk(message); \
-	} \
+#define IPW_DEBUG(level, fmt, ...)					\
+do {									\
+	if (ipw2100_debug_level & (level))				\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U',  __func__,		\
+			 ##__VA_ARGS__);				\
 } while (0)
 #else
-#define IPW_DEBUG(level, message...) do {} while (0)
+#define IPW_DEBUG(level, fmt, ...)					\
+do {									\
+	if (0)								\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U',  __func__,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #endif				/* CONFIG_IPW2100_DEBUG */
 
 #ifdef CONFIG_IPW2100_DEBUG
@@ -539,8 +546,7 @@ static int ipw2100_get_ordinal(struct ipw2100_priv *priv, u32 ord,
 	u32 total_length;
 
 	if (ordinals->table1_addr == 0) {
-		printk(KERN_WARNING DRV_NAME ": attempt to use fw ordinals "
-		       "before they have been loaded.\n");
+		pr_warn("attempt to use fw ordinals before they have been loaded\n");
 		return -EINVAL;
 	}
 
@@ -548,9 +554,8 @@ static int ipw2100_get_ordinal(struct ipw2100_priv *priv, u32 ord,
 		if (*len < IPW_ORD_TAB_1_ENTRY_SIZE) {
 			*len = IPW_ORD_TAB_1_ENTRY_SIZE;
 
-			printk(KERN_WARNING DRV_NAME
-			       ": ordinal buffer length too small, need %zd\n",
-			       IPW_ORD_TAB_1_ENTRY_SIZE);
+			pr_warn("ordinal buffer length too small, need %zd\n",
+				IPW_ORD_TAB_1_ENTRY_SIZE);
 
 			return -EINVAL;
 		}
@@ -601,8 +606,7 @@ static int ipw2100_get_ordinal(struct ipw2100_priv *priv, u32 ord,
 		return 0;
 	}
 
-	printk(KERN_WARNING DRV_NAME ": ordinal %d neither in table 1 nor "
-	       "in table 2\n", ord);
+	pr_warn("ordinal %d neither in table 1 nor in table 2\n", ord);
 
 	return -EINVAL;
 }
@@ -680,9 +684,9 @@ static void printk_buf(int level, const u8 * data, u32 len)
 		return;
 
 	while (len) {
-		printk(KERN_DEBUG "%s\n",
-		       snprint_line(line, sizeof(line), &data[ofs],
-				    min(len, 16U), ofs));
+		pr_debug("%s\n",
+			 snprint_line(line, sizeof(line), &data[ofs],
+				      min(len, 16U), ofs));
 		ofs += 16;
 		len -= min(len, 16U);
 	}
@@ -820,8 +824,7 @@ static int ipw2100_hw_send_command(struct ipw2100_priv *priv,
 	}
 
 	if (priv->fatal_error) {
-		printk(KERN_WARNING DRV_NAME ": %s: firmware fatal error\n",
-		       priv->net_dev->name);
+		pr_warn("%s: firmware fatal error\n", priv->net_dev->name);
 		return -EIO;
 	}
 
@@ -1052,7 +1055,7 @@ static int ipw2100_download_firmware(struct ipw2100_priv *priv)
 	/* load microcode */
 	err = ipw2100_ucode_download(priv, &ipw2100_firmware);
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": %s: Error loading microcode: %d\n",
+		pr_err("%s: Error loading microcode: %d\n",
 		       priv->net_dev->name, err);
 		goto fail;
 	}
@@ -1064,8 +1067,7 @@ static int ipw2100_download_firmware(struct ipw2100_priv *priv)
 	/* s/w reset and clock stabilization (again!!!) */
 	err = sw_reset_and_clock(priv);
 	if (err) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: sw_reset_and_clock failed: %d\n",
+		pr_err("%s: sw_reset_and_clock failed: %d\n",
 		       priv->net_dev->name, err);
 		goto fail;
 	}
@@ -1259,8 +1261,7 @@ static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 	 * fw & dino ucode
 	 */
 	if (ipw2100_download_firmware(priv)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to power on the adapter.\n",
+		pr_err("%s: Failed to power on the adapter\n",
 		       priv->net_dev->name);
 		return -EIO;
 	}
@@ -1319,9 +1320,8 @@ static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 		     i ? "SUCCESS" : "FAILED");
 
 	if (!i) {
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Firmware did not initialize.\n",
-		       priv->net_dev->name);
+		pr_warn("%s: Firmware did not initialize\n",
+			priv->net_dev->name);
 		return -EIO;
 	}
 
@@ -1512,8 +1512,7 @@ static int ipw2100_hw_stop_adapter(struct ipw2100_priv *priv)
 
 		err = ipw2100_hw_phy_off(priv);
 		if (err)
-			printk(KERN_WARNING DRV_NAME
-			       ": Error disabling radio %d\n", err);
+			pr_warn("Error disabling radio %d\n", err);
 
 		/*
 		 * If in D0-standby mode going directly to D3 may cause a
@@ -1539,9 +1538,8 @@ static int ipw2100_hw_stop_adapter(struct ipw2100_priv *priv)
 
 		err = ipw2100_hw_send_command(priv, &cmd);
 		if (err)
-			printk(KERN_WARNING DRV_NAME ": "
-			       "%s: Power down command failed: Error %d\n",
-			       priv->net_dev->name, err);
+			pr_warn("%s: Power down command failed: Error %d\n",
+				priv->net_dev->name, err);
 		else
 			schedule_timeout_uninterruptible(HW_POWER_DOWN_DELAY);
 	}
@@ -1578,9 +1576,8 @@ static int ipw2100_hw_stop_adapter(struct ipw2100_priv *priv)
 	}
 
 	if (i == 0)
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Could now power down adapter.\n",
-		       priv->net_dev->name);
+		pr_warn("%s: Could now power down adapter\n",
+			priv->net_dev->name);
 
 	/* assert s/w reset */
 	write_register(priv->net_dev, IPW_REG_RESET_REG,
@@ -1617,15 +1614,13 @@ static int ipw2100_disable_adapter(struct ipw2100_priv *priv)
 
 	err = ipw2100_hw_send_command(priv, &cmd);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       ": exit - failed to send CARD_DISABLE command\n");
+		pr_warn("exit - failed to send CARD_DISABLE command\n");
 		goto fail_up;
 	}
 
 	err = ipw2100_wait_for_card_state(priv, IPW_HW_STATE_DISABLED);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       ": exit - card failed to change to DISABLED\n");
+		pr_warn("exit - card failed to change to DISABLED\n");
 		goto fail_up;
 	}
 
@@ -1758,9 +1753,8 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 	    (priv->status & STATUS_RESET_PENDING)) {
 		/* Power cycle the card ... */
 		if (ipw2100_power_cycle_adapter(priv)) {
-			printk(KERN_WARNING DRV_NAME
-			       ": %s: Could not cycle adapter.\n",
-			       priv->net_dev->name);
+			pr_warn("%s: Could not cycle adapter\n",
+				priv->net_dev->name);
 			rc = 1;
 			goto exit;
 		}
@@ -1769,8 +1763,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 
 	/* Load the firmware, start the clocks, etc. */
 	if (ipw2100_start_adapter(priv)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to start the firmware.\n",
+		pr_err("%s: Failed to start the firmware\n",
 		       priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1780,8 +1773,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 
 	/* Determine capabilities of this particular HW configuration */
 	if (ipw2100_get_hw_features(priv)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to determine HW features.\n",
+		pr_err("%s: Failed to determine HW features\n",
 		       priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1789,15 +1781,14 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 
 	/* Initialize the geo */
 	if (libipw_set_geo(priv->ieee, &ipw_geos[0])) {
-		printk(KERN_WARNING DRV_NAME "Could not set geo\n");
+		pr_warn("Could not set geo\n");
 		return 0;
 	}
 	priv->ieee->freq_band = LIBIPW_24GHZ_BAND;
 
 	lock = LOCK_NONE;
 	if (ipw2100_set_ordinal(priv, IPW_ORD_PERS_DB_LOCK, &lock, &ord_len)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to clear ordinal lock.\n",
+		pr_err("%s: Failed to clear ordinal lock\n",
 		       priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1806,7 +1797,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 	priv->status &= ~STATUS_SCANNING;
 
 	if (rf_kill_active(priv)) {
-		printk(KERN_INFO "%s: Radio is disabled by RF switch.\n",
+		pr_info("%s: Radio is disabled by RF switch\n",
 		       priv->net_dev->name);
 
 		if (priv->stop_rf_kill) {
@@ -1824,7 +1815,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 	/* Send all of the commands that must be sent prior to
 	 * HOST_COMPLETE */
 	if (ipw2100_adapter_setup(priv)) {
-		printk(KERN_ERR DRV_NAME ": %s: Failed to start the card.\n",
+		pr_err("%s: Failed to start the card\n",
 		       priv->net_dev->name);
 		rc = 1;
 		goto exit;
@@ -1833,8 +1824,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 	if (!deferred) {
 		/* Enable the adapter - sends HOST_COMPLETE */
 		if (ipw2100_enable_adapter(priv)) {
-			printk(KERN_ERR DRV_NAME ": "
-			       "%s: failed in call to enable adapter.\n",
+			pr_err("%s: failed in call to enable adapter\n",
 			       priv->net_dev->name);
 			ipw2100_hw_stop_adapter(priv);
 			rc = 1;
@@ -1882,8 +1872,7 @@ static void ipw2100_down(struct ipw2100_priv *priv)
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 
 	if (ipw2100_hw_stop_adapter(priv))
-		printk(KERN_ERR DRV_NAME ": %s: Error stopping adapter.\n",
-		       priv->net_dev->name);
+		pr_err("%s: Error stopping adapter\n", priv->net_dev->name);
 
 	/* Do not disable the interrupt until _after_ we disable
 	 * the adaptor.  Otherwise the CARD_DISABLE command will never
@@ -2540,9 +2529,8 @@ static void isr_rx(struct ipw2100_priv *priv, int i,
 
 	/* We need to allocate a new SKB and attach it to the RDB. */
 	if (unlikely(ipw2100_alloc_skb(priv, packet))) {
-		printk(KERN_WARNING DRV_NAME ": "
-		       "%s: Unable to allocate SKB onto RBD ring - disabling "
-		       "adapter.\n", dev->name);
+		pr_warn("%s: Unable to allocate SKB onto RBD ring - disabling adapter\n",
+			dev->name);
 		/* TODO: schedule adapter shutdown */
 		IPW_DEBUG_INFO("TODO: Shutdown adapter...\n");
 	}
@@ -2871,8 +2859,7 @@ static int __ipw2100_tx_process(struct ipw2100_priv *priv)
 		break;
 
 	default:
-		printk(KERN_WARNING DRV_NAME ": %s: Bad fw_pend_list entry!\n",
-		       priv->net_dev->name);
+		pr_warn("%s: Bad fw_pend_list entry!\n", priv->net_dev->name);
 		return 0;
 	}
 
@@ -2885,8 +2872,7 @@ static int __ipw2100_tx_process(struct ipw2100_priv *priv)
 	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
 		      &w);
 	if (w != txq->next)
-		printk(KERN_WARNING DRV_NAME ": %s: write index mismatch\n",
-		       priv->net_dev->name);
+		pr_warn("%s: write index mismatch\n", priv->net_dev->name);
 
 	/*
 	 * txq->next is the index of the last packet written txq->oldest is
@@ -2942,10 +2928,9 @@ static int __ipw2100_tx_process(struct ipw2100_priv *priv)
 	switch (packet->type) {
 	case DATA:
 		if (txq->drv[txq->oldest].status.info.fields.txType != 0)
-			printk(KERN_WARNING DRV_NAME ": %s: Queue mismatch.  "
-			       "Expecting DATA TBD but pulled "
-			       "something else: ids %d=%d.\n",
-			       priv->net_dev->name, txq->oldest, packet->index);
+			pr_warn("%s: Queue mismatch.  Expecting DATA TBD but pulled something else: ids %d=%d\n",
+				priv->net_dev->name,
+				txq->oldest, packet->index);
 
 		/* DATA packet; we have to unmap and free the SKB */
 		for (i = 0; i < frag_num; i++) {
@@ -2979,10 +2964,9 @@ static int __ipw2100_tx_process(struct ipw2100_priv *priv)
 
 	case COMMAND:
 		if (txq->drv[txq->oldest].status.info.fields.txType != 1)
-			printk(KERN_WARNING DRV_NAME ": %s: Queue mismatch.  "
-			       "Expecting COMMAND TBD but pulled "
-			       "something else: ids %d=%d.\n",
-			       priv->net_dev->name, txq->oldest, packet->index);
+			pr_warn("%s: Queue mismatch.  Expecting COMMAND TBD but pulled something else: ids %d=%d\n",
+				priv->net_dev->name,
+				txq->oldest, packet->index);
 
 #ifdef CONFIG_IPW2100_DEBUG
 		if (packet->info.c_struct.cmd->host_command_reg <
@@ -3020,9 +3004,8 @@ static inline void __ipw2100_tx_complete(struct ipw2100_priv *priv)
 		i++;
 
 	if (i == 200) {
-		printk(KERN_WARNING DRV_NAME ": "
-		       "%s: Driver is running slow (%d iters).\n",
-		       priv->net_dev->name, i);
+		pr_warn("%s: Driver is running slow (%d iters)\n",
+			priv->net_dev->name, i);
 	}
 }
 
@@ -3258,8 +3241,7 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 		      (unsigned long)inta & IPW_INTERRUPT_MASK);
 
 	if (inta & IPW2100_INTA_FATAL_ERROR) {
-		printk(KERN_WARNING DRV_NAME
-		       ": Fatal interrupt. Scheduling firmware restart.\n");
+		pr_warn("Fatal interrupt. Scheduling firmware restart.\n");
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_FATAL_ERROR);
 
@@ -3276,8 +3258,7 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 	}
 
 	if (inta & IPW2100_INTA_PARITY_ERROR) {
-		printk(KERN_ERR DRV_NAME
-		       ": ***** PARITY ERROR INTERRUPT !!!!\n");
+		pr_err("***** PARITY ERROR INTERRUPT !!!!\n");
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_PARITY_ERROR);
 	}
@@ -3379,7 +3360,7 @@ static irqreturn_t ipw2100_interrupt(int irq, void *data)
 
 	if (inta == 0xFFFFFFFF) {
 		/* Hardware disappeared */
-		printk(KERN_WARNING DRV_NAME ": IRQ INTA == 0xFFFFFFFF\n");
+		pr_warn("IRQ INTA == 0xFFFFFFFF\n");
 		goto none;
 	}
 
@@ -3468,9 +3449,8 @@ static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
 		v = pci_alloc_consistent(priv->pci_dev,
 					 sizeof(struct ipw2100_cmd_header), &p);
 		if (!v) {
-			printk(KERN_ERR DRV_NAME ": "
-			       "%s: PCI alloc failed for msg "
-			       "buffers.\n", priv->net_dev->name);
+			pr_err("%s: PCI alloc failed for msg buffers\n",
+			       priv->net_dev->name);
 			err = -ENOMEM;
 			break;
 		}
@@ -4040,7 +4020,7 @@ static int ipw2100_switch_mode(struct ipw2100_priv *priv, u32 mode)
 
 	err = ipw2100_disable_adapter(priv);
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": %s: Could not disable adapter %d\n",
+		pr_err("%s: Could not disable adapter %d\n",
 		       priv->net_dev->name, err);
 		return err;
 	}
@@ -4068,7 +4048,7 @@ static int ipw2100_switch_mode(struct ipw2100_priv *priv, u32 mode)
 	ipw2100_firmware.version = 0;
 #endif
 
-	printk(KERN_INFO "%s: Resetting on mode change.\n", priv->net_dev->name);
+	pr_info("%s: Resetting on mode change\n", priv->net_dev->name);
 	priv->reset_backoff = 0;
 	schedule_reset(priv);
 
@@ -4486,8 +4466,7 @@ static int ipw2100_tx_allocate(struct ipw2100_priv *priv)
 	    kmalloc(TX_PENDED_QUEUE_LENGTH * sizeof(struct ipw2100_tx_packet),
 		    GFP_ATOMIC);
 	if (!priv->tx_buffers) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: alloc failed form tx buffers.\n",
+		pr_err("%s: alloc failed form tx buffers\n",
 		       priv->net_dev->name);
 		bd_queue_free(priv, &priv->tx_queue);
 		return -ENOMEM;
@@ -4498,8 +4477,7 @@ static int ipw2100_tx_allocate(struct ipw2100_priv *priv)
 					 sizeof(struct ipw2100_data_header),
 					 &p);
 		if (!v) {
-			printk(KERN_ERR DRV_NAME
-			       ": %s: PCI alloc failed for tx " "buffers.\n",
+			pr_err("%s: PCI alloc failed for tx buffers\n",
 			       priv->net_dev->name);
 			err = -ENOMEM;
 			break;
@@ -4809,8 +4787,7 @@ static int ipw2100_set_port_type(struct ipw2100_priv *priv, u32 port_type,
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			printk(KERN_ERR DRV_NAME
-			       ": %s: Could not disable adapter %d\n",
+			pr_err("%s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5390,8 +5367,7 @@ static int ipw2100_set_wep_flags(struct ipw2100_priv *priv, u32 flags,
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			printk(KERN_ERR DRV_NAME
-			       ": %s: Could not disable adapter %d\n",
+			pr_err("%s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5478,8 +5454,7 @@ static int ipw2100_set_key(struct ipw2100_priv *priv,
 		err = ipw2100_disable_adapter(priv);
 		/* FIXME: IPG: shouldn't this prink be in _disable_adapter()? */
 		if (err) {
-			printk(KERN_ERR DRV_NAME
-			       ": %s: Could not disable adapter %d\n",
+			pr_err("%s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -5515,8 +5490,7 @@ static int ipw2100_set_key_index(struct ipw2100_priv *priv,
 	if (!batch_mode) {
 		err = ipw2100_disable_adapter(priv);
 		if (err) {
-			printk(KERN_ERR DRV_NAME
-			       ": %s: Could not disable adapter %d\n",
+			pr_err("%s: Could not disable adapter %d\n",
 			       priv->net_dev->name, err);
 			return err;
 		}
@@ -6232,8 +6206,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
 	ioaddr = pci_iomap(pci_dev, 0, 0);
 	if (!ioaddr) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling ioremap_nocache.\n");
+		pr_warn("Error calling ioremap_nocache\n");
 		err = -EIO;
 		goto fail;
 	}
@@ -6241,8 +6214,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	/* allocate and initialize our net_device */
 	dev = ipw2100_alloc_device(pci_dev, ioaddr);
 	if (!dev) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling ipw2100_alloc_device.\n");
+		pr_warn("Error calling ipw2100_alloc_device\n");
 		err = -ENOMEM;
 		goto fail;
 	}
@@ -6250,8 +6222,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	/* set up PCI mappings for device */
 	err = pci_enable_device(pci_dev);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling pci_enable_device.\n");
+		pr_warn("Error calling pci_enable_device\n");
 		return err;
 	}
 
@@ -6262,16 +6233,14 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
 	err = pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32));
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling pci_set_dma_mask.\n");
+		pr_warn("Error calling pci_set_dma_mask\n");
 		pci_disable_device(pci_dev);
 		return err;
 	}
 
 	err = pci_request_regions(pci_dev, DRV_NAME);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling pci_request_regions.\n");
+		pr_warn("Error calling pci_request_regions\n");
 		pci_disable_device(pci_dev);
 		return err;
 	}
@@ -6285,8 +6254,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	pci_set_power_state(pci_dev, PCI_D0);
 
 	if (!ipw2100_hw_is_adapter_in_system(dev)) {
-		printk(KERN_WARNING DRV_NAME
-		       "Device not found via register read.\n");
+		pr_warn("Device not found via register read\n");
 		err = -ENODEV;
 		goto fail;
 	}
@@ -6299,8 +6267,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
 	/* Allocate and initialize the Tx/Rx queues and lists */
 	if (ipw2100_queues_allocate(priv)) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling ipw2100_queues_allocate.\n");
+		pr_warn("Error calling ipw2100_queues_allocate\n");
 		err = -ENOMEM;
 		goto fail;
 	}
@@ -6309,16 +6276,14 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	err = request_irq(pci_dev->irq,
 			  ipw2100_interrupt, IRQF_SHARED, dev->name, priv);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling request_irq: %d.\n", pci_dev->irq);
+		pr_warn("Error calling request_irq: %d\n", pci_dev->irq);
 		goto fail;
 	}
 	dev->irq = pci_dev->irq;
 
 	IPW_DEBUG_INFO("Attempting to register device...\n");
 
-	printk(KERN_INFO DRV_NAME
-	       ": Detected Intel PRO/Wireless 2100 Network Connection\n");
+	pr_info("Detected Intel PRO/Wireless 2100 Network Connection\n");
 
 	err = ipw2100_up(priv, 1);
 	if (err)
@@ -6336,8 +6301,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	 */
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_WARNING DRV_NAME
-		       "Error calling register_netdev.\n");
+		pr_warn("Error calling register_netdev\n");
 		goto fail;
 	}
 	registered = 2;
@@ -6356,9 +6320,8 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	if (!(priv->status & STATUS_RF_KILL_MASK)) {
 		/* Enable the adapter - sends HOST_COMPLETE */
 		if (ipw2100_enable_adapter(priv)) {
-			printk(KERN_WARNING DRV_NAME
-			       ": %s: failed in call to enable adapter.\n",
-			       priv->net_dev->name);
+			pr_warn("%s: failed in call to enable adapter\n",
+				priv->net_dev->name);
 			ipw2100_hw_stop_adapter(priv);
 			err = -EIO;
 			goto fail_unlock;
@@ -6509,7 +6472,7 @@ static int ipw2100_resume(struct pci_dev *pci_dev)
 	pci_set_power_state(pci_dev, PCI_D0);
 	err = pci_enable_device(pci_dev);
 	if (err) {
-		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		pr_err("%s: pci_enable_device failed on resume\n",
 		       dev->name);
 		mutex_unlock(&priv->action_mutex);
 		return err;
@@ -6631,8 +6594,8 @@ static int __init ipw2100_init(void)
 {
 	int ret;
 
-	printk(KERN_INFO DRV_NAME ": %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-	printk(KERN_INFO DRV_NAME ": %s\n", DRV_COPYRIGHT);
+	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	pr_info("%s\n", DRV_COPYRIGHT);
 
 	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
 			   PM_QOS_DEFAULT_VALUE);
@@ -8433,10 +8396,8 @@ static int ipw2100_mod_firmware_load(struct ipw2100_fw *fw)
 	    (struct ipw2100_fw_header *)fw->fw_entry->data;
 
 	if (IPW2100_FW_MAJOR(h->version) != IPW2100_FW_MAJOR_VERSION) {
-		printk(KERN_WARNING DRV_NAME ": Firmware image not compatible "
-		       "(detected version id of %u). "
-		       "See Documentation/networking/README.ipw2100\n",
-		       h->version);
+		pr_warn("Firmware image not compatible (detected version id of %u). See Documentation/networking/README.ipw2100\n",
+			h->version);
 		return 1;
 	}
 
@@ -8476,8 +8437,7 @@ static int ipw2100_get_firmware(struct ipw2100_priv *priv,
 	rc = request_firmware(&fw->fw_entry, fw_name, &priv->pci_dev->dev);
 
 	if (rc < 0) {
-		printk(KERN_ERR DRV_NAME ": "
-		       "%s: Firmware '%s' not available or load failed.\n",
+		pr_err("%s: Firmware '%s' not available or load failed\n",
 		       priv->net_dev->name, fw_name);
 		return rc;
 	}
@@ -8562,8 +8522,7 @@ static int ipw2100_fw_download(struct ipw2100_priv *priv, struct ipw2100_fw *fw)
 		firmware_data_left -= 2;
 
 		if (len > 32) {
-			printk(KERN_ERR DRV_NAME ": "
-			       "Invalid firmware run-length of %d bytes\n",
+			pr_err("Invalid firmware run-length of %d bytes\n",
 			       len);
 			return -EINVAL;
 		}
@@ -8674,8 +8633,7 @@ static int ipw2100_ucode_download(struct ipw2100_priv *priv,
 	}
 
 	if (i == 10) {
-		printk(KERN_ERR DRV_NAME ": %s: Error initializing Symbol\n",
-		       dev->name);
+		pr_err("%s: Error initializing Symbol\n", dev->name);
 		return -EIO;
 	}
 
@@ -8692,8 +8650,7 @@ static int ipw2100_ucode_download(struct ipw2100_priv *priv,
 	}
 
 	if (i == 30) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: No response from Symbol - hw not alive\n",
+		pr_err("%s: No response from Symbol - hw not alive\n",
 		       dev->name);
 		printk_buf(IPW_DL_ERROR, (u8 *) & response, sizeof(response));
 		return -EIO;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.h b/drivers/net/wireless/ipw2x00/ipw2100.h
index 9731252..a978791 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.h
+++ b/drivers/net/wireless/ipw2x00/ipw2100.h
@@ -108,8 +108,8 @@ struct ipw2100_rx_packet;
 #define IPW_DL_IO            (1<<26)
 #define IPW_DL_TRACE         (1<<28)
 
-#define IPW_DEBUG_ERROR(f, a...) printk(KERN_ERR DRV_NAME ": " f, ## a)
-#define IPW_DEBUG_WARNING(f, a...) printk(KERN_WARNING DRV_NAME ": " f, ## a)
+#define IPW_DEBUG_ERROR(f, a...) pr_err(f, ## a)
+#define IPW_DEBUG_WARNING(f, a...) pr_warn(f, ## a)
 #define IPW_DEBUG_INFO(f...)    IPW_DEBUG(IPW_DL_INFO, ## f)
 #define IPW_DEBUG_WX(f...)     IPW_DEBUG(IPW_DL_WX, ## f)
 #define IPW_DEBUG_SCAN(f...)   IPW_DEBUG(IPW_DL_SCAN, ## f)
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 254b892..43e2e51 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -30,6 +30,8 @@
 
 ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <net/cfg80211-wext.h>
@@ -1214,8 +1216,7 @@ static ssize_t store_debug_level(struct device_driver *d, const char *buf,
 	} else
 		val = simple_strtoul(p, &p, 10);
 	if (p == buf)
-		printk(KERN_INFO DRV_NAME
-		       ": %s is not in hex or decimal form.\n", buf);
+		pr_info("%s is not in hex or decimal form\n", buf);
 	else
 		ipw_debug_level = val;
 
@@ -5229,8 +5230,8 @@ static void ipw_rx_queue_replenish(void *data)
 		rxb = list_entry(element, struct ipw_rx_mem_buffer, list);
 		rxb->skb = alloc_skb(IPW_RX_BUF_SIZE, GFP_ATOMIC);
 		if (!rxb->skb) {
-			printk(KERN_CRIT "%s: Can not allocate SKB buffers.\n",
-			       priv->net_dev->name);
+			pr_crit("%s: Can not allocate SKB buffers\n",
+				priv->net_dev->name);
 			/* We don't reschedule replenish work here -- we will
 			 * call the restock method and if it still needs
 			 * more buffers it will schedule replenish */
@@ -7795,8 +7796,7 @@ static void ipw_rebuild_decrypted_skb(struct ipw_priv *priv,
 	case SEC_LEVEL_0:
 		break;
 	default:
-		printk(KERN_ERR "Unknown security level %d\n",
-		       priv->ieee->sec.level);
+		pr_err("Unknown security level %d\n", priv->ieee->sec.level);
 		break;
 	}
 }
@@ -8394,7 +8394,7 @@ static void ipw_rx(struct ipw_priv *priv)
 	while (i != r) {
 		rxb = priv->rxq->queue[i];
 		if (unlikely(rxb == NULL)) {
-			printk(KERN_CRIT "Queue not allocated!\n");
+			pr_crit("Queue not allocated!\n");
 			break;
 		}
 		priv->rxq->queue[i] = NULL;
@@ -8666,9 +8666,7 @@ static int ipw_sw_reset(struct ipw_priv *priv, int option)
 	if ((priv->pci_dev->device == 0x4223) ||
 	    (priv->pci_dev->device == 0x4224)) {
 		if (option == 1)
-			printk(KERN_INFO DRV_NAME
-			       ": Detected Intel PRO/Wireless 2915ABG Network "
-			       "Connection\n");
+			pr_info("Detected Intel PRO/Wireless 2915ABG Network Connection\n");
 		priv->ieee->abg_true = 1;
 		band = LIBIPW_52GHZ_BAND | LIBIPW_24GHZ_BAND;
 		modulation = LIBIPW_OFDM_MODULATION |
@@ -8677,9 +8675,7 @@ static int ipw_sw_reset(struct ipw_priv *priv, int option)
 		priv->ieee->mode = IEEE_A | IEEE_G | IEEE_B;
 	} else {
 		if (option == 1)
-			printk(KERN_INFO DRV_NAME
-			       ": Detected Intel PRO/Wireless 2200BG Network "
-			       "Connection\n");
+			pr_info("Detected Intel PRO/Wireless 2200BG Network Connection\n");
 
 		priv->ieee->abg_true = 0;
 		band = LIBIPW_24GHZ_BAND;
@@ -10333,7 +10329,7 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct libipw_txb *txb,
 		case SEC_LEVEL_0:
 			break;
 		default:
-			printk(KERN_ERR "Unknown security level %d\n",
+			pr_err("Unknown security level %d\n",
 			       priv->ieee->sec.level);
 			break;
 		}
@@ -10379,16 +10375,14 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct libipw_txb *txb,
 		for (j = i; j < txb->nr_frags; j++)
 			remaining_bytes += txb->fragments[j]->len - hdr_len;
 
-		printk(KERN_INFO "Trying to reallocate for %d bytes\n",
-		       remaining_bytes);
+		pr_info("Trying to reallocate for %d bytes\n", remaining_bytes);
 		skb = alloc_skb(remaining_bytes, GFP_ATOMIC);
 		if (skb != NULL) {
 			tfd->u.data.chunk_len[i] = cpu_to_le16(remaining_bytes);
 			for (j = i; j < txb->nr_frags; j++) {
 				int size = txb->fragments[j]->len - hdr_len;
 
-				printk(KERN_INFO "Adding frag %d %d...\n",
-				       j, size);
+				pr_info("Adding frag %d %d...\n", j, size);
 				memcpy(skb_put(skb, size),
 				       txb->fragments[j]->data + hdr_len, size);
 			}
@@ -10555,8 +10549,8 @@ static int ipw_net_set_mac_address(struct net_device *dev, void *p)
 	mutex_lock(&priv->mutex);
 	priv->config |= CFG_CUSTOM_MAC;
 	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
-	printk(KERN_INFO "%s: Setting MAC to %pM\n",
-	       priv->net_dev->name, priv->mac_addr);
+	pr_info("%s: Setting MAC to %pM\n",
+		priv->net_dev->name, priv->mac_addr);
 	schedule_work(&priv->adapter_restart);
 	mutex_unlock(&priv->mutex);
 	return 0;
@@ -11770,7 +11764,7 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	if (!err)
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		printk(KERN_WARNING DRV_NAME ": No suitable DMA available.\n");
+		pr_warn("No suitable DMA available\n");
 		goto out_pci_disable_device;
 	}
 
@@ -11876,10 +11870,9 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 	}
 #endif
 
-	printk(KERN_INFO DRV_NAME ": Detected geography %s (%d 802.11bg "
-	       "channels, %d 802.11a channels)\n",
-	       priv->ieee->geo.name, priv->ieee->geo.bg_channels,
-	       priv->ieee->geo.a_channels);
+	pr_info("Detected geography %s (%d 802.11bg channels, %d 802.11a channels)\n",
+		priv->ieee->geo.name, priv->ieee->geo.bg_channels,
+		priv->ieee->geo.a_channels);
 
 	return 0;
 
@@ -11993,7 +11986,7 @@ static int ipw_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct net_device *dev = priv->net_dev;
 
-	printk(KERN_INFO "%s: Going into suspend...\n", dev->name);
+	pr_info("%s: Going into suspend...\n", dev->name);
 
 	/* Take down the device; powers it off, etc. */
 	ipw_down(priv);
@@ -12017,13 +12010,12 @@ static int ipw_pci_resume(struct pci_dev *pdev)
 	int err;
 	u32 val;
 
-	printk(KERN_INFO "%s: Coming out of suspend...\n", dev->name);
+	pr_info("%s: Coming out of suspend...\n", dev->name);
 
 	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
-		       dev->name);
+		pr_err("%s: pci_enable_device failed on resume\n", dev->name);
 		return err;
 	}
 	pci_restore_state(pdev);
@@ -12078,8 +12070,8 @@ static int __init ipw_init(void)
 {
 	int ret;
 
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
-	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
+	pr_info(DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	pr_info(DRV_COPYRIGHT "\n");
 
 	ret = pci_register_driver(&ipw_driver);
 	if (ret) {
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.h b/drivers/net/wireless/ipw2x00/ipw2200.h
index 570d6fb..4fe0811 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.h
+++ b/drivers/net/wireless/ipw2x00/ipw2200.h
@@ -1395,18 +1395,30 @@ BITC(x,19),BITC(x,18),BITC(x,17),BITC(x,16),\
 BIT_ARG16(x)
 
 
-#define IPW_DEBUG(level, fmt, args...) \
-do { if (ipw_debug_level & (level)) \
-  printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
-         in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
+#define IPW_DEBUG(level, fmt, ...)					\
+do {									\
+	if (ipw_debug_level & (level))					\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U', __func__,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 
 #ifdef CONFIG_IPW2200_DEBUG
-#define IPW_LL_DEBUG(level, fmt, args...) \
-do { if (ipw_debug_level & (level)) \
-  printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
-         in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
+#define IPW_LL_DEBUG(level, fmt, ...)					\
+do {									\
+	if (ipw_debug_level & (level))					\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U', __func__,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #else
-#define IPW_LL_DEBUG(level, fmt, args...) do {} while (0)
+#define IPW_LL_DEBUG(level, fmt, ...)					\
+do {									\
+	if (0)								\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U', __func__,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #endif				/* CONFIG_IPW2200_DEBUG */
 
 /*
@@ -1470,10 +1482,10 @@ do { if (ipw_debug_level & (level)) \
 #define IPW_DL_MERGE         (1<<30)
 #define IPW_DL_QOS           (1<<31)
 
-#define IPW_ERROR(f, a...) printk(KERN_ERR DRV_NAME ": " f, ## a)
-#define IPW_WARNING(f, a...) printk(KERN_WARNING DRV_NAME ": " f, ## a)
-#define IPW_DEBUG_INFO(f, a...)    IPW_DEBUG(IPW_DL_INFO, f, ## a)
+#define IPW_ERROR(fmt, ...)		pr_err(fmt, ##__VA_ARGS__)
+#define IPW_WARNING(fmt, ...)		pr_warn(fmt, ##__VA_ARGS__)
 
+#define IPW_DEBUG_INFO(f, a...)   IPW_DEBUG(IPW_DL_INFO, f, ## a)
 #define IPW_DEBUG_WX(f, a...)     IPW_DEBUG(IPW_DL_WX, f, ## a)
 #define IPW_DEBUG_SCAN(f, a...)   IPW_DEBUG(IPW_DL_SCAN, f, ## a)
 #define IPW_DEBUG_TRACE(f, a...)  IPW_LL_DEBUG(IPW_DL_TRACE, f, ## a)
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index 0b22fb4..1b4bfa2 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -62,12 +62,21 @@
 
 #ifdef CONFIG_LIBIPW_DEBUG
 extern u32 libipw_debug_level;
-#define LIBIPW_DEBUG(level, fmt, args...) \
-do { if (libipw_debug_level & (level)) \
-  printk(KERN_DEBUG "libipw: %c %s " fmt, \
-         in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
+#define LIBIPW_DEBUG(level, fmt, ...)					\
+do {									\
+	if (libipw_debug_level & (level))				\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U', __func__ ,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #else
-#define LIBIPW_DEBUG(level, fmt, args...) do {} while (0)
+#define LIBIPW_DEBUG(level, fmt, ...)					\
+do {									\
+	if (0)								\
+		pr_debug("%c %s " fmt,					\
+			 in_interrupt() ? 'I' : 'U', __func__ ,		\
+			 ##__VA_ARGS__);				\
+} while (0)
 #endif				/* CONFIG_LIBIPW_DEBUG */
 
 /*
@@ -108,8 +117,9 @@ do { if (libipw_debug_level & (level)) \
 #define LIBIPW_DL_RX            (1<<9)
 #define LIBIPW_DL_QOS           (1<<31)
 
-#define LIBIPW_ERROR(f, a...) printk(KERN_ERR "libipw: " f, ## a)
-#define LIBIPW_WARNING(f, a...) printk(KERN_WARNING "libipw: " f, ## a)
+#define LIBIPW_ERROR(f, a...) pr_err(f, ## a)
+#define LIBIPW_WARNING(f, a...) pr_warn(f, ## a)
+
 #define LIBIPW_DEBUG_INFO(f, a...)   LIBIPW_DEBUG(LIBIPW_DL_INFO, f, ## a)
 
 #define LIBIPW_DEBUG_WX(f, a...)     LIBIPW_DEBUG(LIBIPW_DL_WX, f, ## a)
diff --git a/drivers/net/wireless/ipw2x00/libipw_geo.c b/drivers/net/wireless/ipw2x00/libipw_geo.c
index c9fe3c9..c3465a6 100644
--- a/drivers/net/wireless/ipw2x00/libipw_geo.c
+++ b/drivers/net/wireless/ipw2x00/libipw_geo.c
@@ -23,6 +23,9 @@
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 ******************************************************************************/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index 3adb240..854298d 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -30,6 +30,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
@@ -269,8 +271,7 @@ static ssize_t debug_level_proc_write(struct file *file,
 		return count;
 	buf[len] = 0;
 	if (sscanf(buf, "%li", &val) != 1)
-		printk(KERN_INFO DRV_NAME
-		       ": %s is not in hex or decimal form.\n", buf);
+		pr_info("%s is not in hex or decimal form\n", buf);
 	else
 		libipw_debug_level = val;
 
@@ -308,8 +309,8 @@ static int __init libipw_init(void)
 	}
 #endif				/* CONFIG_LIBIPW_DEBUG */
 
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
-	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
+	pr_info(DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	pr_info(DRV_COPYRIGHT "\n");
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 02e0579..9d03758 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -13,6 +13,8 @@
  * more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
@@ -172,8 +174,8 @@ libipw_rx_frame_mgmt(struct libipw_device *ieee, struct sk_buff *skb,
 			u16 stype)
 {
 	if (ieee->iw_mode == IW_MODE_MASTER) {
-		printk(KERN_DEBUG "%s: Master mode not yet supported.\n",
-		       ieee->dev->name);
+		pr_debug("%s: Master mode not yet supported\n",
+			 ieee->dev->name);
 		return 0;
 /*
   hostap_update_sta_ps(ieee, (struct hostap_libipw_hdr_4addr *)
@@ -201,9 +203,8 @@ libipw_rx_frame_mgmt(struct libipw_device *ieee, struct sk_buff *skb,
 
 	if (ieee->iw_mode == IW_MODE_MASTER) {
 		if (type != WLAN_FC_TYPE_MGMT && type != WLAN_FC_TYPE_CTRL) {
-			printk(KERN_DEBUG "%s: unknown management frame "
-			       "(type=0x%02x, stype=0x%02x) dropped\n",
-			       skb->dev->name, type, stype);
+			pr_debug("%s: unknown management frame (type=0x%02x, stype=0x%02x) dropped\n",
+				 skb->dev->name, type, stype);
 			return -1;
 		}
 
@@ -211,8 +212,8 @@ libipw_rx_frame_mgmt(struct libipw_device *ieee, struct sk_buff *skb,
 		return 0;
 	}
 
-	printk(KERN_DEBUG "%s: hostap_rx_frame_mgmt: management frame "
-	       "received in non-Host AP mode\n", skb->dev->name);
+	pr_debug("%s: %s: management frame received in non-Host AP mode\n",
+		 __func__, skb->dev->name);
 	return -1;
 }
 #endif
@@ -317,9 +318,8 @@ libipw_rx_frame_decrypt_msdu(struct libipw_device *ieee,
 	res = crypt->ops->decrypt_msdu(skb, keyidx, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
-		       " (SA=%pM keyidx=%d)\n", ieee->dev->name, hdr->addr2,
-		       keyidx);
+		pr_debug("%s: MSDU decryption/MIC verification failed (SA=%pM keyidx=%d)\n",
+			 ieee->dev->name, hdr->addr2, keyidx);
 		return -1;
 	}
 
@@ -355,7 +355,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 
 	hdr = (struct libipw_hdr_4addr *)skb->data;
 	if (skb->len < 10) {
-		printk(KERN_INFO "%s: SKB length < 10\n", dev->name);
+		pr_info("%s: SKB length < 10\n", dev->name);
 		goto rx_dropped;
 	}
 
@@ -367,8 +367,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 	hdrlen = libipw_get_hdrlen(fc);
 
 	if (skb->len < hdrlen) {
-		printk(KERN_INFO "%s: invalid SKB length %d\n",
-			dev->name, skb->len);
+		pr_info("%s: invalid SKB length %d\n", dev->name, skb->len);
 		goto rx_dropped;
 	}
 
@@ -469,8 +468,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 		if (type == WLAN_FC_TYPE_MGMT && stype == WLAN_FC_STYPE_AUTH &&
 		    fc & IEEE80211_FCTL_PROTECTED && ieee->host_decrypt &&
 		    (keyidx = hostap_rx_frame_decrypt(ieee, skb, crypt)) < 0) {
-			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from %pM\n", dev->name, hdr->addr2);
+			pr_debug("%s: failed to decrypt mgmt::auth from %pM\n",
+				 dev->name, hdr->addr2);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -598,9 +597,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 			flen -= hdrlen;
 
 		if (frag_skb->tail + flen > frag_skb->end) {
-			printk(KERN_WARNING "%s: host decrypted and "
-			       "reassembled frame did not fit skb\n",
-			       dev->name);
+			pr_warn("%s: host decrypted and reassembled frame did not fit skb\n",
+				dev->name);
 			libipw_frag_cache_invalidate(ieee, hdr);
 			goto rx_dropped;
 		}
@@ -715,8 +713,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 	 * the received frame. */
 	if (ieee->ieee802_1x && ieee->iw_mode == IW_MODE_MASTER) {
 		if (ethertype == ETH_P_PAE) {
-			printk(KERN_DEBUG "%s: RX: IEEE 802.1X frame\n",
-			       dev->name);
+			pr_debug("%s: RX: IEEE 802.1X frame\n", dev->name);
 			if (ieee->hostapd && ieee->apdev) {
 				/* Send IEEE 802.1X frames to the user
 				 * space daemon for processing */
@@ -727,9 +724,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 				goto rx_exit;
 			}
 		} else if (!frame_authorized) {
-			printk(KERN_DEBUG "%s: dropped frame from "
-			       "unauthorized port (IEEE 802.1X): "
-			       "ethertype=0x%04x\n", dev->name, ethertype);
+			pr_debug("%s: dropped frame from unauthorized port (IEEE 802.1X): ethertype=0x%04x\n",
+				 dev->name, ethertype);
 			goto rx_dropped;
 		}
 	}
@@ -778,8 +774,8 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 			ieee->ap->bridged_multicast++;
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2 == NULL)
-				printk(KERN_DEBUG "%s: skb_clone failed for "
-				       "multicast frame\n", dev->name);
+				pr_debug("%s: skb_clone failed for multicast frame\n",
+					 dev->name);
 		} else if (hostap_is_sta_assoc(ieee->ap, dst)) {
 			/* send frame directly to the associated STA using
 			 * wireless media and not passing to higher layers */
@@ -1277,8 +1273,7 @@ static int libipw_parse_info_param(struct libipw_info_element
 			break;
 
 		case WLAN_EID_QOS_PARAMETER:
-			printk(KERN_ERR
-			       "QoS Error need to parse QOS_PARAMETER IE\n");
+			pr_err("QoS Error need to parse QOS_PARAMETER IE\n");
 			break;
 			/* 802.11h */
 		case WLAN_EID_PWR_CONSTRAINT:
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index e8c0398..a06e081 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -23,6 +23,9 @@
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 ******************************************************************************/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
@@ -168,7 +171,7 @@ static int libipw_encrypt_fragment(struct libipw_device *ieee,
 
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_INFO "%s: Encryption failed: len=%d.\n",
+		pr_info("%s: Encryption failed: len=%d.\n",
 		       ieee->dev->name, frag->len);
 		ieee->ieee_stats.tx_discards++;
 		return -1;
@@ -282,12 +285,12 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* If there is no driver handler to take the TXB, dont' bother
 	 * creating it... */
 	if (!ieee->hard_start_xmit) {
-		printk(KERN_WARNING "%s: No xmit handler.\n", ieee->dev->name);
+		pr_warn("%s: No xmit handler.\n", ieee->dev->name);
 		goto success;
 	}
 
 	if (unlikely(skb->len < SNAP_SIZE + sizeof(u16))) {
-		printk(KERN_WARNING "%s: skb too small (%d).\n",
+		pr_warn("%s: skb too small (%d).\n",
 		       ieee->dev->name, skb->len);
 		goto success;
 	}
@@ -426,7 +429,7 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 	txb = libipw_alloc_txb(nr_frags, frag_size,
 				  ieee->tx_headroom, GFP_ATOMIC);
 	if (unlikely(!txb)) {
-		printk(KERN_WARNING "%s: Could not allocate TXB\n",
+		pr_warn("%s: Could not allocate TXB\n",
 		       ieee->dev->name);
 		goto failed;
 	}
diff --git a/drivers/net/wireless/ipw2x00/libipw_wx.c b/drivers/net/wireless/ipw2x00/libipw_wx.c
index 1571505..631a1a1 100644
--- a/drivers/net/wireless/ipw2x00/libipw_wx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_wx.c
@@ -30,6 +30,8 @@
 
 ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/hardirq.h>
 #include <linux/kmod.h>
 #include <linux/slab.h>
@@ -403,7 +405,7 @@ int libipw_wx_set_encode(struct libipw_device *ieee,
 			kfree(new_crypt);
 			new_crypt = NULL;
 
-			printk(KERN_WARNING "%s: could not initialize WEP: "
+			pr_warn("%s: could not initialize WEP: "
 			       "load module lib80211_crypt_wep\n", dev->name);
 			return -EOPNOTSUPP;
 		}
-- 
1.7.8.111.gad25c.dirty
