From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next?] hns: avoid stack overflow with CONFIG_KASAN
Date: Fri,  3 Feb 2017 17:35:46 +0100
Message-ID: <20170203163607.3488037-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        Kejian Yan <yankejian@huawei.com>,
        Lisheng <lisheng011@huawei.com>, oulijun <oulijun@huawei.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of ACCESS_ONCE() looks like a micro-optimization to force gcc to use
an indexed load for the register address, but it has an absolutely detrimental
effect on builds with gcc-5 and CONFIG_KASAN=y, leading to a very likely
kernel stack overflow aside from very complex object code:

hisilicon/hns/hns_dsaf_gmac.c: In function 'hns_gmac_update_stats':
hisilicon/hns/hns_dsaf_gmac.c:419:1: error: the frame size of 2912 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_ppe.c: In function 'hns_ppe_reset_common':
hisilicon/hns/hns_dsaf_ppe.c:390:1: error: the frame size of 1184 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_ppe.c: In function 'hns_ppe_get_regs':
hisilicon/hns/hns_dsaf_ppe.c:621:1: error: the frame size of 3632 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_rcb.c: In function 'hns_rcb_get_common_regs':
hisilicon/hns/hns_dsaf_rcb.c:970:1: error: the frame size of 2784 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_gmac.c: In function 'hns_gmac_get_regs':
hisilicon/hns/hns_dsaf_gmac.c:641:1: error: the frame size of 5728 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_rcb.c: In function 'hns_rcb_get_ring_regs':
hisilicon/hns/hns_dsaf_rcb.c:1021:1: error: the frame size of 2208 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_comm_init':
hisilicon/hns/hns_dsaf_main.c:1209:1: error: the frame size of 1904 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_xgmac.c: In function 'hns_xgmac_get_regs':
hisilicon/hns/hns_dsaf_xgmac.c:748:1: error: the frame size of 4704 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_update_stats':
hisilicon/hns/hns_dsaf_main.c:2420:1: error: the frame size of 1088 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_regs':
hisilicon/hns/hns_dsaf_main.c:2753:1: error: the frame size of 10768 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

This does not seem to happen any more with gcc-7, but removing the ACCESS_ONCE
seems safe anyway and it avoids a serious issue for some people. I have verified
that with gcc-5.3.1, the object code we get is better in the new version
both with and without CONFIG_KASAN, as we no longer allocate a 1344 byte
stack frame for hns_dsaf_get_regs() but otherwise have practically identical
object code.

With gcc-7.0.0, removing ACCESS_ONCE has no effect, the object code is already
good either way.

This patch is probably not urgent to get into 4.11 as only KASAN=y builds
with certain compilers are affected, but I still think it makes sense to
backport into older kernels.

Cc: stable@vger.kernel.org
Fixes: 511e6bc ("net: add Hisilicon Network Subsystem DSAF support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 87226685f742..8fa18fc17cd2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -1014,9 +1014,7 @@
 
 static inline void dsaf_write_reg(void __iomem *base, u32 reg, u32 value)
 {
-	u8 __iomem *reg_addr = ACCESS_ONCE(base);
-
-	writel(value, reg_addr + reg);
+	writel(value, base + reg);
 }
 
 #define dsaf_write_dev(a, reg, value) \
@@ -1024,9 +1022,7 @@ static inline void dsaf_write_reg(void __iomem *base, u32 reg, u32 value)
 
 static inline u32 dsaf_read_reg(u8 __iomem *base, u32 reg)
 {
-	u8 __iomem *reg_addr = ACCESS_ONCE(base);
-
-	return readl(reg_addr + reg);
+	return readl(base + reg);
 }
 
 static inline void dsaf_write_syscon(struct regmap *base, u32 reg, u32 value)
-- 
2.9.0
