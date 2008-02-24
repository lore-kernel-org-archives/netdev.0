From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes (50% rebased)
Date: Sun, 24 Feb 2008 00:20:41 -0500
Message-ID: <20080224052041.GA16773@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:60635 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbYBXFUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 00:20:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a 50% resend, rebased on top of net-2.6.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 MAINTAINERS                        |   11 +-
 drivers/net/cs89x0.c               |   12 +-
 drivers/net/e1000e/82571.c         |   22 +--
 drivers/net/e1000e/defines.h       |   10 +-
 drivers/net/e1000e/e1000.h         |    3 +-
 drivers/net/e1000e/hw.h            |    4 +-
 drivers/net/e1000e/ich8lan.c       |   24 ++--
 drivers/net/e1000e/lib.c           |   50 ++-----
 drivers/net/e1000e/netdev.c        |   18 ++--
 drivers/net/e1000e/phy.c           |   10 +-
 drivers/net/ehea/ehea.h            |   34 +++++-
 drivers/net/ehea/ehea_main.c       |  281 +++++++++++++++++++++++++++++++++---
 drivers/net/fs_enet/fs_enet-main.c |    7 +-
 drivers/net/gianfar.c              |   14 +-
 drivers/net/igb/igb_main.c         |   15 +--
 drivers/net/ixgb/ixgb_ethtool.c    |    1 +
 drivers/net/macb.c                 |    2 +-
 drivers/net/pcmcia/pcnet_cs.c      |   10 +-
 drivers/net/phy/mdio_bus.c         |    4 +-
 drivers/net/sis190.c               |   15 ++-
 drivers/net/sky2.c                 |  123 ++++++++--------
 drivers/net/sky2.h                 |   27 ++--
 drivers/net/tlan.c                 |   64 ++++----
 drivers/net/tulip/uli526x.c        |   12 ++-
 drivers/net/via-rhine.c            |    2 +-
 drivers/net/virtio_net.c           |    2 +-
 drivers/s390/net/claw.c            |   39 +++---
 27 files changed, 531 insertions(+), 285 deletions(-)

Adrian Bunk (1):
      net/phy/mdio_bus.c: fix a check-after-use

Andy Gospodarek (1):
      igb: fix legacy mode irq issue

Atsushi Nemoto (1):
      macb: Fix speed setting

Auke Kok (4):
      ixgb: add RNBC counter - no buffer count - to ethtool stats
      e1000e: 82573 can use eerd method to read eeprom
      e1000e: fix spelling errors in comments
      e1000e: remove unused read value in ASPM disable code.

Becky Bruce (1):
      gianfar: don't pass NULL dev ptr to DMA ops

Bill Hayes (1):
      igb: Fix panic with NICs with 1000BASE-SX PHY

Christian Borntraeger (1):
      virtio_net: Fix oops on early interrupts - introduced by virtio reset code

Francois Romieu (1):
      sis190: read the mac address from the eeprom first

Grant Grundler (2):
      update TULIP MAINTAINERS
      uli526x partially recognizing interface

Harvey Harrison (1):
      tlan: add static to function definitions

Jesse Brandeburg (3):
      e1000e: fix link up message to show ethX:
      e1000e: fix flow control when using ethtool overrides
      e1000e: fix flow control denial of service possibility

Julia Lawall (1):
      claw: make use of DIV_ROUND_UP

Komuro (1):
      pcnet_cs: if AX88190-based card, printk "use axnet_cs instead" message.

Laura Garcia (1):
      [netdrvr] via-rhine: Use register offset definition for WOLcgClr

Leonardo Potenza (1):
      drivers/net/cs89x0.c: compilation warning fix

Scott Wood (1):
      fs_enet: Don't call phy_mii_ioctl() in atomic context.

Stephen Hemminger (1):
      sky2: fix LED management

Thomas Klein (1):
      ehea: add kdump support

diff --git a/MAINTAINERS b/MAINTAINERS
index 36c7bc6..2333255 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3884,10 +3884,13 @@ M:	trivial@kernel.org
 L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
-TULIP NETWORK DRIVER
-L:	tulip-users@lists.sourceforge.net
-W:	http://sourceforge.net/projects/tulip/
-S:	Orphan
+TULIP NETWORK DRIVERS
+P:	Grant Grundler
+M:	grundler@parisc-linux.org
+P:	Kyle McMartin
+M:	kyle@parisc-linux.org
+L:	netdev@vger.kernel.org
+S:	Maintained
 
 TUN/TAP driver
 P:	Maxim Krasnyansky
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 5717509..348371f 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -172,30 +172,30 @@ static char version[] __initdata =
    them to system IRQ numbers. This mapping is card specific and is set to
    the configuration of the Cirrus Eval board for this chip. */
 #ifdef CONFIG_ARCH_CLPS7500
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x80090303, 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
 static unsigned int cs8900_irq_map[] = {12,0,0,0};
 #elif defined(CONFIG_SH_HICOSH4)
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x0300, 0};
 static unsigned int cs8900_irq_map[] = {1,0,0,0};
 #elif defined(CONFIG_MACH_IXDP2351)
-static unsigned int netcard_portlist[] __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #include <asm/irq.h>
 #elif defined(CONFIG_ARCH_IXDP2X01)
 #include <asm/irq.h>
-static unsigned int netcard_portlist[] __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_PNX010X)
 #include <asm/irq.h>
 #include <asm/arch/gpio.h>
 #define CIRRUS_DEFAULT_BASE	IO_ADDRESS(EXT_STATIC2_s0_BASE + 0x200000)	/* = Physical address 0x48200000 */
 #define CIRRUS_DEFAULT_IRQ	VH_INTC_INT_NUM_CASCADED_INTERRUPT_1 /* Event inputs bank 1 - ID 35/bit 3 */
