From: frank.blaschka@de.ibm.com
Subject: [patch 6/6] [PATCH] qeth: fix wait_event_timeout handling
Date: Wed, 25 Mar 2009 07:57:19 +0100
Message-ID: <20090325065809.349207000@de.ibm.com>
References: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:35192 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755499AbZCYG6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:12 -0400
Content-Disposition: inline; filename=620-qeth-wait-event.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

wait_event_timeout just takes the numnber of jiffies to wait as
an argument. That value does not include jiffies itself.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c
+++ git_linus/drivers/s390/net/qeth_core_main.c
@@ -1676,7 +1676,7 @@ int qeth_send_control_data(struct qeth_c
 	int rc;
 	unsigned long flags;
 	struct qeth_reply *reply = NULL;
-	unsigned long timeout;
+	unsigned long timeout, event_timeout;
 	struct qeth_ipa_cmd *cmd;
 
 	QETH_DBF_TEXT(TRACE, 2, "sendctl");
@@ -1701,9 +1701,10 @@ int qeth_send_control_data(struct qeth_c
 	qeth_prepare_control_data(card, len, iob);
 
 	if (IS_IPA(iob->data))
-		timeout = jiffies + QETH_IPA_TIMEOUT;
+		event_timeout = QETH_IPA_TIMEOUT;
 	else
-		timeout = jiffies + QETH_TIMEOUT;
+		event_timeout = QETH_TIMEOUT;
+	timeout = jiffies + event_timeout;
 
 	QETH_DBF_TEXT(TRACE, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
@@ -1731,7 +1732,7 @@ int qeth_send_control_data(struct qeth_c
 	if ((cmd->hdr.command == IPA_CMD_SETIP) &&
 	    (cmd->hdr.prot_version == QETH_PROT_IPV4)) {
 		if (!wait_event_timeout(reply->wait_q,
-		    atomic_read(&reply->received), timeout))
+		    atomic_read(&reply->received), event_timeout))
 			goto time_err;
 	} else {
 		while (!atomic_read(&reply->received)) {

