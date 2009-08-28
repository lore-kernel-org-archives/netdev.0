From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 6/9] fanotify: merge notification events with different masks
Date: Fri, 28 Aug 2009 14:56:19 -0400
Message-ID: <20090828185618.8014.55255.stgit@paris.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532AbZH1S42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 14:56:28 -0400
In-Reply-To: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of just merging fanotify events if they are exactly the same, merge
notification events with different masks.  To do this we have to clone the
old event, update the mask in the new event with the new merged mask, and
put the new event in place of the old event.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/fanotify/fanotify.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index caf34bb..e8e56cb 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -10,8 +10,7 @@
 
 static bool try_merge(struct fsnotify_event *old, struct fsnotify_event *new)
 {
-	if ((old->mask == new->mask) &&
-	    (old->to_tell == new->to_tell) &&
+	if ((old->to_tell == new->to_tell) &&
 	    (old->data_type == new->data_type)) {
 		switch (old->data_type) {
 		case (FSNOTIFY_EVENT_PATH):
@@ -29,15 +28,28 @@ static bool try_merge(struct fsnotify_event *old, struct fsnotify_event *new)
 
 static int fanotify_merge(struct list_head *list, struct fsnotify_event *event)
 {
-	struct fsnotify_event_holder *holder;
+	struct fsnotify_event_holder *test_holder, *prev;
 	struct fsnotify_event *test_event;
+	struct fsnotify_event *new_event;
+	int ret;
 
 	/* and the list better be locked by something too! */
 
-	list_for_each_entry_reverse(holder, list, event_list) {
-		test_event = holder->event;
-		if (try_merge(test_event, event))
+	list_for_each_entry_safe_reverse(test_holder, prev, list, event_list) {
+		test_event = test_holder->event;
+		if (try_merge(test_event, event)) {
+			if (test_event->mask == event->mask)
+				return -EEXIST;
+			new_event = fsnotify_clone_event(test_event);
+			if (!new_event)
+				return 0;
+			new_event->mask = (test_event->mask | event->mask);
+			ret = fsnotify_replace_event(test_holder, new_event);
+			fsnotify_put_event(new_event); /* matches the ref from clone */
+			if (ret)
+				return ret;
 			return -EEXIST;
+		}
 	}
 
 	return 0;

