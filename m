From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 5/5] net: fix races in page->_count manipulation
Date: Fri, 10 Oct 2014 04:48:18 -0700
Message-ID: <1412941698-17502-6-git-send-email-edumazet@google.com>
References: <1412941698-17502-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:53702 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaJJLsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:48:39 -0400
Received: by mail-oi0-f73.google.com with SMTP id u20so1127671oif.4
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:48:38 -0700 (PDT)
In-Reply-To: <1412941698-17502-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
the page. Other entities in the kernel need to use get_page_unless_zero()
to get a reference to the page before testing page properties, so we could
loose a refcount increment.

The only case it is valid is when page->_count is 0

Fixes: 540eb7bf0bbed ("net: Update alloc frag to reduce get/put page usage and recycle pages")
Signed-off-by: Eric Dumaze <edumazet@google.com>
---
 net/core/skbuff.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a30d750647e7..829d013745ab 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -360,18 +360,29 @@ refill:
 				goto end;
 		}
 		nc->frag.size = PAGE_SIZE << order;
-recycle:
-		atomic_set(&nc->frag.page->_count, NETDEV_PAGECNT_MAX_BIAS);
+		/* Even if we own the page, we do not use atomic_set().
+		 * This would break get_page_unless_zero() users.
+		 */
+		atomic_add(NETDEV_PAGECNT_MAX_BIAS - 1,
+			   &nc->frag.page->_count);
 		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
 		nc->frag.offset = 0;
 	}
 
 	if (nc->frag.offset + fragsz > nc->frag.size) {
-		/* avoid unnecessary locked operations if possible */
-		if ((atomic_read(&nc->frag.page->_count) == nc->pagecnt_bias) ||
-		    atomic_sub_and_test(nc->pagecnt_bias, &nc->frag.page->_count))
-			goto recycle;
-		goto refill;
+		if (atomic_read(&nc->frag.page->_count) != nc->pagecnt_bias) {
+			if (!atomic_sub_and_test(nc->pagecnt_bias,
+						 &nc->frag.page->_count))
+				goto refill;
+			/* OK, page count is 0, we can safely set it */
+			atomic_set(&nc->frag.page->_count,
+				   NETDEV_PAGECNT_MAX_BIAS);
+		} else {
+			atomic_add(NETDEV_PAGECNT_MAX_BIAS - nc->pagecnt_bias,
+				   &nc->frag.page->_count);
+		}
+		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
+		nc->frag.offset = 0;
 	}
 
 	data = page_address(nc->frag.page) + nc->frag.offset;
-- 
2.1.0.rc2.206.gedb03e5
