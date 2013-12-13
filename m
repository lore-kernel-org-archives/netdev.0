From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 5/5] net: phy: suspend phydev when going to HALTED
Date: Fri, 13 Dec 2013 10:20:29 +0100
Message-ID: <1386926429-28818-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When phydev is going to HALTED state, we can try to suspend it to
safe more power. phy_suspend helper will check if PHY can be suspended,
so just call it when entering HALTED state.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36c6994..6429942 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -740,7 +740,7 @@ void phy_state_machine(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct phy_device *phydev =
 			container_of(dwork, struct phy_device, state_queue);
-	int needs_aneg = 0;
+	int needs_aneg = 0, do_suspend = 0;
 	int err = 0;
 
 	mutex_lock(&phydev->lock);
@@ -855,6 +855,7 @@ void phy_state_machine(struct work_struct *work)
 				phydev->link = 0;
 				netif_carrier_off(phydev->attached_dev);
 				phydev->adjust_link(phydev->attached_dev);
+				do_suspend = 1;
 			}
 			break;
 		case PHY_RESUMING:
@@ -913,6 +914,9 @@ void phy_state_machine(struct work_struct *work)
 	if (needs_aneg)
 		err = phy_start_aneg(phydev);
 
+	if (do_suspend)
+		phy_suspend(phydev);
+
 	if (err < 0)
 		phy_error(phydev);
 
-- 
1.7.2.5
