From: frank.blaschka@de.ibm.com
Subject: [patch 5/7] [PATCH] ctcm: use correct idal word list for ctcmpc
Date: Wed, 07 Mar 2012 13:06:27 +0100
Message-ID: <20120307120708.040677712@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Belinda Thompson <belindat@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:39298 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276Ab2CGMHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:14 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:11 -0000
Content-Disposition: inline; filename=612-ctcm-idal-list.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Belinda Thompson <belindat@us.ibm.com>

Communication Server Linux uses the ctcmpc code of the ctcm driver.
Sending problems have shown up caused by a wrong idal word list for
the first ccw. Function ctcmpc_chx_txdone() invokes the function
to prepare the idal word list without setting an appropriate length
for the first ccw, which may lead to an incomplete idal word list.
This patch sets the maximum buffer size as data length of the first 
ccw. Thus correct idal word lists are guaranteed in all cases.

Signed-off-by: Belinda Thompson <belindat@us.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/ctcm_fsms.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/ctcm_fsms.c linux-2.6-patched/drivers/s390/net/ctcm_fsms.c
--- linux-2.6/drivers/s390/net/ctcm_fsms.c	2012-01-05 00:55:44.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_fsms.c	2012-03-06 13:36:00.000000000 +0100
@@ -1341,6 +1341,12 @@ static void ctcmpc_chx_txdone(fsm_instan
 
 	spin_unlock(&ch->collect_lock);
 	clear_normalized_cda(&ch->ccw[1]);
+
+	CTCM_PR_DBGDATA("ccwcda=0x%p data=0x%p\n",
+			(void *)(unsigned long)ch->ccw[1].cda,
+			ch->trans_skb->data);
+	ch->ccw[1].count = ch->max_bufsize;
+
 	if (set_normalized_cda(&ch->ccw[1], ch->trans_skb->data)) {
 		dev_kfree_skb_any(ch->trans_skb);
 		ch->trans_skb = NULL;
@@ -1350,6 +1356,11 @@ static void ctcmpc_chx_txdone(fsm_instan
 		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
 		return;
 	}
+
+	CTCM_PR_DBGDATA("ccwcda=0x%p data=0x%p\n",
+			(void *)(unsigned long)ch->ccw[1].cda,
+			ch->trans_skb->data);
+
 	ch->ccw[1].count = ch->trans_skb->len;
 	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
 	ch->prof.send_stamp = current_kernel_time(); /* xtime */
