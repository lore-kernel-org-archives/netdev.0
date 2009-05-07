From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: set queue0 for srrctl configuration
	correctly for DCB
Date: Thu, 07 May 2009 13:39:16 -0700
Message-ID: <20090507203915.19886.76171.stgit@localhost.localdomain>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:55924
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759388AbZEGUje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:39:34 -0400
In-Reply-To: <20090507203854.19886.54737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current configuration is not setting queue 0 correctly for DCB
configurations.  As a result unconfigured queues are being used to setup
the SRRCTL register rx buffer len sizes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4c38d51..d64a2d7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1740,7 +1740,18 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	unsigned long mask;
 
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		queue0 = index;
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+			if (dcb_i == 8)
+				queue0 = index >> 4;
+			else if (dcb_i == 4)
+				queue0 = index >> 5;
+			else
+				dev_err(&adapter->pdev->dev, "Invalid DCB "
+				        "configuration\n");
+		} else {
+			queue0 = index;
+		}
 	} else {
 		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
 		queue0 = index & mask;

