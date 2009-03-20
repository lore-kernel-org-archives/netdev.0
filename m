From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/5] igb: rework igb_set_multi so that vfs are
	properly updated
Date: Fri, 20 Mar 2009 03:17:25 -0700
Message-ID: <20090320101725.17663.72236.stgit@lost.foo-projects.org>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:51748 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754844AbZCTKRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:17:44 -0400
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently if there are no multicast addresses programmed into the PF then
the VFs cannot have their multicast filters reset.  This change makes it so
the code path that updates vf multicast is always called along with the pf
updates.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3dd3a5a..a977bd7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2464,7 +2464,7 @@ static void igb_set_multi(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
-	u8  *mta_list;
+	u8  *mta_list = NULL;
 	u32 rctl;
 	int i;
 
@@ -2485,17 +2485,15 @@ static void igb_set_multi(struct net_device *netdev)
 	}
 	wr32(E1000_RCTL, rctl);
 
-	if (!netdev->mc_count) {
-		/* nothing to program, so clear mc list */
-		igb_update_mc_addr_list(hw, NULL, 0, 1,
-					mac->rar_entry_count);
-		return;
+	if (netdev->mc_count) {
+		mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
+		if (!mta_list) {
+			dev_err(&adapter->pdev->dev,
+			        "failed to allocate multicast filter list\n");
+			return;
+		}
 	}
 
-	mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
-	if (!mta_list)
-		return;
-
 	/* The shared function expects a packed array of only addresses. */
 	mc_ptr = netdev->mc_list;
 