-static unsigned int netcard_portlist[] __initdata = {CIRRUS_DEFAULT_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {CIRRUS_DEFAULT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
 #else
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
 static unsigned int cs8900_irq_map[] = {10,11,12,5};
 #endif
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 3beace5..7fe2031 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -438,7 +438,7 @@ static void e1000_release_nvm_82571(struct e1000_hw *hw)
  *  For non-82573 silicon, write data to EEPROM at offset using SPI interface.
  *
  *  If e1000e_update_nvm_checksum is not called after this function, the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_82571(struct e1000_hw *hw, u16 offset, u16 words,
 				 u16 *data)
@@ -547,7 +547,7 @@ static s32 e1000_validate_nvm_checksum_82571(struct e1000_hw *hw)
  *  poll for completion.
  *
  *  If e1000e_update_nvm_checksum is not called after this function, the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 				      u16 words, u16 *data)
@@ -1053,7 +1053,7 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 		/* If SerDes loopback mode is entered, there is no form
 		 * of reset to take the adapter out of that mode.  So we
 		 * have to explicitly take the adapter out of loopback
-		 * mode.  This prevents drivers from twidling their thumbs
+		 * mode.  This prevents drivers from twiddling their thumbs
 		 * if another tool failed to take it out of loopback mode.
 		 */
 		ew32(SCTL,
@@ -1098,7 +1098,7 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
  *  e1000e_get_laa_state_82571 - Get locally administered address state
  *  @hw: pointer to the HW structure
  *
- *  Retrieve and return the current locally administed address state.
+ *  Retrieve and return the current locally administered address state.
  **/
 bool e1000e_get_laa_state_82571(struct e1000_hw *hw)
 {
@@ -1113,7 +1113,7 @@ bool e1000e_get_laa_state_82571(struct e1000_hw *hw)
  *  @hw: pointer to the HW structure
  *  @state: enable/disable locally administered address
  *
- *  Enable/Disable the current locally administed address state.
+ *  Enable/Disable the current locally administers address state.
  **/
 void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state)
 {
@@ -1281,16 +1281,6 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_82571,
-	.read_nvm		= e1000e_read_nvm_spi,
-	.release_nvm		= e1000_release_nvm_82571,
-	.update_nvm		= e1000_update_nvm_checksum_82571,
-	.valid_led_default	= e1000_valid_led_default_82571,
-	.validate_nvm		= e1000_validate_nvm_checksum_82571,
-	.write_nvm		= e1000_write_nvm_82571,
-};
-
-static struct e1000_nvm_operations e82573_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_nvm_82571,
 	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_82571,
 	.update_nvm		= e1000_update_nvm_checksum_82571,
@@ -1355,6 +1345,6 @@ struct e1000_info e1000_82573_info = {
 	.get_invariants		= e1000_get_invariants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_m88,
-	.nvm_ops		= &e82573_nvm_ops,
+	.nvm_ops		= &e82571_nvm_ops,
 };
 
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 6232c3e..a4f511f 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -66,7 +66,7 @@
 #define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
 /* Extended Device Control */
-#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
+#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
@@ -75,12 +75,12 @@
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 
-/* Receive Decriptor bit definitions */
+/* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
 #define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_ERR_CE        0x01    /* CRC Error */
 #define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
@@ -223,7 +223,7 @@
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
 
-/* Constants used to intrepret the masked PCI-X bus speed. */
+/* Constants used to interpret the masked PCI-X bus speed. */
 
 #define HALF_DUPLEX 1
 #define FULL_DUPLEX 2
@@ -517,7 +517,7 @@
 /* PHY 1000 MII Register/Bit Definitions */
 /* PHY Registers defined by IEEE */
 #define PHY_CONTROL      0x00 /* Control Register */
-#define PHY_STATUS       0x01 /* Status Regiser */
+#define PHY_STATUS       0x01 /* Status Register */
 #define PHY_ID1          0x02 /* Phy Id Reg (word 1) */
 #define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
 #define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 8b88c22..327c062 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -42,8 +42,7 @@
 struct e1000_info;
 
 #define ndev_printk(level, netdev, format, arg...) \
-	printk(level "%s: %s: " format, (netdev)->dev.parent->bus_id, \
-	       (netdev)->name, ## arg)
+	printk(level "%s: " format, (netdev)->name, ## arg)
 
 #ifdef DEBUG
 #define ndev_dbg(netdev, format, arg...) \
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 3c5862f..916025b 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -184,7 +184,7 @@ enum e1e_registers {
 	E1000_ICRXDMTC = 0x04120, /* Irq Cause Rx Desc MinThreshold Count */
 	E1000_ICRXOC   = 0x04124, /* Irq Cause Receiver Overrun Count */
 	E1000_RXCSUM   = 0x05000, /* RX Checksum Control - RW */
-	E1000_RFCTL    = 0x05008, /* Receive Filter Control*/
+	E1000_RFCTL    = 0x05008, /* Receive Filter Control */
 	E1000_MTA      = 0x05200, /* Multicast Table Array - RW Array */
 	E1000_RA       = 0x05400, /* Receive Address - RW Array */
 	E1000_VFTA     = 0x05600, /* VLAN Filter Table Array - RW Array */
@@ -202,7 +202,7 @@ enum e1e_registers {
 	E1000_FACTPS    = 0x05B30, /* Function Active and Power State to MNG */
 	E1000_SWSM      = 0x05B50, /* SW Semaphore */
 	E1000_FWSM      = 0x05B54, /* FW Semaphore */
-	E1000_HICR      = 0x08F00, /* Host Inteface Control */
+	E1000_HICR      = 0x08F00, /* Host Interface Control */
 };
 
 /* RSS registers */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8f8139d..0ae3955 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -671,7 +671,7 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
  *  e1000_check_polarity_ife_ich8lan - Check cable polarity for IFE PHY
  *  @hw: pointer to the HW structure
  *
- *  Polarity is determined on the polarity reveral feature being enabled.
+ *  Polarity is determined on the polarity reversal feature being enabled.
  *  This function is only called by other family-specific
  *  routines.
  **/
@@ -947,7 +947,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	/* Either we should have a hardware SPI cycle in progress
 	 * bit to check against, in order to start a new cycle or
 	 * FDONE bit should be changed in the hardware so that it
-	 * is 1 after harware reset, which can then be used as an
+	 * is 1 after hardware reset, which can then be used as an
 	 * indication whether a cycle is in progress or has been
 	 * completed.
 	 */
@@ -1155,7 +1155,7 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
  *  which writes the checksum to the shadow ram.  The changes in the shadow
  *  ram are then committed to the EEPROM by processing each bank at a time
  *  checking for the modified bit and writing only the pending changes.
- *  After a succesful commit, the shadow ram is cleared and is ready for
+ *  After a successful commit, the shadow ram is cleared and is ready for
  *  future writes.
  **/
 static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
@@ -1680,7 +1680,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
  *   - initialize LED identification
  *   - setup receive address registers
  *   - setup flow control
- *   - setup transmit discriptors
+ *   - setup transmit descriptors
  *   - clear statistics
  **/
 static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
@@ -1961,7 +1961,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 		     E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 	ew32(PHY_CTRL, phy_ctrl);
 
-	/* Call gig speed drop workaround on Giga disable before accessing
+	/* Call gig speed drop workaround on Gig disable before accessing
 	 * any PHY registers */
 	e1000e_gig_downshift_workaround_ich8lan(hw);
 
@@ -1972,7 +1972,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 /**
  *  e1000_set_kmrn_lock_loss_workaound_ich8lan - Set Kumeran workaround state
  *  @hw: pointer to the HW structure
- *  @state: boolean value used to set the current Kumaran workaround state
+ *  @state: boolean value used to set the current Kumeran workaround state
  *
  *  If ICH8, set the current Kumeran workaround state (enabled - TRUE
  *  /disabled - FALSE).
@@ -2017,7 +2017,7 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 			E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 		ew32(PHY_CTRL, reg);
 
-		/* Call gig speed drop workaround on Giga disable before
+		/* Call gig speed drop workaround on Gig disable before
 		 * accessing any PHY registers */
 		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
@@ -2045,7 +2045,7 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
  *  @hw: pointer to the HW structure
  *
  *  Steps to take when dropping from 1Gb/s (eg. link cable removal (LSC),
- *  LPLU, Giga disable, MDIC PHY reset):
+ *  LPLU, Gig disable, MDIC PHY reset):
  *    1) Set Kumeran Near-end loopback
  *    2) Clear Kumeran Near-end loopback
  *  Should only be called for ICH8[m] devices with IGP_3 Phy.
@@ -2089,10 +2089,10 @@ static s32 e1000_cleanup_led_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_on_ich8lan - Turn LED's on
+ *  e1000_led_on_ich8lan - Turn LEDs on
  *  @hw: pointer to the HW structure
  *
- *  Turn on the LED's.
+ *  Turn on the LEDs.
  **/
 static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
 {
@@ -2105,10 +2105,10 @@ static s32 e1000_led_on_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_off_ich8lan - Turn LED's off
+ *  e1000_led_off_ich8lan - Turn LEDs off
  *  @hw: pointer to the HW structure
  *
- *  Turn off the LED's.
+ *  Turn off the LEDs.
  **/
 static s32 e1000_led_off_ich8lan(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 16f35fa..95f75a4 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -589,9 +589,6 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 nvm_data;
 
-	if (mac->fc != e1000_fc_default)
-		return 0;
-
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
 	 * a bit that determines whether the HW defaults to enabling or
@@ -1107,34 +1104,13 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			mac->fc = e1000_fc_rx_pause;
 			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
-		}
-		/* Per the IEEE spec, at this point flow control should be
-		 * disabled.  However, we want to consider that we could
-		 * be connected to a legacy switch that doesn't advertise
-		 * desired flow control, but can be forced on the link
-		 * partner.  So if we advertised no flow control, that is
-		 * what we will resolve to.  If we advertised some kind of
-		 * receive capability (Rx Pause Only or Full Flow Control)
-		 * and the link partner advertised none, we will configure
-		 * ourselves to enable Rx Flow Control only.  We can do
-		 * this safely for two reasons:  If the link partner really
-		 * didn't want flow control enabled, and we enable Rx, no
-		 * harm done since we won't be receiving any PAUSE frames
-		 * anyway.  If the intent on the link partner was to have
-		 * flow control enabled, then by us enabling RX only, we
-		 * can at least receive pause frames and process them.
-		 * This is a good idea because in most cases, since we are
-		 * predominantly a server NIC, more times than not we will
-		 * be asked to delay transmission of packets than asking
-		 * our link partner to pause transmission of frames.
-		 */
-		else if ((mac->original_fc == e1000_fc_none) ||
-			 (mac->original_fc == e1000_fc_tx_pause)) {
+		} else {
+			/*
+			 * Per the IEEE spec, at this point flow control
+			 * should be disabled.
+			 */
 			mac->fc = e1000_fc_none;
 			hw_dbg(hw, "Flow Control = NONE.\r\n");
-		} else {
-			mac->fc = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
 		}
 
 		/* Now we need to do one last check...  If we auto-
@@ -1164,7 +1140,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_get_speed_and_duplex_copper - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_copper - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1200,7 +1176,7 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
 }
 
 /**
- *  e1000e_get_speed_and_duplex_fiber_serdes - Retreive current speed/duplex
+ *  e1000e_get_speed_and_duplex_fiber_serdes - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1410,7 +1386,7 @@ s32 e1000e_cleanup_led_generic(struct e1000_hw *hw)
  *  e1000e_blink_led - Blink LED
  *  @hw: pointer to the HW structure
  *
- *  Blink the led's which are set to be on.
+ *  Blink the LEDs which are set to be on.
  **/
 s32 e1000e_blink_led(struct e1000_hw *hw)
 {
@@ -1515,7 +1491,7 @@ void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  *  @hw: pointer to the HW structure
  *
  *  Returns 0 if successful, else returns -10
- *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not casued
+ *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not caused
  *  the master requests to be disabled.
  *
  *  Disables PCI-Express master access and verifies there are no pending
@@ -1876,7 +1852,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_read_nvm_spi - Read EEPROM's using SPI
+ *  e1000e_read_nvm_spi - Reads EEPROM using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -1980,7 +1956,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
  *  Writes data to EEPROM at offset using SPI interface.
  *
  *  If e1000e_update_nvm_checksum is not called after this function , the
- *  EEPROM will most likley contain an invalid checksum.
+ *  EEPROM will most likely contain an invalid checksum.
  **/
 s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
@@ -2222,7 +2198,7 @@ static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
  *
  *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
  *
- *  This function checks whether the HOST IF is enabled for command operaton
+ *  This function checks whether the HOST IF is enabled for command operation
  *  and also checks whether the previous command is completed.  It busy waits
  *  in case of previous command is not completed.
  **/
@@ -2254,7 +2230,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_check_mng_mode - check managament mode
+ *  e1000e_check_mng_mode - check management mode
  *  @hw: pointer to the HW structure
  *
  *  Reads the firmware semaphore register and returns true (>0) if
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3031d6d..fc5c63f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1006,7 +1006,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
  * e1000_get_hw_control - get control of the h/w from f/w
  * @adapter: address of board private structure
  *
- * e1000_get_hw_control sets {CTRL_EXT|FWSM}:DRV_LOAD bit.
+ * e1000_get_hw_control sets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that
  * the driver is loaded. For AMT version (only with 82573)
  * of the f/w this means that the network i/f is open.
@@ -1032,7 +1032,7 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
  * e1000_release_hw_control - release control of the h/w to f/w
  * @adapter: address of board private structure
  *
- * e1000_release_hw_control resets {CTRL_EXT|FWSM}:DRV_LOAD bit.
+ * e1000_release_hw_control resets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that the
  * driver is no longer loaded. For AMT version (only with 82573) i
  * of the f/w this means that the network i/f is closed.
@@ -1241,6 +1241,11 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 
 /**
  * e1000_update_itr - update the dynamic ITR value based on statistics
+ * @adapter: pointer to adapter
+ * @itr_setting: current adapter->itr
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ *
  *      Stores a new ITR value based on packets and byte
  *      counts during the last interrupt.  The advantage of per interrupt
  *      computation is faster updates and more accurate ITR for the current
@@ -1250,10 +1255,6 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
  *      while increasing bulk throughput.
  *      this functionality is controlled by the InterruptThrottleRate module
  *      parameter (see e1000_param.c)
- * @adapter: pointer to adapter
- * @itr_setting: current adapter->itr
- * @packets: the number of packets during this measurement interval
- * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 				     u16 itr_setting, int packets,
@@ -1366,6 +1367,7 @@ set_itr_now:
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
+ * @budget: amount of packets driver is allowed to process this poll
  **/
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
@@ -2000,7 +2002,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	    e1000_check_reset_block(hw))
 		return;
 
-	/* managebility (AMT) is enabled */
+	/* manageability (AMT) is enabled */
 	if (er32(MANC) & E1000_MANC_SMBUS_EN)
 		return;
 
@@ -3488,7 +3490,6 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 {
 	int pos;
-	u32 cap;
 	u16 val;
 
 	/*
@@ -3503,7 +3504,6 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 	 * active.
 	 */
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	pci_read_config_dword(pdev, pos + PCI_EXP_LNKCAP, &cap);
 	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
 	if (val & 0x2) {
 		dev_warn(&pdev->dev, "Disabling L1 ASPM\n");
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index fc6fee1..dab3c46 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -121,7 +121,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
  *  @offset: register offset to be read
  *  @data: pointer to the read data
  *
- *  Reads the MDI control regsiter in the PHY at offset and stores the
+ *  Reads the MDI control register in the PHY at offset and stores the
  *  information read to data.
  **/
 static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
@@ -1172,7 +1172,7 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 }
 
 /**
- *  e1000e_check_downshift - Checks whether a downshift in speed occured
+ *  e1000e_check_downshift - Checks whether a downshift in speed occurred
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns 1
@@ -1388,8 +1388,8 @@ s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
  *  received signal, adjusting for the attenuation produced by the
- *  cable.  By reading the AGC registers, which reperesent the
- *  cobination of course and fine gain value, the value can be put
+ *  cable.  By reading the AGC registers, which represent the
+ *  combination of course and fine gain value, the value can be put
  *  into a lookup table to obtain the approximate cable length
  *  for each channel.
  **/
@@ -1619,7 +1619,7 @@ s32 e1000e_phy_sw_reset(struct e1000_hw *hw)
  *  Verify the reset block is not blocking us from resetting.  Acquire
  *  semaphore (if necessary) and read/set/write the device control reset
  *  bit in the PHY.  Wait the appropriate delay time for the device to
- *  reset and relase the semaphore (if necessary).
+ *  reset and release the semaphore (if necessary).
  **/
 s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 {
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 88fb53e..7c4ead3 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0083"
+#define DRV_VERSION	"EHEA_0087"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -386,6 +386,13 @@ struct ehea_port_res {
 
 
 #define EHEA_MAX_PORTS 16
+
+#define EHEA_NUM_PORTRES_FW_HANDLES    6  /* QP handle, SendCQ handle,
+					     RecvCQ handle, EQ handle,
+					     SendMR handle, RecvMR handle */
+#define EHEA_NUM_PORT_FW_HANDLES       1  /* EQ handle */
+#define EHEA_NUM_ADAPTER_FW_HANDLES    2  /* MR handle, NEQ handle */
+
 struct ehea_adapter {
 	u64 handle;
 	struct of_device *ofdev;
@@ -405,6 +412,31 @@ struct ehea_mc_list {
 	u64 macaddr;
 };
 
+/* kdump support */
+struct ehea_fw_handle_entry {
+	u64 adh;               /* Adapter Handle */
+	u64 fwh;               /* Firmware Handle */
+};
+
+struct ehea_fw_handle_array {
+	struct ehea_fw_handle_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
+struct ehea_bcmc_reg_entry {
+	u64 adh;               /* Adapter Handle */
+	u32 port_id;           /* Logical Port Id */
+	u8 reg_type;           /* Registration Type */
+	u64 macaddr;
+};
+
+struct ehea_bcmc_reg_array {
+	struct ehea_bcmc_reg_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
 #define EHEA_PORT_UP 1
 #define EHEA_PORT_DOWN 0
 #define EHEA_PHY_LINK_UP 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c051c7e..21af674 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -35,6 +35,7 @@
 #include <linux/if_ether.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <asm/kexec.h>
 
 #include <net/ip.h>
 
@@ -98,8 +99,10 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
-
 struct semaphore dlpar_mem_lock;
+struct ehea_fw_handle_array ehea_fw_handles;
+struct ehea_bcmc_reg_array ehea_bcmc_regs;
+
 
 static int __devinit ehea_probe_adapter(struct of_device *dev,
 					const struct of_device_id *id);
@@ -132,6 +135,160 @@ void ehea_dump(void *adr, int len, char *msg)
 	}
 }
 
+static void ehea_update_firmware_handles(void)
+{
+	struct ehea_fw_handle_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	int num_adapters = 0;
+	int num_ports = 0;
+	int num_portres = 0;
+	int i = 0;
+	int num_fw_handles, k, l;
+
+	/* Determine number of handles */
+	list_for_each_entry(adapter, &adapter_list, list) {
+		num_adapters++;
+
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_ports++;
+			num_portres += port->num_def_qps + port->num_add_tx_qps;
+		}
+	}
+
+	num_fw_handles = num_adapters * EHEA_NUM_ADAPTER_FW_HANDLES +
+			 num_ports * EHEA_NUM_PORT_FW_HANDLES +
+			 num_portres * EHEA_NUM_PORTRES_FW_HANDLES;
+
+	if (num_fw_handles) {
+		arr = kzalloc(num_fw_handles * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			for (l = 0;
+			     l < port->num_def_qps + port->num_add_tx_qps;
+			     l++) {
+				struct ehea_port_res *pr = &port->port_res[l];
+
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->qp->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->eq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_mr.handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_mr.handle;
+			}
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = port->qp_eq->fw_handle;
+		}
+
+		arr[i].adh = adapter->handle;
+		arr[i++].fwh = adapter->neq->fw_handle;
+
+		if (adapter->mr.handle) {
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = adapter->mr.handle;
+		}
+	}
+
+out_update:
+	kfree(ehea_fw_handles.arr);
+	ehea_fw_handles.arr = arr;
+	ehea_fw_handles.num_entries = i;
+}
+
+static void ehea_update_bcmc_registrations(void)
+{
+	struct ehea_bcmc_reg_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	struct ehea_mc_list *mc_entry;
+	int num_registrations = 0;
+	int i = 0;
+	int k;
+
+	/* Determine number of registrations */
+	list_for_each_entry(adapter, &adapter_list, list)
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_registrations += 2;	/* Broadcast registrations */
+
+			list_for_each_entry(mc_entry, &port->mc_list->list,list)
+				num_registrations += 2;
+		}
+
+	if (num_registrations) {
+		arr = kzalloc(num_registrations * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_UNTAGGED;
+			arr[i++].macaddr = port->mac_addr;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_VLANID_ALL;
+			arr[i++].macaddr = port->mac_addr;
+
+			list_for_each_entry(mc_entry,
+					    &port->mc_list->list, list) {
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_UNTAGGED;
+				arr[i++].macaddr = mc_entry->macaddr;
+
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_VLANID_ALL;
+				arr[i++].macaddr = mc_entry->macaddr;
+			}
+		}
+	}
+
+out_update:
+	kfree(ehea_bcmc_regs.arr);
+	ehea_bcmc_regs.arr = arr;
+	ehea_bcmc_regs.num_entries = i;
+}
+
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -1601,19 +1758,25 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
+	down(&ehea_bcmc_regs.lock);
+
 	/* Deregister old MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;
 
 	port->mac_addr = cb0->port_mac_addr << 16;
 
 	/* Register new MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;
 
 	ret = 0;
+
+out_upregs:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1775,9 +1938,11 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
+	down(&ehea_bcmc_regs.lock);
+
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
-		return;
+		goto out;
 	}
 	ehea_allmulti(dev, 0);
 
@@ -1803,6 +1968,8 @@ static void ehea_set_multicast_list(struct net_device *dev)
 
 	}
 out:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2285,6 +2452,8 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
+	down(&ehea_fw_handles.lock);
+
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
@@ -2321,8 +2490,17 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	ret = 0;
+	down(&ehea_bcmc_regs.lock);
+
+	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+	if (ret) {
+		ret = -EIO;
+		goto out_free_irqs;
+	}
+
 	port->state = EHEA_PORT_UP;
+
+	ret = 0;
 	goto out;
 
 out_free_irqs:
@@ -2334,6 +2512,12 @@ out:
 	if (ret)
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }
 
@@ -2382,16 +2566,27 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
+	down(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+
 	ehea_free_interrupts(dev);
 
+	down(&ehea_fw_handles.lock);
+
 	port->state = EHEA_PORT_DOWN;
 
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
 	ret = ehea_clean_all_portres(port);
 	if (ret)
 		ehea_info("Failed freeing resources for %s. ret=%i",
 			  dev->name, ret);
 
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }
 
@@ -2920,19 +3115,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
-
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret) {
-		ret = -EIO;
-		goto out_unreg_port;
-	}
-
 	ehea_set_ethtool_ops(dev);
 
 	ret = register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=%d", ret);
-		goto out_dereg_bc;
+		goto out_unreg_port;
 	}
 
 	port->lro_max_aggr = lro_max_aggr;
@@ -2949,9 +3137,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	return port;
 
-out_dereg_bc:
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-
 out_unreg_port:
 	ehea_unregister_port(port);
 
@@ -2971,7 +3156,6 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 {
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
 	port->adapter->active_ports--;
@@ -3014,7 +3198,6 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 
 		i++;
 	};
-
 	return 0;
 }
 
@@ -3159,6 +3342,7 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
+	down(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3239,7 +3423,10 @@ out_kill_eq:
 
 out_free_ad:
 	kfree(adapter);
+
 out:
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
 	return ret;
 }
 
@@ -3258,18 +3445,41 @@ static int __devexit ehea_remove(struct of_device *dev)
 
 	flush_scheduled_work();
 
+	down(&ehea_fw_handles.lock);
+
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
 	ehea_remove_adapter_mr(adapter);
 	list_del(&adapter->list);
-
 	kfree(adapter);
 
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return 0;
 }
 
+void ehea_crash_handler(void)
+{
+	int i;
+
+	if (ehea_fw_handles.arr)
+		for (i = 0; i < ehea_fw_handles.num_entries; i++)
+			ehea_h_free_resource(ehea_fw_handles.arr[i].adh,
+					     ehea_fw_handles.arr[i].fwh,
+					     FORCE_FREE);
+
+	if (ehea_bcmc_regs.arr)
+		for (i = 0; i < ehea_bcmc_regs.num_entries; i++)
+			ehea_h_reg_dereg_bcmc(ehea_bcmc_regs.arr[i].adh,
+					      ehea_bcmc_regs.arr[i].port_id,
+					      ehea_bcmc_regs.arr[i].reg_type,
+					      ehea_bcmc_regs.arr[i].macaddr,
+					      0, H_DEREG_BCMC);
+}
+
 static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
@@ -3330,7 +3540,12 @@ int __init ehea_module_init(void)
 
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
+	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
+	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
+
 	sema_init(&dlpar_mem_lock, 1);
+	sema_init(&ehea_fw_handles.lock, 1);
+	sema_init(&ehea_bcmc_regs.lock, 1);
 
 	ret = check_module_parm();
 	if (ret)
@@ -3340,12 +3555,18 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 
-	register_reboot_notifier(&ehea_reboot_nb);
+	ret = register_reboot_notifier(&ehea_reboot_nb);
+	if (ret)
+		ehea_info("failed registering reboot notifier");
+
+	ret = crash_shutdown_register(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed registering crash handler");
 
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
-		goto out;
+		goto out2;
 	}
 
 	ret = driver_create_file(&ehea_driver.driver,
@@ -3353,21 +3574,33 @@ int __init ehea_module_init(void)
 	if (ret) {
 		ehea_error("failed to register capabilities attribute, ret=%d",
 			   ret);
-		unregister_reboot_notifier(&ehea_reboot_nb);
-		ibmebus_unregister_driver(&ehea_driver);
-		goto out;
+		goto out3;
 	}
 
+	return ret;
+
+out3:
+	ibmebus_unregister_driver(&ehea_driver);
+out2:
+	unregister_reboot_notifier(&ehea_reboot_nb);
+	crash_shutdown_unregister(&ehea_crash_handler);
 out:
 	return ret;
 }
 
 static void __exit ehea_module_exit(void)
 {
+	int ret;
+
 	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	unregister_reboot_notifier(&ehea_reboot_nb);
+	ret = crash_shutdown_unregister(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed unregistering crash handler");
+	kfree(ehea_fw_handles.arr);
+	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
 }
 
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 42d94ed..af869cf 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -946,16 +946,11 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct mii_ioctl_data *mii = (struct mii_ioctl_data *)&rq->ifr_data;
-	unsigned long flags;
-	int rc;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irqsave(&fep->lock, flags);
-	rc = phy_mii_ioctl(fep->phydev, mii, cmd);
-	spin_unlock_irqrestore(&fep->lock, flags);
-	return rc;
+	return phy_mii_ioctl(fep->phydev, mii, cmd);
 }
 
 extern int fs_mii_connect(struct net_device *dev);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4244fc2..718cf77 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -605,7 +605,7 @@ void stop_gfar(struct net_device *dev)
 
 	free_skb_resources(priv);
 
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -626,7 +626,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	for (i = 0; i < priv->tx_ring_size; i++) {
 
 		if (priv->tx_skbuff[i]) {
-			dma_unmap_single(NULL, txbdp->bufPtr,
+			dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
 					txbdp->length,
 					DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
@@ -643,7 +643,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	if(priv->rx_skbuff != NULL) {
 		for (i = 0; i < priv->rx_ring_size; i++) {
 			if (priv->rx_skbuff[i]) {
-				dma_unmap_single(NULL, rxbdp->bufPtr,
+				dma_unmap_single(&priv->dev->dev, rxbdp->bufPtr,
 						priv->rx_buffer_size,
 						DMA_FROM_DEVICE);
 
@@ -708,7 +708,7 @@ int startup_gfar(struct net_device *dev)
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(NULL,
+	vaddr = (unsigned long) dma_alloc_coherent(&dev->dev,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -919,7 +919,7 @@ err_irq_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -1053,7 +1053,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set buffer length and pointer */
 	txbdp->length = skb->len;
-	txbdp->bufPtr = dma_map_single(NULL, skb->data,
+	txbdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
 	/* Save the skb pointer so we can free it later */
@@ -1332,7 +1332,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	 */
 	skb_reserve(skb, alignamount);
 
-	bdp->bufPtr = dma_map_single(NULL, skb->data,
+	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 	bdp->length = 0;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bff280e..6a1f230 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -439,7 +439,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		err = igb_request_msix(adapter);
 		if (!err) {
 			/* enable IAM, auto-mask,
-			 * DO NOT USE EIAME or IAME in legacy mode */
+			 * DO NOT USE EIAM or IAM in legacy mode */
 			wr32(E1000_IAM, IMS_ENABLE_MASK);
 			goto request_done;
 		}
@@ -465,14 +465,9 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
 			  netdev->name, netdev);
 
-	if (err) {
+	if (err)
 		dev_err(&adapter->pdev->dev, "Error %d getting interrupt\n",
 			err);
-		goto request_done;
-	}
-
-	/* enable IAM, auto-mask */
-	wr32(E1000_IAM, IMS_ENABLE_MASK);
 
 request_done:
 	return err;
@@ -821,7 +816,8 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	igb_reset_adaptive(&adapter->hw);
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**
@@ -2057,7 +2053,8 @@ static void igb_set_multi(struct net_device *netdev)
 static void igb_update_phy_info(unsigned long data)
 {
 	struct igb_adapter *adapter = (struct igb_adapter *) data;
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 53a9fd0..75f3a68 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -67,6 +67,7 @@ static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"rx_over_errors", IXGB_STAT(net_stats.rx_over_errors)},
 	{"rx_crc_errors", IXGB_STAT(net_stats.rx_crc_errors)},
 	{"rx_frame_errors", IXGB_STAT(net_stats.rx_frame_errors)},
+	{"rx_no_buffer_count", IXGB_STAT(stats.rnbc)},
 	{"rx_fifo_errors", IXGB_STAT(net_stats.rx_fifo_errors)},
 	{"rx_missed_errors", IXGB_STAT(net_stats.rx_missed_errors)},
 	{"tx_aborted_errors", IXGB_STAT(net_stats.tx_aborted_errors)},
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 81bf005..1d210ed 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -148,7 +148,7 @@ static void macb_handle_link_change(struct net_device *dev)
 
 			if (phydev->duplex)
 				reg |= MACB_BIT(FD);
-			if (phydev->speed)
+			if (phydev->speed == SPEED_100)
 				reg |= MACB_BIT(SPD);
 
 			macb_writel(bp, NCFGR, reg);
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 6323988..fd8158a 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -590,6 +590,13 @@ static int pcnet_config(struct pcmcia_device *link)
 	dev->if_port = 0;
     }
 
+    if ((link->conf.ConfigBase == 0x03c0)
+	&& (link->manf_id == 0x149) && (link->card_id = 0xc1ab)) {
+	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
+	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
+	goto failed;
+    }
+
     local_hw_info = get_hwinfo(link);
     if (local_hw_info == NULL)
 	local_hw_info = get_prom(link);
@@ -1567,12 +1574,11 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x0104, 0x0145),
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0x0230),
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0x4530),
-/*	PCMCIA_DEVICE_MANF_CARD(0x0149, 0xc1ab), conflict with axnet_cs */
+	PCMCIA_DEVICE_MANF_CARD(0x0149, 0xc1ab),
 	PCMCIA_DEVICE_MANF_CARD(0x0186, 0x0110),
 	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x2328),
 	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x8041),
 	PCMCIA_DEVICE_MANF_CARD(0x0213, 0x2452),
