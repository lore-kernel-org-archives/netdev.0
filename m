From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 6/6][SCTP]: Extend /proc/net/sctp/snmp to provide more
	statistics.
Date: Mon, 17 Jul 2006 17:25:37 -0700
Message-ID: <1153182337.4282.48.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:6109 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751267AbWGRA2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:28:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0S9pd004441
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0S9ds277994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0S9PF027140
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:09 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Extend /proc/net/sctp/snmp to provide more statistics.

This patch adds more statistics info under /proc/net/sctp/snmp
that should be useful for debugging. The additional events that
are counted now include timer expirations, retransmits, packet
and data chunk discards.

The Data chunk discards include all the cases where a data chunk
is discarded including high tsn, bad stream, dup tsn and the most
useful one(out of receive buffer/rwnd).

Also moved the SCTP MIB data structures from the generic include
directories to include/sctp/sctp.h.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/linux/snmp.h    |   33 ---------------------------------
 include/net/sctp/sctp.h |   41 +++++++++++++++++++++++++++++++++++++++++
 include/net/snmp.h      |    6 ------
 net/sctp/input.c        |    1 +
 net/sctp/outqueue.c     |    6 +++++-
 net/sctp/proc.c         |   14 +++++++++++++-
 net/sctp/sm_statefuns.c |   14 ++++++++++++++
 7 files changed, 74 insertions(+), 41 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 4db25d5..5294c41 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -158,39 +158,6 @@ enum
 	__UDP_MIB_MAX
 };
 
