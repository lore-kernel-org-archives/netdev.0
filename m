From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 4/9] fanotify: fscking all notification system
Date: Fri, 28 Aug 2009 14:56:04 -0400
Message-ID: <20090828185604.8014.19115.stgit@paris.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752447AbZH1S4Q@vger.kernel.org>
In-Reply-To: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fanotify is a novel file notification system which bases notification on
giving userspace both an event type (open, close, read, write) and an open
file descriptor to the object in question.  This should address a number of
races and problems with other notification systems like inotify and dnotify
and should allow the future implementation of blocking or access controlled
notification.  These are useful for on access scanners or hierachical storage
management schemes.

This patch just implements the basics of the fsnotify functions.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/Kconfig             |    1 
 fs/notify/Makefile            |    1 
 fs/notify/fanotify/Kconfig    |   11 +++++
 fs/notify/fanotify/Makefile   |    1 
 fs/notify/fanotify/fanotify.c |   90 +++++++++++++++++++++++++++++++++++++++++
 fs/notify/fanotify/fanotify.h |   12 +++++
 include/linux/Kbuild          |    1 
 include/linux/fanotify.h      |   40 ++++++++++++++++++
 8 files changed, 157 insertions(+), 0 deletions(-)
 create mode 100644 fs/notify/fanotify/Kconfig
 create mode 100644 fs/notify/fanotify/Makefile
 create mode 100644 fs/notify/fanotify/fanotify.c
 create mode 100644 fs/notify/fanotify/fanotify.h
 create mode 100644 include/linux/fanotify.h

diff --git a/fs/notify/Kconfig b/fs/notify/Kconfig
index dffbb09..22c629e 100644
--- a/fs/notify/Kconfig
+++ b/fs/notify/Kconfig
@@ -3,3 +3,4 @@ config FSNOTIFY
 
 source "fs/notify/dnotify/Kconfig"
 source "fs/notify/inotify/Kconfig"
+source "fs/notify/fanotify/Kconfig"
diff --git a/fs/notify/Makefile b/fs/notify/Makefile
index 0922cc8..396a387 100644
--- a/fs/notify/Makefile
+++ b/fs/notify/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_FSNOTIFY)		+= fsnotify.o notification.o group.o inode_mark.o
 
 obj-y			+= dnotify/
 obj-y			+= inotify/