-/*	PCMCIA_DEVICE_MANF_CARD(0x021b, 0x0202), conflict with axnet_cs */
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0300),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0307),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x030a),
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6e9f619..963630c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err = 0;
 
-	mutex_init(&bus->mdio_lock);
-
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
 			NULL == bus->write)
 		return -EINVAL;
 
+	mutex_init(&bus->mdio_lock);
+
 	if (bus->reset)
 		bus->reset(bus);
 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 202fdf3..20745fd 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1633,13 +1633,18 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
 					 struct net_device *dev)
 {
-	u8 from;
+	int rc;
+
+	rc = sis190_get_mac_addr_from_eeprom(pdev, dev);
+	if (rc < 0) {
+		u8 reg;
 
-	pci_read_config_byte(pdev, 0x73, &from);
+		pci_read_config_byte(pdev, 0x73, &reg);
 
-	return (from & 0x00000001) ?
-		sis190_get_mac_addr_from_apc(pdev, dev) :
-		sis190_get_mac_addr_from_eeprom(pdev, dev);
+		if (reg & 0x00000001)
+			rc = sis190_get_mac_addr_from_apc(pdev, dev);
+	}
+	return rc;
 }
 
 static void sis190_set_speed_auto(struct net_device *dev)
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 9a62959..54c6626 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -572,8 +572,9 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 	default:
 		/* set Tx LED (LED_TX) to blink mode on Rx OR Tx activity */
 		ledctrl |= PHY_M_LED_BLINK_RT(BLINK_84MS) | PHY_M_LEDC_TX_CTRL;
