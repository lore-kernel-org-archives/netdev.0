From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: sctp: improve timer slack calculation for transport HBs
Date: Mon, 30 Jun 2014 13:52:08 +0200
Message-ID: <1404129129-23270-2-git-send-email-dborkman@redhat.com>
References: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbaF3LwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 07:52:13 -0400
In-Reply-To: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4960, section 8.3 says:

  On an idle destination address that is allowed to heartbeat,
  it is recommended that a HEARTBEAT chunk is sent once per RTO
  of that destination address plus the protocol parameter
  'HB.interval', with jittering of +/- 50% of the RTO value,
  and exponential backoff of the RTO if the previous HEARTBEAT
  is unanswered.

Currently, we calculate jitter via sctp_jitter() function first,
and then add its result to the current RTO for the new timeout:

  TMO = RTO + (RAND() % RTO) - (RTO / 2)
              `------------------------^-=> sctp_jitter()

Instead, we can just simplify all this by directly calculating:

  TMO = (RTO / 2) + (RAND() % RTO)

With the help of prandom_u32_max(), we don't need to open code
our own global PRNG, but can instead just make use of the per
CPU implementation of prandom with better quality numbers. Also,
we can now spare us the conditional for divide by zero check
since no div or mod operation needs to be used. Note that
prandom_u32_max() won't emit the same result as a mod operation,
but we really don't care here as we only want to have a random
number scaled into RTO interval.

Note, exponential RTO backoff is handeled elsewhere, namely in
sctp_do_8_2_transport_strike().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h | 21 ---------------------
 net/sctp/transport.c    | 17 +++++++++--------
 2 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 8e4de46..c2035c9 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -388,27 +388,6 @@ static inline int sctp_list_single_entry(struct list_head *head)
 	return (head->next != head) && (head->next == head->prev);
 }
 
-/* Generate a random jitter in the range of -50% ~ +50% of input RTO. */
-static inline __s32 sctp_jitter(__u32 rto)
-{
-	static __u32 sctp_rand;
-	__s32 ret;
-
-	/* Avoid divide by zero. */
-	if (!rto)
-		rto = 1;
-
-	sctp_rand += jiffies;
-	sctp_rand ^= (sctp_rand << 12);
-	sctp_rand ^= (sctp_rand >> 20);
-
-	/* Choose random number from 0 to rto, then move to -50% ~ +50%
-	 * of rto.
-	 */
-	ret = sctp_rand % rto - (rto >> 1);
-	return ret;
-}
-
 /* Break down data chunks at this point.  */
 static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
 {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 7dd672f..b10e047 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -594,15 +594,16 @@ void sctp_transport_burst_reset(struct sctp_transport *t)
 }
 
 /* What is the next timeout value for this transport? */
-unsigned long sctp_transport_timeout(struct sctp_transport *t)
+unsigned long sctp_transport_timeout(struct sctp_transport *trans)
 {
-	unsigned long timeout;
-	timeout = t->rto + sctp_jitter(t->rto);
-	if ((t->state != SCTP_UNCONFIRMED) &&
-	    (t->state != SCTP_PF))
-		timeout += t->hbinterval;
-	timeout += jiffies;
-	return timeout;
+	/* RTO + timer slack +/- 50% of RTO */
+	unsigned long timeout = (trans->rto >> 1) + prandom_u32_max(trans->rto);
+
+	if (trans->state != SCTP_UNCONFIRMED &&
+	    trans->state != SCTP_PF)
+		timeout += trans->hbinterval;
+
+	return timeout + jiffies;
 }
 
 /* Reset transport variables to their initial values */
-- 
1.7.11.7
