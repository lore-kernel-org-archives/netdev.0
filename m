From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/3] xfrm: Modify xfrm_ipcomp code to use new per-cpu helpers
Date: Wed,  7 Dec 2011 12:59:10 -0600
Message-ID: <1323284350-13784-4-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1323284350-13784-1-git-send-email-sjenning@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	Robert Jennings <rcj@linux.vnet.ibm.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323284350-13784-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exchanges the per-cpu transform allocation/free
code in xfrm_ipcomp for a call to the new helper in the
cryptographic API

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 net/xfrm/xfrm_ipcomp.c |   34 ++++++++--------------------------
 1 files changed, 8 insertions(+), 26 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index e5246fb..d681fbd 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -245,7 +245,6 @@ static void * __percpu *ipcomp_alloc_scratches(void)
 static void ipcomp_free_tfms(struct crypto_comp * __percpu *tfms)
 {
 	struct ipcomp_tfms *pos;
-	int cpu;
 
 	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
 		if (pos->tfms == tfms)
@@ -259,15 +258,7 @@ static void ipcomp_free_tfms(struct crypto_comp * __percpu *tfms)
 
 	list_del(&pos->list);
 	kfree(pos);
-
-	if (!tfms)
-		return;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = *per_cpu_ptr(tfms, cpu);
-		crypto_free_comp(tfm);
-	}
-	free_percpu(tfms);
+	crypto_free_percpu_comp(tfms, cpu_possible_mask);
 }
 
 static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
@@ -295,27 +286,18 @@ static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
 	if (!pos)
 		return NULL;
 
+	tfms = crypto_alloc_percpu_comp(alg_name, 0, CRYPTO_ALG_ASYNC,
+					cpu_possible_mask);
+	if (IS_ERR_VALUE((unsigned long)tfms)) {
+		kfree(pos);
+		return NULL;
+	}
+
 	pos->users = 1;
 	INIT_LIST_HEAD(&pos->list);
 	list_add(&pos->list, &ipcomp_tfms_list);
 
-	pos->tfms = tfms = alloc_percpu(struct crypto_comp *);
-	if (!tfms)
-		goto error;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
-							    CRYPTO_ALG_ASYNC);
-		if (IS_ERR(tfm))
-			goto error;
-		*per_cpu_ptr(tfms, cpu) = tfm;
-	}
-
 	return tfms;
-
-error:
-	ipcomp_free_tfms(tfms);
-	return NULL;
 }
 
 static void ipcomp_free_data(struct ipcomp_data *ipcd)
-- 
1.7.5.4
