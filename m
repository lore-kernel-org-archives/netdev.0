From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 20/30] solos: Fix various bugs in status packet handling
Date: Tue, 17 Mar 2009 21:29:31 +0000
Message-ID: <1237325371.27681.349.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37668 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758272AbZCQV3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:39 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqv-0001vu-Lf
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:37 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   49 ++++++++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 8121f85..5e228a3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -293,13 +293,15 @@ static char *next_string(struct sk_buff *skb)
 {
 	int i = 0;
 	char *this = skb->data;
-
-	while (i < skb->len) {
+	
+	for (i = 0; i < skb->len; i++) {
 		if (this[i] == '\n') {
 			this[i] = 0;
-			skb_pull(skb, i);
+			skb_pull(skb, i + 1);
 			return this;
 		}
+		if (!isprint(this[i]))
+			return NULL;
 	}
 	return NULL;
 }
@@ -316,7 +318,7 @@ static char *next_string(struct sk_buff *skb)
 static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
 {
 	char *str, *end, *state_str;
-	int ver, rate_up, rate_down, state, snr, attn;
+	int ver, rate_up, rate_down, state;
 
 	if (!card->atmdev[port])
 		return -ENODEV;
@@ -333,16 +335,22 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	}
 
 	str = next_string(skb);
+	if (!str)
+		return -EIO;
 	rate_up = simple_strtol(str, &end, 10);
 	if (*end)
 		return -EIO;
 
 	str = next_string(skb);
+	if (!str)
+		return -EIO;
 	rate_down = simple_strtol(str, &end, 10);
 	if (*end)
 		return -EIO;
 
 	state_str = next_string(skb);
+	if (!state_str)
+		return -EIO;
 	if (!strcmp(state_str, "Showtime"))
 		state = ATM_PHY_SIG_FOUND;
 	else {
@@ -350,25 +358,24 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 		release_vccs(card->atmdev[port]);
 	}
 
-	str = next_string(skb);
-	snr = simple_strtol(str, &end, 10);
-	if (*end)
-		return -EIO;
-
-	str = next_string(skb);
-	attn = simple_strtol(str, &end, 10);
-	if (*end)
-		return -EIO;
-
-	if (state == ATM_PHY_SIG_LOST && !rate_up && !rate_down)
+	if (state == ATM_PHY_SIG_LOST) {
 		dev_info(&card->dev->dev, "Port %d ATM state: %s\n",
 			 port, state_str);
-	else
-		dev_info(&card->dev->dev, "Port %d ATM state: %s (%d/%d kb/s, SNR %ddB, Attn %ddB)\n",
-			 port, state_str, rate_up/1000, rate_down/1000,
-			 snr, attn);
-
-	card->atmdev[port]->link_rate = rate_down;
+	} else {
+		char *snr, *attn;
+
+		snr = next_string(skb);
+		if (!str)
+			return -EIO;
+		attn = next_string(skb);
+		if (!attn)
+			return -EIO;
+
+		dev_info(&card->dev->dev, "Port %d: %s (%d/%d kb/s%s%s%s%s)\n",
+			 port, state_str, rate_down/1000, rate_up/1000,
+			 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
+	}		
+	card->atmdev[port]->link_rate = rate_down / 424;
 	card->atmdev[port]->signal = state;
 
 	return 0;
-- 
1.6.0.6


