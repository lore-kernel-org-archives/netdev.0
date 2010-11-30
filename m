From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] af_packet: replace struct pgv with char **
Date: Tue, 30 Nov 2010 21:57:37 +0800
Message-ID: <1291125457-14427-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55387 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab0K3N6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 08:58:17 -0500
Received: by gyb11 with SMTP id 11so2693861gyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 05:58:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we can check if an address is vmalloc address with is_vmalloc_addr(),
we can replace struct pgv with char **. Then we may get more pg_vecs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/packet/af_packet.c |   50 ++++++++++++++++---------------------------------
 1 file changed, 17 insertions(+), 33 deletions(-)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0171b20..a26f981 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -164,14 +164,8 @@ struct packet_mreq_max {
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);
 
-#define PGV_FROM_VMALLOC 1
-struct pgv {
-	char *buffer;
-	unsigned char flags;
-};
-
 struct packet_ring_buffer {
-	struct pgv		*pg_vec;
+	char			**pg_vec;
 	unsigned int		head;
 	unsigned int		frames_per_block;
 	unsigned int		frame_size;
@@ -297,8 +291,7 @@ static void *packet_lookup_frame(struct packet_sock *po,
 	pg_vec_pos = position / rb->frames_per_block;
 	frame_offset = position % rb->frames_per_block;
 
-	h.raw = rb->pg_vec[pg_vec_pos].buffer +
-		(frame_offset * rb->frame_size);
+	h.raw = rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size);
 
 	if (status != __packet_get_status(po, h.raw))
 		return NULL;
@@ -2340,26 +2333,24 @@ static const struct vm_operations_struct packet_mmap_ops = {
 	.close	=	packet_mm_close,
 };
 
-static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
-			unsigned int len)
+static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
 {
 	int i;
 
 	for (i = 0; i < len; i++) {
-		if (likely(pg_vec[i].buffer)) {
-			if (pg_vec[i].flags & PGV_FROM_VMALLOC)
-				vfree(pg_vec[i].buffer);
+		if (likely(pg_vec[i])) {
+			if (is_vmalloc_addr(pg_vec[i]))
+				vfree(pg_vec[i]);
 			else
-				free_pages((unsigned long)pg_vec[i].buffer,
+				free_pages((unsigned long)pg_vec[i],
 					   order);
-			pg_vec[i].buffer = NULL;
+			pg_vec[i] = NULL;
 		}
 	}
 	kfree(pg_vec);
 }
 
-static inline char *alloc_one_pg_vec_page(unsigned long order,
-					  unsigned char *flags)
+static inline char *alloc_one_pg_vec_page(unsigned long order)
 {
 	char *buffer = NULL;
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP |
@@ -2373,7 +2364,6 @@ static inline char *alloc_one_pg_vec_page(unsigned long order,
 	/*
 	 * __get_free_pages failed, fall back to vmalloc
 	 */
-	*flags |= PGV_FROM_VMALLOC;
 	buffer = vzalloc((1 << order) * PAGE_SIZE);
 
 	if (buffer)
@@ -2382,7 +2372,6 @@ static inline char *alloc_one_pg_vec_page(unsigned long order,
 	/*
 	 * vmalloc failed, lets dig into swap here
 	 */
-	*flags = 0;
 	gfp_flags &= ~__GFP_NORETRY;
 	buffer = (char *)__get_free_pages(gfp_flags, order);
 	if (buffer)
@@ -2394,20 +2383,19 @@ static inline char *alloc_one_pg_vec_page(unsigned long order,
 	return NULL;
 }
 
-static struct pgv *alloc_pg_vec(struct tpacket_req *req, int order)
+static char **alloc_pg_vec(struct tpacket_req *req, int order)
 {
 	unsigned int block_nr = req->tp_block_nr;
-	struct pgv *pg_vec;
+	char **pg_vec;
 	int i;
 
-	pg_vec = kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);
+	pg_vec = kcalloc(block_nr, sizeof(char *), GFP_KERNEL);
 	if (unlikely(!pg_vec))
 		goto out;
 
 	for (i = 0; i < block_nr; i++) {
-		pg_vec[i].buffer = alloc_one_pg_vec_page(order,
-							 &pg_vec[i].flags);
-		if (unlikely(!pg_vec[i].buffer))
+		pg_vec[i] = alloc_one_pg_vec_page(order);
+		if (unlikely(!pg_vec[i]))
 			goto out_free_pgvec;
 	}
 
@@ -2424,7 +2412,7 @@ out_free_pgvec:
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring)
 {
-	struct pgv *pg_vec = NULL;
+	char **pg_vec = NULL;
 	struct packet_sock *po = pkt_sk(sk);
 	int was_running, order = 0;
 	struct packet_ring_buffer *rb;
@@ -2587,16 +2575,12 @@ static int packet_mmap(struct file *file, struct socket *sock,
 
 		for (i = 0; i < rb->pg_vec_len; i++) {
 			struct page *page;
-			void *kaddr = rb->pg_vec[i].buffer;
+			void *kaddr = rb->pg_vec[i];
 			int pg_num;
 
 			for (pg_num = 0; pg_num < rb->pg_vec_pages;
 					pg_num++) {
-				if (rb->pg_vec[i].flags & PGV_FROM_VMALLOC)
-					page = vmalloc_to_page(kaddr);
-				else
-					page = virt_to_page(kaddr);
-
+				page = pgv_to_page(kaddr);
 				err = vm_insert_page(vma, start, page);
 				if (unlikely(err))
 					goto out;
