From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6 (for 2.6.23)
Date: Sat, 22 Sep 2007 12:08:03 -0400
Message-ID: <20070922160803.GB4738@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2170 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbXIVQiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 12:38:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

One of these is a fairly obvious one-liner (COMPATIBLE_IOCTL).  The other is
a bit more complicated, but fixes a problem created by a patch already
in 2.6.23 (reported this week by Yoshifuji).  Please pull this for
2.6.23 if at all possible.

Thanks!

John

---

Individual patches are here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 81cfe79b9c577139a873483654640eb3f6e78c39:
  Linus Torvalds (1):
        Linux 2.6.23-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Jean Tourrilhes (1):
      WE : Add missing auth compat-ioctl

Larry Finger (1):
      softmac: Fix inability to associate with WEP networks

 fs/compat_ioctl.c                              |    2 +
 net/ieee80211/softmac/ieee80211softmac_assoc.c |    2 -
 net/ieee80211/softmac/ieee80211softmac_wx.c    |   54 +++++++++---------------
 3 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 5a5b711..37310b0 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -3190,6 +3190,8 @@ COMPATIBLE_IOCTL(SIOCSIWRETRY)
 COMPATIBLE_IOCTL(SIOCGIWRETRY)
 COMPATIBLE_IOCTL(SIOCSIWPOWER)
 COMPATIBLE_IOCTL(SIOCGIWPOWER)
+COMPATIBLE_IOCTL(SIOCSIWAUTH)
+COMPATIBLE_IOCTL(SIOCGIWAUTH)
 /* hiddev */
 COMPATIBLE_IOCTL(HIDIOCGVERSION)
 COMPATIBLE_IOCTL(HIDIOCAPPLICATION)
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index afb6c66..e475f2e 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -273,8 +273,6 @@ ieee80211softmac_assoc_work(struct work_struct *work)
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
 			if (ieee80211softmac_start_scan(mac)) {
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
-				mac->associnfo.associating = 0;
-				mac->associnfo.associated = 0;
 			}
 			goto out;
 		} else {
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index d054e92..442b987 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -70,44 +70,30 @@ ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 			      char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
-	struct ieee80211softmac_network *n;
 	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
 
 check_assoc_again:
 	mutex_lock(&sm->associnfo.mutex);
-	/* Check if we're already associating to this or another network
-	 * If it's another network, cancel and start over with our new network
-	 * If it's our network, ignore the change, we're already doing it!
-	 */
 	if((sm->associnfo.associating || sm->associnfo.associated) &&
 	   (data->essid.flags && data->essid.length)) {
-		/* Get the associating network */
-		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == data->essid.length &&
-		   !memcmp(n->essid.data, extra, n->essid.len)) {
-			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
-				MAC_ARG(sm->associnfo.bssid));
-			goto out;
-		} else {
-			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
-			/* Cancel assoc work */
-			cancel_delayed_work(&sm->associnfo.work);
-			/* We don't have to do this, but it's a little cleaner */
-			list_for_each_entry(authptr, &sm->auth_queue, list)
-				cancel_delayed_work(&authptr->work);
-			sm->associnfo.bssvalid = 0;
-			sm->associnfo.bssfixed = 0;
-			sm->associnfo.associating = 0;
-			sm->associnfo.associated = 0;
-			/* We must unlock to avoid deadlocks with the assoc workqueue
-			 * on the associnfo.mutex */
-			mutex_unlock(&sm->associnfo.mutex);
-			flush_scheduled_work();
-			/* Avoid race! Check assoc status again. Maybe someone started an
-			 * association while we flushed. */
-			goto check_assoc_again;
-		}
+		dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
+		/* Cancel assoc work */
+		cancel_delayed_work(&sm->associnfo.work);
+		/* We don't have to do this, but it's a little cleaner */
+		list_for_each_entry(authptr, &sm->auth_queue, list)
+			cancel_delayed_work(&authptr->work);
+		sm->associnfo.bssvalid = 0;
+		sm->associnfo.bssfixed = 0;
+		sm->associnfo.associating = 0;
+		sm->associnfo.associated = 0;
+		/* We must unlock to avoid deadlocks with the assoc workqueue
+		 * on the associnfo.mutex */
+		mutex_unlock(&sm->associnfo.mutex);
+		flush_scheduled_work();
+		/* Avoid race! Check assoc status again. Maybe someone started an
+		 * association while we flushed. */
+		goto check_assoc_again;
 	}
 
 	sm->associnfo.static_essid = 0;
@@ -153,13 +139,13 @@ ieee80211softmac_wx_get_essid(struct net_device *net_dev,
 		data->essid.length = sm->associnfo.req_essid.len;
 		data->essid.flags = 1;  /* active */
 		memcpy(extra, sm->associnfo.req_essid.data, sm->associnfo.req_essid.len);
-	}
-
+		dprintk(KERN_INFO PFX "Getting essid from req_essid\n");
+	} else if (sm->associnfo.associated || sm->associnfo.associating) {
 	/* If we're associating/associated, return that */
-	if (sm->associnfo.associated || sm->associnfo.associating) {
 		data->essid.length = sm->associnfo.associate_essid.len;
 		data->essid.flags = 1;  /* active */
 		memcpy(extra, sm->associnfo.associate_essid.data, sm->associnfo.associate_essid.len);
+		dprintk(KERN_INFO PFX "Getting essid from associate_essid\n");
 	}
 	mutex_unlock(&sm->associnfo.mutex);
 
-- 
John W. Linville
linville@tuxdriver.com