+
 		/* turn off the Rx LED (LED_RX) */
-		ledover &= ~PHY_M_LED_MO_RX;
+		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
@@ -602,7 +603,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
 			/* turn on 100 Mbps LED (LED_LINK100) */
-			ledover |= PHY_M_LED_MO_100;
+			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
 		}
 
 		if (ledover)
@@ -3322,82 +3323,80 @@ static void sky2_set_multicast(struct net_device *dev)
 /* Can have one global because blinking is controlled by
  * ethtool and that is always under RTNL mutex
  */
-static void sky2_led(struct sky2_hw *hw, unsigned port, int on)
+static void sky2_led(struct sky2_port *sky2, enum led_mode mode)
 {
-	u16 pg;
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
 
-	switch (hw->chip_id) {
-	case CHIP_ID_YUKON_XL:
+	spin_lock_bh(&sky2->phy_lock);
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		u16 pg;
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
-			     on ? (PHY_M_LEDC_LOS_CTRL(1) |
-				   PHY_M_LEDC_INIT_CTRL(7) |
-				   PHY_M_LEDC_STA1_CTRL(7) |
-				   PHY_M_LEDC_STA0_CTRL(7))
-			     : 0);
 
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-		break;
+		switch (mode) {
+		case MO_LED_OFF:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(8) |
+				     PHY_M_LEDC_INIT_CTRL(8) |
+				     PHY_M_LEDC_STA1_CTRL(8) |
+				     PHY_M_LEDC_STA0_CTRL(8));
+			break;
+		case MO_LED_ON:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(9) |
+				     PHY_M_LEDC_INIT_CTRL(9) |
+				     PHY_M_LEDC_STA1_CTRL(9) |
+				     PHY_M_LEDC_STA0_CTRL(9));
+			break;
+		case MO_LED_BLINK:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(0xa) |
+				     PHY_M_LEDC_INIT_CTRL(0xa) |
+				     PHY_M_LEDC_STA1_CTRL(0xa) |
+				     PHY_M_LEDC_STA0_CTRL(0xa));
+			break;
+		case MO_LED_NORM:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(1) |
+				     PHY_M_LEDC_INIT_CTRL(8) |
+				     PHY_M_LEDC_STA1_CTRL(7) |
+				     PHY_M_LEDC_STA0_CTRL(7));
+		}
 
