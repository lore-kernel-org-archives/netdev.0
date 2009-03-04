From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] smsc911x: improve EEPROM loading timeout logic in open
Date: Wed,  4 Mar 2009 17:33:25 +0000
Message-ID: <1236188005-14065-2-git-send-email-steve.glendinning@smsc.com>
References: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
Cc: Roel Kluin <roel.kluin@gmail.com>,
	Juha Leppanen <juha_motorsportcom@luukku.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:37269 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753514AbZCDRd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 12:33:29 -0500
In-Reply-To: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch from Juha Leppanen suppresses a false warning if the eeprom
load succeeds on the very last attempt.

Juha> In function smsc911x_open smsc911x_reg_read+udelay can be run 50
Juha> times with timeout reaching -1, and the following if statetement
Juha> does not catch the timeout and no warning is issued. Also if the
Juha> 50th smsc911x_reg_read is GOOD, loop is exited with timeout as 0
Juha> and bogus warning issued.  Replace testing order and --timeout
Juha> instead of timeout-- and now max 50 smsc911x_reg_read's are done,
Juha> with max 49 udelays.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 9a79510..ad15aab 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1162,8 +1162,8 @@ static int smsc911x_open(struct net_device *dev)
 
 	/* Make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout = 50;
-	while ((timeout--) &&
-	       (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_)) {
+	while ((smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_) &&
+	       --timeout) {
 		udelay(10);
 	}
 
-- 
1.6.0.6

