From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 08/30] solos: Handle new line status change packets, hook
 up to ATM layer info
Date: Tue, 17 Mar 2009 21:29:16 +0000
Message-ID: <1237325356.27681.337.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37656 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757763AbZCQV3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:23 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqe-0001v0-Lj
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:20 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 92 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index b0c4676..4c87dfb 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -82,6 +82,7 @@ struct pkt_hdr {
 #define PKT_COMMAND	1
 #define PKT_POPEN	3
 #define PKT_PCLOSE	4
+#define PKT_STATUS	5
 
 struct solos_card {
 	void __iomem *config_regs;
@@ -275,6 +276,72 @@ static ssize_t solos_param_store(struct device *dev, struct device_attribute *at
 	return ret;
 }
 
+static char *next_string(struct sk_buff *skb)
+{
+	int i = 0;
+	char *this = skb->data;
+
+	while (i < skb->len) {
+		if (this[i] == '\n') {
+			this[i] = 0;
+			skb_pull(skb, i);
+			return this;
+		}
+	}
+	return NULL;
+}
+
+/*
+ * Status packet has fields separated by \n, starting with a version number
+ * for the information therein. Fields are....
+ *
+ *     packet version
+ *     TxBitRate	(version >= 1)
+ *     RxBitRate	(version >= 1)
+ *     State		(version >= 1)
+ */       
+static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
+{
+	char *str, *end;
+	int ver, rate_up, rate_down, state;
+
+	if (!card->atmdev[port])
+		return -ENODEV;
+
+	str = next_string(skb);
+	if (!str)
+		return -EIO;
+
+	ver = simple_strtol(str, NULL, 10);
+	if (ver < 1) {
+		dev_warn(&card->dev->dev, "Unexpected status interrupt version %d\n",
+			 ver);
+		return -EIO;
+	}
+
+	str = next_string(skb);
+	rate_up = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	str = next_string(skb);
+	rate_down = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	str = next_string(skb);
+	if (!strcmp(str, "Showtime"))
+		state = ATM_PHY_SIG_FOUND;
+	else state = ATM_PHY_SIG_LOST;
+
+	card->atmdev[port]->link_rate = rate_down;
+	card->atmdev[port]->signal = state;
+
+	dev_info(&card->dev->dev, "ATM state: '%s', %d/%d kb/s up/down.\n",
+		 str, rate_up/1000, rate_down/1000);
+	return 0;
+}
+
 static int process_command(struct solos_card *card, int port, struct sk_buff *skb)
 {
 	struct solos_param *prm;
@@ -512,7 +579,7 @@ void solos_bh(unsigned long card_arg)
 
 			size = le16_to_cpu(header.size);
 
-			skb = alloc_skb(size, GFP_ATOMIC);
+			skb = alloc_skb(size + 1, GFP_ATOMIC);
 			if (!skb) {
 				if (net_ratelimit())
 					dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
@@ -547,6 +614,11 @@ void solos_bh(unsigned long card_arg)
 				atomic_inc(&vcc->stats->rx);
 				break;
 
+			case PKT_STATUS:
+				process_status(card, port, skb);
+				dev_kfree_skb(skb);
+				break;
+
 			case PKT_COMMAND:
 			default: /* FIXME: Not really, surely? */
 				if (process_command(card, port, skb))
@@ -996,6 +1068,9 @@ static int atm_init(struct solos_card *card)
 	int i;
 
 	for (i = 0; i < card->nr_ports; i++) {
+		struct sk_buff *skb;
+		struct pkt_hdr *header;
+
 		skb_queue_head_init(&card->tx_queue[i]);
 		skb_queue_head_init(&card->cli_queue[i]);
 
@@ -1016,6 +1091,22 @@ static int atm_init(struct solos_card *card)
 		card->atmdev[i]->ci_range.vci_bits = 16;
 		card->atmdev[i]->dev_data = card;
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
+		card->atmdev[i]->signal = ATM_PHY_SIG_UNKNOWN;
+
+		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
+		if (!skb) {
+			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in atm_init()\n");
+			continue;
+		}
+
+		header = (void *)skb_put(skb, sizeof(*header));
+
+		header->size = cpu_to_le16(0);
+		header->vpi = cpu_to_le16(0);
+		header->vci = cpu_to_le16(0);
+		header->type = cpu_to_le16(PKT_STATUS);
+
+		fpga_queue(card, i, skb, NULL);
 	}
 	return 0;
 }
-- 
1.6.0.6


