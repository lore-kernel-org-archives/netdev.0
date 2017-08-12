From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: use cmpxchg64 when updating private flags in ethtool
Date: Sat, 12 Aug 2017 04:08:42 -0700
Message-ID: <20170812110848.18264-11-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12721 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbdHLLIz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:55 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When a user gives an invalid command to change a private flag which is
not supported, either because it is read-only, or the device is not
capable of the feature, we simply ignore the request.

A naive solution would simply be to report error codes when one of the
flags was not supported. However, this causes problems because it makes
the operation not atomic. If a user requests multiple private flags
together at once we could end up changing one before failing at the
second flag.

We can do a bit better if we instead update a temporary copy of the
flags variable in the loop, and then copy it into place after. If we
aren't careful this has the pitfall of potentially silently overwriting
any changes caused by other threads.

Avoid this by using cmpxchg64 which will compare and swap the flags
variable only if it currently matched the old value. We'll report
-EAGAIN in the (hopefully rare!) case where the cmpxchg64 fails.

This ensures that we can properly report when flags are not supported in
an atomic fashion without the risk of overwriting other threads changes.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 57 +++++++++++++++-------
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 41 ++++++++++++----
 2 files changed, 70 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c76549e41705..a868c8d4fec9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -4069,23 +4069,26 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
-	u64 changed_flags;
+	u64 orig_flags, new_flags, changed_flags;
 	u32 i, j;
 
-	changed_flags = pf->flags;
+	orig_flags = READ_ONCE(pf->flags);
+	new_flags = orig_flags;
 
 	for (i = 0; i < I40E_PRIV_FLAGS_STR_LEN; i++) {
 		const struct i40e_priv_flags *priv_flags;
 
 		priv_flags = &i40e_gstrings_priv_flags[i];
 
-		if (priv_flags->read_only)
-			continue;
-
 		if (flags & BIT(i))
-			pf->flags |= priv_flags->flag;
+			new_flags |= priv_flags->flag;
 		else
-			pf->flags &= ~(priv_flags->flag);
+			new_flags &= ~(priv_flags->flag);
+
+		/* If this is a read-only flag, it can't be changed */
+		if (priv_flags->read_only &&
+		    ((orig_flags ^ new_flags) & ~BIT(i)))
+			return -EOPNOTSUPP;
 	}
 
 	if (pf->hw.pf_id != 0)
@@ -4096,18 +4099,40 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 
 		priv_flags = &i40e_gl_gstrings_priv_flags[j];
 
-		if (priv_flags->read_only)
-			continue;
-
 		if (flags & BIT(i + j))
-			pf->flags |= priv_flags->flag;
+			new_flags |= priv_flags->flag;
 		else
-			pf->flags &= ~(priv_flags->flag);
+			new_flags &= ~(priv_flags->flag);
+
+		/* If this is a read-only flag, it can't be changed */
+		if (priv_flags->read_only &&
+		    ((orig_flags ^ new_flags) & ~BIT(i)))
+			return -EOPNOTSUPP;
 	}
 
 flags_complete:
-	/* check for flags that changed */
-	changed_flags ^= pf->flags;
+	/* Before we finalize any flag changes, we need to perform some
+	 * checks to ensure that the changes are supported and safe.
+	 */
+
+	/* ATR eviction is not supported on all devices */
+	if ((new_flags & I40E_FLAG_HW_ATR_EVICT_ENABLED) &&
+	    !(pf->hw_features & I40E_HW_ATR_EVICT_CAPABLE))
+		return -EOPNOTSUPP;
+
+	/* Compare and exchange the new flags into place. If we failed, that
+	 * is if cmpxchg64 returns anything but the old value, this means that
+	 * something else has modified the flags variable since we copied it
+	 * originally. We'll just punt with an error and log something in the
+	 * message buffer.
+	 */
+	if (cmpxchg64(&pf->flags, orig_flags, new_flags) != orig_flags) {
+		dev_warn(&pf->pdev->dev,
+			 "Unable to update pf->flags as it was modified by another thread...\n");
+		return -EAGAIN;
+	}
+
+	changed_flags = orig_flags ^ new_flags;
 
 	/* Process any additional changes needed as a result of flag changes.
 	 * The changed_flags value reflects the list of bits that were
@@ -4121,10 +4146,6 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 		set_bit(__I40E_FD_FLUSH_REQUESTED, pf->state);
 	}
 
-	/* Only allow ATR evict on hardware that is capable of handling it */
-	if (!(pf->hw_features & I40E_HW_ATR_EVICT_CAPABLE))
-		pf->flags &= ~I40E_FLAG_HW_ATR_EVICT_ENABLED;
-
 	if (changed_flags & I40E_FLAG_TRUE_PROMISC_SUPPORT) {
 		u16 sw_flags = 0, valid_flags = 0;
 		int ret;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 76fd89c1dbb2..65874d6b3ab9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -258,29 +258,50 @@ static u32 i40evf_get_priv_flags(struct net_device *netdev)
 static int i40evf_set_priv_flags(struct net_device *netdev, u32 flags)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	u64 changed_flags;
+	u32 orig_flags, new_flags, changed_flags;
 	u32 i;
 
-	changed_flags = adapter->flags;
+	orig_flags = READ_ONCE(adapter->flags);
+	new_flags = orig_flags;
 
 	for (i = 0; i < I40EVF_PRIV_FLAGS_STR_LEN; i++) {
 		const struct i40evf_priv_flags *priv_flags;
 
 		priv_flags = &i40evf_gstrings_priv_flags[i];
 
-		if (priv_flags->read_only)
-			continue;
-
 		if (flags & BIT(i))
-			adapter->flags |= priv_flags->flag;
+			new_flags |= priv_flags->flag;
 		else
-			adapter->flags &= ~(priv_flags->flag);
+			new_flags &= ~(priv_flags->flag);
+
+		if (priv_flags->read_only &&
+		    ((orig_flags ^ new_flags) & ~BIT(i)))
+			return -EOPNOTSUPP;
+	}
+
+	/* Before we finalize any flag changes, any checks which we need to
+	 * perform to determine if the new flags will be supported should go
+	 * here...
+	 */
+
+	/* Compare and exchange the new flags into place. If we failed, that
+	 * is if cmpxchg returns anything but the old value, this means
+	 * something else must have modified the flags variable since we
+	 * copied it. We'll just punt with an error and log something in the
+	 * message buffer.
+	 */
+	if (cmpxchg(&adapter->flags, orig_flags, new_flags) != orig_flags) {
+		dev_warn(&adapter->pdev->dev,
+			 "Unable to update adapter->flags as it was modified by another thread...\n");
+		return -EAGAIN;
 	}
 
-	/* check for flags that changed */
-	changed_flags ^= adapter->flags;
+	changed_flags = orig_flags ^ new_flags;
 
-	/* Process any additional changes needed as a result of flag changes. */
+	/* Process any additional changes needed as a result of flag changes.
+	 * The changed_flags value reflects the list of bits that were changed
+	 * in the code above.
+	 */
 
 	/* issue a reset to force legacy-rx change to take effect */
 	if (changed_flags & I40EVF_FLAG_LEGACY_RX) {
-- 
2.14.0
