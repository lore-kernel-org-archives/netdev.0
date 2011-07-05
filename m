From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 4/6] r8169: add ERI functions
Date: Tue, 5 Jul 2011 17:44:53 +0800
Message-ID: <1309859095-32031-4-git-send-email-hayeswang@realtek.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the ERI functions which would be used by the new chips.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3aeae68..fa2c139 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1046,6 +1046,49 @@ static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
 	return value;
 }
 
+static
+void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
+{
+	unsigned int i;
+
+	BUG_ON((addr & 3) || (mask == 0));
+	RTL_W32(ERIDR, val);
+	RTL_W32(ERIAR, ERIAR_WRITE_CMD | type | mask | addr);
+
+	for (i = 0; i < 100; i++) {
+		udelay(100);
+		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
+			break;
+	}
+}
+
+static  u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
+{
+	unsigned int i;
+	u32 value = ~0x00;
+
+	RTL_W32(ERIAR, ERIAR_READ_CMD | type | ERIAR_MASK_1111 | addr);
+
+	for (i = 0; i < 100; i++) {
+		udelay(100);
+		if (RTL_R32(ERIAR) & ERIAR_FLAG) {
+			value = RTL_R32(ERIDR);
+			break;
+		}
+	}
+
+	return value;
+}
+
+static void
+rtl_eri_write_w0w1(void __iomem *ioaddr, int addr, u32 mask, u32 m, u32 p, int type)
+{
+	u32 val;
+
+	val = rtl_eri_read(ioaddr, addr, type);
+	rtl_eri_write(ioaddr, addr, mask, (val & ~m) | p, type);
+}
+
 static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 {
 	u8 value = 0xff;
-- 
1.7.3.2
