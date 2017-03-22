From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/15] nfp: lock area cache earlier
Date: Tue, 21 Mar 2017 17:59:12 -0700
Message-ID: <20170322005921.10965-7-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34993 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757414AbdCVBIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:07 -0400
Received: by mail-pf0-f175.google.com with SMTP id 20so38798972pfk.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:06 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We shouldn't access area_cache_list without its lock even
to check if it's empty.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index 4e08362d8c97..5189fedb0f4f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -821,10 +821,7 @@ area_cache_get(struct nfp_cpp *cpp, u32 id,
 	 * the need for special case code below when
 	 * checking against available cache size.
 	 */
-	if (length == 0)
-		return NULL;
-
-	if (list_empty(&cpp->area_cache_list) || id == 0)
+	if (length == 0 || id == 0)
 		return NULL;
 
 	/* Remap from cpp_island to cpp_target */
@@ -832,10 +829,15 @@ area_cache_get(struct nfp_cpp *cpp, u32 id,
 	if (err < 0)
 		return NULL;
 
-	addr += *offset;
-
 	mutex_lock(&cpp->area_cache_mutex);
 
+	if (list_empty(&cpp->area_cache_list)) {
+		mutex_unlock(&cpp->area_cache_mutex);
+		return NULL;
+	}
+
+	addr += *offset;
+
 	/* See if we have a match */
 	list_for_each_entry(cache, &cpp->area_cache_list, entry) {
 		if (id == cache->id &&
-- 
2.11.0
