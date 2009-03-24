From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 7/9] [PATCH] ctcm: fix minor findings from code analysis tool
Date: Tue, 24 Mar 2009 13:29:11 +0100
Message-ID: <20090324124336.211792000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	"Joel A. Fowler" <fowlerja@us.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:53500 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758419AbZCXMnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:39 -0400
Content-Disposition: inline; filename=626-ctcm-beam.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joel A. Fowler <fowlerja@us.ibm.com>
From: Ursula Braun <ursula.braun@de.ibm.com>

This patch fixes problems in the ctcm driver identified by
static code analysis:
o remove an unnecessary always true condition in ctcm_unpack_skb
o remove duplicate assignment in ctc_mpc_alloc_channel
o remove an unnecessary always true condition in ctcmpc_send_sweep_resp
o remove duplicate initialization in ctcmpc_unpack_skb
o shorten if condition in mpc_action_go_inop
o remove INOP event if mpc group is undefined in mpc_action_doxid7

Signed-off-by: Joel A. Fowler <fowlerja@us.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |    8 +++-----
 drivers/s390/net/ctcm_mpc.c  |   17 +++++------------
 2 files changed, 8 insertions(+), 17 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_main.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.c
@@ -168,11 +168,9 @@ void ctcm_unpack_skb(struct channel *ch,
 		if (len > 0) {
 			skb_pull(pskb, header->length);
 			if (skb_tailroom(pskb) < LL_HEADER_LENGTH) {
-				if (!(ch->logflags & LOG_FLAG_OVERRUN)) {
-					CTCM_DBF_DEV_NAME(TRACE, dev,
-						"Overrun in ctcm_unpack_skb");
-					ch->logflags |= LOG_FLAG_OVERRUN;
-				}
+				CTCM_DBF_DEV_NAME(TRACE, dev,
+					"Overrun in ctcm_unpack_skb");
+				ch->logflags |= LOG_FLAG_OVERRUN;
 				return;
 			}
 			skb_put(pskb, LL_HEADER_LENGTH);
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_mpc.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
@@ -393,7 +393,6 @@ int ctc_mpc_alloc_channel(int port_num, 
 		} else {
 			/* there are problems...bail out	    */
 			/* there may be a state mismatch so restart */
-			grp->port_persist = 1;
 			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 			grp->allocchan_callback_retries = 0;
 		}
@@ -699,11 +698,9 @@ static void ctcmpc_send_sweep_resp(struc
 	return;
 
 done:
-	if (rc != 0) {
-		grp->in_sweep = 0;
-		ctcm_clear_busy_do(dev);
-		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-	}
+	grp->in_sweep = 0;
+	ctcm_clear_busy_do(dev);
+	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 
 	return;
 }
@@ -1118,7 +1115,6 @@ static void ctcmpc_unpack_skb(struct cha
 
 		if (unlikely(fsm_getstate(grp->fsm) != MPCG_STATE_READY))
 					goto done;
-		pdu_last_seen = 0;
 		while ((pskb->len > 0) && !pdu_last_seen) {
 			curr_pdu = (struct pdu *)pskb->data;
 
@@ -1396,8 +1392,7 @@ static void mpc_action_go_inop(fsm_insta
 				CTCM_FUNTAIL, dev->name);
 	if ((grp->saved_state != MPCG_STATE_RESET) ||
 		/* dealloc_channel has been called */
-			((grp->saved_state == MPCG_STATE_RESET) &&
-						(grp->port_persist == 0)))
+		(grp->port_persist == 0))
 		fsm_deltimer(&priv->restart_timer);
 
 	wch = priv->channel[WRITE];
@@ -1917,10 +1912,8 @@ static void mpc_action_doxid7(fsm_instan
 
 	if (priv)
 		grp = priv->mpcg;
-	if (grp == NULL) {
-		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	if (grp == NULL)
 		return;
-	}
 
 	for (direction = READ; direction <= WRITE; direction++)	{
 		struct channel *ch = priv->channel[direction];

