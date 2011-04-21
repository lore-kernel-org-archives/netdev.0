From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 22/27] HFI: Add event notifications
Date: Thu, 21 Apr 2011 17:38:52 -0400
Message-ID: <1303421937-2325-23-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:52442 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755302Ab1DUVjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:22 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLF7Ob016462
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:15:07 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdCoZ1208560
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:15 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCK0012779
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Interrupts and some error notifications get passed to window users through
events.  User-space applications can register for a signal to be delivered
or can spawn a thread to call into the HFI DD and wait.
Kernel windows can register callbacks.

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/core/Makefile       |    1 +
 drivers/net/hfi/core/hfidd_adpt.c   |    5 +
 drivers/net/hfi/core/hfidd_events.c | 1098 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_init.c   |   35 ++
 drivers/net/hfi/core/hfidd_intr.c   |   40 ++-
 drivers/net/hfi/core/hfidd_proto.h  |   16 +-
 drivers/net/hfi/core/hfidd_window.c |   24 +
 include/linux/hfi/hfidd_client.h    |   64 ++
 include/linux/hfi/hfidd_internal.h  |   69 +++
 include/linux/hfi/hfidd_requests.h  |    3 +
 10 files changed, 1353 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_events.c

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index d2ed86f..da71824 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -3,6 +3,7 @@
 #
 hfi_core-objs:=	hfidd_adpt.o \
 		hfidd_window.o \
+		hfidd_events.o \
 		hfidd_init.o \
 		hfidd_xlat.o \
 		hfidd_map.o \
diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
index 8e3f5af..1e92911 100644
--- a/drivers/net/hfi/core/hfidd_adpt.c
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -116,6 +116,7 @@ int hfidd_alloc_windows(struct hfidd_acs *p_acs)
 
 		/* Initialize window fields */
 		spin_lock_init(&(p_acs->win[i]->win_lock));
+		spin_lock_init(&(p_acs->win[i]->event_lock));
 
 		p_acs->win[i]->ai = p_acs->index;
 		p_acs->win[i]->index = p_acs->dds.window_start + i;
@@ -136,6 +137,8 @@ void hfidd_free_windows(struct hfidd_acs *p_acs)
 	int		i;
 
 	for (i = 0; i < p_acs->dds.window_num; i++) {
+		if (p_acs->win[i])
+			hfidd_events_clean(p_acs, p_acs->win[i]);
 		kfree(p_acs->win[i]);
 		p_acs->win[i] = NULL;
 	}
