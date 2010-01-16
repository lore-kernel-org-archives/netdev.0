From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: phylib: kernel oops on resume with 2.6.33-rc4
Date: Sun, 17 Jan 2010 01:37:03 +0300
Message-ID: <20100116223703.GA13190@oksana.dev.rtsoft.ru>
References: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EA9@dbde02.ent.ti.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Nori, Sekhar" <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:55562 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752729Ab0APWhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 17:37:07 -0500
Content-Disposition: inline
In-Reply-To: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EA9@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sat, Jan 16, 2010 at 09:38:34PM +0530, Nori, Sekhar wrote:
> Hello all,
> 
> I am hitting a kernel oops when resuming from suspend-to-RAM on 2.6.33-rc4
> kernel.
> 
> The MAC is TI DaVinci EMAC and PHY is SMSC LAN8710. However, I also hit the
> issue even when using generic PHY driver (CONFIG_SMSC_PHY turned off).
> 
> On reverting commit 541cd3e "phylib: Fix deadlock on resume" which was
> introduced in 2.6.33-rc4, the issue doesn't come about. So far, I haven't
> figured out how this particular commit is causing the oops. Full oops report
> is attached. Appreciate any help in debugging this.

It seems phy_start_machine() needlessly reinitialized work
struct. This is OK for ucc_geth and gianfar driver because
these drivers do not detach PHYs on suspend, but TI davinci
does. :-/

Can you try the patch down below?

Thanks!

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index b0e9f9c..0295097 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -410,7 +410,6 @@ EXPORT_SYMBOL(phy_start_aneg);
 
 
 static void phy_change(struct work_struct *work);
-static void phy_state_machine(struct work_struct *work);
 
 /**
  * phy_start_machine - start PHY state machine tracking
@@ -430,7 +429,6 @@ void phy_start_machine(struct phy_device *phydev,
 {
 	phydev->adjust_state = handler;
 
-	INIT_DELAYED_WORK(&phydev->state_queue, phy_state_machine);
 	schedule_delayed_work(&phydev->state_queue, HZ);
 }
 
@@ -761,7 +759,7 @@ EXPORT_SYMBOL(phy_start);
  * phy_state_machine - Handle the state machine
  * @work: work_struct that describes the work to be done
  */
-static void phy_state_machine(struct work_struct *work)
+void phy_state_machine(struct work_struct *work)
 {
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct phy_device *phydev =
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8212b2b..adbc0fd 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -177,6 +177,7 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	dev->state = PHY_DOWN;
 
 	mutex_init(&dev->lock);
+	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
 
 	return dev;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7968def..6a7eb40 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -485,6 +485,7 @@ void phy_driver_unregister(struct phy_driver *drv);
 int phy_driver_register(struct phy_driver *new_driver);
 void phy_prepare_link(struct phy_device *phydev,
 		void (*adjust_link)(struct net_device *));
+void phy_state_machine(struct work_struct *work);
 void phy_start_machine(struct phy_device *phydev,
 		void (*handler)(struct net_device *));
 void phy_stop_machine(struct phy_device *phydev);
