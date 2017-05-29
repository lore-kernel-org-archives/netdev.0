From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 12/17] net: qualcomm: make qca_7k_common a separate kernel module
Date: Mon, 29 May 2017 13:57:20 +0200
Message-ID: <1496059045-13572-13-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to share common functions between QCA7000 SPI and UART protocol
driver the qca_7k_common needs to be a separate kernel module.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/Kconfig         |  8 +++++++-
 drivers/net/ethernet/qualcomm/Makefile        |  5 +++--
 drivers/net/ethernet/qualcomm/qca_7k_common.c | 10 ++++++++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index d7720bf..b4c369d 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -16,7 +16,13 @@ config NET_VENDOR_QUALCOMM
 if NET_VENDOR_QUALCOMM
 
 config QCA7000
-	tristate "Qualcomm Atheros QCA7000 support"
+	tristate
+	help
+	  This enables support for the Qualcomm Atheros QCA7000.
+
+config QCA7000_SPI
+	tristate "Qualcomm Atheros QCA7000 SPI support"
+	select QCA7000
 	depends on SPI_MASTER && OF
 	---help---
 	  This SPI protocol driver supports the Qualcomm Atheros QCA7000.
diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index 5e17bf1..65556ca 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Qualcomm network device drivers.
 #
 
-obj-$(CONFIG_QCA7000) += qcaspi.o
-qcaspi-objs := qca_spi.o qca_7k_common.o qca_7k.o qca_debug.o
+obj-$(CONFIG_QCA7000) += qca_7k_common.o
+obj-$(CONFIG_QCA7000_SPI) += qcaspi.o
+qcaspi-objs := qca_7k.o qca_debug.o qca_spi.o
 
 obj-y += emac/
diff --git a/drivers/net/ethernet/qualcomm/qca_7k_common.c b/drivers/net/ethernet/qualcomm/qca_7k_common.c
index 0d3daa9..6b511f0 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k_common.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k_common.c
@@ -21,7 +21,9 @@
  *   by an atheros frame while transmitted over a serial channel;
  */
 
+#include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 
 #include "qca_7k_common.h"
 
@@ -46,6 +48,7 @@ qcafrm_create_header(u8 *buf, u16 length)
 
 	return QCAFRM_HEADER_LEN;
 }
+EXPORT_SYMBOL_GPL(qcafrm_create_header);
 
 u16
 qcafrm_create_footer(u8 *buf)
@@ -57,6 +60,7 @@ qcafrm_create_footer(u8 *buf)
 	buf[1] = 0x55;
 	return QCAFRM_FOOTER_LEN;
 }
+EXPORT_SYMBOL_GPL(qcafrm_create_footer);
 
 /*   Gather received bytes and try to extract a full ethernet frame by
  *   following a simple state machine.
@@ -154,3 +158,9 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(qcafrm_fsm_decode);
+
+MODULE_DESCRIPTION("Qualcomm Atheros QCA7000 common");
+MODULE_AUTHOR("Qualcomm Atheros Communications");
+MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
+MODULE_LICENSE("Dual BSD/GPL");
-- 
2.1.4
