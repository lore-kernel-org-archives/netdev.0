From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] xfrm: Fix esn sequence number diff calculation in xfrm_replay_notify_esn()
Date: Wed, 27 Mar 2013 08:41:08 +0100
Message-ID: <1364370068-20025-4-git-send-email-steffen.klassert@secunet.com>
References: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53937 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab3C0Hl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 03:41:26 -0400
In-Reply-To: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

Commit 0017c0b "xfrm: Fix replay notification for esn." is off by one
for the sequence number wrapped case as UINT_MAX is 0xffffffff, not
0x100000000. ;)

Just calculate the diff like done everywhere else in the file.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index a390673..8dafe6d3 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -359,14 +359,12 @@ static void xfrm_replay_notify_esn(struct xfrm_state *x, int event)
 		if (replay_esn->seq_hi == preplay_esn->seq_hi)
 			seq_diff = replay_esn->seq - preplay_esn->seq;
 		else
-			seq_diff = UINT_MAX - preplay_esn->seq
-				   + replay_esn->seq;
+			seq_diff = ~preplay_esn->seq + replay_esn->seq + 1;
 
 		if (replay_esn->oseq_hi == preplay_esn->oseq_hi)
 			oseq_diff = replay_esn->oseq - preplay_esn->oseq;
 		else
-			oseq_diff = UINT_MAX - preplay_esn->oseq
-				    + replay_esn->oseq;
+			oseq_diff = ~preplay_esn->oseq + replay_esn->oseq + 1;
 
 		if (seq_diff < x->replay_maxdiff &&
 		    oseq_diff < x->replay_maxdiff) {
-- 
1.7.9.5
