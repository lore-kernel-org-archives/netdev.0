From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 6/9] sctp: handle ootb packet in chunk order
 as defined
Date: Wed, 20 Apr 2011 15:30:01 +0800
Message-ID: <4DAE8B79.7060007@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58874 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab1DTHaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:30:02 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

Changed the order of processing SHUTDOWN ACK and COOKIE ACK
refer to section 8.4:Handle "Out of the Blue" Packets.

SHUTDOWN ACK chunk should be processed before processing
"Stale Cookie" ERROR or a COOKIE ACK.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/input.c        |   15 ---------------
 net/sctp/sm_statefuns.c |   21 +++++++++++++++++++++
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 30cec77..3a8eb79 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -661,7 +661,6 @@ static int sctp_rcv_ootb(struct sk_buff *skb)
 {
 	sctp_chunkhdr_t *ch;
 	__u8 *ch_end;
-	sctp_errhdr_t *err;
 
 	ch = (sctp_chunkhdr_t *) skb->data;
 
@@ -697,20 +696,6 @@ static int sctp_rcv_ootb(struct sk_buff *skb)
 		if (SCTP_CID_INIT == ch->type && (void *)ch != skb->data)
 			goto discard;
 
-		/* RFC 8.4, 7) If the packet contains a "Stale cookie" ERROR
-		 * or a COOKIE ACK the SCTP Packet should be silently
-		 * discarded.
-		 */
-		if (SCTP_CID_COOKIE_ACK == ch->type)
-			goto discard;
-
-		if (SCTP_CID_ERROR == ch->type) {
-			sctp_walk_errors(err, ch) {
-				if (SCTP_ERROR_STALE_COOKIE == err->cause)
-					goto discard;
-			}
-		}
-
 		ch = (sctp_chunkhdr_t *) ch_end;
 	} while (ch_end < skb_tail_pointer(skb));
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 194d5ec..ad3b43b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3332,8 +3332,10 @@ sctp_disposition_t sctp_sf_ootb(const struct sctp_endpoint *ep,
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
 	sctp_chunkhdr_t *ch;
+	sctp_errhdr_t *err;
 	__u8 *ch_end;
 	int ootb_shut_ack = 0;
+	int ootb_cookie_ack = 0;
 
 	SCTP_INC_STATS(SCTP_MIB_OUTOFBLUES);
 
@@ -3358,6 +3360,23 @@ sctp_disposition_t sctp_sf_ootb(const struct sctp_endpoint *ep,
 		if (SCTP_CID_ABORT == ch->type)
 			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
+		/* RFC 8.4, 7) If the packet contains a "Stale cookie" ERROR
+		 * or a COOKIE ACK the SCTP Packet should be silently
+		 * discarded.
+		 */
+
+		if (SCTP_CID_COOKIE_ACK == ch->type)
+			ootb_cookie_ack = 1;
+
+		if (SCTP_CID_ERROR == ch->type) {
+			sctp_walk_errors(err, ch) {
+				if (SCTP_ERROR_STALE_COOKIE == err->cause) {
+					ootb_cookie_ack = 1;
+					break;
+				}
+			}
+		}
+
 		/* Report violation if chunk len overflows */
 		ch_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
 		if (ch_end > skb_tail_pointer(skb))
@@ -3369,6 +3388,8 @@ sctp_disposition_t sctp_sf_ootb(const struct sctp_endpoint *ep,
 
 	if (ootb_shut_ack)
 		return sctp_sf_shut_8_4_5(ep, asoc, type, arg, commands);
+	else if (ootb_cookie_ack)
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 	else
 		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
 }
-- 
1.6.5.2


