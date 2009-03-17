From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 24/30] solos: Tidy up status interrupt handling, cope with
 'ERROR' status
Date: Tue, 17 Mar 2009 21:29:33 +0000
Message-ID: <1237325373.27681.353.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37672 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757572AbZCQV3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:45 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr1-0001w6-AR
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:43 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c54eceb..f27bd92 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -340,6 +340,12 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	str = next_string(skb);
 	if (!str)
 		return -EIO;
+	if (!strcmp(str, "ERROR")) {
+		dev_dbg(&card->dev->dev, "Status packet indicated Solos error on port %d (starting up?)\n",
+			 port);
+		return 0;
+	}
+
 	rate_up = simple_strtol(str, &end, 10);
 	if (*end)
 		return -EIO;
@@ -362,8 +368,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	}
 
 	if (state == ATM_PHY_SIG_LOST) {
-		dev_info(&card->dev->dev, "Port %d ATM state: %s\n",
-			 port, state_str);
+		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
 	} else {
 		char *snr, *attn;
 
@@ -374,7 +379,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 		if (!attn)
 			return -EIO;
 
-		dev_info(&card->dev->dev, "Port %d: %s (%d/%d kb/s%s%s%s%s)\n",
+		dev_info(&card->dev->dev, "Port %d: %s @%d/%d kb/s%s%s%s%s\n",
 			 port, state_str, rate_down/1000, rate_up/1000,
 			 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
 	}		
@@ -663,7 +668,11 @@ void solos_bh(unsigned long card_arg)
 				break;
 
 			case PKT_STATUS:
-				process_status(card, port, skb);
+				if (process_status(card, port, skb) &&
+				    net_ratelimit()) {
+					dev_warn(&card->dev->dev, "Bad status packet of %d bytes on port %d:\n", skb->len, port);
+					print_buffer(skb);
+				}
 				dev_kfree_skb_any(skb);
 				break;
 
-- 
1.6.0.6


