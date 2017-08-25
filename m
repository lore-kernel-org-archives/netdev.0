From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] xen-netback: update ubuf_info initialization to anonymous union
Date: Fri, 25 Aug 2017 13:10:43 -0400
Message-ID: <20170825171043.84011-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, wei.liu2@citrix.com, paul.durrant@citrix.com,
        kbuild-all@01.org, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:37490 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755669AbdHYRKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 13:10:47 -0400
Received: by mail-qt0-f193.google.com with SMTP id g13so343233qta.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 10:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The xen driver initializes struct ubuf_info fields using designated
initializers. I recently moved these fields inside a nested anonymous
struct inside an anonymous union. I had missed this use case.

This breaks compilation of xen-netback with older compilers.
>From kbuild bot with gcc-4.4.7:

   drivers/net//xen-netback/interface.c: In function
   'xenvif_init_queue':
   >> drivers/net//xen-netback/interface.c:554: error: unknown field 'ctx' specified in initializer
   >> drivers/net//xen-netback/interface.c:554: warning: missing braces around initializer
      drivers/net//xen-netback/interface.c:554: warning: (near initialization for '(anonymous).<anonymous>')
   >> drivers/net//xen-netback/interface.c:554: warning: initialization makes integer from pointer without a cast
   >> drivers/net//xen-netback/interface.c:555: error: unknown field 'desc' specified in initializer

Add double braces around the designated initializers to match their
nested position in the struct. After this, compilation succeeds again.

Fixes: 4ab6c99d99bb ("sock: MSG_ZEROCOPY notification coalescing")
Reported-by: kbuild bot <lpk@intel.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/xen-netback/interface.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e322a862ddfe..ee8ed9da00ad 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -551,8 +551,8 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 	for (i = 0; i < MAX_PENDING_REQS; i++) {
 		queue->pending_tx_info[i].callback_struct = (struct ubuf_info)
 			{ .callback = xenvif_zerocopy_callback,
-			  .ctx = NULL,
-			  .desc = i };
+			  { { .ctx = NULL,
+			      .desc = i } } };
 		queue->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
 	}
 
-- 
2.14.1.342.g6490525c54-goog
