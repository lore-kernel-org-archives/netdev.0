From: Thomas Fitzsimmons <fitzsim@fitzsim.org>
Subject: [PATCH] net: mvneta: Fix big endian issue in mvneta_txq_desc_csum()
Date: Tue, 08 Jul 2014 18:30:54 -0400
Message-ID: <m31ttvqy8x.fsf@fitzsim.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: David S. Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

This commit fixes the command value generated for CSUM calculation
when running in big endian mode.  The Ethernet protocol ID for IP was
being unconditionally byte-swapped in the layer 3 protocol check (with
swab16), which caused the mvneta driver to not function correctly in
big endian mode.  This patch byte-swaps the ID conditionally with
htons.

Cc: <stable@vger.kernel.org> # v3.13+
Signed-off-by: Thomas Fitzsimmons <fitzsim@fitzsim.org>
---
The mvneta driver existed prior to v3.13, but it has only supported big
endian from v3.13 onward.  If it's accepted, this patch needs to be
backported for stable only as far back as v3.13.

 drivers/net/ethernet/marvell/mvneta.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 45beca1..667cf65 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1207,7 +1207,7 @@ static u32 mvneta_txq_desc_csum(int l3_offs, int l3_proto,
 	command =  l3_offs    << MVNETA_TX_L3_OFF_SHIFT;
 	command |= ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT;
 
-	if (l3_proto == swab16(ETH_P_IP))
+	if (l3_proto == htons(ETH_P_IP))
 		command |= MVNETA_TXD_IP_CSUM;
 	else
 		command |= MVNETA_TX_L3_IP6;
-- 
1.7.1
