From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] net: Update netdev_alloc_frag to work more efficiently with
	TCP and GRO
Date: Tue, 19 Jun 2012 17:43:06 -0700
Message-ID: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15901 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623Ab2FTAms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 20:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to help improve system performance when
netdev_alloc_frag is used in scenarios in which buffers are short lived.
This is accomplished by allowing the page offset to be reset in the event
that the page count is 1.  I also reordered the direction in which we give
out sections of the page so that we start at the end of the page and end at
the start.  The main motivation being that I preferred to have offset
represent the amount of page remaining to be used.

My primary test case was using ixgbe in combination with TCP.  With this
patch applied I saw CPU utilization drop from 3.4% to 3.0% for a single
thread of netperf receiving a TCP stream via ixgbe.

I also tested several scenarios in which the page reuse would not be
possible such as UDP flows and routing.  In both of these scenarios I saw
no noticeable performance degradation compared to the kernel without this
patch.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/skbuff.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b21522..eb3853c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -317,15 +317,22 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	if (unlikely(!nc->page)) {
 refill:
 		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
-		nc->offset = 0;
 	}
 	if (likely(nc->page)) {
-		if (nc->offset + fragsz > PAGE_SIZE) {
+		unsigned int offset = PAGE_SIZE;
+
+		if (page_count(nc->page) != 1)
+			offset = nc->offset;
+
+		if (offset < fragsz) {
 			put_page(nc->page);
 			goto refill;
 		}
-		data = page_address(nc->page) + nc->offset;
-		nc->offset += fragsz;
+
+		offset -= fragsz;
+		nc->offset = offset;
+
+		data = page_address(nc->page) + offset;
 		get_page(nc->page);
 	}
 	local_irq_restore(flags);
