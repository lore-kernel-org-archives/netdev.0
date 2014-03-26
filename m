From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/7] isdn: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 22:33:39 +0100
Message-ID: <1395869625-15209-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Use del_timer_sync to ensure that the timer is stopped on all CPUs before
the driver exists.

This change was suggested by Thomas Gleixner.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
declarer name module_exit;
identifier ex;
@@

module_exit(ex);

@@
identifier r.ex;
@@

ex(...) {
  <...
- del_timer
+ del_timer_sync
    (...)
  ...>
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.

 drivers/isdn/act2000/module.c  |    2 +-
 drivers/isdn/i4l/isdn_common.c |    2 +-
 drivers/isdn/sc/init.c         |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index 92acc81..d6f19b1 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -390,8 +390,8 @@ static void __exit sc_exit(void)
 		/*
 		 * kill the timers
 		 */
-		del_timer(&(sc_adapter[i]->reset_timer));
-		del_timer(&(sc_adapter[i]->stat_timer));
+		del_timer_sync(&(sc_adapter[i]->reset_timer));
+		del_timer_sync(&(sc_adapter[i]->stat_timer));
 
 		/*
 		 * Tell I4L we're toast
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 130f216..9b856e1 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -2381,7 +2381,7 @@ static void __exit isdn_exit(void)
 	}
 	isdn_tty_exit();
 	unregister_chrdev(ISDN_MAJOR, "isdn");
-	del_timer(&dev->timer);
+	del_timer_sync(&dev->timer);
 	/* call vfree with interrupts enabled, else it will hang */
 	vfree(dev);
 	printk(KERN_NOTICE "ISDN-subsystem unloaded\n");
diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index b4147c0..c3a1b06 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -796,7 +796,7 @@ static void __exit act2000_exit(void)
 	act2000_card *last;
 	while (card) {
 		unregister_card(card);
-		del_timer(&card->ptimer);
+		del_timer_sync(&card->ptimer);
 		card = card->next;
 	}
 	card = cards;
