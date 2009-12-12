From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] igbvf: avoid reset storms due to mailbox issues
Date: Fri, 11 Dec 2009 19:41:16 -0800
Message-ID: <20091212034115.10674.14928.stgit@localhost.localdomain>
References: <20091212034033.10674.67054.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:36816
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933373AbZLLDl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 22:41:27 -0500
In-Reply-To: <20091212034033.10674.67054.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that reset/interrupt storms can be avoided when
there are mailbox issues.  The new behavior is to only allow the device to
trigger mailbox related resets only once every 10 seconds.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/igbvf.h  |    1 +
 drivers/net/igbvf/netdev.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index 3d1ee7a..a1774b2 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -276,6 +276,7 @@ struct igbvf_adapter {
 	unsigned long led_status;
 
 	unsigned int flags;
+	unsigned long last_reset;
 };
 
 struct igbvf_info {
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index a127620..e9dd95f 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1469,6 +1469,8 @@ static void igbvf_reset(struct igbvf_adapter *adapter)
 		memcpy(netdev->perm_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
 	}
+
+	adapter->last_reset = jiffies;
 }
 
 int igbvf_up(struct igbvf_adapter *adapter)
@@ -1812,11 +1814,15 @@ static bool igbvf_has_link(struct igbvf_adapter *adapter)
 	s32 ret_val = E1000_SUCCESS;
 	bool link_active;
 
+	/* If interface is down, stay link down */
+	if (test_bit(__IGBVF_DOWN, &adapter->state))
+		return false;
+
 	ret_val = hw->mac.ops.check_for_link(hw);
 	link_active = !hw->mac.get_link_status;
 
 	/* if check for link returns error we will need to reset */
-	if (ret_val)
+	if (ret_val && time_after(jiffies, adapter->last_reset + (10 * HZ)))
 		schedule_work(&adapter->reset_task);
 
 	return link_active;

