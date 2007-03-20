From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 14/31] [DCCP]: Remove ambiguity in the way before48 is used
Date: Tue, 20 Mar 2007 20:13:50 -0300
Message-ID: <20070320231349.GC17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:38396 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbXCTXNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:13:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66486wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:13:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes two ambiguities in employing the new definition of before48,
following the analysis on http://www.mail-archive.com/dccp@vger.kernel.org/msg01295.html

 (1) Updating GSR when P.seqno >= S.SWL
     With the old definition we did not update when P.seqno and S.SWL are 2^47 apart. To
     ensure the same behaviour as with the old definition, this is replaced with the
     equivalent condition dccp_delta_seqno(S.SWL, P.seqno) >= 0

 (2) Sending SYNC when P.seqno >= S.OSR
     Here it is debatable whether the new definition causes an ambiguity: the case is
     similar to (1); and to have consistency with the case (1), we use the equivalent
     condition dccp_delta_seqno(S.OSR, P.seqno) >= 0

Detailed Justification
----------------------
 dccp_delta_seqno(a, b) returns a value >= 0 if either a is `before' b or a == b,
 using the new definition: a `before' b   <=>  1 <= (b - a) mod 2^48 <= 2^47 - 1.

 The old and new definition of `before' are identical as long as the modulo-2^48
 difference between a and b is not equal to 2^47. In both cases, a test of the
 form !before(x, y) has been replaced by dccp_delta_seqno(y, x) >= 0.
 For all values excluding y = (x + 2^47) % 2^48, the equivalence is clear to see.
 When y = (x + 2^47) % 2^48 then !before(x, y) returned false in the new definition.
 However, 'dccp_delta_seqno(x, (x+2^47) % 2^48) >= 0' also returns false; hence we
 have full equivalence.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/input.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 78b043c..a190015 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -86,7 +86,8 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 	    dh->dccph_type == DCCP_PKT_SYNCACK) {
 		if (between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			      dp->dccps_awl, dp->dccps_awh) &&
-		    !before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_swl))
+		    dccp_delta_seqno(dp->dccps_swl,
+				     DCCP_SKB_CB(skb)->dccpd_seq) >= 0)
 			dccp_update_gsr(sk, DCCP_SKB_CB(skb)->dccpd_seq);
 		else
 			return -1;
@@ -203,7 +204,8 @@ static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 		if (dp->dccps_role != DCCP_ROLE_CLIENT)
 			goto send_sync;
 check_seq:
-		if (!before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_osr)) {
+		if (dccp_delta_seqno(dp->dccps_osr,
+				     DCCP_SKB_CB(skb)->dccpd_seq) >= 0) {
 send_sync:
 			dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq,
 				       DCCP_PKT_SYNC);
-- 
1.5.0.3

