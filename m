From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/14] nfp: track link state changes
Date: Tue,  4 Apr 2017 16:12:25 -0700
Message-ID: <20170404231235.32027-5-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35852 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754793AbdDDXM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:57 -0400
Received: by mail-pf0-f172.google.com with SMTP id o126so25032110pfb.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:57 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For caching link settings - remember if we have seen link events
since the last time the eth_port information was refreshed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  6 +++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 ++++++++++++++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 8e04aa0e6e87..91e963b5104f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -523,7 +523,8 @@ struct nfp_net_dp {
  * @reconfig_sync_present:  Some thread is performing synchronous reconfig
  * @reconfig_timer:	Timer for async reading of reconfig results
  * @link_up:            Is the link up?
- * @link_status_lock:	Protects @link_up and ensures atomicity with BAR reading
+ * @link_changed:	Has link state changes since last port refresh?
+ * @link_status_lock:	Protects @link_* and ensures atomicity with BAR reading
  * @rx_coalesce_usecs:      RX interrupt moderation usecs delay parameter
  * @rx_coalesce_max_frames: RX interrupt moderation frame count parameter
  * @tx_coalesce_usecs:      TX interrupt moderation usecs delay parameter
@@ -580,6 +581,7 @@ struct nfp_net {
 	u32 me_freq_mhz;
 
 	bool link_up;
+	bool link_changed;
 	spinlock_t link_status_lock;
 
 	spinlock_t reconfig_lock;
@@ -810,6 +812,8 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
 
+bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
+
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
 void nfp_net_debugfs_destroy(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 6944a3202a45..8664815f45ce 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -376,6 +376,19 @@ static irqreturn_t nfp_net_irq_rxtx(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+bool nfp_net_link_changed_read_clear(struct nfp_net *nn)
+{
+	unsigned long flags;
+	bool ret;
+
+	spin_lock_irqsave(&nn->link_status_lock, flags);
+	ret = nn->link_changed;
+	nn->link_changed = false;
+	spin_unlock_irqrestore(&nn->link_status_lock, flags);
+
+	return ret;
+}
+
 /**
  * nfp_net_read_link_status() - Reread link status from control BAR
  * @nn:       NFP Network structure
@@ -395,6 +408,7 @@ static void nfp_net_read_link_status(struct nfp_net *nn)
 		goto out;
 
 	nn->link_up = link_up;
+	nn->link_changed = true;
 
 	if (nn->link_up) {
 		netif_carrier_on(nn->dp.netdev);
-- 
2.11.0
