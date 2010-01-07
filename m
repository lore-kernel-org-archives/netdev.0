From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] ixgbe: Add Flow Director configuration
	support as a mod parameter
Date: Wed, 06 Jan 2010 20:49:29 -0800
Message-ID: <20100107044928.28605.62132.stgit@localhost.localdomain>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Luca Deri <deri@ntop.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:40959 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932561Ab0AGEtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:49:52 -0500
In-Reply-To: <20100107044741.28605.31414.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds the ability to change the Flow Director behavior in
ixgbe through a module parameter.  ixgbe, on 82599 hardware, can support
hash-based or perfect-based filtering.  It currently uses hash-based, and
should have a knob to enable perfect-based filtering.

This will be used in conjunction with the ethtool n-tuple filter
programming support.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Luca Deri <deri@ntop.org>
CC: Joseph Gasparakis <joseph.gasparakis@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ceeef52..13d413a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -124,6 +124,11 @@ static struct notifier_block dca_notifier = {
 };
 #endif
 
+static unsigned int fdir_filter_mode;
+module_param(fdir_filter_mode, uint, 0);
+MODULE_PARM_DESC(fdir_filter_mode, "Flow Director filtering mode: 0 - hash, "
+                 "1 - perfect");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -4002,10 +4007,17 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
-		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
+		if (fdir_filter_mode == 0) {
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->atr_sample_rate = 20;
+		} else {
+			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			spin_lock_init(&adapter->fdir_perfect_lock);
+		}
+
 		adapter->ring_feature[RING_F_FDIR].indices =
 		                                         IXGBE_MAX_FDIR_INDICES;
-		adapter->atr_sample_rate = 20;
 		adapter->fdir_pballoc = 0;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;

