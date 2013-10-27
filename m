From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: use jiffies_64 value to calculate credit timeout
Date: Sun, 27 Oct 2013 11:11:53 +0000
Message-ID: <1382872313-11675-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <david.vrabel@citrix.com>, <jbeulich@suse.com>,
	<annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jason Luan <jianhai.luan@oracle.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50956 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969Ab3J0LLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 07:11:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

time_after_eq() only works if the delta is < MAX_ULONG/2.

For a 32bit Dom0, if netfront sends packets at a very low rate, the time
between subsequent calls to tx_credit_exceeded() may exceed MAX_ULONG/2
and the test for timer_after_eq() will be incorrect. Credit will not be
replenished and the guest may become unable to send packets (e.g., if
prior to the long gap, all credit was exhausted).

Use jiffies_64 variant to mitigate this problem for 32bit Dom0.

Suggested-by: Jan Beulich <jbeulich@suse.com>
Suggested-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Jason Luan <jianhai.luan@oracle.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |    4 ++--
 drivers/net/xen-netback/netback.c   |   13 ++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5715318..400fea1 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -163,6 +163,7 @@ struct xenvif {
 	unsigned long   credit_usec;
 	unsigned long   remaining_credit;
 	struct timer_list credit_timeout;
+	u64 credit_window_start;
 
 	/* Statistics */
 	unsigned long rx_gso_checksum_fixup;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 01bb854..8c45b63 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -312,8 +312,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
 	init_timer(&vif->credit_timeout);
-	/* Initialize 'expires' now: it's used to track the credit window. */
-	vif->credit_timeout.expires = jiffies;
+	/* credit window is tracked in credit_window_start */
+	vif->credit_window_start = get_jiffies_64();
 
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f3e591c..1bc0688 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1185,18 +1185,17 @@ out:
 
 static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 {
-	unsigned long now = jiffies;
-	unsigned long next_credit =
-		vif->credit_timeout.expires +
-		msecs_to_jiffies(vif->credit_usec / 1000);
+	u64 now = get_jiffies_64();
+	u64 next_credit = vif->credit_window_start +
+		(u64)msecs_to_jiffies(vif->credit_usec / 1000);
 
 	/* Timer could already be pending in rare cases. */
 	if (timer_pending(&vif->credit_timeout))
 		return true;
 
 	/* Passed the point where we can replenish credit? */
-	if (time_after_eq(now, next_credit)) {
-		vif->credit_timeout.expires = now;
+	if (time_after_eq64(now, next_credit)) {
+		vif->credit_timeout.expires = (unsigned long)now;
 		tx_add_credit(vif);
 	}
 
@@ -1207,7 +1206,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 		vif->credit_timeout.function =
 			tx_credit_callback;
 		mod_timer(&vif->credit_timeout,
-			  next_credit);
+			  (unsigned long)next_credit);
 
 		return true;
 	}
-- 
1.7.10.4
