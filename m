From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V2 2/2] bpf: control a set of perf events by creating a new ioctl PERF_EVENT_IOC_SET_ENABLER
Date: Wed, 14 Oct 2015 12:37:57 +0000
Message-ID: <1444826277-94060-3-git-send-email-xiakaixu@huawei.com>
References: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:26475 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbJNMiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:38:23 -0400
In-Reply-To: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a new ioctl PERF_EVENT_IOC_SET_ENABLER to let
perf to select an event as 'enabler'. So we can set this 'enabler'
event to enable/disable a set of events. The event on CPU 0 is
treated as the 'enabler' event by default.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 include/linux/perf_event.h      |  1 +
 include/uapi/linux/perf_event.h |  1 +
 kernel/events/core.c            | 42 ++++++++++++++++++++++++++++++++++++++++-
 kernel/trace/bpf_trace.c        |  5 ++++-
 4 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index dcbf7d5..bc9fe77 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -473,6 +473,7 @@ struct perf_event {
 
 	atomic_t			event_limit;
 	atomic_t			sample_disable;
+	atomic_t			*p_sample_disable;
 
 	void (*destroy)(struct perf_event *);
 	struct rcu_head			rcu_head;
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index a2b9dd7..3b4fb90 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -393,6 +393,7 @@ struct perf_event_attr {
 #define PERF_EVENT_IOC_SET_FILTER	_IOW('$', 6, char *)
 #define PERF_EVENT_IOC_ID		_IOR('$', 7, __u64 *)
 #define PERF_EVENT_IOC_SET_BPF		_IOW('$', 8, __u32)
+#define PERF_EVENT_IOC_SET_ENABLER	_IO ('$', 9)
 
 enum perf_event_ioc_flags {
 	PERF_IOC_FLAG_GROUP		= 1U << 0,
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 942351c..03d2594 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -4152,6 +4152,7 @@ static int perf_event_set_output(struct perf_event *event,
 				 struct perf_event *output_event);
 static int perf_event_set_filter(struct perf_event *event, void __user *arg);
 static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd);
+static int perf_event_set_sample_enabler(struct perf_event *event, u32 enabler_fd);
 
 static long _perf_ioctl(struct perf_event *event, unsigned int cmd, unsigned long arg)
 {
@@ -4208,6 +4209,9 @@ static long _perf_ioctl(struct perf_event *event, unsigned int cmd, unsigned lon
 	case PERF_EVENT_IOC_SET_BPF:
 		return perf_event_set_bpf_prog(event, arg);
 
+	case PERF_EVENT_IOC_SET_ENABLER:
+		return perf_event_set_sample_enabler(event, arg);
+
 	default:
 		return -ENOTTY;
 	}
@@ -6337,7 +6341,7 @@ static int __perf_event_overflow(struct perf_event *event,
 		irq_work_queue(&event->pending);
 	}
 
-	if (!atomic_read(&event->sample_disable))
+	if (!atomic_read(event->p_sample_disable))
 		return ret;
 
 	if (event->overflow_handler)
@@ -6989,6 +6993,35 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	return 0;
 }
 
+static int perf_event_set_sample_enabler(struct perf_event *event, u32 enabler_fd)
+{
+	int ret;
+	struct fd enabler;
+	struct perf_event *enabler_event;
+
+	if (enabler_fd == -1)
+		return 0;
+
+	ret = perf_fget_light(enabler_fd, &enabler);
+	if (ret)
+		return ret;
+	enabler_event = enabler.file->private_data;
+	if (event == enabler_event) {
+		fdput(enabler);
+		return 0;
+	}
+
+	/* they must be on the same PMU*/
+	if (event->pmu != enabler_event->pmu) {
+		fdput(enabler);
+		return -EINVAL;
+	}
+
+	event->p_sample_disable = &enabler_event->sample_disable;
+	fdput(enabler);
+	return 0;
+}
+
 static void perf_event_free_bpf_prog(struct perf_event *event)
 {
 	struct bpf_prog *prog;
@@ -7023,6 +7056,11 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	return -ENOENT;
 }
 
+static int perf_event_set_sample_enabler(struct perf_event *event, u32 group_fd)
+{
+	return -ENOENT;
+}
+
 static void perf_event_free_bpf_prog(struct perf_event *event)
 {
 }
@@ -7718,6 +7756,8 @@ static void perf_event_check_sample_flag(struct perf_event *event)
 		atomic_set(&event->sample_disable, 0);
 	else
 		atomic_set(&event->sample_disable, 1);
+
+	event->p_sample_disable = &event->sample_disable;
 }
 
 /*
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index f261333..d012be3 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -221,9 +221,12 @@ static u64 bpf_perf_event_sample_control(u64 r1, u64 index, u64 flag, u64 r4, u6
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct perf_event *event;
 
-	if (unlikely(index >= array->map.max_entries))
+	if (unlikely(index > array->map.max_entries))
 		return -E2BIG;
 
+	if (index == array->map.max_entries)
+		index = 0;
+
 	event = (struct perf_event *)array->ptrs[index];
 	if (!event)
 		return -ENOENT;
-- 
1.8.3.4
