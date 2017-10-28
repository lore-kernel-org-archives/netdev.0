From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] nfp: Improve unlocking of a mutex in area_cache_get()
Date: Sat, 28 Oct 2017 17:18:56 +0200
Message-ID: <b543c761-6931-ad0a-f12c-c2152c7bcd72@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, oss-drivers@netronome.com,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 17:12:10 +0200

Add a jump target so that a call of the function "mutex_unlock" is stored
only once at the end of this function implementation.
Replace four calls by goto statements.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 28 ++++++++++------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 04dd5758ecf5..e864793b7ca0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -822,10 +822,8 @@ area_cache_get(struct nfp_cpp *cpp, u32 id,
 
 	mutex_lock(&cpp->area_cache_mutex);
 
-	if (list_empty(&cpp->area_cache_list)) {
-		mutex_unlock(&cpp->area_cache_mutex);
-		return NULL;
-	}
+	if (list_empty(&cpp->area_cache_list))
+		goto unlock;
 
 	addr += *offset;
 
@@ -843,10 +841,8 @@ area_cache_get(struct nfp_cpp *cpp, u32 id,
 
 	/* Can we fit in the cache entry? */
 	if (round_down(addr + length - 1, cache->size) !=
-	    round_down(addr, cache->size)) {
-		mutex_unlock(&cpp->area_cache_mutex);
-		return NULL;
-	}
+	    round_down(addr, cache->size))
+		goto unlock;
 
 	/* If id != 0, we will need to release it */
 	if (cache->id) {
@@ -863,23 +859,23 @@ area_cache_get(struct nfp_cpp *cpp, u32 id,
 	if (cpp->op->area_init) {
 		err = cpp->op->area_init(cache->area,
 					 id, cache->addr, cache->size);
-		if (err < 0) {
-			mutex_unlock(&cpp->area_cache_mutex);
-			return NULL;
-		}
+		if (err < 0)
+			goto unlock;
 	}
 
 	/* Attempt to acquire */
 	err = nfp_cpp_area_acquire(cache->area);
-	if (err < 0) {
-		mutex_unlock(&cpp->area_cache_mutex);
-		return NULL;
-	}
+	if (err < 0)
+		goto unlock;
 
 exit:
 	/* Adjust offset */
 	*offset = addr - cache->addr;
 	return cache;
+
+unlock:
+	mutex_unlock(&cpp->area_cache_mutex);
+	return NULL;
 }
 
 static void
-- 
2.14.3