-	default:
-		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, 0);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+	} else
 		gm_phy_write(hw, port, PHY_MARV_LED_OVER, 
-			     on ? PHY_M_LED_ALL : 0);
-	}
+				     PHY_M_LED_MO_DUP(mode) |
+				     PHY_M_LED_MO_10(mode) |
+				     PHY_M_LED_MO_100(mode) |
+				     PHY_M_LED_MO_1000(mode) |
+				     PHY_M_LED_MO_RX(mode) |
+				     PHY_M_LED_MO_TX(mode));
+
+	spin_unlock_bh(&sky2->phy_lock);
 }
 
 /* blink LED's for finding board */
 static int sky2_phys_id(struct net_device *dev, u32 data)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	unsigned port = sky2->port;
-	u16 ledctrl, ledover = 0;
-	long ms;
-	int interrupted;
-	int onoff = 1;
+	unsigned int i;
 
-	if (!data || data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ))
-		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT);
-	else
-		ms = data * 1000;
-
-	/* save initial values */
-	spin_lock_bh(&sky2->phy_lock);
-	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		ledctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	} else {
-		ledctrl = gm_phy_read(hw, port, PHY_MARV_LED_CTRL);
-		ledover = gm_phy_read(hw, port, PHY_MARV_LED_OVER);
-	}
-
-	interrupted = 0;
-	while (!interrupted && ms > 0) {
-		sky2_led(hw, port, onoff);
-		onoff = !onoff;
-
-		spin_unlock_bh(&sky2->phy_lock);
-		interrupted = msleep_interruptible(250);
-		spin_lock_bh(&sky2->phy_lock);
-
-		ms -= 250;
-	}
+	if (data == 0)
+		data = UINT_MAX;
 
