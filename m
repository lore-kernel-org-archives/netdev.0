From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] additional net driver fixes
Date: Tue, 25 Sep 2007 15:51:34 -0400
Message-ID: <20070925195134.GA26397@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33571 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745AbXIYTvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 15:51:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These two wireless fixes are IN ADDITION to the previously submitted
fixes.  Same linear history.  In other words, if you pull
"upstream-linus", you will get both the changes below, _and_ the changes
I submitted yesterday.  If you have already pulled yesterday's fixes,
then you will only receive the changesets below.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 fs/compat_ioctl.c                              |    2 +
 net/ieee80211/softmac/ieee80211softmac_assoc.c |    2 -
 net/ieee80211/softmac/ieee80211softmac_wx.c    |   54 +++++++++---------------
 7 files changed, 61 insertions(+), 52 deletions(-)

Jean Tourrilhes (1):
      WE : Add missing auth compat-ioctl

Larry Finger (1):
      softmac: Fix inability to associate with WEP networks

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
 
