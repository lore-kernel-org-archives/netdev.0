From: Tony Camuso <tcamuso@redhat.com>
Subject: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock (2)
Date: Wed,  6 May 2015 09:09:18 -0400
Message-ID: <1430917758-45028-1-git-send-email-tcamuso@redhat.com>
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, nhorman@redhat.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch should have been part of the previous patch having the
same summary. See  http://marc.info/?l=linux-kernel&m=143039470103795&w=2
Unfortunately, I didn't check to see where else this lock was used before
submitting that patch. This should take care of it for netxen_nic, as I
did a thorough search this time.

To recap from the original patch; although testing this driver with
DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled did not produce any traces,
it would be more prudent in the case of tx_clean_lock to use _bh
versions of spin_[un]lock, since this lock is manipulated in both
the process and softirq contexts.

This patch was tested for functionality and regressions with netperf
and DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled.

Signed-off-by: Tony Camuso <tcamuso@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 2da9627..6301bae 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1766,7 +1766,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	int done = 0;
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 
-	if (!spin_trylock(&adapter->tx_clean_lock))
+	if (!spin_trylock_bh(&adapter->tx_clean_lock))
 		return 1;
 
 	sw_consumer = tx_ring->sw_consumer;
@@ -1821,7 +1821,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	 */
 	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
 	done = (sw_consumer == hw_consumer);
-	spin_unlock(&adapter->tx_clean_lock);
+	spin_unlock_bh(&adapter->tx_clean_lock);
 
 	return done;
 }
-- 
1.8.3.1