-	/* resume regularly scheduled programming */
-	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ledctrl);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	} else {
-		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
-		gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);
+	for (i = 0; i < data; i++) {
+		sky2_led(sky2, MO_LED_ON);
+		if (msleep_interruptible(500))
+			break;
+		sky2_led(sky2, MO_LED_OFF);
+		if (msleep_interruptible(500))
+			break;
 	}
-	spin_unlock_bh(&sky2->phy_lock);
+	sky2_led(sky2, MO_LED_NORM);
 
 	return 0;
 }
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 5ab5c1c..7bb3ba9 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1318,18 +1318,21 @@ enum {
 	BLINK_670MS	= 4,/* 670 ms */
 };
 
-/**** PHY_MARV_LED_OVER    16 bit r/w LED control */
-enum {
-	PHY_M_LED_MO_DUP  = 3<<10,/* Bit 11..10:  Duplex */
-	PHY_M_LED_MO_10	  = 3<<8, /* Bit  9.. 8:  Link 10 */
-	PHY_M_LED_MO_100  = 3<<6, /* Bit  7.. 6:  Link 100 */
-	PHY_M_LED_MO_1000 = 3<<4, /* Bit  5.. 4:  Link 1000 */
-	PHY_M_LED_MO_RX	  = 3<<2, /* Bit  3.. 2:  Rx */
-	PHY_M_LED_MO_TX	  = 3<<0, /* Bit  1.. 0:  Tx */
-
-	PHY_M_LED_ALL	  = PHY_M_LED_MO_DUP | PHY_M_LED_MO_10 
-			    | PHY_M_LED_MO_100 | PHY_M_LED_MO_1000
-			    | PHY_M_LED_MO_RX,
+/*****  PHY_MARV_LED_OVER	16 bit r/w	Manual LED Override Reg *****/
+#define PHY_M_LED_MO_SGMII(x)	((x)<<14)	/* Bit 15..14:  SGMII AN Timer */
+
+#define PHY_M_LED_MO_DUP(x)	((x)<<10)	/* Bit 11..10:  Duplex */
+#define PHY_M_LED_MO_10(x)	((x)<<8)	/* Bit  9.. 8:  Link 10 */
+#define PHY_M_LED_MO_100(x)	((x)<<6)	/* Bit  7.. 6:  Link 100 */
+#define PHY_M_LED_MO_1000(x)	((x)<<4)	/* Bit  5.. 4:  Link 1000 */
+#define PHY_M_LED_MO_RX(x)	((x)<<2)	/* Bit  3.. 2:  Rx */
+#define PHY_M_LED_MO_TX(x)	((x)<<0)	/* Bit  1.. 0:  Tx */
+
+enum led_mode {
+	MO_LED_NORM  = 0,
+	MO_LED_BLINK = 1,
+	MO_LED_OFF   = 2,
+	MO_LED_ON    = 3,
 };
 
 /*****  PHY_MARV_EXT_CTRL_2	16 bit r/w	Ext. PHY Specific Ctrl 2 *****/
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 3af5b92..0166407 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1400,7 +1400,7 @@ static void TLan_SetMulticastList( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 {
 	/* printk( "TLAN:  Invalid interrupt on %s.\n", dev->name ); */
 	return 0;
@@ -1432,7 +1432,7 @@ u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		eoc = 0;
@@ -1518,7 +1518,7 @@ u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 {
 	TLan_ReadAndClearStats( dev, TLAN_RECORD );
 
@@ -1554,7 +1554,7 @@ u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack = 0;
@@ -1689,7 +1689,7 @@ u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 {
 	printk( "TLAN:  Test interrupt on %s.\n", dev->name );
 	return 1;
@@ -1719,7 +1719,7 @@ u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	TLanList		*head_list;
@@ -1767,7 +1767,7 @@ u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack;
@@ -1842,7 +1842,7 @@ u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	dma_addr_t	head_list_phys;
@@ -1902,7 +1902,7 @@ u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-void TLan_Timer( unsigned long data )
+static void TLan_Timer( unsigned long data )
 {
 	struct net_device	*dev = (struct net_device *) data;
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -1983,7 +1983,7 @@ void TLan_Timer( unsigned long data )
 	 *
 	 **************************************************************/
 
-void TLan_ResetLists( struct net_device *dev )
+static void TLan_ResetLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2043,7 +2043,7 @@ void TLan_ResetLists( struct net_device *dev )
 } /* TLan_ResetLists */
 
 
-void TLan_FreeLists( struct net_device *dev )
+static void TLan_FreeLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2092,7 +2092,7 @@ void TLan_FreeLists( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_PrintDio( u16 io_base )
+static void TLan_PrintDio( u16 io_base )
 {
 	u32 data0, data1;
 	int	i;
@@ -2127,7 +2127,7 @@ void TLan_PrintDio( u16 io_base )
 	 *
 	 **************************************************************/
 
-void TLan_PrintList( TLanList *list, char *type, int num)
+static void TLan_PrintList( TLanList *list, char *type, int num)
 {
 	int i;
 
@@ -2163,7 +2163,7 @@ void TLan_PrintList( TLanList *list, char *type, int num)
 	 *
 	 **************************************************************/
 
-void TLan_ReadAndClearStats( struct net_device *dev, int record )
+static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
@@ -2238,7 +2238,7 @@ void TLan_ReadAndClearStats( struct net_device *dev, int record )
 	 *
 	 **************************************************************/
 
-void
+static void
 TLan_ResetAdapter( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2324,7 +2324,7 @@ TLan_ResetAdapter( struct net_device *dev )
 
 
 
-void
+static void
 TLan_FinishReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2448,7 +2448,7 @@ TLan_FinishReset( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_SetMac( struct net_device *dev, int areg, char *mac )
+static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 {
 	int i;
 
@@ -2490,7 +2490,7 @@ void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyPrint( struct net_device *dev )
+static void TLan_PhyPrint( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16 i, data0, data1, data2, data3, phy;
@@ -2539,7 +2539,7 @@ void TLan_PhyPrint( struct net_device *dev )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyDetect( struct net_device *dev )
+static void TLan_PhyDetect( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		control;
@@ -2586,7 +2586,7 @@ void TLan_PhyDetect( struct net_device *dev )
 
 
 
-void TLan_PhyPowerDown( struct net_device *dev )
+static void TLan_PhyPowerDown( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2611,7 +2611,7 @@ void TLan_PhyPowerDown( struct net_device *dev )
 
 
 
-void TLan_PhyPowerUp( struct net_device *dev )
+static void TLan_PhyPowerUp( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2632,7 +2632,7 @@ void TLan_PhyPowerUp( struct net_device *dev )
 
 
 
-void TLan_PhyReset( struct net_device *dev )
+static void TLan_PhyReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		phy;
@@ -2660,7 +2660,7 @@ void TLan_PhyReset( struct net_device *dev )
 
 
 
-void TLan_PhyStartLink( struct net_device *dev )
+static void TLan_PhyStartLink( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		ability;
@@ -2747,7 +2747,7 @@ void TLan_PhyStartLink( struct net_device *dev )
 
 
 
-void TLan_PhyFinishAutoNeg( struct net_device *dev )
+static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		an_adv;
@@ -2903,7 +2903,7 @@ void TLan_PhyMonitor( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
+static int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 {
 	u8	nack;
 	u16	sio, tmp;
@@ -2993,7 +2993,7 @@ int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
+static void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 {
 	u16 sio;
 	u32 i;
@@ -3035,7 +3035,7 @@ void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSync( u16 base_port )
+static void TLan_MiiSync( u16 base_port )
 {
 	int i;
 	u16 sio;
@@ -3074,7 +3074,7 @@ void TLan_MiiSync( u16 base_port )
 	 *
 	 **************************************************************/
 
-void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
+static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 {
 	u16	sio;
 	int	minten;
@@ -3144,7 +3144,7 @@ void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 	 *
 	 **************************************************************/
 
-void TLan_EeSendStart( u16 io_base )
+static void TLan_EeSendStart( u16 io_base )
 {
 	u16	sio;
 
@@ -3184,7 +3184,7 @@ void TLan_EeSendStart( u16 io_base )
 	 *
 	 **************************************************************/
 
-int TLan_EeSendByte( u16 io_base, u8 data, int stop )
+static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 {
 	int	err;
 	u8	place;
@@ -3245,7 +3245,7 @@ int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 	 *
 	 **************************************************************/
 
-void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
+static void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 {
 	u8  place;
 	u16 sio;
@@ -3303,7 +3303,7 @@ void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 	 *
 	 **************************************************************/
 
-int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
+static int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
 {
 	int err;
 	TLanPrivateInfo *priv = netdev_priv(dev);
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index a7afeea..a59c1f2 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -482,9 +482,11 @@ static void uli526x_init(struct net_device *dev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
 	u8	phy_tmp;
+	u8	timeout;
 	u16	phy_value;
 	u16 phy_reg_reset;
 
+
 	ULI526X_DBUG(0, "uli526x_init()", 0);
 
 	/* Reset M526x MAC controller */
@@ -509,11 +511,19 @@ static void uli526x_init(struct net_device *dev)
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
-	/* Phyxcer capability setting */
+	/* phyxcer capability setting */
 	phy_reg_reset = phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id);
 	phy_reg_reset = (phy_reg_reset | 0x8000);
 	phy_write(db->ioaddr, db->phy_addr, 0, phy_reg_reset, db->chip_id);
+
+	/* See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management
+	 * functions") or phy data sheet for details on phy reset
+	 */
 	udelay(500);
+	timeout = 10;
+	while (timeout-- &&
+		phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id) & 0x8000)
+			udelay(100);
 
 	/* Process Phyxcer Media Mode */
 	uli526x_set_phyxcer(db);
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 7c851b1..8c9d6ae 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1893,7 +1893,7 @@ static void rhine_shutdown (struct pci_dev *pdev)
 
 	/* Make sure we use pattern 0, 1 and not 4, 5 */
 	if (rp->quirks & rq6patterns)
-		iowrite8(0x04, ioaddr + 0xA7);
+		iowrite8(0x04, ioaddr + WOLcgClr);
 
 	if (rp->wolopts & WAKE_MAGIC) {
 		iowrite8(WOLmagic, ioaddr + WOLcrSet);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fdc2367..19fd4cb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -361,6 +361,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
+	vdev->priv = vi;
 
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
@@ -395,7 +396,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	pr_debug("virtnet: registered device %s\n", dev->name);
-	vdev->priv = vi;
 	return 0;
 
 unregister:
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index c307621..d8a5c22 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -1851,8 +1851,7 @@ claw_hw_tx(struct sk_buff *skb, struct net_device *dev, long linkid)
                 }
         }
         /*      See how many write buffers are required to hold this data */
-        numBuffers= ( skb->len + privptr->p_env->write_size - 1) /
-			( privptr->p_env->write_size);
+	numBuffers = DIV_ROUND_UP(skb->len, privptr->p_env->write_size);
 
         /*      If that number of buffers isn't available, give up for now */
         if (privptr->write_free_count < numBuffers ||
@@ -2114,8 +2113,7 @@ init_ccw_bk(struct net_device *dev)
         */
         ccw_blocks_perpage= PAGE_SIZE /  CCWBK_SIZE;
         ccw_pages_required=
-		(ccw_blocks_required+ccw_blocks_perpage -1) /
-			 ccw_blocks_perpage;
+		DIV_ROUND_UP(ccw_blocks_required, ccw_blocks_perpage);
 
 #ifdef DEBUGMSG
         printk(KERN_INFO "%s: %s() > ccw_blocks_perpage=%d\n",
@@ -2131,30 +2129,29 @@ init_ccw_bk(struct net_device *dev)
 	 * provide good performance. With packing buffers support 32k
 	 * buffers are used.
          */
-        if (privptr->p_env->read_size < PAGE_SIZE) {
-            claw_reads_perpage= PAGE_SIZE / privptr->p_env->read_size;
-            claw_read_pages= (privptr->p_env->read_buffers +
-	    	claw_reads_perpage -1) / claw_reads_perpage;
+	if (privptr->p_env->read_size < PAGE_SIZE) {
+		claw_reads_perpage = PAGE_SIZE / privptr->p_env->read_size;
+		claw_read_pages = DIV_ROUND_UP(privptr->p_env->read_buffers,
+						claw_reads_perpage);
          }
          else {       /* > or equal  */
-            privptr->p_buff_pages_perread=
-	    	(privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_read_pages=
-	    	privptr->p_env->read_buffers * privptr->p_buff_pages_perread;
+		privptr->p_buff_pages_perread =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_read_pages = privptr->p_env->read_buffers *
+					privptr->p_buff_pages_perread;
          }
         if (privptr->p_env->write_size < PAGE_SIZE) {
-            claw_writes_perpage=
-	    	PAGE_SIZE / privptr->p_env->write_size;
-            claw_write_pages=
-	    	(privptr->p_env->write_buffers + claw_writes_perpage -1) /
-			claw_writes_perpage;
+		claw_writes_perpage =
+			PAGE_SIZE / privptr->p_env->write_size;
+		claw_write_pages = DIV_ROUND_UP(privptr->p_env->write_buffers,
+						claw_writes_perpage);
 
         }
         else {      /* >  or equal  */
-            privptr->p_buff_pages_perwrite=
-	    	 (privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_write_pages=
-	     	privptr->p_env->write_buffers * privptr->p_buff_pages_perwrite;
+		privptr->p_buff_pages_perwrite =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_write_pages = privptr->p_env->write_buffers *
+					privptr->p_buff_pages_perwrite;
         }
 #ifdef DEBUGMSG
         if (privptr->p_env->read_size < PAGE_SIZE) {
