From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf, events: add non-linear data support
 for raw records
Date: Wed, 13 Jul 2016 15:42:31 +0200
Message-ID: <20160713134231.GT30154@twins.programming.kicks-ass.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
 <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42414 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbcGMNnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 09:43:03 -0400
Content-Disposition: inline
In-Reply-To: <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok so the nonlinear thing was it doing _two_ copies, one the regular
__output_copy() on raw->data and second the optional fragment thingy
using __output_custom().

Would something like this work instead?

It does the nonlinear thing and the custom copy function thing but
allows more than 2 fragments and allows each fragment to have a custom
copy.

It doesn't look obviously more expensive; it has the one ->copy branch
extra, but then it doesn't recompute the sizes.

---

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 1fe22032f228..83e2a83e8db3 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -69,9 +69,18 @@ struct perf_callchain_entry_ctx {
 	bool			    contexts_maxed;
 };
 
+typedef unsigned long (*perf_copy_f)(void *dst, const void *src, unsigned long len);
+
+struct perf_raw_frag {
+	struct perf_raw_frag		*next;
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
diff --git a/kernel/events/core.c b/kernel/events/core.c
index fe8d49a56322..f7ad7d65317d 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5617,16 +5617,21 @@ void perf_output_sample(struct perf_output_handle *handle,
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
+					__output_copy(handle, frag->data, frag->size);
+				}
+				frag = frag->next;
+			} while (frag);
 		} else {
 			struct {
 				u32	size;
@@ -5751,14 +5756,22 @@ void perf_prepare_sample(struct perf_event_header *header,
 	}
 
 	if (sample_type & PERF_SAMPLE_RAW) {
-		int size = sizeof(u32);
+		struct perf_raw_record *raw = data->raw;
+		int size = sizeof(u64);
 
-		if (data->raw)
-			size += data->raw->size;
-		else
-			size += sizeof(u32);
+		if (raw) {
+			struct perf_raw_frag *frag = &raw->frag;
 
-		header->size += round_up(size, sizeof(u64));
+			size = sizeof(u32);
+			do {
+				size += frag->size;
+				frag = frag->next;
+			} while (frag)
+			size = round_up(size, sizeof(u64));
+			raw->size = size;
+		}
+
+		header->size += size;
 	}
 
 	if (sample_type & PERF_SAMPLE_BRANCH_STACK) {
