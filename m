From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 07/18] pcmcia: use pcmica_{read,write}_config_byte
Date: Fri,  6 Aug 2010 00:06:43 +0200
Message-ID: <1281046014-7585-7-git-send-email-linux@dominikbrodowski.net>
References: <20100805220511.GA7040@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-serial@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20100805220511.GA7040@comet.dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pcmcia_read_config_byte and pcmcia_write_config_byte instead
of pcmcia_access_configuration_register.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-serial@vger.kernel.org
CC: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/axnet_cs.c              |    3 +-
 drivers/net/pcmcia/nmclan_cs.c             |   21 ++-----
 drivers/net/pcmcia/xirc2ps_cs.c            |   16 ++---
 drivers/net/wireless/hostap/hostap_cs.c    |   91 ++++++++--------------------
 drivers/net/wireless/orinoco/spectrum_cs.c |   32 +++-------
 drivers/pcmcia/cistpl.c                    |    7 +-
 drivers/pcmcia/cs_internal.h               |    4 +-
 drivers/pcmcia/pcmcia_resource.c           |   72 +++++++++++++---------
 drivers/serial/serial_cs.c                 |    8 +--
 drivers/ssb/pcmcia.c                       |   14 +----
 include/pcmcia/cs.h                        |   12 ----
 include/pcmcia/ds.h                        |    4 +-
 12 files changed, 105 insertions(+), 179 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 467fd4b..ee0a6d0 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -378,8 +378,7 @@ static int axnet_config(struct pcmcia_device *link)
     /* Maybe PHY is in power down mode. (PPD_SET = 1) 
        Bit 2 of CCSR is active low. */ 
     if (i == 32) {
-	conf_reg_t reg = { 0, CS_WRITE, CISREG_CCSR, 0x04 };
- 	pcmcia_access_configuration_register(link, &reg);
+	pcmcia_write_config_byte(link, CISREG_CCSR, 0x04);
 	for (i = 0; i < 32; i++) {
 	    j = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 1);
 	    j2 = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 2);
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c0eacfa..c0d85af 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -757,29 +757,20 @@ static void nmclan_reset(struct net_device *dev)
 
 #if RESET_XILINX
   struct pcmcia_device *link = &lp->link;
-  conf_reg_t reg;
-  u_long OrigCorValue; 
+  u8 OrigCorValue;
 
   /* Save original COR value */
-  reg.Function = 0;
-  reg.Action = CS_READ;
-  reg.Offset = CISREG_COR;
-  reg.Value = 0;
-  pcmcia_access_configuration_register(link, &reg);
-  OrigCorValue = reg.Value;
+  pcmcia_read_config_byte(link, CISREG_COR, &OrigCorValue);
 
   /* Reset Xilinx */
