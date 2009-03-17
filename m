From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 11/30] solos: Add SNR and Attn to status packet, fix oops
 on load
Date: Tue, 17 Mar 2009 21:29:23 +0000
Message-ID: <1237325363.27681.340.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37659 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143AbZCQV31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:27 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqj-0001v9-03
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:25 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index b500f00..2978699 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -303,8 +303,8 @@ static char *next_string(struct sk_buff *skb)
  */       
 static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
 {
-	char *str, *end;
-	int ver, rate_up, rate_down, state;
+	char *str, *end, *state_str;
+	int ver, rate_up, rate_down, state, snr, attn;
 
 	if (!card->atmdev[port])
 		return -ENODEV;
@@ -330,19 +330,35 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	if (*end)
 		return -EIO;
 
-	str = next_string(skb);
-	if (!strcmp(str, "Showtime"))
+	state_str = next_string(skb);
+	if (!strcmp(state_str, "Showtime"))
 		state = ATM_PHY_SIG_FOUND;
 	else {
 		state = ATM_PHY_SIG_LOST;
 		release_vccs(card->atmdev[port]);
 	}
 
+	str = next_string(skb);
+	snr = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	str = next_string(skb);
+	attn = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	if (state == ATM_PHY_SIG_LOST && !rate_up && !rate_down)
+		dev_info(&card->dev->dev, "Port %d ATM state: %s\n",
+			 port, state_str);
+	else
+		dev_info(&card->dev->dev, "Port %d ATM state: %s (%d/%d kb/s, SNR %ddB, Attn %ddB)\n",
+			 port, state_str, rate_up/1000, rate_down/1000,
+			 snr, attn);
+
 	card->atmdev[port]->link_rate = rate_down;
 	card->atmdev[port]->signal = state;
 
-	dev_info(&card->dev->dev, "ATM state: '%s', %d/%d kb/s up/down.\n",
-		 str, rate_up/1000, rate_down/1000);
 	return 0;
 }
 
@@ -851,7 +867,7 @@ static int fpga_tx(struct solos_card *card)
 	dev_vdbg(&card->dev->dev, "TX Flags are %X\n", tx_pending);
 
 	for (port = 0; port < card->nr_ports; port++) {
-		if (!(tx_pending & (1 << port))) {
+		if (card->atmdev[port] && !(tx_pending & (1 << port))) {
 
 			spin_lock(&card->tx_queue_lock);
 			skb = skb_dequeue(&card->tx_queue[port]);
-- 
1.6.0.6



