From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 27/53] perf/core: Put size of a sample at the end of it by PERF_SAMPLE_TAILSIZE
Date: Mon, 11 Jan 2016 13:48:18 +0000
Message-ID: <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	"Ingo Molnar" <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Yunlong Song <yunlong.song@huawei.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a PERF_SAMPLE_TAILSIZE flag which allows a size
field attached at the end of a sample. The idea comes from [1] that,
with tie size at tail of an event, it is possible for user program who
read from the ring buffer parse events backward.

For example:

   head
    |
    V
 +--+---+-------+----------+------+---+
 |E6|...|   B  8|   C    11|  D  7|E..|
 +--+---+-------+----------+------+---+

In this case, from the 'head' pointer provided by kernel, user program
can first see '6' by (*(head - sizeof(u64))), then it can get the start
pointer of record 'E', then it can read size and find start position
of record D, C, B in similar way.

The implementation is easy: adding a PERF_SAMPLE_TAILSIZE flag, makes
perf_output_sample() output size at the end of a sample.

Following things are done for ensure the ring buffer is safe for
backward parsing:

 - Don't allow two events with different PERF_SAMPLE_TAILSIZE setting
   set their output to each other;

 - For non-sample events, also output tailsize if required.

This patch has a limitation for perf:

Before reading such ring buffer, perf must ensure all events which may
output to it is already stopped, so the 'head' pointer it get is the
end of the last record.

[1] http://lkml.kernel.org/g/1449063499-236703-1-git-send-email-wangnan0@huawei.com

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: David Ahern <dsahern@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Yunlong Song <yunlong.song@huawei.com>
---
 include/linux/perf_event.h      | 17 ++++++---
 include/uapi/linux/perf_event.h |  3 +-
 kernel/events/core.c            | 82 +++++++++++++++++++++++++++++------------
 kernel/events/ring_buffer.c     |  7 ++--
 4 files changed, 75 insertions(+), 34 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index f9828a4..c5df1e82 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -835,13 +835,13 @@ extern void perf_event_output(struct perf_event *event,
 				struct pt_regs *regs);
 
 extern void
-perf_event_header__init_id(struct perf_event_header *header,
-			   struct perf_sample_data *data,
-			   struct perf_event *event);
+perf_event_header__init_extra(struct perf_event_header *header,
+			      struct perf_sample_data *data,
+			      struct perf_event *event);
 extern void
-perf_event__output_id_sample(struct perf_event *event,
-			     struct perf_output_handle *handle,
-			     struct perf_sample_data *sample);
+perf_event__output_extra(struct perf_event *event, u64 evt_size,
+			 struct perf_output_handle *handle,
+			 struct perf_sample_data *sample);
 
 extern void
 perf_log_lost_samples(struct perf_event *event, u64 lost);
@@ -1032,6 +1032,11 @@ static inline bool has_aux(struct perf_event *event)
 	return event->pmu->setup_aux;
 }
 
