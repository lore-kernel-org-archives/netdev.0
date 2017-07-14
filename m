From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 05/22] scsi: gdth: avoid buffer overflow warning
Date: Fri, 14 Jul 2017 14:06:57 +0200
Message-ID: <20170714120720.906842-6-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        David Howells <dhowells@redhat.com>
To: linux-kernel@vger.kernel.org,
        Achim Leubner <achim_leubner@adaptec.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc notices that we would overflow the buffer for the
inquiry of the product name if we have too many adapters:

drivers/scsi/gdth.c: In function 'gdth_next':
drivers/scsi/gdth.c:2357:29: warning: 'sprintf' may write a terminating nul past the end of the destination [-Wformat-overflow=]
         sprintf(inq.product,"Host Drive  #%02d",t);
                             ^~~~~~~~~~~~~~~~~~~
drivers/scsi/gdth.c:2357:9: note: 'sprintf' output between 16 and 17 bytes into a destination of size 16
         sprintf(inq.product,"Host Drive  #%02d",t);

This won't happen in practice, so just use snprintf to
truncate the string.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/gdth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index facc7271f932..a4473356a9dc 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -2354,7 +2354,7 @@ static int gdth_internal_cache_cmd(gdth_ha_str *ha, Scsi_Cmnd *scp)
         inq.resp_aenc = 2;
         inq.add_length= 32;
         strcpy(inq.vendor,ha->oem_name);
-        sprintf(inq.product,"Host Drive  #%02d",t);
+        snprintf(inq.product, sizeof(inq.product), "Host Drive  #%02d",t);
         strcpy(inq.revision,"   ");
         gdth_copy_internal_data(ha, scp, (char*)&inq, sizeof(gdth_inq_data));
         break;
-- 
2.9.0
