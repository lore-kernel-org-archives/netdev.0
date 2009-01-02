From: frank.blaschka@de.ibm.com
Subject: [patch 4/6] qeth: do not spin for SETIP ip assist command
Date: Fri, 02 Jan 2009 16:01:43 +0100
Message-ID: <20090102150255.266826000@de.ibm.com>
References: <20090102150139.830998000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:37521 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148AbZABPDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 10:03:54 -0500
Content-Disposition: inline; filename=608-qeth-nospin.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

The ip assist hw command for setting an IP address last unacceptable
long so we can not spin while we waiting for the irq. Since we can
ensure process context for all occurrences of this command we can use
wait.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   40 +++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:07.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:07.000000000 +0100
@@ -1685,6 +1685,7 @@ int qeth_send_control_data(struct qeth_c
 	unsigned long flags;
 	struct qeth_reply *reply = NULL;
 	unsigned long timeout;
+	struct qeth_ipa_cmd *cmd;
 
 	QETH_DBF_TEXT(TRACE, 2, "sendctl");
 
@@ -1731,17 +1732,34 @@ int qeth_send_control_data(struct qeth_c
 		wake_up(&card->wait_q);
 		return rc;
 	}
-	while (!atomic_read(&reply->received)) {
-		if (time_after(jiffies, timeout)) {
-			spin_lock_irqsave(&reply->card->lock, flags);
-			list_del_init(&reply->list);
-			spin_unlock_irqrestore(&reply->card->lock, flags);
-			reply->rc = -ETIME;
-			atomic_inc(&reply->received);
-			wake_up(&reply->wait_q);
-		}
-		cpu_relax();
-	};
+
+	/* we have only one long running ipassist, since we can ensure
+	   process context of this command we can sleep */
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	if ((cmd->hdr.command == IPA_CMD_SETIP) &&
+	    (cmd->hdr.prot_version == QETH_PROT_IPV4)) {
+		if (!wait_event_timeout(reply->wait_q,
+		    atomic_read(&reply->received), timeout))
+			goto time_err;
+	} else {
+		while (!atomic_read(&reply->received)) {
+			if (time_after(jiffies, timeout))
+				goto time_err;
+			cpu_relax();
+		};
+	}
+
+	rc = reply->rc;
+	qeth_put_reply(reply);
+	return rc;
+
+time_err:
+	spin_lock_irqsave(&reply->card->lock, flags);
+	list_del_init(&reply->list);
+	spin_unlock_irqrestore(&reply->card->lock, flags);
+	reply->rc = -ETIME;
+	atomic_inc(&reply->received);
+	wake_up(&reply->wait_q);
 	rc = reply->rc;
 	qeth_put_reply(reply);
 	return rc;

-- 
