From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2 5/7] sctp: use limited socket backlog
Date: Wed,  3 Mar 2010 16:36:27 +0800
Message-ID: <1267605389-7369-5-git-send-email-yi.zhu@intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60230 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab0CCIet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:34:49 -0500
In-Reply-To: <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sctp adapt to the limited socket backlog change.

Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/sctp/input.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index c0c973e..20e69c3 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -75,7 +75,7 @@ static struct sctp_association *__sctp_lookup_association(
 					const union sctp_addr *peer,
 					struct sctp_transport **pt);
 
-static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
+static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
 
 
 /* Calculate the SCTP checksum of an SCTP packet.  */
@@ -265,8 +265,12 @@ int sctp_rcv(struct sk_buff *skb)
 	}
 
 	if (sock_owned_by_user(sk)) {
+		if (sctp_add_backlog(sk, skb)) {
+			sctp_bh_unlock_sock(sk);
+			sctp_chunk_free(chunk);
+			goto discard_release;
+		}
 		SCTP_INC_STATS_BH(SCTP_MIB_IN_PKT_BACKLOG);
-		sctp_add_backlog(sk, skb);
 	} else {
 		SCTP_INC_STATS_BH(SCTP_MIB_IN_PKT_SOFTIRQ);
 		sctp_inq_push(&chunk->rcvr->inqueue, chunk);
@@ -362,7 +366,7 @@ done:
 	return 0;
 }
 
-static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
+static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	struct sctp_chunk *chunk = SCTP_INPUT_CB(skb)->chunk;
 	struct sctp_ep_common *rcvr = chunk->rcvr;
@@ -377,7 +381,7 @@ static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 	else
 		BUG();
 
-	sk_add_backlog(sk, skb);
+	return sk_add_backlog_limited(sk, skb);
 }
 
 /* Handle icmp frag needed error. */
-- 
1.6.3.3

