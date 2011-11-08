From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 1/2] sctp: fasthandoff with ASCONF at mobile-node
Date: Wed, 9 Nov 2011 01:23:07 +0900
Message-ID: <E3745FDE-AFD0-402B-AB36-4FAB640BBCE6@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55332 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751351Ab1KHQb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 11:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d42e880c330693ceb0e03a48d1e4347b190d0cce Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Fri, 17 Jun 2011 11:03:23 +0900
Subject: [PATCH 1/2] sctp: fasthandoff with ASCONF at mobile-node

Fast retransmission after changing the last address
with ASCONF negotiation

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/sm_make_chunk.c   |    4 +++-
 net/sctp/transport.c       |   16 ++++++++++++++++
 3 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e90e7a9..3382615 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1085,6 +1085,7 @@ void sctp_transport_burst_reset(struct sctp_transport *);
 unsigned long sctp_transport_timeout(struct sctp_transport *);
 void sctp_transport_reset(struct sctp_transport *);
 void sctp_transport_update_pmtu(struct sctp_transport *, u32);
+void sctp_transport_immediate_rtx(struct sctp_transport *);
 
 
 /* This is the structure we use to queue packets as they come into
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0121e0a..a85eeeb 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3400,8 +3400,10 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 		asconf_len -= length;
 	}
 
-	if (no_err && asoc->src_out_of_asoc_ok)
+	if (no_err && asoc->src_out_of_asoc_ok) {
 		asoc->src_out_of_asoc_ok = 0;
+		sctp_transport_immediate_rtx(asoc->peer.primary_path);
+	}
 
 	/* Free the cached last sent asconf chunk. */
 	list_del_init(&asconf->transmitted_list);
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 394c57c..3889330 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -641,3 +641,19 @@ void sctp_transport_reset(struct sctp_transport *t)
 	t->cacc.next_tsn_at_change = 0;
 	t->cacc.cacc_saw_newack = 0;
 }
+
+/* Schedule retransmission on the given transport */
+void sctp_transport_immediate_rtx(struct sctp_transport *t)
+{
+	/* Stop pending T3_rtx_timer */
+	if (timer_pending(&t->T3_rtx_timer)) {
+		(void)del_timer(&t->T3_rtx_timer);
+		sctp_transport_put(t);
+	}
+	sctp_retransmit(&t->asoc->outqueue, t, SCTP_RTXR_T3_RTX);
+	if (!timer_pending(&t->T3_rtx_timer)) {
+		if (!mod_timer(&t->T3_rtx_timer, jiffies + t->rto))
+			sctp_transport_hold(t);
+	}
+	return;
+}
-- 
1.7.3.2
