From: nhorman@tuxdriver.com
Subject: [PATCH] Enhance AF_PACKET implementation to not require high order contiguous memory allocation
Date: Mon, 25 Oct 2010 15:06:06 -0400
Message-ID: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jpirko@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37525 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932760Ab0JYTG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:06:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

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

So instead I've done this.  This patch does the aforementioned change,
allocating an array of pages instead of one contiguous chunk, and then vmaps the
array into a contiguous memory space, so that it can still be accessed in the
same way it was before.  This allows for a consisten user and kernel space
behavior for memory mapped AF_PACKET sockets, which at the same time relieving
the memory pressure placed on a system when tcpdump defaults are used.

Tested successfully by me.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/packet/af_packet.c |   94 +++++++++++++++++++++++++++++++++++++----------
 1 files changed, 74 insertions(+), 20 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3616f27..fad3891 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -163,8 +163,14 @@ struct packet_mreq_max {
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);
 
+struct pkt_page_list {
+	unsigned int num_pages;
+	char	*vmap_area;
+	unsigned long pages[0];
+};
+
 struct packet_ring_buffer {
-	char			**pg_vec;
+	struct pkt_page_list	**pg_vec;
 	unsigned int		head;
 	unsigned int		frames_per_block;
 	unsigned int		frame_size;
@@ -283,7 +289,8 @@ static void *packet_lookup_frame(struct packet_sock *po,
 	pg_vec_pos = position / rb->frames_per_block;
 	frame_offset = position % rb->frames_per_block;
 
-	h.raw = rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size);
+	h.raw = rb->pg_vec[pg_vec_pos]->vmap_area +
+		(frame_offset * rb->frame_size);
 
 	if (status != __packet_get_status(po, h.raw))
 		return NULL;
@@ -2322,41 +2329,86 @@ static const struct vm_operations_struct packet_mmap_ops = {
 	.close	=	packet_mm_close,
 };
 
-static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
+static void free_one_pkt_list(struct pkt_page_list *pglist)
+{
+	int i;
+
+	if ((pglist->num_pages > 1) && (pglist->vmap_area))
+		vunmap(pglist->vmap_area);
+	for (i = 0; i < pglist->num_pages; i++)
+		free_pages(pglist->pages[i], 0);
+}
+
+static void free_pg_vec(struct pkt_page_list **pg_vec, unsigned int order,
+			unsigned int len)
 {
 	int i;
 
-	for (i = 0; i < len; i++) {
+	for (i = 0; i < len; i++)
 		if (likely(pg_vec[i]))
-			free_pages((unsigned long) pg_vec[i], order);
-	}
+			free_one_pkt_list(pg_vec[i]);
+
 	kfree(pg_vec);
 }
 
-static inline char *alloc_one_pg_vec_page(unsigned long order)
+static inline struct pkt_page_list *alloc_one_pg_page_list(unsigned long order)
 {
+	int i;
+	struct pkt_page_list *newlist;
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP | __GFP_ZERO | __GFP_NOWARN;
 
-	return (char *) __get_free_pages(gfp_flags, order);
+
+	newlist = kzalloc(sizeof(struct pkt_page_list)+
+			  (sizeof(void *)*(1<<order)), GFP_KERNEL);
+	if (!newlist)
+		return NULL;
+	newlist->num_pages = (1<<order);
+
+	for (i = 0; i < newlist->num_pages; i++) {
+		newlist->pages[i] = __get_free_pages(gfp_flags, 0);
+		if (!newlist->pages[i])
+			goto out_free;
+	}
+
+	return newlist;
+out_free:
+	free_one_pkt_list(newlist);
+	kfree(newlist);
+	return NULL;
 }
 
-static char **alloc_pg_vec(struct tpacket_req *req, int order)
+static struct pkt_page_list **alloc_pg_vec(struct tpacket_req *req, int order)
 {
 	unsigned int block_nr = req->tp_block_nr;
-	char **pg_vec;
-	int i;
+	struct pkt_page_list **pg_vec;
+	struct page **pages;
+	int i, j;
 
-	pg_vec = kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
-	if (unlikely(!pg_vec))
+	pg_vec = kzalloc(block_nr * sizeof(struct pkt_page_list *), GFP_KERNEL);
+	pages = kzalloc(block_nr * sizeof(struct page *), GFP_KERNEL);
+
+	if (unlikely(!pg_vec || !pages))
 		goto out;
 
 	for (i = 0; i < block_nr; i++) {
-		pg_vec[i] = alloc_one_pg_vec_page(order);
-		if (unlikely(!pg_vec[i]))
-			goto out_free_pgvec;
+		pg_vec[i] = alloc_one_pg_page_list(order);
+
+		if (order > 0) {
+			for (j = 0; j < pg_vec[i]->num_pages; j++)
+				pages[j] = virt_to_page(pg_vec[i]->pages[j]);
+
+			if (unlikely(!pg_vec[i]))
+				goto out_free_pgvec;
+			pg_vec[i]->vmap_area = vmap(pages, pg_vec[i]->num_pages,
+						 VM_MAP, PAGE_KERNEL);
+			if (!pg_vec[i]->vmap_area)
+				goto out_free_pgvec;
+		} else
+			pg_vec[i]->vmap_area = (void *)pg_vec[i]->pages[0];
 	}
 
 out:
+	kfree(pages);
 	return pg_vec;
 
 out_free_pgvec:
@@ -2368,7 +2420,7 @@ out_free_pgvec:
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring)
 {
-	char **pg_vec = NULL;
+	struct pkt_page_list **pg_vec = NULL;
 	struct packet_sock *po = pkt_sk(sk);
 	int was_running, order = 0;
 	struct packet_ring_buffer *rb;
@@ -2530,11 +2582,13 @@ static int packet_mmap(struct file *file, struct socket *sock,
 			continue;
 
 		for (i = 0; i < rb->pg_vec_len; i++) {
-			struct page *page = virt_to_page(rb->pg_vec[i]);
+			struct pkt_page_list *plist = rb->pg_vec[i];
 			int pg_num;
+			struct page *page;
 
-			for (pg_num = 0; pg_num < rb->pg_vec_pages;
-					pg_num++, page++) {
+			for (pg_num = 0; pg_num < plist->num_pages;
+					pg_num++) {
+				page = virt_to_page(plist->pages[pg_num]);
 				err = vm_insert_page(vma, start, page);
 				if (unlikely(err))
 					goto out;
-- 
1.7.2.3