@@ -208,6 +211,8 @@ int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
 			if (p_acs->state != HFI_AVAIL) {
 				p_acs->isr = query_p->local_node_id;
 				p_acs->state = HFI_AVAIL;
+				/* Notify user that adapter is ready */
+				hfidd_notify_hfi_ready(p_acs);
 			}
 		} else {
 			p_acs->state = HFI_UNAVAIL;
diff --git a/drivers/net/hfi/core/hfidd_events.c b/drivers/net/hfi/core/hfidd_events.c
new file mode 100644
index 0000000..ff92306
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_events.c
@@ -0,0 +1,1098 @@
+/* hfidd_events.c
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/hfi/hfidd_internal.h>
+#include "hfidd_proto.h"
+
+static void rem_events(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		struct hfidd_tid_info *tid_info, unsigned int events,
+		struct hfidd_win_event **event_list);
+static int hfidd_hfi_ready_registration(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *reg);
+static void hfidd_hfi_ready_unregistration(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *reg);
+
+static unsigned int event_mask[HFIDD_NUM_EVENT_TYPES] = {
+	HFIDD_SEND_EVENT,
+	HFIDD_RECV_EVENT,
+	HFIDD_WIN_ERROR_EVENT,
+	HFIDD_HFI_ERROR_EVENT,
+	HFIDD_TERMINATE_EVENT,
+	HFIDD_RELEASE_WINDOW_EVENT,
+	HFIDD_CAU_ERROR_EVENT,
+	HFIDD_ICS_ERROR_EVENT,
+	HFIDD_HFI_READY_REG_EVENT,
+	HFIDD_ROUTE_CHANGE_EVENT,
+	HFIDD_IP_TRC_LVL_EVENT,
+	HFIDD_POOL_SIZE_EVENT};
+
+
+static void hfidd_tid_info_init(struct hfidd_tid_info *tid_info)
+{
+	memset(tid_info, 0, sizeof(*tid_info));
+	sema_init(&(tid_info->tid_sem), 1);
+	INIT_LIST_HEAD(&(tid_info->event_list));
+	init_waitqueue_head(&(tid_info->event_wait));
+	tid_info->th = current;
+}
+
+static void hfidd_tid_info_end(struct hfidd_tid_info *tid_info,
+		struct hfidd_q_event **q_event_list)
+{
+	struct list_head	*pos;
+	struct list_head	*q;
+	struct hfidd_q_event	*ev;
+
+	/* Clean up any remaining events. */
+	list_for_each_safe(pos, q, &(tid_info->event_list)) {
+		ev = list_entry(pos, struct hfidd_q_event, list);
+		list_del(pos);
+		ev->next = *q_event_list;
+		*q_event_list = ev;
+	}
+}
+
+static inline void hfidd_update_eb(struct hfidd_tid_info *tid_info,
+		struct hfi_reg_events *reg_events)
+{
+	tid_info->eb_xd = current->group_leader;
+	tid_info->eb = (struct hfi_event_buffer *)reg_events->info.eb.use.allu;
+}
+
+/* Post an event.  The win->event_lock must be held before calling. */
+static int hfidd_post_event(struct hfidd_acs *p_acs,
+		struct hfidd_tid_info *tid_info, enum hfi_event_type type,
+		unsigned int event, struct hfidd_q_event **q_event_list)
+{
+	int			rc = 0;
+	struct hfidd_q_event	*ev;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_post_event: event=0x%x tid=0x%llx\n",
+		event, tid_info->tid);
+
+	if (tid_info->type == WAIT_FOR_EVENTS) {
+		/* Allocate and fill in the structure for the event. */
+		if (*q_event_list == NULL) {
+			rc = -EFAULT;
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_post_event: internal error - "
+				"%d\n", rc);
+		} else {
+			ev = *q_event_list;
+			*q_event_list = (*q_event_list)->next;
+			ev->event = event;
+
+			/*
+			 * Add the event to the event list and wake up any
+			 * waiting thread.
+			 */
+			list_add(&(ev->list), &(tid_info->event_list));
+			wake_up_interruptible(&(tid_info->event_wait));
+		}
+	}
+
+	return rc;
+}
+
+/*
+ * Wakeup waiting task if necessary.  The win->event_lock must be held before
+ * calling.
+ */
+static int hfidd_events_wakeup(struct hfidd_acs *p_acs,
+		struct hfidd_tid_info *tid_info,
+		struct hfidd_q_event **q_event_list)
+{
+	int			rc = 0;
+	struct list_head	*pos;
+	struct list_head	*q;
+	struct hfidd_q_event	*ev;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_wakeup: tid=0x%llx\n", tid_info->tid);
+	/*
+	 * A well behaved thread will not be waiting for any events when
+	 * wakeup is called.  This code is to handle misbehaving threads.
+	 */
+
+	/*
+	 * Add an event that will cause any misbehaving waiting thread to
+	 * wake up.  Once it wakes up, it will see that we are cleaning up
+	 * (because win->open_close_count has changed) and will end.
+	 */
+	if (*q_event_list == NULL) {
+		rc = -EFAULT;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_wakeup: internal error - "
+			"%d\n", rc);
+		goto hfidd_events_wakeup_error1;
+	}
+
+	ev = *q_event_list;
+	*q_event_list = (*q_event_list)->next;
+	ev->event = HFIDD_TERMINATE;
+	list_add(&(ev->list), &(tid_info->event_list));
+	wake_up_interruptible(&(tid_info->event_wait));
+
+	/* By getting this lock, we make sure that we don't delete tid_info */
+	/* until the thread is done using it. */
+	down(&(tid_info->tid_sem));
+
+	list_for_each_safe(pos, q, &(tid_info->event_list)) {
+		ev = list_entry(pos, struct hfidd_q_event, list);
+		list_del(pos);
+		ev->next = *q_event_list;
+		*q_event_list = ev;
+	}
+
+	up(&(tid_info->tid_sem));
+
+
+hfidd_events_wakeup_error1:
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_wakeup: rc=%d\n", rc);
+	return rc;
+}
+
+/*
+ * Preallocate a group of q events.  We must preallocate because we are
+ * not allowed to use kzalloc once we have the event_lock.
+ */
+static struct hfidd_q_event *hfidd_prealloc_q_events(struct hfidd_acs *p_acs,
+		struct hfidd_window *win, int num_events)
+{
+	int i;
+	struct hfidd_q_event *q_event_list = NULL;
+	struct hfidd_q_event *q_event;
+
+	for (i = 0; i < num_events; i++) {
+		q_event = kzalloc(sizeof(*q_event), GFP_KERNEL);
+		if (q_event == NULL) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_prealloc_q_events: kzalloc failed, "
+				"num_events = %d\n", num_events);
+
+			while (q_event_list != NULL) {
+				q_event = q_event_list->next;
+				kfree(q_event_list);
+				q_event_list = q_event;
+			}
+			return NULL;
+		}
+		q_event->next = q_event_list;
+		q_event_list = q_event;
+	}
+
+	return q_event_list;
+}
+
+/* Return any queue events that haven't been used. */
+static void hfidd_return_q_events(struct hfidd_acs *p_acs,
+		struct hfidd_q_event **q_event_list)
+{
+	struct hfidd_q_event *q_event;
+
+	while (*q_event_list != NULL) {
+		q_event = (*q_event_list)->next;
+		kfree(*q_event_list);
+		*q_event_list = q_event;
+	}
+}
+/*
+ * Preallocate a tid_info structure.  We must preallocate because we are
+ * not allowed to use kzalloc once we have the event_lock.
+ */
+static struct hfidd_tid_info *prealloc_tid_list(struct hfidd_acs *p_acs)
+{
+	struct hfidd_tid_info *tid_list;
+
+	tid_list = kzalloc(sizeof(*tid_list), GFP_KERNEL);
+	if (tid_list == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"prealloc_tid_list: kzalloc tid info failed\n");
+	} else {
+		hfidd_tid_info_init(tid_list);
+		tid_list->next = NULL;
+	}
+	return tid_list;
+}
+
+/* Return a list of hfidd_tid_info structures. */
+static void return_tid_list(struct hfidd_acs *p_acs,
+		struct hfidd_tid_info **tid_list,
+		struct hfidd_q_event **q_event_list)
+{
+	struct hfidd_tid_info *tid_info;
+
+	while (*tid_list != NULL) {
+		tid_info = *tid_list;
+		*tid_list = tid_info->next;
+		hfidd_tid_info_end(tid_info, q_event_list);
+		kfree(tid_info);
+	}
+}
+
+/*
+ * Preallocate a list of hfidd_win_event structures.  We must preallocate
+ * because we are not allowed to use kzalloc once we have the event_lock.
+ */
+static struct hfidd_win_event *prealloc_event_list(struct hfidd_acs *p_acs,
+		unsigned int events)
+{
+	int i;
+	unsigned int		test_bit = HFIDD_LOWEST_EVENT;
+	struct hfidd_win_event	*win_event;
+	struct hfidd_win_event	*event_list = NULL;
+
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		if (events & test_bit) {
+			win_event = kzalloc(sizeof(*win_event), GFP_KERNEL);
+			if (win_event == NULL) {
+				dev_printk(KERN_ERR, p_acs->hfidd_dev,
+					"prealloc_event_list: kzalloc failed\n");
+
+				while (event_list != NULL) {
+					win_event = event_list;
+					event_list = event_list->next;
+					kfree(win_event);
+				}
+				return NULL;
+			}
+			win_event->next = event_list;
+			event_list = win_event;
+		}
+		test_bit <<= 1;
+	}
+	return event_list;
+}
+
+/* Return a list of hfidd_win_event structures. */
+static void return_event_list(struct hfidd_acs *p_acs,
+		struct hfidd_win_event **event_list)
+{
+	struct hfidd_win_event *win_event;
+
+	while (*event_list != NULL) {
+		win_event = *event_list;
+		*event_list = (*event_list)->next;
+		kfree(win_event);
+	}
+}
+
+/*
+ * Add a group of events to the event handling structures.  The caller must
+ * hold win->event_lock.
+ */
+static int add_events(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		struct hfidd_tid_info *tid_info, unsigned int events,
+		struct hfidd_win_event **event_list)
+{
+	int			rc = 0;
+	int			i;
+	unsigned int		test_bit = HFIDD_LOWEST_EVENT;
+	struct hfidd_win_event	*win_event;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"add_events: enter win=0x%x events=0x%x\n",
+		win->index, events);
+
+	/* Add individual pointers from the window to the tid_info. */
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		if (events & test_bit) {
+			/* Add a pointer from the window to the events. */
+			if (*event_list == NULL) {
+				rc = -EFAULT;
+				dev_printk(KERN_ERR, p_acs->hfidd_dev,
+					"add_events: internal error - "
+					"%d\n", rc);
+
+				goto add_events_err1;
+			}
+			win_event = *event_list;
+			*event_list = (*event_list)->next;
+			win_event->tid_info = tid_info;
+			win_event->next = win->events[i];
+			win->events[i] = win_event;
+			atomic_inc(&(win->num_events[i]));
+		}
+		test_bit <<= 1;
+	}
+	return rc;
+
+add_events_err1:
+	rem_events(p_acs, win, tid_info, events, event_list);
+	return rc;
+}
+
+/*
+ * Remove a group of events from the event handling structures.	 The caller
+ * must hold win->event_lock.
+ */
+static void rem_events(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		struct hfidd_tid_info *tid_info, unsigned int events,
+		struct hfidd_win_event **event_list)
+{
+	int			i;
+	unsigned int		test_bit = HFIDD_LOWEST_EVENT;
+	struct hfidd_win_event	*prev_win_event;
+	struct hfidd_win_event	*win_event;
+	unsigned int		temp_events = events;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"rem_events: enter win=0x%x events=0x%x\n",
+		win->index, events);
+
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		if (temp_events & test_bit) {
+			/* Remove pointer from the window or p_acs to events. */
+			prev_win_event = NULL;
+			for (win_event = win->events[i]; win_event != NULL;
+					win_event = win_event->next) {
+				/* Search for this tid in list. */
+				if (win_event->tid_info == tid_info)
+					break;
+				else
+					prev_win_event = win_event;
+			}
+			if (win_event != NULL) {
+				/* Found tid.  Remove it. */
+				if (prev_win_event == NULL)
+					win->events[i] = win_event->next;
+				else
+					prev_win_event->next = win_event->next;
+				win_event->next = *event_list;
+				*event_list = win_event;
+				atomic_dec(&(win->num_events[i]));
+			}
+		}
+		test_bit <<= 1;
+	}
+}
+
+/*
+ * Find a tid_info structure for a given tid and window.  The caller must
+ * hold win->event_lock.
+ */
+static struct hfidd_tid_info *get_tid_info(struct hfidd_acs *p_acs,
+		struct hfidd_window *win, unsigned long long tid,
+		enum hfi_event_hndlr_type type,
+		struct hfidd_tid_info **prev_tid_info,
+		struct hfidd_tid_info **tid_list)
+{
+	struct hfidd_tid_info	*tid_info;
+
+	*prev_tid_info = NULL;
+
+	/* See if it exists already. */
+	for (tid_info = win->tid_list; tid_info != NULL;
+			tid_info = tid_info->next) {
+		if (tid_info->tid == tid)
+			break;
+		*prev_tid_info = tid_info;
+	}
+
+	/* Allocate new structure if necessary. */
+	if (tid_info == NULL) {
+		*prev_tid_info = NULL;
+		if (*tid_list == NULL) {
+			tid_info = NULL;
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"get_tid_info: internal error\n");
+		} else {
+			tid_info = *tid_list; /* Set to NULL so caller knows the
+						 preallocated tid_info
+						 structure was used. */
+			*tid_list = (*tid_list)->next;
+			tid_info->tid = tid;
+			tid_info->type = type;
+			atomic_inc(&win->num_tids);
+			tid_info->next = win->tid_list;
+			win->tid_list = tid_info;
+		}
+	}
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"get_tid_info: exit reg_events=0x%x tid_info=%p\n",
+		tid_info->registered_events,
+		(void *) tid_info);
+
+	return tid_info;
+}
+
+/*
+ * Remove a tid_info structure for a given tid and window.  The caller must
+ * hold win->event_lock.
+ */
+static void rem_tid_info(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		struct hfidd_tid_info *prev_tid_info,
+		struct hfidd_tid_info *tid_info,
+		struct hfidd_tid_info **tid_list)
+{
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"rem_tid_info: remove tid_info for tid 0x%llx\n",
+		tid_info->tid);
+
+	if (prev_tid_info == NULL)
+		win->tid_list = tid_info->next;
+	else
+		prev_tid_info->next = tid_info->next;
+	if (atomic_read(&win->num_tids) > 0)
+		atomic_dec(&win->num_tids);
+	tid_info->next = *tid_list;
+	*tid_list = tid_info; /* Set up to free after releasing lock */
+}
+
+
+/* Register events. */
+int hfidd_events_register(struct hfidd_acs *p_acs, struct hfi_reg_events *arg)
+{
+	int			rc = 0;
+	int			got_lock = 0;
+	struct hfi_reg_events	reg_events;
+	unsigned long long	tid;
+	struct hfidd_tid_info	*prev_tid_info;
+	struct hfidd_tid_info	*tid_info = NULL;
+	struct hfidd_tid_info	*tid_list = NULL;
+	unsigned int		new_events;
+	struct hfidd_window	*win = NULL;
+	struct hfidd_win_event	*event_list = NULL;
+	unsigned long		flags = 0;
+	struct hfidd_q_event	*q_event_list = NULL;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_register: enter p_acs=0x%p\n", (void *)p_acs);
+
+	/* Copy in client info from user */
+	rc = copy_from_user(&reg_events, arg, sizeof(reg_events));
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: copy_from_user failed, "
+			"rc=0x%x\n", rc);
+		return rc;
+	}
+
+	/* Verify inputs */
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_register: enter type=0x%x win=0x%x "
+		"events=0x%x\n", reg_events.type, reg_events.window,
+		reg_events.info.events);
+
+	if ((reg_events.type != WAIT_FOR_EVENTS) &&
+	    (reg_events.type != SIGNAL_EVENTS)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: invalid type - "
+			"0x%x\n", reg_events.type);
+		return -EINVAL;
+	}
+	if ((reg_events.window <  min_hfi_windows(p_acs)) ||
+	    (reg_events.window >= max_hfi_windows(p_acs))) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: invalid win - "
+			"0x%x\n", reg_events.window);
+		return -EINVAL;
+	}
+	if ((reg_events.type == WAIT_FOR_EVENTS) &&
+	    (reg_events.info.events & ~HFIDD_ALL_EVENTS)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: invalid events - "
+			"0x%x\n", reg_events.info.events & ~HFIDD_ALL_EVENTS);
+		return -EINVAL;
+	}
+	if ((reg_events.type == SIGNAL_EVENTS) &&
+	    (reg_events.info.eb.use.kptr == NULL)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: invalid signal buffer\n");
+		return -EINVAL;
+	}
+
+	win = hfi_window(p_acs, reg_events.window);
+	/*
+	 * Preallocate data structures.	 We must do this before the
+	 * lock or it will cause errors.
+	 */
+	tid_list = prealloc_tid_list(p_acs);
+	if (tid_list == NULL)
+		return -ENOMEM;
+	if (reg_events.type == WAIT_FOR_EVENTS)
+		event_list = prealloc_event_list(p_acs, reg_events.info.events);
+	else
+		event_list = prealloc_event_list(p_acs, HFIDD_ALL_EVENTS);
+	if (event_list == NULL) {
+		rc = -ENOMEM;
+		goto events_reg_err1;
+	}
+
+	spin_lock_irqsave(&(win->event_lock), flags);
+	got_lock = 1;
+	if (win->state == WIN_AVAILABLE) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: inv state wi=0x%x st=0x%x\n",
+			win->index, win->state);
+		rc = -EINVAL;
+		goto events_reg_err1;
+	}
+
+	/* Get the tid_info structure for this tid. */
+	tid = (current->pid);
+
+	tid_info = get_tid_info(p_acs, win, tid, reg_events.type,
+			&prev_tid_info, &tid_list);
+	if (tid_info == NULL)
+		goto events_reg_err1;
+	if (tid_info->type != reg_events.type) {
+		/* The user can't change types after first registration */
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: inv typ chg old=0x%x new=0x%x\n",
+			tid_info->type, reg_events.type);
+		rc = -EINVAL;
+		goto events_reg_err2;
+	}
+
+	/* Add new event entries. */
+	if (reg_events.type == WAIT_FOR_EVENTS) {
+		new_events = ~tid_info->registered_events &
+			reg_events.info.events;
+	} else {
+		/*
+		 * If signal version is registered more than once, this will
+		 * end up with no events.  Otherwise, all events
+		 */
+		new_events = (~tid_info->registered_events) &
+			HFIDD_ALL_EVENTS;
+		hfidd_update_eb(tid_info, &reg_events);
+	}
+	rc = add_events(p_acs, win, tid_info, new_events, &event_list);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_register: failed to add events, "
+			"rc=%d\n", rc);
+		goto events_reg_err2;
+	}
+	tid_info->registered_events |= new_events;
+
+events_reg_err2:
+	/* Remove tid info if necessary */
+	if (!(tid_info->registered_events))
+		rem_tid_info(p_acs, win, prev_tid_info, tid_info, &tid_list);
+
+events_reg_err1:
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_register: rc=%d events=0x%x\n",
+		rc, (tid_info == NULL) ? 0 : tid_info->registered_events);
+
+	if (got_lock)
+		spin_unlock_irqrestore(&(win->event_lock), flags);
+	return_tid_list(p_acs, &tid_list, &q_event_list);
+	hfidd_return_q_events(p_acs, &q_event_list);
+	return_event_list(p_acs, &event_list);
+	return rc;
+}
+
+int hfidd_events_unregister(struct hfidd_acs *p_acs, struct hfi_reg_events *arg)
+{
+	int			rc = 0;
+	int			got_lock = 0;
+	struct hfi_reg_events	unreg_events;
+	unsigned long long	tid;
+	struct hfidd_tid_info	*prev_tid_info;
+	struct hfidd_tid_info	*tid_info = NULL;
+	struct hfidd_tid_info	*tid_list = NULL;
+	struct hfidd_window	*win = NULL;
+	struct hfidd_win_event	*event_list = NULL;
+	unsigned long		flags = 0;
+	struct hfidd_q_event	*q_event_list = NULL;
+	unsigned int		events_to_rem;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_unregister: enter p_acs=0x%p\n", (void *)p_acs);
+
+	/* Copy in client info from user */
+	rc = copy_from_user(&unreg_events, arg, sizeof(unreg_events));
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_unregister: COPYIN err rc=0x%x\n", rc);
+		return rc;
+	}
+
+	/* Validate input */
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_unregister: enter win=0x%x events=0x%x\n",
+		unreg_events.window, unreg_events.info.events);
+
+	if ((unreg_events.type != WAIT_FOR_EVENTS) &&
+	    (unreg_events.type != SIGNAL_EVENTS)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_unregister: invalid type - "
+			"0x%x\n", unreg_events.type);
+		return -EINVAL;
+	}
+
+	if ((unreg_events.window < min_hfi_windows(p_acs)) ||
+	    (unreg_events.window >= max_hfi_windows(p_acs))) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_unregister: invalid win - "
+			"0x%x\n", unreg_events.window);
+		return -EINVAL;
+	}
+
+	if ((unreg_events.type == WAIT_FOR_EVENTS) &&
+	    (unreg_events.info.events & ~HFIDD_ALL_EVENTS)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_unregister: invalid events - "
+			"0x%x\n", unreg_events.info.events & ~HFIDD_ALL_EVENTS);
+		return -EINVAL;
+	}
+	win = hfi_window(p_acs, unreg_events.window);
+
+	/*
+	 * Preallocate data structures.	 We must do this before the
+	 * lock or it will cause errors.
+	 */
+	tid_list = prealloc_tid_list(p_acs);
+	if (tid_list == NULL)
+		return -ENOMEM;
+	spin_lock_irqsave(&(win->event_lock), flags);
+	got_lock = 1;
+
+	/* Get the tid_info structure for this tid. */
+	tid = (current->pid);
+
+	tid_info = get_tid_info(p_acs, win, tid, unreg_events.type,
+			&prev_tid_info, &tid_list);
+	if (tid_info == NULL)
+		goto events_unreg_err1;
+	if (tid_info->type != unreg_events.type) {
+		/* The user can't change types after first registration */
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_events_unregister: inv typ chg old=0x%x new=0x%x\n",
+			tid_info->type, unreg_events.type);
+		rc = -EINVAL;
+		goto events_unreg_err2;
+	}
+
+	/* Remove entries. */
+	if (unreg_events.type == WAIT_FOR_EVENTS)
+		events_to_rem = unreg_events.info.events;
+	else
+		events_to_rem = HFIDD_ALL_EVENTS;
+	rem_events(p_acs, win, tid_info, events_to_rem, &event_list);
+	tid_info->registered_events &= ~events_to_rem;
+
+events_unreg_err2:
+	/* Remove tid_info if necessary. */
+	if (!(tid_info->registered_events))
+		rem_tid_info(p_acs, win, prev_tid_info, tid_info, &tid_list);
+
+events_unreg_err1:
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_unregister: rc=%d events=0x%x\n",
+		rc, (tid_info == NULL) ? 0 : tid_info->registered_events);
+
+	if (got_lock)
+		spin_unlock_irqrestore(&(win->event_lock), flags);
+	return_tid_list(p_acs, &tid_list, &q_event_list);
+	hfidd_return_q_events(p_acs, &q_event_list);
+	return_event_list(p_acs, &event_list);
+	return rc;
+}
+
+/* Report that an event has occurred. */
+int hfidd_report_event(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		enum hfi_event_type event)
+{
+	int			rc = 0;
+	struct hfidd_win_event	*win_event_p;
+	struct hfidd_q_event	*q_event_list = NULL;
+	int			num_events;
+	unsigned long		flags;
+	int			allocated = 0;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_report_event: enter event=0x%x p_acs=0x%p\n",
+		event, (void *) p_acs);
+
+	/*
+	 * Prealloc queue event entries.  We must do this because we use a
+	 * lock that keeps us from allocating storage.
+	 */
+	while (!allocated) {
+		num_events = atomic_read(&(win->num_events[event]));
+		q_event_list = hfidd_prealloc_q_events(p_acs, win,
+				num_events);
+		if ((q_event_list == NULL) && num_events) {
+			rc = -ENOMEM;
+			return rc;
+		}
+		spin_lock_irqsave(&(win->event_lock), flags);
+		if (num_events == atomic_read(&(win->num_events[event]))) {
+			allocated = 1;
+		} else {
+			/*
+			 * The number of events we allocated for does not
+			 * match the current number of events.	It must
+			 * have changed between the allocation and the lock.
+			 * We must keep trying until we get a match.
+			 */
+			spin_unlock_irqrestore(&(win->event_lock), flags);
+			hfidd_return_q_events(p_acs, &q_event_list);
+		}
+	}
+
+	/* Mark that the event has occurred and awaken each tid. */
+	for (win_event_p = win->events[event]; win_event_p != NULL;
+			win_event_p = win_event_p->next) {
+		hfidd_post_event(p_acs, win_event_p->tid_info,
+				event, event_mask[event], &q_event_list);
+	}
+	spin_unlock_irqrestore(&(win->event_lock), flags);
+	hfidd_return_q_events(p_acs, &q_event_list);
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_report_event: type=0x%x rc=%d\n", event, rc);
+	return rc;
+}
+
+/* Clean up event handling when a window closes. */
+int hfidd_events_clean(struct hfidd_acs *p_acs, struct hfidd_window *win)
+{
+	int			rc = 0;
+	int			i;
+	struct hfidd_win_event	*win_event_p;
+	struct hfidd_win_event	*win_event_list = NULL;
+	struct hfidd_win_event	*next_win_event_p;
+	struct hfidd_tid_info	*tid_info;
+	struct hfidd_tid_info	*next_tid_info;
+	struct hfidd_tid_info	*tid_list = NULL;
+	int			num_events;
+	unsigned long		flags;
+	int			allocated = 0;
+	struct hfidd_q_event	*q_event_list = NULL;
+	int			loop_count = 0;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_clean: enter p_acs=0x%p\n", (void *)p_acs);
+
+	/*
+	 * Prealloc queue event entries.  We must do this because we use a
+	 * ock that keeps us from allocating storage.
+	 */
+	while (!allocated) {
+		num_events = atomic_read(&win->num_tids);
+		q_event_list = hfidd_prealloc_q_events(p_acs, win,
+				num_events);
+		if ((q_event_list == NULL) && num_events) {
+			rc = -ENOMEM;
+			return rc;
+		}
+		spin_lock_irqsave(&(win->event_lock), flags);
+		if (num_events == atomic_read(&win->num_tids)) {
+			allocated = 1;
+		} else {
+			/*
+			 * The number of events we allocated for does not
+			 * match the current number of tids.  It must
+			 * have changed between the allocation and the lock.
+			 * We must keep trying until we get a match.
+			 */
+			spin_unlock_irqrestore(&(win->event_lock), flags);
+			hfidd_return_q_events(p_acs, &q_event_list);
+		}
+	}
+
+	/* Return all of the win_info structures. */
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		for (win_event_p = win->events[i]; win_event_p != NULL;
+				win_event_p = next_win_event_p) {
+			next_win_event_p = win_event_p->next;
+			win_event_p->next = win_event_list;
+			win_event_list = win_event_p;
+		}
+		win->events[i] = NULL;
+		atomic_set(&win->num_events[i], 0);
+	}
+
+	/* Return tid_info structures. */
+	for (tid_info = win->tid_list; tid_info != NULL;
+			tid_info = next_tid_info) {
+		/* Wake up the waiting task if necessary. */
+		hfidd_events_wakeup(p_acs, tid_info, &q_event_list);
+		next_tid_info = tid_info->next;
+		if (atomic_read(&win->num_tids) > 0)
+			atomic_dec(&win->num_tids);
+		tid_info->next = tid_list;
+		tid_list = tid_info;
+	}
+	win->tid_list = NULL;
+	atomic_set(&win->num_tids, 0);
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		win->funcs[i].function_p.use.kptr = NULL;
+		win->funcs[i].parameter.use.kptr = NULL;
+	}
+
+	/* Wait for all threads to finish. */
+	spin_unlock_irqrestore(&(win->event_lock), flags); /* Must disable or
+							will hang */
+	while ((atomic_read(&win->event_wait_count) > 0) &&
+			(loop_count < HFIDD_EVENT_CLEANUP_LOOP_COUNT)) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HFIDD_EVENT_CLEANUP_DELAY);
+		loop_count++;
+	}
+	atomic_set(&win->event_wait_count, 0);
+
+	return_event_list(p_acs, &win_event_list);
+	return_tid_list(p_acs, &tid_list, &q_event_list);
+	hfidd_return_q_events(p_acs, &q_event_list);
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_events_clean: rc=%d\n", rc);
+	return rc;
+}
+
+int hfidd_callback_register(struct hfidd_acs *p_acs, struct hfi_reg_events *arg)
+{
+	struct hfi_reg_events	reg_events;
+	struct hfidd_window	*win;
+	int			rc;
+
+	/* Copy in client info from user */
+	memcpy(&reg_events, arg, sizeof(reg_events));
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_callback_register: enter type=0x%x win=0x%x "
+		"events=0x%x\n", reg_events.type, reg_events.window,
+		reg_events.info.func.index);
+
+	/* Verify inputs */
+	if (reg_events.type != FUNCTIONS_FOR_EVENTS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_register: invalid type = "
+			"0x%x\n", reg_events.type);
+		return -EINVAL;
+	}
+	if (reg_events.info.func.index == HFIDD_HFI_READY_REG) {
+		rc = hfidd_hfi_ready_registration(p_acs, &reg_events);
+		return rc;
+	}
+
+	if ((reg_events.window <  min_hfi_windows(p_acs)) ||
+	    (reg_events.window >= max_hfi_windows(p_acs))) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_register: invalid win = "
+			"0x%x\n", reg_events.window);
+		return -EINVAL;
+	}
+
+	if (reg_events.info.func.index >= HFIDD_NUM_EVENT_TYPES) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_register: invalid events = "
+			"0x%x\n", reg_events.info.func.index);
+		return -EINVAL;
+	}
+
+	win = hfi_window(p_acs, reg_events.window);
+	spin_lock(&(win->win_lock));
+	if (win->state == WIN_AVAILABLE) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_register: inv state "
+			"wi=0x%x st=0x%x\n",
+			win->index, win->state);
+		spin_unlock(&(win->win_lock));
+		return -EINVAL;
+	}
+	spin_unlock(&(win->win_lock));
+
+	/* fill in function pointer and parameter */
+	win->funcs[reg_events.info.func.index].function_p.use.kptr =
+			reg_events.info.func.function_p.use.kptr;
+	win->funcs[reg_events.info.func.index].parameter.use.kptr  =
+			reg_events.info.func.parameter.use.kptr;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(hfidd_callback_register);
+
+int hfidd_callback_unregister(struct hfidd_acs *p_acs,
+				struct hfi_reg_events *arg)
+{
+	struct hfi_reg_events	reg_events;
+	struct hfidd_window	*win;
+
+	/* Copy in client info from user */
+	memcpy(&reg_events, arg, sizeof(reg_events));
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_callback_unregister: enter type=0x%x win=0x%x "
+		"events=0x%x\n", reg_events.type, reg_events.window,
+		reg_events.info.func.index);
+
+	/* Verify inputs */
+	if (reg_events.type != FUNCTIONS_FOR_EVENTS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_unregister: invalid type = "
+			"0x%x\n", reg_events.type);
+		return -EINVAL;
+	}
+	if (reg_events.info.func.index == HFIDD_HFI_READY_REG) {
+		hfidd_hfi_ready_unregistration(p_acs, &reg_events);
+		return 0;
+	}
+
+	if ((reg_events.window <  min_hfi_windows(p_acs)) ||
+	    (reg_events.window >= max_hfi_windows(p_acs))) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_unregister: invalid win = "
+			"0x%x\n", reg_events.window);
+		return -EINVAL;
+	}
+
+	if (reg_events.info.func.index >= HFIDD_NUM_EVENT_TYPES) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_unregister: invalid events = "
+			"0x%x\n", reg_events.info.func.index);
+		return -EINVAL;
+	}
+
+	win = hfi_window(p_acs, reg_events.window);
+	spin_lock(&(win->win_lock));
+	if ((win->state != WIN_OPENED) &&
+	    (win->state != WIN_ERROR)  &&
+	    (win->state != WIN_HERROR)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_unregister: inv state "
+			"wi=0x%x st=0x%x\n",
+			win->index, win->state);
+		spin_unlock(&(win->win_lock));
+		return -EINVAL;
+	}
+	spin_unlock(&(win->win_lock));
+
+	win->funcs[reg_events.info.func.index].function_p.use.kptr = NULL;
+	win->funcs[reg_events.info.func.index].parameter.use.kptr  = NULL;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(hfidd_callback_unregister);
+
+int hfidd_callback_event(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		enum hfi_event_type event,
+		unsigned int data1,
+		unsigned int *data2_p)
+{
+	if (win->funcs[event].function_p.use.kptr == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_callback_event: NULL function ptr, "
+			"event=0x%x, win_p=0x%llx\n",
+			event, (unsigned long long)win);
+		return -EINVAL;
+	}
+
+	/* calling function */
+	((hfi_event_func_ptr)win->funcs[event].function_p.use.kptr)
+		(win->funcs[event].parameter.use.kptr,
+		data1, data2_p);
+	return 0;
+}
+
+static int hfidd_hfi_ready_registration(struct hfidd_acs *p_acs,
+				struct hfi_reg_events *reg)
+{
+	struct hfidd_hfi_ready_req *req;
+
+	if (p_acs->state == HFI_AVAIL) {
+		/* notify kernel user */
+		return ((hfi_event_func_ptr)reg->info.func.function_p.use.kptr)
+			(reg->info.func.parameter.use.kptr, 0, 0);
+	} else {
+		/* Alloc entry */
+		req = kzalloc(sizeof(*req), GFP_KERNEL);
+		if (req == NULL) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_hfi_ready_registration: kzalloc failed\n");
+			return -ENOMEM;
+		}
+
+		/* Fill the entry for the list */
+		req->func.index = reg->info.func.index;
+		req->func.function_p.use.kptr =
+				reg->info.func.function_p.use.kptr;
+		req->func.parameter.use.kptr =
+				reg->info.func.parameter.use.kptr;
+		list_add(&(req->list), &(p_acs->hfi_ready_reg_list));
+	}
+
+	return 0;
+}
+
+static void hfidd_hfi_ready_unregistration(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *reg)
+{
+	struct hfidd_hfi_ready_req *req;
+	struct list_head        *q;
+	struct list_head        *pos;
+
+	list_for_each_safe(pos, q, &p_acs->hfi_ready_reg_list) {
+		req = list_entry(pos,
+			struct hfidd_hfi_ready_req, list);
+		if ((req->func.function_p.use.kptr ==
+		     reg->info.func.function_p.use.kptr) &&
+		    (req->func.parameter.use.kptr ==
+		     reg->info.func.parameter.use.kptr)) {
+				list_del(pos);
+				kfree(req);
+				break;
+		}
+	}
+
+}
+
+void hfidd_notify_hfi_ready(struct hfidd_acs *p_acs)
+{
+	struct hfidd_hfi_ready_req *req;
+	struct list_head        *q;
+	struct list_head        *pos;
+
+	list_for_each_safe(pos, q, &p_acs->hfi_ready_reg_list) {
+		req = list_entry(pos,
+			struct hfidd_hfi_ready_req, list);
+
+		dev_printk(KERN_INFO, p_acs->hfidd_dev,
+			"hfidd_notify_hfi_ready: Calling Kernel user\n");
+
+		/* Calling IP function */
+		((hfi_event_func_ptr)req->func.function_p.use.kptr)
+			(req->func.parameter.use.kptr, 0, 0);
+		list_del(pos);
+		kfree(req);
+	}
+}
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 0d0ce69..eb6064e 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -179,6 +179,40 @@ static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 				(struct hfi_window_info *) buf);
 		break;
 
