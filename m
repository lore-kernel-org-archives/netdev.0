From: frank.blaschka@de.ibm.com
Subject: [patch 4/7] [PATCH] qeth: allow HiperSockets framesize change in suspend
Date: Tue, 01 Feb 2011 09:16:51 +0100
Message-ID: <20110201081723.717261632@de.ibm.com>
References: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:40475 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1BAIR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:17:27 -0500
Content-Disposition: inline; filename=607-qeth-chparm-change.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For HiperSockets the framesize-definition determines the selected
mtu-size and the size of the allocated qdio buffers.
A framesize-change may occur while a Linux system with probed
HiperSockets device is in suspend state. This patch enables proper
resuming of a HiperSockets device in this case.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core_main.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1887,8 +1887,16 @@ static int qeth_ulp_enable_cb(struct qet
 			QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 			return 0;
 		}
-		card->info.max_mtu = mtu;
+		if (card->info.initial_mtu && (card->info.initial_mtu != mtu)) {
+			/* frame size has changed */
+			if (card->dev &&
+			    ((card->dev->mtu == card->info.initial_mtu) ||
+			     (card->dev->mtu > mtu)))
+				card->dev->mtu = mtu;
+			qeth_free_qdio_buffers(card);
+		}
 		card->info.initial_mtu = mtu;
+		card->info.max_mtu = mtu;
 		card->qdio.in_buf_size = mtu + 2 * PAGE_SIZE;
 	} else {
 		card->info.initial_mtu = qeth_get_initial_mtu_for_card(card);

