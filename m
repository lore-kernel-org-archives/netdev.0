From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 26/33] arcnet: com90xx: Use arcnet_readb/writeb routines
Date: Tue, 22 Sep 2015 11:02:07 +0200
Message-ID: <1442912534-10821-27-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35048 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Simplify and make consistent the current uses of readb/writeb
by using the newly introduced arcnet_<I/O> equivalents.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com90xx.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index f1cfeb0..a97d086 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -88,6 +88,8 @@ static int numcards;
 #define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
 #define COM9026_REG_W_ADDR_HI	15
 
+#define COM9026_REG_R_STATION	1	/* Station ID */
+
 static int com90xx_skip_probe __initdata = 0;
 
 /* Module parameters */
@@ -239,9 +241,10 @@ static void __init com90xx_probe(void)
 				numprint = 0;
 			goto out1;
 		}
-		if (readb(base) != TESTvalue) {
+		if (arcnet_readb(base, COM9026_REG_R_STATUS) != TESTvalue) {
 			arc_cont(D_INIT_REASONS, "(%02Xh != %02Xh)\n",
-				 readb(base), TESTvalue);
+				 arcnet_readb(base, COM9026_REG_R_STATUS),
+				 TESTvalue);
 			arc_cont(D_INIT_REASONS, "S3: ");
 			if (BUGLVL(D_INIT_REASONS))
 				numprint = 0;
@@ -252,8 +255,8 @@ static void __init com90xx_probe(void)
 		 * in another pass through this loop, they will be discarded
 		 * because *cptr != TESTvalue.
 		 */
-		writeb(0x42, base);
-		if (readb(base) != 0x42) {
+		arcnet_writeb(0x42, base, COM9026_REG_W_INTMASK);
+		if (arcnet_readb(base, COM9026_REG_R_STATUS) != 0x42) {
 			arc_cont(D_INIT_REASONS, "(read only)\n");
 			arc_cont(D_INIT_REASONS, "S3: ");
 			goto out2;
@@ -384,7 +387,8 @@ static void __init com90xx_probe(void)
 			mdelay(RESETtime);
 		} else {
 			/* just one shmem and port, assume they match */
-			writeb(TESTvalue, iomem[0]);
+			arcnet_writeb(TESTvalue, iomem[0],
+				      COM9026_REG_W_INTMASK);
 		}
 #else
 		arcnet_inb(ioaddr, COM9026_REG_R_RESET);
@@ -395,7 +399,7 @@ static void __init com90xx_probe(void)
 			u_long ptr = shmems[index];
 			void __iomem *base = iomem[index];
 
-			if (readb(base) == TESTvalue) {	/* found one */
+			if (arcnet_readb(base, COM9026_REG_R_STATUS) == TESTvalue) {	/* found one */
 				arc_cont(D_INIT, "%lXh)\n", *p);
 				openparen = 0;
 
@@ -409,7 +413,8 @@ static void __init com90xx_probe(void)
 				iomem[index] = iomem[numshmems];
 				break;	/* go to the next I/O port */
 			} else {
-				arc_cont(D_INIT_REASONS, "%Xh-", readb(base));
+				arc_cont(D_INIT_REASONS, "%Xh-",
+					 arcnet_readb(base, COM9026_REG_R_STATUS));
 			}
 		}
 
@@ -431,7 +436,7 @@ static void __init com90xx_probe(void)
 
 	/* Now put back TESTvalue on all leftover shmems. */
 	for (index = 0; index < numshmems; index++) {
-		writeb(TESTvalue, iomem[index]);
+		arcnet_writeb(TESTvalue, iomem[index], COM9026_REG_W_INTMASK);
 		iounmap(iomem[index]);
 		release_mem_region(shmems[index], MIRROR_SIZE);
 	}
@@ -449,7 +454,7 @@ static int check_mirror(unsigned long addr, size_t size)
 
 	p = ioremap(addr, size);
 	if (p) {
-		if (readb(p) == TESTvalue)
+		if (arcnet_readb(p, COM9026_REG_R_STATUS) == TESTvalue)
 			res = 1;
 		else
 			res = 0;
@@ -487,7 +492,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem,
 	 * 2k (or there are no mirrors at all) but on some, it's 4k.
 	 */
 	mirror_size = MIRROR_SIZE;
-	if (readb(p) == TESTvalue &&
+	if (arcnet_readb(p, COM9026_REG_R_STATUS) == TESTvalue &&
 	    check_mirror(shmem - MIRROR_SIZE, MIRROR_SIZE) == 0 &&
 	    check_mirror(shmem - 2 * MIRROR_SIZE, MIRROR_SIZE) == 1)
 		mirror_size = 2 * MIRROR_SIZE;
@@ -537,7 +542,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem,
 	}
 
 	/* get and check the station ID from offset 1 in shmem */
-	dev->dev_addr[0] = readb(lp->mem_start + 1);
+	dev->dev_addr[0] = arcnet_readb(lp->mem_start, COM9026_REG_R_STATION);
 
 	dev->base_addr = ioaddr;
 
@@ -616,7 +621,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 #endif
 
 	/* verify that the ARCnet signature byte is present */
-	if (readb(lp->mem_start) != TESTvalue) {
+	if (arcnet_readb(lp->mem_start, COM9026_REG_R_STATUS) != TESTvalue) {
 		if (really_reset)
 			arc_printk(D_NORMAL, dev, "reset failed: TESTvalue not present.\n");
 		return 1;
-- 
2.5.1
