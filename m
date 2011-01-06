From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Madge Ambassador ATM Adapter driver: Always release_firmware()
 in ucode_init() and don't leak memory.
Date: Thu, 6 Jan 2011 22:06:37 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101062203160.13988@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Failure to call release_firmware() will result in memory leak in 
drivers/atm/ambassador.c::ucode_init().
This patch makes sure we always call release_firmware() when needed, thus 
removing the leak(s).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ambassador.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

  Compile tested only since I have no way to actually test this.

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index ffe9b65..ab56539 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -1927,7 +1927,7 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   unsigned long start_address;
   const struct ihex_binrec *rec;
   int res;
-  
+
   res = request_ihex_firmware(&fw, "atmsar11.fw", &dev->pci_dev->dev);
   if (res) {
     PRINTK (KERN_ERR, "Cannot load microcode data");
@@ -1937,6 +1937,7 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   /* First record contains just the start address */
   rec = (const struct ihex_binrec *)fw->data;
   if (be16_to_cpu(rec->len) != sizeof(__be32) || be32_to_cpu(rec->addr)) {
+    release_firmware(fw);
     PRINTK (KERN_ERR, "Bad microcode data (no start record)");
     return -EINVAL;
   }
@@ -1950,10 +1951,12 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
     PRINTD (DBG_LOAD, "starting region (%x, %u)", be32_to_cpu(rec->addr),
 	    be16_to_cpu(rec->len));
     if (be16_to_cpu(rec->len) > 4 * MAX_TRANSFER_DATA) {
+	    release_firmware(fw);
 	    PRINTK (KERN_ERR, "Bad microcode data (record too long)");
 	    return -EINVAL;
     }
     if (be16_to_cpu(rec->len) & 3) {
+	    release_firmware(fw);
 	    PRINTK (KERN_ERR, "Bad microcode data (odd number of bytes)");
 	    return -EINVAL;
     }



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
