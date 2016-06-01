From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 2/4] inotify: Convert inotify limits to be accounted per-realuser/per-namespace
Date: Wed,  1 Jun 2016 10:52:58 +0300
Message-ID: <1464767580-22732-3-git-send-email-kernel@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com, Nikolay Borisov <kernel@kyup.com>
To: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38641 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757528AbcFAHxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 03:53:17 -0400
Received: by mail-wm0-f49.google.com with SMTP id a20so15045302wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 00:53:15 -0700 (PDT)
In-Reply-To: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 fs/notify/inotify/inotify_fsnotify.c | 14 +++++++++++++-
 fs/notify/inotify/inotify_user.c     | 23 +++++++++++++++--------
 include/linux/sched.h                |  2 --
 3 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 2cd900c2c737..efaeec3f2e26 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -166,7 +166,19 @@ static void inotify_free_group_priv(struct fsnotify_group *group)
 	idr_for_each(&group->inotify_data.idr, idr_callback, group);
 	idr_destroy(&group->inotify_data.idr);
 	if (group->inotify_data.user) {
-		atomic_dec(&group->inotify_data.user->inotify_devs);
+		struct user_struct *user = group->inotify_data.user;
+		void *key = group->inotify_data.userns_ptr;
+		struct inotify_state *state;
+
+		spin_lock(&user->inotify_lock);
+		state = __find_inotify_state(user, key);
+		if (--state->inotify_devs == 0)
+			hash_del(&state->node);
+		spin_unlock(&user->inotify_lock);
+
+		if (state->inotify_devs == 0)
+			kfree(state);
+
 		free_uid(group->inotify_data.user);
 	}
 }
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index ae7ec2414252..e7cc4eaa838f 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -94,7 +94,7 @@ static int inotify_init_state(struct user_struct *user,
 	int ret = 0;
 
 	spin_lock(&user->inotify_lock);
-	state =  __find_inotify_count(user, key);
+	state =  __find_inotify_state(user, key);
 
 	if (!state) {
 		spin_unlock(&user->inotify_lock);
@@ -536,7 +536,8 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
 	/* remove this mark from the idr */
 	inotify_remove_from_idr(group, i_mark);
 
-	atomic_dec(&group->inotify_data.user->inotify_watches);
+	inotify_dec_watches(group->inotify_data.user,
+			    group->inotify_data.userns_ptr);
 }
 
 /* ding dong the mark is dead */
@@ -609,6 +610,8 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	int ret;
 	struct idr *idr = &group->inotify_data.idr;
 	spinlock_t *idr_lock = &group->inotify_data.idr_lock;
+	struct user_struct *user = group->inotify_data.user;
+	void *key = group->inotify_data.userns_ptr;
 
 	mask = inotify_arg_to_mask(arg);
 
@@ -621,7 +624,7 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	tmp_i_mark->wd = -1;
 
 	ret = -ENOSPC;
-	if (atomic_read(&group->inotify_data.user->inotify_watches) >= inotify_max_user_watches)
+	if (inotify_read_watches(user, key) >= inotify_max_user_watches)
 		goto out_err;
 
 	ret = inotify_add_to_idr(idr, idr_lock, tmp_i_mark);
@@ -638,7 +641,7 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	}
 
 	/* increment the number of watches the user has */
-	atomic_inc(&group->inotify_data.user->inotify_watches);
+	inotify_inc_watches(user, key);
 
 	/* return the watch descriptor for this new mark */
 	ret = tmp_i_mark->wd;
@@ -669,6 +672,9 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 {
 	struct fsnotify_group *group;
 	struct inotify_event_info *oevent;
+	struct user_struct *user = get_current_user();
+	void *key = current_user_ns();
+	int ret;
 
 	group = fsnotify_alloc_group(&inotify_fsnotify_ops);
 	if (IS_ERR(group))
@@ -689,12 +695,13 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 
 	spin_lock_init(&group->inotify_data.idr_lock);
 	idr_init(&group->inotify_data.idr);
-	group->inotify_data.user = get_current_user();
+	group->inotify_data.user = user;
+	group->inotify_data.userns_ptr = key;
 
-	if (atomic_inc_return(&group->inotify_data.user->inotify_devs) >
-	    inotify_max_user_instances) {
+	ret = inotify_init_state(user, key);
+	if (ret < 0) {
 		fsnotify_destroy_group(group);
-		return ERR_PTR(-EMFILE);
+		return ERR_PTR(ret);
 	}
 
 	return group;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0c55d951d0bb..8f589b32ed15 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -842,8 +842,6 @@ struct user_struct {
 #ifdef CONFIG_INOTIFY_USER
 	spinlock_t inotify_lock;
 	DECLARE_HASHTABLE(inotify_tbl, 6);
-	atomic_t inotify_watches; /* How many inotify watches does this user have? */
-	atomic_t inotify_devs;	/* How many inotify devs does this user have opened? */
 #endif
 #ifdef CONFIG_FANOTIFY
 	atomic_t fanotify_listeners;
-- 
2.5.0
