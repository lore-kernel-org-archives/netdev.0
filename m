From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: phy: Add state machine state transitions debug prints
Date: Sat, 16 May 2015 10:17:56 -0700
Message-ID: <1431796676-11438-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34251 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbEPRSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 13:18:23 -0400
Received: by obfe9 with SMTP id e9so98062286obf.1
        for <netdev@vger.kernel.org>; Sat, 16 May 2015 10:18:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful to debug the PHY state machine, add dynamic debug
prints of the old and new PHY devices state under a friendly format.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- keep everything in drivers/net/phy/phy.c as suggested by David

 drivers/net/phy/phy.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 52cd8db..1457ecf 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -58,6 +58,31 @@ static const char *phy_speed_to_str(int speed)
 	}
 }
 
+#define PHY_STATE_STR(_state)			\
+	case PHY_##_state:			\
+		return __stringify(_state);	\
+
+static const char *phy_state_to_str(enum phy_state st)
+{
+	switch (st) {
+	PHY_STATE_STR(DOWN)
+	PHY_STATE_STR(STARTING)
+	PHY_STATE_STR(READY)
+	PHY_STATE_STR(PENDING)
+	PHY_STATE_STR(UP)
+	PHY_STATE_STR(AN)
+	PHY_STATE_STR(RUNNING)
+	PHY_STATE_STR(NOLINK)
+	PHY_STATE_STR(FORCING)
+	PHY_STATE_STR(CHANGELINK)
+	PHY_STATE_STR(HALTED)
+	PHY_STATE_STR(RESUMING)
+	}
+
+	return NULL;
+}
+
+
 /**
  * phy_print_status - Convenience function to print out the current phy status
  * @phydev: the phy_device struct
@@ -770,10 +795,13 @@ void phy_state_machine(struct work_struct *work)
 	struct phy_device *phydev =
 			container_of(dwork, struct phy_device, state_queue);
 	bool needs_aneg = false, do_suspend = false, do_resume = false;
+	enum phy_state old_state;
 	int err = 0;
 
 	mutex_lock(&phydev->lock);
 
+	old_state = phydev->state;
+
 	if (phydev->drv->link_change_notify)
 		phydev->drv->link_change_notify(phydev);
 
@@ -949,6 +977,9 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
+	dev_dbg(&phydev->dev, "PHY state change %s -> %s\n",
+		phy_state_to_str(old_state), phy_state_to_str(phydev->state));
+
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
 			   PHY_STATE_TIME * HZ);
 }
-- 
2.1.4
