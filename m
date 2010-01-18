From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] phylib: Move workqueue initialization to a proper place
Date: Mon, 18 Jan 2010 18:37:16 +0300
Message-ID: <20100118153716.GA30861@oksana.dev.rtsoft.ru>
References: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EA9@dbde02.ent.ti.com>
 <20100116223703.GA13190@oksana.dev.rtsoft.ru>
 <B85A65D85D7EB246BE421B3FB0FBB59301E2025EED@dbde02.ent.ti.com>
 <20100117.192353.85482728.davem@davemloft.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nsekhar@ti.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:43902 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753077Ab0ARPhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 10:37:20 -0500
Content-Disposition: inline
In-Reply-To: <20100117.192353.85482728.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 541cd3ee00a4fe975b22fac6a3bc846bacef37f7 ("phylib: Fix deadlock
on resume") caused TI DaVinci EMAC ethernet driver to oops upon resume:

 PM: resume of devices complete after 237.098 msecs
 Restarting tasks ... done.
 kernel BUG at kernel/workqueue.c:354!
 Unable to handle kernel NULL pointer dereference at virtual address 00000000
 [...]
 Backtrace:
 [<c002c598>] (__bug+0x0/0x2c) from [<c0052a54>] (queue_delayed_work_on+0x74/0xf8)
 [<c00529e0>] (queue_delayed_work_on+0x0/0xf8) from [<c0052b30>] (queue_delayed_work+0x2c/0x30)

The oops pops up because TI DaVinci EMAC driver detaches PHY on
suspend and attaches it back on resume. Attaching makes phylib call
phy_start_machine() that initializes a workqueue. On the other hand,
PHY's resume routine will call phy_start_machine() again, and that
will cause the oops since we just destroyed the already scheduled
workqueue.

This patch fixes the issue by moving workqueue initialization to
phy_device_create().

p.s. We don't see this oops with ucc_geth and gianfar drivers because
they perform a fine-grained suspend, i.e. they just stop the PHYs
without detaching.

Reported-by: Sekhar Nori <nsekhar@ti.com>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Tested-by: Sekhar Nori <nsekhar@ti.com>
---

On Sun, Jan 17, 2010 at 07:23:53PM -0800, David Miller wrote:
[...]
> >> It seems phy_start_machine() needlessly reinitialized work
> >> struct. This is OK for ucc_geth and gianfar driver because
> >> these drivers do not detach PHYs on suspend, but TI davinci
> >> does. :-/
> >>
> >> Can you try the patch down below?
> > 
> > This seems to have fixed the problem. Thanks! I hope this can be
> > included for the next rc. FWIW,
> > 
> > Reported-and-Tested-by: Sekhar Nori <nsekhar@ti.com>
> 
> Anton, please resubmit with your signoff.

Here it is. Thanks!

 drivers/net/phy/phy.c        |    4 +---
 drivers/net/phy/phy_device.c |    1 +
 include/linux/phy.h          |    1 +
 3 files changed, 3 insertions(+), 3 deletions(-)

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
-- 
1.6.5.7

