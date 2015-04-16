From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 15/16] netconsole: implement netconsole receiver library
Date: Thu, 16 Apr 2015 19:03:52 -0400
Message-ID: <1429225433-11946-16-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements libncrx.a and a simple receiver program ncrx
using the library.  The library makes use of the extended header,
retransmission and ack support to implement reliable netconsole
receiver.  The library is structured as a pure state machine leaving
all IO and timing handling to the library user and should be easy to
fit into any environment.

The reordering and retransmission mechanisms are fairly simple.  Each
receiver instance has a ring buffer where messages are slotted
according to their sequence number.  A hole in sequence numbers
trigger retransmission after the sequence progresses certain number of
slots or certain amount of duration has passed.

See tools/lib/netconsole/ncrx.h for information on usage.

Tested with simulated heavy packet loss (50%).  Messages are
transferred without loss and all the common scenarios including
reboots are handled correctly.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 tools/Makefile                |  16 +-
 tools/lib/netconsole/Makefile |  36 ++
 tools/lib/netconsole/ncrx.c   | 906 ++++++++++++++++++++++++++++++++++++++++++
 tools/lib/netconsole/ncrx.h   | 204 ++++++++++
 tools/ncrx/Makefile           |  14 +
 tools/ncrx/ncrx.c             | 143 +++++++
 6 files changed, 1318 insertions(+), 1 deletion(-)
 create mode 100644 tools/lib/netconsole/Makefile
 create mode 100644 tools/lib/netconsole/ncrx.c
 create mode 100644 tools/lib/netconsole/ncrx.h
 create mode 100644 tools/ncrx/Makefile
 create mode 100644 tools/ncrx/ncrx.c

diff --git a/tools/Makefile b/tools/Makefile
index 9a617ad..9f588f7 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -9,6 +9,7 @@ help:
 	@echo '  firewire   - the userspace part of nosy, an IEEE-1394 traffic sniffer'
 	@echo '  hv         - tools used when in Hyper-V clients'
 	@echo '  lguest     - a minimal 32-bit x86 hypervisor'
+	@echo '  ncrx       - simple reliable netconsole logger'
 	@echo '  perf       - Linux performance measurement and analysis tool'
 	@echo '  selftests  - various kernel selftests'
 	@echo '  turbostat  - Intel CPU idle stats and freq reporting tool'
@@ -50,6 +51,12 @@ liblockdep: FORCE
 libapikfs: FORCE
 	$(call descend,lib/api)
 
+libncrx: FORCE
+	$(call descend,lib/netconsole)
+
+ncrx: libncrx FORCE
+	$(call descend,$@)
+
 perf: libapikfs FORCE
 	$(call descend,$@)
 
@@ -100,6 +107,12 @@ liblockdep_clean:
 libapikfs_clean:
 	$(call descend,lib/api,clean)
 
+libncrx_clean:
+	$(call descend,lib/netconsole,clean)
+
+ncrx_clean: libncrx_clean
+	$(call descend,$(@:_clean=),clean)
+
 perf_clean: libapikfs_clean
 	$(call descend,$(@:_clean=),clean)
 
@@ -114,6 +127,7 @@ tmon_clean:
 
 clean: acpi_clean cgroup_clean cpupower_clean hv_clean firewire_clean lguest_clean \
 		perf_clean selftests_clean turbostat_clean usb_clean virtio_clean \
-		vm_clean net_clean x86_energy_perf_policy_clean tmon_clean
+		vm_clean net_clean x86_energy_perf_policy_clean tmon_clean \
+		ncrx_clean
 
 .PHONY: FORCE
