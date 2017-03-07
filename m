From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 21/22] net: mvpp2: set dma mask and coherent dma
 mask on PPv2.2
Date: Tue,  7 Mar 2017 16:53:19 +0100
Message-ID: <1488902000-2658-22-git-send-email-thomas.petazzoni@free-electrons.com>
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

On PPv2.2, the streaming mappings can be anywhere in the first 40 bits
of the physical address space. However, for the coherent mappings, we
still need them to be in the first 32 bits of the address space,
because all BM pools share a single register to store the high 32 bits
of the BM pool address, which means all BM pools must be allocated in
the same 4GB memory area.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 0a3c470..92c47f3 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6941,6 +6941,20 @@ static int mvpp2_probe(struct platform_device *pdev)
 	/* Get system's tclk rate */
 	priv->tclk = clk_get_rate(priv->pp_clk);
 
+	if (priv->hw_version == MVPP22) {
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(40));
+		if (err)
+			goto err_mg_clk;
+		/* Sadly, the BM pools all share the same register to
+		 * store the high 32 bits of their address. So they
+		 * must all have the same high 32 bits, which forces
+		 * us to restrict coherent memory to DMA_BIT_MASK(32).
+		 */
+		err = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (err)
+			goto err_mg_clk;
+	}
+
 	/* Initialize network controller */
 	err = mvpp2_init(pdev, priv);
 	if (err < 0) {
-- 
2.7.4
