From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: get rid of SCTP_DBG_TSNS entirely
Date: Mon,  1 Jul 2013 11:31:36 +0200
Message-ID: <1372671096-27129-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037Ab3GAJbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 05:31:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After having reworked the debugging framework, Neil and Vlad agreed to
get rid of the leftover SCTP_DBG_TSNS code for a couple of reasons:

We can use systemtap scripts to investigate these things, we now have
pr_debug() helpers that make life easier, and if we really need anything
else besides those tools, we will be forced to come up with something
better than we have there. Therefore, get rid of this ifdef debugging
code entirely for now.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: Neil Horman <nhorman@tuxdriver.com>
---
 On top of [PATCH net-next v4 0/2] Rework SCTP debugging framework.

 net/sctp/Kconfig    |   9 -----
 net/sctp/outqueue.c | 105 ----------------------------------------------------
 2 files changed, 114 deletions(-)

diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index d80bf1a..71c1a59 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -49,15 +49,6 @@ config NET_SCTPPROBE
         To compile this code as a module, choose M here: the
         module will be called sctp_probe.
 
-config SCTP_DBG_TSNS
-	bool "SCTP: Debug transactions"
-	help
-	  If you say Y, this will enable transaction debugging, visible
-	  from the kernel's dynamic debugging framework.
-
-	  If unsure, say N.  However, if you are running into problems, use 
-	  this option to gather outqueue trace information.
-
 config SCTP_DBG_OBJCNT
 	bool "SCTP: Debug object counts"
 	depends on PROC_FS
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 511b3b3..cb80a8e 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1335,21 +1335,6 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 	int bytes_acked = 0;
 	int migrate_bytes = 0;
 
-	/* These state variables are for coherent debug output. --xguo */
-
-#ifdef CONFIG_SCTP_DBG_TSNS
-	__u32 dbg_ack_tsn = 0;	/* An ACKed TSN range starts here... */
-	__u32 dbg_last_ack_tsn = 0;  /* ...and finishes here.	     */
-	__u32 dbg_kept_tsn = 0;	/* An un-ACKed range starts here...  */
-	__u32 dbg_last_kept_tsn = 0; /* ...and finishes here.	     */
-
-	/* 0 : The last TSN was ACKed.
-	 * 1 : The last TSN was NOT ACKed (i.e. KEPT).
-	 * -1: We need to initialize.
-	 */
-	int dbg_prt_state = -1;
-#endif /* CONFIG_SCTP_DBG_TSNS */
-
 	sack_ctsn = ntohl(sack->cum_tsn_ack);
 
 	INIT_LIST_HEAD(&tlist);
@@ -1471,49 +1456,6 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				 */
 				list_add_tail(lchunk, &tlist);
 			}
-
-#ifdef CONFIG_SCTP_DBG_TSNS
-			switch (dbg_prt_state) {
-			case 0:	/* last TSN was ACKed */
-				if (dbg_last_ack_tsn + 1 == tsn) {
-					/* This TSN belongs to the
-					 * current ACK range.
-					 */
-					break;
-				}
-
-				if (dbg_last_ack_tsn != dbg_ack_tsn) {
-					/* Display the end of the
-					 * current range.
-					 */
-					pr_cont("-%08x", dbg_last_ack_tsn);
-				}
-
-				/* Start a new range.  */
-				pr_cont(",%08x", tsn);
-				dbg_ack_tsn = tsn;
-				break;
-
-			case 1:	/* The last TSN was NOT ACKed. */
-				if (dbg_last_kept_tsn != dbg_kept_tsn) {
-					/* Display the end of current range. */
-					pr_cont("-%08x", dbg_last_kept_tsn);
-				}
-
-				pr_cont("\n");
-				/* FALL THROUGH... */
-			default:
-				/* This is the first-ever TSN we examined.  */
-				/* Start a new range of ACK-ed TSNs.  */
-				pr_debug("ACKed: %08x", tsn);
-
-				dbg_prt_state = 0;
-				dbg_ack_tsn = tsn;
-			}
-
-			dbg_last_ack_tsn = tsn;
-#endif /* CONFIG_SCTP_DBG_TSNS */
-
 		} else {
 			if (tchunk->tsn_gap_acked) {
 				pr_debug("%s: receiver reneged on data TSN:0x%x\n",
@@ -1537,56 +1479,9 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			}
 
 			list_add_tail(lchunk, &tlist);
-
-#ifdef CONFIG_SCTP_DBG_TSNS
-			/* See the above comments on ACK-ed TSNs. */
-			switch (dbg_prt_state) {
-			case 1:
-				if (dbg_last_kept_tsn + 1 == tsn)
-					break;
-
-				if (dbg_last_kept_tsn != dbg_kept_tsn)
-					pr_cont("-%08x", dbg_last_kept_tsn);
-
-				pr_cont(",%08x", tsn);
-				dbg_kept_tsn = tsn;
-				break;
-
-			case 0:
-				if (dbg_last_ack_tsn != dbg_ack_tsn)
-					pr_cont("-%08x", dbg_last_ack_tsn);
-
-				pr_cont("\n");
-				/* FALL THROUGH... */
-			default:
-				pr_debug("KEPT: %08x", tsn);
-
-				dbg_prt_state = 1;
-				dbg_kept_tsn = tsn;
-			}
-
-			dbg_last_kept_tsn = tsn;
-#endif /* CONFIG_SCTP_DBG_TSNS */
 		}
 	}
 
-#ifdef CONFIG_SCTP_DBG_TSNS
-	/* Finish off the last range, displaying its ending TSN.  */
-	switch (dbg_prt_state) {
-	case 0:
-		if (dbg_last_ack_tsn != dbg_ack_tsn)
-			pr_cont("-%08x\n", dbg_last_ack_tsn);
-		else
-			pr_cont("\n");
-		break;
-	case 1:
-		if (dbg_last_kept_tsn != dbg_kept_tsn)
-			pr_cont("-%08x\n", dbg_last_kept_tsn);
-		else
-			pr_cont("\n");
-		break;
-	}
-#endif /* CONFIG_SCTP_DBG_TSNS */
 	if (transport) {
 		if (bytes_acked) {
 			struct sctp_association *asoc = transport->asoc;
-- 
1.7.11.7
