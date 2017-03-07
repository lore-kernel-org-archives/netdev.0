From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 03/22] net: mvpp2: remove support for buffer header
Date: Tue,  7 Mar 2017 16:53:01 +0100
Message-ID: <1488902000-2658-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The "buffer header" functionality is a functionality used by the
hardware to split an incoming packets over multiple BM buffers if they
are not large enough. However, the mvpp2 driver guarantees that a pool
of BM buffers has buffers with a size large enough to store MTU-sized
packets. Therefore, this functionality is completely unused, and the
code can be removed, and we should never get a descriptor with bit
MVPP2_RXD_BUF_HDR set.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 77 ------------------------------------
 1 file changed, 77 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 6a4d126..fb8b5e9 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -215,9 +215,6 @@
 #define     MVPP2_BM_PHY_RLS_PRIO_EN_MASK	BIT(1)
 #define     MVPP2_BM_PHY_RLS_GRNTD_MASK		BIT(2)
 #define MVPP2_BM_VIRT_RLS_REG			0x64c0
-#define MVPP2_BM_MC_RLS_REG			0x64c4
-#define     MVPP2_BM_MC_ID_MASK			0xfff
-#define     MVPP2_BM_FORCE_RELEASE_MASK		BIT(12)
 
 /* TX Scheduler registers */
 #define MVPP2_TXP_SCHED_PORT_INDEX_REG		0x8000
@@ -929,22 +926,6 @@ struct mvpp2_bm_pool {
 	u32 port_map;
 };
 
-struct mvpp2_buff_hdr {
-	u32 next_buff_dma_addr;
-	u32 next_buff_virt_addr;
-	u16 byte_count;
-	u16 info;
-	u8  reserved1;		/* bm_qset (for future use, BM)		*/
-};
-
-/* Buffer header info bits */
-#define MVPP2_B_HDR_INFO_MC_ID_MASK	0xfff
-#define MVPP2_B_HDR_INFO_MC_ID(info)	((info) & MVPP2_B_HDR_INFO_MC_ID_MASK)
-#define MVPP2_B_HDR_INFO_LAST_OFFS	12
-#define MVPP2_B_HDR_INFO_LAST_MASK	BIT(12)
-#define MVPP2_B_HDR_INFO_IS_LAST(info) \
-	   ((info & MVPP2_B_HDR_INFO_LAST_MASK) >> MVPP2_B_HDR_INFO_LAST_OFFS)
-
 /* Static declaractions */
 
 /* Number of RXQs used by single port */
@@ -3611,22 +3592,6 @@ static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
 	mvpp2_write(port->priv, MVPP2_BM_PHY_RLS_REG(pool), buf_dma_addr);
 }
 
-/* Release multicast buffer */
-static void mvpp2_bm_pool_mc_put(struct mvpp2_port *port, int pool,
-				 dma_addr_t buf_dma_addr,
-				 unsigned long buf_virt_addr,
-				 int mc_id)
-{
-	u32 val = 0;
-
-	val |= (mc_id & MVPP2_BM_MC_ID_MASK);
-	mvpp2_write(port->priv, MVPP2_BM_MC_RLS_REG, val);
-
-	mvpp2_bm_pool_put(port, pool,
-			  buf_dma_addr | MVPP2_BM_PHY_RLS_MC_BUFF_MASK,
-			  buf_virt_addr);
-}
-
 /* Refill BM pool */
 static void mvpp2_pool_refill(struct mvpp2_port *port, u32 bm,
 			      dma_addr_t dma_addr,
@@ -5075,43 +5040,6 @@ static u32 mvpp2_skb_tx_csum(struct mvpp2_port *port, struct sk_buff *skb)
 	return MVPP2_TXD_L4_CSUM_NOT | MVPP2_TXD_IP_CSUM_DISABLE;
 }
 
-static void mvpp2_buff_hdr_rx(struct mvpp2_port *port,
-			      struct mvpp2_rx_desc *rx_desc)
-{
-	struct mvpp2_buff_hdr *buff_hdr;
-	struct sk_buff *skb;
-	u32 rx_status = rx_desc->status;
-	dma_addr_t buff_dma_addr;
-	unsigned long buff_virt_addr;
-	dma_addr_t buff_dma_addr_next;
-	unsigned long buff_virt_addr_next;
-	int mc_id;
-	int pool_id;
-
-	pool_id = (rx_status & MVPP2_RXD_BM_POOL_ID_MASK) >>
-		   MVPP2_RXD_BM_POOL_ID_OFFS;
-	buff_dma_addr = rx_desc->buf_dma_addr;
-	buff_virt_addr = rx_desc->buf_cookie;
-
-	do {
-		skb = (struct sk_buff *)buff_virt_addr;
-		buff_hdr = (struct mvpp2_buff_hdr *)skb->head;
-
-		mc_id = MVPP2_B_HDR_INFO_MC_ID(buff_hdr->info);
-
-		buff_dma_addr_next = buff_hdr->next_buff_dma_addr;
-		buff_virt_addr_next = buff_hdr->next_buff_virt_addr;
-
-		/* Release buffer */
-		mvpp2_bm_pool_mc_put(port, pool_id, buff_dma_addr,
-				     buff_virt_addr, mc_id);
-
-		buff_dma_addr = buff_dma_addr_next;
-		buff_virt_addr = buff_virt_addr_next;
-
-	} while (!MVPP2_B_HDR_INFO_IS_LAST(buff_hdr->info));
-}
-
 /* Main rx processing */
 static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		    struct mvpp2_rx_queue *rxq)
@@ -5146,11 +5074,6 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		bm = mvpp2_bm_cookie_build(rx_desc);
 		pool = mvpp2_bm_cookie_pool_get(bm);
 		bm_pool = &port->priv->bm_pools[pool];
-		/* Check if buffer header is used */
-		if (rx_status & MVPP2_RXD_BUF_HDR) {
-			mvpp2_buff_hdr_rx(port, rx_desc);
-			continue;
-		}
 
 		/* In case of an error, release the requested buffer pointer
 		 * to the Buffer Manager. This request process is controlled
-- 
2.7.4
