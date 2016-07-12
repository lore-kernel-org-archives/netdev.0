From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] perf, events: add non-linear data support for raw records
Date: Wed, 13 Jul 2016 00:36:17 +0200
Message-ID: <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44874 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbcGLWg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:36:59 -0400
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for non-linear data on raw records. It means
that for such data, the newly introduced __output_custom() helper will
be used instead of __output_copy(). __output_custom() will invoke
whatever custom callback is passed in via struct perf_raw_record_frag
to extract the data into the ring buffer slot.

To keep changes in perf_prepare_sample() and in perf_output_sample()
minimal, size/size_head split was added to perf_raw_record that call
sites fill out, so that two extra tests in fast-path can be avoided.

The few users of raw records are adapted to initialize their size_head
and frag data; no change in behavior for them. Later patch will extend
BPF side with a first user and callback for this facility, future users
could be things like XDP BPF programs (that work on different context
though and would thus have a different callback), etc.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/s390/kernel/perf_cpum_sf.c |  2 ++
 arch/x86/events/amd/ibs.c       |  2 ++
 include/linux/perf_event.h      |  8 ++++++++
 kernel/events/core.c            | 13 ++++++++++---
 kernel/events/internal.h        | 18 ++++++++++++++----
 kernel/trace/bpf_trace.c        |  1 +
 6 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/arch/s390/kernel/perf_cpum_sf.c b/arch/s390/kernel/perf_cpum_sf.c
index a8e8321..99c5952 100644
--- a/arch/s390/kernel/perf_cpum_sf.c
+++ b/arch/s390/kernel/perf_cpum_sf.c
@@ -984,7 +984,9 @@ static int perf_push_sample(struct perf_event *event, struct sf_raw_sample *sfr)
 	/* Setup perf sample */
 	perf_sample_data_init(&data, 0, event->hw.last_period);
 	raw.size = sfr->size;
+	raw.size_head = raw.size;
 	raw.data = sfr;
+	raw.frag = NULL;
 	data.raw = &raw;
 
 	/* Setup pt_regs to look like an CPU-measurement external interrupt
diff --git a/arch/x86/events/amd/ibs.c b/arch/x86/events/amd/ibs.c
index feb90f6..9b27dff 100644
--- a/arch/x86/events/amd/ibs.c
+++ b/arch/x86/events/amd/ibs.c
@@ -656,7 +656,9 @@ fail:
 
 	if (event->attr.sample_type & PERF_SAMPLE_RAW) {
 		raw.size = sizeof(u32) + ibs_data.size;
+		raw.size_head = raw.size;
 		raw.data = ibs_data.data;
+		raw.frag = NULL;
 		data.raw = &raw;
 	}
 
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 1a827ce..bf08bdf 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -69,9 +69,17 @@ struct perf_callchain_entry_ctx {
 	bool			    contexts_maxed;
 };
 
+struct perf_raw_record_frag {
+	void				*data;
+	unsigned long (*copy_cb)	(void *dst, const void *src,
+					 unsigned long n);
+};
+
 struct perf_raw_record {
 	u32				size;
+	u32				size_head;
 	void				*data;
+	struct perf_raw_record_frag	*frag;
 };
 
 /*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9c51ec3..3e1dd7a 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5553,14 +5553,20 @@ void perf_output_sample(struct perf_output_handle *handle,
 	}
 
 	if (sample_type & PERF_SAMPLE_RAW) {
-		if (data->raw) {
-			u32 raw_size = data->raw->size;
+		struct perf_raw_record *raw = data->raw;
+
+		if (raw) {
+			u32 raw_size = raw->size;
 			u32 real_size = round_up(raw_size + sizeof(u32),
 						 sizeof(u64)) - sizeof(u32);
 			u64 zero = 0;
 
 			perf_output_put(handle, real_size);
-			__output_copy(handle, data->raw->data, raw_size);
+			__output_copy(handle, raw->data, raw->size_head);
+			if (raw->frag)
+				__output_custom(handle, raw->frag->copy_cb,
+						raw->frag->data,
+						raw->size - raw->size_head);
 			if (real_size - raw_size)
 				__output_copy(handle, &zero, real_size - raw_size);
 		} else {
@@ -7388,6 +7394,7 @@ void perf_tp_event(u16 event_type, u64 count, void *record, int entry_size,
 
 	struct perf_raw_record raw = {
 		.size = entry_size,
+		.size_head = entry_size,
 		.data = record,
 	};
 
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 05f9f6d..1b08d94 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -123,10 +123,7 @@ static inline unsigned long perf_aux_size(struct ring_buffer *rb)
 	return rb->aux_nr_pages << PAGE_SHIFT;
 }
 
-#define DEFINE_OUTPUT_COPY(func_name, memcpy_func)			\
-static inline unsigned long						\
-func_name(struct perf_output_handle *handle,				\
-	  const void *buf, unsigned long len)				\
+#define __DEFINE_OUTPUT_COPY_BODY(memcpy_func)				\
 {									\
 	unsigned long size, written;					\
 									\
@@ -152,6 +149,19 @@ func_name(struct perf_output_handle *handle,				\
 	return len;							\
 }
 
+#define DEFINE_OUTPUT_COPY(func_name, memcpy_func)			\
+static inline unsigned long						\
+func_name(struct perf_output_handle *handle,				\
+	  const void *buf, unsigned long len)				\
+__DEFINE_OUTPUT_COPY_BODY(memcpy_func)
+
+static inline unsigned long
+__output_custom(struct perf_output_handle *handle,
+		unsigned long (*copy_cb)(void *dst, const void *src,
+					 unsigned long n),
+		const void *buf, unsigned long len)
+__DEFINE_OUTPUT_COPY_BODY(copy_cb)
+
 static inline unsigned long
 memcpy_common(void *dst, const void *src, unsigned long n)
 {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 094c716..8540bd5 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -246,6 +246,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	struct perf_event *event;
 	struct perf_raw_record raw = {
 		.size = size,
+		.size_head = size,
 		.data = data,
 	};
 
-- 
1.9.3
