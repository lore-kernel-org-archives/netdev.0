From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: Fix error count increments that were results of HEARTBEATS
Date: Wed, 26 Aug 2009 10:46:17 -0400
Message-ID: <1251297977-23859-1-git-send-email-vladislav.yasevich@hp.com>
References: <1251191279-1764-1-git-send-email-chunbo.luo@windriver.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	yjwei@cn.fujitsu.com, Vlad Yasevich <vladislav.yasevich@hp.com>
To: chunbo.luo@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:14042 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbZHZOqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 10:46:17 -0400
In-Reply-To: <1251191279-1764-1-git-send-email-chunbo.luo@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is what I am applying.  After walking through all the code
paths that flow through the sctp_do_8_2_transport_strike() function,
it became obviouse that were not doing the right thing all the time.
The post-increment trick just obfuscated the real behavior and actually
had problems when HEARTBEAT and DATA mixed.  I've tried to make the
new code much clearer in its intentens and behavior and it solves the
problem in all of my simulations.

Feel free to comment.
-vlad

---

SCTP RFC 4960 states that unacknowledged HEARTBEATS count as
errors agains a given transport or endpoint.  As such, we
should increment the error counts for only for unacknowledged
HB, otherwise we detect failure too soon.  This goes for both
the overall error count and the path error count.

Now, there is a difference in how the detection is done
between the two.  The path error detection is done after
the increment, so to detect it properly, we actually need
to exceed the path threshold.  The overall error detection
is done _BEFORE_ the increment.  Thus to detect the failure,
it's enough for the error count to match the threshold.
This is why all the state functions use '>=' to detect failure,
while path detection uses '>'.

Thanks goes to Chunbo Luo <chunbo.luo@windriver.com> who first
proposed patches to fix this issue and made me re-read the spec
and the code to figure out how this cruft really works.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_sideeffect.c |   20 ++++++++++++++++----
 net/sctp/sm_statefuns.c  |    2 +-
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 238adf7..41cb73b 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -440,14 +440,26 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	/* The check for association's overall error counter exceeding the
 	 * threshold is done in the state function.
 	 */
-	/* When probing UNCONFIRMED addresses, the association overall
-	 * error count is NOT incremented
+	/* We are here due to a timer expiration.  If the timer was
+	 * not a HEARTBEAT, then normal error tracking is done.
+	 * If the timer was a heartbeat, we only increment error counts
+	 * when we already have an outstanding HEARTBEAT that has not
+	 * been acknowledged.
+	 * Additionaly, some tranport states inhibit error increments.
 	 */
-	if (transport->state != SCTP_UNCONFIRMED)
+	if (!is_hb) {
 		asoc->overall_error_count++;
+		if (transport->state != SCTP_INACTIVE)
+			transport->error_count++;
+	 } else if (transport->hb_sent) {
+		if (transport->state != SCTP_UNCONFIRMED)
+			asoc->overall_error_count++;
+	 	if (transport->state != SCTP_INACTIVE)
+			transport->error_count++;
+	}
 
 	if (transport->state != SCTP_INACTIVE &&
-	    (transport->error_count++ >= transport->pathmaxrxt)) {
+	    (transport->error_count > transport->pathmaxrxt)) {
 		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
 					 " transport IP: port:%d failed.\n",
 					 asoc,
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7fb08a6..45b8bca 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -971,7 +971,7 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 
-	if (asoc->overall_error_count > asoc->max_retrans) {
+	if (asoc->overall_error_count >= asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
 		/* CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
-- 
1.5.4.3

