From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/4] igb: do not clobber the TSAUXC
	bits on reset.
Date: Mon, 27 May 2013 11:21:44 +0200
Message-ID: <0c838f7cd866c88eb85bb8d2aaaef21048a7d0e9.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Jacob Keller <jacob.e.keller@intel.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The TSAUXC register has a number of different bits, one of which disables
the main clock function. Previously, the clock was re-enabled by clearing
the entire register. This patch changes the code to preserve the values
of the other bits in that register.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index ebc2f72..5944de0 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -860,6 +860,8 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 void igb_ptp_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long flags;
+	u32 tsauxc;
 
 	if (!(adapter->flags & IGB_FLAG_PTP))
 		return;
@@ -875,7 +877,11 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i210:
 	case e1000_i211:
 		/* Enable the timer functions and interrupts. */
-		wr32(E1000_TSAUXC, 0x0);
+		spin_lock_irqsave(&adapter->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsauxc &= ~TSAUXC_DISABLE;
+		wr32(E1000_TSAUXC, tsauxc);
+		spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
-- 
1.7.10.4


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
