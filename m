From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e: Bypass timeout recovery level 0 so as to not cause MDD
Date: Mon, 23 Jun 2014 17:47:37 -0700
Message-ID: <1403570858-13548-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754545AbaFXArw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:52 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

When a Tx hang happens, usually the Tx queue disable fails. At
this point if we try to recover by a VSI reinit the HW gets
unhappy and we get a Malicious Driver Detect (MDD) event.
HW expects a PF reset if a queue disable fails, if we don't do a PF
reset and restart the queue we get an MDD.  This patch makes sure we
do a PF reset on Tx hang and that way we avoid any MDD because of Tx
queue disable failure.

Change-ID: I665ab6223577c788da857ee2132e733dc9a451e4
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6522a51..168030b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -278,7 +278,7 @@ static void i40e_tx_timeout(struct net_device *netdev)
 	pf->tx_timeout_count++;
 
 	if (time_after(jiffies, (pf->tx_timeout_last_recovery + HZ*20)))
-		pf->tx_timeout_recovery_level = 0;
+		pf->tx_timeout_recovery_level = 1;
 	pf->tx_timeout_last_recovery = jiffies;
 	netdev_info(netdev, "tx_timeout recovery level %d\n",
 		    pf->tx_timeout_recovery_level);
@@ -6827,6 +6827,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	pf->irq_pile->num_entries = pf->hw.func_caps.num_msix_vectors;
 	pf->irq_pile->search_hint = 0;
 
+	pf->tx_timeout_recovery_level = 1;
+
 	mutex_init(&pf->switch_mutex);
 
 sw_init_done:
-- 
1.9.3
