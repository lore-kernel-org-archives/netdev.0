From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: use priv flags to control packet split
Date: Thu,  3 Dec 2015 05:25:54 -0800
Message-ID: <1449149160-105219-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3437 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759434AbbLCN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:05 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Ethtool priv flags implementation to enable or disable packet split, which
is a hardware feature that inspects headers and will put headers in a
separate DMA buffer from the payload data.  The driver was automatically
choosing to enable packet split in some cases and this gives the user the
ability to turn it off/on explicitly.

to query state:
ethtool --show-priv-flags ethx

to enable:
ethtool --set-priv-flags ethx packet-split on
to disable:
ethtool --set-priv-flags ethx packet-split off

Why would anyone want this?
	Because some environments benefit from header/data split in the receive
	buffer, and the driver defaults to one or the other depending on
	environment/kernel parameters.

Why didn't you implement a generic ethtool control for this feature?
	Because Intel hardware is the only hardware that supports header/data
	split.

Change-ID: I803121e1eecc9ccb2884031fd85dd1110b3af66d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 27 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index dde7ae7..4ca85d5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -104,6 +104,7 @@
 #define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
 #define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
 #define I40E_PRIV_FLAGS_VEB_STATS	BIT(3)
+#define I40E_PRIV_FLAGS_PS		BIT(4)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b52c509..29d5833 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -231,6 +231,7 @@ static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"LinkPolling",
 	"flow-director-atr",
 	"veb-stats",
+	"packet-split",
 };
 
 #define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings)
@@ -2709,6 +2710,8 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_FD_ATR : 0;
 	ret_flags |= pf->flags & I40E_FLAG_VEB_STATS_ENABLED ?
 		I40E_PRIV_FLAGS_VEB_STATS : 0;
+	ret_flags |= pf->flags & I40E_FLAG_RX_PS_ENABLED ?
+		I40E_PRIV_FLAGS_PS : 0;
 
 	return ret_flags;
 }
@@ -2723,6 +2726,26 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	bool reset_required = false;
+
+	/* NOTE: MFP is not settable */
+
+	/* allow the user to control the method of receive
+	 * buffer DMA, whether the packet is split at header
+	 * boundaries into two separate buffers.  In some cases
+	 * one routine or the other will perform better.
+	 */
+	if ((flags & I40E_PRIV_FLAGS_PS) &&
+	    !(pf->flags & I40E_FLAG_RX_PS_ENABLED)) {
+		pf->flags |= I40E_FLAG_RX_PS_ENABLED;
+		pf->flags &= ~I40E_FLAG_RX_1BUF_ENABLED;
+		reset_required = true;
+	} else if (!(flags & I40E_PRIV_FLAGS_PS) &&
+		   (pf->flags & I40E_FLAG_RX_PS_ENABLED)) {
+		pf->flags &= ~I40E_FLAG_RX_PS_ENABLED;
+		pf->flags |= I40E_FLAG_RX_1BUF_ENABLED;
+		reset_required = true;
+	}
 
 	if (flags & I40E_PRIV_FLAGS_LINKPOLL_FLAG)
 		pf->flags |= I40E_FLAG_LINK_POLLING_ENABLED;
@@ -2745,6 +2768,10 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	else
 		pf->flags &= ~I40E_FLAG_VEB_STATS_ENABLED;
 
+	/* if needed, issue reset to cause things to take effect */
+	if (reset_required)
+		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
+
 	return 0;
 }
 
-- 
2.5.0
