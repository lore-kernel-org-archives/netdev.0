From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [RFC][PATCH 1/2] bgmac: separate RX desc setup code
	into new function
Date: Sun, 11 Aug 2013 19:49:14 +0200
Message-ID: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
Reply-To: OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org,
 Hauke Mehrtens <hauke@hauke-m.de>, Florian Fainelli <f.fainelli@gmail.com>,
 Jonas Gorski <jogo@openwrt.org>, Robert Bradley <robert.bradley1@gmail.com>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

---
 drivers/net/ethernet/broadcom/bgmac.c |   41 ++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 1b8e7a3..e70ee43 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -268,6 +268,26 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 	return 0;
 }
 
+static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
+				    struct bgmac_dma_ring *ring, int desc_idx)
+{
+	struct bgmac_dma_desc *dma_desc = ring->cpu_base + desc_idx;
+	u32 ctl0 = 0, ctl1 = 0;
+
+	if (desc_idx == ring->num_slots - 1)
+		ctl0 |= BGMAC_DESC_CTL0_EOT;
+	ctl1 |= BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
+	/* Is there any BGMAC device that requires extension? */
+	/* ctl1 |= (addrext << B43_DMA64_DCTL1_ADDREXT_SHIFT) &
+	 * B43_DMA64_DCTL1_ADDREXT_MASK;
+	 */
+
+	dma_desc->addr_low = cpu_to_le32(lower_32_bits(ring->slots[desc_idx].dma_addr));
+	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
+	dma_desc->ctl0 = cpu_to_le32(ctl0);
+	dma_desc->ctl1 = cpu_to_le32(ctl1);
+}
+
 static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			     int weight)
 {
@@ -484,8 +504,6 @@ err_dma_free:
 static void bgmac_dma_init(struct bgmac *bgmac)
 {
 	struct bgmac_dma_ring *ring;
-	struct bgmac_dma_desc *dma_desc;
-	u32 ctl0, ctl1;
 	int i;
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
@@ -514,23 +532,8 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGHI,
 			    upper_32_bits(ring->dma_base));
 
-		for (j = 0, dma_desc = ring->cpu_base; j < ring->num_slots;
-		     j++, dma_desc++) {
-			ctl0 = ctl1 = 0;
-
-			if (j == ring->num_slots - 1)
-				ctl0 |= BGMAC_DESC_CTL0_EOT;
-			ctl1 |= BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
-			/* Is there any BGMAC device that requires extension? */
-			/* ctl1 |= (addrext << B43_DMA64_DCTL1_ADDREXT_SHIFT) &
-			 * B43_DMA64_DCTL1_ADDREXT_MASK;
-			 */
-
-			dma_desc->addr_low = cpu_to_le32(lower_32_bits(ring->slots[j].dma_addr));
-			dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[j].dma_addr));
-			dma_desc->ctl0 = cpu_to_le32(ctl0);
-			dma_desc->ctl1 = cpu_to_le32(ctl1);
-		}
+		for (j = 0; j < ring->num_slots; j++)
+			bgmac_dma_rx_setup_desc(bgmac, ring, j);
 
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
 			    ring->num_slots * sizeof(struct bgmac_dma_desc));
-- 
1.7.10.4
