From: Tony Camuso <tcamuso@redhat.com>
Subject: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock
Date: Thu, 30 Apr 2015 07:51:27 -0400
Message-ID: <1430394687-78627-1-git-send-email-tcamuso@redhat.com>
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, nhorman@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbbD3Lvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 07:51:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing this driver with DEBUG_LOCKDEP and DEBUG_SPINLOCK
enabled did not produce any traces, it would be more prudent in the
case of tx_clean_lock to use spin_[un]lock_bh, since this lock is
manipulated in both the process and softirq contexts.

This patch was tested for functionality and regressions with netperf
and DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled.

Signed-off-by: Tony Camuso <tcamuso@redhat.com>

---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index d746c97..2da9627 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -137,7 +137,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	int i, j;
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 
-	spin_lock(&adapter->tx_clean_lock);
+	spin_lock_bh(&adapter->tx_clean_lock);
 	cmd_buf = tx_ring->cmd_buf_arr;
 	for (i = 0; i < tx_ring->num_desc; i++) {
 		buffrag = cmd_buf->frag_array;
@@ -161,7 +161,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 		}
 		cmd_buf++;
 	}
-	spin_unlock(&adapter->tx_clean_lock);
+	spin_unlock_bh(&adapter->tx_clean_lock);
 }
 
 void netxen_free_sw_resources(struct netxen_adapter *adapter)
-- 
1.8.3.1
