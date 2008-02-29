From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.26] [SCTP]: extend exported data in /proc/net/sctp/assoc
Date: Fri, 29 Feb 2008 10:19:25 -0500
Message-ID: <47C8227D.1050201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:15597 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbYB2PTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 10:19:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

RFC 3873  specifies several MIB objects that can't be obtained by the
current data set exported by /proc/sys/net/sctp/assoc.  This
patch adds the missing pieces of data that allow us to compute all the
objects in the sctpAssocTable object.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    8 ++++++++
 net/sctp/outqueue.c        |    3 +++
 net/sctp/proc.c            |   20 ++++++++++++++------
 net/sctp/sm_statefuns.c    |    2 ++
 4 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9c827a7..8966599 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1661,6 +1661,9 @@ struct sctp_association {
 	/* Transport to which SHUTDOWN chunk was last sent.  */
 	struct sctp_transport *shutdown_last_sent_to;
 
+	/* How many times have we resent a SHUTDOWN */
+	int shutdown_retries;
+
 	/* Transport to which INIT chunk was last sent.  */
 	struct sctp_transport *init_last_sent_to;
 
@@ -1695,6 +1698,11 @@ struct sctp_association {
 	 */
 	__u16 unack_data;
 
+	/* The total number of data chunks that we've had to retransmit
+	 * as the result of a T3 timer expiration
+	 */
+	__u32 rtx_data_chunks;
+
 	/* This is the association's receive buffer space.  This value is used
 	 * to set a_rwnd field in an INIT or a SACK chunk.
 	 */
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 1bb3c5c..fd4deef 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -494,6 +494,8 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 		 */
 		if (transport == transport->asoc->peer.retran_path)
 			sctp_assoc_update_retran_path(transport->asoc);
+		transport->asoc->rtx_data_chunks +=
+			transport->asoc->unack_data;
 		break;
 	case SCTP_RTXR_FAST_RTX:
 		SCTP_INC_STATS(SCTP_MIB_FAST_RETRANSMITS);
@@ -504,6 +506,7 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 		break;
 	case SCTP_RTXR_T1_RTX:
 		SCTP_INC_STATS(SCTP_MIB_T1_RETRANSMITS);
+		transport->asoc->init_retries++;
 		break;
 	default:
 		BUG();
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 9e214da..82bea30 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -281,8 +281,10 @@ static void * sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 		*pos = 0;
 
 	if (*pos == 0)
-		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
-				"RPORT LADDRS <-> RADDRS\n");
+		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
+				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
+				"RPORT LADDRS <-> RADDRS "
+				"HBINT INS OUTS MAXRT T1X T2X RTXC\n");
 
 	return (void *)pos;
 }
@@ -321,15 +323,21 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
 		seq_printf(seq,
-			   "%8p %8p %-3d %-3d %-2d %-4d %4d %8d %8d %7d %5lu %-5d %5d ",
+			   "%8p %8p %-3d %-3d %-2d %-4d "
+			   "%4d %8d %8d %7d %5lu %-5d %5d "
+			   "%8d %5d %5d %4d %4d %4d %8d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
-			   assoc->state, hash, assoc->assoc_id,
+			   assoc->state, hash,
+			   assoc->assoc_id,
 			   assoc->sndbuf_used,
 			   atomic_read(&assoc->rmem_alloc),
 			   sock_i_uid(sk), sock_i_ino(sk),
 			   epb->bind_addr.port,
-			   assoc->peer.port);
-
+			   assoc->peer.port,
+			   assoc->hbinterval, assoc->c.sinit_max_instreams,
+			   assoc->c.sinit_num_ostreams, assoc->max_retrans,
+			   assoc->init_retries, assoc->shutdown_retries,
+			   assoc->rtx_data_chunks);
 		seq_printf(seq, " ");
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "<-> ");
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f2ed647..ade0cbd 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5312,6 +5312,8 @@ sctp_disposition_t sctp_sf_t2_timer_expire(const struct sctp_endpoint *ep,
 	SCTP_DEBUG_PRINTK("Timer T2 expired.\n");
 	SCTP_INC_STATS(SCTP_MIB_T2_SHUTDOWN_EXPIREDS);
 
+	((struct sctp_association *)asoc)->shutdown_retries++;
+
 	if (asoc->overall_error_count >= asoc->max_retrans) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ETIMEDOUT));
-- 
1.5.2.5

