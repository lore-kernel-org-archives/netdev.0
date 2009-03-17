From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 27/30] solos: Swap upstream/downstream rates in status
 packet, clean up some more
Date: Tue, 17 Mar 2009 21:29:35 +0000
Message-ID: <1237325375.27681.357.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37675 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758435AbZCQV3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:49 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr5-0001wG-Bq
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:47 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   51 +++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 7c26bd2..eef920a 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -314,14 +314,16 @@ static char *next_string(struct sk_buff *skb)
  * for the information therein. Fields are....
  *
  *     packet version
- *     TxBitRate	(version >= 1)
  *     RxBitRate	(version >= 1)
+ *     TxBitRate	(version >= 1)
  *     State		(version >= 1)
+ *     LocalSNRMargin	(version >= 1)
+ *     LocalLineAttn	(version >= 1)
  */       
 static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
 {
-	char *str, *end, *state_str;
-	int ver, rate_up, rate_down, state;
+	char *str, *end, *state_str, *snr, *attn;
+	int ver, rate_up, rate_down;
 
 	if (!card->atmdev[port])
 		return -ENODEV;
@@ -346,45 +348,42 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 		return 0;
 	}
 
-	rate_up = simple_strtol(str, &end, 10);
+	rate_down = simple_strtol(str, &end, 10);
 	if (*end)
 		return -EIO;
 
 	str = next_string(skb);
 	if (!str)
 		return -EIO;
-	rate_down = simple_strtol(str, &end, 10);
+	rate_up = simple_strtol(str, &end, 10);
 	if (*end)
 		return -EIO;
 
 	state_str = next_string(skb);
 	if (!state_str)
 		return -EIO;
-	if (!strcmp(state_str, "Showtime"))
-		state = ATM_PHY_SIG_FOUND;
-	else {
-		state = ATM_PHY_SIG_LOST;
+
+	/* Anything but 'Showtime' is down */
+	if (strcmp(state_str, "Showtime")) {
+		card->atmdev[port]->signal = ATM_PHY_SIG_LOST;
 		release_vccs(card->atmdev[port]);
+		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
+		return 0;
 	}
 
-	if (state == ATM_PHY_SIG_LOST) {
-		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
-	} else {
-		char *snr, *attn;
-
-		snr = next_string(skb);
-		if (!str)
-			return -EIO;
-		attn = next_string(skb);
-		if (!attn)
-			return -EIO;
-
-		dev_info(&card->dev->dev, "Port %d: %s @%d/%d kb/s%s%s%s%s\n",
-			 port, state_str, rate_down/1000, rate_up/1000,
-			 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
-	}		
+	snr = next_string(skb);
+	if (!str)
+		return -EIO;
+	attn = next_string(skb);
+	if (!attn)
+		return -EIO;
+
+	dev_info(&card->dev->dev, "Port %d: %s @%d/%d kb/s%s%s%s%s\n",
+		 port, state_str, rate_down/1000, rate_up/1000,
+		 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
+	
 	card->atmdev[port]->link_rate = rate_down / 424;
-	card->atmdev[port]->signal = state;
+	card->atmdev[port]->signal = ATM_PHY_SIG_FOUND;
 
 	return 0;
 }
-- 
1.6.0.6


