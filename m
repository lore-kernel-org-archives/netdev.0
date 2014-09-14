From: Walter Mack <wmack@componentsw.com>
Subject: [PATCH 001/001] IEEE 802.15.4: Add module parameter to mrf24j40 to
 allow use of external transmitters/receivers
Date: Sat, 13 Sep 2014 18:37:39 -0700
Message-ID: <5414F163.6010309@componentsw.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

enhance module drivers/net/ieee802154/mrf24j40.c to allow designs that 
use external transmitters/receivers.

Designs that use Microchip's MRF24J40 with external receivers and 
transmitters require the chip to
be specifically programmed for this, by setting the "test mode register" 
to 0xf.

In my testing, without this flag, I could only receive over a distance 
of a few feet. Setting this flag allows
distances well above 100 feet.

The patch adds a module parameter module_param(ext_rx_tx, bool, 0). When 
setting the parameter to true,
the driver configures the "test mode" register of the mrf24j40 device to 
work with external tranmitters and receivers.

patch applies to kernel version:3.16.0-rc4csi-git-dirty, git: commit 
cd3de83f147601356395b57a8673e9c5ff1e59d1

(I'm doing a patch submission the first time. If I'm doing this wrong, I 
would appreciate feedback for how to do this better next time).

Signed-off-by: Walter J. Mack <wmack@componentsw.com>

---
diff --git a/drivers/net/ieee802154/mrf24j40.c 
b/drivers/net/ieee802154/mrf24j40.c
index 4048062..18cff47 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -26,6 +26,10 @@
  #include <net/mac802154.h>
  #include <net/ieee802154.h>

+static bool ext_rx_tx = false ;
+module_param(ext_rx_tx, bool, 0);
+MODULE_PARM_DESC(ext_rx_tx, " turn on statemachine to manage external 
tx/rx");
+
  /* MRF24J40 Short Address Registers */
  #define REG_RXMCR    0x00  /* Receive MAC control */
  #define REG_PANIDL   0x01  /* PAN ID (low) */
@@ -63,6 +67,8 @@
  #define REG_SLPCON1    0x220
  #define REG_WAKETIMEL  0x222  /* Wake-up Time Match Value Low */
  #define REG_WAKETIMEH  0x223  /* Wake-up Time Match Value High */
+#define REG_TESTMODE   0x22f  /* test mode and state machine control 
register */
+
  #define REG_RX_FIFO    0x300  /* Receive FIFO */

  /* Device configuration: Only channels 11-26 on page 0 are supported. */
@@ -669,6 +675,10 @@ static int mrf24j40_probe(struct spi_device *spi)
      write_short_reg(devrec, REG_RFCTL, 0x0);
      udelay(192);

+    if ( false != ext_rx_tx ){
+      write_long_reg(devrec, REG_TESTMODE, 0x0f);
+    }
+
      /* Set RX Mode. RXMCR<1:0>: 0x0 normal, 0x1 promisc, 0x2 error */
      ret = read_short_reg(devrec, REG_RXMCR, &val);
      if (ret)
