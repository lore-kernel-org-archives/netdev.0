From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 05/22] net: mvpp2: remove
 mvpp2_txq_pend_desc_num_get() function
Date: Tue,  7 Mar 2017 16:53:03 +0100
Message-ID: <1488902000-2658-6-git-send-email-thomas.petazzoni@free-electrons.com>
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

The mvpp2_txq_pend_desc_num_get() function only selects a TX queue, and
reads the number of pending descriptors. It is used in only one place,
in mvpp2_txq_clean(), where the TX queue has already been selected by a
write to MVPP2_TXQ_NUM_REG.

Therefore, this function is useless, and the caller can simply read the
value of the MVPP2_TXQ_PENDING_REG register instead.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 60cc020..9ddda20 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4123,18 +4123,6 @@ static u32 mvpp2_bm_cookie_build(struct mvpp2_rx_desc *rx_desc)
 
 /* Tx descriptors helper methods */
 
-/* Get number of Tx descriptors waiting to be transmitted by HW */
-static int mvpp2_txq_pend_desc_num_get(struct mvpp2_port *port,
-				       struct mvpp2_tx_queue *txq)
-{
-	u32 val;
-
-	mvpp2_write(port->priv, MVPP2_TXQ_NUM_REG, txq->id);
-	val = mvpp2_read(port->priv, MVPP2_TXQ_PENDING_REG);
-
-	return val & MVPP2_TXQ_PENDING_MASK;
-}
-
 /* Get pointer to next Tx descriptor to be processed (send) by HW */
 static struct mvpp2_tx_desc *
 mvpp2_txq_next_desc_get(struct mvpp2_tx_queue *txq)
@@ -4740,7 +4728,8 @@ static void mvpp2_txq_clean(struct mvpp2_port *port, struct mvpp2_tx_queue *txq)
 		mdelay(1);
 		delay++;
 
-		pending = mvpp2_txq_pend_desc_num_get(port, txq);
+		pending = mvpp2_read(port->priv, MVPP2_TXQ_PENDING_REG) &
+			MVPP2_TXQ_PENDING_MASK;
 	} while (pending);
 
 	val &= ~MVPP2_TXQ_DRAIN_EN_MASK;
-- 
2.7.4
