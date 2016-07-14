From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/3] perf, events: add non-linear data support for raw records
Date: Thu, 14 Jul 2016 18:08:03 +0200
Message-ID: <a84a04cb6c6f14f2a8332e89308e354d76e8f7c6.1468511632.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for non-linear data on raw records. It
extends raw records to have one or multiple fragments that will
be written linearly into the ring slot, where each fragment can
optionally have a custom callback handler to walk and extract
complex, possibly non-linear data.

If a callback handler is provided for a fragment, then the new
__output_custom() will be used instead of __output_copy() for
the perf_output_sample() part. perf_prepare_sample() does all
the size calculation only once, so perf_output_sample() doesn't
need to redo the same work anymore, meaning real_size and padding
will be cached in the raw record. The raw record becomes 32 bytes
in size without holes; to not increase it further and to avoid
doing unnecessary recalculations in fast-path, we can reuse
next pointer of the last fragment, idea here is borrowed from
ZERO_OR_NULL_PTR(), which should keep the perf_output_sample()
path for PERF_SAMPLE_RAW minimal.

This facility is needed for BPF's event output helper as a first
user that will, in a follow-up, add an additional perf_raw_frag
to its perf_raw_record in order to be able to more efficiently
dump skb context after a linear head meta data related to it.
skbs can be non-linear and thus need a custom output function to
dump buffers. Currently, the skb data needs to be copied twice;
with the help of __output_custom() this work only needs to be
done once. Future users could be things like XDP/BPF programs
that work on different context though and would thus also have
a different callback function.

The few users of raw records are adapted to initialize their frag
data from the raw record itself, no change in behavior for them.
The code is based upon a PoC diff provided by Peter Zijlstra [1].

  [1] http://thread.gmane.org/gmane.linux.network/421294

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Hi Peter, I've adapted the patch to your suggestion and also
 added the padding; all size calculation is only done once at
 perf_prepare_sample() time as well to avoid unnecessary work.
 Please let me know if you're good with this. Thanks a lot!

 arch/s390/kernel/perf_cpum_sf.c |  9 ++++--
 arch/x86/events/amd/ibs.c       |  8 +++--
 include/linux/perf_event.h      | 20 ++++++++++++-
 kernel/events/core.c            | 66 ++++++++++++++++++++++++++++-------------
 kernel/events/internal.h        | 16 +++++++---
 kernel/trace/bpf_trace.c        |  6 ++--
 6 files changed, 93 insertions(+), 32 deletions(-)

diff --git a/arch/s390/kernel/perf_cpum_sf.c b/arch/s390/kernel/perf_cpum_sf.c
index a8e8321..92619cc 100644
--- a/arch/s390/kernel/perf_cpum_sf.c
+++ b/arch/s390/kernel/perf_cpum_sf.c
@@ -979,12 +979,15 @@ static int perf_push_sample(struct perf_event *event, struct sf_raw_sample *sfr)
 	struct pt_regs regs;
 	struct perf_sf_sde_regs *sde_regs;
 	struct perf_sample_data data;
-	struct perf_raw_record raw;
+	struct perf_raw_record raw = {
+		.frag = {
+			.size = sfr->size,
+			.data = sfr,
+		},
+	};
 
 	/* Setup perf sample */
 	perf_sample_data_init(&data, 0, event->hw.last_period);