+	case HFIDD_REQ_EVENT_REGISTER:
+		if (cmd.req_len != sizeof(struct hfi_reg_events)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_cmd_write: hdr.reqlen 0x%x expected "
+				"0x%lx for cmd req 0x%x\n",
+				cmd.req_len,
+				sizeof(struct hfi_reg_events), cmd.req);
+			return -EINVAL;
+		}
+		if (is_userspace)
+			rc = hfidd_events_register(p_acs,
+					(struct hfi_reg_events *) buf);
+		else
+			rc = hfidd_callback_register(p_acs,
+					(struct hfi_reg_events *) buf);
+		break;
+
+	case HFIDD_REQ_EVENT_UNREGISTER:
+		if (cmd.req_len != sizeof(struct hfi_reg_events)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_cmd_write: hdr.reqlen 0x%x expected "
+				"0x%lx for cmd req 0x%x\n",
+				cmd.req_len,
+				sizeof(struct hfi_reg_events), cmd.req);
+			return -EINVAL;
+		}
+		if (is_userspace)
+			rc = hfidd_events_unregister(p_acs,
+				(struct hfi_reg_events *) buf);
+		else
+			rc = hfidd_callback_unregister(p_acs,
+				(struct hfi_reg_events *) buf);
+		break;
+
 	case HFIDD_REQ_QUERY_DD_INFO:
 		if (cmd.req_len != sizeof(struct hfi_query_dd_info)) {
 			dev_printk(KERN_ERR, p_acs->hfidd_dev,
@@ -348,6 +382,7 @@ int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop)
 {
 	int rc = 0;
 
+	INIT_LIST_HEAD(&(p_acs->hfi_ready_reg_list));
 	rc = hfidd_dds_init(p_acs, &(p_acs->dds));
 	p_acs->dds.num_d_windows = HFI_DYN_WINS_DEFAULT;
 	return rc;
diff --git a/drivers/net/hfi/core/hfidd_intr.c b/drivers/net/hfi/core/hfidd_intr.c
index 253de27..38f35f5 100644
--- a/drivers/net/hfi/core/hfidd_intr.c
+++ b/drivers/net/hfi/core/hfidd_intr.c
@@ -33,15 +33,45 @@
 #include <linux/hfi/hfidd_internal.h>
 #include "hfidd_proto.h"
 
+/* Post window event */
+static int hfidd_post_window_event(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p, enum hfi_event_type event)
+{
+	int rc = 0;
+
+	if (win_p->state == WIN_OPENED) {
+		if (win_p->funcs[event].function_p.use.kptr != NULL) {
+			rc = hfidd_callback_event(p_acs, win_p, event,
+					win_p->index, 0);
+		} else {
+			rc = hfidd_report_event(p_acs, win_p, event);
+		}
+		if (rc) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_post_window_event: failed to "
+				"post event %d win 0x%x rc 0x%x\n",
+				event, win_p->index, rc);
+		}
+	}
+	return rc;
+}
+
 static irqreturn_t send_intr_handler(int irq, void *data)
 {
 	struct hfidd_window *win_p = data;
 	struct hfidd_acs *p_acs;
+	int rc;
 
 	p_acs = hfidd_global.p_acs[win_p->ai];
 	if (p_acs == NULL)
 		return IRQ_HANDLED;
-
+	rc = hfidd_post_window_event(p_acs, win_p, HFIDD_SEND);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"send_intr_handler: failed post send event, "
+			"rc %d for win 0x%llx\n",
+			rc, (unsigned long long) win_p);
+	}
 	return IRQ_HANDLED;
 }
 
