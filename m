From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, events: fix offset in skb copy handler
Date: Fri, 22 Jul 2016 01:19:42 +0200
Message-ID: <19c7fccabbd37bf413aaacb2bc1fc06b559e4791.1469142756.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35684 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbcGUXT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 19:19:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the __output_custom() routine we currently use with
bpf_skb_copy(). I missed that when len is larger than the size of the
current handle, we can issue multiple invocations of copy_func, and
__output_custom() advances destination but also source buffer by the
written amount of bytes. When we have __output_custom(), this is actually
wrong since in that case the source buffer points to a non-linear object,
in our case an skb, which the copy_func helper is supposed to walk.
Therefore, since this is non-linear we thus need to pass the offset into
the helper, so that copy_func can use it for extracting the data from
the source object.

Therefore, adjust the callback signatures properly and pass offset
into the skb_header_pointer() invoked from bpf_skb_copy() callback. The
__DEFINE_OUTPUT_COPY_BODY() is adjusted to accommodate for two things:
i) to pass in whether we should advance source buffer or not; this is
a compile-time constant condition, ii) to pass in the offset for
__output_custom(), which we do with help of __VA_ARGS__, so everything
can stay inlined as is currently. Both changes allow for adapting the
__output_* fast-path helpers w/o extra overhead.

Fixes: 555c8a8623a3 ("bpf: avoid stack copy and use skb ctx for event output")
Fixes: 7e3f977edd0b ("perf, events: add non-linear data support for raw records")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h        |  2 +-
 include/linux/perf_event.h |  2 +-
 kernel/events/internal.h   | 15 ++++++++++-----
 net/core/filter.c          |  4 ++--
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 36da074..1113423 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -211,7 +211,7 @@ bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *f
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
 typedef unsigned long (*bpf_ctx_copy_t)(void *dst, const void *src,
-					unsigned long len);
+					unsigned long off, unsigned long len);
 
 u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 		     void *ctx, u64 ctx_size, bpf_ctx_copy_t ctx_copy);
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index e79e6c6..15e55b7 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -70,7 +70,7 @@ struct perf_callchain_entry_ctx {
 };
 
 typedef unsigned long (*perf_copy_f)(void *dst, const void *src,
-				     unsigned long len);
+				     unsigned long off, unsigned long len);
 
 struct perf_raw_frag {
 	union {
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 2417eb5..486fd78 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -123,18 +123,19 @@ static inline unsigned long perf_aux_size(struct ring_buffer *rb)
 	return rb->aux_nr_pages << PAGE_SHIFT;
 }
 
-#define __DEFINE_OUTPUT_COPY_BODY(memcpy_func)				\
+#define __DEFINE_OUTPUT_COPY_BODY(advance_buf, memcpy_func, ...)	\
 {									\
 	unsigned long size, written;					\
 									\
 	do {								\
 		size    = min(handle->size, len);			\
-		written = memcpy_func(handle->addr, buf, size);		\
+		written = memcpy_func(__VA_ARGS__);			\
 		written = size - written;				\
 									\
 		len -= written;						\
 		handle->addr += written;				\
-		buf += written;						\
+		if (advance_buf)					\
+			buf += written;					\
 		handle->size -= written;				\
 		if (!handle->size) {					\
 			struct ring_buffer *rb = handle->rb;		\
@@ -153,12 +154,16 @@ static inline unsigned long perf_aux_size(struct ring_buffer *rb)
 static inline unsigned long						\
 func_name(struct perf_output_handle *handle,				\
 	  const void *buf, unsigned long len)				\
-__DEFINE_OUTPUT_COPY_BODY(memcpy_func)
+__DEFINE_OUTPUT_COPY_BODY(true, memcpy_func, handle->addr, buf, size)
 
 static inline unsigned long
 __output_custom(struct perf_output_handle *handle, perf_copy_f copy_func,
 		const void *buf, unsigned long len)
-__DEFINE_OUTPUT_COPY_BODY(copy_func)
+{
+	unsigned long orig_len = len;
+	__DEFINE_OUTPUT_COPY_BODY(false, copy_func, handle->addr, buf,
+				  orig_len - len, size)
+}
 
 static inline unsigned long
 memcpy_common(void *dst, const void *src, unsigned long n)
diff --git a/net/core/filter.c b/net/core/filter.c
index 6c627bc..d15d67a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2026,9 +2026,9 @@ bool bpf_helper_changes_skb_data(void *func)
 }
 
 static unsigned long bpf_skb_copy(void *dst_buff, const void *skb,
-				  unsigned long len)
+				  unsigned long off, unsigned long len)
 {
-	void *ptr = skb_header_pointer(skb, 0, len, dst_buff);
+	void *ptr = skb_header_pointer(skb, off, len, dst_buff);
 
 	if (unlikely(!ptr))
 		return len;
-- 
1.9.3
