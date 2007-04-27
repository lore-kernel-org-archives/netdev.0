From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:41:12 -0700 (PDT)
Message-ID: <20070426.204112.118626412.davem@davemloft.net>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
	<20070426.161522.76328746.davem@davemloft.net>
	<20070426.200809.04441500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755238AbXD0DlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 23:41:04 -0400
In-Reply-To: <20070426.200809.04441500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 20:08:09 -0700 (PDT)

> I just found a problem in your work, you cannot use cmpxchg() in
> generic code, it is not available on all processors:

Here is how I'm fixing this for now to get the tree into
a buildable state.

If you have a better fix, please send it to me relative
to what's in net-2.6, thanks.

commit 39bf09493042200b967cdf2ee6e3f670b7963903
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Apr 26 20:39:14 2007 -0700

    [AFS]: Eliminate cmpxchg() usage in vlocation code.
    
    cmpxchg() is not available on every processor so can't
    be used in generic code.
    
    Replace with spinlock protection on the ->state changes,
    wakeups, and wait loops.
    
    Add what appears to be a missing wakeup on transition
    to AFS_VL_VALID state in afs_vlocation_updater().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 73bfa0b..6dd3197 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -219,7 +219,7 @@ struct afs_vlocation {
 	struct afs_volume	*vols[3];	/* volume access record pointer (index by type) */
 	wait_queue_head_t	waitq;		/* status change waitqueue */
 	time_t			update_at;	/* time at which record should be updated */
-	rwlock_t		lock;		/* access lock */
+	spinlock_t		lock;		/* access lock */
 	afs_vlocation_state_t	state;		/* volume location state */
 	unsigned short		upd_rej_cnt;	/* ENOMEDIUM count during update */
 	unsigned short		upd_busy_cnt;	/* EBUSY count during update */
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 7d9815e..74cce17 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -178,7 +178,7 @@ static struct afs_vlocation *afs_vlocation_alloc(struct afs_cell *cell,
 		INIT_LIST_HEAD(&vl->grave);
 		INIT_LIST_HEAD(&vl->update);
 		init_waitqueue_head(&vl->waitq);
-		rwlock_init(&vl->lock);
+		spin_lock_init(&vl->lock);
 		memcpy(vl->vldb.name, name, namesz);
 	}
 
@@ -414,8 +414,10 @@ fill_in_record:
 	ret = afs_vlocation_fill_in_record(vl, key);
 	if (ret < 0)
 		goto error_abandon;
+	spin_lock(&vl->lock);
 	vl->state = AFS_VL_VALID;
 	wake_up(&vl->waitq);
+	spin_unlock(&vl->lock);
 
 	/* schedule for regular updates */
 	afs_vlocation_queue_for_updates(vl);
@@ -434,22 +436,23 @@ found_in_memory:
 	up_write(&cell->vl_sem);
 
 	/* see if it was an abandoned record that we might try filling in */
+	spin_lock(&vl->lock);
 	while (vl->state != AFS_VL_VALID) {
 		afs_vlocation_state_t state = vl->state;
 
 		_debug("invalid [state %d]", state);
 
 		if ((state == AFS_VL_NEW || state == AFS_VL_NO_VOLUME)) {
-			if (cmpxchg(&vl->state, state, AFS_VL_CREATING) ==
-			    state)
-				goto fill_in_record;
-			continue;
+			vl->state = AFS_VL_CREATING;
+			spin_unlock(&vl->lock);
+			goto fill_in_record;
 		}
 
 		/* must now wait for creation or update by someone else to
 		 * complete */
 		_debug("wait");
 
+		spin_unlock(&vl->lock);
 		ret = wait_event_interruptible(
 			vl->waitq,
 			vl->state == AFS_VL_NEW ||
@@ -457,15 +460,19 @@ found_in_memory:
 			vl->state == AFS_VL_NO_VOLUME);
 		if (ret < 0)
 			goto error;
+		spin_lock(&vl->lock);
 	}
+	spin_unlock(&vl->lock);
 
 success:
 	_leave(" = %p",vl);
 	return vl;
 
 error_abandon:
+	spin_lock(&vl->lock);
 	vl->state = AFS_VL_NEW;
 	wake_up(&vl->waitq);
+	spin_unlock(&vl->lock);
 error:
 	ASSERT(vl != NULL);
 	afs_put_vlocation(vl);
@@ -663,10 +670,12 @@ static void afs_vlocation_updater(struct work_struct *work)
 	vl->upd_busy_cnt = 0;
 
 	ret = afs_vlocation_update_record(vl, NULL, &vldb);
+	spin_lock(&vl->lock);
 	switch (ret) {
 	case 0:
 		afs_vlocation_apply_update(vl, &vldb);
 		vl->state = AFS_VL_VALID;
+		wake_up(&vl->waitq);
 		break;
 	case -ENOMEDIUM:
 		vl->state = AFS_VL_VOLUME_DELETED;
@@ -675,6 +684,7 @@ static void afs_vlocation_updater(struct work_struct *work)
 		vl->state = AFS_VL_UNCERTAIN;
 		break;
 	}
+	spin_unlock(&vl->lock);
 
 	/* and then reschedule */
 	_debug("reschedule");