+obj-y			+= fanotify/
diff --git a/fs/notify/fanotify/Kconfig b/fs/notify/fanotify/Kconfig
new file mode 100644
index 0000000..70631ed
--- /dev/null
+++ b/fs/notify/fanotify/Kconfig
@@ -0,0 +1,11 @@
+config FANOTIFY
+	bool "Filesystem wide access notification"
+	select FSNOTIFY
+	default y
+	---help---
+	   Say Y here to enable fanotify suport.  fanotify is a system wide
+	   file access notification interface.  Events are read from from a
+	   socket and in doing so an fd is created in the reading process
+	   which points to the same data as the one on which the event occured.
+
+	   If unsure, say Y.
diff --git a/fs/notify/fanotify/Makefile b/fs/notify/fanotify/Makefile
new file mode 100644
index 0000000..e7d39c0
--- /dev/null
+++ b/fs/notify/fanotify/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_FANOTIFY)		+= fanotify.o
diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
new file mode 100644
index 0000000..59bc883
--- /dev/null
+++ b/fs/notify/fanotify/fanotify.c
@@ -0,0 +1,90 @@
+#include <linux/fdtable.h>
+#include <linux/fsnotify_backend.h>
+#include <linux/init.h>
+#include <linux/kernel.h> /* UINT_MAX */
+#include <linux/net.h> /* struct socket */
+#include <linux/sched.h> /* task_struct */
+#include <linux/types.h>
+
+#include "fanotify.h"
+
+static int fanotify_handle_event(struct fsnotify_group *group, struct fsnotify_event *event)
+{
+	int ret;
+
+	BUILD_BUG_ON(FAN_ACCESS != FS_ACCESS);
+	BUILD_BUG_ON(FAN_MODIFY != FS_MODIFY);
+	BUILD_BUG_ON(FAN_CLOSE_NOWRITE != FS_CLOSE_NOWRITE);
+	BUILD_BUG_ON(FAN_CLOSE_WRITE != FS_CLOSE_WRITE);
+	BUILD_BUG_ON(FAN_OPEN != FS_OPEN);
+	BUILD_BUG_ON(FAN_EVENT_ON_CHILD != FS_EVENT_ON_CHILD);
+	BUILD_BUG_ON(FAN_Q_OVERFLOW != FS_Q_OVERFLOW);
+
+	ret = fsnotify_add_notify_event(group, event, NULL, NULL);
+
+	return ret;
+}
+
+static bool fanotify_should_send_event(struct fsnotify_group *group, struct inode *inode,
+				       __u32 mask, void *data, int data_type)
+{
+	struct fsnotify_mark_entry *entry;
+	bool send;
+
+	/* if we are in an open operation do not send events to fanotify */
+	if (current->flags & PF_NONOTIFY)
+		return false;
+
+	/* sorry, fanotify only gives a damn about files and dirs */
+	if (!S_ISREG(inode->i_mode) &&
+	    !S_ISDIR(inode->i_mode))
+		return false;
+
+	/* if we don't have enough info to send an event to userspace say no */
+	if ((data_type != FSNOTIFY_EVENT_FILE) &&
+	    (data_type != FSNOTIFY_EVENT_PATH))
+		return false;
+
+	/* if this file was opened by fanotify don't send events about it */
+	if (data_type == FSNOTIFY_EVENT_FILE) {
+		struct file *file;
+
+		file = (struct file *)data;
+		if (file->f_mode & FMODE_NONOTIFY)
+			return false;
+	}
+
+	spin_lock(&inode->i_lock);
+	entry = fsnotify_find_mark_entry(group, inode);
+	spin_unlock(&inode->i_lock);
+	if (!entry)
+		return false;
+
+	/* if the event is for a child and this inode doesn't care about
+	 * events on the child, don't send it! */
+	if ((mask & FS_EVENT_ON_CHILD) &&
+	    !(entry->mask & FS_EVENT_ON_CHILD))
+		send = false;
+	else {
+		if (!(entry->mask & FS_EVENT_ON_CHILD) &&
+		    (mask & FS_EVENT_ON_CHILD))
+			send = false;
+		else {
+			mask = (mask & ~FS_EVENT_ON_CHILD);
+			send = (entry->mask & mask);
+		}
+	}
+
+	/* find took a reference */
+	fsnotify_put_mark(entry);
+
+	return send;
+}
+
+const struct fsnotify_ops fanotify_ops = {
+	.handle_event = fanotify_handle_event,
+	.should_send_event = fanotify_should_send_event,
+	.free_group_priv = NULL,
+	.free_event_priv = NULL,
+	.freeing_mark = NULL,
+};
diff --git a/fs/notify/fanotify/fanotify.h b/fs/notify/fanotify/fanotify.h
new file mode 100644
index 0000000..a8785c1
--- /dev/null
+++ b/fs/notify/fanotify/fanotify.h
@@ -0,0 +1,12 @@
+#include <linux/fanotify.h>
+#include <linux/fsnotify_backend.h>
+#include <linux/net.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+static inline bool fanotify_is_mask_valid(__u32 mask)
+{
+	if (mask & ~(FAN_ALL_INCOMING_EVENTS))
+		return false;
+	return true;
+}
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e7d84ff..b298c0e 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -206,6 +206,7 @@ unifdef-y += ethtool.h
 unifdef-y += eventpoll.h
 unifdef-y += signalfd.h
 unifdef-y += ext2_fs.h
+unifdef-y += fanotify.h
 unifdef-y += fb.h
 unifdef-y += fcntl.h
 unifdef-y += filter.h
diff --git a/include/linux/fanotify.h b/include/linux/fanotify.h
new file mode 100644
index 0000000..b560f86
--- /dev/null
+++ b/include/linux/fanotify.h
@@ -0,0 +1,40 @@
+#ifndef _LINUX_FANOTIFY_H
+#define _LINUX_FANOTIFY_H
+
+#include <linux/types.h>
+
+/* the following events that user-space can register for */
+#define FAN_ACCESS		0x00000001	/* File was accessed */
+#define FAN_MODIFY		0x00000002	/* File was modified */
+#define FAN_CLOSE_WRITE		0x00000008	/* Unwrittable file closed */
+#define FAN_CLOSE_NOWRITE	0x00000010	/* Writtable file closed */
+#define FAN_OPEN		0x00000020	/* File was opened */
+
+#define FAN_EVENT_ON_CHILD	0x08000000	/* interested in child events */
+
+/* FIXME currently Q's have no limit.... */
+#define FAN_Q_OVERFLOW		0x00004000	/* Event queued overflowed */
+
+/* helper events */
+#define FAN_CLOSE		(FAN_CLOSE_WRITE | FAN_CLOSE_NOWRITE) /* close */
+
+/*
+ * All of the events - we build the list by hand so that we can add flags in
+ * the future and not break backward compatibility.  Apps will get only the
+ * events that they originally wanted.  Be sure to add new events here!
+ */
+#define FAN_ALL_EVENTS (FAN_ACCESS |\
+			FAN_MODIFY |\
+			FAN_CLOSE |\
+			FAN_OPEN)
+
+/*
+ * All legal FAN bits userspace can request (although possibly not all
+ * at the same time.
+ */
+#define FAN_ALL_INCOMING_EVENTS	(FAN_ALL_EVENTS |\
+				 FAN_EVENT_ON_CHILD)
+#ifdef __KERNEL__
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_FANOTIFY_H */
