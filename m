From: Dave Hansen <haveblue@us.ibm.com>
Subject: [patch] af_packet: use void* for virtual addresses
Date: Fri, 27 Aug 2004 15:22:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C0p77-0004Ik-00@kernel.beaverton.ibm.com>
Cc: netdev@oss.sgi.com, Dave Hansen <haveblue@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've been auditing code, cleaning up warning where code passes
"unsigned long"s to functions and macros that really take pointers.

Here's some explanation as to why I think these types were coded up
this way originally:
http://marc.theaimsgroup.com/?l=linux-mm&m=109155379124628&w=2

The attached patch make packet_opt->pg_vec a pointer to an array of
char*'s instead of a pointer to an array of "unsigned longs" that 
stored virtual addresses.  It also creates the inline function 
pg_vec_endpage(), which hides the virt_to_page() call along with a
little address arithmetic.

One slight oddity in the current code is this:

	pg_vec = kmalloc(req->tp_block_nr*sizeof(unsigned long*), GFP_KERNEL);
	
Since the previous code was storing virtual addresses in unsigned
longs, it was actually trying to allocate an array of *them*, not
of pointers to them.  Not that it matters in the end, but I _think_
that type is technically incorrect.

I replaced it with this line:

	pg_vec = kmalloc(req->tp_block_nr*sizeof(char *), GFP_KERNEL);
	
because I actually want an array of pointers.  

This shouldn't have any functional effect on the code.  I've been
running with it for a few weeks with no problems.

The alternative to reworking the types is to simply cast the argument
to a void* before calling virt_to_page().

Patched against 2.6.9-rc1-mm1 (but should apply to Linus's tree)

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/net/packet/af_packet.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff -puN net/packet/af_packet.c~A0-af_packet_to_voidstar net/packet/af_packet.c
--- memhotplug/net/packet/af_packet.c~A0-af_packet_to_voidstar	2004-08-27 14:06:54.000000000 -0700
+++ memhotplug-dave/net/packet/af_packet.c	2004-08-27 14:06:54.000000000 -0700
@@ -66,6 +66,7 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <asm/page.h>
+#include <asm/io.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/poll.h>
@@ -173,7 +174,7 @@ struct packet_opt
 {
 	struct tpacket_stats	stats;
 #ifdef CONFIG_PACKET_MMAP
-	unsigned long		*pg_vec;
+	char *			*pg_vec;
 	unsigned int		head;
 	unsigned int            frames_per_block;
 	unsigned int		frame_size;
@@ -198,15 +199,15 @@ struct packet_opt
 
 #ifdef CONFIG_PACKET_MMAP
 
-static inline unsigned long packet_lookup_frame(struct packet_opt *po, unsigned int position)
+static inline char *packet_lookup_frame(struct packet_opt *po, unsigned int position)
 {
 	unsigned int pg_vec_pos, frame_offset;
-	unsigned long frame;
+	char *frame;
 
 	pg_vec_pos = position / po->frames_per_block;
 	frame_offset = position % po->frames_per_block;
 
-	frame = (unsigned long) (po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size));
+	frame = po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size);
 	
 	return frame;
 }
@@ -1549,7 +1550,12 @@ static struct vm_operations_struct packe
 	.close =packet_mm_close,
 };
 
-static void free_pg_vec(unsigned long *pg_vec, unsigned order, unsigned len)
+static inline struct page *pg_vec_endpage(char *one_pg_vec, unsigned int order)
+{
+	return virt_to_page(one_pg_vec + (PAGE_SIZE << order) - 1);
+}
+
+static void free_pg_vec(char **pg_vec, unsigned order, unsigned len)
 {
 	int i;
 
@@ -1557,10 +1563,10 @@ static void free_pg_vec(unsigned long *p
 		if (pg_vec[i]) {
 			struct page *page, *pend;
 
-			pend = virt_to_page(pg_vec[i] + (PAGE_SIZE << order) - 1);
+			pend = pg_vec_endpage(pg_vec[i], order);
 			for (page = virt_to_page(pg_vec[i]); page <= pend; page++)
 				ClearPageReserved(page);
-			free_pages(pg_vec[i], order);
+			free_pages((unsigned long)pg_vec[i], order);
 		}
 	}
 	kfree(pg_vec);
@@ -1569,7 +1575,7 @@ static void free_pg_vec(unsigned long *p
 
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing)
 {
-	unsigned long *pg_vec = NULL;
+	char **pg_vec = NULL;
 	struct packet_opt *po = pkt_sk(sk);
 	int was_running, num, order = 0;
 	int err = 0;
@@ -1604,18 +1610,18 @@ static int packet_set_ring(struct sock *
 
 		err = -ENOMEM;
 
-		pg_vec = kmalloc(req->tp_block_nr*sizeof(unsigned long*), GFP_KERNEL);
+		pg_vec = kmalloc(req->tp_block_nr*sizeof(char *), GFP_KERNEL);
 		if (pg_vec == NULL)
 			goto out;
-		memset(pg_vec, 0, req->tp_block_nr*sizeof(unsigned long*));
+		memset(pg_vec, 0, req->tp_block_nr*sizeof(char **));
 
 		for (i=0; i<req->tp_block_nr; i++) {
 			struct page *page, *pend;
-			pg_vec[i] = __get_free_pages(GFP_KERNEL, order);
+			pg_vec[i] = (char *)__get_free_pages(GFP_KERNEL, order);
 			if (!pg_vec[i])
 				goto out_free_pgvec;
 
-			pend = virt_to_page(pg_vec[i] + (PAGE_SIZE << order) - 1);
+			pend = pg_vec_endpage(pg_vec[i], order);
 			for (page = virt_to_page(pg_vec[i]); page <= pend; page++)
 				SetPageReserved(page);
 		}
@@ -1623,7 +1629,7 @@ static int packet_set_ring(struct sock *
 
 		l = 0;
 		for (i=0; i<req->tp_block_nr; i++) {
-			unsigned long ptr = pg_vec[i];
+			char *ptr = pg_vec[i];
 			struct tpacket_hdr *header;
 			int k;
 
_