@@ -49,11 +79,19 @@ static irqreturn_t recv_intr_handler(int irq, void *data)
 {
 	struct hfidd_window *win_p = data;
 	struct hfidd_acs *p_acs;
+	int		rc;
 
 	p_acs = hfidd_global.p_acs[win_p->ai];
 	if (p_acs == NULL)
 		return IRQ_HANDLED;
 
+	rc = hfidd_post_window_event(p_acs, win_p, HFIDD_RECV);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"recv_intr_handler: failed post recv event, "
+			"rc %d for win 0x%llx\n",
+			rc, (unsigned long long) win_p);
+	}
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index af88f0b..89f9639 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -73,6 +73,20 @@ int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
 int hfidd_start_nmmu(struct hfidd_acs *p_acs);
 int hfidd_start_interface(struct hfidd_acs *p_acs);
 int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
+int hfidd_events_register(struct hfidd_acs *p_acs, struct hfi_reg_events *arg);
+int hfidd_events_unregister(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *arg);
+int hfidd_callback_register(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *arg);
+int hfidd_callback_unregister(struct hfidd_acs *p_acs,
+		struct hfi_reg_events *arg);
+int hfidd_report_event(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		enum hfi_event_type event);
+int hfidd_callback_event(struct hfidd_acs *p_acs, struct hfidd_window *win,
+		enum hfi_event_type event, unsigned int data1,
+		unsigned int *data2_p);
+int hfidd_events_clean(struct hfidd_acs *p_acs, struct hfidd_window *win);
+void hfidd_notify_hfi_ready(struct hfidd_acs *p_acs);
 int hfidd_init_win_interrupt(struct hfidd_acs *p_acs,
 		struct hfidd_window *win_p);
 void hfidd_clear_win_interrupt(struct hfidd_window *win_p);
