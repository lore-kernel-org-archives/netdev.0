From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] dsa: b53: avoid 'maybe-uninitialized' warning
Date: Mon, 27 Jun 2016 11:19:13 +0200
Message-ID: <20160627091926.1377587-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some configurations, gcc produces a warning for correct code
in this driver:

drivers/net/dsa/b53/b53_mmap.c: In function 'b53_mmap_read64':
drivers/net/dsa/b53/b53_mmap.c:107:10: error: 'hi' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  *val = ((u64)hi << 32) | lo;
          ^~~~~~~
drivers/net/dsa/b53/b53_mmap.c: In function 'b53_mmap_read48':
drivers/net/dsa/b53/b53_mmap.c:91:11: error: 'hi' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   *val = ((u64)hi << 32) | lo;
           ^~~~~~~
drivers/net/dsa/b53/b53_mmap.c:83:11: error: 'hi' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   *val = ((u64)hi << 16) | lo;

I have seen the warning before and at the time thought I had fixed
it with 55e7f6abe131 ("dsa: b53: fix big-endian register access"),
however it now came back in a different randconfig build that happens
to have different inlining decisions in the compiler.

The mistake that gcc makes here is that it thinks the second call to
readl() might fail because the address 'reg + 4' is not a multiple
of four despite having knowing that 'reg' itself is a multiple of four.

By open-coding the two reads without the redundant alignment check,
we can avoid the warning and produce slightly better object code, but
get slightly longer source code instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/dsa/b53/b53_mmap.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index b70daf9174d4..21f1068b0804 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -70,6 +70,8 @@ static int b53_mmap_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
 
 static int b53_mmap_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
 {
+	u8 __iomem *regs = dev->priv;
+
 	if (WARN_ON(reg % 2))
 		return -EINVAL;
 
@@ -77,16 +79,26 @@ static int b53_mmap_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
 		u16 lo;
 		u32 hi;
 
-		b53_mmap_read16(dev, page, reg, &lo);
-		b53_mmap_read32(dev, page, reg + 2, &hi);
+		if (dev->pdata && dev->pdata->big_endian) {
+			lo = ioread16be(regs + (page << 8) + reg);
+			hi = ioread32be(regs + (page << 8) + reg + 2);
+		} else {
+			lo = readw(regs + (page << 8) + reg);
+			hi = readl(regs + (page << 8) + reg + 2);
+		}
 
 		*val = ((u64)hi << 16) | lo;
 	} else {
 		u32 lo;
 		u16 hi;
 
-		b53_mmap_read32(dev, page, reg, &lo);
-		b53_mmap_read16(dev, page, reg + 4, &hi);
+		if (dev->pdata && dev->pdata->big_endian) {
+			lo = ioread32be(regs + (page << 8) + reg);
+			hi = ioread16be(regs + (page << 8) + reg + 4);
+		} else {
+			lo = readl(regs + (page << 8) + reg);
+			hi = readw(regs + (page << 8) + reg + 4);
+		}
 
 		*val = ((u64)hi << 32) | lo;
 	}
@@ -96,13 +108,19 @@ static int b53_mmap_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
 
 static int b53_mmap_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
 {
+	u8 __iomem *regs = dev->priv;
 	u32 hi, lo;
 
 	if (WARN_ON(reg % 4))
 		return -EINVAL;
 
-	b53_mmap_read32(dev, page, reg, &lo);
-	b53_mmap_read32(dev, page, reg + 4, &hi);
+	if (dev->pdata && dev->pdata->big_endian) {
+		lo = ioread32be(regs + (page << 8) + reg);
+		hi = ioread32be(regs + (page << 8) + reg + 4);
+	} else {
+		lo = readl(regs + (page << 8) + reg);
+		hi = readl(regs + (page << 8) + reg + 4);
+	}
 
 	*val = ((u64)hi << 32) | lo;
 
-- 
2.9.0
