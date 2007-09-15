From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Sat, 15 Sep 2007 09:14:52 -0400
Message-ID: <20070915131452.GA6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4604 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029AbXIONko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 09:40:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Two more fixes for 2.6.23, including one for kernel.org bug 8937...

Thanks,

John

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Larry Finger (1):
      bcm43xx: Fix cancellation of work queue crashes

Masakazu Mokuno (1):
      As struct iw_point is bi-directional payload, we should copy back the content

 drivers/net/wireless/bcm43xx/bcm43xx_main.c  |   28 ++++++++++++++++++-------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h  |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c |    2 +-
 fs/compat_ioctl.c                            |   22 ++++++++++++++++---
 4 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index c5d6753..dfbd01e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3183,6 +3183,9 @@ static void bcm43xx_periodic_work_handler(struct work_struct *work)
 	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
+	/* keep from doing and rearming periodic work if shutting down */
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_UNINIT)
+		goto unlock_mutex;
 	if (unlikely(bcm->periodic_state % 60 == 0)) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
@@ -3228,14 +3231,10 @@ static void bcm43xx_periodic_work_handler(struct work_struct *work)
 	mmiowb();
 	bcm->periodic_state++;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+unlock_mutex:
 	mutex_unlock(&bcm->mutex);
 }
 
-void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
-{
-	cancel_rearming_delayed_work(&bcm->periodic_work);
-}
-
 void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
 {
 	struct delayed_work *work = &bcm->periodic_work;
@@ -3285,6 +3284,14 @@ static int bcm43xx_rng_init(struct bcm43xx_private *bcm)
 	return err;
 }
 
+void bcm43xx_cancel_work(struct bcm43xx_private *bcm)
+{
+	/* The system must be unlocked when this routine is entered.
+	 * If not, the next 2 steps may deadlock */
+	cancel_work_sync(&bcm->restart_work);
+	cancel_delayed_work_sync(&bcm->periodic_work);
+}
+
 static int bcm43xx_shutdown_all_wireless_cores(struct bcm43xx_private *bcm)
 {
 	int ret = 0;
@@ -3321,7 +3328,12 @@ static void bcm43xx_free_board(struct bcm43xx_private *bcm)
 {
 	bcm43xx_rng_exit(bcm);
 	bcm43xx_sysfs_unregister(bcm);
-	bcm43xx_periodic_tasks_delete(bcm);
+
+	mutex_lock(&(bcm)->mutex);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
+	mutex_unlock(&(bcm)->mutex);
+
+	bcm43xx_cancel_work(bcm);
 
 	mutex_lock(&(bcm)->mutex);
 	bcm43xx_shutdown_all_wireless_cores(bcm);
@@ -4016,7 +4028,7 @@ static int bcm43xx_net_stop(struct net_device *net_dev)
 	err = bcm43xx_disable_interrupts_sync(bcm);
 	assert(!err);
 	bcm43xx_free_board(bcm);
-	flush_scheduled_work();
+	bcm43xx_cancel_work(bcm);
 
 	return 0;
 }
@@ -4148,9 +4160,9 @@ static void bcm43xx_chip_reset(struct work_struct *work)
 	struct bcm43xx_phyinfo *phy;
 	int err = -ENODEV;
 
+	bcm43xx_cancel_work(bcm);
 	mutex_lock(&(bcm)->mutex);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
-		bcm43xx_periodic_tasks_delete(bcm);
 		phy = bcm43xx_current_phy(bcm);
 		err = bcm43xx_select_wireless_core(bcm, phy->type);
 		if (!err)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index c8f3c53..14cfbeb 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -122,7 +122,7 @@ void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy);
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm);
 
-void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm);
+void bcm43xx_cancel_work(struct bcm43xx_private *bcm);
 void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm);
 
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index c71b998..8ab5f93 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -327,7 +327,7 @@ static ssize_t bcm43xx_attr_phymode_store(struct device *dev,
 		goto out;
 	}
 
-	bcm43xx_periodic_tasks_delete(bcm);
+	bcm43xx_cancel_work(bcm);
 	mutex_lock(&(bcm)->mutex);
 	err = bcm43xx_select_wireless_core(bcm, phytype);
 	if (!err)
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index a6c9078..5a5b711 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2311,8 +2311,10 @@ static int do_wireless_ioctl(unsigned int fd, unsigned int cmd, unsigned long ar
 	struct iwreq __user *iwr_u;
 	struct iw_point __user *iwp;
 	struct compat_iw_point __user *iwp_u;
-	compat_caddr_t pointer;
+	compat_caddr_t pointer_u;
+	void __user *pointer;
 	__u16 length, flags;
+	int ret;
 
 	iwr_u = compat_ptr(arg);
 	iwp_u = (struct compat_iw_point __user *) &iwr_u->u.data;
@@ -2330,17 +2332,29 @@ static int do_wireless_ioctl(unsigned int fd, unsigned int cmd, unsigned long ar
 			   sizeof(iwr->ifr_ifrn.ifrn_name)))
 		return -EFAULT;
 
-	if (__get_user(pointer, &iwp_u->pointer) ||
+	if (__get_user(pointer_u, &iwp_u->pointer) ||
 	    __get_user(length, &iwp_u->length) ||
 	    __get_user(flags, &iwp_u->flags))
 		return -EFAULT;
 
-	if (__put_user(compat_ptr(pointer), &iwp->pointer) ||
+	if (__put_user(compat_ptr(pointer_u), &iwp->pointer) ||
 	    __put_user(length, &iwp->length) ||
 	    __put_user(flags, &iwp->flags))
 		return -EFAULT;
 
-	return sys_ioctl(fd, cmd, (unsigned long) iwr);
+	ret = sys_ioctl(fd, cmd, (unsigned long) iwr);
+
+	if (__get_user(pointer, &iwp->pointer) ||
+	    __get_user(length, &iwp->length) ||
+	    __get_user(flags, &iwp->flags))
+		return -EFAULT;
+
+	if (__put_user(ptr_to_compat(pointer), &iwp_u->pointer) ||
+	    __put_user(length, &iwp_u->length) ||
+	    __put_user(flags, &iwp_u->flags))
+		return -EFAULT;
+
+	return ret;
 }
 
 /* Since old style bridge ioctl's endup using SIOCDEVPRIVATE
-- 
John W. Linville
linville@tuxdriver.com
