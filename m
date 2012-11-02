From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: [PATCH net-next] macb: Keep driver's speed/duplex in sync with actual
 NCFGR
Date: Fri, 2 Nov 2012 19:09:24 +0200
Message-ID: <201211021909.25473.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, linux-arm-kernel@lists.infradead.org,
 Jamie Iles <jamie@jamieiles.com>, Havard Skinnemoen <havard@skinnemoen.net>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

When underlying phy driver restores its state very fast after being brought 
down and up so that macb driver function macb_handle_link_change() was never 
called with link state "down", driver's internal representation of phy speed 
and duplex (bp->speed and bp->duplex) didn't change. So, macb driver sees no 
reason to perform actual write to the NCFGR register, although the speed and 
duplex settings in that register were reset when interface was brought down 
and up. In that case actual phy speed and duplex differ from NCFGR settings.
The patch fixes that by keeping internal driver representation of speed and 
duplex in sync with actual content of NCFGR.

Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>

---
 drivers/net/ethernet/cadence/macb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c 
b/drivers/net/ethernet/cadence/macb.c
index c374875..13c3c33 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1031,6 +1031,8 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
+	bp->speed = SPEED_10;
+	bp->duplex = DUPLEX_HALF;
 
 	macb_configure_dma(bp);
 
-- 
1.7.8.6
