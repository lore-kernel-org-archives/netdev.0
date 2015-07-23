From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v0 1/6] net: netcp: Fixes the use of spin_lock_bh in timer function
Date: Thu, 23 Jul 2015 09:32:43 -0400
Message-ID: <1437658368-1679-2-git-send-email-w-kwok2@ti.com>
References: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in which the timer routine synchronized
against the ethtool-triggered statistics updates with spin_lock_bh().
A timer function is itself a bottom-half, so this should be
spin_lock().

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 9b7e0a3..cabf977 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2189,14 +2189,15 @@ static void netcp_ethss_timer(unsigned long arg)
 		netcp_ethss_update_link_state(gbe_dev, slave, NULL);
 	}
 
-	spin_lock_bh(&gbe_dev->hw_stats_lock);
+	/* A timer runs as a BH, no need to block them */
+	spin_lock(&gbe_dev->hw_stats_lock);
 
 	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
 		gbe_update_stats_ver14(gbe_dev, NULL);
 	else
 		gbe_update_stats(gbe_dev, NULL);
 
-	spin_unlock_bh(&gbe_dev->hw_stats_lock);
+	spin_unlock(&gbe_dev->hw_stats_lock);
 
 	gbe_dev->timer.expires	= jiffies + GBE_TIMER_INTERVAL;
 	add_timer(&gbe_dev->timer);
-- 
1.7.9.5
