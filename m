From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/16] [CRYPTO] scatterwalk: Prepare for block ciphers
Date: Sun, 13 Aug 2006 22:20:05 +1000
Message-ID: <E1GCEwn-0004fx-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6921 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751051AbWHMMUI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:08 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] scatterwalk: Prepare for block ciphers

This patch prepares the scatterwalk code for use by the new block cipher
type.

Firstly it halves the size of scatter_walk on 32-bit platforms.  This
is important as we allocate at least two of these objects on the stack
for each block cipher operation.

It also exports the symbols since the block cipher code can be built as
a module.

Finally there is a hack in scatterwalk_unmap that relies on progress
being made.  Unfortunately, for hardware crypto we can't guarantee
progress to be made since the hardware can fail.

So this also gets rid of the hack by not advancing the address returned
by scatterwalk_map.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/cipher.c         |   27 +++++++-------
 crypto/scatterwalk.c    |   89 +++++++++++++++++++++---------------------------
 crypto/scatterwalk.h    |   48 +++++++++++++++----------
 include/crypto/algapi.h |    5 ++
 4 files changed, 87 insertions(+), 82 deletions(-)

diff --git a/crypto/cipher.c b/crypto/cipher.c
--- a/crypto/cipher.c
+++ b/crypto/cipher.c
@@ -45,15 +45,10 @@ static unsigned int crypt_slow(const str
 	u8 buffer[bsize * 2 + alignmask];
 	u8 *src = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	u8 *dst = src + bsize;
-	unsigned int n;
-
-	n = scatterwalk_copychunks(src, in, bsize, 0);
-	scatterwalk_advance(in, n);
 
+	scatterwalk_copychunks(src, in, bsize, 0);
 	desc->prfn(desc, dst, src, bsize);
-
-	n = scatterwalk_copychunks(dst, out, bsize, 1);
-	scatterwalk_advance(out, n);
+	scatterwalk_copychunks(dst, out, bsize, 1);
 
 	return bsize;
 }
