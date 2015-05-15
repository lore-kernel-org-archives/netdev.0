From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: Add state machine state transitions debug prints
Date: Fri, 15 May 2015 14:18:42 -0700
Message-ID: <1431724722-14737-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36845 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422770AbbEOVTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:19:10 -0400
Received: by pdfh10 with SMTP id h10so28162398pdf.3
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 14:19:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful to debug the PHY state machine, add dynamic debug
prints of the old and new PHY devices state under a friendly format.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c |  6 ++++++
 include/linux/phy.h   | 24 ++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 52cd8db2c57d..976e7952a131 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -770,10 +770,13 @@ void phy_state_machine(struct work_struct *work)
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
 
@@ -949,6 +952,9 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
+	dev_dbg(&phydev->dev, "PHY state change %s -> %s\n",
+		phy_state_to_str(old_state), phy_state_to_str(phydev->state));
+
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
 			   PHY_STATE_TIME * HZ);
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 701c7a3946e0..c2b14d8c5ddc 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -311,6 +311,30 @@ enum phy_state {
 	PHY_RESUMING
 };
 
+#define PHY_STATE_STR(_state)			\
+	case PHY_##_state:			\
+		return __stringify(_state);	\
+
+static inline const char *phy_state_to_str(enum phy_state st)
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
 /**
  * struct phy_c45_device_ids - 802.3-c45 Device Identifiers
  * @devices_in_package: Bit vector of devices present.
-- 
2.1.0
