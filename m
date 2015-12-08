From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: ezchip: fix address space confusion in nps_enet.c
Date: Tue, 08 Dec 2015 16:28:59 +0100
Message-ID: <33732958.3idC7H2UPT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nps_enet driver happily mixes virtual, physical and __iomem
addresses, which are all different depending on the architecture
and configuration.  That causes a warning when building the code
on ARM with LPAE mode enabled:

drivers/net/ethernet/ezchip/nps_enet.c: In function 'nps_enet_send_frame':
drivers/net/ethernet/ezchip/nps_enet.c:370:13: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]

but will also fail to work for other reasons.

In this patch, I'm trying to change the code to use only normal
kernel pointers, which I assume is what the author actually meant:

* For reading or writing a 32-bit word that may be unaligned when
  an SKB contains unaligned data, I'm using get_unaligned/put_unaligned()
  rather than memcpy_fromio/toio.

* For converting a u8 pointer to a u32 pointer, I use a cast rather
  than the incorrect virt_to_phys.

* For copying a couple of bytes from one place to another while respecting
  alignment, I use memcpy instead of memcpy_toio.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ezchip/nps_enet.c | 30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

It would be helpful to test this patch on real hardware before it gets applied.

The current behavior is so obscure that it's hard to know what the author
of the code actually intended to happen here, this is based on my best guess.


diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 63c2bcf8031a..b1026689b78f 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -48,21 +48,15 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
 			*reg = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
 	else { /* !dst_is_aligned */
 		for (i = 0; i < len; i++, reg++) {
-			u32 buf =
-				nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
-
-			/* to accommodate word-unaligned address of "reg"
-			 * we have to do memcpy_toio() instead of simple "=".
-			 */
-			memcpy_toio((void __iomem *)reg, &buf, sizeof(buf));
+			u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+			put_unaligned(buf, reg);
 		}
 	}
 
 	/* copy last bytes (if any) */
 	if (last) {
 		u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
-
-		memcpy_toio((void __iomem *)reg, &buf, last);
+		memcpy((u8*)reg, &buf, last);
 	}
 }
 
@@ -367,7 +361,7 @@ static void nps_enet_send_frame(struct net_device *ndev,
 	struct nps_enet_tx_ctl tx_ctrl;
 	short length = skb->len;
 	u32 i, len = DIV_ROUND_UP(length, sizeof(u32));
-	u32 *src = (u32 *)virt_to_phys(skb->data);
+	u32 *src = (void *)skb->data;
 	bool src_is_aligned = IS_ALIGNED((unsigned long)src, sizeof(u32));
 
 	tx_ctrl.value = 0;
@@ -375,17 +369,11 @@ static void nps_enet_send_frame(struct net_device *ndev,
 	if (src_is_aligned)
 		for (i = 0; i < len; i++, src++)
 			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, *src);
-	else { /* !src_is_aligned */
-		for (i = 0; i < len; i++, src++) {
-			u32 buf;
-
-			/* to accommodate word-unaligned address of "src"
-			 * we have to do memcpy_fromio() instead of simple "="
-			 */
-			memcpy_fromio(&buf, (void __iomem *)src, sizeof(buf));
-			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, buf);
-		}
-	}
+	else /* !src_is_aligned */
+		for (i = 0; i < len; i++, src++)
+			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF,
+					 get_unaligned(src));
+
 	/* Write the length of the Frame */
 	tx_ctrl.nt = length;
 
-- 
2.1.0.rc2
