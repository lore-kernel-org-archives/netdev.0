From: "David S. Miller" <davem@redhat.com>
Subject: Re: tg3 link not detected on first interface up with mtu change
Date: Mon, 8 Mar 2004 12:19:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308121935.12e1bf9b.davem@redhat.com>
References: <20040305121026.GF14914@raubitschek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Raubitschek <jeff@raubitschek.org>
In-Reply-To: <20040305121026.GF14914@raubitschek.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Mar 2004 07:10:26 -0500
Jeff Raubitschek <jeff@raubitschek.org> wrote:

> using the tg3 (v2.8) driver on 2.4.26-pre1, with dual port NetXtreme BCM5704 (rev 03), if you configure the interfaces with the a non default mtu, link will not be detected (no gigE switch required to reproduce, 100 Mbps switch will produce the same problem)

This should fix it, let me know if it doesn't.

ChangeSet@1.1631, 2004-03-08 11:24:08-08:00, davem@nuts.davemloft.net
  [TIGON3]: Always force PHY reset after major hw config changes.

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Mon Mar  8 11:27:01 2004
+++ b/drivers/net/tg3.c	Mon Mar  8 11:27:01 2004
@@ -782,7 +782,7 @@
 	}
 }
 
-static int tg3_setup_phy(struct tg3 *);
+static int tg3_setup_phy(struct tg3 *, int);
 
 static int tg3_set_power_state(struct tg3 *tp, int state)
 {
@@ -849,7 +849,7 @@
 		tp->link_config.speed = SPEED_10;
 		tp->link_config.duplex = DUPLEX_HALF;
 		tp->link_config.autoneg = AUTONEG_ENABLE;
-		tg3_setup_phy(tp);
+		tg3_setup_phy(tp, 0);
 	}
 
 	pci_read_config_word(tp->pdev, pm + PCI_PM_PMC, &power_caps);
@@ -1212,7 +1212,7 @@
 	return err;
 }
 
-static int tg3_setup_copper_phy(struct tg3 *tp)
+static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 {
 	int current_link_up;
 	u32 bmsr, dummy;
@@ -1245,8 +1245,10 @@
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!(bmsr & BMSR_LSTATUS))
-			tg3_phy_reset(tp, 1);
+			force_reset = 1;
 	}
+	if (force_reset)
+		tg3_phy_reset(tp, 1);
 
 	if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -1775,7 +1777,7 @@
 	return ret;
 }
 
-static int tg3_setup_fiber_phy(struct tg3 *tp)
+static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 {
 	u32 orig_pause_cfg;
 	u16 orig_active_speed;
@@ -1980,14 +1982,14 @@
 	return 0;
 }
 
-static int tg3_setup_phy(struct tg3 *tp)
+static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 {
 	int err;
 
 	if (tp->phy_id == PHY_ID_SERDES) {
-		err = tg3_setup_fiber_phy(tp);
+		err = tg3_setup_fiber_phy(tp, force_reset);
 	} else {
-		err = tg3_setup_copper_phy(tp);
+		err = tg3_setup_copper_phy(tp, force_reset);
 	}
 
 	if (tp->link_config.active_speed == SPEED_1000 &&
@@ -2350,7 +2352,7 @@
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
 				(sblk->status & ~SD_STATUS_LINK_CHG);
-			tg3_setup_phy(tp);
+			tg3_setup_phy(tp, 0);
 		}
 	}
 
@@ -4986,7 +4988,7 @@
 	 */
 	tw32_f(MAC_LOW_WMARK_MAX_RX_FRAME, 2);
 
-	err = tg3_setup_phy(tp);
+	err = tg3_setup_phy(tp, 1);
 	if (err)
 		return err;
 
@@ -5168,7 +5170,7 @@
 				phy_event = 1;
 
 			if (phy_event)
-				tg3_setup_phy(tp);
+				tg3_setup_phy(tp, 0);
 		} else if (tp->tg3_flags & TG3_FLAG_POLL_SERDES) {
 			u32 mac_stat = tr32(MAC_STATUS);
 			int need_setup = 0;
@@ -5188,7 +5190,7 @@
 				udelay(40);
 				tw32_f(MAC_MODE, tp->mac_mode);
 				udelay(40);
-				tg3_setup_phy(tp);
+				tg3_setup_phy(tp, 0);
 			}
 		}
 
@@ -5869,7 +5871,7 @@
 	struct tg3 *tp = dev->priv;
   
 	if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
-					tp->link_config.phy_is_low_power)
+	    tp->link_config.phy_is_low_power)
 		return -EAGAIN;
 
 	spin_lock_irq(&tp->lock);
@@ -5885,7 +5887,7 @@
 		tp->link_config.duplex = cmd->duplex;
   	}
   
-	tg3_setup_phy(tp);
+	tg3_setup_phy(tp, 1);
 	spin_unlock(&tp->tx_lock);
 	spin_unlock_irq(&tp->lock);