+static inline bool has_tailsize(struct perf_event *event)
+{
+	return event->attr.sample_type & PERF_SAMPLE_TAILSIZE;
+}
+
 extern int perf_output_begin(struct perf_output_handle *handle,
 			     struct perf_event *event, unsigned int size);
 extern void perf_output_end(struct perf_output_handle *handle);
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 1afe962..4e8dde8 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -139,8 +139,9 @@ enum perf_event_sample_format {
 	PERF_SAMPLE_IDENTIFIER			= 1U << 16,
 	PERF_SAMPLE_TRANSACTION			= 1U << 17,
 	PERF_SAMPLE_REGS_INTR			= 1U << 18,
+	PERF_SAMPLE_TAILSIZE			= 1U << 19,
 
-	PERF_SAMPLE_MAX = 1U << 19,		/* non-ABI */
+	PERF_SAMPLE_MAX = 1U << 20,		/* non-ABI */
 };
 
 /*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index bf82441..2d59b59 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5128,12 +5128,14 @@ static void __perf_event_header__init_id(struct perf_event_header *header,
 	}
 }
 
-void perf_event_header__init_id(struct perf_event_header *header,
-				struct perf_sample_data *data,
-				struct perf_event *event)
+void perf_event_header__init_extra(struct perf_event_header *header,
+				   struct perf_sample_data *data,
+				   struct perf_event *event)
 {
 	if (event->attr.sample_id_all)
 		__perf_event_header__init_id(header, data, event);
+	if (has_tailsize(event))
+		header->size += sizeof(u64);
 }
 
 static void __perf_event__output_id_sample(struct perf_output_handle *handle,
@@ -5160,12 +5162,14 @@ static void __perf_event__output_id_sample(struct perf_output_handle *handle,
 		perf_output_put(handle, data->id);
 }
 
-void perf_event__output_id_sample(struct perf_event *event,
-				  struct perf_output_handle *handle,
-				  struct perf_sample_data *sample)
+void perf_event__output_extra(struct perf_event *event, u64 evt_size,
+			      struct perf_output_handle *handle,
+			      struct perf_sample_data *sample)
 {
 	if (event->attr.sample_id_all)
 		__perf_event__output_id_sample(handle, sample);
+	if (has_tailsize(event))
+		perf_output_put(handle, evt_size);
 }
 
 static void perf_output_read_one(struct perf_output_handle *handle,
@@ -5407,6 +5411,13 @@ void perf_output_sample(struct perf_output_handle *handle,
 		}
 	}
 
+	/* Should be the last one */
+	if (sample_type & PERF_SAMPLE_TAILSIZE) {
+		u64 evt_size = header->size;
+
+		perf_output_put(handle, evt_size);
+	}
+
 	if (!event->attr.watermark) {
 		int wakeup_events = event->attr.wakeup_events;
 
@@ -5526,6 +5537,9 @@ void perf_prepare_sample(struct perf_event_header *header,
 
 		header->size += size;
 	}
+
+	if (sample_type & PERF_SAMPLE_TAILSIZE)
+		header->size += sizeof(u64);
 }
 
 void perf_event_output(struct perf_event *event,
@@ -5579,14 +5593,15 @@ perf_event_read_event(struct perf_event *event,
 	};
 	int ret;
 
-	perf_event_header__init_id(&read_event.header, &sample, event);
+	perf_event_header__init_extra(&read_event.header, &sample, event);
 	ret = perf_output_begin(&handle, event, read_event.header.size);
 	if (ret)
 		return;
 
 	perf_output_put(&handle, read_event);
 	perf_output_read(&handle, event);
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, read_event.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 }
@@ -5698,7 +5713,7 @@ static void perf_event_task_output(struct perf_event *event,
 	if (!perf_event_task_match(event))
 		return;
 
-	perf_event_header__init_id(&task_event->event_id.header, &sample, event);
+	perf_event_header__init_extra(&task_event->event_id.header, &sample, event);
 
 	ret = perf_output_begin(&handle, event,
 				task_event->event_id.header.size);
@@ -5715,7 +5730,9 @@ static void perf_event_task_output(struct perf_event *event,
 
 	perf_output_put(&handle, task_event->event_id);
 
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event,
+				 task_event->event_id.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 out:
@@ -5794,7 +5811,7 @@ static void perf_event_comm_output(struct perf_event *event,
 	if (!perf_event_comm_match(event))
 		return;
 
-	perf_event_header__init_id(&comm_event->event_id.header, &sample, event);
+	perf_event_header__init_extra(&comm_event->event_id.header, &sample, event);
 	ret = perf_output_begin(&handle, event,
 				comm_event->event_id.header.size);
 
@@ -5808,7 +5825,8 @@ static void perf_event_comm_output(struct perf_event *event,
 	__output_copy(&handle, comm_event->comm,
 				   comm_event->comm_size);
 
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, comm_event->event_id.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 out:
@@ -5917,7 +5935,7 @@ static void perf_event_mmap_output(struct perf_event *event,
 		mmap_event->event_id.header.size += sizeof(mmap_event->flags);
 	}
 
-	perf_event_header__init_id(&mmap_event->event_id.header, &sample, event);
+	perf_event_header__init_extra(&mmap_event->event_id.header, &sample, event);
 	ret = perf_output_begin(&handle, event,
 				mmap_event->event_id.header.size);
 	if (ret)
@@ -5940,7 +5958,8 @@ static void perf_event_mmap_output(struct perf_event *event,
 	__output_copy(&handle, mmap_event->file_name,
 				   mmap_event->file_size);
 
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, mmap_event->event_id.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 out:
@@ -6123,14 +6142,15 @@ void perf_event_aux_event(struct perf_event *event, unsigned long head,
 	};
 	int ret;
 
-	perf_event_header__init_id(&rec.header, &sample, event);
+	perf_event_header__init_extra(&rec.header, &sample, event);
 	ret = perf_output_begin(&handle, event, rec.header.size);
 
 	if (ret)
 		return;
 
 	perf_output_put(&handle, rec);
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, rec.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 }
@@ -6156,7 +6176,7 @@ void perf_log_lost_samples(struct perf_event *event, u64 lost)
 		.lost		= lost,
 	};
 
-	perf_event_header__init_id(&lost_samples_event.header, &sample, event);
+	perf_event_header__init_extra(&lost_samples_event.header, &sample, event);
 
 	ret = perf_output_begin(&handle, event,
 				lost_samples_event.header.size);
@@ -6164,7 +6184,8 @@ void perf_log_lost_samples(struct perf_event *event, u64 lost)
 		return;
 
 	perf_output_put(&handle, lost_samples_event);
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, lost_samples_event.header.size,
+				 &handle, &sample);
 	perf_output_end(&handle);
 }
 
@@ -6211,7 +6232,7 @@ static void perf_event_switch_output(struct perf_event *event, void *data)
 					perf_event_tid(event, se->next_prev);
 	}
 
