From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 19/26] ipsec: Use skcipher and ahash when probing algorithms
Date: Sun, 24 Jan 2016 21:19:11 +0800
Message-ID: <E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
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

This patch removes the last reference to hash and ablkcipher from
IPsec and replaces them with ahash and skcipher respectively.  For
skcipher there is currently no difference at all, while for ahash
the current code is actually buggy and would prevent asynchronous
algorithms from being discovered.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_algo.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index f07224d..250e567 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -9,6 +9,8 @@
  * any later version.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
@@ -782,14 +784,13 @@ void xfrm_probe_algs(void)
 	BUG_ON(in_softirq());
 
 	for (i = 0; i < aalg_entries(); i++) {
-		status = crypto_has_hash(aalg_list[i].name, 0,
-					 CRYPTO_ALG_ASYNC);
+		status = crypto_has_ahash(aalg_list[i].name, 0, 0);
 		if (aalg_list[i].available != status)
 			aalg_list[i].available = status;
 	}
 
 	for (i = 0; i < ealg_entries(); i++) {
-		status = crypto_has_ablkcipher(ealg_list[i].name, 0, 0);
+		status = crypto_has_skcipher(ealg_list[i].name, 0, 0);
 		if (ealg_list[i].available != status)
 			ealg_list[i].available = status;
 	}
