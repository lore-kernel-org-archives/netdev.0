From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH RFC net-next 2/2] net: skbuff: do not allocate emergency memory if flags is not __GFP_MEMALLOC
Date: Sun, 24 Aug 2014 03:07:19 +0530
Message-ID: <1408829839-20742-3-git-send-email-_govind@gmx.com>
References: <1408829839-20742-1-git-send-email-_govind@gmx.com>
Cc: davem@davemloft.net, edumazet@google.com, mgorman@suse.de,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53598 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbaHWVhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 17:37:52 -0400
In-Reply-To: <1408829839-20742-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible that nc->frag.page is previously allocated from emergency memory.
For new alloc call, if the flags does not contain __GFP_MEMALLOC, do not
return pfmemalloc memory.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 net/core/skbuff.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 51a3328..792ce89 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -364,6 +364,13 @@ recycle:
 		atomic_set(&nc->frag.page->_count, NETDEV_PAGECNT_MAX_BIAS);
 		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
 		nc->frag.offset = 0;
+	} else if (nc->frag.page->pfmemalloc && !(gfp_mask & __GFP_MEMALLOC)) {
+		if (atomic_sub_and_test(nc->pagecnt_bias,
+					&nc->frag.page->_count)) {
+			atomic_set(&nc->frag.page->_count, 1);
+			kfree(page_address(nc->frag.page));
+		}
+		goto refill;
 	}
 
 	if (nc->frag.offset + fragsz > nc->frag.size) {
-- 
2.1.0