-	raw.size = sfr->size;
-	raw.data = sfr;
 	data.raw = &raw;
 
 	/* Setup pt_regs to look like an CPU-measurement external interrupt
diff --git a/arch/x86/events/amd/ibs.c b/arch/x86/events/amd/ibs.c
index feb90f6..72dea2f 100644
--- a/arch/x86/events/amd/ibs.c
+++ b/arch/x86/events/amd/ibs.c
@@ -655,8 +655,12 @@ fail:
 	}
 
 	if (event->attr.sample_type & PERF_SAMPLE_RAW) {
-		raw.size = sizeof(u32) + ibs_data.size;
-		raw.data = ibs_data.data;
+		raw = (struct perf_raw_record){
+			.frag = {
+				.size = sizeof(u32) + ibs_data.size,
+				.data = ibs_data.data,
+			},
+		};
 		data.raw = &raw;
 	}
 
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 1a827ce..e79e6c6 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -69,9 +69,22 @@ struct perf_callchain_entry_ctx {
 	bool			    contexts_maxed;
 };
 
+typedef unsigned long (*perf_copy_f)(void *dst, const void *src,
+				     unsigned long len);
+
+struct perf_raw_frag {
+	union {
+		struct perf_raw_frag	*next;
+		unsigned long		pad;
+	};
+	perf_copy_f			copy;
+	void				*data;
+	u32				size;
+} __packed;
+
 struct perf_raw_record {
+	struct perf_raw_frag		frag;
 	u32				size;
-	void				*data;
 };
 
 /*
@@ -1283,6 +1296,11 @@ extern void perf_restore_debug_store(void);
 static inline void perf_restore_debug_store(void)			{ }
 #endif
 
+static __always_inline bool perf_raw_frag_last(const struct perf_raw_frag *frag)
+{
+	return frag->pad < sizeof(u64);
+}
+
 #define perf_output_put(handle, x) perf_output_copy((handle), &(x), sizeof(x))
 
 /*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9c51ec3..b1891b6 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5553,16 +5553,26 @@ void perf_output_sample(struct perf_output_handle *handle,
 	}
 
 	if (sample_type & PERF_SAMPLE_RAW) {
-		if (data->raw) {
-			u32 raw_size = data->raw->size;
-			u32 real_size = round_up(raw_size + sizeof(u32),
-						 sizeof(u64)) - sizeof(u32);
-			u64 zero = 0;
-
-			perf_output_put(handle, real_size);
-			__output_copy(handle, data->raw->data, raw_size);
-			if (real_size - raw_size)
-				__output_copy(handle, &zero, real_size - raw_size);
+		struct perf_raw_record *raw = data->raw;
+
+		if (raw) {
+			struct perf_raw_frag *frag = &raw->frag;
+
+			perf_output_put(handle, raw->size);
+			do {
+				if (frag->copy) {
+					__output_custom(handle, frag->copy,
+							frag->data, frag->size);
+				} else {
+					__output_copy(handle, frag->data,
+						      frag->size);
+				}
+				if (perf_raw_frag_last(frag))
+					break;
+				frag = frag->next;
+			} while (1);
+			if (frag->pad)
+				__output_skip(handle, NULL, frag->pad);
 		} else {
 			struct {
 				u32	size;
@@ -5687,14 +5697,28 @@ void perf_prepare_sample(struct perf_event_header *header,
 	}
 
 	if (sample_type & PERF_SAMPLE_RAW) {
-		int size = sizeof(u32);
-
-		if (data->raw)
-			size += data->raw->size;
-		else
-			size += sizeof(u32);
+		struct perf_raw_record *raw = data->raw;
+		int size;
+
+		if (raw) {
+			struct perf_raw_frag *frag = &raw->frag;
+			u32 sum = 0;
+
+			do {
+				sum += frag->size;
+				if (perf_raw_frag_last(frag))
+					break;
+				frag = frag->next;
+			} while (1);
+
+			size = round_up(sum + sizeof(u32), sizeof(u64));
+			raw->size = size - sizeof(u32);
+			frag->pad = raw->size - sum;
+		} else {
+			size = sizeof(u64);
+		}
 
-		header->size += round_up(size, sizeof(u64));
+		header->size += size;
 	}
 
 	if (sample_type & PERF_SAMPLE_BRANCH_STACK) {
@@ -7331,7 +7355,7 @@ static struct pmu perf_swevent = {
 static int perf_tp_filter_match(struct perf_event *event,
 				struct perf_sample_data *data)
 {
-	void *record = data->raw->data;
+	void *record = data->raw->frag.data;
 
 	/* only top level events have filters set */
 	if (event->parent)
@@ -7387,8 +7411,10 @@ void perf_tp_event(u16 event_type, u64 count, void *record, int entry_size,
 	struct perf_event *event;
 
 	struct perf_raw_record raw = {
-		.size = entry_size,
-		.data = record,
+		.frag = {
+			.size = entry_size,
+			.data = record,
+		},
 	};
 
 	perf_sample_data_init(&data, 0, 0);
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 05f9f6d..2417eb5 100644
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
@@ -152,6 +149,17 @@ func_name(struct perf_output_handle *handle,				\
 	return len;							\
 }
 
+#define DEFINE_OUTPUT_COPY(func_name, memcpy_func)			\
+static inline unsigned long						\
+func_name(struct perf_output_handle *handle,				\
+	  const void *buf, unsigned long len)				\
+__DEFINE_OUTPUT_COPY_BODY(memcpy_func)
+
+static inline unsigned long
+__output_custom(struct perf_output_handle *handle, perf_copy_f copy_func,
+		const void *buf, unsigned long len)
+__DEFINE_OUTPUT_COPY_BODY(copy_func)
+
 static inline unsigned long
 memcpy_common(void *dst, const void *src, unsigned long n)
 {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 094c716..35ab1b2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -245,8 +245,10 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	struct bpf_event_entry *ee;
 	struct perf_event *event;
 	struct perf_raw_record raw = {
-		.size = size,
-		.data = data,
+		.frag = {
+			.size = size,
+			.data = data,
+		},
 	};
 
 	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
-- 
1.9.3
