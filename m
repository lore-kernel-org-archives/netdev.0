From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] [PATCH] qeth: avoid recovery during device online setting
Date: Mon, 11 Jan 2010 13:50:51 +0100
Message-ID: <20100111125125.216556000@de.ibm.com>
References: <20100111125049.566359000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:53327 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab0AKMv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 07:51:27 -0500
Content-Disposition: inline; filename=605-qeth-avoid-recovery.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If a qeth device is set online, several initialisation steps are
performed. If a failure in one of these steps occurs, the qeth
device is reset into DOWN state. If due to the failure a qeth recovery
is scheduled and started in another thread, this might cause all kinds
of conflicts, even a kernel panic. The patch forbids scheduling of a
qeth recovery while online processing is performed till the card is in
state SOFTSETUP.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    1 -
 drivers/s390/net/qeth_l3_main.c |    2 --
 2 files changed, 3 deletions(-)

--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -927,7 +927,6 @@ static int __qeth_l2_set_online(struct c
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
-	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
 	recover_flag = card->state;
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3338,8 +3338,6 @@ static int __qeth_l3_set_online(struct c
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
-	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
-
 	recover_flag = card->state;
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {

