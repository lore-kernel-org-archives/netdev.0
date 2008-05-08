From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] wireless: Add missing locking to cfg80211_dev_rename
Date: Thu, 08 May 2008 14:30:18 -0700
Message-ID: <m1ej8ccwlx.fsf_-_@frodo.ebiederm.org>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
	<m13aoueyq8.fsf@frodo.ebiederm.org> <20080507190838.GA4467@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36295 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbYEHVkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 17:40:03 -0400
In-Reply-To: <20080507190838.GA4467@suse.de> (Greg KH's message of "Wed, 7 May
	2008 12:08:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


device_rename only performs useful and race free validity
checking at the optional sysfs level so depending on it
for all of the validity checking in cfg80211_dev_rename
is racy.

Instead implement all of the needed validity checking
and locking in cfg80211_dev_rename.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/wireless/core.c |   33 ++++++++++++++++++++++++++++-----
 1 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index 80afacd..f1da0b9 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -143,8 +143,11 @@ void cfg80211_put_dev(struct cfg80211_registered_device *drv)
 int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
 			char *newname)
 {
+	struct cfg80211_registered_device *drv;
 	int idx, taken = -1, result, digits;
 
+	mutex_lock(&cfg80211_drv_mutex);
+
 	/* prohibit calling the thing phy%d when %d is not its number */
 	sscanf(newname, PHY_NAME "%d%n", &idx, &taken);
 	if (taken == strlen(newname) && idx != rdev->idx) {
@@ -156,14 +159,30 @@ int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
 		 * deny the name if it is phy<idx> where <idx> is printed
 		 * without leading zeroes. taken == strlen(newname) here
 		 */
+		result = -EINVAL;
 		if (taken == strlen(PHY_NAME) + digits)
-			return -EINVAL;
+			goto out_unlock;
+	}
+
+
+	/* Ignore nop renames */
+	result = 0;
+	if (strcmp(newname, dev_name(&rdev->wiphy.dev)) == 0)
+		goto out_unlock;
+
+	/* Ensure another device does not already have this name. */
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		result = -EINVAL;
+		if (strcmp(newname, dev_name(&drv->wiphy.dev)) == 0)
+			goto out_unlock;
 	}
 
-	/* this will check for collisions */
+	/* this will only check for collisions in sysfs
+	 * which is not even always compiled in.
+	 */
 	result = device_rename(&rdev->wiphy.dev, newname);
 	if (result)
-		return result;
+		goto out_unlock;
 
 	if (!debugfs_rename(rdev->wiphy.debugfsdir->d_parent,
 			    rdev->wiphy.debugfsdir,
@@ -172,9 +191,13 @@ int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
 		printk(KERN_ERR "cfg80211: failed to rename debugfs dir to %s!\n",
 		       newname);
 
-	nl80211_notify_dev_rename(rdev);
+	result = 0;
+out_unlock:
+	mutex_unlock(&cfg80211_drv_mutex);
+	if (result == 0)
+		nl80211_notify_dev_rename(rdev);
 
-	return 0;
+	return result;
 }
 
 /* exported functions */
-- 
1.5.3.rc6.17.g1911

