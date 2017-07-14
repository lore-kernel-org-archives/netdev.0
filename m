From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 02/22] scsi: megaraid: fix format-overflow warning
Date: Fri, 14 Jul 2017 14:06:54 +0200
Message-ID: <20170714120720.906842-3-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>, megaraidlinux.pdl@broadcom.com
To: linux-kernel@vger.kernel.org,
        Kashyap Desai <kashyap.desai@broadcom.com>,
        Sumit Saxena <sumit.saxena@broadcom.com>,
        Shivasharan S <shivasharan.srikanteshwara@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 complains that the firmware version strings might overflow
for some values:

drivers/scsi/megaraid.c: In function 'megaraid_probe_one':
drivers/scsi/megaraid.c:314:33: error: '%d' directive writing between 1 and 2 bytes into a region of size between 1 and 2 [-Werror=format-overflow=]
drivers/scsi/megaraid.c:314:33: note: directive argument in the range [0, 15]
drivers/scsi/megaraid.c:314:3: note: 'sprintf' output between 7 and 9 bytes into a destination of size 7
drivers/scsi/megaraid.c:320:35: error: '%d' directive writing between 1 and 2 bytes into a region of size between 1 and 2 [-Werror=format-overflow=]
drivers/scsi/megaraid.c:320:35: note: directive argument in the range [0, 15]
drivers/scsi/megaraid.c:320:3: note: 'sprintf' output between 7 and 9 bytes into a destination of size 7

This makes the code use a truncating snprintf() instead, which shuts
up that warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/megaraid.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 3c63c292cb92..7195cff51d4c 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -311,13 +311,15 @@ mega_query_adapter(adapter_t *adapter)
 	   right 8 bits making them zero. This 0 value was hardcoded to fix
 	   sparse warnings. */
 	if (adapter->product_info.subsysvid == PCI_VENDOR_ID_HP) {
-		sprintf (adapter->fw_version, "%c%d%d.%d%d",
+		snprintf(adapter->fw_version, sizeof(adapter->fw_version),
+			 "%c%d%d.%d%d",
 			 adapter->product_info.fw_version[2],
 			 0,
 			 adapter->product_info.fw_version[1] & 0x0f,
 			 0,
 			 adapter->product_info.fw_version[0] & 0x0f);
-		sprintf (adapter->bios_version, "%c%d%d.%d%d",
+		snprintf(adapter->bios_version, sizeof(adapter->fw_version),
+			 "%c%d%d.%d%d",
 			 adapter->product_info.bios_version[2],
 			 0,
 			 adapter->product_info.bios_version[1] & 0x0f,
-- 
2.9.0
