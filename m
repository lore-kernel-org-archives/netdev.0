From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 5/9] fanotify:drop notification if they exist in the outgoing
	queue
Date: Fri, 28 Aug 2009 14:56:12 -0400
Message-ID: <20090828185611.8014.4931.stgit@paris.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 59bc883..caf34bb 100644
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
 

