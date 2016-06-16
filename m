From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] dsa: b53: fix big-endian register access
Date: Thu, 16 Jun 2016 11:00:05 +0200
Message-ID: <20160616090017.912604-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The b53 dsa register access confusingly uses __raw register accessors
when both the CPU and the device are big-endian, but it uses little-
endian accessors when the same device is used from a little-endian
CPU, which makes no sense.

This uses normal accessors in device-endianess all the time, which
will work in all four combinations of register and CPU endianess,
and it will have the same barrier semantics in all cases.

This also seems to take care of a (false positive) warning I'm getting:

drivers/net/dsa/b53/b53_mmap.c: In function 'b53_mmap_read64':
drivers/net/dsa/b53/b53_mmap.c:109:10: error: 'hi' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  *val = ((u64)hi << 32) | lo;

I originally planned to submit another patch for that warning
and did this one as a preparation cleanup, but it does seem to be
sufficient by itself.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/dsa/b53/b53_mmap.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index f115ee25c0e8..b70daf9174d4 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -45,9 +45,8 @@ static int b53_mmap_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
 	if (WARN_ON(reg % 2))
 		return -EINVAL;
 
-	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
-	    dev->pdata->big_endian)
-		*val = __raw_readw(regs + (page << 8) + reg);
+	if (dev->pdata && dev->pdata->big_endian)
+		*val = ioread16be(regs + (page << 8) + reg);
 	else
 		*val = readw(regs + (page << 8) + reg);
 
@@ -61,9 +60,8 @@ static int b53_mmap_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
 	if (WARN_ON(reg % 4))
 		return -EINVAL;
 
-	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
-	    dev->pdata->big_endian)
-		*val = __raw_readl(regs + (page << 8) + reg);
+	if (dev->pdata && dev->pdata->big_endian)
+		*val = ioread32be(regs + (page << 8) + reg);
 	else
 		*val = readl(regs + (page << 8) + reg);
 
@@ -128,9 +126,8 @@ static int b53_mmap_write16(struct b53_device *dev, u8 page, u8 reg,
 	if (WARN_ON(reg % 2))
 		return -EINVAL;
 
-	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
-	    dev->pdata->big_endian)
-		__raw_writew(value, regs + (page << 8) + reg);
+	if (dev->pdata && dev->pdata->big_endian)
+		iowrite16be(value, regs + (page << 8) + reg);
 	else
 		writew(value, regs + (page << 8) + reg);
 
@@ -145,9 +142,8 @@ static int b53_mmap_write32(struct b53_device *dev, u8 page, u8 reg,
 	if (WARN_ON(reg % 4))
 		return -EINVAL;
 
-	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) && dev->pdata &&
-	    dev->pdata->big_endian)
-		__raw_writel(value, regs + (page << 8) + reg);
+	if (dev->pdata && dev->pdata->big_endian)
+		iowrite32be(value, regs + (page << 8) + reg);
 	else
 		writel(value, regs + (page << 8) + reg);
 
-- 
2.9.0