-	perf_event_header__init_id(&se->event_id.header, &sample, event);
+	perf_event_header__init_extra(&se->event_id.header, &sample, event);
 
 	ret = perf_output_begin(&handle, event, se->event_id.header.size);
 	if (ret)
@@ -6222,7 +6243,8 @@ static void perf_event_switch_output(struct perf_event *event, void *data)
 	else
 		perf_output_put(&handle, se->event_id);
 
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, se->event_id.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 }
@@ -6282,7 +6304,7 @@ static void perf_log_throttle(struct perf_event *event, int enable)
 	if (enable)
 		throttle_event.header.type = PERF_RECORD_UNTHROTTLE;
 
-	perf_event_header__init_id(&throttle_event.header, &sample, event);
+	perf_event_header__init_extra(&throttle_event.header, &sample, event);
 
 	ret = perf_output_begin(&handle, event,
 				throttle_event.header.size);
@@ -6290,7 +6312,8 @@ static void perf_log_throttle(struct perf_event *event, int enable)
 		return;
 
 	perf_output_put(&handle, throttle_event);
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, throttle_event.header.size,
+				 &handle, &sample);
 	perf_output_end(&handle);
 }
 
@@ -6318,14 +6341,15 @@ static void perf_log_itrace_start(struct perf_event *event)
 	rec.pid	= perf_event_pid(event, current);
 	rec.tid	= perf_event_tid(event, current);
 
-	perf_event_header__init_id(&rec.header, &sample, event);
+	perf_event_header__init_extra(&rec.header, &sample, event);
 	ret = perf_output_begin(&handle, event, rec.header.size);
 
 	if (ret)
 		return;
 
 	perf_output_put(&handle, rec);
-	perf_event__output_id_sample(event, &handle, &sample);
+	perf_event__output_extra(event, rec.header.size,
+				 &handle, &sample);
 
 	perf_output_end(&handle);
 }
@@ -8098,6 +8122,16 @@ perf_event_set_output(struct perf_event *event, struct perf_event *output_event)
 	    event->pmu != output_event->pmu)
 		goto out;
 
+	/*
+	 * Don't allow mixed tailsize setting since the resuling
+	 * ringbuffer would unable to be parsed backward.
+	 *
+	 * '!=' is safe because has_tailsize() returns bool, two differnt
+	 * non-zero values would be treated as equal (both true).
+	 */
+	if (has_tailsize(event) != has_tailsize(output_event))
+		goto out;
+
 set:
 	mutex_lock(&event->mmap_mutex);
 	/* Can't redirect output if we've got an active mmap() */
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index adfdc05..5f8bd89 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -186,10 +186,11 @@ int perf_output_begin(struct perf_output_handle *handle,
 		lost_event.id          = event->id;
 		lost_event.lost        = local_xchg(&rb->lost, 0);
 
-		perf_event_header__init_id(&lost_event.header,
-					   &sample_data, event);
+		perf_event_header__init_extra(&lost_event.header,
+					      &sample_data, event);
 		perf_output_put(handle, lost_event);
-		perf_event__output_id_sample(event, handle, &sample_data);
+		perf_event__output_extra(event, lost_event.header.type,
+					 handle, &sample_data);
 	}
 
 	return 0;
-- 
1.8.3.4
