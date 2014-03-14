From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 10/10] i40e: fix race conditions on
	queuing skb for HW time stamp
Date: Fri, 14 Mar 2014 18:34:41 +0100
Message-ID: <1394818481-7652-11-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

i40e has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c  | 3 +++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 838b69b..7ed0303 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -136,6 +136,7 @@ enum i40e_state_t {
 	__I40E_EMP_RESET_REQUESTED,
 	__I40E_FILTER_OVERFLOW_PROMISC,
 	__I40E_SUSPENDED,
+	__I40E_PTP_TX_IN_PROGRESS,
 };
 
 enum i40e_interrupt_policy {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index e33ec6c..545079c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -238,6 +238,7 @@ static void i40e_ptp_tx_work(struct work_struct *work)
 				   I40E_PTP_TX_TIMEOUT)) {
 		dev_kfree_skb_any(pf->ptp_tx_skb);
 		pf->ptp_tx_skb = NULL;
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 		pf->tx_hwtstamp_timeouts++;
 		dev_warn(&pf->pdev->dev, "clearing Tx timestamp hang");
 		return;
@@ -350,6 +351,7 @@ void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 	skb_tstamp_tx(pf->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(pf->ptp_tx_skb);
 	pf->ptp_tx_skb = NULL;
+	clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 }
 
 /**
@@ -651,6 +653,7 @@ void i40e_ptp_stop(struct i40e_pf *pf)
 	if (pf->ptp_tx_skb) {
 		dev_kfree_skb_any(pf->ptp_tx_skb);
 		pf->ptp_tx_skb = NULL;
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 	}
 
 	if (pf->ptp_clock) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9543683..9db6efa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1746,7 +1746,8 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	 * we are not already transmitting a packet to be timestamped
 	 */
 	pf = i40e_netdev_to_pf(tx_ring->netdev);
-	if (pf->ptp_tx && !pf->ptp_tx_skb) {
+	if (pf->ptp_tx &&
+	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, &pf->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		pf->ptp_tx_skb = skb_get(skb);
 	} else {
-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
