From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH] r8169: Add counters tx_bytes and rx_bytes for ethtool
Date: Tue, 25 May 2010 22:19:46 +0800
Message-ID: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48265 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab0EYO2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 10:28:04 -0400
Received: by pwi2 with SMTP id 2so1066711pwi.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 07:28:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Traffic stats counters (rx_bytes and tx_bytes) in net_device are
"unsigned long". On 32-bit systems, they wrap around every few
minutes, giving out wrong answers to the amount of traffic. To get the
right message, another available approach is "ethtool -S". However,
r8169 didn't support those two counters so far.

Add traffic counters tx_bytes and rx_bytes with 64-bit width for
ethtool. On 32-bit systems, gcc treats each one as two 32-bit
variables, making the increment not "atomic". But there is no sync
issue since the updates to the counters are serialized by driver logic
in any case. Results provided by ethtool maybe slightly biased if the
read and update operations are interleaved. But the results are much
better than the original ones that always fall into the range from 0
to 4GiB.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/r8169.c |   30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..19a2748 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -510,6 +510,8 @@ struct rtl8169_private {

 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
+	u64 tx_bytes;
+	u64 rx_bytes;
 	u32 saved_wolopts;
 };

@@ -1162,6 +1164,8 @@ static void rtl8169_set_msglevel(struct
net_device *dev, u32 value)
 static const char rtl8169_gstrings[][ETH_GSTRING_LEN] = {
 	"tx_packets",
 	"rx_packets",
+	"tx_bytes",
+	"rx_bytes",
 	"tx_errors",
 	"rx_errors",
 	"rx_missed",
@@ -1236,17 +1240,19 @@ static void rtl8169_get_ethtool_stats(struct
net_device *dev,

 	data[0] = le64_to_cpu(tp->counters.tx_packets);
 	data[1] = le64_to_cpu(tp->counters.rx_packets);
-	data[2] = le64_to_cpu(tp->counters.tx_errors);
-	data[3] = le32_to_cpu(tp->counters.rx_errors);
-	data[4] = le16_to_cpu(tp->counters.rx_missed);
-	data[5] = le16_to_cpu(tp->counters.align_errors);
-	data[6] = le32_to_cpu(tp->counters.tx_one_collision);
-	data[7] = le32_to_cpu(tp->counters.tx_multi_collision);
-	data[8] = le64_to_cpu(tp->counters.rx_unicast);
-	data[9] = le64_to_cpu(tp->counters.rx_broadcast);
-	data[10] = le32_to_cpu(tp->counters.rx_multicast);
-	data[11] = le16_to_cpu(tp->counters.tx_aborted);
-	data[12] = le16_to_cpu(tp->counters.tx_underun);
+	data[2] = tp->tx_bytes;
+	data[3] = tp->rx_bytes;
+	data[4] = le64_to_cpu(tp->counters.tx_errors);
+	data[5] = le32_to_cpu(tp->counters.rx_errors);
+	data[6] = le16_to_cpu(tp->counters.rx_missed);
+	data[7] = le16_to_cpu(tp->counters.align_errors);
+	data[8] = le32_to_cpu(tp->counters.tx_one_collision);
+	data[9] = le32_to_cpu(tp->counters.tx_multi_collision);
+	data[10] = le64_to_cpu(tp->counters.rx_unicast);
+	data[11] = le64_to_cpu(tp->counters.rx_broadcast);
+	data[12] = le32_to_cpu(tp->counters.rx_multicast);
+	data[13] = le16_to_cpu(tp->counters.tx_aborted);
+	data[14] = le16_to_cpu(tp->counters.tx_underun);
 }

 static void rtl8169_get_strings(struct net_device *dev, u32
stringset, u8 *data)
@@ -4412,6 +4418,7 @@ static void rtl8169_tx_interrupt(struct net_device *dev,

 		dev->stats.tx_bytes += len;
 		dev->stats.tx_packets++;
+		tp->tx_bytes += len;

 		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);

@@ -4567,6 +4574,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,

 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
+			tp->rx_bytes += pkt_size;
 		}

 		/* Work around for AMD plateform. */

--