-  reg.Action = CS_WRITE;
-  reg.Offset = CISREG_COR;
-  dev_dbg(&link->dev, "nmclan_reset: OrigCorValue=0x%lX, resetting...\n",
+  dev_dbg(&link->dev, "nmclan_reset: OrigCorValue=0x%x, resetting...\n",
 	OrigCorValue);
-  reg.Value = COR_SOFT_RESET;
-  pcmcia_access_configuration_register(link, &reg);
+  pcmcia_write_config_byte(link, CISREG_COR, COR_SOFT_RESET);
   /* Need to wait for 20 ms for PCMCIA to finish reset. */
 
   /* Restore original COR configuration index */
-  reg.Value = COR_LEVEL_REQ | (OrigCorValue & COR_CONFIG_MASK);
-  pcmcia_access_configuration_register(link, &reg);
+  pcmcia_write_config_byte(link, CISREG_COR,
+			  (COR_LEVEL_REQ | (OrigCorValue & COR_CONFIG_MASK)));
   /* Xilinx is now completely reset along with the MACE chip. */
   lp->tx_free_frames=AM2150_MAX_TX_FRAMES;
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index a7662f0..e3a85ce 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -869,7 +869,6 @@ xirc2ps_config(struct pcmcia_device * link)
 	goto config_error;
 
     if (local->dingo) {
-	conf_reg_t reg;
 	win_req_t req;
 	memreq_t mem;
 
@@ -878,15 +877,14 @@ xirc2ps_config(struct pcmcia_device * link)
 	 * the base address of the ethernet port (BasePort1) is written
 	 * to the BAR registers of the modem.
 	 */
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_IOBASE_0;
-	reg.Value = link->io.BasePort2 & 0xff;
-	if ((err = pcmcia_access_configuration_register(link, &reg)))
+	err = pcmcia_write_config_byte(link, CISREG_IOBASE_0,
+				link->io.BasePort2 & 0xff);
+	if (err)
 	    goto config_error;
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_IOBASE_1;
-	reg.Value = (link->io.BasePort2 >> 8) & 0xff;
-	if ((err = pcmcia_access_configuration_register(link, &reg)))
+
+	err = pcmcia_write_config_byte(link, CISREG_IOBASE_1,
+				(link->io.BasePort2 >> 8) & 0xff);
+	if (err)
 	    goto config_error;
 
 	/* There is no config entry for the Ethernet part which
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 2f4b6d4..6912936 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -224,27 +224,18 @@ static int prism2_pccard_card_present(local_info_t *local)
 static void sandisk_set_iobase(local_info_t *local)
 {
 	int res;
-	conf_reg_t reg;
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
-	reg.Function = 0;
-	reg.Action = CS_WRITE;
-	reg.Offset = 0x10; /* 0x3f0 IO base 1 */
-	reg.Value = hw_priv->link->io.BasePort1 & 0x00ff;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, 0x10,
+				hw_priv->link->io.BasePort1 & 0x00ff);
 	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 0 -"
 		       " res=%d\n", res);
 	}
 	udelay(10);
 
-	reg.Function = 0;
-	reg.Action = CS_WRITE;
-	reg.Offset = 0x12; /* 0x3f2 IO base 2 */
-	reg.Value = (hw_priv->link->io.BasePort1 & 0xff00) >> 8;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, 0x12,
+				(hw_priv->link->io.BasePort1 >> 8) & 0x00ff);
 	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 1 -"
 		       " res=%d\n", res);
@@ -270,7 +261,6 @@ static void sandisk_write_hcr(local_info_t *local, int hcr)
 static int sandisk_enable_wireless(struct net_device *dev)
 {
 	int res, ret = 0;
-	conf_reg_t reg;
 	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
@@ -297,12 +287,8 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	       " - using vendor-specific initialization\n", dev->name);
 	hw_priv->sandisk_connectplus = 1;
 
-	reg.Function = 0;
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_COR;
-	reg.Value = COR_SOFT_RESET;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
+				COR_SOFT_RESET);
 	if (res != 0) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
@@ -310,16 +296,13 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	}
 	mdelay(5);
 
-	reg.Function = 0;
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_COR;
 	/*
 	 * Do not enable interrupts here to avoid some bogus events. Interrupts
 	 * will be enabled during the first cor_sreset call.
 	 */
-	reg.Value = COR_LEVEL_REQ | 0x8 | COR_ADDR_DECODE | COR_FUNC_ENA;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
+				(COR_LEVEL_REQ | 0x8 | COR_ADDR_DECODE |
+					COR_FUNC_ENA));
 	if (res != 0) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
@@ -342,30 +325,23 @@ done:
 static void prism2_pccard_cor_sreset(local_info_t *local)
 {
 	int res;
-	conf_reg_t reg;
+	u8 val;
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
 	if (!prism2_pccard_card_present(local))
 	       return;
 
-	reg.Function = 0;
-	reg.Action = CS_READ;
-	reg.Offset = CISREG_COR;
-	reg.Value = 0;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_read_config_byte(hw_priv->link, CISREG_COR, &val);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 1 (%d)\n",
 		       res);
 		return;
 	}
 	printk(KERN_DEBUG "prism2_pccard_cor_sreset: original COR %02x\n",
-	       reg.Value);
+		val);
 
-	reg.Action = CS_WRITE;
-	reg.Value |= COR_SOFT_RESET;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	val |= COR_SOFT_RESET;
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR, val);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 2 (%d)\n",
 		       res);
@@ -374,11 +350,10 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 
 	mdelay(hw_priv->sandisk_connectplus ? 5 : 2);
 
-	reg.Value &= ~COR_SOFT_RESET;
+	val &= ~COR_SOFT_RESET;
 	if (hw_priv->sandisk_connectplus)
