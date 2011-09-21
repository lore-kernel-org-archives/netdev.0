From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Perform a replay check after return from async
 codepaths
Date: Wed, 21 Sep 2011 11:38:58 +0200
Message-ID: <20110921093858.GW1808@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34988 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab1IUJjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 05:39:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When asyncronous crypto algorithms are used, there might be many
packets that passed the xfrm replay check, but the replay advance
function is not called yet for these packets. So the replay check
function would accept a replay of all of these packets. Also the
system might crash if there are more packets in async processing
than the size of the anti replay window, because the replay advance
function would try to update the replay window beyond the bounds.

This pach adds a second replay check after resuming from the async
processing to fix these issues.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index a026b0e..54a0dc2 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -212,6 +212,11 @@ resume:
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
+		if (async && x->repl->check(x, skb, seq)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATESEQERROR);
+			goto drop_unlock;
+		}
+
 		x->repl->advance(x, seq);
 
 		x->curlft.bytes += skb->len;
-- 
1.7.0.4
