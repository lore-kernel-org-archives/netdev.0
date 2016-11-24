From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] irda: fix overly long udelay()
Date: Thu, 24 Nov 2016 17:26:22 +0100
Message-ID: <20161124162630.3802535-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

irda_get_mtt() returns a hardcoded '10000' in some cases,
and with gcc-7, we get a build error because this triggers a
compile-time check in udelay():

drivers/net/irda/w83977af_ir.o: In function `w83977af_hard_xmit':
w83977af_ir.c:(.text.w83977af_hard_xmit+0x14c): undefined reference to `__bad_udelay'

Older compilers did not run into this because they either did not
completely inline the irda_get_mtt() or did not consider the
10000 value a constant expression.

The code has been wrong since the start of git history.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/irda/w83977af_ir.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 4e3d2e7c697c..e8c3a8c32534 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -518,7 +518,9 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		
 		mtt = irda_get_mtt(skb);
 		pr_debug("%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
-			if (mtt)
+			if (mtt > 1000)
+				mdelay(mtt/1000);
+			else if (mtt)
 				udelay(mtt);
 
 			/* Enable DMA interrupt */
-- 
2.9.0