@@ -64,12 +59,16 @@ static inline unsigned int crypt_fast(co
 				      unsigned int nbytes, u8 *tmp)
 {
 	u8 *src, *dst;
+	u8 *real_src, *real_dst;
+
+	real_src = scatterwalk_map(in, 0);
+	real_dst = scatterwalk_map(out, 1);
 
-	src = in->data;
-	dst = scatterwalk_samebuf(in, out) ? src : out->data;
+	src = real_src;
+	dst = scatterwalk_samebuf(in, out) ? src : real_dst;
 
 	if (tmp) {
-		memcpy(tmp, in->data, nbytes);
+		memcpy(tmp, src, nbytes);
 		src = tmp;
 		dst = tmp;
 	}
@@ -77,7 +76,10 @@ static inline unsigned int crypt_fast(co
 	nbytes = desc->prfn(desc, dst, src, nbytes);
 
 	if (tmp)
-		memcpy(out->data, tmp, nbytes);
+		memcpy(real_dst, tmp, nbytes);
+
+	scatterwalk_unmap(real_src, 0);
+	scatterwalk_unmap(real_dst, 1);
 
 	scatterwalk_advance(in, nbytes);
 	scatterwalk_advance(out, nbytes);
@@ -126,9 +128,6 @@ static int crypt(const struct cipher_des
 			tmp = (u8 *)buffer;
 		}
 
-		scatterwalk_map(&walk_in, 0);
-		scatterwalk_map(&walk_out, 1);
-
 		n = scatterwalk_clamp(&walk_in, n);
 		n = scatterwalk_clamp(&walk_out, n);
 
diff --git a/crypto/scatterwalk.c b/crypto/scatterwalk.c
--- a/crypto/scatterwalk.c
+++ b/crypto/scatterwalk.c
@@ -15,9 +15,11 @@
  */
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>
-#include <asm/scatterlist.h>
+#include <linux/scatterlist.h>
+
 #include "internal.h"
 #include "scatterwalk.h"
 
@@ -27,88 +29,77 @@ enum km_type crypto_km_types[] = {
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
 };
+EXPORT_SYMBOL_GPL(crypto_km_types);
 
-static void memcpy_dir(void *buf, void *sgdata, size_t nbytes, int out)
+static inline void memcpy_dir(void *buf, void *sgdata, size_t nbytes, int out)
 {
-	if (out)
-		memcpy(sgdata, buf, nbytes);
-	else
-		memcpy(buf, sgdata, nbytes);
+	void *src = out ? buf : sgdata;
+	void *dst = out ? sgdata : buf;
+
+	memcpy(dst, src, nbytes);
 }
 
 void scatterwalk_start(struct scatter_walk *walk, struct scatterlist *sg)
 {
-	unsigned int rest_of_page;
-
 	walk->sg = sg;
 
-	walk->page = sg->page;
-	walk->len_this_segment = sg->length;
-
 	BUG_ON(!sg->length);
 
-	rest_of_page = PAGE_CACHE_SIZE - (sg->offset & (PAGE_CACHE_SIZE - 1));
-	walk->len_this_page = min(sg->length, rest_of_page);
 	walk->offset = sg->offset;
 }
+EXPORT_SYMBOL_GPL(scatterwalk_start);
 
-void scatterwalk_map(struct scatter_walk *walk, int out)
-{
-	walk->data = crypto_kmap(walk->page, out) + walk->offset;
-}
-
-static inline void scatterwalk_unmap(struct scatter_walk *walk, int out)
+void *scatterwalk_map(struct scatter_walk *walk, int out)
 {
-	/* walk->data may be pointing the first byte of the next page;
-	   however, we know we transfered at least one byte.  So,
-	   walk->data - 1 will be a virtual address in the mapped page. */
-	crypto_kunmap(walk->data - 1, out);
+	return crypto_kmap(scatterwalk_page(walk), out) +
+	       offset_in_page(walk->offset);
 }
+EXPORT_SYMBOL_GPL(scatterwalk_map);
 
 static void scatterwalk_pagedone(struct scatter_walk *walk, int out,
 				 unsigned int more)
 {
 	if (out)
-		flush_dcache_page(walk->page);
+		flush_dcache_page(scatterwalk_page(walk));
 
 	if (more) {
-		walk->len_this_segment -= walk->len_this_page;
-
-		if (walk->len_this_segment) {
-			walk->page++;
-			walk->len_this_page = min(walk->len_this_segment,
-						  (unsigned)PAGE_CACHE_SIZE);
-			walk->offset = 0;
-		}
-		else
+		walk->offset += PAGE_SIZE - 1;
+		walk->offset &= PAGE_MASK;
+		if (walk->offset >= walk->sg->offset + walk->sg->length)
 			scatterwalk_start(walk, sg_next(walk->sg));
 	}
 }
 
 void scatterwalk_done(struct scatter_walk *walk, int out, int more)
 {
-	scatterwalk_unmap(walk, out);
-	if (walk->len_this_page == 0 || !more)
+	if (!offset_in_page(walk->offset) || !more)
 		scatterwalk_pagedone(walk, out, more);
 }
+EXPORT_SYMBOL_GPL(scatterwalk_done);
 
-/*
- * Do not call this unless the total length of all of the fragments
- * has been verified as multiple of the block size.
- */
-int scatterwalk_copychunks(void *buf, struct scatter_walk *walk,
-			   size_t nbytes, int out)
+void scatterwalk_copychunks(void *buf, struct scatter_walk *walk,
+			    size_t nbytes, int out)
 {
-	while (nbytes > walk->len_this_page) {
-		memcpy_dir(buf, walk->data, walk->len_this_page, out);
-		buf += walk->len_this_page;
-		nbytes -= walk->len_this_page;
+	for (;;) {
+		unsigned int len_this_page = scatterwalk_pagelen(walk);
+		u8 *vaddr;
+
+		if (len_this_page > nbytes)
+			len_this_page = nbytes;
+
+		vaddr = scatterwalk_map(walk, out);
+		memcpy_dir(buf, vaddr, len_this_page, out);
+		scatterwalk_unmap(vaddr, out);
+
+		if (nbytes == len_this_page)
+			break;
+
+		buf += len_this_page;
+		nbytes -= len_this_page;
 
-		scatterwalk_unmap(walk, out);
 		scatterwalk_pagedone(walk, out, 1);
-		scatterwalk_map(walk, out);
 	}
 
-	memcpy_dir(buf, walk->data, nbytes, out);
-	return nbytes;
+	scatterwalk_advance(walk, nbytes);
 }
+EXPORT_SYMBOL_GPL(scatterwalk_copychunks);
diff --git a/crypto/scatterwalk.h b/crypto/scatterwalk.h
--- a/crypto/scatterwalk.h
+++ b/crypto/scatterwalk.h
@@ -14,17 +14,11 @@
 
 #ifndef _CRYPTO_SCATTERWALK_H
 #define _CRYPTO_SCATTERWALK_H
+
 #include <linux/mm.h>
-#include <asm/scatterlist.h>
+#include <linux/scatterlist.h>
 
-struct scatter_walk {
-	struct scatterlist	*sg;
-	struct page		*page;
-	void			*data;
-	unsigned int		len_this_page;
-	unsigned int		len_this_segment;
-	unsigned int		offset;
-};
+#include "internal.h"
 
 /* Define sg_next is an inline routine now in case we want to change
    scatterlist to a linked list later. */
@@ -33,26 +27,31 @@ static inline struct scatterlist *sg_nex
 	return sg + 1;
 }
 
-static inline int scatterwalk_samebuf(struct scatter_walk *walk_in,
-				      struct scatter_walk *walk_out)
+static inline unsigned long scatterwalk_samebuf(struct scatter_walk *walk_in,
+						struct scatter_walk *walk_out)
 {
-	return walk_in->page == walk_out->page &&
-	       walk_in->offset == walk_out->offset;
+	return !(((walk_in->sg->page - walk_out->sg->page) << PAGE_SHIFT) +
+		 (int)(walk_in->offset - walk_out->offset));
+}
+
+static inline unsigned int scatterwalk_pagelen(struct scatter_walk *walk)
+{
+	unsigned int len = walk->sg->offset + walk->sg->length - walk->offset;
+	unsigned int len_this_page = offset_in_page(~walk->offset) + 1;
+	return len_this_page > len ? len : len_this_page;
 }
 
 static inline unsigned int scatterwalk_clamp(struct scatter_walk *walk,
 					     unsigned int nbytes)
 {
-	return nbytes > walk->len_this_page ? walk->len_this_page : nbytes;
+	unsigned int len_this_page = scatterwalk_pagelen(walk);
+	return nbytes > len_this_page ? len_this_page : nbytes;
 }
 
 static inline void scatterwalk_advance(struct scatter_walk *walk,
 				       unsigned int nbytes)
 {
-	walk->data += nbytes;
 	walk->offset += nbytes;
-	walk->len_this_page -= nbytes;
-	walk->len_this_segment -= nbytes;
 }
 
 static inline unsigned int scatterwalk_aligned(struct scatter_walk *walk,
@@ -61,9 +60,20 @@ static inline unsigned int scatterwalk_a
 	return !(walk->offset & alignmask);
 }
 
+static inline struct page *scatterwalk_page(struct scatter_walk *walk)
+{
+	return walk->sg->page + (walk->offset >> PAGE_SHIFT);
+}
+
+static inline void scatterwalk_unmap(void *vaddr, int out)
+{
+	crypto_kunmap(vaddr, out);
+}
+
 void scatterwalk_start(struct scatter_walk *walk, struct scatterlist *sg);
-int scatterwalk_copychunks(void *buf, struct scatter_walk *walk, size_t nbytes, int out);
-void scatterwalk_map(struct scatter_walk *walk, int out);
+void scatterwalk_copychunks(void *buf, struct scatter_walk *walk,
+			    size_t nbytes, int out);
+void *scatterwalk_map(struct scatter_walk *walk, int out);
 void scatterwalk_done(struct scatter_walk *walk, int out, int more);
 
 #endif  /* _CRYPTO_SCATTERWALK_H */
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -48,6 +48,11 @@ struct crypto_spawn {
 	struct crypto_instance *inst;
 };
 
+struct scatter_walk {
+	struct scatterlist *sg;
+	unsigned int offset;
+};
+
 int crypto_register_template(struct crypto_template *tmpl);
 void crypto_unregister_template(struct crypto_template *tmpl);
 struct crypto_template *crypto_lookup_template(const char *name);
