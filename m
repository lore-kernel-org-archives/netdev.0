From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net] net: stmmac: fix completely hung TX when using TSO
Date: Tue, 6 Jun 2017 09:25:00 +0200
Message-ID: <20170606072501.16560-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stmmac_tso_allocator can fail to set the Last Descriptor bit
on a descriptor that actually was the last descriptor.

This happens when the buffer of the last descriptor ends
up having a size of exactly TSO_MAX_BUFF_SIZE.

When the IP eventually reaches the next last descriptor,
which actually has the bit set, the DMA will hang.

When the DMA hangs, we get a tx timeout, however,
since stmmac does not do a complete reset of the IP
in stmmac_tx_timeout, we end up in a state with
completely hung TX.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 68a188e74c54..440bea049a7f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2723,7 +2723,7 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
 
 		priv->hw->desc->prepare_tso_tx_desc(desc, 0, buff_size,
 			0, 1,
-			(last_segment) && (buff_size < TSO_MAX_BUFF_SIZE),
+			(last_segment) && (tmp_len <= TSO_MAX_BUFF_SIZE),
 			0, 0);
 
 		tmp_len -= TSO_MAX_BUFF_SIZE;
-- 
2.11.0