-		reg.Value |= COR_IREQ_ENA;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+		val |= COR_IREQ_ENA;
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR, val);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 3 (%d)\n",
 		       res);
@@ -395,8 +370,7 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 {
 	int res;
-	conf_reg_t reg;
-	int old_cor;
+	u8 old_cor;
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
 	if (!prism2_pccard_card_present(local))
@@ -407,25 +381,17 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 		return;
 	}
 
-	reg.Function = 0;
-	reg.Action = CS_READ;
-	reg.Offset = CISREG_COR;
-	reg.Value = 0;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_read_config_byte(hw_priv->link, CISREG_COR, &old_cor);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 1 "
 		       "(%d)\n", res);
 		return;
 	}
 	printk(KERN_DEBUG "prism2_pccard_genesis_sreset: original COR %02x\n",
-	       reg.Value);
-	old_cor = reg.Value;
+		old_cor);
 
-	reg.Action = CS_WRITE;
-	reg.Value |= COR_SOFT_RESET;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
+				old_cor | COR_SOFT_RESET);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 2 "
 		       "(%d)\n", res);
@@ -435,11 +401,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	mdelay(10);
 
 	/* Setup Genesis mode */
-	reg.Action = CS_WRITE;
-	reg.Value = hcr;
-	reg.Offset = CISREG_CCSR;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_CCSR, hcr);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 3 "
 		       "(%d)\n", res);
@@ -447,11 +409,8 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	}
 	mdelay(10);
 
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_COR;
-	reg.Value = old_cor & ~COR_SOFT_RESET;
-	res = pcmcia_access_configuration_register(hw_priv->link,
-						   &reg);
+	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
+				old_cor & ~COR_SOFT_RESET);
 	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 4 "
 		       "(%d)\n", res);
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index cad30e4..39399cd 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -79,35 +79,27 @@ static int
 spectrum_reset(struct pcmcia_device *link, int idle)
 {
 	int ret;
-	conf_reg_t reg;
-	u_int save_cor;
+	u8 save_cor;
+	u8 ccsr;
 
 	/* Doing it if hardware is gone is guaranteed crash */
 	if (!pcmcia_dev_present(link))
 		return -ENODEV;
 
 	/* Save original COR value */
-	reg.Function = 0;
-	reg.Action = CS_READ;
-	reg.Offset = CISREG_COR;
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_read_config_byte(link, CISREG_COR, &save_cor);
 	if (ret)
 		goto failed;
-	save_cor = reg.Value;
 
 	/* Soft-Reset card */
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_COR;
-	reg.Value = (save_cor | COR_SOFT_RESET);
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_write_config_byte(link, CISREG_COR,
+				(save_cor | COR_SOFT_RESET));
 	if (ret)
 		goto failed;
 	udelay(1000);
 
 	/* Read CCSR */
-	reg.Action = CS_READ;
-	reg.Offset = CISREG_CCSR;
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_read_config_byte(link, CISREG_CCSR, &ccsr);
 	if (ret)
 		goto failed;
 
@@ -115,19 +107,15 @@ spectrum_reset(struct pcmcia_device *link, int idle)
 	 * Start or stop the firmware.  Memory width bit should be
 	 * preserved from the value we've just read.
 	 */
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_CCSR;
-	reg.Value = (idle ? HCR_IDLE : HCR_RUN) | (reg.Value & HCR_MEM16);
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ccsr = (idle ? HCR_IDLE : HCR_RUN) | (ccsr & HCR_MEM16);
+	ret = pcmcia_write_config_byte(link, CISREG_CCSR, ccsr);
 	if (ret)
 		goto failed;
 	udelay(1000);
 
 	/* Restore original COR configuration index */
-	reg.Action = CS_WRITE;
-	reg.Offset = CISREG_COR;
-	reg.Value = (save_cor & ~COR_SOFT_RESET);
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_write_config_byte(link, CISREG_COR,
+				(save_cor & ~COR_SOFT_RESET));
 	if (ret)
 		goto failed;
 	udelay(1000);
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index ba4a5ac..1733fab 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -209,7 +209,7 @@ int pcmcia_read_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
  * Probably only useful for writing one-byte registers. Must be called
  * with ops_mutex held.
  */
-void pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
+int pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
 		   u_int len, void *ptr)
 {
 	void __iomem *sys, *end;
@@ -231,7 +231,7 @@ void pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
 				((cis_width) ? MAP_16BIT : 0));
 		if (!sys) {
 			dev_dbg(&s->dev, "could not map memory\n");
-			return; /* FIXME: Error */
+			return -EINVAL;
 		}
 
 		writeb(flags, sys+CISREG_ICTRL0);
