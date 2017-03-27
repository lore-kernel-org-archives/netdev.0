From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: [PATCH RFC v4 06/10] net: qualcomm: make qca_common a separate kernel module
Date: Mon, 27 Mar 2017 15:37:24 +0200
Message-ID: <1490621848-24828-7-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In order to share common functions between QCA7000 SPI and UART protocol
driver the qca_common needs to be a separate kernel module.

Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
---
 drivers/net/ethernet/qualcomm/Kconfig      |  8 +++++++-
 drivers/net/ethernet/qualcomm/Makefile     |  5 +++--
 drivers/net/ethernet/qualcomm/qca_common.c | 10 ++++++++++
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
index 8080570..00d8729 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Qualcomm network device drivers.
 #
 
-obj-$(CONFIG_QCA7000) += qcaspi.o
-qcaspi-objs := qca_spi.o qca_common.o qca_7k.o qca_debug.o
+obj-$(CONFIG_QCA7000) += qca_common.o
+obj-$(CONFIG_QCA7000_SPI) += qcaspi.o
+qcaspi-objs := qca_7k.o qca_debug.o qca_spi.o
 
 obj-y += emac/
diff --git a/drivers/net/ethernet/qualcomm/qca_common.c b/drivers/net/ethernet/qualcomm/qca_common.c
index d930524..f2c9e76 100644
--- a/drivers/net/ethernet/qualcomm/qca_common.c
+++ b/drivers/net/ethernet/qualcomm/qca_common.c
@@ -21,7 +21,9 @@
  *   by an atheros frame while transmitted over a serial channel;
  */
 
+#include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 
 #include "qca_common.h"
 
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
+MODULE_DESCRIPTION("Qualcomm Atheros Common");
+MODULE_AUTHOR("Qualcomm Atheros Communications");
+MODULE_AUTHOR("Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>");
+MODULE_LICENSE("Dual BSD/GPL");
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