diff --git a/tools/lib/netconsole/Makefile b/tools/lib/netconsole/Makefile
new file mode 100644
index 0000000..6bc7997
--- /dev/null
+++ b/tools/lib/netconsole/Makefile
@@ -0,0 +1,36 @@
+include ../../scripts/Makefile.include
+
+CC = $(CROSS_COMPILE)gcc
+AR = $(CROSS_COMPILE)ar
+
+# guard against environment variables
+LIB_H=
+LIB_OBJS=
+
+LIB_H += ncrx.h
+LIB_OBJS += $(OUTPUT)ncrx.o
+
+LIBFILE = libncrx.a
+
+CFLAGS = -g -Wall -O2 $(EXTRA_WARNINGS) $(EXTRA_CFLAGS) -fPIC
+ALL_CFLAGS = $(CFLAGS) $(BASIC_CFLAGS)
+ALL_LDFLAGS = $(LDFLAGS)
+
+RM = rm -f
+
+$(LIBFILE): $(LIB_OBJS)
+	$(QUIET_AR)$(RM) $@ && $(AR) rcs $(OUTPUT)$@ $(LIB_OBJS)
+
+$(LIB_OBJS): $(LIB_H)
+
+$(OUTPUT)%.o: %.c
+	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) $<
+$(OUTPUT)%.s: %.c
+	$(QUIET_CC)$(CC) -S $(ALL_CFLAGS) $<
+$(OUTPUT)%.o: %.S
+	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) $<
+
+clean:
+	$(call QUIET_CLEAN, libncrx) $(RM) $(LIB_OBJS) $(LIBFILE)
+
+.PHONY: clean
diff --git a/tools/lib/netconsole/ncrx.c b/tools/lib/netconsole/ncrx.c
new file mode 100644
index 0000000..8a87e6b
--- /dev/null
+++ b/tools/lib/netconsole/ncrx.c
@@ -0,0 +1,906 @@
+/*
+ * ncrx - extended netconsole receiver library
+ *
+ * Copyright (C) 2015		Facebook, Inc
+ * Copyright (C) 2015		Tejun Heo <tj@kernel.org>
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <string.h>
+#include <time.h>
+#include <errno.h>
+#include <assert.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <netinet/udp.h>
+
+#include "ncrx.h"
+
+/* max payload len for responses, this is what netconsole uses on tx side */
+#define NCRX_RESP_MAX		1000
+/* oos history is tracked with a uint32_t */
+#define NCRX_OOS_MAX		32
+
+struct ncrx_msg_list {
+	struct ncrx_list	head;
+	int			nr;		/* number of msgs on the list */
+};
+
+struct ncrx_slot {
+	struct ncrx_msg		*msg;
+	uint64_t		timestamp;	/* last activity on this slot */
+	struct ncrx_list	hole_node;	/* anchored @ ncrx->hole_list */
+};
+
+struct ncrx {
+	struct ncrx_param	p;
+
+	uint64_t		now;		/* latest time in msecs */
+
+	int			head;		/* next slot to use */
+	int			tail;		/* last slot in use */
+	uint64_t		head_seq;	/* next expected seq, unset=0 */
+	struct ncrx_slot	*slots;		/* msg slots */
+	struct ncrx_list	hole_list;	/* missing or !complete slots */
+
+	uint32_t		oos_history;	/* bit history of oos msgs */
+	struct ncrx_msg_list	oos_list;	/* buffered oos msgs */
+
+	struct ncrx_msg_list	frag_list;	/* buffered printk frag msgs */
+
+	struct ncrx_msg_list	retired_list;	/* msgs to be fetched by user */
+
+	uint64_t		acked_seq;	/* last seq acked, unset=max */
+	uint64_t		acked_at;	/* and when */
+
+	/* response buffer for ncrx_response() */
+	char			resp_buf[NCRX_RESP_MAX + 1];
+	int			resp_len;
+};
+
+static const struct ncrx_param ncrx_dfl_param = {
+	.nr_slots		= NCRX_DFL_NR_SLOTS,
+
+	.ack_intv		= NCRX_DFL_ACK_INTV,
+	.retx_intv		= NCRX_DFL_RETX_INTV,
+	.retx_stride		= NCRX_DFL_RETX_STRIDE,
+	.msg_timeout		= NCRX_DFL_MSG_TIMEOUT,
+
+	.oos_thr		= NCRX_DFL_OOS_THR,
+	.oos_intv		= NCRX_DFL_OOS_INTV,
+	.oos_timeout		= NCRX_DFL_OOS_TIMEOUT,
+
+	.frag_max		= NCRX_DFL_FRAG_MAX,
+	.frag_timeout		= NCRX_DFL_FRAG_TIMEOUT,
+};
+
+/* utilities mostly stolen from kernel */
+#define min(x, y) ({							\
+	typeof(x) _min1 = (x);						\
+	typeof(y) _min2 = (y);						\
+	(void) (&_min1 == &_min2);					\
+	_min1 < _min2 ? _min1 : _min2; })
+
+#define max(x, y) ({							\
+	typeof(x) _max1 = (x);						\
+	typeof(y) _max2 = (y);						\
+	(void) (&_max1 == &_max2);					\
+	_max1 > _max2 ? _max1 : _max2; })
+
+#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
+
+#define container_of(ptr, type, member) ({				\
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);		\
+	(type *)( (char *)__mptr - offsetof(type,member) );})
+
+/* ncrx_msg from its ->node */
+#define node_to_msg(ptr)	container_of(ptr, struct ncrx_msg, node)
+
+/* iterate msg_list */
+#define msg_list_for_each(pos, n, list)					\
+	for (pos = node_to_msg((list)->head.next),			\
+		     n = node_to_msg(pos->node.next);			\
+	     &pos->node != &(list)->head;				\
+	     pos = n, n = node_to_msg(pos->node.next))
+
+/* ncrx_slot from its ->hole_node */
+#define hole_to_slot(ptr)						\
+	container_of(ptr, struct ncrx_slot, hole_node)
+
+/* iterate hole_list */
+#define hole_list_for_each(pos, n, list)				\
+	for (pos = hole_to_slot((list)->next),				\
+		     n = hole_to_slot(pos->hole_node.next);		\
+	     &pos->hole_node != (list);					\
+	     pos = n, n = hole_to_slot(pos->hole_node.next))
+
+static unsigned int hweight32(uint32_t w)
+{
+	w -= (w >> 1) & 0x55555555;
+	w =  (w & 0x33333333) + ((w >> 2) & 0x33333333);
+	w =  (w + (w >> 4)) & 0x0f0f0f0f;
+	return (w * 0x01010101) >> 24;
+}
+
+static void init_list(struct ncrx_list *head)
+{
+	head->next = head;
+	head->prev = head;
+}
+
+static int list_empty(struct ncrx_list *head)
+{
+	return head->next == head;
+}
+
+static void list_del(struct ncrx_list *head)
+{
+	struct ncrx_list *prev = head->prev;
+	struct ncrx_list *next = head->next;
+
+	prev->next = next;
+	next->prev = prev;
+	init_list(head);
+}
+
+static void list_append(struct ncrx_list *node, struct ncrx_list *list)
+{
+	struct ncrx_list *prev = list->prev;
+
+	assert(node->next == node && node->prev == node);
+
+	node->next = list;
+	node->prev = prev;
+	prev->next = node;
+	list->prev = node;
+}
+
+static void msg_list_del(struct ncrx_msg *msg, struct ncrx_msg_list *list)
+{
+	list_del(&msg->node);
+	list->nr--;
+
+	if (!list->nr)
+		assert(list->head.next == &list->head &&
+		       list->head.prev == &list->head);
+}
+
+static void msg_list_append(struct ncrx_msg *msg, struct ncrx_msg_list *list)
+{
+	list_append(&msg->node, &list->head);
+	list->nr++;
+}
+
+static struct ncrx_msg *msg_list_peek(struct ncrx_msg_list *list)
+{
+	if (list_empty(&list->head))
+		return NULL;
+	return node_to_msg(list->head.next);
+}
+
+static struct ncrx_msg *msg_list_pop(struct ncrx_msg_list *list)
+{
+	struct ncrx_msg *msg;
+
+	msg = msg_list_peek(list);
+	if (msg)
+		msg_list_del(msg, list);
+	return msg;
+}
+
+/*
+ * Parse @payload into @msg.  The data is not copied into @msg's buffer.
+ * @msg->text and ->dict are updated to point into @payload instead.
+ */
+static int parse_packet(const char *payload, struct ncrx_msg *msg)
+{
+	char buf[1024];
+	char *p, *tok;
+	int idx;
+
+	memset(msg, 0, sizeof(*msg));
+
+	p = strchr(payload, ';');
+	if (!p || p - payload >= sizeof(buf))
+		goto einval;
+	memcpy(buf, payload, p - payload);
+	buf[p - payload] = '\0';
+
+	msg->text = p + 1;
+	msg->text_len = strlen(msg->text);
+	if (msg->text_len > NCRX_LINE_MAX)
+		msg->text_len = NCRX_LINE_MAX;
+
+	/* <level>,<sequnum>,<timestamp>,<contflag>[,KEY=VAL]* */
+	idx = 0;
+	p = buf;
+	while ((tok = strsep(&p, ","))) {
+		char *endp, *key, *val;
+		unsigned long long v;
+
+		switch (idx++) {
+		case 0:
+			v = strtoul(tok, &endp, 0);
+			if (*endp != '\0' || v > UINT8_MAX)
+				goto einval;
+			msg->facility = v >> 3;
+			msg->level = v & ((1 << 3) - 1);
+			continue;
+		case 1:
+			v = strtoull(tok, &endp, 0);
+			if (*endp != '\0') {
+				if (tok[0] == '-' && tok[1] == '\0')
+					msg->frag = 1;
+				else
+					goto einval;
+			} else {
+				msg->seq = v;
+			}
+			continue;
+		case 2:
+			v = strtoull(tok, &endp, 0);
+			if (*endp != '\0')
+				goto einval;
+			msg->ts_usec = v;
+			continue;
+		case 3:
+			if (tok[0] == 'c')
+				msg->cont_start = 1;
+			else if (tok[0] == '+')
+				msg->cont = 1;
+			continue;
+		}
+
+		val = tok;
+		key = strsep(&val, "=");
+		if (!val)
+			continue;
+		if (!strcmp(key, "ncfrag")) {
+			unsigned nf_off, nf_idx, nf_nr;
+
+			if (sscanf(val, "%u@%u/%u",
+				   &nf_off, &nf_idx, &nf_nr) != 3)
+				goto einval;
+			if (nf_off + msg->text_len >= NCRX_LINE_MAX ||
+			    nf_idx >= nf_nr || nf_nr > 32)
+				goto einval;
+
+			msg->ncfrag_bitmap = UINT32_MAX << nf_nr;
+			msg->ncfrag_bitmap |= 1 << nf_idx;
+
+			msg->ncfrag_off = nf_off;
+		} else if (!strcmp(key, "fragid")) {
+			v = strtoull(val, &endp, 0);
+			if (*endp != '\0')
+				goto einval;
+
+			msg->has_fragid = 1;
+			msg->fragid = v;
+		} else if (!strcmp(key, "emg")) {
+			v = strtoul(val, &endp, 0);
+			if (*endp != '\0')
+				goto einval;
+			msg->emg = v;
+		}
+	}
+	return 0;
+einval:
+	errno = EINVAL;
+	return -1;
+}
+
+/* how far @idx is behind @ncrx->head */
+static int slot_dist(int idx, struct ncrx *ncrx)
+{
+	int dist = ncrx->head - idx;
+	return dist >= 0 ? dist : dist + ncrx->p.nr_slots;
+}
+
+/* number of occupied slots */
+static int nr_queued(struct ncrx *ncrx)
+{
+	return slot_dist(ncrx->tail, ncrx);
+}
+
+/* seq of the last queued message */
+static uint64_t tail_seq(struct ncrx *ncrx)
+{
+	return ncrx->head_seq - nr_queued(ncrx);
+}
+
+/* slot index of a message with sequence number @ncrx->head_seq + @delta */
+static int seq_delta_idx(struct ncrx *ncrx, int delta)
+{
+	int idx = ncrx->head + delta;
+
+	if (idx < 0)
+		return idx + ncrx->p.nr_slots;
+	else if (idx >= ncrx->p.nr_slots)
+		return idx - ncrx->p.nr_slots;
+	else
+		return idx;
+}
+
+/* is @slot completely empty? */
+static int slot_is_free(struct ncrx_slot *slot)
+{
+	return !slot->msg && list_empty(&slot->hole_node);
+}
+
+/* @slot may have just been completed, if so, remove it from hole_list */
+static void slot_maybe_complete(struct ncrx_slot *slot)
+{
+	struct ncrx_msg *msg = slot->msg;
+
+	if (!msg || msg->ncfrag_bitmap || list_empty(&slot->hole_node))
+		return;
+
+	list_del(&slot->hole_node);
+
+	msg->dict = strchr(msg->text, '\n');
+	if (msg->dict) {
+		int len = msg->text_len;
+		msg->text_len = msg->dict - msg->text;
+		msg->text[msg->text_len] = '\0';
+		msg->dict_len = len - msg->text_len - 1;
+		msg->dict++;
+	}
+}
+
+/* retire the last queued slot whether complete or not */
+static void retire_tail(struct ncrx *ncrx)
+{
+	int ntail = (ncrx->tail + 1) % ncrx->p.nr_slots;
+	struct ncrx_slot *slot = &ncrx->slots[ncrx->tail];
+	struct ncrx_slot *nslot = &ncrx->slots[ntail];
+
+	if (slot->msg) {
+		msg_list_append(slot->msg, &ncrx->retired_list);
+		slot->msg = NULL;
+	}
+
+	list_del(&slot->hole_node);	/* free slot is never a hole */
+	ncrx->tail = ntail;
+	/*
+	 * Activities of past msgs are considered activities for newer ones
+	 * too.  This prevents oos interval verdicts from flipping as
+	 * sequence progresses.
+	 */
+	nslot->timestamp = max(slot->timestamp, nslot->timestamp);
+}
+
+/* make room for message with seq ncrx->head_seq + @delta */
+static void make_room(struct ncrx *ncrx, int delta)
+{
+	int i;
+
+	/* head_seq is for the next msg, need to advance for 0 @delta too */
+	for (i = 0; i <= delta; i++) {
+		struct ncrx_slot *slot;
+		int max_busy = ncrx->p.nr_slots - ncrx->p.retx_intv;
+
+		/* a new slot is considered hole until it gets completed */
+		slot = &ncrx->slots[ncrx->head];
+		assert(slot_is_free(slot));
+		list_append(&slot->hole_node, &ncrx->hole_list);
+		slot->timestamp = ncrx->now;
+
+		/*
+		 * Wind the ring buffer and push out if overflowed.  Always
+		 * keep at least one stride empty so that retransmissions
+		 * of expired slots don't count as oos.
+		 */
+		ncrx->head_seq++;
+		ncrx->head = (ncrx->head + 1) % ncrx->p.nr_slots;
+		slot = &ncrx->slots[ncrx->head];
+		if (slot_dist(ncrx->tail, ncrx) > max_busy)
+			retire_tail(ncrx);
+	}
+}
+
+/*
+ * Get slot for @tmsg.  On success, returns pointer to the slot which may
+ * be free or occupied with partial or complete message.  Returns NULL with
+ * errno set to ERANGE if oos, NULL / ENOENT if already retired.
+ */
+static struct ncrx_slot *get_seq_slot(struct ncrx_msg *tmsg, struct ncrx *ncrx)
+{
+	struct ncrx_slot *slot;
+	int64_t delta;
+	int idx;
+
+	/* new seq stream */
+	if (!ncrx->head_seq) {
+		ncrx->head_seq = tmsg->seq;
+		ncrx->acked_seq = UINT64_MAX;
+		tmsg->seq_reset = 1;
+	}
+
+	delta = tmsg->seq - ncrx->head_seq;
+
+	/*
+	 * Consider oos if outside reorder window or if the slot is
+	 * complete and the last activity on it was more than oos_intv ago.
+	 * Emergency messages are never considered oos as they don't follow
+	 * the usual transmission pattern and may repeat indefinitely.
+	 */
+	if (-delta > ncrx->p.nr_slots || delta > ncrx->p.nr_slots) {
+		errno = ERANGE;
+		return NULL;
+	}
+
+	idx = seq_delta_idx(ncrx, delta);
+	slot = &ncrx->slots[idx];
+
+	if (-delta > nr_queued(ncrx)) {
+		int is_free = slot_is_free(slot);
+
+		if (!tmsg->emg &&
+		    (!is_free ||
+		     slot->timestamp + ncrx->p.oos_intv < ncrx->now)) {
+			errno = ERANGE;
+			return NULL;
+		}
+
+		if (is_free)
+			slot->timestamp = ncrx->now;
+		errno = ENOENT;
+		return NULL;
+	}
+
+	make_room(ncrx, delta);
+	slot->timestamp = ncrx->now;
+
+	return slot;
+}
+
+/* make @src's copy, if @src is a fragment, allocate full size as it may grow */
+static struct ncrx_msg *copy_msg(struct ncrx_msg *src)
+{
+	struct ncrx_msg *dst;
+	int data_len;
+
+	assert(!src->dict && !src->dict_len);
+
+	if (src->frag || src->ncfrag_bitmap)
+		data_len = NCRX_RESP_MAX;
+	else
+		data_len = src->text_len;
+
+	dst = malloc(sizeof(*dst) + data_len + 1);
+	if (!dst)
+		return NULL;
+
+	*dst = *src;
+	init_list(&dst->node);
+
+	dst->text = dst->buf;
+	memcpy(dst->text, src->text, src->text_len);
+	dst->text[dst->text_len] = '\0';
+
+	return dst;
+}
+
+/*
+ * @tmsg is a newly parsed msg which has printk fragment information.  If
+ * it's a fragment, queue it on @ncrx->frag_list until it either gets shot
+ * down by the matching complete msg, times out or is pushed out by other
+ * frag msgs.  If a complete message, shoot down the matching frags.
+ */
+static int queue_frag_msg(struct ncrx_msg *tmsg, struct ncrx *ncrx)
+{
+	struct ncrx_msg *match = NULL;
+	struct ncrx_msg *msg, *nmsg;
+
+	if (!tmsg->has_fragid) {
+		errno = EINVAL;
+		return -1;
+	}
+
+	/* look for a match */
+	msg_list_for_each(msg, nmsg, &ncrx->frag_list) {
+		if (msg->fragid == tmsg->fragid) {
+			match = msg;
+			break;
+		}
+	}
+
+	/* @tmsg is a complete one, shoot down the match */
+	if (!tmsg->frag) {
+		if (match) {
+			msg_list_del(msg, &ncrx->frag_list);
+			free(msg);
+		}
+		return 0;
+	}
+
+	/* @tmsg is a frag and there's a match, append new to the old */
+	if (match) {
+		int len = msg->text_len;
+		int left = NCRX_LINE_MAX - len;
+		int new_len = tmsg->text_len;
+
+		if (new_len > left)
+			new_len = left;
+
+		memcpy(msg->text + len, tmsg->text, new_len);
+		msg->text_len += new_len;
+		msg->text[msg->text_len] = '\0';
+		return 0;
+	}
+
+	/* @tmsg is a new frag, allocate, queue and overflow */
+	msg = copy_msg(tmsg);
+	if (!msg)
+		return -1;
+
+	msg_list_append(msg, &ncrx->frag_list);
+
+	if (ncrx->frag_list.nr > ncrx->p.frag_max) {
+		msg = msg_list_pop(&ncrx->frag_list);
+		msg_list_append(msg, &ncrx->retired_list);
+	}
+
+	return 0;
+}
+
+/*
+ * @tmsg is a newly parsed msg which is out-of-sequence.  Queue it on
+ * @ncrx->oos_list until the message times out, gets pushed out by other
+ * oos messages or the sequence stream gets reset.
+ */
+static int queue_oos_msg(struct ncrx_msg *tmsg, struct ncrx *ncrx)
+{
+	struct ncrx_slot *slot;
+	struct ncrx_msg *msg, *nmsg, *first;
+
+	msg = copy_msg(tmsg);
+	if (!msg)
+		return -1;
+
+	msg_list_append(msg, &ncrx->oos_list);
+
+	/*
+	 * Shifted left automatically on each new msg.  Set oos and see if
+	 * there have been too many oos among the last 32 messages.
+	 */
+	ncrx->oos_history |= 1;
+	if (hweight32(ncrx->oos_history) < ncrx->p.oos_thr) {
+		/* nope, handle oos overflow and handle */
+		if (ncrx->oos_list.nr > NCRX_OOS_MAX) {
+			msg = msg_list_pop(&ncrx->oos_list);
+			msg->oos = 1;
+			msg_list_append(msg, &ncrx->retired_list);
+		}
+		return 0;
+	}
+
+	/*
+	 * The current sequence stream seems no good.  Let's reset by
+	 * retiring all pending, picking the oos msg with the lowest seq,
+	 * queueing it to reset the seq and then queueing all other oos
+	 * msgs.  If a msg is still oos after reset, just retire it.
+	 */
+	while (ncrx->tail != ncrx->head) {
+		slot = &ncrx->slots[ncrx->tail];
+		retire_tail(ncrx);
+	}
+
+	ncrx->head_seq = 0;
+	ncrx->acked_seq = UINT64_MAX;
+
+	first = node_to_msg(ncrx->oos_list.head.next);
+	msg_list_for_each(msg, nmsg, &ncrx->oos_list)
+		first = msg->seq < first->seq ? msg : first;
+
+	msg_list_del(first, &ncrx->oos_list);
+	slot = get_seq_slot(first, ncrx);
+	slot->msg = first;
+	slot_maybe_complete(slot);
+
+	while ((msg = msg_list_pop(&ncrx->oos_list))) {
+		slot = get_seq_slot(msg, ncrx);
+		if (slot) {
+			slot->msg = msg;
+			slot_maybe_complete(slot);
+		} else {
+			msg->oos = 1;
+			msg_list_append(msg, &ncrx->retired_list);
+		}
+	}
+
+	return 0;
+}
+
+/* @payload has just been received, parse and queue it */
+static int ncrx_queue_payload(const char *payload, struct ncrx *ncrx)
+{
+	struct ncrx_msg tmsg;
+	struct ncrx_slot *slot;
+	int new_msg = 0;
+
+	if (parse_packet(payload, &tmsg))
+		return -1;
+
+	tmsg.rx_at = ncrx->now;
+	ncrx->oos_history <<= 1;
+
+	/* ack immediately if logging source is doing emergency transmissions */
+	if (tmsg.emg) {
+		ncrx->acked_seq = UINT64_MAX;
+		ncrx->acked_at = 0;
+	}
+
+	/* handle printk frags, note that this is different from ncfrags */
+	if (tmsg.has_fragid || tmsg.frag) {
+		if (queue_frag_msg(&tmsg, ncrx))
+			return -1;
+		/* if @tmsg is frag, there's nothing more to do */
+		if (tmsg.frag)
+			return 0;
+	}
+
+	/* get the matching slot and allocate a new message if empty */
+	slot = get_seq_slot(&tmsg, ncrx);
+	if (slot && !slot->msg) {
+		slot->msg = copy_msg(&tmsg);
+		new_msg = 1;
+	}
+	if (!slot || !slot->msg) {
+		if (errno == ENOENT)
+			return 0;
+		if (errno == ERANGE)
+			return queue_oos_msg(&tmsg, ncrx);
+		return -1;
+	}
+
+	if (!new_msg && slot->msg->ncfrag_bitmap) {
+		struct ncrx_msg *msg = slot->msg;
+		int off = tmsg.ncfrag_off;
+
+		/* ncfrags, assemble in the slot */
+		msg->ncfrag_bitmap |= tmsg.ncfrag_bitmap;
+		memcpy(msg->text + off, tmsg.text, tmsg.text_len);
+		if (msg->text_len < off + tmsg.text_len)
+			msg->text_len = off + tmsg.text_len;
+		msg->text[msg->text_len] = '\0';
+
+		if (msg->ncfrag_bitmap == UINT32_MAX)
+			msg->ncfrag_bitmap = 0;
+	}
+
+	slot_maybe_complete(slot);
+
+	return 0;
+}
+
+/*
+ * Build ncrx_response() output.  Ack for the last retired msg is always
+ * added.  If @slot is non-NULL, re-transmission for it is also added.
+ */
+static void ncrx_build_resp(struct ncrx_slot *slot, struct ncrx *ncrx)
+{
+	/* no msg received? */
+	if (!ncrx->head_seq)
+		return;
+
+	/* "nca<ack-seq>" */
+	if (!ncrx->resp_len) {
+		ncrx->acked_seq = tail_seq(ncrx) - 1;
+		ncrx->acked_at = ncrx->now;
+
+		ncrx->resp_len = snprintf(ncrx->resp_buf, NCRX_RESP_MAX,
+					  "nca%"PRIu64, ncrx->acked_seq);
+	}
+
+	/* " <missing-seq>..." truncated to NCRX_RESP_MAX */
+	if (slot) {
+		int idx = slot - ncrx->slots;
+		int len;
+
+		len = snprintf(ncrx->resp_buf + ncrx->resp_len,
+			       NCRX_RESP_MAX - ncrx->resp_len, " %"PRIu64,
+			       ncrx->head_seq - slot_dist(idx, ncrx));
+		if (ncrx->resp_len + len <= NCRX_RESP_MAX) {
+			ncrx->resp_len += len;
+			ncrx->resp_buf[ncrx->resp_len] = '\0';
+		}
+	}
+}
+
+int ncrx_process(const char *payload, uint64_t now, struct ncrx *ncrx)
+{
+	struct ncrx_slot *slot, *tmp_slot;
+	struct ncrx_msg *msg;
+	uint64_t old_head_seq = ncrx->head_seq;
+	int dist_retx, ret = 0;
+
+	if (now < ncrx->now)
+		fprintf(stderr, "ncrx: time regressed %"PRIu64"->%"PRIu64"\n",
+			ncrx->now, now);
+
+	ncrx->now = now;
+	ncrx->resp_len = 0;
+
+	/*
+	 * If fully acked, keep last ack timestamp current so that new
+	 * messages arriving doesn't trigger ack timeout immediately.
+	 */
+	if (ncrx->acked_seq == tail_seq(ncrx) - 1)
+		ncrx->acked_at = now;
+
+	/* parse and queue @payload */
+	if (payload)
+		ret = ncrx_queue_payload(payload, ncrx);
+
+	/* retire complete & timed-out msgs from tail */
+	while (ncrx->tail != ncrx->head) {
+		struct ncrx_slot *slot = &ncrx->slots[ncrx->tail];
+
+		if ((!slot->msg || !list_empty(&slot->hole_node)) &&
+		    slot->timestamp + ncrx->p.msg_timeout >= now)
+			break;
+		retire_tail(ncrx);
+	}
+
+	/* retire timed-out oos msgs */
+	while ((msg = msg_list_peek(&ncrx->oos_list))) {
+		if (msg->rx_at + ncrx->p.oos_timeout >= now)
+			break;
+		msg->oos = 1;
+		msg_list_del(msg, &ncrx->oos_list);
+		msg_list_append(msg, &ncrx->retired_list);
+	}
+
+	/* retire timed-out frag msgs */
+	while ((msg = msg_list_peek(&ncrx->frag_list))) {
+		if (msg->rx_at + ncrx->p.frag_timeout >= now)
+			break;
+		msg_list_del(msg, &ncrx->frag_list);
+		msg_list_append(msg, &ncrx->retired_list);
+	}
+
+	/* ack pending and timeout expired? */
+	if (ncrx->acked_seq != tail_seq(ncrx) - 1 &&
+	    ncrx->acked_at + ncrx->p.ack_intv < now)
+		ncrx_build_resp(NULL, ncrx);
+
+	/* head passed one or more re-transmission boundaries? */
+	dist_retx = old_head_seq / ncrx->p.retx_stride !=
+		ncrx->head_seq / ncrx->p.retx_stride;
+
+	hole_list_for_each(slot, tmp_slot, &ncrx->hole_list) {
+		int retx = 0;
+
+		/*
+		 * If so, request re-tx of holes further away than stride.
+		 * This ensures that a missing seq is requested at least
+		 * certain number of times regardless of incoming rate.
+		 */
+		if (dist_retx &&
+		    slot_dist(slot - ncrx->slots, ncrx) > ncrx->p.retx_stride)
+			retx = 1;
+
+		/* request re-tx every retx_intv */
+		if (now - slot->timestamp >= ncrx->p.retx_intv) {
+			slot->timestamp = now;
+			retx = 1;
+		}
+
+		if (retx)
+			ncrx_build_resp(slot, ncrx);
+	}
+
+	return ret;
+}
+
+const char *ncrx_response(struct ncrx *ncrx, int *lenp)
+{
+	if (lenp)
+		*lenp = ncrx->resp_len;
+	if (ncrx->resp_len)
+		return ncrx->resp_buf;
+	return NULL;
+}
+
+struct ncrx_msg *ncrx_next_msg(struct ncrx *ncrx)
+{
+	return msg_list_pop(&ncrx->retired_list);
+}
+
+uint64_t ncrx_invoke_process_at(struct ncrx *ncrx)
+{
+	uint64_t when = UINT64_MAX;
+	struct ncrx_msg *msg;
+
+	/* ack pending? */
+	if (ncrx->head_seq && ncrx->acked_seq != tail_seq(ncrx) - 1)
+		when = min(when, ncrx->acked_at + ncrx->p.ack_intv);
+
+	/*
+	 * Holes to request for retransmission?  msg_timeout is the same
+	 * condition but way longer.  Checking on retx_intv is enough.
+	 */
+	if (!list_empty(&ncrx->hole_list))
+		when = min(when, ncrx->now + ncrx->p.retx_intv);
+
+	/* oos timeout */
+	if ((msg = msg_list_peek(&ncrx->oos_list)))
+		when = min(when, msg->rx_at + ncrx->p.oos_timeout);
+
+	/* frag timeout */
+	if ((msg = msg_list_peek(&ncrx->frag_list)))
+		when = min(when, msg->rx_at + ncrx->p.frag_timeout);
+
+	/* min 10ms intv to avoid busy loop in case something goes bonkers */
+	return max(when, ncrx->now + 10);
+}
+
+struct ncrx *ncrx_create(const struct ncrx_param *param)
+{
+	const struct ncrx_param *dfl = &ncrx_dfl_param;
+	struct ncrx_param *p;
+	struct ncrx *ncrx;
+	int i;
+
+	ncrx = calloc(1, sizeof(*ncrx));
+	if (!ncrx)
+		return NULL;
+
+	p = &ncrx->p;
+	if (param) {
+		p->nr_slots	= param->nr_slots	?: dfl->nr_slots;
+
+		p->ack_intv	= param->ack_intv	?: dfl->ack_intv;
+		p->retx_intv	= param->retx_intv	?: dfl->retx_intv;
+		p->retx_stride	= param->retx_stride	?: dfl->retx_stride;
+		p->msg_timeout	= param->msg_timeout	?: dfl->msg_timeout;
+
+		p->oos_thr	= param->oos_thr	?: dfl->oos_thr;
+		p->oos_intv	= param->oos_intv	?: dfl->oos_intv;
+		p->oos_timeout	= param->oos_timeout	?: dfl->oos_timeout;
+
+		p->frag_max	= param->frag_max	?: dfl->frag_max;
+		p->frag_timeout	= param->frag_timeout	?: dfl->frag_timeout;
+	} else {
+		*p = *dfl;
+	}
+
+	ncrx->acked_seq = UINT64_MAX;
+	init_list(&ncrx->hole_list);
+	init_list(&ncrx->oos_list.head);
+	init_list(&ncrx->frag_list.head);
+	init_list(&ncrx->retired_list.head);
+
+	ncrx->slots = calloc(ncrx->p.nr_slots, sizeof(ncrx->slots[0]));
+	if (!ncrx->slots)
+		return NULL;
+
+	for (i = 0; i < ncrx->p.nr_slots; i++)
+		init_list(&ncrx->slots[i].hole_node);
+
+	return ncrx;
+}
+
+void ncrx_destroy(struct ncrx *ncrx)
+{
+	struct ncrx_msg *msg;
+	int i;
+
+	for (i = 0; i < ncrx->p.nr_slots; i++)
+		free(ncrx->slots[i].msg);
+
+	while ((msg = msg_list_pop(&ncrx->oos_list)))
+		free(msg);
+
+	while ((msg = msg_list_pop(&ncrx->frag_list)))
+		free(msg);
+
+	while ((msg = msg_list_pop(&ncrx->retired_list)))
+		free(msg);
+
+	free(ncrx->slots);
+	free(ncrx);
+}
diff --git a/tools/lib/netconsole/ncrx.h b/tools/lib/netconsole/ncrx.h
new file mode 100644
index 0000000..a0e1652
--- /dev/null
+++ b/tools/lib/netconsole/ncrx.h
@@ -0,0 +1,204 @@
+/*
+ * ncrx - extended netconsole receiver library
+ *
+ * Copyright (C) 2015		Facebook, Inc
+ * Copyright (C) 2015		Tejun Heo <tj@kernel.org>
+ */
+#ifndef __NETCONSOLE_NCRX__
+#define __NETCONSOLE_NCRX__
+
+#include <inttypes.h>
+
+#define NCRX_LINE_MAX		8192
+
+struct ncrx_list {
+	struct ncrx_list	*next;
+	struct ncrx_list	*prev;
+};
+
+/*
+ * ncrx_msg represents a single log message and what gets returned from
+ * ncrx_next_msg().  Most of the public fields are self-explanatory except
+ * for the followings.
+ *
+ * frag
+ *	The message is partial fragment of multi-part messages printed
+ *	using KERN_CONT.  Usually, ncrx keeps these fragments until the
+ *	full copy is available and then discards them; however, if the log
+ *	source fails to send the completed copy for some reason, the
+ *	fragments are pushed out as are.
+ *
+ * oos
+ *	The message's sequence number doesn't match up with the current
+ *	message stream.  Could be from a foreign source or corrupt.  Ignore
+ *	when counting missing messages.
+ *
+ * seq_reset
+ *	The sequence number stream has jumped.  This usually happens when
+ *	the log source reboots.  The first message returned after ncrx
+ *	initialization always has this flag set.
+ */
+struct ncrx_msg {
+	/* public fields */
+	uint64_t		seq;		/* printk sequence number */
+	uint64_t		ts_usec;	/* printk timestamp in usec */
+	char			*text;		/* message body */
+	char			*dict;		/* optional dictionary */
+	int			text_len;	/* message body length */
+	int			dict_len;	/* dictionary length */
+
+	uint8_t			facility;	/* log facility */
+	uint8_t			level;		/* printk level */
+	unsigned		cont_start:1;	/* first of continued msgs */
+	unsigned		cont:1;		/* continuation of prev msg */
+	unsigned		frag:1;		/* fragment, no seq assigned */
+	unsigned		oos:1;		/* sequence out-of-order */
+	unsigned		seq_reset:1;	/* sequence reset */
+
+	/* private fields */
+	struct ncrx_list	node;
+	uint64_t		rx_at;		/* rx timestamp in msec */
+	uint32_t		ncfrag_bitmap;	/* netconsole frag map */
+	int			ncfrag_off;	/* netconsole frag offset */
+	uint64_t		fragid;		/* printk frag ID */
+
+	unsigned		has_fragid:1;	/* fragid valid */
+	unsigned		emg:1;		/* emergency transmission */
+
+	char			buf[];
+};
+
+/*
+ * ncrx paramters.  Specify NULL to use defaults for all.  Specify 0 to use
+ * deafult for individual parameters.  All time periods are in millisecs.
+ *
+ * nr_slots
+ *	The number of reorder slots.  This bounds the maximum memory which
+ *	may be consumed by the ncrx instance.  Lowering this number
+ *	increases the chance of the ordering window passing by a missing
+ *	message before it can be obtained leading to missed messages.
+ *
+ * ack_intv
+ *	A received message is acked after this period.  Transmission side
+ *	ack timeout is 10s and this should be shorter than that.
+ *
+ * retx_intv
+ *	Retransmission request is sent and repeated every this period.
+ *
+ * retx_stride
+ *	A missing message generates retransmission request whenever it gets
+ *	pushed back this number of slots by newly arriving message.
+ *
+ * msg_timeout
+ *	A missing message expires after this period and the sequence number
+ *	will be skipped in the output.
+ *
+ * oos_thr
+ *	Among last 32 message, if more than this number of messages are
+ *	out-of-order, the message stream is reset.
+ *
+ * oos_intv
+ *	A message is considered out-of-sequence only if the last message
+ *	received with the sequence number is older than this.
+ *
+ * oos_timeout
+ *	If sequence is not reset in this period after reception of an
+ *	out-of-order message, the message is output.
+ *
+ * frag_max
+ *	The maximum number of fragments to buffer.
+ *
+ * frag_timeout
+ *	If a fragment doesn't get shot down by reception of its matching
+ *	full message in this period, the fragment is output.
+ */
+struct ncrx_param {
+	int			nr_slots;
+
+	int			ack_intv;
+	int			retx_intv;
+	int			retx_stride;
+	int			msg_timeout;
+
+	int			oos_thr;
+	int			oos_intv;
+	int			oos_timeout;
+
+	int			frag_max;
+	int			frag_timeout;
+};
+
+/* default params */
+#define NCRX_DFL_NR_SLOTS	8192
+
+#define NCRX_DFL_ACK_INTV	5000
+#define NCRX_DFL_RETX_INTV	1000
+#define NCRX_DFL_RETX_STRIDE	256
+#define NCRX_DFL_MSG_TIMEOUT	30000
+
+#define NCRX_DFL_OOS_THR	(32 * 3 / 5)			/* 19 */
+#define NCRX_DFL_OOS_INTV	5000
+#define NCRX_DFL_OOS_TIMEOUT	NCRX_DFL_MSG_TIMEOUT
+
+#define NCRX_DFL_FRAG_MAX	32
+#define NCRX_DFL_FRAG_TIMEOUT	NCRX_DFL_MSG_TIMEOUT
+
+/*
+ * A ncrx instance is created by ncrx_create() and destroyed by
+ * ncrx_destroy().  All accesses to a given instance must be serialized;
+ * however, a process may create any number of instances and use them
+ * concurrently.
+ */
+struct ncrx;
+
+struct ncrx *ncrx_create(const struct ncrx_param *param);
+void ncrx_destroy(struct ncrx *ncrx);
+
+/*
+ * A ncrx instance doesn't do any IO or blocking.  It's just a state
+ * machine that the user can feed data into and get the results out of.
+ *
+ * ncrx_process()
+ *	Process @payload of a packet.  @now is the current time in msecs.
+ *	The origin doesn't matter as long as it's monotonously increasing.
+ *	@payload may be NULL.  See ncrx_invoke_process_at().
+ *
+ *	Returns 0 on success.  1 on failure with errno set.  EINVAL
+ *	indicates that @payload is not a valid extended netconsole message.
+ *
+ * ncrx_response()
+ *	The response to send to log source.  If the user calls this
+ *	function after each ncrx_process() invocation and sends back the
+ *	output, re- and emergency transmissions are activated increasing
+ *	the reliability especially if the network is flaky.  If not, ncrx
+ *	will passively reorder and assemble messages.
+ *
+ *	Returns pointer to '\0' terminated response string or NULL if
+ *	there's nothing to send back.  If @lenp is not NULL, *@lenp is set
+ *	to the length of the response string.
+ *
+ * ncrx_next_msg()
+ *	Fetches the next completed message.  Call repeatedly until NULL is
+ *	returned after each ncrx_process() invocation.  Each message should
+ *	be free()'d by the user after consumption.
+ *
+ * ncrx_invoke_process_at()
+ *	Message processing is timing dependent and ncrx often needs to take
+ *	actions after a certain time period even when there hasn't been any
+ *	new packets.  This function indicates when the caller should invoke
+ *	ncrx_process() at the latest.
+ *
+ *	The returned time is relative to @now previously provided to
+ *	ncrx_process().  e.g. if ncrx_process() needs to be invoked after 4
+ *	seconds since the last invocation where @now was 60000, this
+ *	function will return 64000.  Returns UINT64_MAX if there's no
+ *	pending timing dependent operation.
+ *
+ * See tools/ncrx/ncrx.c for a simple example.
+ */
+int ncrx_process(const char *payload, uint64_t now, struct ncrx *ncrx);
+const char *ncrx_response(struct ncrx *ncrx, int *lenp);
+struct ncrx_msg *ncrx_next_msg(struct ncrx *ncrx);
+uint64_t ncrx_invoke_process_at(struct ncrx *ncrx);
+
+#endif	/* __NETCONSOLE_NCRX__ */
diff --git a/tools/ncrx/Makefile b/tools/ncrx/Makefile
new file mode 100644
index 0000000..f3e9859
--- /dev/null
+++ b/tools/ncrx/Makefile
@@ -0,0 +1,14 @@
+# Makefile for ncrx
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS += -Wall -O2 -I../lib
+
+LIBS = ../lib/netconsole/libncrx.a
+LDFLAGS += $(LIBS)
+
+all: ncrx
+%: %.c $(LIBS)
+	$(CC) $(CFLAGS) -o $@ $^
+
+clean:
+	$(RM) ncrx
diff --git a/tools/ncrx/ncrx.c b/tools/ncrx/ncrx.c
new file mode 100644
index 0000000..f462377
--- /dev/null
+++ b/tools/ncrx/ncrx.c
@@ -0,0 +1,143 @@
+/*
+ * ncrx - simple extended netconsole receiver
+ *
+ * Copyright (C) 2015		Facebook, Inc
+ * Copyright (C) 2015		Tejun Heo <tj@kernel.org>
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <time.h>
+#include <poll.h>
+#include <ctype.h>
+#include <errno.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <netinet/udp.h>
+#include <netconsole/ncrx.h>
+
+int main(int argc, char **argv)
+{
+	char buf[NCRX_LINE_MAX + 1];
+	struct ncrx *ncrx;
+	struct sockaddr_in laddr = { };
+	uint64_t next_seq = 0, next_at = UINT64_MAX;
+	int fd;
+
+	if (argc != 2) {
+		fprintf(stderr, "Usage: ncrx PORT\n");
+		return 1;
+	}
+
+	fd = socket(AF_INET, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		perror("socket");
+		return 1;
+	}
+
+	laddr.sin_family = AF_INET;
+	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+	laddr.sin_port = htons(atoi(argv[1]));
+
+	if (bind(fd, (struct sockaddr *)&laddr, sizeof(laddr)) < 0) {
+		perror("bind");
+		return 1;
+	}
+
+	ncrx = ncrx_create(NULL);
+	if (!ncrx) {
+		perror("ncrx_create");
+		return 1;
+	}
+
+	while (1) {
+		struct pollfd pfd = { .fd = fd, .events = POLLIN };
+		struct sockaddr_in raddr;
+		struct ncrx_msg *msg;
+		struct timespec ts;
+		socklen_t raddr_len = sizeof(raddr);
+		char *payload = NULL;
+		const char *resp;
+		uint64_t now;
+		int timeout;
+		int len;
+
+		/* determine sleep interval and poll */
+		timeout = -1;
+		if (next_at != UINT64_MAX) {
+			timeout = 0;
+			if (next_at > now)
+				timeout = next_at - now;
+		}
+
+		if (poll(&pfd, 1, timeout) < 0) {
+			perror("poll");
+			return 1;
+		}
+
+		/* receive message */
+		len = recvfrom(fd, buf, sizeof(buf) - 1, MSG_DONTWAIT,
+			       (struct sockaddr *)&raddr, &raddr_len);
+
+		payload = NULL;
+		if (len >= 0) {
+			buf[len] = '\0';
+			payload = buf;
+		} else if (errno != EAGAIN) {
+			perror("recv");
+			return 1;
+		}
+
+		/* determine the current time */
+		if (clock_gettime(CLOCK_MONOTONIC, &ts)) {
+			perror("clock_gettime");
+			return 1;
+		}
+		now = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
+
+		/* process the payload and perform rx operations */
+		if (ncrx_process(payload, now, ncrx) && errno != ENOENT) {
+			if (errno == EINVAL) {
+				while (len && isspace(payload[len - 1]))
+					payload[--len] = '\0';
+				printf("[%12s] %s\n", "INVAL", payload);
+			} else {
+				perror("ncrx_process");
+			}
+		}
+
+		resp = ncrx_response(ncrx, &len);
+		if (resp && sendto(fd, resp, len, 0,
+				   (struct sockaddr *)&raddr, raddr_len) < 0)
+			perror("sendto");
+
+		while ((msg = ncrx_next_msg(ncrx))) {
+			if (msg->frag) {
+				printf("[%12s] %s\n", "FRAG", msg->text);
+				continue;
+			}
+			if (msg->oos) {
+				printf("[%12s] %s\n", "OOS", msg->text);
+				continue;
+			}
+			if (msg->seq_reset) {
+				printf("[%12s] seq=%"PRIu64"\n", "SEQ RESET",
+				       msg->seq);
+				next_seq = msg->seq;
+			}
+			if (msg->seq != next_seq) {
+				printf("[%12s] %"PRIu64" messages skipped\n",
+				       "SEQ SKIPPED", msg->seq - next_seq);
+			}
+
+			next_seq = msg->seq + 1;
+
+			printf("[%5"PRIu64".%06"PRIu64"] %s\n",
+			       msg->ts_usec / 1000000, msg->ts_usec % 1000000,
+			       msg->text);
+		}
+
+		next_at = ncrx_invoke_process_at(ncrx);
+	}
+
+	return 0;
+}
-- 
2.1.0
