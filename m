From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: avoid refreshing heartbeat timer too often
Date: Tue, 29 Mar 2016 10:41:37 -0300
Message-ID: <1459258897-21607-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbcC2Npp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 09:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently on high rate SCTP streams the heartbeat timer refresh can
consume quite a lot of resources as timer updates are costly and it
contains a random factor, which a) is also costly and b) invalidates
mod_timer() optimization for not editing a timer to the same value.
It may even cause the timer to be slightly advanced, for no good reason.

There are 3 places that call sctp_transport_reset_timers(), including
one that calls it for every single chunk added to a packet on
sctp_outq_flush(), even if they are bundled. As there is the possibility
of working on several transports, it's not trivial to just post-poned
this call as it would require to at least remember which transports were
used.

This change then moves the random factor to outside
sctp_transport_timeout(), allowing sctp_transport_reset_timers() to
check if a timer update is really necessary. For that, the random factor
is considered 0. If timer expires is still after it, the update is not
necessary as it's a possible random value and there is no
security/functional loss in doing so.

On loopback with MTU of 65535 and data chunks with 1636, so that we
have a considerable amount of chunks without stressing system calls,
netperf -t SCTP_STREAM -l 30, perf looked like this before:

Samples: 103K of event 'cpu-clock', Event count (approx.): 25833000000
  Overhead  Command  Shared Object      Symbol
+    6,15%  netperf  [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
-    5,43%  netperf  [kernel.vmlinux]   [k] _raw_write_unlock_irqrestore
   - _raw_write_unlock_irqrestore
      - 96,54% _raw_spin_unlock_irqrestore
         - 36,14% mod_timer
            + 97,24% sctp_transport_reset_timers
            + 2,76% sctp_do_sm
         + 33,65% __wake_up_sync_key
         + 28,77% sctp_ulpq_tail_event
         + 1,40% del_timer
      - 1,84% mod_timer
         + 99,03% sctp_transport_reset_timers
         + 0,97% sctp_do_sm
      + 1,50% sctp_ulpq_tail_event

And after this patch:

Samples: 120K of event 'cpu-clock', Event count (approx.): 30002250000
  Overhead  Command  Shared Object      Symbol
+    7,34%  netperf  [kernel.vmlinux]   [k] memcpy_erms
+    6,67%  netperf  [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
-    5,34%  netperf  [kernel.vmlinux]   [k] _raw_write_unlock_irqrestore
   - _raw_write_unlock_irqrestore
      - 98,00% _raw_spin_unlock_irqrestore
         + 54,24% __wake_up_sync_key
         + 41,54% sctp_ulpq_tail_event
         - 2,61% mod_timer
            + 79,88% sctp_transport_update_pmtu
            + 20,12% sctp_do_sm
         + 1,61% del_timer
      + 1,83% sctp_ulpq_tail_event
+    2,34%  netperf  [kernel.vmlinux]   [k] pvclock_clocksource_read
+    2,31%  netperf  [sctp]             [k] sctp_sendmsg
+    1,93%  netperf  [kernel.vmlinux]   [k] __slab_free
+    1,92%  netperf  [sctp]             [k] sctp_packet_transmit
+    1,85%  netperf  [kernel.vmlinux]   [k] kfree

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/transport.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 9b6b48c7524e4b441a151b80f0babec81f539d49..c9d6c61f5a511f96f38a0f2c275e418e158e0632 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -185,6 +185,8 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
  */
 void sctp_transport_reset_timers(struct sctp_transport *transport)
 {
+	unsigned long expires;
+
 	/* RFC 2960 6.3.2 Retransmission Timer Rules
 	 *
 	 * R1) Every time a DATA chunk is sent to any address(including a
@@ -199,8 +201,10 @@ void sctp_transport_reset_timers(struct sctp_transport *transport)
 			sctp_transport_hold(transport);
 
 	/* When a data chunk is sent, reset the heartbeat interval.  */
-	if (!mod_timer(&transport->hb_timer,
-		       sctp_transport_timeout(transport)))
+	expires = sctp_transport_timeout(transport);
+	if (time_before(transport->hb_timer.expires, expires) &&
+	    !mod_timer(&transport->hb_timer,
+		       expires + prandom_u32_max(transport->rto)))
 	    sctp_transport_hold(transport);
 }
 
@@ -595,7 +599,7 @@ void sctp_transport_burst_reset(struct sctp_transport *t)
 unsigned long sctp_transport_timeout(struct sctp_transport *trans)
 {
 	/* RTO + timer slack +/- 50% of RTO */
-	unsigned long timeout = (trans->rto >> 1) + prandom_u32_max(trans->rto);
+	unsigned long timeout = trans->rto >> 1;
 
 	if (trans->state != SCTP_UNCONFIRMED &&
 	    trans->state != SCTP_PF)
-- 
2.5.0
