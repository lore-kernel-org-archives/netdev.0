From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH 2/3] crypto: af_alg - Allow to link sgl
Date: Thu, 29 Jan 2015 15:13:51 -0800
Message-ID: <20150129231351.25156.40412.stgit@tstruk-mobl1>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow to link af_alg sgls.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/af_alg.c         |   16 ++++++++++++----
 include/crypto/if_alg.h |    4 +++-
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 76d739d..99608f2 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -374,7 +374,8 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
 
 	err = 0;
 
-	sg_init_table(sgl->sg, npages);
+	/* Add one extra for linking */
+	sg_init_table(sgl->sg, npages + 1);
 
 	for (i = 0; i < npages; i++) {
 		int plen = min_t(int, len, PAGE_SIZE - off);
@@ -385,20 +386,27 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
 		len -= plen;
 		err += plen;
 	}
+	sg_mark_end(sgl->sg + npages - 1);
+	sgl->npages = npages;
 
 out:
 	return err;
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
index 5c7b6c5..0908050 100644
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
@@ -71,6 +72,7 @@ int af_alg_accept(struct sock *sk, struct socket *newsock);
 int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
 		   int write);
 void af_alg_free_sg(struct af_alg_sgl *sgl);
+void af_alg_link_sg(struct af_alg_sgl *sgl_prev, struct af_alg_sgl *sgl_new);
 
 int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con);
 
