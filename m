From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 24/26] nfsd: Use shash
Date: Sun, 24 Jan 2016 21:20:02 +0800
Message-ID: <E1aNKaI-0008GJ-Fn@gondolin.me.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 netdev@vger.kernel.org, devel@driverdev.osuosl.org, dm-devel@redhat.com,
 linux-wireless@vger.kernel.org, linux-cifs@vger.kernel.org,
 ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
 keyrings@vger.kernel.org, linux-bluetooth@vger.kernel.org,
 ceph-devel@vger.kernel.org, linux-wpan@vger.kernel.org,
 linux-afs@lists.infradead.org, drbd-dev@lists.linbit.com,
 open-iscsi@googlegroups.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This patch replaces uses of the long obsolete hash interface with
shash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/nfsd/nfs4recover.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 79f0307..a79c150 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -32,10 +32,10 @@
 *
 */
 
+#include <crypto/hash.h>
 #include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
-#include <linux/crypto.h>
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/module.h>
@@ -104,29 +104,35 @@ static int
 nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
 {
 	struct xdr_netobj cksum;
-	struct hash_desc desc;
-	struct scatterlist sg;
+	struct crypto_shash *tfm;
 	int status;
 
 	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
 			clname->len, clname->data);
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
-	desc.tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc.tfm)) {
-		status = PTR_ERR(desc.tfm);
+	tfm = crypto_alloc_shash("md5", 0, 0);
+	if (IS_ERR(tfm)) {
+		status = PTR_ERR(tfm);
 		goto out_no_tfm;
 	}
 
-	cksum.len = crypto_hash_digestsize(desc.tfm);
+	cksum.len = crypto_shash_digestsize(tfm);
 	cksum.data = kmalloc(cksum.len, GFP_KERNEL);
 	if (cksum.data == NULL) {
 		status = -ENOMEM;
  		goto out;
 	}
 
-	sg_init_one(&sg, clname->data, clname->len);
+	{
+		SHASH_DESC_ON_STACK(desc, tfm);
+
+		desc->tfm = tfm;
+		desc->flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+		status = crypto_shash_digest(desc, clname->data, clname->len,
+					     cksum.data);
+		shash_desc_zero(desc);
+	}
 
-	status = crypto_hash_digest(&desc, &sg, sg.length, cksum.data);
 	if (status)
 		goto out;
 
@@ -135,7 +141,7 @@ nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
 	status = 0;
 out:
 	kfree(cksum.data);
-	crypto_free_hash(desc.tfm);
+	crypto_free_shash(tfm);
 out_no_tfm:
 	return status;
 }