@@ -256,7 +256,7 @@ void pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
 			sys = set_cis_map(s, card_offset, flags);
 			if (!sys) {
 				dev_dbg(&s->dev, "could not map memory\n");
-				return; /* FIXME: error */
+				return -EINVAL;
 			}
 
 			end = sys + s->map_size;
@@ -270,6 +270,7 @@ void pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr, u_int addr,
 			addr = 0;
 		}
 	}
+	return 0;
 }
 
 
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 45e7fd1..cebd40d 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -158,8 +158,8 @@ extern struct bin_attribute pccard_cis_attr;
 
 int pcmcia_read_cis_mem(struct pcmcia_socket *s, int attr,
 			u_int addr, u_int len, void *ptr);
-void pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr,
-			  u_int addr, u_int len, void *ptr);
+int pcmcia_write_cis_mem(struct pcmcia_socket *s, int attr,
+			u_int addr, u_int len, void *ptr);
 void release_cis_mem(struct pcmcia_socket *s);
 void destroy_cis_cache(struct pcmcia_socket *s);
 int pccard_read_tuple(struct pcmcia_socket *s, unsigned int function,
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 2394de4..563750e 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -108,25 +108,25 @@ static void release_io_space(struct pcmcia_socket *s, unsigned int base,
 } /* release_io_space */
 
 
-/** pccard_access_configuration_register
+/**
+ * pcmcia_access_config() - read or write card configuration registers
  *
- * Access_configuration_register() reads and writes configuration
- * registers in attribute memory.  Memory window 0 is reserved for
- * this and the tuple reading services.
+ * pcmcia_access_config() reads and writes configuration registers in
+ * attribute memory.  Memory window 0 is reserved for this and the tuple
+ * reading services. Drivers must use pcmcia_read_config_byte() or
+ * pcmcia_write_config_byte().
  */
-
-int pcmcia_access_configuration_register(struct pcmcia_device *p_dev,
-					 conf_reg_t *reg)
+static int pcmcia_access_config(struct pcmcia_device *p_dev,
+				off_t where, u8 *val,
+				int (*accessf) (struct pcmcia_socket *s,
+						int attr, unsigned int addr,
+						unsigned int len, void *ptr))
 {
 	struct pcmcia_socket *s;
 	config_t *c;
 	int addr;
-	u_char val;
 	int ret = 0;
 
-	if (!p_dev || !p_dev->function_config)
-		return -EINVAL;
-
 	s = p_dev->socket;
 
 	mutex_lock(&s->ops_mutex);
@@ -138,26 +138,40 @@ int pcmcia_access_configuration_register(struct pcmcia_device *p_dev,
 		return -EACCES;
 	}
 
-	addr = (c->ConfigBase + reg->Offset) >> 1;
+	addr = (c->ConfigBase + where) >> 1;
+
+	ret = accessf(s, 1, addr, 1, val);
 
-	switch (reg->Action) {
-	case CS_READ:
-		ret = pcmcia_read_cis_mem(s, 1, addr, 1, &val);
-		reg->Value = val;
-		break;
-	case CS_WRITE:
-		val = reg->Value;
-		pcmcia_write_cis_mem(s, 1, addr, 1, &val);
-		break;
-	default:
-		dev_dbg(&s->dev, "Invalid conf register request\n");
-		ret = -EINVAL;
-		break;
-	}
 	mutex_unlock(&s->ops_mutex);
+
 	return ret;
-} /* pcmcia_access_configuration_register */
-EXPORT_SYMBOL(pcmcia_access_configuration_register);
+} /* pcmcia_access_config */
+
+
+/**
+ * pcmcia_read_config_byte() - read a byte from a card configuration register
+ *
+ * pcmcia_read_config_byte() reads a byte from a configuration register in
+ * attribute memory.
+ */
+int pcmcia_read_config_byte(struct pcmcia_device *p_dev, off_t where, u8 *val)
+{
+	return pcmcia_access_config(p_dev, where, val, pcmcia_read_cis_mem);
+}
+EXPORT_SYMBOL(pcmcia_read_config_byte);
+
+
+/**
+ * pcmcia_write_config_byte() - write a byte to a card configuration register
+ *
+ * pcmcia_write_config_byte() writes a byte to a configuration register in
+ * attribute memory.
+ */
+int pcmcia_write_config_byte(struct pcmcia_device *p_dev, off_t where, u8 val)
+{
+	return pcmcia_access_config(p_dev, where, &val, pcmcia_write_cis_mem);
+}
+EXPORT_SYMBOL(pcmcia_write_config_byte);
 
 
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 2b99c7b..2be8b10 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -114,16 +114,14 @@ static void quirk_setup_brainboxes_0104(struct pcmcia_device *link, struct uart_
 
 static int quirk_post_ibm(struct pcmcia_device *link)
 {
-	conf_reg_t reg = { 0, CS_READ, 0x800, 0 };
+	u8 val;
 	int ret;
 
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_read_config_byte(link, 0x800, &val);
 	if (ret)
 		goto failed;
 
-	reg.Action = CS_WRITE;
-	reg.Value = reg.Value | 1;
-	ret = pcmcia_access_configuration_register(link, &reg);
+	ret = pcmcia_write_config_byte(link, 0x800, val | 1);
 	if (ret)
 		goto failed;
 	return 0;
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index 2152030..526682d 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -71,14 +71,9 @@
 /* Write to a PCMCIA configuration register. */
 static int ssb_pcmcia_cfg_write(struct ssb_bus *bus, u8 offset, u8 value)
 {
-	conf_reg_t reg;
 	int res;
 
-	memset(&reg, 0, sizeof(reg));
-	reg.Offset = offset;
-	reg.Action = CS_WRITE;
-	reg.Value = value;
-	res = pcmcia_access_configuration_register(bus->host_pcmcia, &reg);
+	res = pcmcia_write_config_byte(bus->host_pcmcia, offset, value);
 	if (unlikely(res != 0))
 		return -EBUSY;
 
@@ -88,16 +83,11 @@ static int ssb_pcmcia_cfg_write(struct ssb_bus *bus, u8 offset, u8 value)
 /* Read from a PCMCIA configuration register. */
 static int ssb_pcmcia_cfg_read(struct ssb_bus *bus, u8 offset, u8 *value)
 {
-	conf_reg_t reg;
 	int res;
 
-	memset(&reg, 0, sizeof(reg));
-	reg.Offset = offset;
-	reg.Action = CS_READ;
-	res = pcmcia_access_configuration_register(bus->host_pcmcia, &reg);
+	res = pcmcia_read_config_byte(bus->host_pcmcia, offset, value);
 	if (unlikely(res != 0))
 		return -EBUSY;
-	*value = reg.Value;
 
 	return 0;
 }
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index c78d9b1..64e853d 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -19,18 +19,6 @@
 #include <linux/interrupt.h>
 #endif
 
-/* For AccessConfigurationRegister */
-typedef struct conf_reg_t {
-    u_char	Function;
-    u_int	Action;
-    off_t	Offset;
-    u_int	Value;
-} conf_reg_t;
-
-/* Actions */
-#define CS_READ		1
-#define CS_WRITE	2
-
 /* for AdjustResourceInfo */
 /* Action field */
 #define REMOVE_MANAGED_RESOURCE		1
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index e614aa0..d494ce4 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -174,8 +174,8 @@ struct pcmcia_device *pcmcia_dev_present(struct pcmcia_device *p_dev);
 int pcmcia_reset_card(struct pcmcia_socket *skt);
 
 /* CIS config */
-int pcmcia_access_configuration_register(struct pcmcia_device *p_dev,
-					 conf_reg_t *reg);
+int pcmcia_read_config_byte(struct pcmcia_device *p_dev, off_t where, u8 *val);
+int pcmcia_write_config_byte(struct pcmcia_device *p_dev, off_t where, u8 val);
 
 /* device configuration */
 int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req);
-- 
1.7.0.4

