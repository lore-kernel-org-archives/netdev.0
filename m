From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH v2] phy state machine: failsafe leave invalid RUNNING state
Date: Fri,  6 Jan 2017 12:14:48 +0100
Message-ID: <1483701288-14019-1-git-send-email-zefir.kurtisi@neratec.com>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: f.fainelli@gmail.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:18902 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938349AbdAFLOy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 06:14:54 -0500
In-Reply-To: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While in RUNNING state, phy_state_machine() checks for link changes by
comparing phydev->link before and after calling phy_read_status().
This works as long as it is guaranteed that phydev->link is never
changed outside the phy_state_machine().

If in some setups this happens, it causes the state machine to miss
a link loss and remain RUNNING despite phydev->link being 0.

This has been observed running a dsa setup with a process continuously
polling the link states over ethtool each second (SNMPD RFC-1213
agent). Disconnecting the link on a phy followed by a ETHTOOL_GSET
causes dsa_slave_get_settings() / dsa_slave_get_link_ksettings() to
call phy_read_status() and with that modify the link status - and
with that bricking the phy state machine.

This patch adds a fail-safe check while in RUNNING, which causes to
move to CHANGELINK when the link is gone and we are still RUNNING.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
Changes to v1:
* fix kbuild test robot error: use phydev_err instead of dev_warn
  (adapt to changed struct phy_device after 4.4.21)
---
 drivers/net/phy/phy.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 25f93a9..48da6e9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1065,6 +1065,15 @@ void phy_state_machine(struct work_struct *work)
 			if (old_link != phydev->link)
 				phydev->state = PHY_CHANGELINK;
 		}
+		/*
+		 * Failsafe: check that nobody set phydev->link=0 between two
+		 * poll cycles, otherwise we won't leave RUNNING state as long
+		 * as link remains down.
+		 */
+		if (!phydev->link && phydev->state == PHY_RUNNING) {
+			phydev->state = PHY_CHANGELINK;
+			phydev_err(phydev, "no link in PHY_RUNNING\n");
+		}
 		break;
 	case PHY_CHANGELINK:
 		err = phy_read_status(phydev);
-- 
2.7.4
