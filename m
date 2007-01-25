From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Thu, 25 Jan 2007 11:32:37 -0500
Message-ID: <45B8DBA5.9000500@hp.com>
References: <20070103154634.b40d9cde.akpm@osdl.org> 	<1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com> 	<Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>	<1168459812.8248.24.camel@w-sridhar2.beaverton.ibm.com> <Pine.CYG.4.58.0701111007010.5484@shill1-mobl.eicon.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020403080808060905090007"
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:35497 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030330AbXAYQcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 11:32:42 -0500
In-Reply-To: <Pine.CYG.4.58.0701111007010.5484@shill1-mobl.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020403080808060905090007
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Steve

Steve Hill wrote:
> On Wed, 10 Jan 2007, Sridhar Samudrala wrote:
> 
>> So looks like there may be an issue with PR-SCTP(partial reliability)
>> support and packet loss. I will take a look into this.
>>
>> Do you still see this problem even if you don't set timetolive?
> 
> No, the problem seems to go away if the timetolive is set to 0, so this is
> what I have now done since I had not intended to set the timetolive in the
> first place (but I thought it was still worth posting details of the
> problem since it does appear to be a bug).
> 

I think I found this bug.  It was rather interesting to figure out.  The problem
appears to be that data messages time-out within the rto.  As a result, they
move the abandoned list and are never retransmitted.  This clears the retransmit
list and the retransmit timer, however the data is still charged as in-flight against
the association.  This in turn causes new data not to be send, since we are 'supposedly'
utilizing our congestion window.

Can you try the attached patch and let me know if the problem is fixed.  You can 
try reducing rto_max or path_max_retrans to get the failover to happen a little faster.

Regards
-vlad

--------------020403080808060905090007
Content-Type: text/plain;
 name="0001-SCTP-Fix-connection-hang-slowdown-with-PR-SCTP.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-SCTP-Fix-connection-hang-slowdown-with-PR-SCTP.txt"

[SCTP]: Fix connection hang with PR-SCTP

The problem that this patch corrects happens when all
of the following conditions are satisfisfied:
    1.  PR-SCTP is used and the timeout on the chunks is
        set below RTO.Max.
    2.  One of the paths on a multihomed associations
        is brought down.

In this scenario, data will expire within the rto of the
initial transmission and will never be retransmitted.  However
this data still fills the send buffer and is counted against
the association as outstanding data.  This causes any new
data to not be sent and retransmission to not happen.

The fix is to discount the abandoned data from the outstanding
count and peers rwnd estimation.  This allows new data to
be sent and a retransmission timer restarted.  Even though
this new data will most like expire withing the rto, the
timer still counts as a strike agains the transport and forces
the FORWARD-TSN chunk to be retransmitted as well.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/outqueue.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index fba567a..54d1b7f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -396,6 +396,19 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 		if (sctp_chunk_abandoned(chunk)) {
 			list_del_init(lchunk);
 			sctp_insert_list(&q->abandoned, lchunk);
+
+			/* If this chunk has not been previousely acked,
+			 * stop considering it 'outstanding'.  Our peer
+			 * will most likely never see it since it will
+			 * not be retransmitted
+			 */
+			if (!chunk->tsn_gap_acked) {
+				chunk->transport->flight_size -=
+						sctp_data_size(chunk);
+				q->outstanding_bytes -= sctp_data_size(chunk);
+				q->asoc->peer.rwnd += (sctp_data_size(chunk) +
+							sizeof(struct sk_buff));
+			}
 			continue;
 		}
 
@@ -1244,6 +1257,15 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 		if (sctp_chunk_abandoned(tchunk)) {
 			/* Move the chunk to abandoned list. */
 			sctp_insert_list(&q->abandoned, lchunk);
+
+			/* If this chunk has not been acked, stop
+			 * considering it as 'outstanding'.
+			 */
+			if (!tchunk->tsn_gap_acked) {
+				tchunk->transport->flight_size -=
+						sctp_data_size(tchunk);
+				q->outstanding_bytes -= sctp_data_size(tchunk);
+			}
 			continue;
 		}
 
@@ -1695,11 +1717,6 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 		 */ 
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(lchunk);
-			if (!chunk->tsn_gap_acked) {
-				chunk->transport->flight_size -=
-					sctp_data_size(chunk);
-				q->outstanding_bytes -= sctp_data_size(chunk);
-			}
 			sctp_chunk_free(chunk);
 		} else {
 			if (TSN_lte(tsn, asoc->adv_peer_ack_point+1)) {
-- 
1.4.4.2.g8336


--------------020403080808060905090007--
