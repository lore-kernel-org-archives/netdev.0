From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: Move the test on replay window size into the
 replay check functions
Date: Tue, 29 Mar 2011 07:45:52 +0200
Message-ID: <20110329054552.GI1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36966 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131Ab1C2Fp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 01:45:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it is, the replay check is just performed if the replay window of the
legacy implementation is nonzero. So we move the test on a nonzero replay
window inside the replay check functions to be sure we are testing for the
right implementation.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c  |    2 +-
 net/xfrm/xfrm_replay.c |   17 +++++++++++++++--
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 872065c..e063638 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -173,7 +173,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
-		if (x->props.replay_window && x->repl->check(x, skb, seq)) {
+		if (x->repl->check(x, skb, seq)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATESEQERROR);
 			goto drop_unlock;
 		}
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 2f5be5b..f218385 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -118,6 +118,9 @@ static int xfrm_replay_check(struct xfrm_state *x,
 	u32 diff;
 	u32 seq = ntohl(net_seq);
 
+	if (!x->props.replay_window)
+		return 0;
+
 	if (unlikely(seq == 0))
 		goto err;
 
@@ -193,9 +196,14 @@ static int xfrm_replay_check_bmp(struct xfrm_state *x,
 {
 	unsigned int bitnr, nr;
 	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	u32 pos;
 	u32 seq = ntohl(net_seq);
 	u32 diff =  replay_esn->seq - seq;
-	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
+	if (!replay_esn->replay_window)
+		return 0;
+
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
 
 	if (unlikely(seq == 0))
 		goto err;
@@ -373,12 +381,17 @@ static int xfrm_replay_check_esn(struct xfrm_state *x,
 	unsigned int bitnr, nr;
 	u32 diff;
 	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	u32 pos;
 	u32 seq = ntohl(net_seq);
-	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
 	u32 wsize = replay_esn->replay_window;
 	u32 top = replay_esn->seq;
 	u32 bottom = top - wsize + 1;
 
+	if (!wsize)
+		return 0;
+
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
 	if (unlikely(seq == 0 && replay_esn->seq_hi == 0 &&
 		     (replay_esn->seq < replay_esn->replay_window - 1)))
 		goto err;
-- 
1.7.0.4