-/* sctp mib definitions */
-/*
- * draft-ietf-sigtran-sctp-mib-07.txt
- */
-enum
-{
-	SCTP_MIB_NUM = 0,
-	SCTP_MIB_CURRESTAB,			/* CurrEstab */
-	SCTP_MIB_ACTIVEESTABS,			/* ActiveEstabs */
-	SCTP_MIB_PASSIVEESTABS,			/* PassiveEstabs */
-	SCTP_MIB_ABORTEDS,			/* Aborteds */
-	SCTP_MIB_SHUTDOWNS,			/* Shutdowns */
-	SCTP_MIB_OUTOFBLUES,			/* OutOfBlues */
-	SCTP_MIB_CHECKSUMERRORS,		/* ChecksumErrors */
-	SCTP_MIB_OUTCTRLCHUNKS,			/* OutCtrlChunks */
-	SCTP_MIB_OUTORDERCHUNKS,		/* OutOrderChunks */
-	SCTP_MIB_OUTUNORDERCHUNKS,		/* OutUnorderChunks */
-	SCTP_MIB_INCTRLCHUNKS,			/* InCtrlChunks */
-	SCTP_MIB_INORDERCHUNKS,			/* InOrderChunks */
-	SCTP_MIB_INUNORDERCHUNKS,		/* InUnorderChunks */
-	SCTP_MIB_FRAGUSRMSGS,			/* FragUsrMsgs */
-	SCTP_MIB_REASMUSRMSGS,			/* ReasmUsrMsgs */
-	SCTP_MIB_OUTSCTPPACKS,			/* OutSCTPPacks */
-	SCTP_MIB_INSCTPPACKS,			/* InSCTPPacks */
-	SCTP_MIB_RTOALGORITHM,			/* RtoAlgorithm */
-	SCTP_MIB_RTOMIN,			/* RtoMin */
-	SCTP_MIB_RTOMAX,			/* RtoMax */
-	SCTP_MIB_RTOINITIAL,			/* RtoInitial */
-	SCTP_MIB_VALCOOKIELIFE,			/* ValCookieLife */
-	SCTP_MIB_MAXINITRETR,			/* MaxInitRetr */
-	__SCTP_MIB_MAX
-};
-
 /* linux mib definitions */
 enum
 {
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index a9663b4..3b1cd69 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -216,6 +216,47 @@ #define SCTP_DEC_STATS(field)      SNMP_
 
 #endif /* !TEST_FRAME */
 
+/* sctp mib definitions */
+enum
+{
+	SCTP_MIB_NUM = 0,
+	SCTP_MIB_CURRESTAB,			/* CurrEstab */
+	SCTP_MIB_ACTIVEESTABS,			/* ActiveEstabs */
+	SCTP_MIB_PASSIVEESTABS,			/* PassiveEstabs */
+	SCTP_MIB_ABORTEDS,			/* Aborteds */
+	SCTP_MIB_SHUTDOWNS,			/* Shutdowns */
+	SCTP_MIB_OUTOFBLUES,			/* OutOfBlues */
+	SCTP_MIB_CHECKSUMERRORS,		/* ChecksumErrors */
+	SCTP_MIB_OUTCTRLCHUNKS,			/* OutCtrlChunks */
+	SCTP_MIB_OUTORDERCHUNKS,		/* OutOrderChunks */
+	SCTP_MIB_OUTUNORDERCHUNKS,		/* OutUnorderChunks */
+	SCTP_MIB_INCTRLCHUNKS,			/* InCtrlChunks */
+	SCTP_MIB_INORDERCHUNKS,			/* InOrderChunks */
+	SCTP_MIB_INUNORDERCHUNKS,		/* InUnorderChunks */
+	SCTP_MIB_FRAGUSRMSGS,			/* FragUsrMsgs */
+	SCTP_MIB_REASMUSRMSGS,			/* ReasmUsrMsgs */
+	SCTP_MIB_OUTSCTPPACKS,			/* OutSCTPPacks */
+	SCTP_MIB_INSCTPPACKS,			/* InSCTPPacks */
+	SCTP_MIB_T1_INIT_EXPIREDS,
+	SCTP_MIB_T1_COOKIE_EXPIREDS,
+	SCTP_MIB_T2_SHUTDOWN_EXPIREDS,
+	SCTP_MIB_T3_RTX_EXPIREDS,
+	SCTP_MIB_T4_RTO_EXPIREDS,
+	SCTP_MIB_T5_SHUTDOWN_GUARD_EXPIREDS,
+	SCTP_MIB_AUTOCLOSE_EXPIREDS,
+	SCTP_MIB_T3_RETRANSMITS,
+	SCTP_MIB_PMTUD_RETRANSMITS,
+	SCTP_MIB_FAST_RETRANSMITS,
+	SCTP_MIB_IN_PKT_DISCARDS,
+	SCTP_MIB_IN_DATA_CHUNK_DISCARDS,
+	__SCTP_MIB_MAX
+};
+
+#define SCTP_MIB_MAX    __SCTP_MIB_MAX
+struct sctp_mib {
+        unsigned long   mibs[SCTP_MIB_MAX];
+} __SNMP_MIB_ALIGN__;
+
 
 /* Print debugging messages.  */
 #if SCTP_DEBUG
diff --git a/include/net/snmp.h b/include/net/snmp.h
index a36bed8..464970e 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -100,12 +100,6 @@ struct udp_mib {
 	unsigned long	mibs[UDP_MIB_MAX];
 } __SNMP_MIB_ALIGN__;
 
-/* SCTP */
-#define SCTP_MIB_MAX	__SCTP_MIB_MAX
-struct sctp_mib {
-	unsigned long	mibs[SCTP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
-
 /* Linux */
 #define LINUX_MIB_MAX	__LINUX_MIB_MAX
 struct linux_mib {
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 42b66e7..ab4a720 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -271,6 +271,7 @@ int sctp_rcv(struct sk_buff *skb)
 	return 0;
 
 discard_it:
+	SCTP_INC_STATS(SCTP_MIB_IN_PKT_DISCARDS);
 	kfree_skb(skb);
 	return 0;
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 30b710c..37074a3 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -467,6 +467,7 @@ void sctp_retransmit(struct sctp_outq *q
 
 	switch(reason) {
 	case SCTP_RTXR_T3_RTX:
+		SCTP_INC_STATS(SCTP_MIB_T3_RETRANSMITS);
 		sctp_transport_lower_cwnd(transport, SCTP_LOWER_CWND_T3_RTX);
 		/* Update the retran path if the T3-rtx timer has expired for
 		 * the current retran path.
@@ -475,12 +476,15 @@ void sctp_retransmit(struct sctp_outq *q
 			sctp_assoc_update_retran_path(transport->asoc);
 		break;
 	case SCTP_RTXR_FAST_RTX:
+		SCTP_INC_STATS(SCTP_MIB_FAST_RETRANSMITS);
 		sctp_transport_lower_cwnd(transport, SCTP_LOWER_CWND_FAST_RTX);
 		fast_retransmit = 1;
 		break;
 	case SCTP_RTXR_PMTUD:
-	default:
+		SCTP_INC_STATS(SCTP_MIB_PMTUD_RETRANSMITS);
 		break;
+	default:
+		BUG();
 	}
 
 	sctp_retransmit_mark(q, transport, fast_retransmit);
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 5b3b0e0..f58508f 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -57,6 +57,18 @@ static struct snmp_mib sctp_snmp_list[] 
 	SNMP_MIB_ITEM("SctpReasmUsrMsgs", SCTP_MIB_REASMUSRMSGS),
 	SNMP_MIB_ITEM("SctpOutSCTPPacks", SCTP_MIB_OUTSCTPPACKS),
 	SNMP_MIB_ITEM("SctpInSCTPPacks", SCTP_MIB_INSCTPPACKS),
+	SNMP_MIB_ITEM("SctpT1InitExpireds", SCTP_MIB_T1_INIT_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT1CookieExpireds", SCTP_MIB_T1_COOKIE_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT2ShutdownExpireds", SCTP_MIB_T2_SHUTDOWN_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT3RtxExpireds", SCTP_MIB_T3_RTX_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT4RtoExpireds", SCTP_MIB_T4_RTO_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT5ShutdownGuardExpireds", SCTP_MIB_T5_SHUTDOWN_GUARD_EXPIREDS),
+	SNMP_MIB_ITEM("SctpAutocloseExpireds", SCTP_MIB_AUTOCLOSE_EXPIREDS),
+	SNMP_MIB_ITEM("SctpT3Retransmits", SCTP_MIB_T3_RETRANSMITS),
+	SNMP_MIB_ITEM("SctpPmtudRetransmits", SCTP_MIB_PMTUD_RETRANSMITS),
+	SNMP_MIB_ITEM("SctpFastRetransmits", SCTP_MIB_FAST_RETRANSMITS),
+	SNMP_MIB_ITEM("SctpInPktDiscards", SCTP_MIB_IN_PKT_DISCARDS),
+	SNMP_MIB_ITEM("SctpInDataChunkDiscards", SCTP_MIB_IN_DATA_CHUNK_DISCARDS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -328,8 +340,8 @@ static int sctp_assocs_seq_show(struct s
 			   "%8p %8p %-3d %-3d %-2d %-4d %4d %8d %8d %7d %5lu %-5d %5d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash, assoc->assoc_id,
-			   (sk->sk_rcvbuf - assoc->rwnd),
 			   assoc->sndbuf_used,
+			   (sk->sk_rcvbuf - assoc->rwnd),
 			   sock_i_uid(sk), sock_i_ino(sk),
 			   epb->bind_addr.port,
 			   assoc->peer.port);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ead3f1b..525806b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2663,9 +2663,11 @@ sctp_disposition_t sctp_sf_eat_data_6_2(
 		break;
 	case SCTP_IERROR_HIGH_TSN:
 	case SCTP_IERROR_BAD_STREAM:
+		SCTP_INC_STATS(SCTP_MIB_IN_DATA_CHUNK_DISCARDS);
 		goto discard_noforce;
 	case SCTP_IERROR_DUP_TSN:
 	case SCTP_IERROR_IGNORE_TSN:
+		SCTP_INC_STATS(SCTP_MIB_IN_DATA_CHUNK_DISCARDS);
 		goto discard_force;
 	case SCTP_IERROR_NO_DATA:
 		goto consume;
@@ -3652,6 +3654,7 @@ sctp_disposition_t sctp_sf_pdiscard(cons
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
+	SCTP_INC_STATS(SCTP_MIB_IN_PKT_DISCARDS);
 	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
 
 	return SCTP_DISPOSITION_CONSUME;
@@ -4560,6 +4563,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(
 {
 	struct sctp_transport *transport = arg;
 
+	SCTP_INC_STATS(SCTP_MIB_T3_RTX_EXPIREDS);
+
 	if (asoc->overall_error_count >= asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
@@ -4662,6 +4667,7 @@ sctp_disposition_t sctp_sf_t1_init_timer
 	int attempts = asoc->init_err_counter + 1;
 
 	SCTP_DEBUG_PRINTK("Timer T1 expired (INIT).\n");
+	SCTP_INC_STATS(SCTP_MIB_T1_INIT_EXPIREDS);
 
 	if (attempts <= asoc->max_init_attempts) {
 		bp = (struct sctp_bind_addr *) &asoc->base.bind_addr;
@@ -4721,6 +4727,7 @@ sctp_disposition_t sctp_sf_t1_cookie_tim
 	int attempts = asoc->init_err_counter + 1;
 
 	SCTP_DEBUG_PRINTK("Timer T1 expired (COOKIE-ECHO).\n");
+	SCTP_INC_STATS(SCTP_MIB_T1_COOKIE_EXPIREDS);
 
 	if (attempts <= asoc->max_init_attempts) {
 		repl = sctp_make_cookie_echo(asoc, NULL);
@@ -4765,6 +4772,8 @@ sctp_disposition_t sctp_sf_t2_timer_expi
 	struct sctp_chunk *reply = NULL;
 
 	SCTP_DEBUG_PRINTK("Timer T2 expired.\n");
+	SCTP_INC_STATS(SCTP_MIB_T2_SHUTDOWN_EXPIREDS);
+
 	if (asoc->overall_error_count >= asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
@@ -4826,6 +4835,8 @@ sctp_disposition_t sctp_sf_t4_timer_expi
 	struct sctp_chunk *chunk = asoc->addip_last_asconf;
 	struct sctp_transport *transport = chunk->transport;
 
+	SCTP_INC_STATS(SCTP_MIB_T4_RTO_EXPIREDS);
+
 	/* ADDIP 4.1 B1) Increment the error counters and perform path failure
 	 * detection on the appropriate destination address as defined in
 	 * RFC2960 [5] section 8.1 and 8.2.
@@ -4892,6 +4903,7 @@ sctp_disposition_t sctp_sf_t5_timer_expi
 	struct sctp_chunk *reply = NULL;
 
 	SCTP_DEBUG_PRINTK("Timer T5 expired.\n");
+	SCTP_INC_STATS(SCTP_MIB_T5_SHUTDOWN_GUARD_EXPIREDS);
 
 	reply = sctp_make_abort(asoc, NULL, 0);
 	if (!reply)
@@ -4922,6 +4934,8 @@ sctp_disposition_t sctp_sf_autoclose_tim
 {
 	int disposition;
 
+	SCTP_INC_STATS(SCTP_MIB_AUTOCLOSE_EXPIREDS);
+
 	/* From 9.2 Shutdown of an Association
 	 * Upon receipt of the SHUTDOWN primitive from its upper
 	 * layer, the endpoint enters SHUTDOWN-PENDING state and


