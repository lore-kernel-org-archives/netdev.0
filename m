From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 4/8] fanotify:drop notification if they exist in the outgoing
	queue
Date: Fri, 11 Sep 2009 01:26:20 -0400
Message-ID: <20090911052620.32359.13430.stgit@paris.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbZIKF00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 01:26:26 -0400
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fanotify listeners get an open file descriptor to the object in question so
the ordering of operations is not as important as in other notification
systems.  inotify will drop events if the last event in the event FIFO is
the same as the current event.  This patch will drop fanotify events if
they are the same as another event anywhere in the event FIFO.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/fanotify/fanotify.c |   40 ++++++++++++++++++++++++++++++++++++++--
 1 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index b5c2e32..f054300 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -8,6 +8,40 @@
 
 #include "fanotify.h"
 
+static bool try_merge(struct fsnotify_event *old, struct fsnotify_event *new)
+{
+	if ((old->mask == new->mask) &&
+	    (old->to_tell == new->to_tell) &&
+	    (old->data_type == new->data_type)) {
+		switch (old->data_type) {
+		case (FSNOTIFY_EVENT_PATH):
+			if ((old->path.mnt == new->path.mnt) &&
+			    (old->path.dentry == new->path.dentry))
+				return true;
+		case (FSNOTIFY_EVENT_NONE):
+			return true;
+		default:
+			BUG();
+		};
+	}
+	return false;
+}
+
+static int fanotify_merge(struct list_head *list, struct fsnotify_event *event)
+{
+	struct fsnotify_event_holder *holder;
+	struct fsnotify_event *test_event;
+
+	/* and the list better be locked by something too! */
+
+	list_for_each_entry_reverse(holder, list, event_list) {
+		test_event = holder->event;
+		if (try_merge(test_event, event))
+			return -EEXIST;
+	}
+
+	return 0;
+}
 static int fanotify_handle_event(struct fsnotify_group *group, struct fsnotify_event *event)
 {
 	int ret;
@@ -20,8 +54,10 @@ static int fanotify_handle_event(struct fsnotify_group *group, struct fsnotify_e
 	BUILD_BUG_ON(FAN_EVENT_ON_CHILD != FS_EVENT_ON_CHILD);
 	BUILD_BUG_ON(FAN_Q_OVERFLOW != FS_Q_OVERFLOW);
 
-	ret = fsnotify_add_notify_event(group, event, NULL, NULL);
-
+	ret = fsnotify_add_notify_event(group, event, NULL, fanotify_merge);
+	/* -EEXIST means this event was merged with another, not that it was an error */
+	if (ret == -EEXIST)
+		ret = 0;
 	return ret;
 }
 

