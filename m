From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] net/xfrm/xfrm_replay: avoid division by zero
Date: Tue, 22 Jan 2013 10:06:34 +0100
Message-ID: <1358845596-2066-4-git-send-email-steffen.klassert@secunet.com>
References: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33509 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210Ab3AVJHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:07:11 -0500
In-Reply-To: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nickolai Zeldovich <nickolai@csail.mit.edu>

All of the xfrm_replay->advance functions in xfrm_replay.c check if
x->replay_esn->replay_window is zero (and return if so).  However,
one of them, xfrm_replay_advance_bmp(), divides by that value (in the
'%' operator) before doing the check, which can potentially trigger
a divide-by-zero exception.  Some compilers will also assume that the
earlier division means the value cannot be zero later, and thus will
eliminate the subsequent zero check as dead code.

This patch moves the division to after the check.

Signed-off-by: Nickolai Zeldovich <nickolai@csail.mit.edu>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 765f6fe..35754cc 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -242,11 +242,13 @@ static void xfrm_replay_advance_bmp(struct xfrm_state *x, __be32 net_seq)
 	u32 diff;
 	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
 	u32 seq = ntohl(net_seq);
-	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+	u32 pos;
 
 	if (!replay_esn->replay_window)
 		return;
 
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
 	if (seq > replay_esn->seq) {
 		diff = seq - replay_esn->seq;
 
-- 
1.7.9.5