@@ -104,5 +118,5 @@ long long hfi_hquery_interface(u64 unit_id, u64 subtype, u64 query_p,
 		u64 *state);
 long long hfi_start_interface(u64 unit_id);
 long long hfi_stop_interface(u64 unit_id);
-
+long long hfi_query_window(u64 unit_id, u64 win_id, u64 *state);
 #endif
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index 6864eae..1d7f2b1 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -314,6 +314,8 @@ static inline int hfi_validate_window_id(struct hfidd_acs *p_acs,
 static inline void hfi_restore_window_parm(struct hfidd_acs *p_acs,
 		struct hfidd_window *win_p)
 {
+	int i;
+
 	if (win_p->type != HFIDD_RESERVE_WIN) {
 		win_p->type   = HFIDD_DYNAMIC_WIN;
 		win_p->job_id = 0;
@@ -325,6 +327,12 @@ static inline void hfi_restore_window_parm(struct hfidd_acs *p_acs,
 	}
 	win_p->pid   = 0;
 	win_p->is_ip = 0;
+
+
+	for (i = 0; i < HFIDD_NUM_EVENT_TYPES; i++) {
+		win_p->funcs[i].function_p.use.kptr = NULL;
+		win_p->funcs[i].parameter.use.kptr  = NULL;
+	}
 }
 
 /* Validate window number and type for open window request */
@@ -1074,6 +1082,13 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	win_p->state = WIN_OPENED;
 	spin_unlock(&(win_p->win_lock));
 
+	/*
+	 * Increment so that any waiting threads that wake up realize
+	 * they are dealing with a window that has been reopened
+	 */
+	atomic_inc(&win_p->open_close_count);
+	hfidd_events_clean(p_acs, win_p);
+
 	kfree(local_p);
 	return rc;
 
@@ -1129,6 +1144,12 @@ int hfidd_close_window_internal(struct hfidd_acs *p_acs,
 		goto hfidd_close_window_internal_err0;
 	}
 
+	/* Wake up threads waiting for terminate event. */
+	rc = hfidd_report_event(p_acs, win_p, HFIDD_TERMINATE);
+	if (rc)
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"close_window_internal: report event failed "
+			"rc=0x%x\n", rc);
 	spin_lock(&(win_p->win_lock));
 
 	/* Make sure state is open or error state. */
@@ -1183,6 +1204,9 @@ int hfidd_close_window_internal(struct hfidd_acs *p_acs,
 	hfi_restore_window_parm(p_acs, win_p);
 	spin_unlock(&win_p->win_lock);
 
+	atomic_inc(&win_p->open_close_count);
+	hfidd_events_clean(p_acs, win_p);
+
 	dev_printk(KERN_INFO, p_acs->hfidd_dev,
 		"close_window_internal: type=0x%x state=0x%x JobID=0x%x\n",
 		win_p->type, win_p->state, win_p->job_id);
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index 3b2d032..7f87674 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -97,6 +97,9 @@ struct fifo_info {
 #define HFIDD_RESERVE_WIN	3	/* Must be reserved by job scheduler */
 #define HFIDD_DYNAMIC_WIN	4	/* First come, first served. Window# is
 						returned */
+#define HFIDD_DST_BCST_WIN		0
+#define HFIDD_DST_BCST_ISR		0x3FFF
+
 struct hfi_client_info {
 	struct hfi_req_hdr	hdr;
 
@@ -138,6 +141,67 @@ enum hfi_event_type {
 	HFIDD_NUM_EVENT_TYPES	= 12
 };
 
+#define HFIDD_SEND_EVENT			0x00000100
+#define HFIDD_RECV_EVENT			0x00000200
+#define HFIDD_WIN_ERROR_EVENT			0x00000400
+#define HFIDD_HFI_ERROR_EVENT			0x00000800
+#define HFIDD_TERMINATE_EVENT			0x00001000
+#define HFIDD_RELEASE_WINDOW_EVENT		0x00002000
+#define HFIDD_CAU_ERROR_EVENT			0x00004000
+#define HFIDD_ICS_ERROR_EVENT			0x00008000
+#define HFIDD_HFI_READY_REG_EVENT		0x00010000
+#define HFIDD_ROUTE_CHANGE_EVENT		0x00020000
+#define HFIDD_IP_TRC_LVL_EVENT			0x00040000
+#define HFIDD_POOL_SIZE_EVENT			0x00080000
+#define HFIDD_LOWEST_EVENT			HFIDD_SEND_EVENT
+#define HFIDD_ALL_EVENTS			0x000FFF00
+
+enum hfi_event_hndlr_type {
+	WAIT_FOR_EVENTS		= 1,	/* Wait for events */
+	SIGNAL_EVENTS		= 2,	/* Event notification by signal */
+	FUNCTIONS_FOR_EVENTS	= 3	/* Callback functions */
+};
+
+typedef int (*hfi_event_func_ptr)(void *parm, unsigned int win,
+		unsigned int *ext);
+
+struct hfi_callback_func {	/* Callback funcs for kernel windows */
+	enum hfi_event_type	index;		/* index of callback type */
+	unsigned int		pad;
+	struct hfi_64b		function_p;	/* function ptr */
+	struct hfi_64b		parameter;	/* parameter to pass in */
+};
+
+/*
+ * HFIDD_REQ_EVENT_REGISTER/HFIDD_REQ_EVENT_UNREGISTER: event
+ * registration/unregistration
+ */
+#define HFI_MAX_BUF_EVENTS	8	/* # event buffers for signal version */
+struct hfi_event_buffer	{		/* For reporting events with signals */
+	unsigned int		tag;
+	enum hfi_event_type	current_event;
+};
+
+struct hfi_reg_events {
+	struct hfi_req_hdr		hdr;
+	unsigned int			window;
+	enum hfi_event_hndlr_type	type;
+	union {
+		unsigned int		events;
+		struct hfi_callback_func func;
+		struct hfi_64b eb;	/* Pointer to event buffer in
+					user space (signal only) */
+	} info;
+};
+
+/* HFIDD_REQ_EVENT_WAIT: wait on event */
+struct hfi_wait_events {
+	struct hfi_req_hdr	hdr;
+	unsigned int		window;		/* Window for events */
+	unsigned int		events;		/* events to wait for */
+	unsigned int		out_events;	/* events received */
+};
+
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index f82a626..df67b89 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -72,6 +72,16 @@
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
 
+#define HFIDD_EVENT_CLEANUP_LOOP_COUNT	1000
+#define HFIDD_EVENT_CLEANUP_DELAY	10
+
+/* window event */
+struct hfidd_q_event {
+	struct list_head	list;
+	struct hfidd_q_event	*next;		/* For preallocation list */
+	unsigned int		event;
+};
+
 struct hfidd_dds {
 	unsigned int		version;	/* HFI adapter type */
 	unsigned long long	misc_base_address; /* Misc user base address */
@@ -83,6 +93,33 @@ struct hfidd_dds {
 	unsigned long long	fw_ec_level;	/* Firmware Level */
 };
 
+struct hfidd_tid_info {
+	struct hfidd_tid_info	*next;
+	unsigned long long	tid;		/* Thread id */
+	struct semaphore	tid_sem;
+	unsigned int		registered_events;
+	unsigned int		deferred_events;/* Events that have occurred
+						   but have not yet been
+						   reported */
+	enum hfi_event_hndlr_type type;
+	struct list_head	event_list;	/* List of hfidd_event */
+	wait_queue_head_t	event_wait;	/* Used to wait and post
+						   threads */
+	unsigned int		tag;		/* Used with eb */
+	struct task_struct	*eb_xd;		/* For cross task write */
+	struct hfi_event_buffer	*eb;		/* Pointer to event
+						   buffer location in
+						   user space (for
+						   signal handling) */
+	struct task_struct	*th;		/* task_struct associated with
+						   tid */
+};
+
+struct hfidd_win_event {
+	struct hfidd_win_event	*next;
+	struct hfidd_tid_info	*tid_info;
+};
+
 struct hfidd_fifo {
 	unsigned long long	eaddr;
 	unsigned long long	size;
@@ -92,6 +129,7 @@ struct hfidd_fifo {
 
 struct hfidd_window {
 	spinlock_t		win_lock;	/* lock for window */
+	spinlock_t		event_lock;	/* lock for event handling */
 	int			index;
 	unsigned int		type;		/* dynamic/scheduled */
 	int			state;
@@ -117,10 +155,40 @@ struct hfidd_window {
 							   OPEN_WINDOW hcall */
 	unsigned long long	mmio_regs;		/* logical addr from
 							   OPEN WINDOW hcall */
+	atomic_t		open_close_count;	/*Incremented every time
+						   a window is opened or
+						   closed.  This is used for
+						   event handling to determine
+						   if a close occurred while
+						   waiting. */
+	struct hfi_callback_func funcs[HFIDD_NUM_EVENT_TYPES];	/* Callback
+						   funcs for IP */
+	struct hfidd_win_event	*events[HFIDD_NUM_EVENT_TYPES];	/* Each
+						   array entry points to a
+						   list.  Each list entry
+						   contains a tid that should
+						   be posted when this event
+						   occurs. */
+	atomic_t	num_events[HFIDD_NUM_EVENT_TYPES]; /* Number
+						   of elements in each of the
+						   events lists */
+	struct hfidd_tid_info	*tid_list;	/* List of tids registered for
+						   events on this window */
+	atomic_t		num_tids;	/* Number of tids in
+						   tid_list */
+	atomic_t		event_wait_count;/* Indicates how many
+						    threads are waiting for
+						    events on this window */
 	struct hfidd_vlxmem	*sfifo_x_tab;
 	struct hfidd_vlxmem	*rfifo_x_tab;
 };
 
+struct hfidd_hfi_ready_req {
+	struct list_head		list;
+	struct hfi_callback_func	func;
+};
+
+
 #define HFI_DEVICE_NAME_MAX 8
 /* hfi global */
 struct hfidd_acs {
@@ -131,6 +199,7 @@ struct hfidd_acs {
 	unsigned int		state;
 
 	unsigned int		isr;
+	struct list_head	hfi_ready_reg_list;
 
 	struct hfidd_window	**win;
 	struct device		*hfidd_dev;
diff --git a/include/linux/hfi/hfidd_requests.h b/include/linux/hfi/hfidd_requests.h
index a7a38da..002ae7f 100644
--- a/include/linux/hfi/hfidd_requests.h
+++ b/include/linux/hfi/hfidd_requests.h
@@ -37,4 +37,7 @@
 #define HFIDD_REQ_QUERY_DD_INFO			0x00001004
 #define HFIDD_REQ_CLOSE_WINDOW			0x00000a02
 
+#define HFIDD_REQ_EVENT_REGISTER		0x00000702
+#define HFIDD_REQ_EVENT_UNREGISTER		0x00000703
+
 #endif /* _HFIDD_REQUESTS_H_ */
-- 
1.7.3.5

