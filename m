From: nhorman@tuxdriver.com
Subject: [PATCH] Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v2)
Date: Tue,  9 Nov 2010 12:46:39 -0500
Message-ID: <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38620 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab0KIRrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 12:47:11 -0500
In-Reply-To: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

Version 2 of this patch.  Sorry its been awhile, but I've had other issues come
up.  I've re-written this patch taking into account the change notes from the
last round

Change notes:
1) Rewrote the patch to not do all my previous stupid vmaps on single page
arrays.  Instead we just use vmalloc now.

2) Checked into the behavior of tcpdump on high order allocations in the failing
case.  Tcpdump (more specifically I think libpcap) does attempt to minimize the
allocation order on the ring buffer, unfortunately the lowest it will push the
ordrer too given a sufficiently large buffer is order 5, so its still a very
large contiguous allocation, and that says nothing of other malicious
applications that might try to do more.

Summary:
It was shown to me recently that systems under high load were driven very deep
into swap when tcpdump was run.  The reason this happened was because the
AF_PACKET protocol has a SET_RINGBUFFER socket option that allows the user space
application to specify how many entries an AF_PACKET socket will have and how
large each entry will be.  It seems the default setting for tcpdump is to set
the ring buffer to 32 entries of 64 Kb each, which implies 32 order 5
allocation.  Thats difficult under good circumstances, and horrid under memory
pressure.

I thought it would be good to make that a bit more usable.  I was going to do a
simple conversion of the ring buffer from contigous pages to iovecs, but
unfortunately, the metadata which AF_PACKET places in these buffers can easily
span a page boundary, and given that these buffers get mapped into user space,
and the data layout doesn't easily allow for a change to padding between frames
to avoid that, a simple iovec change is just going to break user space ABI
consistency.

So I've done this, I've added a three tiered mechanism to the af_packet set_ring
socket option.  It attempts to allocate memory in the following order:

1) Using __get_free_pages with GFP_NORETRY set, so as to fail quickly without
digging into swap

2) Using vmalloc

3) Using __get_free_pages with GFP_NORETRY clear, causing us to try as hard as
needed to get the memory

The effect is that we don't disturb the system as much when we're under load,
while still being able to conduct tcpdumps effectively.

Tested successfully by me.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/packet/af_packet.c |   84 ++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 68 insertions(+), 16 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3616f27..d1148ac 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -163,8 +163,14 @@ struct packet_mreq_max {
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);
 
+#define PGV_FROM_VMALLOC 1
+struct pgv {
+	char *buffer;
+	unsigned char flags;
+};
+
 struct packet_ring_buffer {
-	char			**pg_vec;
+	struct pgv		*pg_vec;
 	unsigned int		head;
 	unsigned int		frames_per_block;
 	unsigned int		frame_size;
@@ -283,7 +289,8 @@ static void *packet_lookup_frame(struct packet_sock *po,
 	pg_vec_pos = position / rb->frames_per_block;
 	frame_offset = position % rb->frames_per_block;
 
-	h.raw = rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size);
+	h.raw = rb->pg_vec[pg_vec_pos].buffer +
+		(frame_offset * rb->frame_size);
 
 	if (status != __packet_get_status(po, h.raw))
 		return NULL;
@@ -2322,37 +2329,74 @@ static const struct vm_operations_struct packet_mmap_ops = {
 	.close	=	packet_mm_close,
 };
 
-static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
+static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
+			unsigned int len)
 {
 	int i;
 
 	for (i = 0; i < len; i++) {
-		if (likely(pg_vec[i]))
-			free_pages((unsigned long) pg_vec[i], order);
+		if (likely(pg_vec[i].buffer)) {
+			if (pg_vec[i].flags & PGV_FROM_VMALLOC)
+				vfree(pg_vec[i].buffer);
+			else
+				free_pages((unsigned long)pg_vec[i].buffer,
+					   order);
+			pg_vec[i].buffer = NULL;
+		}
 	}
 	kfree(pg_vec);
 }
 
-static inline char *alloc_one_pg_vec_page(unsigned long order)
+static inline char *alloc_one_pg_vec_page(unsigned long order,
+					  unsigned char *flags)
 {
-	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP | __GFP_ZERO | __GFP_NOWARN;
+	char *buffer = NULL;
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP |
+			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
+
+	buffer = (char *) __get_free_pages(gfp_flags, order);
+
+	if (buffer)
+		return buffer;
+
+	/*
+	 * __get_free_pages failed, fall back to vmalloc
+	 */
+	*flags |= PGV_FROM_VMALLOC;
+	buffer = vmalloc((1 << order) * PAGE_SIZE);
 
-	return (char *) __get_free_pages(gfp_flags, order);
+	if (buffer)
+		return buffer;
+
+	/*
+	 * vmalloc failed, lets dig into swap here
+	 */
+	*flags = 0;
+	gfp_flags &= ~__GFP_NORETRY;
+	buffer = (char *)__get_free_pages(gfp_flags, order);
+	if (buffer)
+		return buffer;
+
+	/*
+	 * complete and utter failure
+	 */
+	return NULL;
 }
 
-static char **alloc_pg_vec(struct tpacket_req *req, int order)
+static struct pgv *alloc_pg_vec(struct tpacket_req *req, int order)
 {
 	unsigned int block_nr = req->tp_block_nr;
-	char **pg_vec;
+	struct pgv *pg_vec;
 	int i;
 
-	pg_vec = kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
+	pg_vec = kzalloc(block_nr * sizeof(struct pgv), GFP_KERNEL);
 	if (unlikely(!pg_vec))
 		goto out;
 
 	for (i = 0; i < block_nr; i++) {
-		pg_vec[i] = alloc_one_pg_vec_page(order);
-		if (unlikely(!pg_vec[i]))
+		pg_vec[i].buffer = alloc_one_pg_vec_page(order,
+							 &pg_vec[i].flags);
+		if (unlikely(!pg_vec[i].buffer))
 			goto out_free_pgvec;
 	}
 
@@ -2361,6 +2405,7 @@ out:
 
 out_free_pgvec:
 	free_pg_vec(pg_vec, order, block_nr);
+	kfree(pg_vec);
 	pg_vec = NULL;
 	goto out;
 }
@@ -2368,7 +2413,7 @@ out_free_pgvec:
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring)
 {
-	char **pg_vec = NULL;
+	struct pgv *pg_vec = NULL;
 	struct packet_sock *po = pkt_sk(sk);
 	int was_running, order = 0;
 	struct packet_ring_buffer *rb;
@@ -2530,15 +2575,22 @@ static int packet_mmap(struct file *file, struct socket *sock,
 			continue;
 
 		for (i = 0; i < rb->pg_vec_len; i++) {
-			struct page *page = virt_to_page(rb->pg_vec[i]);
+			struct page *page;
+			void *kaddr = rb->pg_vec[i].buffer;
 			int pg_num;
 
 			for (pg_num = 0; pg_num < rb->pg_vec_pages;
-					pg_num++, page++) {
+					pg_num++) {
+				if (rb->pg_vec[i].flags & PGV_FROM_VMALLOC)
+					page = vmalloc_to_page(kaddr);
+				else
+					page = virt_to_page(kaddr);
+
 				err = vm_insert_page(vma, start, page);
 				if (unlikely(err))
 					goto out;
 				start += PAGE_SIZE;
+				kaddr += PAGE_SIZE;
 			}
 		}
 	}
-- 
1.7.2.3

