From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 28 Mar 2008 22:23:49 -0400
Message-ID: <20080329022349.GA22612@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52697 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756278AbYC2CXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:23:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for net-2.6.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/Kconfig            |    2 +-
 drivers/net/bfin_mac.c         |    2 --
 drivers/net/forcedeth.c        |   18 ++++++++++--------
 drivers/net/ibm_newemac/core.c |    4 ++--
 drivers/net/s2io.c             |    2 +-
 drivers/net/tulip/eeprom.c     |    6 ++++++
 drivers/net/tulip/tulip_core.c |    7 ++++++-
 drivers/net/usb/Kconfig        |    2 +-
 drivers/net/usb/dm9601.c       |    2 +-
 drivers/net/usb/pegasus.c      |    4 ----
 10 files changed, 28 insertions(+), 21 deletions(-)

David Brownell (1):
      drivers/net/usb/pegasus.c: remove in_atomic() check

Grant Grundler (1):
      [netdrvr] tulip_read_eeprom fixes for BUG 4420

Ingo Molnar (1):
      forcedeth: fix locking bug with netconsole

Michael Ellerman (1):
      Make pasemi_mac.c depend on PPC_PASEMI to prevent link errors

Mike Frysinger (2):
      Blackfin EMAC Driver: delete unused variables to fixup gcc warnings
      usb net: asix does not really need 10/100mbit

Peter Korsgaard (1):
      dm9601: Fix multicast hash table handling

Sreenivasa Honnur (1):
      S2io: Version update for Tx completion patch

Valentine Barshak (1):
      ibm_newemac: emac_tx_csum typo fix

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fe7b5ec..3a0b20a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2635,7 +2635,7 @@ config NIU
 
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
-	depends on PPC64 && PCI
+	depends on PPC_PASEMI && PCI
 	select PHYLIB
 	select INET_LRO
 	help
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c993a32..26b2dd5 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -575,7 +575,6 @@ adjust_head:
 static int bf537mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
 	unsigned int data;
 
 	current_tx_ptr->skb = skb;
@@ -634,7 +633,6 @@ out:
 static void bf537mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
-	struct bf537mac_local *lp = netdev_priv(dev);
 	unsigned short len;
 
 	/* allocate a new skb for next time receive */
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6f7e3fd..980c2c2 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1854,6 +1854,7 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ring_desc* start_tx;
 	struct ring_desc* prev_tx;
 	struct nv_skb_map* prev_tx_ctx;
+	unsigned long flags;
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
@@ -1863,10 +1864,10 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
+		spin_lock_irqsave(&np->lock, flags);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1929,13 +1930,13 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
-	spin_lock_irq(&np->lock);
+	spin_lock_irqsave(&np->lock, flags);
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.orig = put_tx;
 
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
 		dev->name, entries, tx_flags_extra);
@@ -1971,6 +1972,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	struct ring_desc_ex* prev_tx;
 	struct nv_skb_map* prev_tx_ctx;
 	struct nv_skb_map* start_tx_ctx;
+	unsigned long flags;
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
@@ -1980,10 +1982,10 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
+		spin_lock_irqsave(&np->lock, flags);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2059,7 +2061,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 			start_tx->txvlan = 0;
 	}
 
-	spin_lock_irq(&np->lock);
+	spin_lock_irqsave(&np->lock, flags);
 
 	if (np->tx_limit) {
 		/* Limit the number of outstanding tx. Setup all fragments, but
@@ -2085,7 +2087,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.ex = put_tx;
 
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	dprintk(KERN_DEBUG "%s: nv_start_xmit_optimized: entries %d queued for transmission. tx_flags_extra: %x\n",
 		dev->name, entries, tx_flags_extra);
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 0789802..378a239 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1242,8 +1242,8 @@ static int emac_close(struct net_device *ndev)
 static inline u16 emac_tx_csum(struct emac_instance *dev,
 			       struct sk_buff *skb)
 {
-	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH &&
-			     skb->ip_summed == CHECKSUM_PARTIAL)) {
+	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH) &&
+		(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		++dev->stats.tx_packets_csum;
 		return EMAC_TX_CTRL_TAH_CSUM;
 	}
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 3c915b8..c082cf0 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-2"
+#define DRV_VERSION "2.0.26.20"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 206918b..da2206f 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -343,6 +343,12 @@ int __devinit tulip_read_eeprom(struct net_device *dev, int location, int addr_l
 	void __iomem *ee_addr = tp->base_addr + CSR9;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
+	/* If location is past the end of what we can address, don't
+	 * read some other location (ie truncate). Just return zero.
+	 */
+	if (location > (1 << addr_len) - 1)
+		return 0;
+
 	iowrite32(EE_ENB & ~EE_CS, ee_addr);
 	iowrite32(EE_ENB, ee_addr);
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index ed600bf..82f404b 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1437,6 +1437,7 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	   EEPROM.
 	   */
 	ee_data = tp->eeprom;
+	memset(ee_data, 0, sizeof(tp->eeprom));
 	sum = 0;
 	if (chip_idx == LC82C168) {
 		for (i = 0; i < 3; i++) {
@@ -1458,8 +1459,12 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		/* A serial EEPROM interface, we read now and sort it out later. */
 		int sa_offset = 0;
 		int ee_addr_size = tulip_read_eeprom(dev, 0xff, 8) & 0x40000 ? 8 : 6;
+		int ee_max_addr = ((1 << ee_addr_size) - 1) * sizeof(u16);
 
-		for (i = 0; i < sizeof(tp->eeprom); i+=2) {
+		if (ee_max_addr > sizeof(tp->eeprom))
+			ee_max_addr = sizeof(tp->eeprom);
+
+		for (i = 0; i < ee_max_addr ; i += sizeof(u16)) {
 			u16 data = tulip_read_eeprom(dev, i/2, ee_addr_size);
 			ee_data[i] = data & 0xff;
 			ee_data[i + 1] = data >> 8;
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index a12c9c4..0604f3f 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -129,7 +129,7 @@ config USB_USBNET
 
 config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
-	depends on USB_USBNET && NET_ETHERNET
+	depends on USB_USBNET
 	select CRC32
 	default y
 	help
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0343b00..01660f6 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -354,7 +354,7 @@ static void dm9601_set_multicast(struct net_device *net)
 		struct dev_mc_list *mc_list = net->mc_list;
 		int i;
 
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc_count; i++, mc_list = mc_list->next) {
 			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index d1ed68a..b588c89 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1128,12 +1128,8 @@ pegasus_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	pegasus_t *pegasus;
 
-	if (in_atomic())
-		return 0;
-
 	pegasus = netdev_priv(dev);
 	mii_ethtool_gset(&pegasus->mii, ecmd);
-
 	return 0;
 }
 
