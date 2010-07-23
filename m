From: frank.blaschka@de.ibm.com
Subject: [patch 4/8] [PATCH] qeth: avoid loop if ipa command response is missing
Date: Fri, 23 Jul 2010 11:15:06 +0200
Message-ID: <20100723091550.146404000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:47431 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=615-qeth-ipa-response.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If qeth issues an ipa command, but for some reasons the response
never comes back, qeth reaches a timeout.
Reset the irq_pending flag of the write channel in timeout handling
code and trigger a recovery to avoid endless looping for the following
ipa command.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 +
 drivers/s390/net/qeth_core_main.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-07-22 10:22:35.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-07-22 10:22:35.000000000 +0200
@@ -740,6 +740,7 @@ struct qeth_card {
 	struct qeth_qdio_info qdio;
 	struct qeth_perf_stats perf_stats;
 	int use_hard_stop;
+	int read_or_write_problem;
 	struct qeth_osn_info osn_info;
 	struct qeth_discipline discipline;
 	atomic_t force_alloc_skb;
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:35.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:35.000000000 +0200
@@ -262,6 +262,7 @@ static int qeth_issue_next_read(struct q
 		QETH_DBF_MESSAGE(2, "%s error in starting next read ccw! "
 			"rc=%i\n", dev_name(&card->gdev->dev), rc);
 		atomic_set(&card->read.irq_pending, 0);
+		card->read_or_write_problem = 1;
 		qeth_schedule_recovery(card);
 		wake_up(&card->wait_q);
 	}
@@ -382,6 +383,7 @@ void qeth_clear_ipacmd_list(struct qeth_
 		qeth_put_reply(reply);
 	}
 	spin_unlock_irqrestore(&card->lock, flags);
+	atomic_set(&card->write.irq_pending, 0);
 }
 EXPORT_SYMBOL_GPL(qeth_clear_ipacmd_list);
 
@@ -1076,6 +1078,7 @@ static int qeth_setup_card(struct qeth_c
 	card->state = CARD_STATE_DOWN;
 	card->lan_online = 0;
 	card->use_hard_stop = 0;
+	card->read_or_write_problem = 0;
 	card->dev = NULL;
 	spin_lock_init(&card->vlanlock);
 	spin_lock_init(&card->mclock);
@@ -1658,6 +1661,10 @@ int qeth_send_control_data(struct qeth_c
 
 	QETH_CARD_TEXT(card, 2, "sendctl");
 
+	if (card->read_or_write_problem) {
+		qeth_release_buffer(iob->channel, iob);
+		return -EIO;
+	}
 	reply = qeth_alloc_reply(card);
 	if (!reply) {
 		return -ENOMEM;
@@ -1729,6 +1736,9 @@ time_err:
 	spin_unlock_irqrestore(&reply->card->lock, flags);
 	reply->rc = -ETIME;
 	atomic_inc(&reply->received);
+	atomic_set(&card->write.irq_pending, 0);
+	qeth_release_buffer(iob->channel, iob);
+	card->write.buf_no = (card->write.buf_no + 1) % QETH_CMD_BUFFER_NO;
 	wake_up(&reply->wait_q);
 	rc = reply->rc;
 	qeth_put_reply(reply);
@@ -2485,6 +2495,10 @@ int qeth_send_ipa_cmd(struct qeth_card *
 	qeth_prepare_ipa_cmd(card, iob, prot_type);
 	rc = qeth_send_control_data(card, IPA_CMD_LENGTH,
 						iob, reply_cb, reply_param);
+	if (rc == -ETIME) {
+		qeth_clear_ipacmd_list(card);
+		qeth_schedule_recovery(card);
+	}
 	return rc;
 }
 EXPORT_SYMBOL_GPL(qeth_send_ipa_cmd);
@@ -3967,6 +3981,7 @@ retriable:
 		else
 			goto retry;
 	}
+	card->read_or_write_problem = 0;
 	rc = qeth_mpc_initialize(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);

