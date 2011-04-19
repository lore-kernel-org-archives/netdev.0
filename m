From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 6/8] sctp: teach CACC algorithm about removed
 transports
Date: Tue, 19 Apr 2011 13:13:56 +0800
Message-ID: <4DAD1A14.9060603@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57090 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab1DSFNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:13:51 -0400
In-Reply-To: <4DAD18AB.3040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

When we have have to remove a transport due to ASCONF, we move
the data to a new active path.  This can trigger CACC algorithm
to not mark that data as missing when SACKs arrive.  This is
because the transport passed to the CACC algorithm is the one
this data is sitting on, not the one it was sent on (that one
may be gone).  So, by sending the original transport (even if
it's NULL), we may start marking data as missing.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/outqueue.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index bf92a5b..7812772 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -131,7 +131,8 @@ static inline int sctp_cacc_skip_3_1_d(struct sctp_transport *primary,
 static inline int sctp_cacc_skip_3_1_f(struct sctp_transport *transport,
 				       int count_of_newacks)
 {
-	if (count_of_newacks < 2 && !transport->cacc.cacc_saw_newack)
+	if (count_of_newacks < 2 &&
+			(transport && !transport->cacc.cacc_saw_newack))
 		return 1;
 	return 0;
 }
@@ -618,9 +619,12 @@ redo:
 
 			/* If we are retransmitting, we should only
 			 * send a single packet.
+			 * Otherwise, try appending this chunk again.
 			 */
 			if (rtx_timeout || fast_rtx)
 				done = 1;
+			else
+				goto redo;
 
 			/* Bundle next chunk in the next round.  */
 			break;
@@ -1683,8 +1687,9 @@ static void sctp_mark_missing(struct sctp_outq *q,
 			/* SFR-CACC may require us to skip marking
 			 * this chunk as missing.
 			 */
-			if (!transport || !sctp_cacc_skip(primary, transport,
-					    count_of_newacks, tsn)) {
+			if (!transport || !sctp_cacc_skip(primary,
+						chunk->transport,
+						count_of_newacks, tsn)) {
 				chunk->tsn_missing_report++;
 
 				SCTP_DEBUG_PRINTK(
-- 
1.6.5.2


