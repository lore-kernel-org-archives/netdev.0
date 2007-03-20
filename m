From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 17/31] [CCID3]: Use MSS for larger initial windows
Date: Tue, 20 Mar 2007 20:14:28 -0300
Message-ID: <20070320231428.GF17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:38396 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbXCTXOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:14:33 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66486wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:14:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This improves the slow-start phase by using the MSS
(as suggested in RFC 4342, sec. 5) instead of the packet size s.
Also figured out that __u32 is ample resource enough.

After applying, I got the following in the logs:

  ccid3_hc_tx_packet_recv: client(f7421700), s=6, MSS=1424, w_init=4380, R_sample=176us, X=24886363

Had the previous variant been used, w_init would have been as low as 24.

Committer note: removed unneeded cast to unsigned long long that was
                causing a compiler warning on 64bit architectures.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 0009b39..52dae40 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -466,20 +466,20 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		if (hctx->ccid3hctx_state == TFRC_SSTATE_NO_FBACK) {
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
-			 * We deviate in that we use `s' instead of `MSS'.
 			 */
-			__u64 w_init = min(4 * hctx->ccid3hctx_s,
-					   max(2 * hctx->ccid3hctx_s, 4380));
+			__u32 w_init = min(4 * dp->dccps_mss_cache,
+					   max(2 * dp->dccps_mss_cache, 4380U));
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
 
-			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
+			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
-				       (unsigned long long)w_init,
+				       dp->dccps_mss_cache,
+				       w_init,
 				       (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
-- 
1.5.0.3

