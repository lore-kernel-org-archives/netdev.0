From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 4/5] lcs: Channel errors drive lcs_recovery which leads to kernel panic.
Date: Fri, 05 Oct 2007 16:45:47 +0200
Message-ID: <20071005144824.199472000@linux.vnet.ibm.com>
References: <20071005144543.448852000@linux.vnet.ibm.com>
Cc: "Klaus D. Wacker" <kdwacker@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:52949 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762031AbXJEOs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 10:48:27 -0400
Content-Disposition: inline; filename=710-lcs-panic.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Klaus D. Wacker <kdwacker@de.ibm.com>

When the lcs irq routine detects channel failures it drives device recovery.
After this event the device is no longer usable for shutdown requests,
because the lcs_irq routine may get wrong channel status information.
In such a case the lcs_irq routine marks the channel in 'error' state.
The channel state comes back to 'running' after restarting the channels.

Signed-off-by: Klaus D. Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/lcs.c |   11 ++++++++---
 drivers/s390/net/lcs.h |    1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/lcs.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/lcs.c
+++ linux-2.6-uschi/drivers/s390/net/lcs.c
@@ -1400,11 +1400,14 @@ lcs_irq(struct ccw_device *cdev, unsigne
 		PRINT_WARN("check on device %s, dstat=0x%X, cstat=0x%X \n",
 			    cdev->dev.bus_id, dstat, cstat);
 		if (rc) {
-			lcs_schedule_recovery(card);
-			wake_up(&card->wait_q);
-			return;
+			channel->state = LCS_CH_STATE_ERROR;
 		}
 	}
+	if (channel->state == LCS_CH_STATE_ERROR) {
+		lcs_schedule_recovery(card);
+		wake_up(&card->wait_q);
+		return;
+	}
 	/* How far in the ccw chain have we processed? */
 	if ((channel->state != LCS_CH_STATE_INIT) &&
 	    (irb->scsw.fctl & SCSW_FCTL_START_FUNC)) {
@@ -1708,6 +1711,8 @@ lcs_stopcard(struct lcs_card *card)
 
 	if (card->read.state != LCS_CH_STATE_STOPPED &&
 	    card->write.state != LCS_CH_STATE_STOPPED &&
+	    card->read.state != LCS_CH_STATE_ERROR &&
+	    card->write.state != LCS_CH_STATE_ERROR &&
 	    card->state == DEV_STATE_UP) {
 		lcs_clear_multicast_list(card);
 		rc = lcs_send_stoplan(card,LCS_INITIATOR_TCPIP);
Index: linux-2.6-uschi/drivers/s390/net/lcs.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/lcs.h
+++ linux-2.6-uschi/drivers/s390/net/lcs.h
@@ -138,6 +138,7 @@ enum lcs_channel_states {
 	LCS_CH_STATE_RUNNING,
 	LCS_CH_STATE_SUSPENDED,
 	LCS_CH_STATE_CLEARED,
+	LCS_CH_STATE_ERROR,
 };
 
 /**

-- 
