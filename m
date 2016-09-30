From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/7] rxrpc: Switch to Congestion Avoidance mode at
 cwnd==ssthresh
Date: Fri, 30 Sep 2016 22:40:25 +0100
Message-ID: <147527162554.28826.2723484388550024625.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to Congestion Avoidance mode at cwnd == ssthresh rather than relying
on cwnd getting incremented beyond ssthresh and the window size, the mode
being shifted and then cwnd being corrected.

We need to make sure we switch into CA mode so that we stop marking every
packet for ACK.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 1461d30583c9..21746f0f7ae0 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -57,7 +57,7 @@ static void rxrpc_congestion_management(struct rxrpc_call *call,
 		call->cong_ssthresh = max_t(unsigned int,
 					    summary->flight_size / 2, 2);
 		cwnd = 1;
-		if (cwnd > call->cong_ssthresh &&
+		if (cwnd >= call->cong_ssthresh &&
 		    call->cong_mode == RXRPC_CALL_SLOW_START) {
 			call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
 			call->cong_tstamp = skb->tstamp;
@@ -82,7 +82,7 @@ static void rxrpc_congestion_management(struct rxrpc_call *call,
 			goto packet_loss_detected;
 		if (summary->cumulative_acks > 0)
 			cwnd += 1;
-		if (cwnd > call->cong_ssthresh) {
+		if (cwnd >= call->cong_ssthresh) {
 			call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
 			call->cong_tstamp = skb->tstamp;
 		}
@@ -161,7 +161,7 @@ resume_normality:
 	call->cong_dup_acks = 0;
 	call->cong_extra = 0;
 	call->cong_tstamp = skb->tstamp;
-	if (cwnd <= call->cong_ssthresh)
+	if (cwnd < call->cong_ssthresh)
 		call->cong_mode = RXRPC_CALL_SLOW_START;
 	else
 		call->cong_mode = RXRPC_CALL_CONGEST_AVOIDANCE;
