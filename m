From: David Dillow <dave@thedillows.org>
Subject: [BK] Updated 2.6 typhoon driver for 3CR990 & 3CR990B cards
Date: 27 Jan 2004 00:35:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075179543.4987.7.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ I've not sent patches to the list, as the firmware update is too big. ]

Jeff, please do a

	bk pull http://typhoon.bkbits.net/typhoon-2.5

This will update the following files:

 drivers/net/typhoon-firmware.h | 6890 +++++++++++++++++++++--------------------
 drivers/net/typhoon.c          |   20 
 drivers/net/typhoon.h          |    6 
 3 files changed, 3563 insertions(+), 3353 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (03/12/15 1.1488)
   Support the new 3CR990B cards that require authentication of the runtime
   firmware image.


And the non-firmware part is:

diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	Mon Jan 26 22:58:36 2004
+++ b/drivers/net/typhoon.c	Mon Jan 26 22:58:36 2004
@@ -85,8 +85,8 @@
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.2"
-#define DRV_MODULE_RELDATE	"03/11/25"
+#define DRV_MODULE_VERSION 	"1.5.3"
+#define DRV_MODULE_RELDATE	"03/12/15"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -157,6 +157,7 @@
 	TYPHOON_TX = 0, TYPHOON_TX95, TYPHOON_TX97, TYPHOON_SVR,
 	TYPHOON_SVR95, TYPHOON_SVR97, TYPHOON_TXM, TYPHOON_BSVR,
 	TYPHOON_FX95, TYPHOON_FX97, TYPHOON_FX95SVR, TYPHOON_FX97SVR,
+	TYPHOON_FXM,
 };
 
 /* directly indexed by enum typhoon_cards, above */
@@ -185,6 +186,8 @@
 	 	TYPHOON_CRYPTO_DES | TYPHOON_FIBER},
 	{ "3Com Typhoon (3CR990-FX-97 Server)",
 	 	TYPHOON_CRYPTO_DES | TYPHOON_CRYPTO_3DES | TYPHOON_FIBER},
+	{ "3Com Typhoon2 (3C990B-FX-97)",
+		TYPHOON_CRYPTO_VARIABLE | TYPHOON_FIBER},
 };
 
 /* Notes on the new subsystem numbering scheme:
@@ -203,6 +206,8 @@
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990B,
 	  PCI_ANY_ID, 0x1000, 0, 0, TYPHOON_TXM },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990B,
+	  PCI_ANY_ID, 0x1102, 0, 0, TYPHOON_FXM },
+	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990B,
 	  PCI_ANY_ID, 0x2000, 0, 0, TYPHOON_BSVR },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_FX,
 	  PCI_ANY_ID, 0x1101, 0, 0, TYPHOON_FX95 },
@@ -1363,6 +1368,7 @@
 	u32 section_len;
 	u32 len;
 	u32 load_addr;
+	u32 hmac;
 	int i;
 	int err;
 
@@ -1406,6 +1412,16 @@
 
 	writel(TYPHOON_INTR_BOOTCMD, ioaddr + TYPHOON_REG_INTR_STATUS);
 	writel(load_addr, ioaddr + TYPHOON_REG_DOWNLOAD_BOOT_ADDR);
+	hmac = le32_to_cpu(fHdr->hmacDigest[0]);
+	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_0);
+	hmac = le32_to_cpu(fHdr->hmacDigest[1]);
+	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_1);
+	hmac = le32_to_cpu(fHdr->hmacDigest[2]);
+	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_2);
+	hmac = le32_to_cpu(fHdr->hmacDigest[3]);
+	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_3);
+	hmac = le32_to_cpu(fHdr->hmacDigest[4]);
+	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_4);
 	typhoon_post_pci_writes(ioaddr);
 	writel(TYPHOON_BOOTCMD_RUNTIME_IMAGE, ioaddr + TYPHOON_REG_COMMAND);
 
diff -Nru a/drivers/net/typhoon.h b/drivers/net/typhoon.h
--- a/drivers/net/typhoon.h	Mon Jan 26 22:58:36 2004
+++ b/drivers/net/typhoon.h	Mon Jan 26 22:58:36 2004
@@ -512,6 +512,7 @@
 	u32 version;
 	u32 numSections;
 	u32 startAddr;
+	u32 hmacDigest[5];
 } __attribute__ ((packed));
 
 struct typhoon_section_header {
@@ -548,6 +549,11 @@
 #define TYPHOON_REG_BOOT_LENGTH			TYPHOON_REG_HOST2ARM1
 
 #define TYPHOON_REG_DOWNLOAD_BOOT_ADDR		TYPHOON_REG_HOST2ARM1
+#define TYPHOON_REG_DOWNLOAD_HMAC_0		TYPHOON_REG_HOST2ARM2
+#define TYPHOON_REG_DOWNLOAD_HMAC_1		TYPHOON_REG_HOST2ARM3
+#define TYPHOON_REG_DOWNLOAD_HMAC_2		TYPHOON_REG_HOST2ARM4
+#define TYPHOON_REG_DOWNLOAD_HMAC_3		TYPHOON_REG_HOST2ARM5
+#define TYPHOON_REG_DOWNLOAD_HMAC_4		TYPHOON_REG_HOST2ARM6
 
 #define TYPHOON_REG_BOOT_RECORD_ADDR_HI		TYPHOON_REG_HOST2ARM2
 #define TYPHOON_REG_BOOT_RECORD_ADDR_LO		TYPHOON_REG_HOST2ARM1
