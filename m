From: Keng Soon Cheah <keng.soon.cheah@ni.com>
Subject: [PATCH RFC] net: phy: Introduced the PHY_AN_PENDING state
Date: Wed, 10 Jun 2015 12:36:35 +0800
Message-ID: <20150610043635.GA6430@pendev.apac.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:40568 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750861AbbFJEhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 00:37:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY_AN_PENDING state is put as a gate to enter the PHY_AN state
where it will wait for any uncomplete auto-negotiation session to
finish before starting a new one.

This extra state could be used to workaround some auto-negotation
issues from certain vendors.

an_pending_timeout module parameter is used to enable the AN_PENDING
transition state. Set it to 0 to disable AN_PENDING state transition,
set it to any non-zero value to specify the timeout period for
PHY_AN_PENDING state in second. The default value is 0.

an_pending_guard module parameter serves as a guard band to delay
the auto-negotiation firing after the previous auto-negotiation
finish.

Signed-off-by: Keng Soon Cheah <keng.soon.cheah@ni.com>

Conflicts:

	drivers/net/phy/phy.c
---
We observed failure in the ethernet link operation when our board pairs
with some network switch model. The problem happens when an
auto-negotiation is started around the time the previous auto-negotiation
complete. We believe this might be an interoperatibility issue between
the PHYs but we need a short-term solution in software to workaround the
issue.

We found that we are able to avoid from hitting the problem by waiting any
pending auto-negotiation to complete before starting a new one and this
patch is designed to serve the purpose.

A PHY_AN_PENDING state is introduced and it will act as a gate to enter
the PHY_AN state. This state will check for auto-negotiation completion
or timeout after an_pending_timeout period, then it will wait for
an_pending_guard before triggering another auto-negotiation.

The following diagram shows the timing diagram


           an_pending_timeout           an_pending_guard
   V                                                       V auto-nego
   |--------------------------------->|....................|
                                      ^
                       auto-negotiation complete/timeout

We do not have plan to submit this patch upstream (unless the community
feels this patch is useful in general) but we would like to seek for
feedback or advice if this patch could introduce new problems.

---
 drivers/net/phy/phy.c |   44 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/phy.h   |    3 ++-
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index b2197b5..35e6484 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -38,6 +38,16 @@
 
 #include <asm/irq.h>
 
+static unsigned int an_pending_timeout;
+module_param(an_pending_timeout, uint, 0644);
+MODULE_PARM_DESC(an_pending_timeout,
+	"Timeout period for PHY_AN_PENDING state in second. 0 to disable PHY_AN_PENDING state (default)");
+
+static unsigned int an_pending_guard;
+module_param(an_pending_guard, uint, 0644);
+MODULE_PARM_DESC(an_pending_guard,
+	"Guard band period before firing auto-negotiation from PHY_AN_PENDING state in second. Default to 0");
+
 static const char *phy_speed_to_str(int speed)
 {
 	switch (speed) {
@@ -82,7 +92,6 @@ static const char *phy_state_to_str(enum phy_state st)
 	return NULL;
 }
 
-
 /**
  * phy_print_status - Convenience function to print out the current phy status
  * @phydev: the phy_device struct
@@ -485,6 +494,18 @@ int phy_start_aneg(struct phy_device *phydev)
 
 	/* Invalidate LP advertising flags */
 	phydev->lp_advertising = 0;
+	if (an_pending_timeout) {
+		switch (phydev->state) {
+		case PHY_AN_PENDING:
+		case PHY_HALTED:
+			break;
+		default:
+			phydev->state = PHY_AN_PENDING;
+			phydev->link_timeout = an_pending_timeout;
+			goto out_unlock;
+		}
+
+	}
 
 	err = phydev->drv->config_aneg(phydev);
 	if (err < 0)
@@ -831,6 +852,27 @@ void phy_state_machine(struct work_struct *work)
 		phydev->link_timeout = PHY_AN_TIMEOUT;
 
 		break;
+	case PHY_AN_PENDING:
+		/* Check if negotiation is done.  Break if there's an error */
+		err = phy_aneg_done(phydev);
+		if (err < 0)
+			break;
+
+		/* If AN is done, we'll proceed with the real aneg triggering */
+		if (err > 0) {
+			if (phydev->link_timeout > 0)
+				phydev->link_timeout = -(an_pending_guard);
+			else if (phydev->link_timeout < 0)
+				phydev->link_timeout++;
+		} else
+			phydev->link_timeout--;
+
+		if (0 == phydev->link_timeout) {
+			needs_aneg = true;
+
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+		}
+		break;
 	case PHY_AN:
 		err = phy_read_status(phydev);
 		if (err < 0)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index a26c3f8..a63afdc 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -308,7 +308,8 @@ enum phy_state {
 	PHY_FORCING,
 	PHY_CHANGELINK,
 	PHY_HALTED,
-	PHY_RESUMING
+	PHY_RESUMING,
+	PHY_AN_PENDING
 };
 
 /**
-- 
1.7.7.6
