From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/3] AFS: Fix VLocation record update wakeup
Date: Fri, 27 Apr 2007 15:31:35 +0100
Message-ID: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890AbXD0Obh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 10:31:37 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3REVasi030620
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 10:31:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the wakeup transitions after a VLocation record update completes one way
or another.  This builds on Dave Miller's partial fix.

Also move wakeups outside the spinlocked sections.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/vlocation.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 74cce17..6c8e95a 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -416,8 +416,8 @@ fill_in_record:
 		goto error_abandon;
 	spin_lock(&vl->lock);
 	vl->state = AFS_VL_VALID;
-	wake_up(&vl->waitq);
 	spin_unlock(&vl->lock);
+	wake_up(&vl->waitq);
 
 	/* schedule for regular updates */
 	afs_vlocation_queue_for_updates(vl);
@@ -442,7 +442,7 @@ found_in_memory:
 
 		_debug("invalid [state %d]", state);
 
-		if ((state == AFS_VL_NEW || state == AFS_VL_NO_VOLUME)) {
+		if (state == AFS_VL_NEW || state == AFS_VL_NO_VOLUME) {
 			vl->state = AFS_VL_CREATING;
 			spin_unlock(&vl->lock);
 			goto fill_in_record;
@@ -453,11 +453,10 @@ found_in_memory:
 		_debug("wait");
 
 		spin_unlock(&vl->lock);
-		ret = wait_event_interruptible(
-			vl->waitq,
-			vl->state == AFS_VL_NEW ||
-			vl->state == AFS_VL_VALID ||
-			vl->state == AFS_VL_NO_VOLUME);
+		ret = wait_event_interruptible(vl->waitq,
+					       vl->state == AFS_VL_NEW ||
+					       vl->state == AFS_VL_VALID ||
+					       vl->state == AFS_VL_NO_VOLUME);
 		if (ret < 0)
 			goto error;
 		spin_lock(&vl->lock);
@@ -471,8 +470,8 @@ success:
 error_abandon:
 	spin_lock(&vl->lock);
 	vl->state = AFS_VL_NEW;
-	wake_up(&vl->waitq);
 	spin_unlock(&vl->lock);
+	wake_up(&vl->waitq);
 error:
 	ASSERT(vl != NULL);
 	afs_put_vlocation(vl);
@@ -675,7 +674,6 @@ static void afs_vlocation_updater(struct work_struct *work)
 	case 0:
 		afs_vlocation_apply_update(vl, &vldb);
 		vl->state = AFS_VL_VALID;
-		wake_up(&vl->waitq);
 		break;
 	case -ENOMEDIUM:
 		vl->state = AFS_VL_VOLUME_DELETED;
@@ -685,6 +683,7 @@ static void afs_vlocation_updater(struct work_struct *work)
 		break;
 	}
 	spin_unlock(&vl->lock);
+	wake_up(&vl->waitq);
 
 	/* and then reschedule */
 	_debug("reschedule");

