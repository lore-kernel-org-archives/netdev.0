From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH v5 2/4] net: phy: Encapsulate actions performed during link
 state changes into function phy_adjust_link
Date: Mon, 17 Oct 2016 10:49:53 -0500
Message-ID: <1476719395-28273-3-git-send-email-zach.brown@ni.com>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 andrew@lunn.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 rpurdie@rpsys.net, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net,
 j.anaszewski@samsung.com, linux-leds@vger.kernel.org, mlindner@marvell.com
To: <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

During phy state machine state transitions some set of actions should
occur whenever the link state changes. These actions should be
encapsulated into a single function

This patch adds the phy_adjust_link function, which is called whenever
phydev->adjust_link would have been called before. Actions that should
occur whenever the phy link is adjusted can now be added to the
phy_adjust_link function.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/phy/phy.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c6f6683..f5721db 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -893,6 +893,11 @@ void phy_start(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_start);
 
+static void phy_adjust_link(struct phy_device *phydev)
+{
+	phydev->adjust_link(phydev->attached_dev);
+}
+
 /**
  * phy_state_machine - Handle the state machine
  * @work: work_struct that describes the work to be done
@@ -935,7 +940,7 @@ void phy_state_machine(struct work_struct *work)
 		if (!phydev->link) {
 			phydev->state = PHY_NOLINK;
 			netif_carrier_off(phydev->attached_dev);
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 			break;
 		}
 
@@ -948,7 +953,7 @@ void phy_state_machine(struct work_struct *work)
 		if (err > 0) {
 			phydev->state = PHY_RUNNING;
 			netif_carrier_on(phydev->attached_dev);
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 
 		} else if (0 == phydev->link_timeout--)
 			needs_aneg = true;
@@ -975,7 +980,7 @@ void phy_state_machine(struct work_struct *work)
 			}
 			phydev->state = PHY_RUNNING;
 			netif_carrier_on(phydev->attached_dev);
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 		}
 		break;
 	case PHY_FORCING:
@@ -991,7 +996,7 @@ void phy_state_machine(struct work_struct *work)
 				needs_aneg = true;
 		}
 
-		phydev->adjust_link(phydev->attached_dev);
+		phy_adjust_link(phydev);
 		break;
 	case PHY_RUNNING:
 		/* Only register a CHANGE if we are polling and link changed
@@ -1020,7 +1025,7 @@ void phy_state_machine(struct work_struct *work)
 			netif_carrier_off(phydev->attached_dev);
 		}
 
-		phydev->adjust_link(phydev->attached_dev);
+		phy_adjust_link(phydev);
 
 		if (phy_interrupt_is_valid(phydev))
 			err = phy_config_interrupt(phydev,
@@ -1030,7 +1035,7 @@ void phy_state_machine(struct work_struct *work)
 		if (phydev->link) {
 			phydev->link = 0;
 			netif_carrier_off(phydev->attached_dev);
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 			do_suspend = true;
 		}
 		break;
@@ -1054,7 +1059,7 @@ void phy_state_machine(struct work_struct *work)
 				} else	{
 					phydev->state = PHY_NOLINK;
 				}
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 			} else {
 				phydev->state = PHY_AN;
 				phydev->link_timeout = PHY_AN_TIMEOUT;
@@ -1070,7 +1075,7 @@ void phy_state_machine(struct work_struct *work)
 			} else	{
 				phydev->state = PHY_NOLINK;
 			}
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 		}
 		break;
 	}
-- 
2.7.4
