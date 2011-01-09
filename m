From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH v2] Madge Ambassador ATM Adapter driver: Always release_firmware()
 in ucode_init() and don't leak memory.
Date: Sun, 9 Jan 2011 22:32:38 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101092229160.633@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101062203160.13988@swampdragon.chaosbits.net> <20110107100239.28032e5d@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110107100239.28032e5d@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Jan 2011, chas williams - CONTRACTOR wrote:

> instead of duplicating the same section again and again, could you
> write something like:
> 
> 	errmsg = "no start record";
> 	goto fail;
> 
> 	...
> 
> 	errmsg = "record to long"
> 	goto fail;
> 
> 	.... whatever ...
> 
> 	return 0;
> 
> fail:
> 	release_firmware(fw)
> 	PRINTK(KERN_ERR, "Bad microcode data (%s)\n", errmsg);
> 	return -EINVAL;
> }
> 

Sure, we can do that instead.

Failure to call release_firmware() will result in memory leak in
drivers/atm/ambassador.c::ucode_init().
This patch makes sure we always call release_firmware() when needed, 
thus removing the leak(s).

Yes, I know checkpatch complains about this patch, but it was either that 
or completely mess up the existing style, so I opted to use the existing 
style and live with the checkpatch related flak.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ambassador.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

  compile tested only.

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index ffe9b65..9f47e86 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -1926,8 +1926,9 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   const struct firmware *fw;
   unsigned long start_address;
   const struct ihex_binrec *rec;
+  const char *errmsg = 0;
   int res;
-  
+
   res = request_ihex_firmware(&fw, "atmsar11.fw", &dev->pci_dev->dev);
   if (res) {
     PRINTK (KERN_ERR, "Cannot load microcode data");
@@ -1937,8 +1938,8 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   /* First record contains just the start address */
   rec = (const struct ihex_binrec *)fw->data;
   if (be16_to_cpu(rec->len) != sizeof(__be32) || be32_to_cpu(rec->addr)) {
-    PRINTK (KERN_ERR, "Bad microcode data (no start record)");
-    return -EINVAL;
+    errmsg = "no start record";
+    goto fail;
   }
   start_address = be32_to_cpup((__be32 *)rec->data);
 
@@ -1950,12 +1951,12 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
     PRINTD (DBG_LOAD, "starting region (%x, %u)", be32_to_cpu(rec->addr),
 	    be16_to_cpu(rec->len));
     if (be16_to_cpu(rec->len) > 4 * MAX_TRANSFER_DATA) {
-	    PRINTK (KERN_ERR, "Bad microcode data (record too long)");
-	    return -EINVAL;
+	    errmsg = "record too long";
+	    goto fail;
     }
     if (be16_to_cpu(rec->len) & 3) {
-	    PRINTK (KERN_ERR, "Bad microcode data (odd number of bytes)");
-	    return -EINVAL;
+	    errmsg = "odd number of bytes";
+	    goto fail;
     }
     res = loader_write(lb, dev, rec);
     if (res)
@@ -1970,6 +1971,10 @@ static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
     res = loader_start(lb, dev, start_address);
 
   return res;
+fail:
+  release_firmware(fw);
+  PRINTK(KERN_ERR, "Bad microcode data (%s)", errmsg);
+  return -EINVAL;
 }
 
 /********** give adapter parameters **********/



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
