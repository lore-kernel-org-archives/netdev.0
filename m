From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Don't allow esn with disabled anti replay detection
Date: Tue, 10 May 2011 07:43:05 +0200
Message-ID: <20110510054305.GC8013@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43327 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab1EJFlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 01:41:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike the standard case, disabled anti replay detection needs some
nontrivial extra treatment on ESN. RFC 4303 states:

Note: If a receiver chooses to not enable anti-replay for an SA, then
the receiver SHOULD NOT negotiate ESN in an SA management protocol.
Use of ESN creates a need for the receiver to manage the anti-replay
window (in order to determine the correct value for the high-order
bits of the ESN, which are employed in the ICV computation), which is
generally contrary to the notion of disabling anti-replay for an SA.

So return an error if an ESN state with disabled anti replay detection
is inserted for now and add the extra treatment later if we need it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index e8a7814..47f1b86 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -535,6 +535,9 @@ int xfrm_init_replay(struct xfrm_state *x)
 		    replay_esn->bmp_len * sizeof(__u32) * 8)
 			return -EINVAL;
 
+	if ((x->props.flags & XFRM_STATE_ESN) && replay_esn->replay_window == 0)
+		return -EINVAL;
+
 	if ((x->props.flags & XFRM_STATE_ESN) && x->replay_esn)
 		x->repl = &xfrm_replay_esn;
 	else
-- 
1.7.0.4

