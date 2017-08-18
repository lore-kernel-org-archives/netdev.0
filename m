From: David Lamparter <equinox@diac24.net>
Subject: [PATCH net-next] net: check type when freeing metadata dst
Date: Fri, 18 Aug 2017 14:31:35 +0200
Message-ID: <20170818123135.518080-1-equinox@diac24.net>
References: <a983211c-530a-8f73-ed00-c95840ce3d08@cogentembedded.com>
Cc: David Lamparter <equinox@diac24.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Sridhar Samudrala <sridhar.samudrala@intel.com>,
        Simon Horman <horms@verge.net.au>,
        "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:57610 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdHRMbq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 08:31:46 -0400
In-Reply-To: <a983211c-530a-8f73-ed00-c95840ce3d08@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3fcece12bc1b ("net: store port/representator id in metadata_dst")
added a new type field to metadata_dst, but metadata_dst_free() wasn't
updated to check it before freeing the METADATA_IP_TUNNEL specific dst
cache entry.

This is not currently causing problems since it's far enough back in the
struct to be zeroed for the only other type currently in existance
(METADATA_HW_PORT_MUX), but nevertheless it's not correct.

Fixes: 3fcece12bc1b ("net: store port/representator id in metadata_dst")
Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: David S. Miller <davem@davemloft.net>
---
 net/core/dst.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 00aa972ad1a1..7954d1710d97 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -299,7 +299,8 @@ EXPORT_SYMBOL_GPL(metadata_dst_alloc);
 void metadata_dst_free(struct metadata_dst *md_dst)
 {
 #ifdef CONFIG_DST_CACHE
-	dst_cache_destroy(&md_dst->u.tun_info.dst_cache);
+	if (md_dst->type == METADATA_IP_TUNNEL)
+		dst_cache_destroy(&md_dst->u.tun_info.dst_cache);
 #endif
 	kfree(md_dst);
 }
-- 
2.13.0
