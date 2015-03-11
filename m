From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH RFC 3/4] crypto: af_alg - Allow to link sgl
Date: Wed, 11 Mar 2015 15:46:23 -0700
Message-ID: <20150311224623.23777.14681.stgit@tstruk-mobl1>
References: <20150311224607.23777.2181.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501AbbCKWsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 18:48:55 -0400
In-Reply-To: <20150311224607.23777.2181.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadeusz Struk <tadeusz.struk@intel.com>

Allow to link af_alg sgls.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/af_alg.c         |   18 +++++++++++++-----
 include/crypto/if_alg.h |    4 +++-
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 7f8b7edc..26089d1 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -358,8 +358,8 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
 	npages = (off + n + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (WARN_ON(npages == 0))
 		return -EINVAL;
-
-	sg_init_table(sgl->sg, npages);
+	/* Add one extra for linking */
+	sg_init_table(sgl->sg, npages + 1);
 
 	for (i = 0, len = n; i < npages; i++) {
 		int plen = min_t(int, len, PAGE_SIZE - off);
@@ -369,18 +369,26 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
 		off = 0;
 		len -= plen;
 	}
+	sg_mark_end(sgl->sg + npages - 1);
+	sgl->npages = npages;
+
 	return n;
 }
 EXPORT_SYMBOL_GPL(af_alg_make_sg);
 
+void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new)
+{
+	sg_unmark_end(sgl_prev->sg + sgl_prev->npages - 1);
+	sg_chain(sgl_prev->sg, sgl_prev->npages + 1, sgl_new->sg);
+}
+EXPORT_SYMBOL(af_alg_link_sg);
+
 void af_alg_free_sg(struct af_alg_sgl *sgl)
 {
 	int i;
 
-	i = 0;
-	do {
+	for (i = 0; i < sgl->npages; i++)
 		put_page(sgl->pages[i]);
-	} while (!sg_is_last(sgl->sg + (i++)));
 }
 EXPORT_SYMBOL_GPL(af_alg_free_sg);
 
diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
index 178525e..018afb2 100644
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -58,8 +58,9 @@ struct af_alg_type {
 };
 
 struct af_alg_sgl {
-	struct scatterlist sg[ALG_MAX_PAGES];
+	struct scatterlist sg[ALG_MAX_PAGES + 1];
 	struct page *pages[ALG_MAX_PAGES];
+	unsigned int npages;
 };
 
 int af_alg_register_type(const struct af_alg_type *type);
@@ -70,6 +71,7 @@ int af_alg_accept(struct sock *sk, struct socket *newsock);
 
 int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len);
 void af_alg_free_sg(struct af_alg_sgl *sgl);
+void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new);
 
 int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con);
 
